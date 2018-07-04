//
//  CustomUVC.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

import UIKit

public class CustomViewCVC: UICollectionViewCell {
    
    public var customView: ReusableView? {
        didSet {
            setupUI()
        }
    }
    
    deinit {
        customView = nil
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        customView?.prepareForReuse()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        if let view = customView as? UIView {
            view.layoutSubviews()
        }
    }
    
    public func setupUI() {
        if let view = customView as? UIView {
            if view.superview == nil {
                contentView.removeSubviews()
                contentView.addSubview(view)
            }
            view.frame = CGRect(x: view.frame.origin.x,
                                y: view.frame.origin.y,
                                width: contentView.frame.size.width,
                                height: contentView.frame.size.height)
        }
    }
}

public class CustomViewTVC: UITableViewCell {
    
    public var customView: ReusableView? {
        didSet {
            setupUI()
        }
    }
    
    deinit {
        customView = nil
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        customView?.prepareForReuse()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        if let view = customView as? UIView {
            view.layoutSubviews()
        }
    }
    
    public func setupUI() {
        if let view = customView as? UIView {
            if view.superview == nil {
                contentView.removeSubviews()
                contentView.addSubview(view)
            }
            view.frame = CGRect(x: view.frame.origin.x,
                                y: view.frame.origin.y,
                                width: contentView.frame.size.width,
                                height: contentView.frame.size.height)
        }
    }
}

