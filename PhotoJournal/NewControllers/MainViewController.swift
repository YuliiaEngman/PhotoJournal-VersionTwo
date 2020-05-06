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
    
  //  var photo: ImageObject?
    
    private var imageObjects = [ImageObject]() {
        didSet {
        //    collectionView.reloadData()
        }
    }
    
    private let imagePickerController = UIImagePickerController()
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    private var selectedImage: UIImage?
//    {
//        didSet {
//           // appendNewPhotoToCollection()
//        }
//    }
    
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
        guard let addPhotoVC = segue.destination as? NewAddPhotoViewController else {
            fatalError("cannot segue to addPhotVC")
        }
        addPhotoVC.updatePhotoDelegate = self
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
    
    
//    private func appendNewPhotoToCollection() {
//        guard let image = selectedImage else {
//            print("image is nil #1")
//            return
//        }
//        print("original image size is \(image.size)")
//
//        //resize image
//        let size = UIScreen.main.bounds.size
//
//        // we will maintain the aspect ratio of the image
//        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
//
//        //resize image
//        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
//
//        print("resized image size is \(resizeImage.size)")
//
//        // jpegData(compressionQuality: 1.0 converts UIImage to Data
//        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
//            return
//        }
//
//        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: "no image description")
//
//        imageObjects.insert(imageObject, at: 0)
//
//        let indexPath = IndexPath(row: 0, section: 0)
//
//        collectionView.insertItems(at: [indexPath])
//
//        //persist imageObject to documents directory
//        do {
//            try dataPersistance.create(imageObject)
//        } catch {
//            print("saving error: \(error)")
//        }
//    }
    
    
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


