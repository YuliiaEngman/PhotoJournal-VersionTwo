//
//  CollectionPhotoCell.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 2/26/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit

protocol CollectionPhotoCellDelegate: AnyObject {
    func didLongPress(_ collectionPhotoCell: CollectionPhotoCell)
}

class CollectionPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    
    @IBOutlet weak var photoLabel: UILabel!
    
    
    weak var delegate: CollectionPhotoCellDelegate?
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
          let gesture = UILongPressGestureRecognizer()
          gesture.addTarget(self, action: #selector(longPressedAction(gesture:)))
          return gesture
      }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20.0
        //backgroundColor = .orange
        
        addGestureRecognizer(longPressGesture)
    }
    
    @objc
       private func longPressedAction(gesture: UILongPressGestureRecognizer) {
           if gesture.state == .began {// if gesture is active
               gesture.state = .cancelled
               return
           }
           delegate?.didLongPress(self)
       }
    
    // FIXME: label does not show
    public func configureCell(imageObject: ImageObject) {
        // convertion Data to UIImage
        guard let image = UIImage(data: imageObject.imageData) else {
            return
        }
        photoImage.image = image
        photoLabel.text = imageObject.imageDescription
         print("image description: \(imageObject.imageDescription)")
    }
    
  
    
    
}
