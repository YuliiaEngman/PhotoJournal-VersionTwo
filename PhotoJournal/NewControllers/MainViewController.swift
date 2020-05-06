//
//  MainViewController.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 5/1/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var imageObjects = [ImageObject]()
    
    private let imagePickerController = UIImagePickerController()
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //FIXME (give the user option to change the color)
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        
        imagePickerController.delegate = self
        
        loadImageObjects()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addPhotoSegue" {
            guard let addPhotoVC = segue.destination as? NewAddPhotoViewController else {
                fatalError("cannot segue to addPhotoVC")
            }
            addPhotoVC.updatePhotoDelegate = self
        } else if segue.identifier == "settingsSegue" {
            
            guard let settingsVC = segue.destination as? NewSettingsViewController else {
                fatalError("cannot segue to settingsVC")
            }
            settingsVC.updateScrollDirectionDelegate = self
            settingsVC.updateColorsDelegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadImageObjects()
        collectionView.reloadData()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try dataPersistance.loadEvents()
            // pay attantion what is printed here:
            print(imageObjects)
        } catch {
            print("loading objects error: \(error)")
        }
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //FIXME: return count fo photos
        print(imageObjects.count)
        return imageObjects.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionPhotoCell", for: indexPath) as? CollectionPhotoCell else {
            fatalError("could downcast to CollectionPhotoCell")
        }
        let imageObject = imageObjects[indexPath.row]
        cell.configureCell(imageObject: imageObject)
        cell.delegate = self
        return cell
    }
}

// here we are using UICollectionViewFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {

//    //This is how you create it in code with UICollectionViewFlowLayout
//
//    let layout = UICollectionViewFlowLayout()
//    layout.scrollDirection = .vertical
//    let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
//  //  or if you are working with an existent collection view
//
//    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//        layout.scrollDirection = .vertical
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //FIXME: cannot set "normal" constraints
        
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.8
        //let layout = UICollectionViewFlowLayout()
       // layout.scrollDirection = UserPreference.shared.getScrollDirection() ?? ScrollDirection(rawValue: "vertical")
        return CGSize(width: itemWidth, height: itemWidth * 1.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selected not found")
            return
        }
        selectedImage = image
        dismiss(animated: true)
    }
}

extension MainViewController: CollectionPhotoCellDelegate {
    func didLongPress(_ imageCell: CollectionPhotoCell) {
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
            let editingObject = self!.imageObjects[indexPath.row]
            //FIXME:
            self?.segueImageObjectForEditing(editingObject)
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
    
    private func segueImageObjectForEditing(_ image: ImageObject? = nil) {
        
        guard let addNewPhotoVC = storyboard?.instantiateViewController(identifier: "NewAddPhotoViewController") as? NewAddPhotoViewController else {
            fatalError("could not downcast to NewAddPhotoViewController")
        }
        addNewPhotoVC.image = image
        
        //see what will happen when I add this line of code
        // so, it works but instead of updating photo it adds a new one
        //FIXME: 
        addNewPhotoVC.updatePhotoDelegate = self
        
        present(addNewPhotoVC, animated: true)
    }
}

extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension MainViewController: UpdatePhotoDelegate {
    func didSavePhotoButtonPressed(_ addPhotosVC: NewAddPhotoViewController, photo: ImageObject) {
        loadImageObjects()
        collectionView.reloadData()
    }
}

extension MainViewController: UpdateScrollDirectionDelegate {
    func scrollDirection(_ settingsVC: NewSettingsViewController, scrollDirection: ScrollDirections) {
    
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        switch scrollDirection {
        case .horizontalScroll:
            layout.scrollDirection = .horizontal
        case .verticalScroll:
            layout.scrollDirection = .vertical
        }
    }
}

extension MainViewController: UpdateColorsDelegate {
    func colorsDelegate(_ settingsVC: NewSettingsViewController, newBackgroundColor: UIColor) {
        view.backgroundColor = newBackgroundColor
    }
}


