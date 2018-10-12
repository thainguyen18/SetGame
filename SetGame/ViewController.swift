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
    
    private var buttons = [SetCardView]() {
        didSet {
            if !game.canStillDrawCards() {
                self.DealMoreButton.isHidden = true
            } else {
                self.DealMoreButton.isHidden = false
            }
        }
    }
    
    private var selectedButtons = [SetCardView]()
 
    private var CardForButton = [SetCardView:SetCard]()
    
    @IBOutlet weak var DealMoreButton: UIButton!
    
    @IBOutlet weak var hintButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var cardsHolderView: UIView!
    
    @IBOutlet weak var newGameButton: UIButton!
        
    
    private var grid = Grid(layout: .aspectRatio(3.0/5.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start game with 12 cards
        for _ in 1...4 {
            dealMoreCards()
        }
        
        // Initially hide hint card
        hintButton.isHidden = true
        
        // Set up gestures
        setUpSwipeGesture()
        setUpRotationGesture()
        
        newGameButton.addTarget(self, action: #selector(self.touchNewGame), for: UIControl.Event.touchUpInside)
    }
    
    
    @objc private func touchNewGame() {
        print("Touch new game")
        
        selectedButtons.removeAll()
        
        for index in buttons.indices {
            buttons[index].removeFromSuperview()
        }
        
        buttons.removeAll()
        
        game = SetGame() // Create new game object
        
        // Start game with 12 cards
        for _ in 1...4 {
            dealMoreCards()
        }
    }
    
    private func setUpSwipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.dealMoreCardsBySwipe(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    private func setUpRotationGesture() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action:#selector(self.shuffleCardsByRotation(_:)))
        self.view.addGestureRecognizer(rotationGesture)
    }
    
    @objc private func dealMoreCardsBySwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.dealMoreCards()
        default:
            break
        }
    }
    
    @objc private func shuffleCardsByRotation(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.shuffleCards()
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !shouldKeepRelayoutCardsDueToAMatchReplacement {
            
            // Initial layout cards
            grid.frame = self.cardsHolderView.frame
            
            reLayoutCards()
        }
        
        // if keep layout due to card replacement then enable rotation layout
        if shouldKeepRelayoutCardsDueToAMatchReplacement {
            shouldKeepRelayoutCardsDueToAMatchReplacement = !shouldKeepRelayoutCardsDueToAMatchReplacement
        }
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
                let _ = addCard()
            }
            shouldShowHintButton()
            
            reLayoutCards()
        } else {
            replaceOrHideMatchedCards()
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
    
    
    @objc private func touchCardButton(button: SetCardView) {
        switch selectedButtons.count {
            case 0,1,2:
                if selectedButtons.contains(button) {
                    deselectButton(cardButton: button)
                    
                } else {
                    selectButton(cardButton: button)
                    if selectedButtons.count == 3 {
                        updateUIForMatch(isMatched: game.isThereAMatch)
                    }
                }
                shouldKeepRelayoutCardsDueToAMatchReplacement = false
            case 3:
                // If these cards are not a match
                if !game.isThereAMatch {
                    deselectAll()
                    selectButton(cardButton: button)
                    
                    shouldKeepRelayoutCardsDueToAMatchReplacement = false
                } else {
                    // if a matched set, replace or hide them
                    if !selectedButtons.contains(button) {
                        replaceOrHideMatchedCards()
                        selectButton(cardButton: button)
                    }
                }
            default: break
        }
    }
    
    private var shouldKeepRelayoutCardsDueToAMatchReplacement = false
    
    private func replaceOrHideMatchedCards() {
        
        for button in selectedButtons {
            if let setCard = CardForButton[button] {
                game.removeCardOnScreen(card: setCard)
                game.addCardToMatched(card: setCard)
            }
            if let index = buttons.index(of:button) {
                buttons.remove(at: index)
            }
            if (game.canStillDrawCards()) { //Replace cards
                if let newButton = addCard() {
                    newButton.frame = button.frame
                    
                    shouldKeepRelayoutCardsDueToAMatchReplacement = true
                    
                    self.cardsHolderView.addSubview(newButton)
                    
                    button.removeFromSuperview()
                }
            } else {
                button.removeFromSuperview() // Or hide cards and relayout
                reLayoutCards()
            }
        }
        
        deselectAll()
            
        // Update score
        scoreLabel.text = "Score: \(game.score)"
    }
    
    private func selectButton(cardButton: SetCardView) {
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
    
    private func deselectButton(cardButton: SetCardView) {
        cardButton.layer.borderWidth = 0.0
        if let index = selectedButtons.index(of: cardButton) {
            selectedButtons.remove(at: index)
        }
        if let card = CardForButton[cardButton], let index = game.selectedCards.index(of:card) {
            game.selectedCards.remove(at: index)
        }
        shouldShowHintButton()
    }
    
    private func deselectAll() {
        for button in buttons {
            button.layer.borderWidth = 0.0
        }
        selectedButtons.removeAll()
        game.selectedCards.removeAll()
    }
    
    
    @objc private func shuffleCards() {
        deselectAll()
        
        let noOfCardsOnScreen = buttons.count
        
        for index in self.buttons.indices {
            buttons[index].removeFromSuperview()
        }
        
        buttons.removeAll()
        
        game.shuffleDeck()
        
        for _ in 1...noOfCardsOnScreen {
            let _ = addCard()
        }
        
        shouldShowHintButton()
        
        reLayoutCards()
    }
    
    private func addCard() -> SetCardView? {
        
        if let setCard = game.draw() {
            
            if game.cards.isEmpty { self.DealMoreButton.isHidden = true }
            
            let button = SetCardView()
            button.setCard = setCard
            button.backgroundColor = UIColor.white
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchAction(_:)))
            button.isUserInteractionEnabled = true
            button.addGestureRecognizer(tap)
            
            self.buttons.append(button)
            
            CardForButton.updateValue(setCard, forKey: button)
            
            return button
        } else {
            return nil
        }
    }
    
    @objc private func touchAction(_ sender: UITapGestureRecognizer) {
        if let cardView = sender.view as? SetCardView {
            self.touchCardButton(button: cardView)
        }
    }

    
    func reLayoutCards() {
        
        grid.cellCount = buttons.count // Relayout frames for cards
        
        let offsetX = self.view.frame.origin.x - self.grid.frame.origin.x
        let offsetY = self.view.frame.origin.y - self.grid.frame.origin.y
        
        for index in self.buttons.indices {
            if let cellFrame = grid[index] {
                buttons[index].frame = cellFrame.offsetBy(dx: offsetX, dy: offsetY).inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
                self.cardsHolderView.addSubview(buttons[index])
            }
        }
    }
}


extension CGRect {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x + dx, y: self.origin.y + dy, width: self.size.width, height: self.size.height)
    }
}


