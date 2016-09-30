//
//  ViewController.swift
//  printRollSwift
//
//  Created by Jose A Sanchez on 04/06/14.
//  Copyright (c) 2014 Jose A Sanchez. All rights reserved.
//

import UIKit


class ViewController: UIViewController,UIPrintInteractionControllerDelegate {
    let kTolerance:CGFloat = 72*0.5

    var pdfURL:NSURL?

    var document:CGPDFDocumentRef?
    var docPageRef:CGPDFPageRef?
    var width:NSNumber?
    var height:NSNumber?
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        let pdfStringURL=NSBundle.mainBundle().pathForResource("Dsize", ofType: "pdf")
        let pdfURL=NSURL.fileURLWithPath(pdfStringURL!)
        document=CGPDFDocumentCreateWithURL(pdfURL)
        
        docPageRef = CGPDFDocumentGetPage(document!, 1);
        
        width = CGPDFPageGetBoxRect(docPageRef!, CGPDFBox.MediaBox).width
        height = CGPDFPageGetBoxRect(docPageRef!, CGPDFBox.MediaBox).height
        let theWebView:UIWebView=UIWebView(frame: CGRect(x: 0,y: 40,width: self.view.frame.width,height: self.view.frame.height-300))
        theWebView.scalesPageToFit=true
        theWebView.loadRequest(NSURLRequest(URL: pdfURL))
        self.view.addSubview(theWebView)
        
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func print(sender : AnyObject) {
        
   
        let myData:NSData=NSData.dataWithContentsOfMappedFile(NSBundle.mainBundle().pathForResource("Dsize", ofType: "pdf")!) as! NSData
        let pic = UIPrintInteractionController.sharedPrintController()
        
        if UIPrintInteractionController.canPrintData(myData) {
            pic.delegate = self
            pic.showsPageRange = false;
            pic.printingItem = myData;
            pic.presentAnimated(true, completionHandler: nil)
        }
        
    }
    
    
    @IBAction func instantprint(sender : AnyObject) {
        
        let myData:NSData=NSData.dataWithContentsOfMappedFile(NSBundle.mainBundle().pathForResource("Dsize", ofType: "pdf")!) as! NSData
        let pic = UIPrintInteractionController.sharedPrintController()
        
        if UIPrintInteractionController.canPrintData(myData) {
            pic.delegate = self
            let pageRenderer=PRPageRenderer()
            pageRenderer.pdfURL=pdfURL
            pic.printPageRenderer = pageRenderer
            pic.presentAnimated(true, completionHandler: nil)
            
        }

        
    }
    
    func printInteractionController(printInteractionController: UIPrintInteractionController, cutLengthForPaper paper: UIPrintPaper) -> CGFloat{
        NSLog ("Roll of %f inches on the printer.",paper.printableRect.size.width/72) ;
        let lengthOfMargins = paper.paperSize.height - paper.printableRect.size.height;
        let numberOfPages = CGPDFDocumentGetNumberOfPages(document!);
        if (numberOfPages>0) {
            //TODO implement multipage PDFs
            let documentSize = CGPDFPageGetBoxRect(docPageRef!,CGPDFBox.MediaBox);
        
            if (documentSize.size.height > documentSize.size.width && documentSize.size.height<=(paper.paperSize.width + CGFloat(kTolerance))) {
                //then rotate 90%
                return documentSize.size.width+lengthOfMargins;
            }
                //document is landscape or cannot be fitted in landscape
            else{
                //document could be fitted the way it is
                if((paper.paperSize.width+kTolerance)>=documentSize.size.width){
                    //just print it with not rotation.
                    return documentSize.size.height+lengthOfMargins;
                }
                else {
                    //we try to rotate first to check if it fits
                    if((paper.paperSize.width+kTolerance)>=documentSize.size.height){
                        return documentSize.size.width+lengthOfMargins;
                    }
                    else {
                        //we need to scale it.
                        //we try to fit it in half size first.
                        let halfWidth=documentSize.size.width/2.0;
                        let halfHeight=documentSize.size.height/2.0;
                        //document is portrait, lets find if it could be fitted in landscape (with some kTolerance)
                        if (halfHeight>halfWidth && halfHeight<=(paper.paperSize.width + kTolerance)) {
                            //then rotate 90% and print in half size
                            return halfWidth+lengthOfMargins;
                        }
                        else if((paper.paperSize.width+kTolerance)>=halfWidth){
                            //print half size, not rotation
                            return halfHeight+lengthOfMargins;
                            
                        }
                        else{
                            //cannot be printed half size so scale to whatever you have loaded on the printer
                            
                            let scale=paper.printableRect.size.width/documentSize.size.height;
                            return documentSize.size.width*scale+lengthOfMargins;
                        }
                    }
                }
                
            }

            
        }
        return 0;
    }
    
    
}

