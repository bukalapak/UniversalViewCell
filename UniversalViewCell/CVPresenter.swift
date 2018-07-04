//
//  CVPresenter.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

public typealias CVCeller = (UICollectionView, IndexPath) -> UICollectionViewCell
public typealias CVSelect = (UICollectionView, IndexPath) -> Void
public typealias CVPreparer = (UICollectionViewCell) -> Void
public typealias CVContentOffset = (UICollectionView, CGPoint) -> CGPoint
public typealias Sizer = (UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize

public typealias CVHeaderFooterCeller = (UICollectionView, String, Int) -> UICollectionReusableView
public typealias CVHeaderFooterSizer = (UICollectionView, Int) -> (CGSize)

@objc public protocol CVCompatible { }
public protocol CVSectionCompatible: CVCompatible { }
public protocol CVSectionHeaderCompatible: CVSectionCompatible { }

public func widthForCVC(items: [CVCompatible]) -> CGFloat {
    var width: CGFloat = 0
    let dummyLayout: UICollectionViewLayout = UICollectionViewLayout()
    let dummyCV: UICollectionView = UICollectionView(frame: .zero,
                                                     collectionViewLayout: dummyLayout)
    let dummyIP: IndexPath = IndexPath(item: 0, section: 0)
    for item in items {
        if let item = item as? CVCItem {
            width += item.sizer(dummyCV, dummyLayout, dummyIP).width
        } else if let item = item as? UVCompatible {
            width += item.cvc.sizer(dummyCV, dummyLayout, dummyIP).width
        }
    }
    return width
}

public func flattenArrayCVC (_ items: [[CVCItem]]) -> [CVCItem] {
    var item: [CVCItem] = []
    for i in items {
        item.append(contentsOf: i)
    }
    return item
}

public class CVCItem: NSObject, CVCompatible, Identifieable {
    @objc public var identifier: String
    @objc public var celler: CVCeller
    @objc public var sizer: Sizer
    @objc public var onSelect: CVSelect?
    @objc public var onVisible: (() ->())?
    
    
    public func identifier(_ identifier: String) -> Self {
        self.identifier = identifier
        return self
    }
    
    @objc public convenience init(celler: @escaping CVCeller, sizer: @escaping Sizer) {
        self.init(celler: celler, sizer: sizer, onSelect: nil)
    }
    
    @objc public required init(celler: @escaping CVCeller,
                               sizer: @escaping Sizer,
                               identifier: String = UUID().uuidString,
                               onSelect: CVSelect? = nil,
                               onVisible: (() ->())? = nil) {
        self.celler = celler
        self.sizer = sizer
        self.onSelect = onSelect
        self.onVisible = onVisible
        self.identifier = identifier
        
    }
    
    @objc public class func from(cvCompatible: CVCompatible?) -> CVCItem? {
        return (cvCompatible as? UVCompatible)?.cvc ?? cvCompatible as? CVCItem
    }
}

public class CVHeader: NSObject, CVSectionHeaderCompatible {
    
    public let celler: CVHeaderFooterCeller
    public var sizer: CVHeaderFooterSizer?
    
    public required init(celler: @escaping CVHeaderFooterCeller, sizer: CVHeaderFooterSizer? = nil) {
        self.celler = celler
        self.sizer = sizer
    }
}

public class CVSection: NSObject {
    public var headerCeller: CVHeader?
    public var items: [CVCItem] = []
}

public class CVPresenter: NSObject, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    fileprivate var sections: [CVSection] = []
    public var items: [CVCompatible] {
        didSet {
            let (sections, cvcItems) = transformToSectionedCells(items: items)
            self.sections = sections
            self.cvcItems = cvcItems
        }
    }
    
    private func transformToSectionedCells(items: [CVCompatible]) -> ([CVSection], [CVCItem]) {
        
        var cvcItemsTemp: [CVCItem] = []
        var sections: [CVSection] = []
        if let _ = items.first as? CVSectionCompatible { } else {
            sections.append(CVSection())
        }
        for item in items {
            if let sectionItem = item as? CVSectionHeaderCompatible {
                if let sectionItem = sectionItem as? CVHeader {
                    sections.append(CVSection())
                    sections.last?.headerCeller = sectionItem
                }
            } else {
                if let uitem = item as? UVCompatible {
                    sections.last?.items.append(uitem.cvc)
                    cvcItemsTemp.append(uitem.cvc)
                } else if let cvItem = item as? CVCItem {
                    sections.last?.items.append(cvItem)
                    cvcItemsTemp.append(cvItem)
                } else {
                    print("Unidentified item. this might be a failed injection")
                }
            }
        }
        return (sections, cvcItemsTemp)
    }
    
    @objc public var cvcItems: [CVCItem] {
        didSet {
            onItemsDidChange(cvcItems, oldValue)
        }
    }
    
    public var onScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var onScrollViewWillBeginDragging: ((UIScrollView) -> Void)?
    public var onScrollViewDidEndDecelerating: ((UIScrollView) -> Void)?
    public var onScrollViewWillEndDragging: ((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void)?
    
    public var onItemsDidChange: ([CVCItem], [CVCItem]) -> Void = { _, _ in }
    
    public override init() {
        cvcItems = []
        items = []
    }
    
    public var getSections: [CVSection] {
        return sections
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cvcItems = sections[indexPath.section].items
        if cvcItems.count == 0 || indexPath.row >= cvcItems.count { return collectionView.dequeueEmptyCell() }
        cvcItems[indexPath.row].onVisible?()
        return cvcItems[indexPath.row].celler(collectionView, indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cvcItems = sections[indexPath.section].items
        if cvcItems.count == 0 || indexPath.row >= cvcItems.count { return }
        cvcItems[indexPath.row].onSelect?(collectionView, indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvcItems = sections[indexPath.section].items
        if cvcItems.count == 0 || indexPath.row >= cvcItems.count { return CGSize.zero }
        return cvcItems[indexPath.row].sizer(collectionView, collectionViewLayout, indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionItem = sections[indexPath.section]
        if let headerCeller = sectionItem.headerCeller {
            return headerCeller.celler(collectionView, kind, indexPath.section)
            
        }
        return UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let size = sections[section].headerCeller?.sizer?(collectionView, section) {
            return size
        }
        return .zero
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScrollViewDidScroll?(scrollView)
    }
    
    /// Callback when the scroll activity ended
    ///
    /// - Parameter scrollView: scrollView
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        onScrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        onScrollViewWillEndDragging?(scrollView, velocity, targetContentOffset)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        onScrollViewWillBeginDragging?(scrollView)
    }
    
    /// mencari index dari CVCItem pertama yg memiliki identifier tersebut
    ///
    /// - Parameter identifier: identifier dari CVCItem yg dicari
    public func findIndexItem(identifier: String) -> Int {
        
        for item in cvcItems where item.identifier == identifier {
            return cvcItems.index(of: item) ?? -1
        }
        return -1
    }
    
    /// mengganti CVCItem dengan identifier tertentu dengan CVCItem lain
    ///
    /// - Parameters:
    ///   - identifier: identifier dari CVCItem yg akan diganti
    ///   - item: CVCItem pengganti
    ///   - cv: collectionview dari CVCItem
    ///   - animated: apakah akan menggunakan animasi
    public func replaceItem(identifier: String, withItem item: CVCItem, inCV cv: UICollectionView, animated: Bool = true) {
        let itemIndex = findIndexItem(identifier: identifier)
        if itemIndex >= 0 {
            cvcItems[itemIndex] = item
            cv.reloadData()
        }
    }
    
    /// mengganti CVCItem dengan identifier tertentu dengan array CVCItem lain
    ///
    /// - Parameters:
    ///   - identifier: identifier dari CVCItem yg akan diganti
    ///   - items: array CVCItem pengganti
    ///   - cv: collectionview dari CVCItem
    ///   - animated: apakah akan menggunakan animasi
    public func replaceItem(identifier: String, withItems item: [CVCItem], inCV cv: UICollectionView, animated: Bool = true) {
        if item.count == 1 {
            replaceItem(identifier: identifier,
                        withItem: item[0],
                        inCV: cv,
                        animated: animated)
            return
        }
        let itemIndex = findIndexItem(identifier: identifier)
        if itemIndex >= 0 {
            cvcItems.remove(at: itemIndex)
            cvcItems.insert(contentsOf: item, at: itemIndex)
            cv.reloadData()
        }
    }
    
}
