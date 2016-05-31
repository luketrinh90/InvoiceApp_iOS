//
//  OvernightStayViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/27/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import UITextField_Shake
import RealmSwift

class OvernightStayViewModel: NSObject {
    
    var isNumOfTimes: Bool?
    var delegate: OvernightStayViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func processNext() -> Bool {
        if let dele = delegate {
            isNumOfTimes = checkTextField(dele.tfNumOfTimes)
            if isNumOfTimes! {
                updateOvernightStay()
                return true
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
    
    func updateOvernightStay() {
        if let dele = delegate {
            try! realm.write {
                dele.passedOverStayObject?.numberOfTimes = Int(dele.tfNumOfTimes.text!)!
                dele.passedOverStayObject!.totalTax = dele.passedOverStayObject!.tax * Double((dele.passedOverStayObject?.numberOfTimes)!)
            }
        }
    }
}

