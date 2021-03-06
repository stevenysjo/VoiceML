//
//  VMLClassifier.swift
//  VoiceML
//
//  Created by Steven on 20/7/18.
//  Copyright © 2018 SJ Dev. All rights reserved.
//

import Foundation
import CoreML

@available(iOS 11.0, *)
class VMLClassifier {
    private let model = VMLModel()
    
    func analyze(text: String) -> (String?, Double?) {
        let counts = bagOfWords(text: text)
        do {
            let prediction = try model.prediction(text: counts)
            return (prediction.label, prediction.labelProbability[prediction.label])
        } catch {
            return (nil, nil)
        }
    }
    
    private func bagOfWords(text: String) -> [String: Double] {
        var bagOfWords = [String: Double]()
        let tagger = NSLinguisticTagger(tagSchemes: [NSLinguisticTagSchemeTokenType], options: 0)
        let range = NSRange(location: 0, length: text.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.string = text
        tagger.enumerateTags(in: range, unit: .word, scheme: NSLinguisticTagSchemeTokenType, options: options) { _, tokenRange, _ in
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

