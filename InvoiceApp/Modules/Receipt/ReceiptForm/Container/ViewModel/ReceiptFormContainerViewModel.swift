//
//  ReceiptFormContainerViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/11/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import UITextField_Shake
import RealmSwift

class ReceiptFormContainerViewModel: NSObject {
    var isName: Bool?
    var isPrice: Bool?
    var isPhoto: Bool?
    
    var delegate: ReceiptFormContainerViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func processSubmit(tfName: UITextField, tfPrice: UITextField, tfNote: UITextField, imgView:UIImageView, taxPrice: TaxPrice?, receipt: Receipt?, service: Service?, overStay: OverStay?, invoice: Invoice?) {
        isName = checkTextField(tfName)
        isPrice = checkTextField(tfPrice)
        isPhoto = checkPhoto(imgView)
        
        if isName! && isPrice! && isPhoto! {
            addReceipt(tfName, tfPrice: tfPrice, tfNote: tfNote, taxPrice: taxPrice, receipt: receipt, service: service, overStay: overStay, invoice: invoice)
        } else {
            print("SUBMIT PROBLEM")
        }
    }
    
    func checkPhoto(imgView:UIImageView) -> Bool {
        imgView.layer.borderWidth = 1
        imgView.layer.masksToBounds = true
        if imgView.image == nil {
            imgView.layer.borderColor = UIColor.redColor().CGColor
            return false
        }
        imgView.layer.borderColor = UIColor.clearColor().CGColor
        return true
    }
    
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
    
    func addReceipt(tfName: UITextField, tfPrice: UITextField, tfNote: UITextField, taxPrice: TaxPrice?, receipt: Receipt?, service: Service?, overStay: OverStay?, invoice: Invoice?) {
        
        try! realm.write {
            receipt!.name = trimString(tfName)
            receipt!.note = trimString(tfNote)
            receipt!.date = NSDate()
            //receipt
            receipt!.isCompleted = true
            
            if taxPrice?.priceTax19 != 0 || taxPrice?.priceTax7 != 0 || taxPrice?.priceTax0 != 0 {
                taxPrice?.isCompleted = true
            }
            
            if receipt?.category == "Service" {
                service!.isCompleted = true
            }
            if receipt?.category == "Overnight Stay" {
                overStay!.isCompleted = true
            }
            
            let viewControllers: [UIViewController] = delegate!.navigationController!.viewControllers as [UIViewController]
            delegate!.navigationController!.popToViewController(viewControllers[1], animated: true)
        }
    }
    
    func trimString(textField: UITextField) -> String {
        let trimmedString = textField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return trimmedString
    }
}
