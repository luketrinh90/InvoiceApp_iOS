//
//  Helper.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/10/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class Helper {
    static func limitCharacter(textField: UITextField, range: NSRange, string: String, length:Int) -> Bool {
        if (range.length + range.location > textField.text!.characters.count ) {
            return false
        }
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= length
    }
    
    static func showDialog(delegate: UIViewController, title:String, message:String, btnTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: btnTitle, style: UIAlertActionStyle.Default, handler: nil))
        delegate.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func showCurrencySymbol(currencyCode: String) -> String {
        let localeComponents = [NSLocaleCurrencyCode: currencyCode]
        let localeIdentifier = NSLocale.localeIdentifierFromComponents(localeComponents)
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        let currencySymbol = locale.objectForKey(NSLocaleCurrencySymbol) as! String
        
        return currencySymbol + " "
    }
}


