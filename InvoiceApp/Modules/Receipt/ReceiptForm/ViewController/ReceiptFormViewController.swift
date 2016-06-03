//
//  ReceiptFormViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/10/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class ReceiptFormViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedServiceObject: Service?
    var passedOverStayObject: OverStay?
    var defaultTaxPriceObject: TaxPrice?
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var btnPlus: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController?
    weak var actionToEnable : UIAlertAction?
    var viewModel: ReceiptFormViewModel?
    var imagePath: String?
    var validatePrice: String?
    
    var priceOptions: [Int: Bool] = [
        19 : false,
        7 : false,
        0 : false
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirst()
    }
    
    func initFirst() {
        viewModel = ReceiptFormViewModel()
        if let model = viewModel {
            model.delegate = self
            model.getPath()
            model.loadImageFromPath()
            model.processTaxPrice()
            initUploadImage()
            
            let language = NSBundle.mainBundle().preferredLocalizations.first! as NSString
            if language != "en" {
                tfCategory.text = NSLocalizedString((passedReceiptObject?.category)! + "Review",comment:"")
                tfType.text = NSLocalizedString((passedReceiptObject?.type)! + "Review",comment:"")
                
                //validate in delegate
                validatePrice = "\\,.{3,}"
            } else {
                tfCategory.text = NSLocalizedString((passedReceiptObject?.category)!,comment:"")
                tfType.text = NSLocalizedString((passedReceiptObject?.type)!,comment:"")
                
                //validate in delegate
                validatePrice = "\\..{3,}"
            }
        }
    }
    
    func initUploadImage() {
        imagePicker = UIImagePickerController()
        imagePicker!.delegate = self
        imagePicker!.allowsEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let price = passedReceiptObject?.priceBefore {
            if price != 0.0 {
                
                let language = NSBundle.mainBundle().preferredLocalizations.first! as NSString
                if language != "en" {
                    let replaceString = String(price).replace(".", withString:",")
                    tfPrice.text = replaceString
                } else {
                    tfPrice.text = String(Double(price).roundToPlaces(2))
                }
                
                btnPlus.userInteractionEnabled = true
                btnPlus.alpha = 1
            } else {
                tfPrice.text = ""
            }
        }
    }
    
    @IBAction func onAddPricePressed(sender: AnyObject) {
        let alertController = UIAlertController(title: NSLocalizedString("Tax Options",comment:""), message: NSLocalizedString("Please choose 1 option below",comment:""), preferredStyle: .ActionSheet)
        let buttonOne = UIAlertAction(title: "19%" + NSLocalizedString(" and ",comment:"") + "7%", style: .Default, handler: { (action) -> Void in
            self.priceOptions[19] = true
            self.priceOptions[7] = true
            self.priceOptions[0] = false
            self.pushTaxPrice()
        })
        let buttonTwo = UIAlertAction(title: "7%" + NSLocalizedString(" and ",comment:"") + "0%", style: .Default, handler: { (action) -> Void in
            self.priceOptions[19] = false
            self.priceOptions[7] = true
            self.priceOptions[0] = true
            self.pushTaxPrice()
        })
        let buttonThree = UIAlertAction(title: "19%" + NSLocalizedString(" and ",comment:"") + "0%", style: .Default, handler: { (action) -> Void in
            self.priceOptions[19] = true
            self.priceOptions[7] = false
            self.priceOptions[0] = true
            self.pushTaxPrice()
        })
        let buttonCancel = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: .Cancel) { (action) -> Void in
        }
        alertController.addAction(buttonOne)
        alertController.addAction(buttonTwo)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonCancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func pushTaxPrice() {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.TaxViewController) as? TaxViewController,
            let nav = navigationController {
            vc.priceOptions = priceOptions
            vc.passedInvoiceObject = passedInvoiceObject
            vc.passedReceiptObject = passedReceiptObject
            vc.passedServiceObject = passedServiceObject
            vc.passedOverStayObject = passedOverStayObject
            vc.passedTaxPriceObject = defaultTaxPriceObject
            nav.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onAddPhotoPressed(sender: AnyObject) {
        if let model = viewModel {
            if let iP = imagePicker {
                model.processBrowseImage(iP, dele: self)
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = resizeImage(pickedImage, newWidth: 194)
            if let model = viewModel {
                model.saveImage(imageView.image!, path: imagePath!)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    // UITextField Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.addTarget(self, action: #selector(ReceiptFormViewController.textChanged(_:)), forControlEvents: .EditingChanged)
    }
    func textFieldDidEndEditing(textField: UITextField) {
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 1 {
            // max 2 fractional digits allowed
            let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let regex = try! NSRegularExpression(pattern: validatePrice!, options: [])
            let matches = regex.matchesInString(newText, options:[], range:NSMakeRange(0, newText.characters.count))
            guard matches.count == 0 else { return false }
            
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                inputTotalPrice(textField, range: range, string: string)
                return Helper.limitCharacter(textField, range: range, string: string, length: 14)
            case ".":
                let array = textField.text?.characters.map { String($0) }
                var decimalCount = 0
                for character in array! {
                    if character == "." {
                        decimalCount += 1
                    }
                }
                if decimalCount == 1 {
                    return false
                } else {
                    return true
                }
            case ",":
                let array = textField.text?.characters.map { String($0) }
                var decimalCount = 0
                for character in array! {
                    if character == "," {
                        decimalCount += 1
                    }
                }
                if decimalCount == 1 {
                    return false
                } else {
                    return true
                }
            default:
                let array = string.characters.map { String($0) }
                if array.count == 0 {
                    inputTotalPrice(textField, range: range, string: string)
                    return true
                }
                return false
            }
        }
        return Helper.limitCharacter(textField, range: range, string: string, length: 50)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //        if let model = viewModel {
        //            model.processSubmit()
        //        }
        return textField.endEditing(true)
    }
    
    //prevent copy/paste
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.cut(_:)) || action == #selector(NSObject.selectAll(_:)) || action == #selector(NSObject.paste(_:)) || action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.select(_:)) || action == #selector(NSObject.delete(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textChanged(sender:UITextField) {
        let trimmedString = sender.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        if trimmedString.characters.count == 0 {
            sender.text = ""
        } else {
            if trimmedString.characters.first == "." || trimmedString.characters.first == "," {
                sender.text = ""
            }
        }
        self.actionToEnable?.enabled = (trimmedString != "")
    }
    
    func inputTotalPrice(textField: UITextField, range: NSRange, string: String) {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        
        if newString == "" {
            btnPlus.userInteractionEnabled = false
            btnPlus.alpha = 0.5
        } else {
            btnPlus.userInteractionEnabled = true
            btnPlus.alpha = 1
        }
        if let model = viewModel {
            model.updateTotalPrice(newString as String)
        }
    }
}
