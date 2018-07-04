//
//  UIView.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

extension UIView {
    
    func index(parent: UIView) -> Int {
        var index = 0 // index of first superview
        var viewWalker = self
        while let parentView = viewWalker.superview {
            if parentView == parent {
                return index
            }
            index += 1
            viewWalker = parentView
        }
        return .max // not found
    }

    func superviewOf<T>(_ type: T.Type) -> T? {
        if let parent = self.superview {
            if let parent = parent as? T {
                return parent
            } else {
                return parent.superviewOf(type)
            }
        } else {
            return nil
        }
    }
    
    func removeSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}
