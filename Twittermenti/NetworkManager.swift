//
//  NetworkManager.swift
//  Twittermenti
//
//  Created by Juan Jimenez on 11/28/22.
//  Copyright © 2022 London App Brewery. All rights reserved.
//

import Foundation
import UIKit
import CoreML



class NetworkManager {
    
    static let shared   = NetworkManager()
    private let baseURL = "https://api.twitter.com/1.1/search/tweets.json?"
    let tweetCount = "100"
    let tweetLang = "en"
    let tweetMode = "extended"


    
    
    private init() {}
    
    
    func getPlistKey(from plistFile: String, key: String) -> String {

            guard let filepath = Bundle.main.path(forResource: plistFile, ofType: "plist") else {

                fatalError("Could not find Security.plist")

            }

            guard let rawdata = try? Data(contentsOf: URL(fileURLWithPath: filepath)) else {

                fatalError("Could not get URL path to plist")

            }

            guard let plist = try? PropertyListSerialization.propertyList(from: rawdata, format: nil) as? [String:Any] else {

                fatalError("Could not covert rawdata into plist dictionary")

            }

            let value = plist![key] as! String

            return value

        }
    
    
    
    func getTweets(searchItem: String) -> [TwitterSentimentClassifierInput]  {
        
        let bearerToken = getPlistKey(from: "Secrets", key: "BearerToker")
        
        var tweets = [TwitterSentimentClassifierInput]()
        var semaphore = DispatchSemaphore (value: 0)
        
        
        let endpoint = baseURL + "q=\(searchItem)&lang=\(tweetLang)&count=\(tweetCount)&tweet_mode=\(tweetMode)"
        
        
        
        guard let url = URL(string: endpoint) else {
            
            fatalError("NO SE PUDO ARMAR LA URL")
        }
        //URL Request
        var  request = URLRequest(url: url)
        
        //request headers
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.addValue("guest_id=v1%3A166974559417088212; guest_id_ads=v1%3A166974559417088212; guest_id_marketing=v1%3A166974559417088212; personalization_id=\"v1_XFTtA+MTguZd2KJQ73uqVg==\"", forHTTPHeaderField: "Cookie")
        //request.addValue("100", forHTTPHeaderField: "count")
        //request.addValue("en", forHTTPHeaderField: "lan")
        //request.addValue("tweetMode", forHTTPHeaderField: "extended")
       
        
        //set the request type
        request.httpMethod = "GET"
        
        // get the urlSession
        
        let session = URLSession.shared
        //create the data task
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            
            //checking for error
            if error == nil && data != nil {
                //parse the data
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print(String(describing: error))
                    semaphore.signal()
                    return
                }
                
                guard let data = data else {
                    fatalError("Invalid data")
                    
                }
                
                do {
                    
                    if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject], let arrayStatuses = responseObject["statuses"] as? [[String:AnyObject]] {
                        
                        //let arrTweets:NSMutableArray = NSMutableArray()
                        
                        
                        for status in arrayStatuses {
                            let text = status["full_text"]
                            let tweetForClassification = TwitterSentimentClassifierInput(text: text as! String)
                            tweets.append(tweetForClassification)
                           // print(status["full_text"]!)
                        
                            
                        }
                        
                        
                    }
                    semaphore.signal()
                    
                } catch {
                    fatalError("error parsing responde data")
                }
            }
        
        }
        dataTask.resume()
        semaphore.wait()
        return  tweets
        
    }
}
