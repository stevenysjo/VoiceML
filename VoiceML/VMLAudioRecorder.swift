//
//  VMLAudioRecorder.swift
//  VoiceML
//
//  Created by Steven on 20/7/18.
//  Copyright © 2018 SJ Dev. All rights reserved.
//

import Foundation
import Speech

class VMLAudioRecorder {
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var isAudioEngineRunning: Bool {
        get {
            return audioEngine.isRunning
        }
    }
    
    let delegate: VMLAudioRecorderDelegate?
    let speechRecognizer: SFSpeechRecognizer
    
    init(withSpeechRecognizer sr: SFSpeechRecognizer, delegate: VMLAudioRecorderDelegate?) {
        self.speechRecognizer = sr
        self.delegate = delegate
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            delegate?.audioRecordingFailed(error: "audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            delegate?.audioRecordingFailed(error: "Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if let r = result {
                self.delegate?.audioRecordingResult(r.bestTranscription.formattedString)
                isFinal = r.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            delegate?.audioRecordingFailed(error: "audioEngine couldn't start because of an error.")
        }
        
        delegate?.audioRecordingStarted()
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

protocol VMLAudioRecorderDelegate {
    func audioRecordingFailed(error: String)
    func audioRecordingStarted()
    func audioRecordingResult(_ result: String?)
}
