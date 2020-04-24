//
//  UserPurchasedStocks.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/27/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import Foundation

struct PurchasedStocksResponse : Decodable {
    var success : Bool!
    var response : String!
    var products : [UserPurchasedStocks]?
}

struct UserPurchasedStocks : Decodable,Encodable {
    var purchaseId : String!
    var userId : String!
    var prdSym : String!
    var prdName : String!
    var openVal : String!
    var prdPrice : String!
    var qty : String!
    var prdTotalAmt : String!
    var soldDt : String!
    var tradeType : String!
    var buyDt : String!
    var latestTradeDt : String!
    
    enum CodingKeys: String, CodingKey {
        
        case purchaseId = "purchase_id"
        case userId = "user_id"
        case prdSym = "product_symbol"
        case prdName = "product_name"
        case openVal = "open_value"
        case prdPrice = "product_price"
        case qty = "quantity"
        case prdTotalAmt = "product_total_amt"
        case soldDt = "sold_date"
        case tradeType = "commercial_type"
        case buyDt = "buy_date"
        case latestTradeDt = "latest_trade_date"
    }
}

