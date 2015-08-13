//
//  MemeEditorViewController.swift
//  ImageLoader
//
//  Created by Markus Willburn on 8/8/15.
//  Copyright (c) 2015 Markus Willburn. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var photoToolbar: UIToolbar!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    // object variable declaration to initiate save capability
    var enableSave = false
    
    var memeToSave : GenMeme! // Meme struct object variable declaration
    var memedImage :  UIImage! // Meme image object variable declaration
    
    // Variable assignment of UITextField Font type and style parameters to be used by initializeMemeEditableParameters method
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : NSNumber(float: -3.0)]
    

    //Initialization of MemeEditorViewController UI View
    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        initializeMemeEditableParameters()
        
        //(DO NOT ERASE!!!!!!!) Will require later when saving memes after text editing
        /*let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        memes = applicationDelegate.memes
        tableView.reloadData() (DO NOT ERASE!!!!!!!)*/
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    @IBAction func pickAnImage(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        /*pickerController.allowsEditing = true*/
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
        self.topTextField.hidden = false
        self.bottomTextField.hidden = false
        
    }
    
    @IBAction func pickedAnImageFromCamera(sender: AnyObject) {
        
        if let cameraAvaialble = UIImagePickerController.isCameraDeviceAvailable as? BooleanType{
         
         cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
   
         let imagePickedFromCamera = UIImagePickerController()
         imagePickedFromCamera.delegate = self
         /*imagePickedFromCamera.allowsEditing = true*/
         imagePickedFromCamera.sourceType = UIImagePickerControllerSourceType.Camera
         self.presentViewController(imagePickedFromCamera, animated: true, completion: nil)
         self.topTextField.hidden = false
         self.bottomTextField.hidden = false
            
        }
            
        else{
            
            noCamera()
        }
    }
    
    @IBAction func saveNewMeme(sender: AnyObject) {
        
        self.memedImage = generationOfMemedImage()
        self.memeToSave = save()
        /*let saveMemeController = self.storyboard!.instantiateViewControllerWithIdentifier("SavedMemeViewController") as! SavedMemeViewController
        saveMemeController.meme = self.memeToSave
        self.presentViewController(saveMemeController, animated: true, completion: nil)*/
        
    }
    
    @IBAction func textFieldEditor(sender: AnyObject) {
            
            switch (sender.tag) {
                
            case 1:
                self.topTextField.delegate = self
    
            case 2:
                self.bottomTextField.delegate = self
                
            default:
                
                return
            }
    }
    
    // Method to initialize Meme UI TextField parameters for alignment, placeholder, and font style
    func initializeMemeEditableParameters(){
        
        /*Set UITextfields default text font style, visual and alignment settings where font style
        is defined in class level variable assignment*/
        
        var fieldShifter = UITextField(frame: CGRectMake(50.0, 30.0, 300.0, 50.0))
        self.topTextField.defaultTextAttributes = memeTextAttributes
        self.bottomTextField.defaultTextAttributes = memeTextAttributes
        
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        
        self.topTextField.textAlignment = .Center
        self.topTextField.text = "Top"
        self.bottomTextField.textAlignment = .Center
        self.bottomTextField.text = "Bottom"
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[NSObject : AnyObject]){
        
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imagePickerView.image = image
                dismissViewControllerAnimated(true, completion: nil)
                self.enableSave = true
            }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
    
            self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if topTextField.text == "Top" || bottomTextField.text == "Bottom" {
            textField.text = " "

        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
    
    func keyboardAnimatedShiftAppear(notification: NSNotification){
    
            self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardAnimatedShiftDisappear(notification: NSNotification){
    
            self.view.frame.origin.y += getKeyboardHeight(notification)
    
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
    
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAnimatedShiftAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAnimatedShiftDisappear:", name: UIKeyboardWillHideNotification, object: nil)
    
    }
    
    func unsubscribeFromKeyboardNotifications(){
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func generationOfMemedImage() -> UIImage {
        //To Hide both the Bottom ToolBar and Top Navigation Bar
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.photoToolbar.hidden = true
        
        // Provides a view of image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // To Show both the Bottom ToolBar and Top Navigation Bar
        self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.photoToolbar.hidden = false
        
        return memedImage
    }
    
    func save() -> GenMeme{
        let meme =  GenMeme(textHeader: topTextField.text, textFootNote: bottomTextField.text, pickedImage: self.imagePickerView.image, memedImage: self.memedImage)
        return meme
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "No camera found on current device", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        }
    
}

