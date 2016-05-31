//
//  ReceiptReviewContainerViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/26/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class ReceiptReviewContainerViewController: UIViewController {
    
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedServiceObject: Service?
    var passedOverStayObject: OverStay?
    var passedTaxPriceObject: TaxPrice?
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = passedReceiptObject?.name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "receiptReviewEmbedSegue") {
            if let vc: ReceiptReviewViewController = segue.destinationViewController as? ReceiptReviewViewController {
                vc.passedInvoiceObject = passedInvoiceObject
                vc.passedReceiptObject = passedReceiptObject
                vc.passedServiceObject = passedServiceObject
                vc.passedTaxPriceObject = passedTaxPriceObject
                vc.passedOverStayObject = passedOverStayObject
            }
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
}
