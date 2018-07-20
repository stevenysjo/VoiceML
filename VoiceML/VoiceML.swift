//
//  VoiceML.swift
//  VoiceML
//
//  Created by Steven Yonanta Siswanto on 20/07/18.
//  Copyright © 2018 SJ Dev. All rights reserved.
//

import Foundation
import Speech

@available(iOS 10.0, *)
public class VoiceML: NSObject, SFSpeechRecognizerDelegate {
    let locale: Locale
    weak var delegate: VoiceMLDelegate?
    var audioRecorder: VMLAudioRecorder?
    
    public var isAudioEngineRunning: Bool {
        get {
            return audioRecorder?.isAudioEngineRunning == true
        }
    }
    
    lazy var speechRecognizer: SFSpeechRecognizer? = {
        let sf = SFSpeechRecognizer(locale: self.locale)
        sf?.delegate = self
        return sf
    }()
    
    public init(withLocale locale: Locale, delegate: VoiceMLDelegate?) {
        self.locale = locale
        super.init()
        self.delegate = delegate
    }

    public func checkAuthorization() {
        VMLAuthorizer.requestAuthorization { (status) in
            self.delegate?.vmlAuthorizationResult(status: status)
        }
    }
    
    public func startRecording() {
        stopRecording()
        guard let sr = speechRecognizer else {
            return
        }
        audioRecorder = VMLAudioRecorder(withSpeechRecognizer: sr, delegate: self)
        audioRecorder?.startRecording()
    }
    
    public func stopRecording() {
        audioRecorder?.stopRecording()
    }
    
    func analyzeText(_ text: String) {
        if #available(iOS 11.0, *) {
            delegate?.getAnalyzedResult(VMLClassifier().analyze(text: text))
        }
    }
}

@available(iOS 10.0, *)
extension VoiceML: VMLAudioRecorderDelegate {
    func audioRecordingFailed(error: String) {
        delegate?.audioRecordingFailed(error: error)
    }
    
    func audioRecordingStarted() {
        delegate?.audioRecordingStarted()
    }
    
    func audioRecordingResult(_ result: String?) {
        delegate?.audioRecordingResult(result)
        if let r = result {
            analyzeText(r)
        }
    }
}

public protocol VoiceMLDelegate: NSObjectProtocol {
    func vmlAuthorizationResult(status: VMLAuthorizationStatus)
    func audioRecordingFailed(error: String)
    func audioRecordingStarted()
    func audioRecordingResult(_ result: String?)
    func getAnalyzedResult(_ result: String?)
}
