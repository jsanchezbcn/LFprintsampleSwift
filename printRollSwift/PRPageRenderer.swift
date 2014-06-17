//
//  PRPageRenderer.swift
//  printRollSwift
//
//  Created by Jose A Sanchez on 04/06/14.
//  Copyright (c) 2014 Jose A Sanchez. All rights reserved.
//

import Foundation
import UIKit



class PRPageRenderer:UIPrintPageRenderer{
    var scale:CGFloat=1.0
    let kTolerance:CGFloat=0.5*72 //half an inch tolerance to detect if it's needed to rotate or not.

    var pdfURL:NSURL?
    func initWithPDFPath(fileurl:NSURL)->PRPageRenderer {
        pdfURL=fileurl
        return self;
        
    }
    
    override func numberOfPages()->Int{
        return 1;
    }
    
    
     override func drawPageAtIndex(pageIndex: Int, inRect printableRect: CGRect) {
        if (pageIndex == 0) {
            
            self.renderPDFInFrame(printableRect)
            
        }
    }

    func newDocumentWithUrl(url:CFURLRef)->CGPDFDocumentRef{
        var myDocument=CGPDFDocumentCreateWithURL(url)
        
        if (CGPDFDocumentIsEncrypted (myDocument)
            || !CGPDFDocumentIsUnlocked (myDocument)
            || CGPDFDocumentGetNumberOfPages(myDocument) == 0) {
                return myDocument;
        }
        return myDocument;
    
    }
    
    
    func renderPDFInFrame(printableRect:CGRect){
        var context:CGContext = UIGraphicsGetCurrentContext()
        let url=NSBundle.mainBundle().URLForResource("Dsize", withExtension: "pdf")
        var document = self.newDocumentWithUrl(url)
        var docPageRef = CGPDFDocumentGetPage(document, 1)

        var pageRect=CGPDFPageGetBoxRect(docPageRef, kCGPDFMediaBox)
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0)
        CGContextFillRect(context, printableRect)

        CGContextSaveGState(context)
        let imageableAreaSize=printableRect.size
        //check if can be printed at 100% first.
        
        //document is portrait, lets find if it could be fitted in landscape (with some kTolerance)
        if (pageRect.size.height>pageRect.size.width && pageRect.size.height<=(printableRect.size.width + kTolerance)) {
        
            //then rotate 90%
            CGContextTranslateCTM(context, printableRect.origin.x, printableRect.origin.y)
            CGContextScaleCTM(context, 1, -1)
            // Rotate the coordinate system.
            CGContextRotateCTM(context,  CGFloat(-M_PI_2))
            scale=1
            
        }
        else{
            //it fits in portrait, not need to scale.
            if (((pageRect.size.height <= (printableRect.size.height + kTolerance))) && (pageRect.size.width <= (printableRect.size.width + kTolerance))) {
                scale = 1
                CGContextTranslateCTM(context,printableRect.origin.x, imageableAreaSize.height)
                CGContextScaleCTM(context, 1.0, -1.0)
            }
            
            else {
                
                //we need to scale it.
                //we try to fit it in half size first.
                let halfWidth=pageRect.size.width/2.0;
                let halfHeight=pageRect.size.height/2.0;
                if(halfHeight>halfWidth && halfHeight<=(printableRect.size.width + kTolerance)) {
                    //then rotate 90% and print in half size
                    CGContextTranslateCTM(context, printableRect.origin.x, printableRect.origin.y);
                    CGContextScaleCTM(context, 1, -1);
                    // Rotate the coordinate system.
                    CGContextRotateCTM(context, CGFloat(-M_PI_2));
                    scale=0.5;
                }
                else if((printableRect.size.width+kTolerance)>=halfWidth){
                    //print half size, not rotation
                    scale = 0.5;
                    CGContextTranslateCTM(context,printableRect.origin.x, imageableAreaSize.height);
                    CGContextScaleCTM(context, 1.0, -1.0);
                }
                else{
                    //cannot be printed half size so scale to whatever you have loaded on the printer
                    
                    if (pageRect.size.width > pageRect.size.height) {
                        scale = ( printableRect.size.height / pageRect.size.width);
                        //lets rotate 90%
                        // Reverse the Y axis to grow from bottom to top.
                        CGContextTranslateCTM(context, printableRect.origin.x, printableRect.origin.y);
                        CGContextScaleCTM(context, 1, -1);
                        // Rotate the coordinate system.
                        CGContextRotateCTM(context, CGFloat(-M_PI_2));
                    }
                    else {
                        
                        CGContextTranslateCTM(context, 0, printableRect.size.height);
                        CGContextScaleCTM(context, 1, -1);
                        scale = printableRect.size.height/pageRect.size.height;
                    }
                }
            }

            
        }
        
        //scale the context to the right scale.
        CGContextScaleCTM(context, scale, scale);
        
        
        
        CGContextDrawPDFPage(context, docPageRef)
        
        CGContextRestoreGState(context)

    }

}
