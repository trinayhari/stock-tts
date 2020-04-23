//
//  DashboardView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/19/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import SideMenuSwift

class DashboardView: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var myStockTbl: UITableView!
    @IBOutlet weak var openBalLbl: UILabel!
    @IBOutlet weak var investBalLbl: UILabel!
    @IBOutlet weak var currBalLbl: UILabel!
    
    //var userPurchasedStocks : [UserPurchasedStocks]!
    var userDetails : User?
    static var userDetailResponse : LoginResponse!
    static var userPurchasesResponse : PurchasedStocksResponse!
    var responseString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
       // self.myStockTbl.delegate = self
       // self.myStockTbl.dataSource = self
        
      if let savedUserDetails = userDefaults.object(forKey: "userVal") as? Data {
           let decoder = JSONDecoder()
        if let loadedVal = try? decoder.decode(User.self, from: savedUserDetails) {
           // loadUI()
            userId = loadedVal.userId
           }
       }

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.callUserDetailService { (responseString) in
        self.loadUI()
        let url = "user/purchased_products/"+(userId)!
            userProductsService(url1: url) { (jsonDict) in
                  let decoder = JSONDecoder()
                do{
                    DispatchQueue.main.async(execute: {
                        indicator.stopAnimating()
                    })
                    DashboardView.userPurchasesResponse = try decoder.decode(PurchasedStocksResponse.self, from: jsonDict!)
                    userPurchasedStocks = DashboardView.userPurchasesResponse.products
                   // print(self.userPurchasedStocks)
                    if DashboardView.userPurchasesResponse.products?.count == 0 {
                      //  self.showAlert(message: "No stocks purchased yet.")
                    }else{
                    self.myStockTbl.dataSource = self
                    self.myStockTbl.delegate = self
                    self.myStockTbl.reloadData()
                    }
                }catch {
                    print(error)
                }
            }
        }
    }
    
    
    @IBAction func onMenu(_ sender: Any) {
      
        self.sideMenuController?.revealMenu(animated: true, completion: nil)
    }
    
    func loadUI(){
        self.openBalLbl.text = ("$ "+(userDetails?.openBal)!)
        self.investBalLbl.text = ("$ "+(userDetails?.transactBal)!)
        self.currBalLbl.text = ("$ "+(userDetails?.currBal)!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userPurchasedStocks!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myStockTbl.dequeueReusableCell(withIdentifier: "myStockCell", for: indexPath) as! MyStockCell
        cell.stSymbol.text = userPurchasedStocks![indexPath.row].prdSym
        cell.stName.text = userPurchasedStocks![indexPath.row].prdName
        cell.prdPrice.text = userPurchasedStocks![indexPath.row].prdPrice
        cell.openVal.text = userPurchasedStocks![indexPath.row].openVal
        cell.sellBtn.tag = indexPath.row
        cell.sellBtn.addTarget(self, action: #selector(sellStock(_:)), for: .touchUpInside)
        return cell
    }
    
    
    
    @objc func sellStock(_ sender:UIButton){
        let sellStockView = self.storyboard?.instantiateViewController(withIdentifier: "SellStock") as! SellStockView
        sellStockView.sellPrd = userPurchasedStocks![sender.tag]
       // print((userPurchasedStocks![sender.tag]).qty)
        let navi = UINavigationController(rootViewController: sellStockView)
       // sellStockView.sellStock = self.stockDt
       // sellStockView.stockNm = self.stockName
       
        self.present(navi, animated: true, completion: nil)
    }
    
    private func callUserDetailService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
        let url = "user/user_details/"+(userId)!
       userDetailsService(url1: url) { (jsonDict) in
         let decoder = JSONDecoder()
         
            do{
                DashboardView.userDetailResponse = try decoder.decode(LoginResponse.self, from: jsonDict!)
                
                self.responseString = DashboardView.userDetailResponse.response
                DispatchQueue.main.async(execute: {
                    indicator.stopAnimating()
                })
                if DashboardView.userDetailResponse?.response == "valid" {
                    self.userDetails = (DashboardView.userDetailResponse?.user)
                    userDetailVal = self.userDetails
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(userDetailVal) {
                        userDefaults.set(encoded,forKey: "userVal")
                    }
                   self.userDetails?.userId = DashboardView.userDetailResponse?.user?.userId
                    completion(self.responseString)
                }
                else {
                   // self.showAlert(message: self.responseString)
                }
                    
            }catch{
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
