//
//  FaceView.swift
//  Happiness
//
//  Created by Murty Gudipati on 2/28/15.
//  Copyright (c) 2015 Murty Gudipati. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView
{
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    
    var faceRect: CGRect {
        var faceWidth = min(bounds.size.width, bounds.size.height) * scale
        var faceCenter = convertPoint(center, fromView: superview)
        var faceRect = CGRectMake(faceCenter.x, faceCenter.y, faceWidth, faceWidth)
        return CGRectOffset(faceRect, -faceWidth/2, -faceWidth/2)
    }
    
    weak var dataSource: FaceViewDataSource?
    
    private struct Scaling {
        static let FaceWidthToEyeWidthRatio: CGFloat = 6
        static let FaceWidthToEyeOffsetRatio: CGFloat = 3
        static let FaceWidthToEyeSeparationRatio: CGFloat = 3
        static let FaceWidthToMouthWidthRatio: CGFloat = 2
        static let FaceWidthToMouthHeightRatio: CGFloat = 5
        static let FaceWidthToMouthOffsetRatio: CGFloat = 1.5
    }

    private enum Eye { case Left, Right }
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
        let eyeWidth = faceRect.width / Scaling.FaceWidthToEyeWidthRatio
        let eyeVerticalOffset = faceRect.width / Scaling.FaceWidthToEyeOffsetRatio
        let eyeSeparation = faceRect.width / Scaling.FaceWidthToEyeSeparationRatio
        
        var eyeCenter = faceRect.origin
        eyeCenter.y += eyeVerticalOffset
        switch whichEye {
        case .Left: eyeCenter.x += (faceRect.width - eyeSeparation) / 2
        case .Right: eyeCenter.x += (faceRect.width + eyeSeparation) / 2
        }
        
        var eyeRect = CGRectMake(eyeCenter.x, eyeCenter.y, eyeWidth, eyeWidth)
        let path = UIBezierPath(ovalInRect: CGRectOffset(eyeRect, -eyeWidth/2, -eyeWidth/2))
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath {
        let mouthWidth = faceRect.width / Scaling.FaceWidthToMouthWidthRatio
        let mouthHeight = faceRect.width / Scaling.FaceWidthToMouthHeightRatio
        let mouthVerticalOffset = faceRect.width / Scaling.FaceWidthToMouthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight

        var mouthCenter = faceRect.origin
        let start = CGPoint(x: faceRect.origin.x + (faceRect.width - mouthWidth) / 2,
            y: faceRect.origin.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    override func drawRect(rect: CGRect) {
        let facePath = UIBezierPath(ovalInRect: faceRect)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        bezierPathForSmile(dataSource?.smilinessForFaceView(self) ?? 0.0).stroke()
    }
}
