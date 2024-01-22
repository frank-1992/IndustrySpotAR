//
//  UserDefaults+Extension.swift
//  IndustryAR
//
//  Created by 吴熠 on 2/4/23.
//

import Foundation
import UIKit

extension UserDefaults {
    
    private static let kHasAutoShowBottomMenu = "IndustryAR-kHasAutoShow"
//    private static let kIsTrackingOn = "IndustryAR-kIsTrackingOn"
    private static let kIsLabelDisplay = "IndustryAR-kIsLabelDisplay"
    private static let kIsJsonNumberToStore = "IndustryAR-kIsJsonNumberToStore"
    
    static var jsonNumberToStore: [String: Any ]? {
        get {
            self.standard.dictionary(forKey: kIsJsonNumberToStore)
        }
        set {
            self.standard.set(newValue, forKey: kIsJsonNumberToStore)
        }
    }
    
    static var hasAutoShowBottomMenu: Bool {
        get {
            self.standard.bool(forKey: kHasAutoShowBottomMenu)
        }
        set {
            self.standard.set(newValue, forKey: kHasAutoShowBottomMenu)
        }
    }
    
//    static var isTrackingOn: Bool {
//        get {
//            self.standard.bool(forKey: kIsTrackingOn)
//        }
//        set {
//            self.standard.set(newValue, forKey: kIsTrackingOn)
//        }
//    }

    
    static var isLabelDisplay: Bool {
        get {
            self.standard.bool(forKey: kIsLabelDisplay)
        }
        set {
            self.standard.set(newValue, forKey: kIsLabelDisplay)
        }
    }

}
