//
//  SubServiceViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/13/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class SubServiceViewModel: NSObject {
    
    var delegate: SubServiceViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func processService(serviceName: String) {
        if let dele = delegate {
            let obj = realm.objects(Service).filter("invoiceID = \(dele.passedInvoiceObject!.id)").filter("receiptID = \(dele.passedReceiptObject!.id)")
            if obj.count > 0 {
                try! realm.write {
                    obj.last?.serviceName = serviceName
                    obj.last?.isCompleted = false
                    dele.defaultServiceObject = obj.last
                    print("LAST SERVICE OBJECT WITH DEFAULT VALUE \(dele.defaultServiceObject)")
                }
            } else {
                createNewServiceObject(serviceName)
            }
        }
    }
    
    func createNewServiceObject(serviceName: String) {
        if let dele = delegate {
            let service = Service()
            service.invoiceID = dele.passedInvoiceObject!.id
            service.receiptID = dele.passedReceiptObject!.id
            service.serviceName = serviceName
            service.yourName = ""
            service.occasion = ""
            service.employeesGuest = ""
            service.tax = 0.0
            service.isCompleted = false
            try! realm.write {
                realm.add(service)
                dele.defaultServiceObject = service
                print("CREATE SERVICE OBJECT WITH DEFAULT VALUE \(dele.defaultServiceObject)")
            }
        }
    }
}

