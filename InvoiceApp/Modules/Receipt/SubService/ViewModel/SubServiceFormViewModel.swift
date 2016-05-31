//
//  SubServiceFormViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/13/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import UITextField_Shake
import RealmSwift

class SubServiceFormViewModel: NSObject {
    
    var isName: Bool?
    var isOccasion: Bool?
    var employeesGuestName: Bool?
    var delegate: SubServiceFormViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func processNext(isViand: Bool) -> Bool {
        if let dele = delegate {
            isName = checkTextField(dele.tfName)
            
            if isViand == false {
                isOccasion = checkTextField(dele.tfOccasion)
                employeesGuestName = checkTextField(dele.tfEmployeesGuest)
                if isName! && isOccasion! && employeesGuestName! {
                    updateService()
                    return true
                }
            } else {
                if isName! {
                    updateService()
                    return true
                }
            }
        }
        return false
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
    
    func updateService() {
        if let dele = delegate {
            try! realm.write {
                dele.passedServiceObject?.yourName = trimString(dele.tfName)
                dele.passedServiceObject?.occasion = trimString(dele.tfOccasion)
                dele.passedServiceObject?.employeesGuest = trimString(dele.tfEmployeesGuest)
                dele.passedServiceObject?.tax = calculateTaxForService()
                dele.passedServiceObject?.isCompleted = false
            }
        }
    }
    
    func trimString(textField: UITextField) -> String {
        let trimmedString = textField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return trimmedString
    }
    
    func calculateTaxForService() -> Double {
        if let dele = delegate {
            if dele.passedReceiptObject?.type == "Breakfast" {
                return 1.67
            }
        }
        return 3.10
    }
}
