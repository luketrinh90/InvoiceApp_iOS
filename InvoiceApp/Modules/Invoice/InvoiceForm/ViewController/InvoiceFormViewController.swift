//
//  InvoiceFormViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/9/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class InvoiceFormViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var tfInvoiceName: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfCurrency: UITextField!
    
    var viewModel: InvoiceFormViewModel?
    weak var actionToEnable : UIAlertAction?
    var pickerData: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirst()
        tfInvoiceName.becomeFirstResponder()
    }
    
    func initFirst() {
        viewModel = InvoiceFormViewModel()
        if let model = viewModel {
            model.delegate = self
            model.initPicker()
            model.readPropertyList()
        }
    }
    
    @IBAction func processSubmit(sender: AnyObject) {
        if let model = viewModel {
            model.processSubmit()
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            self.view.endEditing(true)
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func onOutsidePressed(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let data = pickerData {
            return data.count
        }
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let data = pickerData {
            return data[row]
        }
        return "Error"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let data = pickerData {
            tfCurrency.text = data[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        if let data = pickerData {
            pickerLabel.text = data[row]
        }
        pickerLabel.font = UIFont.systemFontOfSize(22, weight: UIFontWeightThin)
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    // UITextField Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.addTarget(self, action: #selector(InvoiceFormViewController.textChanged(_:)), forControlEvents: .EditingChanged)
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
        if textField.tag == 2 || textField.tag == 3 {
            return false
        }
        return Helper.limitCharacter(textField, range: range, string: string, length: 50)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let model = viewModel {
            model.processSubmit()
        }
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
