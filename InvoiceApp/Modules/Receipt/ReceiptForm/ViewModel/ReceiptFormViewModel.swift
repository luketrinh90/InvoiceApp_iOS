//
//  ReceiptFormViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/11/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import UITextField_Shake
import RealmSwift

class ReceiptFormViewModel: NSObject {
    
    var delegate: ReceiptFormViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func checkTextField(textField: UITextField) -> Bool {
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 0
        
        if let tf = textField.text {
            if tf.isEmpty {
                textField.layer.borderColor = UIColor.redColor().CGColor
                textField.shake(10, withDelta: 1.0, speed: 0.05)
                return false
            }
        }
        
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.grayColor().CGColor
        return true
    }
    
    /////////////////////////////////////
    
    func processBrowseImage(imagePicker: UIImagePickerController, dele: UIViewController) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController()
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Take Photo",comment:""), style: .Default) { action -> Void in
            imagePicker.sourceType = .Camera
            dele.presentViewController(imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Choose Photo",comment:""), style: .Default) { action -> Void in
            imagePicker.sourceType = .PhotoLibrary
            dele.presentViewController(imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        dele.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func getPath() -> String {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let newPath = documentsPath.URLByAppendingPathComponent("ImagesForInvoiceApp")
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(newPath.path!, withIntermediateDirectories: true, attributes: nil)
            if let dele = delegate {
                dele.imagePath = newPath.path
            }
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        return "ERROR"
    }
    
    func saveImage (image: UIImage, path: String) -> Bool {
        var fileName = ""
        
        if let dele = delegate {
            if let invoiceId = dele.passedInvoiceObject,
                let receiptId = dele.passedReceiptObject {
                fileName = String(invoiceId.id) + String(receiptId.id) + ".jpg"
            }
        }
        
        let finalPath = (path as NSString).stringByAppendingPathComponent(fileName)
        let jpgImageData = UIImageJPEGRepresentation(image, 0.5)
        let result = jpgImageData!.writeToFile(finalPath, atomically: true)
        
        if result == true {
            saveImageIntoDatabase(fileName)
        }
        
        return result
    }
    
    func loadImageFromPath() -> UIImage? {
        if let dele = delegate {
            if let receipt = dele.passedReceiptObject {
                
                let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
                let imagePath = documentsPath.URLByAppendingPathComponent("ImagesForInvoiceApp/\(receipt.photo)")
                
                let image = UIImage(contentsOfFile: imagePath.path!)
                
                if image == nil {
                    print("Missing image at: \(receipt.photo)")
                } else {
                    dele.imageView.image = image
                }
                print("Loading image from path: \(imagePath)") // this is just for you to see the path in case you want to go to the directory, using Finder.
                return image
            }
        }
        return nil
    }
    
    func saveImageIntoDatabase(fileName: String) {
        if let dele = delegate {
            try! realm.write {
                if let receipt = dele.passedReceiptObject {
                    receipt.photo = fileName
                }
            }
        }
    }
    
    func processTaxPrice() {
        if let dele = delegate {
            let obj = realm.objects(TaxPrice).filter("invoiceID = \(dele.passedInvoiceObject!.id)").filter("receiptID = \(dele.passedReceiptObject!.id)")
            if obj.count > 0 {
                try! realm.write {
                    obj.last?.isCompleted = false
                    dele.defaultTaxPriceObject = obj.last
                    print("LAST TAX PRICE OBJECT WITH DEFAULT VALUE \(dele.defaultTaxPriceObject)")
                }
            } else {
                createNewTaxPriceObject()
            }
        }
    }
    
    func createNewTaxPriceObject() {
        if let dele = delegate {
            let taxPrice = TaxPrice()
            taxPrice.invoiceID = dele.passedInvoiceObject!.id
            taxPrice.receiptID = dele.passedReceiptObject!.id
            taxPrice.priceTax19 = 0.0
            taxPrice.priceTax7 = 0.0
            taxPrice.priceTax0 = 0.0
            taxPrice.isCompleted = false
            try! realm.write {
                realm.add(taxPrice)
                dele.defaultTaxPriceObject = taxPrice
                print("CREATE TAX PRICE OBJECT WITH DEFAULT VALUE \(dele.defaultTaxPriceObject)")
            }
        }
    }
    
    func updateTotalPrice(newString: String) {
        if let dele = delegate {
            try! realm.write {
                //
                if newString != "" {
                    
                    if newString.containsString(",") {
                        let replaceString = newString.replace(",", withString:".")
                        dele.passedReceiptObject?.priceBefore = Double(replaceString)!.roundToPlaces(2)
                    } else {
                        dele.passedReceiptObject?.priceBefore = Double(newString)!.roundToPlaces(2)
                    }
                    
                } else {
                    dele.passedReceiptObject?.priceBefore = 0.0
                }
                print("DEFAULT DEFAULT DEFAULT DEFAULT DEFAULT PRICE \(dele.passedReceiptObject)")
            }
        }
    }
    
    func trimString(textField: UITextField) -> String {
        let trimmedString = textField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return trimmedString
    }
}

extension String {
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
