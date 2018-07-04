//
//  ReusableView.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

public protocol ReusableView: class {
    
    func prepareForReuse()
    var tableViewAccessoryType: UITableViewCellAccessoryType { get set }
    var selectionStyle: UITableViewCellSelectionStyle { get set }
    var cellBackgroundColor: UIColor? { get set }
    var cellAccessoryView: UIView? { get set }
}

public protocol BaseReusableView: ReusableView {
    associatedtype PState: BaseUIState
    var state: PState { get set }
    func bind(_ state: PState) // used for bind new state
}

public extension BaseReusableView {
    func prepareForReuse() {
        let state = PState()
        bind(state)
    }
    
    static func item(builder: (PState) -> Void) -> UVCItem<Self> {
        let state: PState = PState()
        builder(state)
        return UVCItem(state: state)
    }

}

public extension BaseReusableView where Self: UIView {
    static func asHeader(builder: (PState) -> ()) -> TVHeader {
        let state = PState()
        builder(state)
        return TVHeader(
            celler: { (tv, index) -> (UIView) in
                let view = Self()
                view.backgroundColor = state.cellBackgroundColor
                view.bind(state)
                return view
        }, heighter: { (tv, index) -> (CGFloat) in
            return state.height
        })
    }

}

public extension ReusableView where Self: UIView {
    
    public var selectionStyle: UITableViewCellSelectionStyle {
        get {
            if let parent = self.superviewOf(UITableViewCell.self) {
                return parent.selectionStyle
            }
            return .none
        }
        set {
            if let parent = self.superviewOf(UITableViewCell.self) {
                parent.selectionStyle = newValue
            }
        }
    }
    
    public var tableViewAccessoryType: UITableViewCellAccessoryType {
        get {
            if let parent = superviewOf(UITableViewCell.self) {
                return parent.accessoryType
            }
            return .none
        }
        set {
            if let parent = superviewOf(UITableViewCell.self) {
                parent.accessoryType = newValue
            }
        }
    }
    
    public var cellBackgroundColor: UIColor? {
        get {
            if let tableViewParent = superviewOf(UITableViewCell.self),
                let collectionViewParent = superviewOf(UICollectionViewCell.self) {
                let tableViewIndex = index(parent: tableViewParent)
                let collectionViewIndex = index(parent: collectionViewParent)
                if tableViewIndex < collectionViewIndex {
                    return tableViewParent.backgroundColor
                } else if collectionViewIndex < tableViewIndex {
                    return collectionViewParent.backgroundColor
                }
            } else if let parent = superviewOf(UITableViewCell.self) {
                return parent.backgroundColor
            } else if let parent = superviewOf(UICollectionViewCell.self) {
                return parent.backgroundColor
            }
            return nil
        }
        set {
            if let tableViewParent = superviewOf(UITableViewCell.self),
                let collectionViewParent = superviewOf(UICollectionViewCell.self) {
                let tableViewIndex = index(parent: tableViewParent)
                let collectionViewIndex = index(parent: collectionViewParent)
                if tableViewIndex < collectionViewIndex {
                    tableViewParent.backgroundColor = newValue
                } else if collectionViewIndex < tableViewIndex {
                    collectionViewParent.backgroundColor = newValue
                }
            } else if let parent = superviewOf(UITableViewCell.self) {
                parent.backgroundColor = newValue
            } else if let parent = superviewOf(UICollectionViewCell.self) {
                parent.backgroundColor = newValue
            }
        }
    }
    
    public var cellAccessoryView: UIView? {
        get {
            if let parent = self.superviewOf(UITableViewCell.self) {
                return parent.accessoryView
            }
            return nil
        }
        set {
            if let parent = self.superviewOf(UITableViewCell.self) {
                parent.accessoryView = newValue
            }
        }
    }
}

open class BaseUIState {
    
    open var size: CGSize {
        return CGSize(width: width,
                      height: height)
    }
    
    open var onVisible: (() -> ())?
    
    open var height: CGFloat = 0
    
    open var width: CGFloat = 0
    
    open var isUserInteractionEnabled: Bool = true
    
    public required init() { }

    // for uitableviewcell
    open var selectionStyle: UITableViewCellSelectionStyle = .none
    open var accessoryType: UITableViewCellAccessoryType = .none
    
    // for uitableviewcell or uicollectionviewcell
    open var cellBackgroundColor: UIColor?
    open var cellAccessoryView: UIView?
    
    open var onSelect: UVSelect?
    
    open var margin: UIEdgeInsets = .zero
    
    public var marginedWidth: CGFloat {
        return width - (margin.left + margin.right)
    }
    
    public var marginedHeight: CGFloat {
        return height - (margin.top + margin.bottom)
    }

}
