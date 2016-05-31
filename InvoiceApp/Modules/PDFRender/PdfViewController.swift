//
//  PdfViewController.swift
//  InvoiceApp
//
//  Created by Huynnh Tan Si on 5/17/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import PKHUD
import MessageUI

class PDFViewController: UIViewController, UIActionSheetDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate {
    
    var passedInvoiceObject: Invoice?
    
    @IBOutlet weak var reviewPdf: UIWebView!
    
    override func viewDidLoad() {
        print("Invoice id = \(passedInvoiceObject?.id)")
    }
    
    override func viewDidAppear(animated: Bool) {
        let fileName = self.getPDFFileName()
        PDFRenderer.drawPDF(fileName, invoice: passedInvoiceObject!)
        self.showPDFFile(fileName)
    }
    
    func getPDFFileName() -> String {
        let fileName = "Invoice.PDF"
        let arrayPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let path = arrayPaths[0]
        let pdfFileName = (path as NSString).stringByAppendingPathComponent(fileName)
        return pdfFileName
    }
    
    func showPDFFile(fileName:String) -> Void {
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        let url = NSURL.fileURLWithPath(fileName)
        let request = NSURLRequest.init(URL: url)
        
        reviewPdf.scalesPageToFit = true
        reviewPdf.loadRequest(request)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if !webView.loading {
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.show()
            PKHUD.sharedHUD.hide(afterDelay:0.5)
        }
    }
    
    func printPDF() -> Void {
        let url = NSURL.init(fileURLWithPath: getPDFFileName())
        if UIPrintInteractionController.canPrintURL(url) {
            
            let printController = UIPrintInteractionController.sharedPrintController()
            printController.showsNumberOfCopies = false
            printController.printInfo = UIPrintInfo.printInfo()
            printController.printingItem = url
            
            printController.presentAnimated(true, completionHandler: nil)
            return
        }
    }
    
    func sendMail() -> Void {
        if (MFMailComposeViewController.canSendMail()) {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            let data = NSData(contentsOfFile: getPDFFileName())
            composeVC.addAttachmentData(data!, mimeType: "application/pdf", fileName: "Invoice.PDF")
            self.presentViewController(composeVC, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: "No mail service", message: "Please add your mail first", preferredStyle: .ActionSheet)
            alertVC.addAction(UIAlertAction.init(title: "OK", style: .Default, handler: { (action) in
                alertVC.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func exportOptions(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: "Export to: ", message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Printer", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.printPDF()
        })
        let saveAction = UIAlertAction(title: "Mail", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sendMail()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func onBackPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
}