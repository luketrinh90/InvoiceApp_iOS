//
//  ReceiptCategoryViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/10/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class ReceiptCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var category: [String]?
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readPropertyList()
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func readPropertyList(){
        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistPath:String? = NSBundle.mainBundle().pathForResource("Category", ofType: "plist")! //the path of the data
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
            
            category = plistData["Category"] as? [String]
        }
        catch { // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cate = category {
            if cate.count > 0 {
                return cate.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("receiptCategoryTableViewCell") as! ReceiptCategoryTableViewCell
        
        if let cate = category {
            cell.lblName.text = cate[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cate = category {
            if NSLocalizedString(cate[indexPath.row],comment:"") == "Others" {
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptFormContainerViewController) as? ReceiptFormContainerViewController,
                    let nav = navigationController {
                    try! realm.write {
                        passedReceiptObject?.category = NSLocalizedString(cate[indexPath.row],comment:"")
                        passedReceiptObject?.type = ""
                        vc.passedInvoiceObject = passedInvoiceObject
                        vc.passedReceiptObject = passedReceiptObject
                        nav.pushViewController(vc, animated: true)
                    }
                }
            } else {
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.ReceiptSubCategoryViewController) as? ReceiptSubCategoryViewController,
                    let nav = navigationController {
                    try! realm.write {
                        passedReceiptObject?.category = NSLocalizedString(cate[indexPath.row],comment:"")
                        vc.passedInvoiceObject = passedInvoiceObject
                        vc.passedReceiptObject = passedReceiptObject
                        nav.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}
