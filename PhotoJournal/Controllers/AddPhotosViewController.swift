//
//  AddPhotosViewController.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 2/26/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import AVFoundation

class AddPhotosViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    private var imageObjects = [ImageObject]()
    
    public var image: ImageObject?
    
    private let imagePickerController = UIImagePickerController()
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    private var selectedImage: UIImage? {
        didSet {
           appendNewPhotoToCollection()
            //updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        imagePickerController.delegate = self
        
        //updateUI()
    }
    
    // I think this code should be in main vc
    private func updateUI() {
        if let image = image {
            textField.text = image.imageDescription
            imageView.image = UIImage(data: image.imageData)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
    
    private func appendNewPhotoToCollection() {
        guard let image = selectedImage else {
            print("image is nil # 3")
            return
        }
        print("original image size is \(image.size)")
        
        //resize image
        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        //resize image
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        
        print("resized image size is \(resizeImage.size)")
        
        // jpegData(compressionQuality: 1.0 converts UIImage to Data
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // create an ImageObject using image selected
        //let imageObject = ImageObject(imageData: resizedImageData, date: Date())
        
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: textField.text ?? "no photo description")
        
        //insert new imageObject into imageObjects
        imageObjects.insert(imageObject, at: 0)
        
        
        /*  //FIXME: I dont htink we need this code:
         // create an indexPath for insertion into collection view
         let indexPath = IndexPath(row: 0, section: 0)
         
         // insert new cell into collection view
         
         collectionView.insertItems(at: [indexPath])
         */
        
        //persist imageObject to documents directory
        do {
            try dataPersistance.create(imageObject)
        } catch {
            print("saving error: \(error)")
        }
    }
    
    @IBAction func photoLibraryButton(_ sender: UIButton) {
        self.showImageController(isCameraSelected: false)
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        self.showImageController(isCameraSelected: true)
    }
    
    private func showImageController(isCameraSelected: Bool) {
        // source type default will be .photoLibrary
        imagePickerController.sourceType = .photoLibrary
        
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        present(imagePickerController, animated: true)
    }
    
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        imageView.image = UIImage(systemName: "photo")
               textField.placeholder = "Enter photo description"
               
               guard let mainVC = storyboard?.instantiateViewController(identifier: "CollectionMainViewController") as? CollectionMainViewController else {
                   fatalError("could not downcast to CollectionMainViewController")
               }
               //editPhotoVC.image = image
               //present(mainVC, animated: true)
               let navigationVC = UINavigationController(rootViewController: mainVC)
               present(navigationVC, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        appendNewPhotoToCollection()
        
        guard let image = imageView.image else {
               print("image is nil # 4")
               return
           }
           
           let size = UIScreen.main.bounds.size
           
           let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
           
           let resizedImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
           
           guard let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) else {
               return
           }
           
           let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: textField.text ?? "no photo description")
           
           do {
            try dataPersistance.create(imageObject)
           } catch {
               print("saving error: \(error)")
           }
           dismiss(animated: true, completion: nil)
    }
    
}

extension AddPhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    // most important - what is that image - here image is come in shape of the dictionary
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // we need to access the UIImagePickerController.InfoKey.originalImage key to get the UIImage that was selected
        // since we get back Any type - optional, therefore we have to unwrap it
        // now we have to downcast to UIImage (before it was just Any)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selected not found")
            return
        }
        //selectedImage = image
        imageView.image = image
        dismiss(animated: true)
    }
}

extension AddPhotosViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

//extension UIImage {
//    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
//        let size = CGSize(width: width, height: height)
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { (context) in
//            self.draw(in: CGRect(origin: .zero, size: size))
//        }
//    }
//}
