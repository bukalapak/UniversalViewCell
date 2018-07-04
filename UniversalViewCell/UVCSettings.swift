//
//  UVCSettings.swift
//  UniversalViewCell
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import Foundation

public struct UVCSettings {
    
    public var defaultTableCellHeight: CGFloat = 40
    public var defaultTableFooterHeight: CGFloat = 30
    public var defaultTableHeaderHeight: CGFloat = 0
    
    static var shared = UVCSettings()
    
    public static func set(builder: ((UVCSettings) ->())) {
        builder(shared)
    }
    
}
