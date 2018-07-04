//
//  NibManager.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

public class NibManager: NSObject {
    public static let instance: NibManager = NibManager()
    private override init() {}
    
    fileprivate var nibMap: [String: Bool] = [:]
    
    public func getNib(name: String, bundle: Bundle = Bundle.main) -> UINib? {
        switch nibMap[name] {
        case .none:
            if let _ = bundle.path(forResource: name, ofType: "nib") {
                let nib: UINib = UINib(nibName: name, bundle: bundle)
                nibMap[name] = true
                return nib
            } else {
                nibMap[name] = false
                return nil
            }
        case .some(let exist):
            var nib: UINib? = nil
            if exist {
                nib = UINib(nibName: name, bundle: bundle)
            }
            return nib
        }
    }
    
}
