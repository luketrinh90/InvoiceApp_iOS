//
//  ReceiptViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/12/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class ReceiptViewModel: NSObject {
    var isName: Bool?
    var isNote: Bool?
    var isDate: Bool?
    var isCurrency: Bool?
    
    var delegate: ReceiptViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func processReceipt() {
        if let dele = delegate {
            let obj = realm.objects(Receipt).filter("invoiceID = \(dele.passedInvoiceObject!.id)")
            if obj.count > 0 {
                if obj.last!.isCompleted == false {
                    dele.defaultReceiptObject = obj.last
                    print("LAST RECEIPT OBJECT WITH DEFAULT VALUE \(dele.defaultReceiptObject)")
                } else {
                    createNewReceiptObject()
                }
            } else {
                createNewReceiptObject()
            }
        }
    }
    
    func createNewReceiptObject() {
        if let dele = delegate {
            let receipt = Receipt()
            receipt.invoiceID = dele.passedInvoiceObject!.id
            receipt.id = receipt.incrementID(dele.passedInvoiceObject!.id)
            receipt.name = ""
            receipt.price = 0.0
            receipt.date = NSDate()
            receipt.note = ""
            receipt.category = ""
            receipt.type = ""
            receipt.photo = ""
            receipt.isCompleted = false
            try! realm.write {
                realm.add(receipt)
                dele.defaultReceiptObject = receipt
                print("CREATE RECEIPT OBJECT WITH DEFAULT VALUE \(dele.defaultReceiptObject)")
            }
        }
    }
}
