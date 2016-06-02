//
//  SubServiceFormViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/12/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class SubServiceFormViewController: UIViewController, UITextFieldDelegate {
    
    var array: [String]?
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedServiceObject: Service?
    
    var viewModel: SubServiceFormViewModel?
    weak var actionToEnable : UIAlertAction?
    
    @IBOutlet weak var lblSubServiceFormName: UILabel!
    //lines
    @IBOutlet weak var imgLine1: UIImageView!
    @IBOutlet weak var imgLine2: UIImageView!
    @IBOutlet weak var imgLine3: UIImageView!
    
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfOccasion: UITextField!
    @IBOutlet weak var tfEmployeesGuest: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirst()
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func initFirst() {
        viewModel = SubServiceFormViewModel()
        if let model = viewModel {
            model.delegate = self
        }
        
        //
        lblSubServiceFormName.text = NSLocalizedString((passedServiceObject?.serviceName)!,comment:"")
        tfName.becomeFirstResponder()
        if passedServiceObject?.serviceName == "Viand" {
            tfOccasion.hidden = true
            tfEmployeesGuest.hidden = true
            
            imgLine2.hidden = true
            imgLine3.hidden = true
        }
        
        if passedServiceObject?.serviceName == "Guest" {
            tfEmployeesGuest.placeholder = NSLocalizedString("guests name",comment:"")
        }
    }
    
    @IBAction func onNextPressed(sender: AnyObject) {
        if let model = viewModel {
            if model.processNext(tfOccasion.hidden) == true {
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptFormContainerViewController) as? ReceiptFormContainerViewController,
                    let nav = navigationController {
                    vc.passedInvoiceObject = passedInvoiceObject
                    vc.passedReceiptObject = passedReceiptObject
                    vc.passedServiceObject = passedServiceObject
                    nav.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    // UITextField Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.addTarget(self, action: #selector(SubServiceFormViewController.textChanged(_:)), forControlEvents: .EditingChanged)
    }
    func textFieldDidEndEditing(textField: UITextField) {
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return Helper.limitCharacter(textField, range: range, string: string, length: 50)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        onNextPressed(self)
        return textField.endEditing(true)
    }
    
    //prevent copy/paste
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.cut(_:)) || action == #selector(NSObject.selectAll(_:)) || action == #selector(NSObject.paste(_:)) || action == #selector(NSObject.copy(_:)) || action == #selector(NSObject.select(_:)) || action == #selector(NSObject.delete(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textChanged(sender:UITextField) {
        let trimmedString = sender.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        if trimmedString.characters.count == 0 {
            sender.text = ""
        }
        self.actionToEnable?.enabled = (trimmedString != "")
    }
    
}
