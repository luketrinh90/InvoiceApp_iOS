//
//  InvoiceViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/9/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class InvoiceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var invoiceTableView: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        invoiceTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if realm.objects(Invoice).count > 0 {
            lblNoData.hidden = showEmptyTableErrorMessage()
            return realm.objects(Invoice).count
        }
        lblNoData.hidden = showEmptyTableErrorMessage()
        return 0
    }
    
    func showEmptyTableErrorMessage() -> Bool {
        if realm.objects(Invoice).count > 0 {
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("invoiceTableViewCell") as! InvoiceTableViewCell
        
        cell.lblInvoiceName.text = realm.objects(Invoice).sorted("id", ascending: false)[indexPath.row].name
        cell.lblDate.text = NSLocalizedString("Date: ",comment:"") + dateToString(realm.objects(Invoice).sorted("id", ascending: false)[indexPath.row].date)
        cell.lblCurrency.text = NSLocalizedString("Currency: ", comment: "") + String(realm.objects(Invoice).sorted("id", ascending: false)[indexPath.row].currencyCode)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptViewController) as? ReceiptViewController,
            let nav = navigationController {
            vc.passedInvoiceObject = realm.objects(Invoice).sorted("id", ascending: false)[indexPath.row]
            nav.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deleteReceipt(indexPath, tableView: tableView)
        }
    }
    
    func deleteReceipt(inPath:NSIndexPath, tableView: UITableView) {
        let alertController = UIAlertController(title: NSLocalizedString("Delete",comment:""), message: NSLocalizedString("Are you sure you want to delete this invoice?",comment:""), preferredStyle: .ActionSheet)
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
        let deleteInvoiceObject = realm.objects(Invoice).sorted("id", ascending: false)[inPath.row]
        
        let deleteReceiptObject = realm.objects(Receipt).sorted("id", ascending: false).filter("invoiceID = \(deleteInvoiceObject.id)")
        let deleteServiceObject = realm.objects(Service).filter("invoiceID = \(deleteInvoiceObject.id)")
        let deleteTaxPriceObject = realm.objects(TaxPrice).filter("invoiceID = \(deleteInvoiceObject.id)")
        let deleteOverStayObject = realm.objects(OverStay).filter("invoiceID = \(deleteInvoiceObject.id)")
        
        realm.beginWrite()
        realm.delete(deleteInvoiceObject)
        realm.delete(deleteReceiptObject)
        realm.delete(deleteServiceObject)
        realm.delete(deleteTaxPriceObject)
        realm.delete(deleteOverStayObject)
        try! realm.commitWrite()
        
        tableView.deleteRowsAtIndexPaths([inPath], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func dateToString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter.stringFromDate(date)
    }
}
