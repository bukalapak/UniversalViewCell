//
//  UICollectionView.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

protocol DontAutoRegister {}
private var disableReuseAssociationKey: UInt8 = 0
@objc protocol NibBased { }

extension UICollectionView {
    func dequeue<T: UICollectionViewCell>(_ indexPath: IndexPath) -> T {
        
        var suffix = ""
        let c = T.self
        #if DEBUG
        if disableReuse && !(c is DontAutoRegister.Type) {
            suffix = UUID().uuidString
        }
        #endif
        
        //registering everytime only takes about 0.2 ms at most, its fine.
        register(class:c, suffix: suffix)
        return self.dequeueReusableCell(withReuseIdentifier: "\(c)\(suffix)", for: indexPath) as! T
    }
    
    var disableReuse: Bool {
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

    func register(class ofClass: AnyClass, suffix: String = "") {
        
        if let _ = ofClass as? NibBased.Type {
            self.register(nibName: "\(ofClass)", bundle: Bundle(for: ofClass), suffix: suffix)
        } else if let _ = ofClass as? DontAutoRegister.Type {
            
        } else {
            self.register(ofClass, forCellWithReuseIdentifier: "\(ofClass)\(suffix)")
        }
    }
    
    func register(nibName: String, bundle: Bundle = Bundle.main, suffix: String = "") {
        if let nib = NibManager.instance.getNib(name: nibName, bundle: bundle) {
            register(nib, forCellWithReuseIdentifier: nibName + suffix)
        }
    }
    
    func dequeueEmptyCell() -> UICollectionViewCell {
        return dequeue(IndexPath(item: 0, section: 0))
    }

}
