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

protocol UpdateColorsDelegate: AnyObject {
    func colorsDelegate(_ settingsVC: NewSettingsViewController, newBackgroundColor: UIColor)
}

class NewSettingsViewController: UIViewController {
    
    @IBOutlet weak var horizontalScroll: UIButton!
    
    @IBOutlet weak var verticalScroll: UIButton!
    
    weak var updateScrollDirectionDelegate: UpdateScrollDirectionDelegate?
    
    weak var updateColorsDelegate: UpdateColorsDelegate?
    
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
    
    
    @IBAction func redbuttonPressed(_ sender: UIButton) {
        updateColorsDelegate?.colorsDelegate(self, newBackgroundColor: .systemPink)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tealbuttonPressed(_ sender: UIButton) {
        updateColorsDelegate?.colorsDelegate(self, newBackgroundColor: .systemTeal)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func whitebuttonPressed(_ sender: UIButton) {
        updateColorsDelegate?.colorsDelegate(self, newBackgroundColor: .white)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yellowbuttonPressed(_ sender: UIButton) {
        updateColorsDelegate?.colorsDelegate(self, newBackgroundColor: .systemYellow)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func greenbuttonPressed(_ sender: UIButton) {
        updateColorsDelegate?.colorsDelegate(self, newBackgroundColor: .green)
        dismiss(animated: true, completion: nil)
    }
}
