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
    
    private var buttons = [UIButton]() {
        didSet {
            if buttons.count >= 24 {
                self.DealMoreButton.isHidden = true
            } else {
                self.DealMoreButton.isHidden = false
            }
        }
    }
    
    private var selectedButtons = [UIButton]()
 
    private var CardForButton = [UIButton:SetCard]()
    
    @IBOutlet weak var DealMoreButton: UIButton!
    
    @IBOutlet weak var hintButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start game with 12 cards
        for _ in 1...12 {
            addCard()
        }
        
        // Initially hide hint card
        hintButton.isHidden = true
    }
    
    @IBAction func showHintCard() {
        if let hintCard = game.hintCard() {
            if let hintButton = CardForButton.keys.filter({CardForButton[$0] == hintCard}).first {
                hintButton.layer.borderColor = UIColor.magenta.cgColor
                hintButton.layer.borderWidth = 3.0
            }
        }
    }
    
    @IBAction func dealMoreCards() {
        if !game.isThereAMatch {
            for _ in 0...2 {
                addCard()
            }
            shouldShowHintButton()
        } else {
            replaceOrHideMatchedCards()
            if (game.canStillDrawCards()) {
                for _ in 0...2 {
                    addCard()
                }
            }
        }
    }
    
    
    private func updateUIForMatch(isMatched: Bool) {
        if isMatched {
            for index in 0...selectedButtons.count - 1 {
                selectedButtons[index].layer.borderColor = UIColor.green.cgColor
                selectedButtons[index].layer.borderWidth = 3.0
            }
        } else {
            for index in 0...selectedButtons.count - 1 {
                selectedButtons[index].layer.borderColor = UIColor.red.cgColor
                selectedButtons[index].layer.borderWidth = 3.0
            }
        }
    }
    
    
    @objc private func touchCardButton(button: UIButton) {
        switch selectedButtons.count {
            case 0,1:
                if selectedButtons.contains(button) {
                    deselectButton(cardButton: button)
                    
                } else {
                    selectButton(cardButton: button)
                }
            case 2:
                if selectedButtons.contains(button) {
                    deselectButton(cardButton: button)
                    
                } else {
                    selectButton(cardButton: button)
                    
                    updateUIForMatch(isMatched: game.isThereAMatch)
                }
            case 3:
                // If these cards are not a match
                if !game.isThereAMatch {
                    deselectAll()
                    selectButton(cardButton: button)
                } else {
                    // if a matched set, replace or hide them
                    if !selectedButtons.contains(button) {
                        replaceOrHideMatchedCards()
                        if (game.canStillDrawCards()) { dealMoreCards() }
                        selectButton(cardButton: button)
                    }
                }
            default: break
        }
    }
    
    private func replaceOrHideMatchedCards() {
        if (game.canStillDrawCards()) { //Replace cards
            
            for button in selectedButtons {
                button.removeFromSuperview()
                if let setCard = CardForButton[button] {
                    game.removeCardOnScreen(card: setCard)
                    game.addCardToMatched(card: setCard)
                }
                if let index = buttons.index(of:button) {
                    buttons.remove(at: index)
                }
            }
        } else { // Hide cards
            
            for button in selectedButtons {
                button.isHidden = true
                if let setCard = CardForButton[button] {
                    game.removeCardOnScreen(card: setCard)
                    game.addCardToMatched(card: setCard)
                }
                if let index = buttons.index(of:button) {
                    buttons.remove(at: index)
                }
            }
        }
        deselectAll()
        
        // Update score
        scoreLabel.text = "Score: \(game.score)"
    }
    
    private func selectButton(cardButton: UIButton) {
        cardButton.layer.borderColor = UIColor.blue.cgColor
        cardButton.layer.borderWidth = 3.0
        
        selectedButtons.append(cardButton)
        
        if let card = CardForButton[cardButton] {
            game.selectedCards.append(card)
        }
        shouldShowHintButton()
    }
    
    private func shouldShowHintButton() {
        if let _ = game.hintCard() {
            hintButton.isHidden = false
        } else {
            hintButton.isHidden = true
        }
    }
    
    private func deselectButton(cardButton: UIButton) {
        cardButton.layer.borderWidth = 0.0
        if let index = selectedButtons.index(of: cardButton) {
            selectedButtons.remove(at: index)
        }
        if let card = CardForButton[cardButton], let index = game.selectedCards.index(of:card) {
            game.selectedCards.remove(at: index)
        }
    }
    
    private func deselectAll() {
        for button in buttons {
            button.layer.borderWidth = 0.0
        }
        selectedButtons.removeAll()
        game.selectedCards.removeAll()
    }
    
    
    private func addCard() {
        
        if buttons.count >= 24 {
            print("Table is full of cards, please match some!")
            return
        }
        
        if let setCard = game.draw() {
            
            if game.cards.isEmpty { self.DealMoreButton.isHidden = true }
            
            let button = UIButton(type: .system)
            button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            button.layer.cornerRadius = 8.0
            button.setAttributedTitle(self.makeCardUI(card: setCard), for: UIControl.State.normal)
            button.addTarget(self, action: #selector(self.touchCardButton), for: UIControl.Event.touchUpInside)
            
            var randomButtonrect:CGRect?
            
            repeat {
                randomButtonrect = getRandomRect()
            } while randomButtonrect == nil
            
            if let rect = randomButtonrect {
                button.frame = rect
                
                self.view.addSubview(button)
                
                self.buttons.append(button)
                
                CardForButton.updateValue(setCard, forKey: button)
            }
        }
    }
    
    private func getRandomRect() -> CGRect? {
        let marginRect = CGRect(x: self.view.frame.origin.x + 20.0, y: self.view.frame.origin.y + 40.0, width: self.view.frame.size.width - 35.0, height: self.view.frame.size.height - 70.0)
        
        let randomRect = CGRect(x: CGFloat(Double.random0and1) * marginRect.size.width + 20.0, y: CGFloat(Double.random0and1) * marginRect.size.height + 40.0, width: 50.0, height: 70.0)
        
        if (buttons.filter {$0.frame.intersects(randomRect)}.count > 0) {
            return nil
        }
        if (!marginRect.contains(randomRect)) {
            return nil
        }
        return randomRect
    }
    
    private func makeCardUI(card:SetCard) -> NSAttributedString {
        var attributes = [NSAttributedString.Key:Any]()
        attributes.updateValue(UIFont.systemFont(ofSize: 14.0), forKey: .font)
        
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
                attributes.updateValue(cardColor.withAlphaComponent(0.10), forKey: .foregroundColor)
                attributes.updateValue(-50.0, forKey: .strokeWidth)
            case .filled:
                attributes.updateValue(-50.0, forKey: .strokeWidth)
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


