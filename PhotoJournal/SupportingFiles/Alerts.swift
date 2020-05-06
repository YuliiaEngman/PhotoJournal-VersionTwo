//
//  Alerts.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 5/6/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
