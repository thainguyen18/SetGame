//
//  ViewController.swift
//  SetGame
//
//  Created by Thai Nguyen on 9/6/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var game = SetGame()
    
    private var buttons = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addCard(to: buttons)
        addCard(to: buttons)
        addCard(to: buttons)
    }
    
    @objc private func touchCard(button: UIButton) {
        print("Touch a card with title: \(button.currentTitle ?? "No Title")")
    }
    
    private func addCard(to group:[UIButton]) {
        let marginRect = CGRect(x: self.view.frame.origin.x + 20.0, y: self.view.frame.origin.y + 40.0, width: self.view.frame.size.width - 35.0, height: self.view.frame.size.height - 70.0)
        
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.setTitle("Card 1", for: UIControlState.normal)
        button.addTarget(self, action: #selector(self.touchCard), for: UIControlEvents.touchUpInside)
        
        var randomButtonrect = CGRect()
        
        repeat {
            randomButtonrect = CGRect(x: CGFloat(Double.random0and1) * marginRect.size.width + 20.0, y: CGFloat(Double.random0and1) * marginRect.size.height + 40.0, width: 60.0, height: 80.0)
        } while (group.filter {$0.frame.intersects(randomButtonrect)}.count > 0) && (marginRect.contains(button.frame))
        
        button.frame = randomButtonrect
        
        self.view.addSubview(button)
        
        self.buttons.append(button)
    }
    
    private func makeCardUI(card:SetCard) -> NSAttributedString {
        var attributes = [NSAttributedStringKey:Any]()
        attributes.updateValue(UIFont.systemFont(ofSize: 20.0), forKey: .font)
        
        var cardColor:UIColor
        
        var atrString:NSAttributedString
        
        switch card.color {
            case .black:
                attributes.updateValue(UIColor.black, forKey: .strokeColor)
                cardColor = UIColor.black
            case .orange:
                attributes.updateValue(UIColor.orange, forKey: .strokeColor)
                cardColor = UIColor.orange
            case .blue:
                attributes.updateValue(UIColor.blue, forKey: .strokeColor)
                cardColor = UIColor.blue
        }
        
        switch card.shading {
            case .striped:
                attributes.updateValue(cardColor.withAlphaComponent(0.15), forKey: .foregroundColor)
                attributes.updateValue(-5.0, forKey: .strokeWidth)
            case .filled:
                attributes.updateValue(cardColor.withAlphaComponent(1.0), forKey: .foregroundColor)
                attributes.updateValue(-5.0, forKey: .strokeWidth)
            case .open: attributes.updateValue(5.0, forKey: .strokeWidth)
        }
        
        var text = ""
        
        switch card.symbol {
            case .triangle:
                for _ in 1...card.number.rawValue {
                    text.append("△")
                }
                atrString = NSAttributedString(string: text, attributes: attributes)
            case .circle:
                for _ in 1...card.number.rawValue {
                    text.append("◯")
                }
                atrString = NSAttributedString(string: text, attributes: attributes)
            case .square:
                for _ in 1...card.number.rawValue {
                    text.append("▢")
                }
                atrString = NSAttributedString(string: text, attributes: attributes)
        }
    
        return atrString
    }
}


extension Double {
    public static var random0and1:Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
}


