//
//  VoiceML.swift
//  VoiceML
//
//  Created by Steven Yonanta Siswanto on 20/07/18.
//  Copyright © 2018 SJ Dev. All rights reserved.
//

import Foundation
import Speech

public class VoiceML: NSObject, SFSpeechRecognizerDelegate {
    let locale: Locale
    weak var delegate: VoiceMLDelegate?
    
    lazy var speechRecognizer: SFSpeechRecognizer? = {
        let sf = SFSpeechRecognizer(locale: locale)
        sf?.delegate = self
        return sf
    }()
    
    public init(withLocale locale: Locale, delegate: VoiceMLDelegate?) {
        self.locale = locale
        super.init()
        self.delegate = delegate
    }

    public func checkAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (status) in
            self.delegate?.vmlAuthorizationResult(status: status)
        }
    }
    
}

public protocol VoiceMLDelegate: NSObjectProtocol {
    func vmlAuthorizationResult(status: SFSpeechRecognizerAuthorizationStatus)
}
