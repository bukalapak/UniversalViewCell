//
//  UITableView.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

private var disableReuseAssociationKey: UInt8 = 0

extension UITableView {
    
    public var disableReuse: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &disableReuseAssociationKey) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set(value) {
            objc_setAssociatedObject(self,
                                     &disableReuseAssociationKey,
                                     NSNumber(value: value),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func register(nibName: String, bundle: Bundle = Bundle.main, suffix: String = "") {
        if let nib = NibManager.instance.getNib(name: nibName, bundle: bundle) {
            register(nib, forCellReuseIdentifier: nibName + suffix)
        }
    }
    
    public func register(class ofClass: AnyClass, suffix: String = "") {
        
        if let _ = ofClass as? NibBased.Type {
            self.register(nibName: "\(ofClass)", bundle: Bundle(for: ofClass), suffix: suffix)
        } else if let _ = ofClass as? DontAutoRegister.Type {
            
        } else {
            self.register(ofClass, forCellReuseIdentifier: "\(ofClass)\(suffix)")
        }
    }
    
    //swiftlint:disable force_cast
    public func dequeue<T: UITableViewCell>(_ indexPath: IndexPath? = nil) -> T {
        
        var suffix = ""
        let c = T.self
        #if DEBUG
        if disableReuse && !(c is DontAutoRegister.Type) {
            suffix = UUID().uuidString
        }
        #endif
        //registering everytime only takes about 0.2 ms at most, its fine.
        register(class: T.self, suffix: suffix)
        if let indexPath = indexPath {
            return self.dequeueReusableCell(withIdentifier: "\(T.self)\(suffix)", for: indexPath) as! T
        } else {
            return self.dequeueReusableCell(withIdentifier: "\(T.self)\(suffix)") as! T
        }
    }
}
