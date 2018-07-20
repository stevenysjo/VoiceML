//
//  VMLClassifier.swift
//  VoiceML
//
//  Created by Steven on 20/7/18.
//  Copyright © 2018 SJ Dev. All rights reserved.
//

import Foundation
import CoreML

class VMLClassifier {
    private let model = VMLModel()
    
    func analyze(text: String) -> VMLModelOutput? {
        let counts = bagOfWords(text: text)
        do {
            let prediction = try model.prediction(text: counts)
            return prediction
        } catch {
            return nil
        }
    }
    
    private func bagOfWords(text: String) -> [String: Double] {
        var bagOfWords = [String: Double]()
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagScheme.tokenType], options: 0)
        let range = NSRange(location: 0, length: text.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.string = text
        tagger.enumerateTags(in: range, unit: .word, scheme: NSLinguisticTagScheme.tokenType, options: options) { _, tokenRange, _ in
            let word = (text as NSString).substring(with: tokenRange)
            if bagOfWords[word] != nil {
                bagOfWords[word]! += 1
            } else {
                bagOfWords[word] = 1
            }
        }
        
        return bagOfWords
    }
}

