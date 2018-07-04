//
//  TVPresenter.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import UIKit

public typealias TVCeller = (UITableView, IndexPath) -> (UITableViewCell)
public typealias TVSelect = (UITableView, IndexPath) -> Void
public typealias TVCPreparer = (UITableViewCell) -> Void
public typealias Heighter = (UITableView, IndexPath) -> (CGFloat)
public typealias TVEditable = (UITableView, IndexPath) -> (TVEditableProperty)
public typealias TVCommitEdit = (UITableView, UITableViewCellEditingStyle, IndexPath) -> Void

public typealias TVHeaderFooterCeller = (UITableView, Int) -> (UIView)
public typealias HeaderFooterHeighter = (UITableView, Int) -> (CGFloat)

public protocol Identifieable: Hashable {
    var identifier: String { get }
}

extension Identifieable {
    public var hashValue: Int {
        return identifier.hashValue
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

public protocol TVCompatible { }
public protocol TVSectionCompatible: TVCompatible { }
public protocol TVSectionHeaderCompatible: TVSectionCompatible { }
public protocol TVSectionFooterCompatible: TVSectionCompatible { }

/// Implement this protocol to have vc with tvc presenter
@objc public protocol TVCAdapter {
    func refreshTVC()
    @objc optional func repopulateTable()
}

/// Editable Property of TVCItem
public class TVEditableProperty: NSObject {
    public var movable: Bool = false
    public var editingStyle: UITableViewCellEditingStyle = .delete
    public var indentOnEditing: Bool = false
    public var commitEditing: TVCommitEdit?
    
    public init(movable: Bool,
                editingStyle: UITableViewCellEditingStyle,
                indentOnEditing: Bool,
                onCommitEditing: TVCommitEdit? = nil) {
        self.movable = movable
        self.editingStyle = editingStyle
        self.indentOnEditing = indentOnEditing
        self.commitEditing = onCommitEditing
    }
}

@objcMembers
public class TVCItem: NSObject, TVCompatible, Identifieable {
    
    public let celler: TVCeller
    public var heighter: Heighter?
    public var onSelect: TVSelect?
    public var onVisible: (() -> ())?
    public var identifier: String
    public var editableProperty: TVEditable?
    
    public func identifier(_ identifier: String) -> Self {
        self.identifier = identifier
        return self
    }
    
    public required init(
        celler: @escaping TVCeller,
        heighter: Heighter? = nil,
        onSelect: TVSelect? = nil,
        onVisible: (() -> ())? = nil,
        editableProperty: TVEditable? = nil,
        identifier: String = UUID().uuidString) {
        self.celler = celler
        self.heighter = heighter
        self.onSelect = onSelect
        self.onVisible = onVisible
        self.editableProperty = editableProperty
        self.identifier = identifier
    }
    
    public class func from(tvCompatible: TVCompatible?) -> TVCItem? {
        return (tvCompatible as? UVCompatible)?.tvc ?? tvCompatible as? TVCItem
    }
}

@objcMembers
public class TVHeader: NSObject, TVSectionHeaderCompatible, Identifieable {
    
    public let celler: TVHeaderFooterCeller
    public var heighter: HeaderFooterHeighter?
    public var identifier: String
    
    public required init(celler: @escaping TVHeaderFooterCeller,
                         identifier: String = UUID().uuidString,
                         heighter: HeaderFooterHeighter? = nil) {
        self.celler = celler
        self.heighter = heighter
        self.identifier = identifier
    }
}

extension String: TVSectionHeaderCompatible, Identifieable {
    
    public var identifier: String {
        return self
    }
}

@objcMembers
public class TVFooter: NSObject, TVSectionFooterCompatible, Identifieable {
    
    public let celler: TVHeaderFooterCeller
    public var heighter: HeaderFooterHeighter?
    public var identifier: String
    
    public required init(celler: @escaping TVHeaderFooterCeller,
                         identifier: String = UUID().uuidString,
                         heighter: HeaderFooterHeighter? = nil) {
        self.celler = celler
        self.heighter = heighter
        self.identifier = identifier
    }
}

public class TVTextFooter: TVSectionFooterCompatible, Identifieable {
    
    public let text: String
    
    public var identifier: String {
        return text
    }
    
    public required init(text: String) {
        self.text = text
    }
}

public class TVTextHeader: TVSectionHeaderCompatible, Identifieable {
    public let text: String
    
    public var identifier: String {
        return text
    }
    
    public required init(text: String) {
        self.text = text
    }
}

public class TVSection: NSObject {
    @objc public var titleHeader: String?
    @objc public var titleFooter: String?
    @objc public var headerCeller: TVHeader?
    @objc public var footerCeller: TVFooter?
    @objc public var items: [TVCItem] = []
}

@objcMembers
public class TVPresenter: NSObject, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    fileprivate var sections: [TVSection] = []
    public var onScrollViewDidScroll: ((UIScrollView) -> Void)?
    public var onRowDidMove: ((IndexPath, IndexPath) -> Void)?
    public var isEditable: Bool = false
    
    public var items: [TVCompatible] {
        didSet {
            self.sections = transformToSectionedCells(items: items)
        }
    }
    
    private func transformToSectionedCells(items: [TVCompatible]) -> [TVSection] {
        var sections: [TVSection] = []
        if let _ = items.first as? TVSectionCompatible { } else {
            sections.append(TVSection())
        }
        for item in items {
            if let sectionItem = item as? TVSectionFooterCompatible {
                if let sectionItem = sectionItem as? TVFooter {
                    sections.last!.footerCeller = sectionItem
                } else if let sectionItem = sectionItem as? TVTextFooter {
                    sections.last!.titleFooter = sectionItem.text
                }
            } else if let sectionItem = item as? TVSectionCompatible {
                let section: TVSection = TVSection()
                if let sectionItem = item as? TVHeader {
                    section.headerCeller = sectionItem
                } else if let title = sectionItem as? TVTextHeader {
                    section.titleHeader = title.text
                } else if let title = sectionItem as? String {
                    section.titleHeader = title
                }
                sections.append(section)
            } else {
                if let uitem = item as? UVCompatible {
                    sections.last?.items.append(uitem.tvc)
                } else if let tvItem = item as? TVCItem {
                    sections.last?.items.append(tvItem)
                } else {
                    print("Unidentified item. this might be a failed injection")
                }
            }
        }
        return sections
    }
    
    public func getSections() -> [TVSection] {
        return sections
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sections.count > section {
            return sections[section].titleHeader
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if sections.count > section {
            return sections[section].titleFooter
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections.count > section {
            return sections[section].items.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let item = self[indexPath],
            let heighter = item.heighter {
            return heighter(tableView, indexPath)
        }
        return UVCSettings.shared.defaultTableCellHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if sections.count > section {
            return sections[section].footerCeller?.heighter?(tableView, section) ?? UVCSettings.shared.defaultTableFooterHeight
        }
        return UVCSettings.shared.defaultTableFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if sections.count > section {
            return sections[section].headerCeller?.heighter?(tableView, section) ?? UVCSettings.shared.defaultTableHeaderHeight
        }
        return UVCSettings.shared.defaultTableHeaderHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sections.count > section {
            return sections[section].headerCeller?.celler(tableView, section)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if sections.count > section {
            return sections[section].footerCeller?.celler(tableView, section)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let item = self[indexPath] {
            item.onVisible?()
            return item.celler(tableView, indexPath)
        }
        return tableView.dequeue()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self[indexPath],
            let onSelect = item.onSelect {
            onSelect(tableView, indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let item = self[indexPath],
            let editable = item.editableProperty {
            let editableProperty = editable(tableView, indexPath)
            return editableProperty.movable
        }
        return false
    }
    
    /// update item in TVPresenter sections when any row has been moved
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSection = sourceIndexPath.section
        let sourceRow = sourceIndexPath.row
        
        let destinationSection = destinationIndexPath.section
        let destinationRow = destinationIndexPath.row
        
        let itemToMove = sections[sourceSection].items[sourceRow]
        
        sections[sourceSection].items.remove(at: sourceRow)
        sections[destinationSection].items.insert(itemToMove, at: destinationRow)
        
        onRowDidMove?(sourceIndexPath, destinationIndexPath)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if let item = self[indexPath],
            let editable = item.editableProperty {
            let editableProperty = editable(tableView, indexPath)
            return editableProperty.editingStyle
        }
        if tableView.isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if let item = self[indexPath],
            let editable = item.editableProperty {
            let editableProperty = editable(tableView, indexPath)
            return editableProperty.indentOnEditing
        }
        return false
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self[indexPath]?.editableProperty != nil
    }
    
    /// perform delete item in TVPresenter sections when delete type of editing cell is fired
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
        if let item = self[indexPath],
            let editable = item.editableProperty {
            let editableProperty = editable(tableView, indexPath)
            editableProperty.commitEditing?(tableView, editingStyle, indexPath)
        }
    }
    
    @objc public subscript(index: IndexPath) -> TVCItem? {
        if sections.count > index.section {
            if sections[index.section].items.count > index.row {
                return sections[index.section].items[index.row]
            }
        }
        return nil
    }
    
    @objc public func sectionItems() -> [TVSection] {
        return sections
    }
    
    @objc public func sectionCount() -> Int {
        return sections.count
    }
    
    public func itemCountInSection(_ index: Int) -> Int {
        return sections[index].items.count
    }
    
    public func indexPath(of tvcItem: TVCItem) -> IndexPath? {
        
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                
                if tvcItem == item {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    public func firstIndex(of tvCompatibleObject: TVCompatible) -> Int? {
        for (index, item) in items.enumerated() {
            if let tvcItem = item as? TVCItem,
                let tvcObject = tvCompatibleObject as? TVCItem,
                tvcItem.identifier == tvcObject.identifier {
                return index
            }
        }
        return nil
    }
    
    public override init() {
        self.items = []
    }
    
    public required init(menuList: [TVCompatible]) {
        self.items = menuList
        super.init()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScrollViewDidScroll?(scrollView)
    }
}
