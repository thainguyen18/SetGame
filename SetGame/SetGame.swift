//
//  SetGame.swift
//  SetGame
//
//  Created by Thai Nguyen on 9/6/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import Foundation

struct SetGame {
    
    private(set) var cards = [SetCard]()
    
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
