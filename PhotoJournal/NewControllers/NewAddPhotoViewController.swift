//
//  NewAddPhotoViewController.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 5/1/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import UIKit
import AVFoundation

protocol UpdatePhotoDelegate: AnyObject {
    func didSavePhotoButtonPressed(_ addPhotosVC: NewAddPhotoViewController, photo: ImageObject)
}

class NewAddPhotoViewController: UIViewController {
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePickerController = UIImagePickerController()
    
    private let dataPersistance = PersistenceHelper(filename: "images.plist")
    
    weak var updatePhotoDelegate: UpdatePhotoDelegate?
    
    public var image: ImageObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        imagePickerController.delegate = self
        
        updateUI()
    }
    
     private func updateUI() {
         if let image = image {
             textField.text = image.imageDescription
             imageView.image = UIImage(data: image.imageData)
         } else {
            imageView.image = UIImage(systemName: "photo")
            textField.placeholder = "Enter description of your photo"
         }
     }
    
    //FIXME:
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        guard let image = imageView.image else {
               print("image is nil # 2")
               return
           }
           
           let size = UIScreen.main.bounds.size
           
           let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
           
           let resizedImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
           
           guard let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) else {
               return
           }
           
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), imageDescription: textField.text ?? "no image description")
           
        
           do {
            try dataPersistance.create(imageObject)
           } catch {
               print("saving error: \(error)")
           }
        
       updatePhotoDelegate?.didSavePhotoButtonPressed(self, photo: imageObject)
        
           dismiss(animated: true, completion: nil)
    }
    
    private func showImageController(isCameraSelected: Bool) {
          // source type default will be .photoLibrary
          imagePickerController.sourceType = .photoLibrary
          
          if isCameraSelected {
              imagePickerController.sourceType = .camera
          }
          present(imagePickerController, animated: true)
      }
    
    @IBAction func photolibraryButton(_ sender: UIButton) {
        self.showImageController(isCameraSelected: false)
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        self.showImageController(isCameraSelected: true)
    }
}


extension NewAddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        imageView.image = image
        dismiss(animated: true)
    }
}

extension NewAddPhotoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


