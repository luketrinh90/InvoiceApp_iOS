//
//  ReceiptReviewViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/26/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit

class ReceiptReviewViewController: UITableViewController {
    
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedServiceObject: Service?
    var passedOverStayObject: OverStay?
    var passedTaxPriceObject: TaxPrice?
    
    //receipt
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfTaxPrice1: UITextField!
    @IBOutlet weak var tfTaxPrice2: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tfType: UITextField!
    
    //service
    @IBOutlet weak var tfServiceName: UITextField!
    @IBOutlet weak var tfYourName: UITextField!
    @IBOutlet weak var tfOccasion: UITextField!
    @IBOutlet weak var tfEmployees: UITextField!
    
    //overnight stay
    @IBOutlet weak var tfTax: UITextField!
    @IBOutlet weak var tfTimes: UITextField!
    @IBOutlet weak var tfTotal: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    //tax
    @IBOutlet weak var lblFirstTax: UILabel!
    @IBOutlet weak var lblSecondTax: UILabel!
    @IBOutlet weak var tfFirstTax: UITextField!
    @IBOutlet weak var tfSecondTax: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showDetail()
        processShowTax()
        
        print("INVOICE \(passedInvoiceObject)")
        print("RECEIPT \(passedReceiptObject)")
        print("SERVICE \(passedServiceObject)")
        print("OVERSTAY \(passedOverStayObject)")
        print("TAXPRICE \(passedTaxPriceObject)")
    }
    
    func processShowTax() {
        
        if let price = passedTaxPriceObject {
            if price.priceTax19 != 0 {
                if tfFirstTax.text == "" {
                    lblFirstTax.text = "19%"
                    if passedInvoiceObject?.currencyCode == "EUR" {
                        tfFirstTax.text = String(price.priceTax19).replace(".", withString:",")
                    } else {
                        tfFirstTax.text = String(price.priceTax19)
                    }
                }
            }
            if price.priceTax7 != 0 {
                if tfFirstTax.text == "" {
                    lblFirstTax.text = "7%"
                    if passedInvoiceObject?.currencyCode == "EUR" {
                        tfFirstTax.text = String(price.priceTax7).replace(".", withString:",")
                    } else {
                        tfFirstTax.text = String(price.priceTax7)
                    }
                    
                } else if tfSecondTax.text == "" {
                    lblSecondTax.text = "7%"
                    if passedInvoiceObject?.currencyCode == "EUR" {
                        tfSecondTax.text = String(price.priceTax7).replace(".", withString:",")
                    } else {
                        tfSecondTax.text = String(price.priceTax7)
                    }
                }
            }
            if price.priceTax0 != 0 {
                if tfFirstTax.text == "" {
                    lblFirstTax.text = "0%"
                    if passedInvoiceObject?.currencyCode == "EUR" {
                        tfFirstTax.text = String(price.priceTax0).replace(".", withString:",")
                    } else {
                        tfFirstTax.text = String(price.priceTax0)
                    }
                } else if tfSecondTax.text == "" {
                    lblSecondTax.text = "0%"
                    if passedInvoiceObject?.currencyCode == "EUR" {
                        tfSecondTax.text = String(price.priceTax0).replace(".", withString:",")
                    } else {
                        tfSecondTax.text = String(price.priceTax0)
                    }
                }
            }
        }
    }
    
    func showDetail() {
        if let receipt = passedReceiptObject {
            tfName.text = receipt.name
            tfNote.text = receipt.note
            
            let language = NSBundle.mainBundle().preferredLocalizations.first! as NSString
            if language != "en" {
                tfCategory.text = NSLocalizedString(receipt.category + "Review",comment:"")
                tfType.text = NSLocalizedString(receipt.type + "Review",comment:"")
            } else {
                tfCategory.text = NSLocalizedString(receipt.category,comment:"")
                tfType.text = NSLocalizedString(receipt.type,comment:"")
            }
            
            if passedInvoiceObject?.currencyCode == "EUR" {
                tfPrice.text = Helper.showCurrencySymbol(passedInvoiceObject!.currencyCode) + String(receipt.price).replace(".", withString:",")
            } else {
                tfPrice.text = Helper.showCurrencySymbol(passedInvoiceObject!.currencyCode) + String(receipt.price)
            }
        }
        
        if let service = passedServiceObject {
            tfServiceName.text = NSLocalizedString(service.serviceName,comment:"")
            tfYourName.text = service.yourName
            tfOccasion.text = service.occasion
            tfEmployees.text = service.employeesGuest
        }
        
        if let overStay = passedOverStayObject {
            tfTax.text = String(overStay.tax)
            tfTimes.text = String(overStay.numberOfTimes)
            tfTotal.text = String(overStay.totalTax)
        }
        
        loadImageFromPath()
    }
    
    func loadImageFromPath() -> UIImage? {
        if let receipt = passedReceiptObject {
            
            let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
            let imagePath = documentsPath.URLByAppendingPathComponent("ImagesForInvoiceApp/\(receipt.photo)")
            
            let image = UIImage(contentsOfFile: imagePath.path!)
            
            if image == nil {
                print("Missing image at: \(receipt.photo)")
            } else {
                imageView.image = image
            }
            print("Loading image from path: \(imagePath)") // this is just for you to see the path in case you want to go to the directory, using Finder.
            return image
        }
        
        return nil
    }
    
    //ser 242, over 192, photo 250
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 54
        } else if indexPath.row == 1 {
            return 155
        } else if indexPath.row == 2 {
            return 54
        } else if indexPath.row == 3 {
            return 54
        } else if indexPath.row == 4 {
            return 54
        } else if indexPath.row == 5 {
            if passedServiceObject != nil {
                return 271
            }
        } else if indexPath.row == 6 {
            if passedOverStayObject != nil {
                return 217
            }
        } else if indexPath.row == 7 {
            if let photo = passedReceiptObject?.photo {
                if !photo.isEmpty {
                    return 300
                }
            }
        }
        return 0
    }
}
