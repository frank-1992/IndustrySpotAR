//
//  ARViewController+Recorder.swift
//  IndustryAR
//
//  Created by 吴熠 on 3/29/23.
//

import Foundation
import ARVideoKit

extension ARViewController: RecordARDelegate {
    func recorder(didEndRecording path: URL, with noError: Bool) {
        
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        
    }
    
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {
        
    }
    
    
}
