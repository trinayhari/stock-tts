//
//  StockTimelyDt.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/21/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import Foundation

struct StockIntervalResponse : Decodable {
   
    var metaData : MetaData?
    let timeSeriesDay : [String: TimeSeriesDaily]?
    let timeSeriesMins : [String: TimeSeriesDaily]?
    let timeSeriesMonth : [String: TimeSeriesDaily]?
   // let timeSeries : [String:[TimeSeriesDaily]]
    
    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeriesDay = "Time Series (Daily)"
        case timeSeriesMins = "Time Series (30min)"
        case timeSeriesMonth = "Monthly Time Series"
   
    }
  
}
struct MetaData : Decodable,Encodable {
    
    var info: String?
    var symbol: String?
    var lastRf: String?
    var interval : String?
    var opSize: String?
    var timeZone: String?
    
    
    enum CodingKeys: String, CodingKey {
        
        case info = "1. Information"
        case symbol = "2. Symbol"
        case lastRf = "3. Last Refreshed"
        case opSize = "4. Output Size"
        case timeZone = "5. Time Zone"
        
    }
      
   init(data:[String:Any]){
    self.info = (data[info!] as? String ?? "")
    self.symbol = (data[symbol!] as? String ?? "")
    self.lastRf = (data[lastRf!] as? String ?? "")
    self.opSize = (data[opSize!] as? String ?? "")
    self.timeZone = (data[timeZone!] as? String ?? "")
        
    }
}

struct TimeSeriesDaily: Codable {
    let the1Open, the2High, the3Low, the4Close: String
    let the5Volume: String

    enum CodingKeys: String, CodingKey {
        case the1Open = "1. open"
        case the2High = "2. high"
        case the3Low = "3. low"
        case the4Close = "4. close"
        case the5Volume = "5. volume"
    }
}



