//
//  OvernightStayViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/27/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class OvernightStayViewController: UIViewController {
    
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var tfNumOfTimes: UITextField!
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedOverStayObject: OverStay?
    
    var viewModel: OvernightStayViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = OvernightStayViewModel()
        if let model = viewModel {
            model.delegate = self
            lblType.text = NSLocalizedString((passedReceiptObject?.type)!,comment:"")
            tfNumOfTimes.becomeFirstResponder()
        }
    }
    
    @IBAction func btnNext(sender: AnyObject) {
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptFormContainerViewController) as? ReceiptFormContainerViewController,
            let nav = navigationController {
            if let model = viewModel {
                if model.processNext() == true {
                    vc.passedInvoiceObject = passedInvoiceObject
                    vc.passedReceiptObject = passedReceiptObject
                    vc.passedOverStayObject = passedOverStayObject
                    nav.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
}
