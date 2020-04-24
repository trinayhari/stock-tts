//
//  StockDetails.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/20/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//


import Foundation

struct StockDetail : Decodable {
   
    var globalQuote : GlobalQuote?
    
    enum CodingKeys: String, CodingKey {
        case globalQuote = "Global Quote"
   
    }
    
  init(globalQt : GlobalQuote?) {
       
    self.globalQuote = globalQt
        
    }
    
}

struct GlobalQuote : Decodable,Encodable {
    
    var symbol: String?
    var open: String?
    var high: String?
    var low: String?
    var price: String?
    var volume : String?
    var latestTrDay : String?
    var prClose : String?
    var change : String?
    var chPercent : String?
    
    enum CodingKeys: String, CodingKey {
        
        case symbol = "01. symbol"
        case open = "02. open"
        case high = "03. high"
        case low = "04. low"
        case price = "05. price"
        case volume = "06. volume"
        case latestTrDay = "07. latest trading day"
        case prClose = "08. previous close"
        case change = "09. change"
        case chPercent = "10. change percent"
    }
    
   
    
   init(data:[String:Any]){
    self.symbol = (data["01. symbol"] as? String ?? "")
    self.open = (data["02. open"] as? String ?? "")
    self.high = (data["03. high"] as? String ?? "")
    self.low = (data["04. low"] as? String ?? "")
    self.price = (data["05. price"] as? String ?? "")
    self.volume = (data["06. volume"] as? String ?? "")
    self.latestTrDay = (data["07. latest trading day"] as? String ?? "")
    self.prClose = (data["08. previous close"] as? String ?? "")
    self.change = (data["09. change"] as? String ?? "")
    self.chPercent = (data["10. change percent"] as? String ?? "")
        
    }
}
