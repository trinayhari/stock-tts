//
//  BuyStockView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/30/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import Alamofire

class BuyStockView: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var stNameLbl: UILabel!
    @IBOutlet weak var stSymLbl: UILabel!
    @IBOutlet weak var stPriceLbl: UILabel!
    @IBOutlet weak var buyQtTxt: UITextField!
    @IBOutlet weak var availMoneyLbl: UILabel!
    @IBOutlet weak var puchaseAmt: UILabel!
    
    var stNm : String!
    var qtyNum : Int!
   // var userDetails : User?
    var buyStock = GlobalQuote(data: [:])
    var totalCost = 0.00
    static var purchaseResponse : PurchasedStocksResponse!
    var responseString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        self.buyQtTxt.delegate = self
       /* if let savedUserDetails = userDefaults.object(forKey: "userVal") as? Data {
                  let decoder = JSONDecoder()
               if let loadedUserVal = try? decoder.decode(User.self, from: savedUserDetails) {
                    userDetailVal = loadedUserVal
                  }
              }*/
        self.loadUI()
        
        // Do any additional setup after loading the view.
    }
    
    func loadUI(){
        availMoneyLbl.text = "$ "+(userDetailVal?.currBal!)!
        stNameLbl.text = self.stNm
        stSymLbl.text = self.buyStock.symbol
        stPriceLbl.text = self.buyStock.price
        self.puchaseAmt.text = (String(describing: self.totalCost))
    }
    
    @IBAction func goBack(_ sender: Any) {
        if #available(iOS 13.0, *) {
                sceneDelegate.createMainView()
        } else {
            appDelegate.createMainView()
        }
      /*  let dashboardView = self.storyboard?.instantiateViewController(identifier: "dashboard") as! DashboardView
       let navi = UINavigationController(rootViewController: dashboardView)
        self.present(navi, animated: true, completion: nil)*/
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   /* func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == buyQtTxt{
            self.qtyNum = Int(buyQtTxt.text!)
            textField.resignFirstResponder()
            self.view.endEditing(true)
            return true
    }
        return true
    }
   
    

    @IBAction func onBuyStock(_ sender: Any) {
        
         self.qtyNum = Int(buyQtTxt.text!)
        if buyQtTxt.text!.isEmpty == true {
           // self.showAlert(message: "Enter a quantity to purchase")
        }
        else {
       
        if self.qtyNum >= 0 {
            totalCost = Double(self.qtyNum) * Double(self.buyStock.price!)!
            if self.totalCost < Double((userDetailVal?.currBal!)!)! {
            
            let alertController = UIAlertController(title: "Buy Stock", message:
                "You are about to buy \(buyQtTxt.text!) quantity.Total purchase amount is \(String(describing: self.totalCost))", preferredStyle: .alert)
             alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                
                let currBalance = Double((userDetailVal?.currBal!)!)! - self.totalCost
                userDetailVal?.currBal = (String(describing: currBalance))
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(userDetailVal) {
                                      userDefaults.set(encoded,forKey: "userVal")
                }
                alertController.dismiss(animated: true, completion: nil)
                self.callPurchaseService { (responseString) in
                    DispatchQueue.main.async(execute: {
                        indicator.stopAnimating()
                    })
                   // self.showAlert(message: self.responseString)
                    self.puchaseAmt.text = String(format:"%.2f", self.totalCost)
                    self.availMoneyLbl.text = "$ "+String(format:"%.2f", currBalance)
                  //self.puchaseAmt.text = (String(describing: self.totalCost))
                 // self.availMoneyLbl.text = "$ "+(String(describing: currBalance))
                }
               
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                self.buyQtTxt.text! = ""
                  alertController.dismiss(animated: true, completion: nil)
                }))

                self.present(alertController, animated: true, completion: nil)
        }
            else {
              //  showAlert(message: "Your available amount is not sufficient")
            }
        }
    }
    }
    
    private func callPurchaseService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
        let url = "user/save_purchase_product"
        let parameters : Parameters = ["user_id":userId!,"product_symbol":self.stSymLbl.text!, "product_name":self.stNm!,"open_value":self.buyStock.open!, "product_price":stPriceLbl.text!, "quantity":qtyNum!, "product_total_amt":self.totalCost, "commercial_type":"buy", "latest_trade_date":self.buyStock.latestTrDay!]
        buyStockService(url1: url, parameters: parameters) { (jsonDict) in
            let decoder = JSONDecoder()
            do{
                BuyStockView.purchaseResponse = try decoder.decode(PurchasedStocksResponse.self, from: jsonDict!)
            
                self.responseString = BuyStockView.purchaseResponse.response
            DispatchQueue.main.async(execute: {
                indicator.stopAnimating()
            })
                if BuyStockView.purchaseResponse.success == true {
                   completion(self.responseString)
                     Alert.showViewAlert(message: self.responseString, vc: self)
                    // showAlert(message: self.responseString)
                    }
                    else {
                      Alert.showViewAlert(message: self.responseString, vc: self)
                    }
            }catch {
                
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
