// I got tired of not having a general image view to image coordinate conversion
// so here's one

import UIKit
import AVFoundation

extension CGRect {
    var center : CGPoint { return CGPoint(x:midX,y:midY) }
    func centeredRect(_ r:CGRect) -> CGRect {
        let r = CGRect(origin:.zero, size:r.size)
        let mycenter = self.center
        let hiscenter = r.center
        let hisOrigin = CGPoint(
            x:mycenter.x-hiscenter.x, y:mycenter.y-hiscenter.y)
        return(CGRect(origin:hisOrigin, size:r.size))
    }
}

extension UIImageView {
    func convertPointToImageCoordinates(_ p:CGPoint) -> CGPoint {
        switch self.contentMode {
        case .scaleAspectFit:
            let r = AVMakeRect(aspectRatio: self.image!.size, insideRect: self.bounds)
            let scale = self.image!.size.width / r.width
            var p2 = CGPoint(x: p.x - r.minX, y: p.y - r.minY)
            p2 = CGPoint(x: p2.x * scale, y: p2.y * scale)
            return p2
        case .scaleAspectFill:
            var scale = self.bounds.height / self.image!.size.height
            if self.image!.size.width * scale < self.bounds.width {
                scale = self.bounds.width / self.image!.size.width
            }
            let scaledImageSize = CGSize(
                width:self.image!.size.width * scale,
                height:self.image!.size.height * scale)
            let scaledImageRect = self.bounds.centeredRect(CGRect(
                origin:.zero, size:scaledImageSize))
            let p2 = CGPoint(
                x: (p.x - scaledImageRect.origin.x) / scale,
                y: (p.y - scaledImageRect.origin.y) / scale)
            return p2
        default:
            fatalError("not written")
        }
    }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

class ViewController: UIViewController {
    @IBAction func tap(_ sender:UITapGestureRecognizer) {
        print("tap")
        let p = sender.location(in: sender.view!)
        let iv = sender.view as! UIImageView
        let p2 = iv.convertPointToImageCoordinates(p)
        // visual confirmation, top left of black rectangle should be at click point
        let im = iv.image!
        let im2 = UIGraphicsImageRenderer(size:im.size).image { _ in
            im.draw(at:.zero)
            UIBezierPath(rect: CGRect(origin:p2, size:im.size)).fill()
        }
        iv.image = im2
        delay(0.05) {
            iv.image = nil
            iv.image = im2
            delay(1) {
                iv.image = im
                delay(0.05) {
                    iv.image = nil
                    iv.image = im
                }
            }
        }
    }
}

