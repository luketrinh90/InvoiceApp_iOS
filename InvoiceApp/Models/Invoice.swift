//
//  Invoice.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/9/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import RealmSwift

class Invoice: Object {
    dynamic var id = 0
    dynamic var name = ""
    dynamic var note = ""
    dynamic var date = NSDate()
    dynamic var currencyCode = ""
    
    func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        let RetNext: NSArray = Array(realm.objects(Invoice).sorted("id"))
        let last = RetNext.lastObject
        if RetNext.count > 0 {
            let valor = last?.valueForKey("id") as? Int
            return valor! + 1
        } else {
            return 1
        }
    }
}

class Receipt: Object {
    dynamic var invoiceID = 0
    dynamic var id = 0
    dynamic var name = ""
    dynamic var priceBefore = 0.0
    dynamic var priceAfter = 0.0
    dynamic var date = NSDate()
    dynamic var note = ""
    dynamic var category = ""
    dynamic var type = ""
    dynamic var photo = ""
    dynamic var isCompleted = false
    
    func incrementID(passedInvoiceId: Int) -> Int {
        let realm = try! Realm()
        let RetNext: NSArray = Array(realm.objects(Receipt).filter("invoiceID = \(passedInvoiceId)").sorted("id"))
        let last = RetNext.lastObject
        if RetNext.count > 0 {
            let valor = last?.valueForKey("id") as? Int
            return valor! + 1
        } else {
            return 1
        }
    }
}

class Service: Object {
    dynamic var invoiceID = 0
    dynamic var receiptID = 0
    
    //viand, employees, guest
    dynamic var serviceName = ""
    
    //form
    dynamic var yourName = ""
    dynamic var occasion = ""
    dynamic var employeesGuest = ""
    
    //1.67 or 3.10
    dynamic var tax = 0.0
    dynamic var isCompleted = false
}

class OverStay: Object {
    dynamic var invoiceID = 0
    dynamic var receiptID = 0
    
    //1.67 or 3.10 or 0.0
    dynamic var tax = 0.0
    dynamic var numberOfTimes = 0
    dynamic var totalTax = 0.0
    dynamic var isCompleted = false
}

//in taxPrice Form
class TaxPrice: Object {
    dynamic var invoiceID = 0
    dynamic var receiptID = 0
    //
    dynamic var priceTax19 = 0.0
    dynamic var priceTax7 = 0.0
    dynamic var priceTax0 = 0.0
    //
    dynamic var isCompleted = false
}
