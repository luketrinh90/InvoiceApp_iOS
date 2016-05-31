//
//  TaxViewModel.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/12/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class TaxViewModel: NSObject {
    
    var delegate: TaxViewController?
    
    // Get the default Realm
    let realm = try! Realm()
    
    ///////////////////////////////////////////////////////////////////////
    
    func checkTextField() {
        if let dele = delegate {
            for (key, value) in dele.priceOptions! {
                if key == 19 && value == false {
                    processAvailableTextField(dele.tf19, enableTf1: dele.tf7, enableTf2: dele.tf0, becomeFr: dele.tf7)
                }
                if key == 7 && value == false {
                    processAvailableTextField(dele.tf7, enableTf1: dele.tf19, enableTf2: dele.tf0, becomeFr: dele.tf19)
                }
                if key == 0 && value == false {
                    processAvailableTextField(dele.tf0, enableTf1: dele.tf19, enableTf2: dele.tf7, becomeFr: dele.tf19)
                }
            }
        }
    }
    
    func processAvailableTextField(disableTf: UITextField, enableTf1: UITextField, enableTf2: UITextField, becomeFr: UITextField) {
        disableTf.backgroundColor = UIColor.lightGrayColor()
        enableTf1.userInteractionEnabled = true
        enableTf2.userInteractionEnabled = true
        becomeFr.becomeFirstResponder()
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    func updateTaxPrice() {
        if let dele = delegate {
            try! realm.write {
                //
                if dele.tf19.text != "" {
                    if dele.tf19.text!.containsString(",") {
                        let replaceString = dele.tf19.text!.replace(",", withString:".")
                        dele.passedTaxPriceObject?.priceTax19 = Double(replaceString)!.roundToPlaces(2)
                    } else {
                        dele.passedTaxPriceObject?.priceTax19 = Double(dele.tf19.text!)!.roundToPlaces(2)
                    }
                } else {
                    dele.passedTaxPriceObject?.priceTax19 = 0.0
                }
                //
                if dele.tf7.text != "" {
                    if dele.tf7.text!.containsString(",") {
                        let replaceString = dele.tf7.text!.replace(",", withString:".")
                        dele.passedTaxPriceObject?.priceTax7 = Double(replaceString)!.roundToPlaces(2)
                    } else {
                        dele.passedTaxPriceObject?.priceTax7 = Double(dele.tf7.text!)!.roundToPlaces(2)
                    }
                } else {
                    dele.passedTaxPriceObject?.priceTax7 = 0.0
                }
                //
                if dele.tf0.text != "" {
                    if dele.tf0.text!.containsString(",") {
                        let replaceString = dele.tf0.text!.replace(",", withString:".")
                        dele.passedTaxPriceObject?.priceTax0 = Double(replaceString)!.roundToPlaces(2)
                    } else {
                        dele.passedTaxPriceObject?.priceTax0 = Double(dele.tf0.text!)!.roundToPlaces(2)
                    }
                } else {
                    dele.passedTaxPriceObject?.priceTax0 = 0.0
                }
            }
        }
    }
    
    func trimString(textField: UITextField) -> String {
        let trimmedString = textField.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        return trimmedString
    }
}
