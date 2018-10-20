//
//  ViewController.swift
//  Concentration
//
//  Created by Thai Nguyen on 8/20/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ConcentrationViewController: UIViewController
{
    private lazy var game = Concentration(numberOfPairOfCards: numberOfPairOfCards)
    
    var numberOfPairOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    
    @IBOutlet private weak var flipCountLabel: UILabel!
    
    @IBAction private func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            
        }
    }
    
    
    private func updateViewFromModel() {
        guard cardButtons != nil else { return }
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : chosenCardColor
            }
        }
        
        let attributes: [NSAttributedString.Key:Any] = [
            .strokeWidth : 5.0,
            .strokeColor : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        ]
        
        let attributedString = NSAttributedString(string: "Flips: " + String(game.flipsCount), attributes: attributes)
        
        scoreLabel.text = "Score: \(game.score)"
        
        flipCountLabel.attributedText = attributedString
    }
    
    @IBOutlet private var cardButtons: [UIButton]!
    
//    private let themes = ["animals":"🐶🐱🐰🦊🦁🐵🦆🕷🦂🐟🐍🐿",
//                  "sports":"⚽️🏀🏈🎱🏓🏹⛸⛷🎣🥊🎾🏐",
//                  "faces":"😄☺️😍😂😡😈😱😤😐😵😇😎",
//                    "fruits":"🍎🍊🍋🍌🍉🍓🥑🌽🍅🍍🥦🥒",
//                    "objects":"⌚️📱💻🖨🖱📷📺🎥🔦⏰💎💰",
//                    "flags":"🇻🇳🇺🇸🏴󠁧󠁢󠁥󠁮󠁧󠁿🇧🇷🇫🇷🇩🇪🇮🇹🇨🇳🇯🇵🇪🇸🇰🇷🇨🇭"]
    
    private let backgroundColors = ["Animals":#colorLiteral(red: 0.13333, green: 0.13333, blue: 0.13333, alpha: 1), "Sports":#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1), "Faces":#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), "Fruits":#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), "Objects":#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), "Flags":#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)]
    
    private let cardBackColors = ["Animals":#colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), "Sports":#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), "Faces":#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), "Fruits":#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "Objects":#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), "Flags":#colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)]
    
    private var chosenCardColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
    
    private var emojiChoices = ""
    
    private var emoji = [Card:String]()
    
    private func emoji(for card: Card) -> String {
        
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        
        return emoji[card] ?? "?"
    }
    
    var theme: String? {
        didSet {
            emojiChoices = theme ?? ""
            emoji = [:]
            
            self.view.backgroundColor = backgroundColors[theme!] ?? #colorLiteral(red: 0.13333, green: 0.13333, blue: 0.13333, alpha: 1)
            chosenCardColor = cardBackColors[theme!] ?? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            
            updateViewFromModel()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //randomThemeForgame()
        
        
        updateViewFromModel()
    }
    
    
//    private func randomThemeForgame() {
//        let themeKeys = Array(themes.keys)
//        let randomThemeKey = themeKeys.count.arc4random
//        emojiChoices = themes[themeKeys[randomThemeKey]] ?? ""
//        self.view.backgroundColor = backgroundColors[themeKeys[randomThemeKey]] ?? #colorLiteral(red: 0.13333, green: 0.13333, blue: 0.13333, alpha: 1)
//        chosenCardColor = cardBackColors[themeKeys[randomThemeKey]] ?? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
//    }
   
    
    @IBAction private func touchNewGame(_ sender: Any) {
        game.resetGame()
        emoji.removeAll()
        //randomThemeForgame()
        updateViewFromModel()
    }
    
    @IBOutlet private weak var scoreLabel: UILabel!
}

//extension Int {
//    var arc4random: Int {
//        if self > 0 {
//            return Int(arc4random_uniform(UInt32(self)))
//        } else if self < 0 {
//            return -Int(arc4random_uniform(UInt32(self)))
//        } else {
//            return 0
//        }
//    }
//}

