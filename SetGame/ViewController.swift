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
    
    @IBOutlet weak var DealMoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start game with 12 cards
        for _ in 1...12 {
            addCard()
        }
    }
    
    @IBAction func dealMoreCards() {
        if !isThereAMatch {
            for _ in 0...2 {
                addCard()
            }
        } else {
            // if a matched set, replace or hide them
            if (game.cards.count > 0) { //Replace cards
                removeItems(of: cardSetToMatch, from: &CardsOnScreen)
                for i in selectedCards.indices { selectedCards[i].removeFromSuperview() }
                removeItems(of: selectedCards, from: &buttons)
                for _ in 0...2 {
                    addCard()
                }
            } else { // Hide cards
                removeItems(of: cardSetToMatch, from: &CardsOnScreen)
                for i in selectedCards.indices { selectedCards[i].isHidden = true }
                removeItems(of: selectedCards, from: &buttons)
            }
            deselectAll()
        }
    }
    
    private var cardSetToMatch = [SetCard]() {
        didSet {
            if cardSetToMatch.count == 3 {
                updateUIForMatch(isMatched:game.matchCards(card1: cardSetToMatch[0], card2: cardSetToMatch[1], card3: cardSetToMatch[2]))
            }
        }
    }
    
    private func updateUIForMatch(isMatched: Bool) {
        if isMatched {
            for index in 0...selectedCards.count - 1 {
                selectedCards[index].layer.borderColor = UIColor.green.cgColor
                selectedCards[index].layer.borderWidth = 3.0
            }
        } else {
            for index in 0...selectedCards.count - 1 {
                selectedCards[index].layer.borderColor = UIColor.red.cgColor
                selectedCards[index].layer.borderWidth = 3.0
            }
        }
    }
    
    private func deselectAll() {
        for button in selectedCards {
            button.layer.borderWidth = 0.0
        }
        selectedCards.removeAll()
        cardSetToMatch.removeAll()
    }
    
    private var selectedCards = [UIButton]()
    
    @objc private func touchCard(button: UIButton) {
        switch selectedCards.count {
            case 0:
                selectCard(card: button)
            case 1,2:
                if selectedCards.contains(button) {
                    deselectCard(card: button)
                } else {
                    selectCard(card: button)
                }
            case 3:
                // If these cards are not a match
                if !game.matchCards(card1: cardSetToMatch[0], card2: cardSetToMatch[1], card3: cardSetToMatch[2]) {
                    deselectAll()
                    selectCard(card: button)
                } else {
                    // if a matched set, replace or hide them
                    if !selectedCards.contains(button) {
                        if (game.cards.count > 0) { //Replace cards
                            
                            removeItems(of: cardSetToMatch, from: &CardsOnScreen)
                            for i in selectedCards.indices { selectedCards[i].removeFromSuperview() }
                            removeItems(of: selectedCards, from: &buttons)
                            dealMoreCards()
                        } else { // Hide cards
                            removeItems(of: cardSetToMatch, from: &CardsOnScreen)
                            for i in selectedCards.indices { selectedCards[i].isHidden = true }
                            removeItems(of: selectedCards, from: &buttons)
                        }
                        deselectAll()
                        selectCard(card: button)
                    }
                }
            default: break
        }
    }
    
    private var isThereAMatch: Bool {
        get {
            if cardSetToMatch.count != 3 {
                return false
            }
            return game.matchCards(card1: cardSetToMatch[0], card2: cardSetToMatch[1], card3: cardSetToMatch[2])
            
        }
    }
    
    private func removeItems<T>(of array1:[T], from array2:inout [T]) where T:Equatable {
        if array1.count <= array2.count {
            for i in 0...array1.count - 1{
                if let index = array2.index(of: array1[i]) {
                    array2.remove(at: index)
                }
            }
        }
    }
    
    private func selectCard(card: UIButton) {
        card.layer.borderColor = UIColor.blue.cgColor
        card.layer.borderWidth = 3.0
        
        selectedCards.append(card)
        if let idIndex = buttons.index(of: card) {
            cardSetToMatch.append(CardsOnScreen[idIndex])
        }
    }
    
    private func deselectCard(card: UIButton) {
        card.layer.borderWidth = 0.0
        if let index = selectedCards.index(of: card) {
            selectedCards.remove(at: index)
            cardSetToMatch.remove(at: index)
        }
    }
    
    private var CardsOnScreen = [SetCard]()
    
    private func addCard() {
        
        if buttons.count >= 24 {
            print("Table is full of cards, please match some!")
            return
        }
        
        let setCard = game.cards.removeFirst()
        
        if game.cards.isEmpty { self.DealMoreButton.isHidden = true }
        
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        button.layer.cornerRadius = 8.0
        button.setAttributedTitle(self.makeCardUI(card: setCard), for: UIControlState.normal)
        button.addTarget(self, action: #selector(self.touchCard), for: UIControlEvents.touchUpInside)
        
        var randomButtonrect:CGRect?
        
        repeat {
            randomButtonrect = getRandomRect()
        } while randomButtonrect == nil
        
        if let rect = randomButtonrect {
            button.frame = rect
            
            self.view.addSubview(button)
            
            self.buttons.append(button)
            
            self.CardsOnScreen.append(setCard)
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
        var attributes = [NSAttributedStringKey:Any]()
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


