//
//  SetCard.swift
//  SetGame
//
//  Created by Thai Nguyen on 9/6/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import Foundation

struct SetCard: Equatable {
    
    let number: Number
    let symbol: Symbol
    let shading: Shading
    let color: CardColor
    
    init(number: Number, symbol:Symbol, shading:Shading, color:CardColor) {
        self.number = number
        self.symbol = symbol
        self.shading = shading
        self.color = color
    }
    
    init() { // Default
        self.number = .one
        self.symbol = .circle
        self.shading = .open
        self.color = .black
    }
    
    enum Number: Int {
        case one = 1
        case two = 2
        case three = 3
        
        static var all = [Number.one, .two, .three]
    }
    
    enum Symbol: String {
        case triangle
        case circle
        case square
        
        static let all = [Symbol.triangle, .circle, .square]
    }
    
    enum Shading {
        case open
        case striped
        case filled
        
        static let all = [Shading.open, .striped, .filled]
    }
    
    enum CardColor {
        case black
        case orange
        case blue
        
        static let all = [CardColor.black, .orange, .blue]
    }
}
