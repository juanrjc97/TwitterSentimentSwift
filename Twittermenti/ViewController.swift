//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import CoreML
@available(iOS 16.0, *)

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    //@IBOutlet weak var sentimentLabel: UILabel!
    let twitterBrain =  TwitterSentimentClassifier()

    @IBOutlet weak var SentimentLabel: UILabel!
    @IBOutlet weak var memeHolder: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        
    }

    @IBAction func predictPressed(_ sender: Any) {
        if var searchText =  textField.text {
            
            if searchText.contains("#") {
                    searchText.replace("#", with: "%23")
            }
            
            do {
                let tweetsBach: [TwitterSentimentClassifierInput] = NetworkManager.shared.getTweets(searchItem: searchText)
                 let predictions = try self.twitterBrain.predictions(inputs: tweetsBach)
                
                var sentimentScore = 0
                
                for pred in predictions {
                    let sentiment = pred.label
                    if sentiment == "Pos"{
                        sentimentScore += 1
                    }else if sentiment == "Neg"{
                        sentimentScore -= 1
                    }
                }
                
                updateUI(with: sentimentScore)
                sentimentScore = 0
               
               
            }catch{
                fatalError("Ocurrio un error dentro del clasificador")
            }
        }
    
    }
    
    func updateUI(with sentimentScore: Int) {
        if sentimentScore > 20 {
            self.SentimentLabel.text = "Super Happy"
            self.memeHolder.image = UIImage(named: "superHappy")
        }else if sentimentScore > 10
        {
            self.SentimentLabel.text = "Really Happy"
            self.memeHolder.image = UIImage(named: "happy")
        }
        else if sentimentScore > 0 {
            self.SentimentLabel.text = "Happy"
            self.memeHolder.image = UIImage(named: "happyDown")
            
        }else if sentimentScore == 0 {
            self.SentimentLabel.text = "Normal"
            self.memeHolder.image = UIImage(named: "normal")
            
        }else if sentimentScore > -10 {
            self.SentimentLabel.text = "Angry"
            self.memeHolder.image = UIImage(named: "Angry")
            
        }else if sentimentScore > -20 {
            self.SentimentLabel.text = "Super Angry"
            self.memeHolder.image = UIImage(named: "reallyAngry")
            
        }
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return false
    }
    
}

