//
//  SellStockView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 4/3/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import Alamofire
import iOSDropDown

class SellStockView: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var stName: UILabel!
    @IBOutlet weak var stSymbol: UILabel!
    @IBOutlet weak var currPrice: UILabel!
    @IBOutlet weak var purchasePr: UILabel!
    @IBOutlet weak var soldAmt: UILabel!
    @IBOutlet weak var userAmt: UILabel!
   // @IBOutlet weak var qtyNumTxt: UITextField!
    @IBOutlet weak var sellQty: DropDown!
    var responseString : String!
    var stockNm : String!
    var totalSoldCost = 0.00
    var sellStock = GlobalQuote(data: [:])
    var sellPrd : UserPurchasedStocks!
    var qty : Int!
    var purchaseId : String!
    //var currBalance : Double!
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        self.sellQty.delegate = self
       // print("theuser details",userDetailVal?.currBal)
        callGetStockService { (responseString) in
            
            self.currPrice.text = "$ "+responseString
            self.loadUI()
               }
        
        // Do any additional setup after loading the view.
    }
    
    func loadUI(){
       
        self.userAmt.text = "$ "+(userDetailVal?.currBal!)!
        self.stName.text = self.sellPrd.prdName
        self.stSymbol.text = self.sellPrd.prdSym
        self.purchasePr.text = self.sellPrd.prdPrice
        self.soldAmt.text = (String(describing: self.totalSoldCost))
        let i = Int(self.sellPrd.qty!)
        var qtyArray = [String]()
        for  j in 1..<(i!+1) {
           
            qtyArray.append(String(j))
            //i+=1;
        }
        sellQty.backgroundColor = UIColor.white
        sellQty.selectedRowColor = UIColor.lightGray
       // let qtyArray = [1,2]
        sellQty.optionArray = qtyArray

        sellQty.didSelect{(selectedText , index ,id) in
        self.sellQty.text = selectedText
            }
        self.sellQty.showList()
        //print(qtyArray)
       // qtyNumTxt.text = String(describing: qtyArray.last)
        for values in userPurchasedStocks! {
           // print(values.prdSym,self.stockSym.text)
            if values.prdSym == self.sellStock.symbol{
                self.purchasePr.text =  values.prdPrice
                break
            }
            
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        if #available(iOS 13.0, *) {
                sceneDelegate.createMainView()
        } else {
            appDelegate.createMainView()
        }
       /* let dashboardView = self.storyboard?.instantiateViewController(identifier: "dashboard") as! DashboardView
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
           if textField == sellQty{
             //  self.qtyNum = Int(buyQtTxt.text!)
               textField.resignFirstResponder()
               self.view.endEditing(true)
               return true
       }
           return true
       }
    
    private func callGetStockService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()      //  print("the value is ")
        getStockDetails(funcName: "GLOBAL_QUOTE", symbol:self.sellPrd.prdSym) { (jsonDict) in
            DispatchQueue.main.async(execute: {
                indicator.stopAnimating()
            })
               let decoder = JSONDecoder()
            
               do{
                   
                StockDetailsView.stockResponse = try decoder.decode(StockDetail.self, from: jsonDict!)
                if (StockDetailsView.stockResponse?.globalQuote) != nil {
                self.sellStock = ((StockDetailsView.stockResponse?.globalQuote!)!)
                    
                    completion(self.sellStock.price!)
                    
            }
                else {
                   // self.showAlert(message: "No Stock is selected")
                }
                       
               }catch{
                   print(error)
               }
           }
        
          
          }
    
    @IBAction func onSellStock(_ sender: Any) {
        
               if sellQty.text!.isEmpty == true {
                Alert.showViewAlert(message: "Enter a quantity to sell", vc: self)
               }
               else {
              self.qty = Int(sellQty.text!)!
               if self.qty >= 0 {
                self.totalSoldCost = Double(self.qty) * Double(self.sellStock.price!)!
                   
                   let alertController = UIAlertController(title: "Sell Stock", message:
                    "You are about to sell \(sellQty.text!) quantity.Total selling amount is \(String(describing:  self.totalSoldCost))", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        let currBalance = Double((userDetailVal?.currBal!)!)! + self.totalSoldCost
                        userDetailVal?.currBal = (String(describing: currBalance))
                       
                       let encoder = JSONEncoder()
                       if let encoded = try? encoder.encode(userDetailVal) {
                                             userDefaults.set(encoded,forKey: "userVal")
                       }
                       alertController.dismiss(animated: true, completion: nil)
                       self.callSellService { (responseString) in
                        DispatchQueue.main.async(execute: {
                            indicator.stopAnimating()
                        })
                      //  self.showAlert(message: self.responseString)
                        self.soldAmt.text = String(format:"%.2f", self.totalSoldCost)
                        self.userAmt.text = "$ "+String(format:"%.2f", currBalance)
                        
                       }
                           
                       }))
                       alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                        self.sellQty.text! = ""
                         alertController.dismiss(animated: true, completion: nil)
                       }))

                       self.present(alertController, animated: true, completion: nil)
              
                 
               }
           }
    }
    
    private func callSellService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
        let url = "user/save_sold_product"
        let parameters : Parameters = ["user_id":userId!,"product_symbol":self.stSymbol.text!, "product_name":self.stName.text!,"open_value":self.sellStock.open!, "product_price":currPrice.text!,"quantity":self.sellQty.text!, "product_total_amt":self.totalSoldCost, "commercial_type":"sell", "latest_trade_date":self.sellStock.latestTrDay!,"purchased_id":self.sellPrd.purchaseId!]
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
