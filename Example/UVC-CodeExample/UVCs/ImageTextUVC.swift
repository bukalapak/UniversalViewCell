//
//  ImageTextUVC.swift
//  UVC-CodeExample
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import UIKit
import UniversalViewCell

class ImageTextUVC: UIView, BaseReusableView {
    
    var state: ImageTextUVC.State = ImageTextUVC.State()
    
    func bind(_ state: ImageTextUVC.State) {
        self.state = state
    }
    
    typealias PState = State
    class State: BaseUIState { }
    
}


