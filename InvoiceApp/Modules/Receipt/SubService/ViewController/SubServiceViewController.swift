//
//  SubServiceViewController.swift
//  InvoiceApp
//
//  Created by Luân Trịnh on 5/12/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class SubServiceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array: [String]?
    var passedInvoiceObject: Invoice?
    var passedReceiptObject: Receipt?
    var passedOverStayObject: OverStay?
    var defaultServiceObject: Service?
    var viewModel: SubServiceViewModel?
    @IBOutlet weak var lblSubServiceName: UILabel!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirst()
        readPropertyList()
    }
    
    func initFirst() {
        viewModel = SubServiceViewModel()
        if let model = viewModel {
            model.delegate = self
            lblSubServiceName.text = NSLocalizedString((passedReceiptObject?.type)!,comment:"")
        }
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func readPropertyList(){
        
        var format = NSPropertyListFormat.XMLFormat_v1_0 //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistPath:String? = NSBundle.mainBundle().pathForResource(passedReceiptObject?.category, ofType: "plist")! //the path of the data
        let plistXML = NSFileManager.defaultManager().contentsAtPath(plistPath!)! //the data in XML format
        do { //convert the data to a dictionary and handle errors.
            plistData = try NSPropertyListSerialization.propertyListWithData(plistXML,options: .MutableContainersAndLeaves,format: &format)as! [String:AnyObject]
            
            //assign the values in the dictionary to the properties
            //            isColorInverted = plistData["Inverse Color"] as! Bool
            //
            //            let red = plistData["Red"] as! CGFloat
            //            let green = plistData["Green"] as! CGFloat
            //            let blue = plistData["Blue"] as! CGFloat
            //            color1 = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            
            array = plistData["SubService"] as? [String]
        }
        catch { // error condition
            print("Error reading plist: \(error), format: \(format)")
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cate = array {
            if cate.count > 0 {
                return cate.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("subServiceTableViewCell") as! SubServiceTableViewCell
        
        if let cate = array {
            cell.lblName.text = cate[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let arr = array {
            if let vc = self.storyboard?.instantiateViewControllerWithIdentifier(NotificationConstants.ViewController.SubServiceFormViewController) as? SubServiceFormViewController,
                let nav = navigationController {
                if let model = viewModel {
                    model.processService(NSLocalizedString(arr[indexPath.row],comment:""))
                    vc.passedInvoiceObject = passedInvoiceObject
                    vc.passedReceiptObject = passedReceiptObject
                    vc.passedServiceObject = defaultServiceObject
                    nav.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
