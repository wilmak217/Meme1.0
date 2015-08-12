//
//  MemeEditorViewController.swift
//  ImageLoader
//
//  Created by Markus Willburn on 8/8/15.
//  Copyright (c) 2015 Markus Willburn. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    /*var  = [CreatedMemes]!*/
    
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
        if let cameraAvaialble = UIImagePickerController.isCameraDeviceAvailable as? BooleanType{
        
            cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        }
        else {
            noCamera()
        }
      
        self.subscribeToKeyboardNotifications()
        /*self.subscribeToHideKeyboardNotifications()*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        /*self.unsubscribeFromHidingKeyboardNotifications()*/
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
        
         let imagePickedFromCamera = UIImagePickerController()
         imagePickedFromCamera.delegate = self
         /*imagePickedFromCamera.allowsEditing = true*/
         imagePickedFromCamera.sourceType = UIImagePickerControllerSourceType.Camera
         self.presentViewController(imagePickedFromCamera, animated: true, completion: nil)
         self.topTextField.hidden = false
         self.bottomTextField.hidden = false
        
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
        
        /*self.topTextField.hidden = true
        self.bottomTextField.hidden = true*/
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[NSObject : AnyObject]){
        
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
                imagePickerView.contentMode = .ScaleAspectFit
                self.imagePickerView.image = image
                dismissViewControllerAnimated(true, completion: nil)
            
            }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
    
            self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        if topTextField.isFirstResponder() || bottomTextField.isFirstResponder(){
            
            let newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
            
            switch textField {
            
            case topTextField:
                println("Top text field is now editable!")
                /*Insert code for image croppping functionality to fit textField string in appropriate position based on image type, i.e. portrait or landscape */
                
            case bottomTextField:
                
                println("Bottom text field is now editable!")
                /*Insert code for image croppping functionality to fit textField string in appropriate position based on image type, i.e. portrait or landscape */
                
            default:
                
                return false
            }
        }
        
    return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {

        if topTextField.text == "Top" || bottomTextField.text == "Bottom" {
            textField.text = " "
        }
    }
    
    
    func keyboardAnimatedShiftAppear(notification: NSNotification){
        
        if bottomTextField.isFirstResponder(){

           self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardAnimatedShiftDisappear(notification: NSNotification){
        
        if bottomTextField.isFirstResponder(){
            
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
    
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
    func subscribeToKeyboardNotifications(){
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAnimatedShiftAppear", name: UIKeyboardWillShowNotification, object: nil)
    
    }
    
    func unsubscribeFromKeyboardNotifications(){
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    
    }

    func subscribeToHideKeyboardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAnimatedShiftDisappear", name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromHidingKeyboardNotifications(){
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "No camera found on current device", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
        }
    
    
}

