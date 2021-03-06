//
//  VMLAuthorizer.swift
//  VoiceML
//
//  Created by Steven on 20/7/18.
//  Copyright © 2018 SJ Dev. All rights reserved.
//

import Foundation
import Speech

class VMLAuthorizer: NSObject {
    static func requestAuthorization(_ completion:@escaping (_ status: VMLAuthorizationStatus)->()) {
        if #available(iOS 10.0, *) {
            SFSpeechRecognizer.requestAuthorization { (status) in
                switch status {
                case .notDetermined: completion(.notDetermined)
                case .denied: completion(.denied)
                case .restricted: completion(.restricted)
                case .authorized: completion(.authorized)
                }
            }
        } else {
            completion(.denied)
        }
    }
}

public enum VMLAuthorizationStatus : Int {
    case notDetermined
    case denied
    case restricted
    case authorized
}
