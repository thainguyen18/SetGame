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
        // Shuffe cards
        var shuffledCards = [SetCard]()
        
        for _ in 0..<cards.count {
            if cards.count > 0 {
                let randomIndex = cards.count.arc4random
                shuffledCards.append(cards[randomIndex])
                cards.remove(at: randomIndex)
            }
        }
        
        cards = shuffledCards
    }
    
    func matchCards(card1: SetCard, card2: SetCard,card3: SetCard) -> Bool {
//        if !satisfySetRules(a: card1.number, b: card2.number, c: card3.number) { return false }
//        if !satisfySetRules(a: card1.color, b: card2.color, c: card3.color) { return false }
//        if !satisfySetRules(a: card1.shading, b: card2.shading, c: card3.shading) { return false }
//        if !satisfySetRules(a: card1.symbol, b: card2.symbol, c: card3.symbol) { return false }
        return true
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
