//
//  Concentration.swift
//  Concentration
//
//  Created by Thai Nguyen on 8/20/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import Foundation

struct Concentration
{
    private(set) var cards = [Card]()
    
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    var score = 0
    
    private(set) var flipsCount = 0
    
    private var startTime = Date()
    
    private var numberOfMatchedCards = 0
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index is not in the cards")
        if !cards[index].isMatched {
            flipsCount += 1
            
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // Check if cards match
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    
                    score += 2
                    
                    numberOfMatchedCards += 2
                    
                } else {
                    if cards[index].wasPreviouslySeen {
                        score -= 1
                    } else {
                        cards[index].wasPreviouslySeen = true
                    }
                    
                    if cards[matchIndex].wasPreviouslySeen {
                        score -= 1
                    } else {
                        cards[matchIndex].wasPreviouslySeen = true
                    }
                }
                
                cards[index].isFaceUp = true
                
                // check if game ends when number of matched cards equals total no of cards
                if numberOfMatchedCards == cards.count {
                    let endTime = Date()
                    let playTime = Int(endTime.timeIntervalSince(startTime))
                    
                    // deduct 1 point for every 10 seconds played
                    score -= (playTime / 10)
                }
                
            } else {
                // either no cards or 2 cards are face up
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    init(numberOfPairOfCards: Int) {
        assert(numberOfPairOfCards > 0, "Concentration.init(\(numberOfPairOfCards)): you must have at least one pair of cards")
        for _ in 1...numberOfPairOfCards {
            let card = Card()
            cards += [card,card]
        }
        
        // TODO: Shuffle the cards
        var shuffledCards = [Card]()

        for _ in 0..<cards.count {
            if cards.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(cards.count)))
                shuffledCards.append(cards[randomIndex])
                cards.remove(at: randomIndex)
            }
        }

        cards = shuffledCards
        
        // record start time of the game
        startTime = Date()
    }
    
    mutating func resetGame() {
        for index in cards.indices {
            cards[index].isFaceUp = false
            cards[index].isMatched = false
            cards[index].wasPreviouslySeen = false
        }
        
        score = 0
        
        flipsCount = 0
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
    
}
