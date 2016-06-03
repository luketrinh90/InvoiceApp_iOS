//
//  TaxViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/11/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class TaxViewController: UIViewController, UITextFieldDelegate {
    
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedServiceObject: Service?
    var passedOverStayObject: OverStay?
    var passedTaxPriceObject: TaxPrice?
    
    @IBOutlet weak var tf19: UITextField!
    @IBOutlet weak var tf7: UITextField!
    @IBOutlet weak var tf0: UITextField!
    
    var priceAfterTax19: Double? = 0.0
    var priceAfterTax7: Double? = 0.0
    var priceAfterTax0: Double? = 0.0
    var totalPriceAfterTax: Double? = 0.0
    
    weak var actionToEnable : UIAlertAction?
    var viewModel: TaxViewModel?
    var priceOptions: [Int: Bool]?
    var validatePrice: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirst()
    }
    
    func initFirst() {
        viewModel = TaxViewModel()
        if let model = viewModel {
            model.delegate = self
            model.checkTextField()
            
            let language = NSBundle.mainBundle().preferredLocalizations.first! as NSString
            if language != "en" {
                //validate in delegate
                validatePrice = "\\,.{3,}"
            } else {
                //validate in delegate
                validatePrice = "\\..{3,}"
            }
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func onOutsidePressed(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    
    // UITextField Delegates
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.addTarget(self, action: #selector(TaxViewController.textChanged(_:)), forControlEvents: .EditingChanged)
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
        // max 2 fractional digits allowed
        let newText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let regex = try! NSRegularExpression(pattern: validatePrice!, options: [])
        let matches = regex.matchesInString(newText, options:[], range:NSMakeRange(0, newText.characters.count))
        guard matches.count == 0 else { return false }
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            inputPrice(textField, range: range, string: string)
            return Helper.limitCharacter(textField, range: range, string: string, length: 14)
        case ".":
            let array = textField.text?.characters.map { String($0) }
            var decimalCount = 0
            for character in array! {
                if character == "." {
                    decimalCount += 1
                }
            }
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        case ",":
            let array = textField.text?.characters.map { String($0) }
            var decimalCount = 0
            for character in array! {
                if character == "," {
                    decimalCount += 1
                }
            }
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let array = string.characters.map { String($0) }
            if array.count == 0 {
                inputPrice(textField, range: range, string: string)
                return true
            }
            return false
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //        if let model = viewModel {
        //            model.processSubmit()
        //        }
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
        } else {
            if trimmedString.characters.first == "." || trimmedString.characters.first == "," {
                sender.text = ""
            }
        }
        self.actionToEnable?.enabled = (trimmedString != "")
    }
    
    func errorShow(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {
            action in switch action.style {
            case .Default:
                print("default")
                self.clearTextField()
            case .Cancel:
                print("cancel")
            case .Destructive:
                print("destructive")
            }
        }))
    }
    
    @IBAction func onAddPressed(sender: AnyObject) {
        if tf19.text == "" && tf7.text == "" && tf0.text == "" {
            errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Please input price in the field",comment:""))
        } else {
            if let model = viewModel {
                model.updateTaxPrice()
                onBackPressed(self)
            }
        }
    }
    
    func inputPrice(textField: UITextField, range: NSRange, string: String) {
        let userEnteredString = textField.text
        let newString = (userEnteredString! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        let language = NSBundle.mainBundle().preferredLocalizations.first! as NSString
        
        if newString == "" {
            clearTextField()
        } else {
            
            let inputPrice = Double(newString as String)?.roundToPlaces(2)
            
            for (key, value) in priceOptions! {
                if key == 19 && value == false {
                    ///////////////////////
                    if let price = passedReceiptObject?.priceBefore {
                        if textField.tag == 1 {
                            if inputPrice > price {
                                errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Your input price is GREATER than your total price",comment:""))
                            } else {
                                if language != "en" {
                                    if newString.containsString(",") {
                                        let replaceString = (newString as String).replace(",", withString:".")
                                        if let inputPrice = Double(replaceString as String)?.roundToPlaces(2) {
                                            tf0.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    } else {
                                        if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                            tf0.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    }
                                } else {
                                    if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                        tf0.text = String(price - inputPrice)
                                    }
                                }
                            }
                        } else if textField.tag == 2 {
                            if inputPrice > price {
                                errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Your input price is GREATER than your total price",comment:""))
                            } else {
                                if language != "en" {
                                    if newString.containsString(",") {
                                        let replaceString = (newString as String).replace(",", withString:".")
                                        if let inputPrice = Double(replaceString as String)?.roundToPlaces(2) {
                                            tf7.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    } else {
                                        if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                            tf7.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    }
                                } else {
                                    if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                        tf7.text = String(price - inputPrice)
                                    }
                                }
                            }
                        }
                    }
                    ///////////////////////
                } else if key == 7 && value == false {
                    ///////////////////////
                    if let price = passedReceiptObject?.priceBefore {
                        if textField.tag == 0 {
                            if inputPrice > price {
                                errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Your input price is GREATER than your total price",comment:""))
                            } else {
                                if language != "en" {
                                    if newString.containsString(",") {
                                        let replaceString = (newString as String).replace(",", withString:".")
                                        if let inputPrice = Double(replaceString as String)?.roundToPlaces(2) {
                                            tf0.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    } else {
                                        if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                            tf0.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    }
                                } else {
                                    if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                        tf0.text = String(price - inputPrice)
                                    }
                                }
                            }
                        } else if textField.tag == 2 {
                            if inputPrice > price {
                                errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Your input price is GREATER than your total price",comment:""))
                            } else {
                                if language != "en" {
                                    if newString.containsString(",") {
                                        let replaceString = (newString as String).replace(",", withString:".")
                                        if let inputPrice = Double(replaceString as String)?.roundToPlaces(2) {
                                            tf19.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    } else {
                                        if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                            tf19.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    }
                                } else {
                                    if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                        tf19.text = String(price - inputPrice)
                                    }
                                }
                            }
                        }
                    }
                    ///////////////////////
                } else if key == 0 && value == false {
                    ///////////////////////
                    if let price = passedReceiptObject?.priceBefore {
                        if textField.tag == 0 {
                            if inputPrice > price {
                                errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Your input price is GREATER than your total price",comment:""))
                            } else {
                                if language != "en" {
                                    if newString.containsString(",") {
                                        let replaceString = (newString as String).replace(",", withString:".")
                                        if let inputPrice = Double(replaceString as String)?.roundToPlaces(2) {
                                            tf7.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    } else {
                                        if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                            tf7.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    }
                                } else {
                                    if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                        tf7.text = String(price - inputPrice)
                                    }
                                }
                            }
                        } else if textField.tag == 1 {
                            if inputPrice > price {
                                errorShow(NSLocalizedString("Warning",comment:""), message: NSLocalizedString("Your input price is GREATER than your total price",comment:""))
                            } else {
                                if language != "en" {
                                    if newString.containsString(",") {
                                        let replaceString = (newString as String).replace(",", withString:".")
                                        if let inputPrice = Double(replaceString as String)?.roundToPlaces(2) {
                                            tf19.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    } else {
                                        if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                            tf19.text = String(price - inputPrice).replace(".", withString:",")
                                        }
                                    }
                                } else {
                                    if let inputPrice = Double(newString as String)?.roundToPlaces(2) {
                                        tf19.text = String(price - inputPrice)
                                    }
                                }
                            }
                        }
                    }
                    ///////////////////////
                }
                
            }
        }
    }
    
    func calculatePrice() {
        
    }
    
    func clearTextField() {
        tf19.text = ""
        tf7.text = ""
        tf0.text = ""
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
