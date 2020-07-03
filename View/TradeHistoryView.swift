//
//  TradeHistoryView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 4/27/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit

class TradeHistoryView: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var allPrdsTbl: UITableView!
    static var userAllProductsResponse : PurchasedStocksResponse!
   var sellStock = GlobalQuote(data: [:])
    var userAllProducts : [UserPurchasedStocks]?
    var responseString : String!
    var currPrice = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        callgetAllPrdService { (responseString) in
            if TradeHistoryView.userAllProductsResponse.products?.count == 0 {
               showAlert(message: "No transactions made...")
              
            }else{
                
                self.callGetStockService { (currPrice1) in
                    DispatchQueue.main.async(execute: {
                        indicator.stopAnimating()
                    })
                   self.allPrdsTbl.dataSource = self
                   self.allPrdsTbl.delegate = self
                   self.allPrdsTbl.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAllProducts!.count
       }
    
    
       
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = allPrdsTbl.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath) as! AllProductsCell
    cell.stName.text = userAllProducts![indexPath.row].prdName
    cell.stSymbol.text = userAllProducts![indexPath.row].prdSym
    cell.purAmt.text = userAllProducts![indexPath.row].prdTotalAmt
    
    if userAllProducts![indexPath.row].soldId != nil {
        cell.stPrice.textColor = UIColor.green
        cell.qty.text = userAllProducts![indexPath.row].qty!+" shares"
    }
    else {
        cell.stPrice.textColor = UIColor.red
        cell.qty.text = userAllProducts![indexPath.row].actQty+" shares"
    }
    cell.stPrice.text = userAllProducts![indexPath.row].prdPrice
    let plPerValue = (Float(self.currPrice[indexPath.row])! - Float(userAllProducts![indexPath.row].prdPrice)!) / (Float(userAllProducts![indexPath.row].prdPrice)!)
    cell.plPercent.text = String(format:"%.2f", plPerValue)+" %"
    return cell
   }
    
    
   private func callGetStockService (completion: @escaping ([String]) -> Void) {
         //  print("the value is ")
    for values in userAllProducts! {
        
        getStockDetails(funcName: "GLOBAL_QUOTE", symbol:values.prdSym) { (jsonDict) in
            
               let decoder = JSONDecoder()
            
               do{
                   
                StockDetailsView.stockResponse = try decoder.decode(StockDetail.self, from: jsonDict!)
                if (StockDetailsView.stockResponse?.globalQuote) != nil {
                let stockDetails = ((StockDetailsView.stockResponse?.globalQuote!)!)
                    self.currPrice.append(stockDetails.price!)
                    if self.userAllProducts?.count == self.currPrice.count {
                    completion(self.currPrice)
                    }
                    
            }
                else {
                   // self.showAlert(message: "No Stock is selected")
                }
                       
               }catch{
                   print(error)
               }
           }
    }
          
          }
    
    
    @IBAction func goBack(_ sender: Any) {
        if #available(iOS 13.0, *) {
            sceneDelegate.createMainView()
        } else {
            appDelegate.createMainView()
        }
    }
    
    private func callgetAllPrdService (completion: @escaping (String) -> Void) {
     indicator.startAnimating()
         let url = "user/all_products/"+(userId)!
             userProductsService(url1: url) { (jsonDict) in
                   let decoder = JSONDecoder()
                 do{
                    TradeHistoryView.userAllProductsResponse = try decoder.decode(PurchasedStocksResponse.self, from: jsonDict!)
                    self.responseString = TradeHistoryView.userAllProductsResponse.response
                    if TradeHistoryView.userAllProductsResponse.success == true {
                    self.userAllProducts = TradeHistoryView.userAllProductsResponse.products
                        completion(self.responseString)
                    }
                    else {
                        Alert.showViewAlert(message: self.responseString, vc: self)
                    }
                 }catch {
                     print(error)
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
