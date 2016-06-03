//
//  ReceiptViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/10/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class ReceiptViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnViewPDF: UIButton!
    @IBOutlet weak var receiptTableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblNoData: UILabel!
    var passedInvoiceObject: Invoice?
    var viewModel: ReceiptViewModel?
    var defaultReceiptObject: Receipt?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //lblTitle.text = "Receipt - " + passedInvoiceObject?.name
        initFirst()
    }
    
    func filterReceipt() -> Int {
        if let obj = passedInvoiceObject {
            return realm.objects(Receipt).filter("invoiceID = \(obj.id)").filter("isCompleted = 1").count
        }
        return 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        receiptTableView.reloadData()
    }
    
    func initFirst() {
        viewModel = ReceiptViewModel()
        if let model = viewModel {
            model.delegate = self
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterReceipt() > 0 {
            lblNoData.hidden = showEmptyTableErrorMessage()
            btnViewPDF.enabled = true
            return filterReceipt()
        }
        lblNoData.hidden = showEmptyTableErrorMessage()
        btnViewPDF.enabled = false
        return 0
    }
    
    func showEmptyTableErrorMessage() -> Bool {
        if filterReceipt() > 0 {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("receiptTableViewCell") as! ReceiptTableViewCell
        
        cell.lblReceiptName.text = realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(passedInvoiceObject!.id)").filter("isCompleted = 1")[indexPath.row].name
        cell.lblReceiptDate.text = NSLocalizedString("Date: ",comment:"") + dateToString(realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(passedInvoiceObject!.id)").filter("isCompleted = 1")[indexPath.row].date)
        
        if passedInvoiceObject?.currencyCode == "EUR" {
            cell.lblReceiptPrice.text = NSLocalizedString("Price: ", comment: "") + Helper.showCurrencySymbol(passedInvoiceObject!.currencyCode) + String(Double(realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(passedInvoiceObject!.id)").filter("isCompleted = 1")[indexPath.row].priceAfter).roundToPlaces(2)).replace(".", withString:",")
        } else {
            cell.lblReceiptPrice.text = NSLocalizedString("Price: ", comment: "") + Helper.showCurrencySymbol(passedInvoiceObject!.currencyCode) + String(Double(realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(passedInvoiceObject!.id)").filter("isCompleted = 1")[indexPath.row].priceAfter).roundToPlaces(2))
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let receipt = realm.objects(Receipt)[indexPath.row]
        print("Receipt id = \(receipt.id)")
        
        if receipt.category == "Service" {
            let services = realm.objects(Service).filter("receiptID = \(receipt.id)")
            if services.count > 0 {
                print("ServiceName = \(services[0].serviceName)")
            }
        }
        
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptReviewContainerViewController) as? ReceiptReviewContainerViewController,
            let invoiceObj = passedInvoiceObject,
            let nav = navigationController {
            
            let receipt = realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(invoiceObj.id)").filter("isCompleted = 1")[indexPath.row]
            let service = realm.objects(Service).filter("invoiceID = \(invoiceObj.id)").filter("receiptID = \(receipt.id)").filter("isCompleted = 1").last
            let taxPrice = realm.objects(TaxPrice).filter("invoiceID = \(invoiceObj.id)").filter("receiptID = \(receipt.id)").filter("isCompleted = 1").last
            let overStay = realm.objects(OverStay).filter("invoiceID = \(invoiceObj.id)").filter("receiptID = \(receipt.id)").filter("isCompleted = 1").last
            
            vc.passedInvoiceObject = passedInvoiceObject
            vc.passedReceiptObject = receipt
            vc.passedServiceObject = service
            vc.passedTaxPriceObject = taxPrice
            vc.passedOverStayObject = overStay
            
            nav.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deleteReceipt(indexPath, tableView: tableView)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func deleteReceipt(inPath:NSIndexPath, tableView: UITableView) {
        let alertController = UIAlertController(title: NSLocalizedString("Delete",comment:""), message: NSLocalizedString("Are you sure you want to delete this receipt?",comment:""), preferredStyle: .ActionSheet)
        let buttonDelete = UIAlertAction(title: NSLocalizedString("Delete Now",comment:""), style: .Destructive, handler: { (action) -> Void in
            self.processDeleteObject(inPath, tableView: tableView)
        })
        let buttonCancel = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: .Cancel) { (action) -> Void in
            tableView.setEditing(false, animated: true)
        }
        alertController.addAction(buttonDelete)
        alertController.addAction(buttonCancel)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func processDeleteObject(inPath:NSIndexPath, tableView: UITableView) {
        if let invoiceObj = passedInvoiceObject {
            let deleteReceiptObject = realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(invoiceObj.id)").filter("isCompleted = 1")[inPath.row]
            
            let deleteServiceObject = realm.objects(Service).filter("invoiceID = \(invoiceObj.id)").filter("receiptID = \(deleteReceiptObject.id)")
            let deleteTaxPriceObject = realm.objects(TaxPrice).filter("invoiceID = \(invoiceObj.id)").filter("receiptID = \(deleteReceiptObject.id)")
            let deleteOverStayObject = realm.objects(OverStay).filter("invoiceID = \(invoiceObj.id)").filter("receiptID = \(deleteReceiptObject.id)")
            
            realm.beginWrite()
            realm.delete(deleteReceiptObject)
            realm.delete(deleteServiceObject)
            realm.delete(deleteTaxPriceObject)
            realm.delete(deleteOverStayObject)
            try! realm.commitWrite()
            
            tableView.deleteRowsAtIndexPaths([inPath], withRowAnimation: .Automatic)
        }
    }
    
    func dateToString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter.stringFromDate(date)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "receiptSegue") {
            if let vc: ReceiptCategoryViewController = segue.destinationViewController as? ReceiptCategoryViewController {
                if let model = viewModel {
                    model.processReceipt()
                    vc.passedReceiptObject = defaultReceiptObject
                    vc.passedInvoiceObject = passedInvoiceObject
                }
            }
        }
        
        if segue.identifier == "viewPDF" {
            if let vc: PDFViewController = segue.destinationViewController as? PDFViewController {
                vc.passedInvoiceObject = passedInvoiceObject
            }
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
}
