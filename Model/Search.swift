//
//  Search.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/19/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import Foundation

struct SearchResponse : Decodable {
   
    var bestMatches : [BestMatches]?
    
    enum CodingKeys: String, CodingKey {
        case bestMatches = "bestMatches"
   
    }
    
  init(searchRes : [BestMatches]?) {
       
        self.bestMatches = searchRes ?? []
        
    }
    
}

struct BestMatches : Decodable,Encodable {
    
    var symbol: String? 
    var name: String?
    var type: String?
    var region: String?
    var marketOpen: String?
    var marketClose : String?
    var timezone : String?
    var currency : String?
    var matchScore : String?
    
    enum CodingKeys: String, CodingKey {
        
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case region = "4. region"
        case marketOpen = "5. marketOpen"
        case marketClose = "6. marketClose"
        case timezone = "7. timezone"
        case currency = "8. currency"
        case matchScore = "9. matchScore"
    }
    
   
    
   init(data:[String:Any]){
    self.symbol = (data["1. symbol"] as? String ?? "")
    self.name = (data["2. name"] as? String ?? "")
    self.type = (data["3. type"] as? String ?? "")
    self.region = (data["4. region"] as? String ?? "")
    self.marketOpen = (data["5. marketOpen"] as? String ?? "")
    self.marketClose = (data["6. marketClose"] as? String ?? "")
    self.timezone = (data["7. timezone"] as? String ?? "")
    self.currency = (data["8. currency"] as? String ?? "")
    self.matchScore = (data["9. matchScore"] as? String ?? "")
        
    }
}
