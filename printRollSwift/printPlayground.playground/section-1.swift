// Playground - noun: a place where people can play

import UIKit
var str = "Hello, playground1"



//let url = NSBundle.mainBundle().pathForResource("Dsize", ofType: "pdf")
let url="/Users/jsanchez/Documents/swift/Resources/Dsize.pdf"


let pdfURL=NSURL.fileURLWithPath(url)
let document=CGPDFDocumentCreateWithURL(pdfURL)
let docPageRef = CGPDFDocumentGetPage(document, 1);

let documentSize = CGPDFPageGetBoxRect(docPageRef,kCGPDFMediaBox)

let numberOfPages = 1
let width = CGPDFPageGetBoxRect(docPageRef, kCGPDFMediaBox).width
width/72

let height = CGPDFPageGetBoxRect(docPageRef, kCGPDFMediaBox).height
height/72

let kTolerance:CGFloat = 72.0*0.5
func getPaperLenght(paperSize: CGSize, rintableRect printableRect: CGRect) -> CGFloat{
    var scale:CGFloat=1
    NSLog ("Roll of %f inches on the printer.",printableRect.size.width/72)
    let lengthOfMargins = paperSize.height - printableRect.size.height
    document
    
    numberOfPages
    
    let width=paperSize.width + kTolerance
    width
    
    //TBD implement multipage PDFs
    let documentSize = CGPDFPageGetBoxRect(docPageRef,kCGPDFMediaBox)
    if ((documentSize.size.height > documentSize.size.width) && (documentSize.size.height <= width)) {
        //then rotate 90%
        return documentSize.size.width+lengthOfMargins
    }
        //document is landscape or cannot be fitted in landscape
    else{
        //document could be fitted the way it is
        if(width >= documentSize.size.width){
            //just print it with not rotation.
            return documentSize.size.height+lengthOfMargins
        }
        else {
            //we try to rotate first to check if it fits
            if(width >= documentSize.size.height){
                return documentSize.size.width+lengthOfMargins
            }
            else {
                //we need to scale it.
                //we try to fit it in half size first.
                let halfWidth=documentSize.size.width/2.0
                let halfHeight=documentSize.size.height/2.0
                scale=0.5
                //document is portrait, lets find if it could be fitted in landscape (with some kTolerance)
                if (halfHeight>halfWidth && halfHeight <= width) {
                    //then rotate 90% and print in half size
                    return halfWidth+lengthOfMargins
                }
                else if(width >= halfWidth){
                    //print half size, not rotation
                    return halfHeight+lengthOfMargins
                    
                }
                else{
                    //cannot be printed half size so scale to whatever you have loaded on the printer in portrait.
                    documentSize
                    printableRect
                    if(documentSize.height>documentSize.width){
                        scale=printableRect.size.width/documentSize.size.width
                        return documentSize.size.height*scale+lengthOfMargins
                    }
                    else{
                        //we do rotate
                        scale=printableRect.size.height/documentSize.size.width
                        return documentSize.size.width*scale+lengthOfMargins
                    }
                }
            }
        }
        
    }

}


class printView:UIView{

    init(frame: CGRect) {
    
        super.init(frame: frame)
        
    }
    
    override func drawRect(printableRect: CGRect) {
    
        
        printableRect
        var context:CGContext = UIGraphicsGetCurrentContext()
        var scale=1.0
        var rotation=0.0
        
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
            rotation=CGFloat(-M_PI_2)
            
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
                    rotation=CGFloat(-M_PI_2)
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
                        rotation=CGFloat(-M_PI_2)
                    }
                    else {
                        
                        
                        if(documentSize.height>documentSize.width){
                            CGContextTranslateCTM(context, 0, printableRect.size.height);
                            CGContextScaleCTM(context, 1, -1);

                        }
                        else{
                            
                            
                        }
                        scale = printableRect.size.width/pageRect.size.height;

                        
                    }
                }
            }
            
            
        }
        
        //scale the context to the right scale.
        CGContextScaleCTM(context, scale, scale);
        
        
        
        CGContextDrawPDFPage(context, docPageRef)
        
        
        
        
        CGContextRestoreGState(context)
        
        //draw a watermark if needed
        
        if(scale<1){
            var context = UIGraphicsGetCurrentContext()
            //CGContextSaveGState(context)
            
            var message:NSString="";
            if(scale==0.5){
                message="Halfsize"
            }
            else{
                message="\(Int(scale*100))% Scale"
            }
            
            var fontsize=10.0
            var initpoint=CGPoint(x: 0, y: 0)
            if(rotation==0){
                initpoint=CGPointMake(0, printableRect.size.width/2);
                fontsize=printableRect.size.width/6

            }
            else{
                initpoint=CGPointMake(0, printableRect.size.height/2)
                fontsize=printableRect.size.height/6

            }
            
            let font = UIFont(name: "Helvetica", size: fontsize)
            let emptyDictionary = Dictionary<String, Float>()
            
            
            //let attrsDictionary = Dictionary<NSString,AnyObject>()
            let attrsDictionary = [NSFontAttributeName:font,NSBaselineOffsetAttributeName:1.0,NSForegroundColorAttributeName:UIColor(white: 0.8, alpha: 0.3)]
            
            
            /*
            //rotate message 45 degrees
            let transform1 = CGAffineTransformMakeRotation(-45.0 * M_PI/180.0);
            CGContextConcatCTM(context, transform1);
            */
            
            //messagesize=[message sizeWithAttributes:attrsDictionary];
            message.drawAtPoint(initpoint, withAttributes: attrsDictionary)
            
            //CGContextRestoreGState(context);
            
        }

        
    

    
    
    }
    


    
    
}








let rollsize:Array=[14.0,18.0,24.0,36.0,42.0]
var view=printView(frame: CGRectMake(0, 0, 0, 0))
var views:Array=[]
var scale=1.0



for item in rollsize{
    
    var paperSize=CGSizeMake(item*72, 0)
    
    var printableRect=CGRectMake(0,0,(item-0.5)*72, 0)
    
    var lenght=getPaperLenght(paperSize,rintableRect: printableRect)

    (item,lenght/72)
    
    
    view=printView(frame: CGRectMake(0, 0, item*72, lenght))
    
    
    //view.backgroundColor=UIColor(red: 255, green: 0, blue: 0, alpha: 1)
    //renderPDFInFrame(view.frame)
    views.append(view)
    
    

}



views[0]
views[1]
views[2]
views[3]
views[4]
















