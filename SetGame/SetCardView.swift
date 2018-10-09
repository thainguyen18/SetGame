//
//  SetCardView.swift
//  SetGame
//
//  Created by Thai Nguyen on 10/8/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    
    var setCard = SetCard() { didSet{ setNeedsDisplay() } }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let path = drawCard()
        path.stroke()
    }
    
    private func drawCard() -> UIBezierPath {
        var path = UIBezierPath()
        path.lineWidth = 5.0
        
        switch setCard.color {
        case .black:
            #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).setStroke()
        case .blue:
            #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).setStroke()
        case .orange:
            #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).setStroke()
        }
        
        switch setCard.number {
        case .one:
            path = drawSymbol(at: self.centerPoint)
        case .two:
            path = drawSymbol(at: self.verticalTwoPointsUpper)
            path.append(drawSymbol(at: self.verticalTwoPointsLower))
        case .three:
            path = drawSymbol(at: self.verticalThreePointsUpper)
            path.append(drawSymbol(at: self.centerPoint))
            path.append(drawSymbol(at: self.verticalThreePointsLower))
        }
        
        switch setCard.shading {
        case .filled:
            self.mainColor.setFill()
            path.fill()
        case .striped:
            let stripes = self.makeStripes()
            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState() // Save current context
                path.addClip()
                
                self.mainColor.setStroke()
                stripes.stroke()
                
                context.restoreGState() // Restore graphic state
            }
            
        default:
            break
        }
        
        return path
    }
    
    private func drawSymbol(at point: CGPoint) -> UIBezierPath {
        switch setCard.symbol {
        case .circle:
            return drawCircle(center: point, radius: self.circleRadius)
        case .square:
            return drawSquare(center: point, side: squareSide)
        case .triangle:
            return drawTriangle(center: point, side: squareSide)
        }
    }
    
    private func drawSquare(center: CGPoint, side: CGFloat) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        let startX = center.x - side / 2
        let startY = center.y - side / 2
        
        path.move(to: CGPoint(x: startX, y: startY))
        
        path.addLine(to: path.currentPoint)
        path.addLine(to: CGPoint(x: startX + side, y: startY))
        path.addLine(to: path.currentPoint)
        path.addLine(to: CGPoint(x: startX + side, y: startY + side))
        path.addLine(to: path.currentPoint)
        path.addLine(to: CGPoint(x: startX, y: startY + side))
        path.addLine(to: path.currentPoint)
        path.close()
        
        return path
    }
    
    private func drawTriangle(center: CGPoint, side: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let startX = center.x - side / 2
        let startY = center.y + side / 2
        
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: center.x, y: center.y - side / 2))
        path.addLine(to: CGPoint(x: center.x + side / 2, y: center.y + side / 2))
        path.close()
        
        return path
    }
    
    
    private func drawCircle(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2, clockwise: true)
    }
    
    private func makeStripes() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 3.0
        let gap:CGFloat = 5.0
        path.move(to: bounds.origin)
        var startingY = bounds.origin.y
        
        while startingY < bounds.size.height {
            path.addLine(to: CGPoint(x: bounds.size.width, y: startingY))
            startingY += gap
            
            path.move(to: CGPoint(x: bounds.origin.x, y: startingY))
        }
        return path
    }

}

extension SetCardView {
    
    struct aspectRatio {
        static let itemToBoundsRatio: CGFloat = 0.15
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    }
    
    private var mainColor: UIColor {
        switch setCard.color {
        case .black:
            return UIColor.black
        case .blue:
            return UIColor.blue
        case .orange:
            return UIColor.orange
        }
    }
    
    private var circleRadius: CGFloat {
        return bounds.size.height * aspectRatio.itemToBoundsRatio / 2.0
    }
    
    private var squareSide: CGFloat {
        return bounds.size.height * aspectRatio.itemToBoundsRatio
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * aspectRatio.cornerRadiusToBoundsHeight
    }
    
    private var centerPoint: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var verticalTwoPointsUpper: CGPoint {
        return CGPoint(x: centerPoint.x, y: centerPoint.y - bounds.size.height * aspectRatio.itemToBoundsRatio)
    }
    
    private var verticalTwoPointsLower: CGPoint {
        return CGPoint(x: centerPoint.x, y: centerPoint.y + bounds.size.height * aspectRatio.itemToBoundsRatio)
    }
    
    private var verticalThreePointsUpper: CGPoint {
        return CGPoint(x: centerPoint.x, y: centerPoint.y - bounds.size.height * aspectRatio.itemToBoundsRatio * 2)
    }
    
    private var verticalThreePointsLower: CGPoint {
        return CGPoint(x: centerPoint.x, y: centerPoint.y + bounds.size.height * aspectRatio.itemToBoundsRatio * 2)
    }
}
