//
//  Login.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/19/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import Foundation

struct LoginResponse : Decodable {
    var success : Bool?
    var response : String?
    var user : User?
    
}

struct User : Decodable,Encodable {
    var userId : String?
    var userNm : String?
    var userMail : String?
    var pwd : String?
    var openBal : String?
    var currBal : String?
    var transactBal : String?
    var createDt : String?
    var lastLoginDt : String?
    
    enum CodingKeys: String, CodingKey {
           
           case userId = "user_id"
           case userNm = "name"
           case userMail = "email"
           case pwd = "password"
           case openBal = "opening_balance"
           case currBal = "current_balance"
           case transactBal = "transaction_balance"
           case createDt = "created_date"
           case lastLoginDt = "last_login_date"
       }
    
    init(data:[String:Any]){
       self.userId = (data["user_id"] as? String ?? "")
       self.userNm = (data["name"] as? String ?? "")
       self.userMail = (data["email"] as? String ?? "")
       self.pwd = (data["password"] as? String ?? "")
       self.openBal = (data["opening_balance"] as? String ?? "")
       self.currBal = (data["current_balance"] as? String ?? "")
       self.transactBal = (data["transaction_balance"] as? String ?? "")
       self.createDt = (data["created_date"] as? String ?? "")
       self.lastLoginDt = (data["last_login_date"] as? String ?? "")
       }
    }

/*"success": true,
"response": "valid",
"user": {
    "user_id": "3",
    "name": "aaa",
    "email": "a@g.com",
    "password": "47bce5c74f589f4867dbd57e9ca9f808",
    "opening_balance": "3000.00",
    "current_balance": "3000.00",
    "transaction_balance": "0.00",
    "created_date": "2020-03-26 02:59:15",
    "last_login_date": "2020-03-26 02:59:15",
    "is_active": "1" */
