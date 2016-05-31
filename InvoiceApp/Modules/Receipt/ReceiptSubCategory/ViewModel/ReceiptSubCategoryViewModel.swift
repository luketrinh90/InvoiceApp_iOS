//
//  ReceiptSubCategoryViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/13/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class ReceiptSubCategoryViewModel: NSObject {
    
    var delegate: ReceiptSubCategoryViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func processOverStay(overStayType: String) {
        if let dele = delegate {
            
            let obj = realm.objects(OverStay).filter("invoiceID = \(dele.passedInvoiceObject!.id)").filter("receiptID = \(dele.passedReceiptObject!.id)")
            if obj.count > 0 {
                try! realm.write {
                    obj.last?.tax = calculateTaxForOverStay(overStayType)
                    obj.last?.numberOfTimes = 0
                    obj.last?.totalTax = 0.0
                    obj.last?.isCompleted = false
                    dele.defaultOverStayObject = obj.last
                    print("LAST OVER STAY OBJECT WITH DEFAULT VALUE \(dele.defaultOverStayObject)")
                }
            } else {
                createNewOverStayObject(overStayType)
            }
        }
    }
    
    func createNewOverStayObject(overStayType: String) {
        if let dele = delegate {
            let overStay = OverStay()
            overStay.invoiceID = dele.passedInvoiceObject!.id
            overStay.receiptID = dele.passedReceiptObject!.id
            overStay.tax = calculateTaxForOverStay(overStayType)
            overStay.numberOfTimes = 0
            overStay.totalTax = 0.0
            overStay.isCompleted = false
            try! realm.write {
                realm.add(overStay)
                dele.defaultOverStayObject = overStay
                print("CREATE OVER STAY OBJECT WITH DEFAULT VALUE \(dele.defaultOverStayObject)")
            }
        }
    }
    
    func calculateTaxForOverStay(overStayType: String) -> Double {
        if overStayType == "Breakfast" {
            return 1.67
        } else if overStayType == "Lunch" {
            return 3.10
        }
        return 0.0
    }
}
