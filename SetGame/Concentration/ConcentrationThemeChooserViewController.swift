//
//  ConcentrationThemeChooserViewController.swift
//  SetGame
//
//  Created by Thai Nguyen on 10/19/18.
//  Copyright © 2018 Thai Nguyen. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    private let themes = ["Animals":"🐶🐱🐰🦊🦁🐵🦆🕷🦂🐟🐍🐿",
                          "Sports":"⚽️🏀🏈🎱🏓🏹⛸⛷🎣🥊🎾🏐",
                          "Faces":"😄☺️😍😂😡😈😱😤😐😵😇😎",
                          "Fruits":"🍎🍊🍋🍌🍉🍓🥑🌽🍅🍍🥦🥒",
                          "Objects":"⌚️📱💻🖨🖱📷📺🎥🔦⏰💎💰",
                          "Flags":"🇻🇳🇺🇸🏴󠁧󠁢󠁥󠁮󠁧󠁿🇧🇷🇫🇷🇩🇪🇮🇹🇨🇳🇯🇵🇪🇸🇰🇷🇨🇭"]
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    private var lastSeguedToConcentrationViewController: ConcentrationViewController?
    
    
    
    @IBAction func chooseTheme(_ sender: Any) {
        if let cvc = splitViewDetailConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
                cvc.navigationItem.title = themeName
            }
        } else if let cvc = lastSeguedToConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
                cvc.navigationItem.title = themeName
            }
            navigationController?.pushViewController(cvc, animated: true)
        } else {
            performSegue(withIdentifier: "Choose Theme", sender: sender as! UIButton)
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        if let cvc = secondaryViewController as? ConcentrationViewController {
            return cvc.theme == nil
        }
        
        return false
    }
    

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier, identifier == "Choose Theme", let cvc = segue.destination as? ConcentrationViewController {
            if let themeName = (sender as? UIButton)?.currentTitle, let theme = themes[themeName] {
                cvc.theme = theme
                lastSeguedToConcentrationViewController = cvc
                cvc.navigationItem.title = themeName
            }
        }
    }

}
