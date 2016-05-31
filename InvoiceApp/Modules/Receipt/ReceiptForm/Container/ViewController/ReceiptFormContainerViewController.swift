//
//  ReceiptFormContainerViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/11/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class ReceiptFormContainerViewController: UIViewController {
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedServiceObject: Service?
    var passedOverStayObject: OverStay?
    var viewModel: ReceiptFormContainerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirst()
    }
    
    func initFirst() {
        viewModel = ReceiptFormContainerViewModel()
        if let model = viewModel {
            model.delegate = self
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "receiptFormEmbedSegue" {
            if let vc = segue.destinationViewController as? ReceiptFormViewController {
                vc.passedInvoiceObject = passedInvoiceObject
                vc.passedReceiptObject = passedReceiptObject
                vc.passedServiceObject = passedServiceObject
                vc.passedOverStayObject = passedOverStayObject
            }
        }
    }
    
    @IBAction func onDonePressed(sender: AnyObject) {
        let obj : ReceiptFormViewController = self.childViewControllers.last as! ReceiptFormViewController
        
        if let model = viewModel {
            model.processSubmit(obj.tfName, tfPrice: obj.tfPrice, tfNote: obj.tfNote, imgView: obj.imageView, taxPrice: obj.defaultTaxPriceObject, receipt: obj.passedReceiptObject, service: obj.passedServiceObject, overStay: obj.passedOverStayObject, invoice: obj.passedInvoiceObject)
        }
    }
}
