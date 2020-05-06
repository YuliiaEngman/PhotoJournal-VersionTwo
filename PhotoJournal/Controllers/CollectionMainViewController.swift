//
//  ViewController.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 1/27/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import AVFoundation

class CollectionMainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    private var imageObjects = [ImageObject]() {
           didSet {
               DispatchQueue.main.async {
                   self.collectionView.reloadData()
               }
           }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME (give the user option to change the color)
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadImagesObjects()
        //updateUI()
    }
    
    private func loadImagesObjects() {
        do {
            imageObjects = try dataPersistance.loadEvents()
        } catch {
            print("loading objects error: \(error)")
        }
    }

}

extension CollectionMainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //FIXME: return count fo photos
        return imageObjects.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionPhotoCell", for: indexPath) as? CollectionPhotoCell else {
            fatalError("could downcast to CollectionPhotoCell")
        }
        let imageObject = imageObjects[indexPath.row]
        // FIXME: add label
        cell.configureCell(imageObject: imageObject)
       // cell.backgroundColor = .yellow
        
        // FIXME: creating custom delegation - set delegate object for longPress -> move this code to LongPress for editing function
        cell.delegate = self
        return cell
    }
}

// here we are using UICollectionViewFlowLayout
extension CollectionMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //FIXME: cannot set "normal" constraints
        
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.8
        return CGSize(width: itemWidth, height: itemWidth * 1.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
}

extension CollectionMainViewController: CollectionPhotoCellDelegate {
    func didLongPress(_ imageCell: CollectionPhotoCell) {
        //print("cell was selected")
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            return
        }
        
        // action: delete, edit (segues to addPhotoVC), cancel
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
            self?.deleteImageObject(indexPath: indexPath)
        }
        
        let editAction = UIAlertAction(title: "Edit", style: .destructive) {
           [weak self] alertAction in
//           let editingObject = self!.imageObjects[indexPath.row]
//           self?.segueImageObjectForEditing(editingObject)
            
            guard let editPhotoVC = self?.storyboard?.instantiateViewController(identifier: "AddPhotosViewController") as? AddPhotosViewController else {
                        fatalError("could not downcast to AddPhotosViewController")
                    }
            let editingObject = self!.imageObjects[indexPath.row]
            print(editingObject)
                    editPhotoVC.image = editingObject
            //editPhotoVC.textField.text = editingObject.imageDescription
            
            self?.present(editPhotoVC, animated: true)


        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func deleteImageObject(indexPath: IndexPath) {
        
        do {
            // delete image object from documents directory
            try dataPersistance.delete(event: indexPath.row)
            
            //delete imageObject from imageObjects
            imageObjects.remove(at: indexPath.row)
            //delete cell from collection view
            collectionView.deleteItems(at: [indexPath])
        } catch {
            print("error deleting item: \(error)")
        }
    }
    
    //private func segueImageObjectForEditing(_ image: ImageObject? = nil) {
//    private func segueImageObjectForEditing(_ image: ImageObject) {
//
//        guard let editPhotoVC = storyboard?.instantiateViewController(identifier: "AddPhotosViewController") as? AddPhotosViewController else {
//            fatalError("could not downcast to AddPhotosViewController")
//        }
//        editPhotoVC.image = image
//
//        present(editPhotoVC, animated: true)
//    }
}


