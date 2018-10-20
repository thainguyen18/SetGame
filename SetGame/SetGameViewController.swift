//
//  ViewController.swift
//  SetGame
//
//  Created by Thai Nguyen on 9/6/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController, UIDynamicAnimatorDelegate {

    lazy var game = SetGame()
    
    private var buttons = [SetCardView]() {
        didSet {
            if !game.canStillDrawCards() {
                self.drawingDeck.isHidden = true
            } else {
                self.drawingDeck.isHidden = false
            }
        }
    }
    
    private var selectedButtons = [SetCardView]()
 
    private var CardForButton = [SetCardView:SetCard]()
    
    @IBOutlet weak var hintButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var cardsHolderView: UIView!
    
    @IBOutlet weak var newGameButton: UIButton!
    
    private var grid = Grid(layout: .aspectRatio(3.0/5.0))
    
    @IBOutlet weak var drawingDeck: UIButton!
    
    @IBOutlet weak var matchingCardsDeck: UIView!
    
    lazy var animator = UIDynamicAnimator(referenceView: self.view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set self to be Animator delegate
        animator.delegate = self
        
        // Initially hide hint card
        hintButton.isHidden = true
        
        // Set up gestures
        setUpRotationGesture()
        
        newGameButton.addTarget(self, action: #selector(self.touchNewGame), for: UIControl.Event.touchUpInside)
        
        // add action deal more cards by tapping deal more button
        drawingDeck.addTarget(self, action: #selector(self.dealMoreCards), for: UIControl.Event.touchUpInside)
    }
    
    
    @objc private func touchNewGame() {

        selectedButtons.removeAll()
        
        for index in buttons.indices {
            buttons[index].removeFromSuperview()
        }
        
        buttons.removeAll()
        
        game = SetGame() // Create new game object
        
        // Start game with 12 cards
        initialDraw()
    }
    
    
    private func setUpRotationGesture() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action:#selector(self.shuffleCardsByRotation(_:)))
        self.view.addGestureRecognizer(rotationGesture)
    }
    
    
    @objc private func shuffleCardsByRotation(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.returnCardsToDeckAndShuffle()
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        if !shouldKeepRelayoutCardsDueToAMatchReplacement {
//
//            // Initial layout cards
//            grid.frame = self.cardsHolderView.frame
//
//            reLayoutCards()
//        }
//
//        // if keep layout due to card replacement then enable rotation layout
//        if shouldKeepRelayoutCardsDueToAMatchReplacement {
//            shouldKeepRelayoutCardsDueToAMatchReplacement = !shouldKeepRelayoutCardsDueToAMatchReplacement
//        }
        
        
        if self.buttons.isEmpty {
            // Initial layout cards
            grid.frame = self.cardsHolderView.frame
            
            // Start game with 12 cards
            initialDraw()
        }
        
        if !shouldKeepRelayoutCardsDueToAMatchReplacement {
            // Adapt UI when bounds change
            grid.frame = self.cardsHolderView.frame

            reLayoutCards()
        }

        //if keep layout due to card replacement then enable rotation layout
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
    
    @objc private func dealMoreCards() {
        // Deal card automatically when there is a match
        for _ in 0...2 {
            let _ = addCard()
        }
        shouldShowHintButton()
        
        reLayoutCards()
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
                    
                    shouldKeepRelayoutCardsDueToAMatchReplacement = false
                    
                    if selectedButtons.count == 3 {
                        updateUIForMatch(isMatched: game.isThereAMatch)
                        
                        // If these cards are a match, replace or hide them
                        if game.isThereAMatch {
                            matchedCards = selectedButtons
                            
                            cardToFaceDown = selectedButtons.last
                            
                            replaceOrHideMatchedCards()
                        }
                    }
                }
            case 3:
                // If there is no match with selected cards
                deselectAll()
                selectButton(cardButton: button)
                
                shouldKeepRelayoutCardsDueToAMatchReplacement = false
        
            default: break
        }
    }
    
    private var cardToFaceDown: SetCardView?
    
    private var matchedCards = [SetCardView]()
    
    private var shouldKeepRelayoutCardsDueToAMatchReplacement = false
    
    private func replaceOrHideMatchedCards() {
        
        var cardIndex = 0
        
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
                    
                    shouldKeepRelayoutCardsDueToAMatchReplacement = true
                    
                    // Animate card replacement
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.7,
                                                                   delay: 0.3 * Double(cardIndex),
                                                                   options: .curveEaseIn,
                                                                   animations: { newButton.frame = button.frame },
                                                                   completion: {position in
                                                                    UIView.transition(with: newButton,
                                                                                      duration: 0.5,
                                                                                      options: .transitionFlipFromLeft,
                                                                                      animations: {
                                                                                        newButton.isFaceUp = true
                                                                    })
                    })
                }
            } else {
                // Or hide cards and relayout
                reLayoutCards()
            }
            
            // Animate discarding to pile
            
            button.layer.borderWidth = 0.0 // remove match UI on card
            
            self.cardBehavior.addItem(button) // Add fly away behavior to card
            
            // Set timer to let cards bounce around for a certain amount of time
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { timer in
                
                self.cardBehavior.removeItem(button) // Remove behavior before snapping to deck by delegation
                
                timer.invalidate()
            })
            
            cardIndex += 1
        }
        
        deselectAll()
            
        // Update score
        scoreLabel.text = "Score: \(game.score)"
    }
    
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
        let newFrame = self.view.convert(self.matchingCardsDeck.frame, to: self.cardsHolderView)
        
        matchedCards.forEach { card in
            self.cardsHolderView.bringSubviewToFront(card)
            
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                           delay: 0.0,
                                                           options: [],
                                                           animations: {
                                                            card.transform = .identity
            },
                                                           completion: { position in
                                                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                                                                           delay: 0.0,
                                                                                                           options: .curveEaseIn,
                                                                                                           animations: {
                                                                                                            card.frame = newFrame },
                                                                                                           completion: {position in
                                                                                                            if let card = self.cardToFaceDown {
                                                                                                                UIView.transition(with: card,
                                                                                                                                  duration: 1.0,
                                                                                                                                  options: .transitionFlipFromLeft,
                                                                                                                                  animations: {
                                                                                                                                    card.isFaceUp = false
                                                                                                                })
                                                                                                            }
                                                            })
                                                            
            })
        }
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
    
    
    private func shuffleCards() {
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
    
    @objc private func returnCardsToDeckAndShuffle() {
        
        let deckLocation = self.view.convert(drawingDeck.frame, to: cardsHolderView)
        
        buttons.forEach{ card in
            
            UIView.transition(with: card,
                              duration: 0.5,
                              options: [.transitionFlipFromLeft],
                              animations: { card.isFaceUp = false },
                              completion: {finished in
                                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5,
                                                                               delay: 0.5,
                                                                               options: [.curveEaseIn],
                                                                               animations: {card.frame = deckLocation},
                                                                               completion: nil
                                                                                )
            })
        }
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {timer in
            self.shuffleCards()
            
            timer.invalidate()
        })
    }
    
    private func addCard() -> SetCardView? {
        
        if let setCard = game.draw() {
            
            //if game.cards.isEmpty { self.DealMoreButton.isHidden = true }
            
            let button = SetCardView()
            button.setCard = setCard
            button.backgroundColor = UIColor.white
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchAction(_:)))
            button.isUserInteractionEnabled = true
            button.addGestureRecognizer(tap)
            
            self.buttons.append(button)
            
            CardForButton.updateValue(setCard, forKey: button)
            
            // Initial card view position i.e at drawing deck with offset
            button.frame = self.view.convert(drawingDeck.frame, to: cardsHolderView)
            
            self.cardsHolderView.addSubview(button)
            
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
    
    private func initialDraw() {
        for _ in 0...11 {
            let _ = addCard()
        }
        reLayoutCards()
    }

    
    func reLayoutCards() {
        
        grid.cellCount = buttons.count // Relayout frames for cards
        
        let offsetX = self.view.frame.origin.x - self.grid.frame.origin.x
        let offsetY = self.view.frame.origin.y - self.grid.frame.origin.y
        
        var noOfCardsToAnimate = 0
        
        for index in self.buttons.indices {
            if let cellFrame = grid[index] {
                let newCardFrame = cellFrame.offsetBy(dx: offsetX, dy: offsetY).inset(by: UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0))
                
                // If card view position has changed
                let card = buttons[index]
                if card.frame != newCardFrame {
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.7,
                                                                   delay: 0.2 * Double(noOfCardsToAnimate),
                                                                   options: [.curveEaseIn],
                                                                   animations: {
                                                                    card.frame = newCardFrame
                    },
                                                                   completion: {position in
                                                                    if !card.isFaceUp {
                                                                        UIView.transition(with: card,
                                                                                          duration: 0.5,
                                                                                          options: [.transitionFlipFromLeft], animations: {
                                                                                            card.isFaceUp = true
                                                                        },
                                                                                          completion: nil)
                                                                    }
                    })
                    noOfCardsToAnimate += 1
                }
            }
        }
    }
}


extension CGRect {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGRect {
        return CGRect(x: self.origin.x + dx, y: self.origin.y + dy, width: self.size.width, height: self.size.height)
    }
}


