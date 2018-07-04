//
//  UVCompatible.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

public typealias UCeller = () -> (ReusableView)
public typealias UVSelect = (RecyclerView, IndexPath) -> (Void)
public typealias UVSizer = (RecyclerView, IndexPath) -> CGSize

public enum RecyclerView {
    case table(UITableView)
    case collection(UICollectionView)
}

public protocol UVCompatible: TVCompatible {
    var tvc: TVCItem { get }
    var cvc: CVCItem { get }
}

/// instantiate object of UIView
/// if public classType is NibBased, instantiate from nib
///
/// - Parameter public classType: public class type that want to be instantiate
/// - Returns: UCeller to instantiate public classType object
public func uCeller(_ classType: UIView.Type) -> UCeller {
    return {
        if classType is NibBased {
            // sengaja force cast, yg tidak implement BaseReusableView2 akan crash
            return Bundle(for: classType).loadNibNamed(
                String(describing: classType),
                owner: nil,
                options: nil
                )![0] as! ReusableView
        }
        // sengaja force cast, yg tidak implement BaseReusableView2 akan crash
        return classType.init() as! ReusableView
    }
}

/// get UVSizer using width of UICollectionView / UITableView with specified height
///
/// - Parameter height: height of uvc
/// - Returns: UVSizer with specified height
public func uvSizer(height: CGFloat) -> UVSizer {
    return { rv, _ in
        switch rv {
        case .table(let tv):
            return CGSize(width: tv.frame.size.width, height: height)
        case .collection(let cv):
            return CGSize(width: cv.frame.size.width, height: height)
        }
    }
}

open class UVCItem<T: BaseReusableView>: TVCompatible, CVCompatible, UVCompatible, Identifieable {
    public lazy var tvc: TVCItem = self.initTVC()
    public lazy var cvc: CVCItem = self.initCVC()
    
    private var uvcPreparer: ((T) -> ())?
    private var uvcCeller: UCeller
    private var uvcSizer: UVSizer
    private var uvcOnSelect: UVSelect?
    private var uvcOnVisible: (() -> ())?
    private var tvEditableProperty: TVEditable?
    public var identifier: String
    
    public func identifier(_ identifier: String) -> Self {
        self.identifier = identifier
        return self
    }
    
    public convenience init(state: T.PState) {
        self.init(
            preparer: { view in
                view.bind(state)
                view.selectionStyle = state.selectionStyle
                view.cellBackgroundColor = state.cellBackgroundColor
                view.cellAccessoryView = state.cellAccessoryView
                view.tableViewAccessoryType = state.accessoryType
        },
            sizer: { _, _ in
                return state.size
        },
            onSelect: state.onSelect,
            onVisible: state.onVisible
        )
    }
    
    public required init(preparer: ((T) -> Void)?,
                         sizer: @escaping UVSizer,
                         identifier: String = UUID().uuidString,
                         onSelect: UVSelect? = nil,
                         onVisible: (() -> ())? = nil) {
        // sengaja force cast, hanya berlaku untuk UIView
        uvcCeller = uCeller(T.self as! UIView.Type)
        uvcSizer = sizer
        uvcOnSelect = onSelect
        uvcPreparer = preparer
        uvcOnVisible = onVisible
        self.identifier = identifier
    }
    
    /// set custom sizer for uvc
    ///
    /// - Parameter sizer: UVSizer to be set
    /// - Returns: uvc with custom sizer
    public func sizer(sizer: @escaping UVSizer) -> UVCItem<T> {
        uvcSizer = sizer
        return self
    }
    
    /// set custom preparer for uvc
    ///
    /// - Parameter preparer: preparer to be set
    /// - Returns: uvc with custom preparer
    public func preparer(preparer: ((T) -> Void)?) -> UVCItem<T> {
        uvcPreparer = preparer
        return self
    }
    
    /// set custom onSelect for uvc
    ///
    /// - Parameter onSelect: UVSelect to be set
    /// - Returns: uvc with custom onSelect
    public func onSelect(onSelect: @escaping UVSelect) -> UVCItem<T> {
        uvcOnSelect = onSelect
        return self
    }
    
    /// set custom editableProperty for uvc
    ///
    /// - Parameter editableProperty: UVSelect to be set
    /// - Returns: uvc with custom onSelect
    public func editableProperty(editableProperty: @escaping TVEditable) -> UVCItem<T> {
        tvEditableProperty = editableProperty
        return self
    }
    
    public func initTVC() -> TVCItem {
        return TVCItem(
            celler: { [weak self] (tv, ip) -> (UITableViewCell) in
                let viewClass = T.self
                tv.register(CustomViewTVC.self,
                            forCellReuseIdentifier: String(describing: viewClass))
                let cell = tv.dequeueReusableCell(
                    withIdentifier: String(describing: viewClass),
                    for: ip) as! CustomViewTVC
                
                guard let s = self else {
                    return cell
                }
                
                if cell.customView == nil {
                    cell.customView = s.uvcCeller()
                }
                if let view = cell.customView as? T {
                    s.uvcPreparer?(view)
                }
                
                cell.setNeedsLayout()
                return cell
            },
            heighter: { [weak self] tv, ip -> CGFloat in
                return self?.uvcSizer(.table(tv), ip).height ?? 0
            },
            onSelect: { [weak self] tv, ip in
                self?.uvcOnSelect?(.table(tv), ip)
            },
            onVisible: uvcOnVisible,
            editableProperty: tvEditableProperty,
            identifier: identifier
        )
    }
    
    public func initCVC() -> CVCItem {
        return CVCItem(
            celler: { [weak self] (cv, ip) -> UICollectionViewCell in
                let viewClass = T.self
                cv.register(CustomViewCVC.self,
                            forCellWithReuseIdentifier: String(describing: viewClass))
                let cell = cv.dequeueReusableCell(
                    withReuseIdentifier: String(describing: viewClass),
                    for: ip) as! CustomViewCVC
                
                guard let s = self else {
                    return cell
                }
                
                if cell.customView == nil {
                    cell.customView = s.uvcCeller()
                }
                if let view = cell.customView as? T {
                    s.uvcPreparer?(view)
                }
                cell.setNeedsLayout()
                return cell
            },
            sizer: { [weak self] cv, _, ip -> CGSize in
                return self?.uvcSizer(.collection(cv), ip) ?? .zero
            },
            identifier: identifier,
            onSelect: { [weak self] cv, ip in
                self?.uvcOnSelect?(.collection(cv), ip)
            },
            onVisible: uvcOnVisible
        )
    }
}

