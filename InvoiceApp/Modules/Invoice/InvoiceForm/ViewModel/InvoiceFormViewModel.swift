//
//  InvoiceFormViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/10/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import UITextField_Shake
import RealmSwift

class InvoiceFormViewModel: NSObject {
    var isName: Bool?
    var isDate: Bool?
    var isCurrency: Bool?
    
    var delegate: InvoiceFormViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    func initPicker() {
        if let dele = delegate {
            //pickerView
            let pickerView = UIPickerView()
            pickerView.delegate = dele
            dele.tfCurrency.inputView = pickerView
            
            //datePicker
            let datePickerView  : UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.Date
            
            dele.tfDate.inputView = datePickerView
            
            setDefaultDate()
            
            datePickerView.addTarget(self, action: #selector(InvoiceFormViewModel.handleDatePicker(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    func setDefaultDate() {
        if let dele = delegate {
            dele.tfDate.text = dateToString(NSDate())
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        if let dele = delegate {
            dele.tfDate.text = dateToString(sender.date)
        }
    }
    
    func dateToString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        return formatter.stringFromDate(date)
    }
    
    func processSubmit() {
        if let dele = delegate {
            isName = checkTextField(dele.tfInvoiceName)
            isDate = checkTextField(dele.tfDate)
            isCurrency = checkTextField(dele.tfCurrency)
            
            if isName! && isDate! && isCurrency! {
                addInvoice()
            } else {
                print("SUBMIT PROBLEM")
            }
        }
    }
    
    func checkTextField(textField: UITextField) -> Bool {
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 0
        
        if let tf = textField.text {
            if tf.isEmpty {
                textField.layer.borderColor = UIColor.redColor().CGColor
                textField.shake(10, withDelta: 1.0, speed: 0.05)
                return false
            }
        }
        
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.grayColor().CGColor
        return true
    }
    
    func addInvoice() {
        if let dele = delegate {
            let invoice = Invoice()
            invoice.id = invoice.incrementID()
            invoice.name = trimString(dele.tfInvoiceName)
            invoice.note = trimString(dele.tfNote)
            invoice.date = stringToDate(dele.tfDate.text!)
            invoice.currencyCode = trimString(dele.tfCurrency)
            try! realm.write {
                realm.add(invoice)
                pushFromCreateInvoiceToReceipt(invoice.id)
            }
        }
    }
    
    func pushFromCreateInvoiceToReceipt(id: Int) {
        if let vc = delegate!.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptViewController) as? ReceiptViewController,
            let nav = delegate!.navigationController {
            vc.passedInvoiceObject = realm.objects(Invoice).sorted("id", ascending: false).filter("id = \(id)").last
            if let navController = delegate!.navigationController {
                navController.popViewControllerAnimated(false)
                nav.pushViewController(vc, animated: true)
            }
        }
    }
    
    func trimString(textField: UITextField) -> String {
        let trimmedString = textField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return trimmedString
    }
    
    func stringToDate(dateString: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        return dateFormatter.dateFromString(dateString)!
    }
    
    func readPropertyList() {
        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistPath:String? = NSBundle.mainBundle().pathForResource("Currency", ofType: "plist")! //the path of the data
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)! //the data in XML format
        do { //convert the data to a dictionary and handle errors.
            plistData = try NSPropertyListSerialization.propertyListWithData(plistXML,options: .MutableContainersAndLeaves,format: &format) as! [String:AnyObject]
            
            //assign the values in the dictionary to the properties
            //            isColorInverted = plistData["Inverse Color"] as! Bool
            //
            //            let red = plistData["Red"] as! CGFloat
            //            let green = plistData["Green"] as! CGFloat
            //            let blue = plistData["Blue"] as! CGFloat
            //            color1 = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            if let dele = delegate {
                dele.pickerData = plistData["Currency"] as? [String]
                if dele.tfCurrency.text == "" {
                    dele.tfCurrency.text = dele.pickerData![0]
                }
            }
        }
        catch { // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
}
