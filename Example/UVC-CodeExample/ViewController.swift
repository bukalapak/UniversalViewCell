//
//  ViewController.swift
//  UVC-CodeExample
//
//  Created by Azis Senoaji Prasetyotomo on 03/07/18.
//  Copyright © 2018 Azis Senoaji Prasetyotomo. All rights reserved.
//

import UIKit
import UniversalViewCell

class ViewController: UIViewController {

    var presenter: TVPresenter = TVPresenter()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = presenter
        tableView.dataSource = presenter
        populateCell()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func populateCell() {
        presenter.items = []
        presenter.items.append(
            ImageTextUVC.asHeader { state in
                state.height = 40
                state.cellBackgroundColor = .yellow
            }
        )
        presenter.items.append(
            ImageTextUVC.item { state in
                state.height = 50
                state.cellBackgroundColor = .black
            }
        )
        presenter.items.append(
            ImageTextUVC.item { state in
                state.height = 50
                state.cellBackgroundColor = .red
            }
        )
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

