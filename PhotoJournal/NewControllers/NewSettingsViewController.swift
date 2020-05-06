//
//  NewSettingsViewController.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 5/1/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit

enum ScrollDirections {
    case horizontalScroll
    case verticalScroll
}

protocol UpdateScrollDirectionDelegate: AnyObject {
    func scrollDirection(_ settingsVC: NewSettingsViewController, scrollDirection: ScrollDirections)
}

class NewSettingsViewController: UIViewController {
    
    @IBOutlet weak var horizontalScroll: UIButton!
    
    @IBOutlet weak var verticalScroll: UIButton!
    
    weak var updateScrollDirectionDelegate: UpdateScrollDirectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func horizontalButtonPressed(_ sender: UIButton) {
        updateScrollDirectionDelegate?.scrollDirection(self, scrollDirection: .horizontalScroll)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func varticalButtonPressed(_ sender: UIButton) {
        updateScrollDirectionDelegate?.scrollDirection(self, scrollDirection: .verticalScroll)
        dismiss(animated: true, completion: nil)
    }
    
    
}
