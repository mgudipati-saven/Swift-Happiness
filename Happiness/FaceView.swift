//
//  FaceView.swift
//  Happiness
//
//  Created by Murty Gudipati on 2/28/15.
//  Copyright (c) 2015 Murty Gudipati. All rights reserved.
//

import UIKit

class FaceView: UIView
{
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    var scale: CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    
    var faceRect: CGRect {
        var faceWidth = min(bounds.size.width, bounds.size.height) * scale
        var faceCenter = convertPoint(center, fromView: superview)
        var faceRect = CGRectMake(faceCenter.x, faceCenter.y, faceWidth, faceWidth)
        return CGRectOffset(faceRect, -faceWidth/2, -faceWidth/2)
    }
    
    private struct Scaling {
        static let FaceWidthToEyeWidthRatio: CGFloat = 5
        static let FaceWidthToEyeOffsetRatio: CGFloat = 4
        static let FaceWidthToEyeSeparationRatio: CGFloat = 5
        static let FaceWidthToMouthWidthRatio: CGFloat = 2
        static let FaceWidthToMouthHeightRatio: CGFloat = 5
        static let FaceWidthToMouthOffsetRatio: CGFloat = 5
    }

    private enum Eye { case Left, Right }
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
        let eyeWidth = faceRect.width / Scaling.FaceWidthToEyeWidthRatio
        let eyeVerticalOffset = faceRect.width / Scaling.FaceWidthToEyeOffsetRatio
        let eyeSeparation = faceRect.width / Scaling.FaceWidthToEyeSeparationRatio
        
        var eyeCenter = convertPoint(center, fromView: superview)
        eyeCenter.y -= eyeVerticalOffset
        switch whichEye {
        case .Left: eyeCenter.x -= eyeSeparation
        case .Right: eyeCenter.x += eyeSeparation
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

        var mouthCenter = convertPoint(center, fromView: superview)
        let start = CGPoint(x: mouthCenter.x - mouthWidth / 2, y: mouthCenter.y + mouthVerticalOffset)
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
        bezierPathForSmile(-0.5).stroke()
    }
}
