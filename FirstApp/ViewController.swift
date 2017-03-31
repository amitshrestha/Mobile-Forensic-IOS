//
//  ViewController.swift
//  FirstApp
//
//  Created by Amit on 1/9/17.
//  Copyright © 2017 Amit. All rights reserved.
//

import UIKit
var list = [""]

import UIKit
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //MARK: Properties

    @IBOutlet weak var secretMessagefield: UITextField!
    
    @IBAction func embedButton(sender: AnyObject) {
        self.performSegueWithIdentifier("embedviewconnect", sender: self)
    }
    
    @IBOutlet weak var myTableView: UITableView!
    let image = UIImagePickerController()

    
   //for image rotation 90 degree
    var rads = (90.0 * CGFloat(M_PI)) / 180.0;
    @IBAction func rotateButton(sender: AnyObject) {
        UIView.animateWithDuration(2.0, animations: {
            self.myImageView.transform = CGAffineTransformRotate(self.myImageView.transform, self.rads)
            
        })
        
    }
    
    
    //end of image rotation 90 degree

   //for image import
    @IBAction func importButton(sender: AnyObject) {
        //rotate back to original position first
        self.myImageView.transform = CGAffineTransformMakeRotation(0);
        //end of rotate back to original position first
        
        image.allowsEditing = false
        image.sourceType = .PhotoLibrary
        
        presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImageView.contentMode = .ScaleAspectFit
            myImageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var new_image: UIImageView!
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBOutlet weak var myImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        image.delegate = self
        self.view.backgroundColor = UIColor(red: 11/255, green: 77/255, blue: 146/255, alpha: 1)
//        let clearMatrix = dctForImageName("sample.png")
//        print("Clear image DCT matrix: \(clearMatrix)")
        
    }
    
    
    func dctForImageName(name:String) -> Matrix {
        let image = UIImage(named: name)
        let matrix = matrixFromImage(image!)
        let dctMatrix = calculateDCT(matrix, blockSize: 8)
        
        return dctMatrix
    }
    
    
    
   //end of image import code
    
    //start of image capture
    @IBAction func myCaptureBtn(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            image.delegate = self
            image.sourceType = .Camera
            image.allowsEditing = false
            presentViewController(image, animated: true, completion: nil)
        } else {
            print("The device has no camera")
        }
    }
    //end of image capture
    
    //start of export image
    
    @IBAction func exportImage(sender: AnyObject) {
         UIImageWriteToSavedPhotosAlbum(myImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    //end of export image
    
    override func viewWillAppear(animated: Bool) {
        UINavigationBar.appearance().backgroundColor = UIColor.greenColor()
        navigationItem.title = "Basic Image Skill"
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

