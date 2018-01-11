//
//  HomeViewController.swift
//  Collab
//
//  Created by Anirudh Natarajan on 4/16/17.
//  Copyright © 2017 Kodikos. All rights reserved.
//

var bgImage: UIImage? = nil
var landscape: Bool = true

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var createSessionButton: UIButton!
    @IBOutlet var addBackgroundButton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
        createSessionButton.layer.cornerRadius = 40
        createSessionButton.clipsToBounds = true
        addBackgroundButton.layer.cornerRadius = 40
        addBackgroundButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearBoardPressed(_ sender: Any) {
        landscape = true
        self.performSegue(withIdentifier: "goToCountdown", sender: self)
    }
    
    @IBAction func backgroundImagePressed(_ sender: UIBarButtonItem) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.modalPresentationStyle = .popover
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        bgImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if(Int((bgImage?.size.height)!)+50 > Int((bgImage?.size.width)!)){
            landscape = false
        } else {
            landscape = true
        }
        dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "goToCountdown", sender: self)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
