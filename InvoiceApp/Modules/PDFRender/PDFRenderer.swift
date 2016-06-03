//
//  File.swift
//  InvoiceApp
//
//  Created by Huynnh Tan Si on 5/17/16.
//  Copyright © 2016 Luân Trịnh. All rights reserved.
//

import UIKit
import RealmSwift

class PDFRenderer {
    
    static let realm = try! Realm()
    
    static func drawImage(image:UIImage, rect:CGRect) -> Void {
        image.drawInRect(rect)
    }
    
    static func drawLogo() -> Void {
        let objects = NSBundle.mainBundle().loadNibNamed("PdfPage", owner: nil, options: nil)
        
        let mainView = objects[0]
        
        for view in mainView.subviews {
            if view.isKindOfClass(UIImageView) {
                let imageView = view as! UIImageView
                self.drawImage(imageView.image!, rect: view.frame)
            }
        }
    }
    
    static func drawText(textToDraw:String, frameRect:CGRect) -> Void {
        let stringRef = textToDraw as CFString
        
        let currentText = CFAttributedStringCreate(nil, stringRef, nil)
        let frameStter = CTFramesetterCreateWithAttributedString(currentText)
        
        let framePath = CGPathCreateMutable()
        CGPathAddRect(framePath, nil, frameRect)
        
        let currentRange = CFRangeMake(0, 0)
        //print("Current Location = \(currentRange.location)")
        
        let frameRef = CTFramesetterCreateFrame(frameStter, currentRange, framePath, nil)
        
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity)
        
        CGContextTranslateCTM(currentContext, 0, frameRect.origin.y*2)
        CGContextScaleCTM(currentContext, 1.0, -1.0)
        
        CTFrameDraw(frameRef, currentContext!)
        
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        CGContextTranslateCTM(currentContext, 0, -1*frameRect.origin.y*2);
    }
    
    static func drawLabels() -> Void {
        let objects = NSBundle.mainBundle().loadNibNamed("PdfPage", owner: nil, options: nil)
        let mainView = objects[0]
        
        for view in mainView.subviews {
            if view.isKindOfClass(UILabel) {
                let label = view as! UILabel
                self.drawText(label.text!, frameRect: label.frame)
            }
            if view.isKindOfClass(UITextView) {
                let label = view as! UITextView
                self.drawText(label.text!, frameRect: label.frame)
            }
        }
    }
    
    static func drawLineFromPoint(fromPoint:CGPoint, toPoint:CGPoint) -> Void {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1.0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let color = CGColorCreate(colorSpace, [0.2, 0.3, 0.2, 0.3])
        
        CGContextSetStrokeColorWithColor(context, color)
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        CGContextStrokePath(context)
    }
    
    //pass invoice object
    static func drawDataTable(data:Results<Receipt>, nextRow:Int, invoice:Invoice) -> Int {
        
        let language = NSBundle.mainBundle().preferredLocalizations.first! as NSString
        
        let origin = CGPointMake(8, 100)
        let rowCount = data.count
        let rowHeight = 60
        
        let columnCount = 6
        let columnWidth = 132
        var i = 0;
        
        for nextRow in nextRow...rowCount {
            let newOrigin:CGFloat = origin.y + CGFloat(rowHeight*i)
            let from = CGPointMake(origin.x, CGFloat(newOrigin));
            let to = CGPointMake(origin.x + CGFloat(columnCount*columnWidth), newOrigin)
            
            if newOrigin > 500 {
                return nextRow
            }
            
            self.drawLineFromPoint(from, toPoint: to)
            
            if nextRow == rowCount {
                let drawLabelToalFrame = CGRectMake(origin.x + 10, newOrigin + 10 + CGFloat(rowHeight), CGFloat(columnWidth), CGFloat(rowHeight))
                self.drawText(NSLocalizedString("Total",comment:""), frameRect: drawLabelToalFrame)
                
                var total:Double = 0
                for r in 0...rowCount-1 {
                    total += data[r].priceAfter
                }
                let drawTextFrame = CGRectMake(CGFloat(132*5 + 10), newOrigin + 10 + CGFloat(rowHeight), CGFloat(columnWidth), CGFloat(rowHeight))
                if invoice.currencyCode == "EUR" {
                    self.drawText("\(Helper.showCurrencySymbol(invoice.currencyCode))\(String(Double(total).roundToPlaces(2)).replace(".", withString: ","))", frameRect: drawTextFrame)
                } else {
                    self.drawText("\(Helper.showCurrencySymbol(invoice.currencyCode))\(Double(total).roundToPlaces(2))", frameRect: drawTextFrame)
                }
                return 0
            }
            
            for j in 0...columnCount-1 {
                
                let newOriginX = origin.x + CGFloat(j*columnWidth)
                let newOriginY = origin.y + CGFloat((i+1)*rowHeight)
                let drawTextFrame = CGRectMake(newOriginX + 10, newOriginY + 10, CGFloat(columnWidth), CGFloat(rowHeight))
                
                let receipt = data[nextRow]
                let tax = realm.objects(TaxPrice).filter("receiptID = \(receipt.id)")[0]
                
                var drawTextString = ""
                switch j {
                //Date
                case 0:
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd/MMM/yyy"
                    drawTextString = dateFormatter.stringFromDate(receipt.date)
                //Category
                case 1:
                    //drawTextString = NSLocalizedString(receipt.category + "Review",comment:"")
                    
                    if language != "en" {
                        drawTextString = NSLocalizedString(receipt.category + "Review",comment:"")
                    } else {
                        drawTextString = NSLocalizedString(receipt.category,comment:"")
                    }
                //Type
                case 2:
                    //drawTextString = receipt.type
                    
                    if language != "en" {
                        drawTextString = NSLocalizedString(receipt.type + "Review",comment:"")
                    } else {
                        drawTextString = NSLocalizedString(receipt.type,comment:"")
                    }
                //Name
                case 3:
                    drawTextString = receipt.name
                //Tax
                case 4:
                    if tax.priceTax19 > 0 {
                        if invoice.currencyCode == "EUR" {
                            drawTextString = "19%: \(String(tax.priceTax19).replace(".", withString: ","))\n"
                        } else {
                            drawTextString = "19%: \(tax.priceTax19)\n"
                        }
                    }
                    if tax.priceTax7 > 0 {
                        if invoice.currencyCode == "EUR" {
                            drawTextString = drawTextString.stringByAppendingString("7%: \(String(tax.priceTax7).replace(".", withString: ","))\n")
                        } else {
                            drawTextString = drawTextString.stringByAppendingString("7%: \(tax.priceTax7)\n")
                        }
                    }
                    if tax.priceTax0 > 0 {
                        if invoice.currencyCode == "EUR" {
                            drawTextString = drawTextString.stringByAppendingString("0%: \(String(tax.priceTax0).replace(".", withString: ","))")
                        } else {
                            drawTextString = drawTextString.stringByAppendingString("0%: \(tax.priceTax0)")
                        }
                    }
                //Price
                case 5:
                    if invoice.currencyCode == "EUR" {
                        drawTextString = ("\(Helper.showCurrencySymbol(invoice.currencyCode))\(String(Double(receipt.priceAfter).roundToPlaces(2)).replace(".", withString: ","))")
                    } else {
                        drawTextString = ("\(Helper.showCurrencySymbol(invoice.currencyCode))\(Double(receipt.priceAfter).roundToPlaces(2))")
                    }
                default:
                    drawTextString = ""
                }
                self.drawText(drawTextString, frameRect: drawTextFrame)
            }
            i += 1
        }
        
        return 0
    }
    
    static func drawTemplate(pageNum: Int) -> Void {
        self.drawLogo()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE - dd MMM yyy - hh:mm:ss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        // Draw Header Line
        self.drawLineFromPoint(CGPointMake(0, 43), toPoint: CGPointMake(792, 43))
        
        // Draw Footer Line
        self.drawText(NSLocalizedString("Listed on ",comment:"") + dateString,frameRect: CGRectMake(16, 36, 300, 21))
        self.drawLineFromPoint(CGPointMake(0, 560), toPoint: CGPointMake(792, 560))
        
        // Draw number of page
        self.drawText(NSLocalizedString("Page",comment:"") + " \(pageNum)",frameRect: CGRectMake(740, 583, 100, 21))
        self.drawText(NSLocalizedString("Generated by Invoice App from iPhone",comment:""),frameRect: CGRectMake(8, 583, 300, 21))
    }
    
    static func drawPDF(fileName:String, invoice:Invoice) -> Void {
        
        // Begin PDF file
        UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil)
        
        let receipts = realm.objects(Receipt).filter("invoiceID = \(invoice.id)").filter("isCompleted = 1")
        
        var pageNum = 1
        
        var isDrawingTable = true
        var nextRow = 0
        repeat {
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 792, 612), nil)
            
            drawTemplate(pageNum)
            
            // Draw data-rows
            self.drawLabels()
            nextRow = drawDataTable(receipts, nextRow: nextRow, invoice: invoice)
            if nextRow == 0 {
                isDrawingTable = false
            }
            
            pageNum += 1
            
        } while isDrawingTable
        
        
        var images = [String]()
        for i in 0...receipts.count-1 {
            let imagePath = receipts[i].photo
            let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]).URLByAppendingPathComponent("ImagesForInvoiceApp/\(imagePath)")
            
            if !imagePath.isEmpty {
                images.append(documentsPath.path!)
            }
        }
        
        let part = images.count%4 >= 1 ? 1:0
        let numberPageOfImage:Int = part + images.count/4
        
        for i in 0...numberPageOfImage-1 {
            
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 792, 612), nil)
            
            drawTemplate(pageNum)
            
            var imageInPage = 4
            if images.count < 4 {
                imageInPage = images.count
            }
            
            if i > 0 {
                imageInPage = images.count - i*4
            }
            
            for j in 0...imageInPage-1 {
                let pos = j + i*4
                let image = UIImage(contentsOfFile: images[pos])
                drawImage(image!, rect: CGRectMake(8 + CGFloat(j*194), 100, (image?.size.width)!, (image?.size.height)!))
            }
            
            pageNum += 1
        }
        
        UIGraphicsEndPDFContext()
        
    }
}
