//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Ethan Wong on 5/5/21.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        // Parse dynamically creates tables for you
        let post = PFObject(className: "Posts")
        
        // define schema
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!
        
        // store image (stored as a URL, not directly)
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground(block: {
            (success, error) in
            if success {
                print("saved!")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error!")
            }
        })
        
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        // launch camera
        let picker = UIImagePickerController()
        picker.delegate = self // call myself back when done taking photo
        picker.allowsEditing = true
        
        // also need to check if camera is available or it will crash
        /* SWIFT enum, can start with dot, will smartly figure out */
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary // use photo Library if on simulator w/o camera
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        /* scale image so it uploads better using AlamoFire */
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
