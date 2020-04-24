//
//  StockDetailsView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/20/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import Charts

class StockDetailsView: UIViewController,ChartViewDelegate {
    
    @IBOutlet weak var stkDetailsScroll: UIScrollView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var stockPrice: UILabel!
    @IBOutlet weak var stockNm: UILabel!
    @IBOutlet weak var stockSym: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var chPer: UILabel!
    @IBOutlet weak var segmentCntrl: UISegmentedControl!
    
    var stockSymStr : String!
    var stockName = ""
    var stockDt = GlobalQuote(data: [:])
    var stockIntervalDetails = [String:TimeSeriesDaily]()
    static var graphResponse: StockIntervalResponse?
    static var stockResponse : StockDetail?
    var xAxisLabel = [String]()
    var funcName = "TIME_SERIES_DAILY"
    var interval = ""
    var xAxis : XAxis!
    var monthInterval = 1
    var userStocks : [UserPurchasedStocks]!
   
    /*enum DateFormatType : String {
           case type1 = "yyyy-MM-dd HH:mm:ss"
           case type2 = "yyyy-MM-dd"
           case type3 = "yyyy/MM/dd"
       }*/
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        stkDetailsScroll.isScrollEnabled = true
        stkDetailsScroll.contentSize = CGSize(width: self.view.frame.size.width, height: 750)
        if  DashboardView.userPurchasesResponse.products != nil {
            self.userStocks = DashboardView.userPurchasesResponse.products
        }
        self.title = stockName
        self.chartView.delegate = self
        self.chartView.xAxis.drawLabelsEnabled = true
                          self.chartView.xAxis.labelTextColor = UIColor.white
                          self.chartView.leftAxis.labelTextColor = UIColor.white
        self.chartView.zoom(scaleX: 10.0, scaleY: 1.0, x: 0, y: 0)
        self.chartView.xAxis.avoidFirstLastClippingEnabled = false
                          self.chartView.dragEnabled = true
                          self.chartView.setScaleEnabled(true)
                          self.chartView.pinchZoomEnabled = true
                          xAxis = self.chartView.xAxis
                          xAxis.labelPosition = .bottom
                          xAxis.drawLabelsEnabled = true
                          xAxis.drawLimitLinesBehindDataEnabled = true
                          self.chartView.xAxis.granularity = 1
       // self.chartView.setVisibleXRangeMaximum(10)
        self.segmentCntrl.selectedSegmentIndex = 1
        if stockSymStr != "" {
        callGetStockService { (stockSymStr) in
            self.loadUI()
            self.callSearchService { (true) in
            }
        }
        }
        
        // Do any additional setup after loading the view.
    }
    
  
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBuyStock(_ sender: Any) {
        let buyStockView = self.storyboard?.instantiateViewController(withIdentifier: "BuyStock") as! BuyStockView
                      let navi = UINavigationController(rootViewController: buyStockView)
                        buyStockView.buyStock = self.stockDt
                        buyStockView.stNm = self.stockName
                      // buyStockView.stockSymStr = symName
                      // buyStockView.stockName = stockData[indexPath.row].name!
                      self.present(navi, animated: true, completion: nil)
    }
    
    
   /* @IBAction func onSellStock(_ sender: Any) {
        let sellStockView = self.storyboard?.instantiateViewController(withIdentifier: "SellStock") as! SellStockView
        let navi = UINavigationController(rootViewController: sellStockView)
        sellStockView.sellStock = self.stockDt
        sellStockView.stockNm = self.stockName
        // buyStockView.stockSymStr = symName
        // buyStockView.stockName = stockData[indexPath.row].name!
        self.present(navi, animated: true, completion: nil)
    }*/
    
 
    private func callGetStockService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
     
        getStockDetails(funcName: "GLOBAL_QUOTE", symbol:stockSymStr) { (jsonDict) in
            
               let decoder = JSONDecoder()
            
               do{
                   //let arr = Array<Any>(jsonDict!)
                   //print(arr)
                StockDetailsView.stockResponse = try decoder.decode(StockDetail.self, from: jsonDict!)
                if (StockDetailsView.stockResponse?.globalQuote) != nil {
                self.stockDt = ((StockDetailsView.stockResponse?.globalQuote!)!)
                // self.loadUI()
                    completion("success")
               // self.callSearchService { (true) in
                //}
                    
            }
                else {
                   // self.showAlert(message: "No Stock is selected")
                }
                       
               }catch{
                   print(error)
               }
           }
        
          
          }
    
    func loadUI(){
       // print("The stockdata",self.stockDt)
        self.stockNm.text = (self.stockName)
        self.stockSym.text = (self.stockDt.symbol)
        self.stockPrice.text = (self.stockDt.price)
        self.volume.text = (self.stockDt.volume)
        self.chPer.text = (self.stockDt.chPercent)
       /* for values in self.userStocks {
           // print(values.prdSym,self.stockSym.text)
            if values.prdSym == self.stockSym.text {
                print("the product is purchased")
                self.sellBtn.isHidden = false
                break
            }
            else {
                self.sellBtn.isHidden = true
            }
        }*/
        
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry.y)
    }
    
    @IBAction func onSelectInterval(_ sender: Any) {
        self.stockIntervalDetails = [:]
        self.chartView.isHidden = true
        self.chartView.zoom(scaleX: 0.0, scaleY: 0.0, x: 0, y: 0)
        switch self.segmentCntrl.selectedSegmentIndex
           {
           case 0:
            self.monthInterval = 1
           self.funcName = "TIME_SERIES_INTRADAY"
           self.interval = "30min"
           getIntervalStockDetails(funcName: self.funcName, symbol: self.stockSym.text!, interval: self.interval) { (jsonDict) in
             let decoder = JSONDecoder()
            
            do{
                StockDetailsView.graphResponse = try decoder.decode(StockIntervalResponse.self, from: jsonDict!)
                self.stockIntervalDetails = StockDetailsView.graphResponse!.timeSeriesMins ?? [:]
                self.chartView.zoom(scaleX: 10.0, scaleY: 1.0, x: 0, y: 0)
                self.formGraph()
            }catch {
                print(error)
            }
            
            }
           case 1:
            self.funcName = "TIME_SERIES_DAILY"
           self.monthInterval = 1
            getStockDetails(funcName: funcName, symbol:self.stockSym.text!) { (jsonDict) in
             let decoder = JSONDecoder()
            
            do{
                StockDetailsView.graphResponse = try decoder.decode(StockIntervalResponse.self, from: jsonDict!)
                 self.stockIntervalDetails = StockDetailsView.graphResponse!.timeSeriesDay ?? [:]
                self.chartView.zoom(scaleX: 10.0, scaleY: 1.0, x: 0, y: 0)
                self.formGraph()
            }catch {
                print(error)
            }
            
            }
            case 2:
            self.monthInterval = 1
            self.funcName = "TIME_SERIES_MONTHLY"
             getStockDetails(funcName: funcName, symbol:self.stockSym.text!) { (jsonDict) in
              let decoder = JSONDecoder()
             
             do{
                 StockDetailsView.graphResponse = try decoder.decode(StockIntervalResponse.self, from: jsonDict!)
                  self.stockIntervalDetails = StockDetailsView.graphResponse!.timeSeriesMonth ?? [:]
                self.chartView.zoom(scaleX: 13.0, scaleY: 1.0, x: 0, y: 0)
                 self.formGraph()
             }catch {
                 print(error)
             }
             
             }
            case 3:
                 self.funcName = "TIME_SERIES_MONTHLY"
                 self.monthInterval = 3
                 getStockDetails(funcName: funcName, symbol:self.stockSym.text!) { (jsonDict) in
                  let decoder = JSONDecoder()
                 
                 do{
                     StockDetailsView.graphResponse = try decoder.decode(StockIntervalResponse.self, from: jsonDict!)
                      self.stockIntervalDetails = StockDetailsView.graphResponse!.timeSeriesMonth ?? [:]
                    self.chartView.zoom(scaleX: 12.0, scaleY: 1.0, x: 0, y: 0)
                     self.formGraph()
                 }catch {
                     print(error)
                 }
                 
                 }
            case 4:
                  self.funcName = "TIME_SERIES_MONTHLY"
                  self.monthInterval = 6
                  getStockDetails(funcName: funcName, symbol:self.stockSym.text!) { (jsonDict) in
                   let decoder = JSONDecoder()
                  
                  do{
                      StockDetailsView.graphResponse = try decoder.decode(StockIntervalResponse.self, from: jsonDict!)
                       self.stockIntervalDetails = StockDetailsView.graphResponse!.timeSeriesMonth ?? [:]
                     self.chartView.zoom(scaleX: 13.0, scaleY: 1.0, x: 0, y: 0)
                      self.formGraph()
                  }catch {
                      print(error)
                  }
                  
                  }
           
           default:
               break
           }
       
       }
    
  
    
    func formGraph() {
        DispatchQueue.main.async(execute: {
            indicator.stopAnimating()
        })
        self.chartView.isHidden = false
        xAxisLabel = []
        if self.stockIntervalDetails.count == 0 {
           // self.showAlert(message: "No Chart data available")
            self.chartView.isHidden = true
        }
        else {
       let newArr = Array(self.stockIntervalDetails)
       let sortedStocks = newArr.sorted {($0.key).compare(($1.key), options: .numeric) == .orderedDescending}
       var dataEntries: [ChartDataEntry] = []
       // print(sortedStocks[0].value.the4Close)
            var j = 0
            for i in 0..<self.stockIntervalDetails.count where i%monthInterval == 0{
                self.xAxisLabel.append(self.dateFormatter(dtString: sortedStocks[i].key))
               // print (xAxisLabel)
                let dataEntry = ChartDataEntry(x: Double(j) , y: Double(sortedStocks[i].value.the4Close)!)
                    dataEntries.append(dataEntry)
                j+=1
                
            }
          //  print(dataEntries)
          //  print(xAxisLabel)
        self.xAxis.granularity = 1.0
        self.chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.xAxisLabel)
        let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "ClosePrice")
                       lineChartDataSet.circleColors = [UIColor.orange]
                       lineChartDataSet.circleRadius = 2.0
                       lineChartDataSet.drawValuesEnabled = false
                       lineChartDataSet.drawFilledEnabled = true
                       lineChartDataSet.colors = [UIColor.yellow]
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
       // self.chartView.setVisibleXRangeMaximum(10.0)
        self.chartView.data?.setValueTextColor(NSUIColor.white)
        self.chartView.data = lineChartData
        }
  
    }
   
    
    private func callSearchService (completion: @escaping (Bool) -> Void) {
        getStockDetails(funcName: funcName, symbol:stockSymStr) { (jsonDict) in
            let decoder = JSONDecoder()
         DispatchQueue.main.async(execute: {
             indicator.stopAnimating()
         })
            do{
                StockDetailsView.graphResponse = try decoder.decode(StockIntervalResponse.self, from: jsonDict!)
                self.stockIntervalDetails = StockDetailsView.graphResponse!.timeSeriesDay ?? [:]
                self.formGraph()
             
            }catch{
                print(error)
            }
        }
       
       }
    
       
    func dateFormatter(dtString:String) -> String{
        var newDate : String!
        switch self.funcName {
        case "TIME_SERIES_DAILY","TIME_SERIES_MONTHLY":
        
            let dtFormatter = DateFormatter()
            dtFormatter.dateFormat = "yyyy-MM-dd "
            let dt = dtFormatter.date(from: dtString)
               let dtFormatter1 = DateFormatter()
               dtFormatter1.dateFormat = "MMM dd"
               newDate = dtFormatter1.string(from: dt!)
            //print("the date",newDate)
            
        case "TIME_SERIES_INTRADAY":
            let dtFormatter = DateFormatter()
            dtFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dt = dtFormatter.date(from: dtString)
               let dtFormatter1 = DateFormatter()
               dtFormatter1.dateFormat = "HH:mm"
               newDate = dtFormatter1.string(from: dt!)
          //  print("the date",newDate)
       
        default:
            break;
        }
        return newDate
     
      
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



