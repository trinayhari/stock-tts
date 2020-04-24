//
//  SearchView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/19/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import Alamofire

class SearchStockView: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate  {

    @IBOutlet weak var searchResultsTbl: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
     var userValArray = [String:Any]()
    var searchSym = ""
    static var srcResponse: SearchResponse?
    var responseJSON : [String : Any]?
    var stockData = [BestMatches]()
    var symName : String!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.searchResultsTbl.delegate = self
        self.searchResultsTbl.dataSource = self
        self.searchBar.delegate = self
        setIndicator()
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSym = searchText
        
        if searchSym == "" {
            self.searchResultsTbl.isHidden = true
        }
        else{
        callSearchService { (searchSym) in
          
          //  print(searchSym,"success")
        }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchSym = ""
        self.searchResultsTbl.isHidden = true
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTbl.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchStockCell
        cell.stockName.text = (stockData[indexPath.row].name!)
        cell.stockSym.text = (stockData[indexPath.row].symbol!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        symName = stockData[indexPath.row].symbol!
        if symName != "" {
         let stockDetailView = self.storyboard?.instantiateViewController(withIdentifier: "Details") as! StockDetailsView
               let navi = UINavigationController(rootViewController: stockDetailView)
                stockDetailView.stockSymStr = symName
                stockDetailView.stockName = stockData[indexPath.row].name!
               self.present(navi, animated: true, completion: nil)
        }else {
            print("select a proper stock")
        }
    }
    
   
    
    private func callSearchService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
        searchService(funcName: "SYMBOL_SEARCH", searchText: searchSym) { (jsonDict) in

          //  let convertedString = String(data: jsonDict!, encoding: String.Encoding.utf8)
           // print(convertedString )
            let decoder = JSONDecoder()
         DispatchQueue.main.async(execute: {
             indicator.stopAnimating()
         })
            do{
                //let arr = Array<Any>(jsonDict!)
                //print(arr)
                SearchStockView.srcResponse = try decoder.decode(SearchResponse.self, from: jsonDict!)
                
                self.stockData = (SearchStockView.srcResponse?.bestMatches)!
                
               /* let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self.stockData) {
                    self.userValArray = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String:Any] ?? [:]
                    print(self.userValArray)
                }*/
                self.searchResultsTbl.isHidden = false
                self.searchResultsTbl.reloadData()
                //SearchStockView.srcResponse = SearchResponse(from: searchResponse.bestMatches)
                //print(SearchStockView.srcResponse?.bestMatches["name"])
                    
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
