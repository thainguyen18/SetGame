//
//  SetGame.swift
//  SetGame
//
//  Created by Thai Nguyen on 9/6/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import Foundation

struct SetGame {
    
    var cards = [SetCard]()
    var cardsOnScreen = [SetCard]()
    var matchedCards = [SetCard]()
    var selectedCards = [SetCard]()
    
    var isThereAMatch: Bool {
        return matchCards(cards:selectedCards)
    }
    
    var score: Int {
        return matchedCards.count / 3
    }
    
    init() {
        for number in SetCard.Number.all {
            for symbol in SetCard.Symbol.all {
                for shading in SetCard.Shading.all {
                    for color in SetCard.CardColor.all {
                        cards.append(SetCard(number: number, symbol: symbol, shading: shading, color: color))
                    }
                }
            }
        }
    }
    
    // Draw random card
    mutating func draw() -> SetCard? {
        
        if cards.count > 0 {
            
            let randomIndex = cards.count.arc4random
            let card = cards.remove(at: randomIndex)
            cardsOnScreen.append(card)
            return card
            
        } else { return nil }
    }
    
    
    func canStillDrawCards() -> Bool {
        return cards.count > 0
    }
    
    mutating func removeCardOnScreen(card: SetCard) {
        if let index = cardsOnScreen.index(of: card) {
            cardsOnScreen.remove(at: index)
        }
    }
    
    mutating func addCardToMatched(card: SetCard) {
        matchedCards.append(card)
    }
    
    func matchCards(cards: [SetCard]) -> Bool {
        if cards.count == 3 {
            if !satisfySetRules(a: cards[0].number, b: cards[1].number, c: cards[2].number) {return false}
            if !satisfySetRules(a: cards[0].color, b: cards[1].color, c: cards[2].color) {return false}
            if !satisfySetRules(a: cards[0].shading, b: cards[1].shading, c: cards[2].shading) {return false}
            if !satisfySetRules(a: cards[0].symbol, b: cards[1].symbol, c: cards[2].symbol) {return false}
            return true
        } else {
            return false
        }
    }
    
    func hintCard() -> SetCard? {
        var hintCard: SetCard?
        if selectedCards.count == 2 {
            for card in cardsOnScreen {
                if matchCards(cards: [selectedCards[0],selectedCards[1], card]) {
                    hintCard = card
                }
            }
        }
        return hintCard
    }
    
    private func satisfySetRules<T>(a:T, b:T, c:T) -> Bool where T:Equatable {
        if a == b && b == c {
            return true
        } else if a != b && b != c && c != a {
            return true
        } else { return false }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}
