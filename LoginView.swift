//
//  LoginView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/19/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import Alamofire

class LoginView: UIViewController,UITextFieldDelegate {
  
    @IBOutlet weak var unameTxt: UITextField!
    @IBOutlet weak var pwdTxt: UITextField!
    static var logResponse : LoginResponse?
    var userDetails : User?
    var responseString : String!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.unameTxt.delegate = self
        self.pwdTxt.delegate = self
        setIndicator()
      //  self.unameTxt.setValue(UIColor.white, forKeyPath: "placeholdeLabel.textColor")
        self.unameTxt.attributedPlaceholder = NSAttributedString(string: "Username",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.pwdTxt.attributedPlaceholder = NSAttributedString(string: "Password",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
       //userDefaults.set(false, forKey: "isLogged")
        print("islogged")
        if userDefaults.bool(forKey: "isLogged") {
            
        if #available(iOS 13.0, *) {
                sceneDelegate.createMainView()
        } else {
            appDelegate.createMainView()
        }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    private func callLoginService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
        let url = "user/userlogin"
        let parameters: Parameters = ["username":unameTxt.text!,"password":pwdTxt.text!]
        loginService(url1: url, parameters: parameters) { (jsonDict) in
         
         let decoder = JSONDecoder()
         
            do{
                LoginView.logResponse = try decoder.decode(LoginResponse.self, from: jsonDict!)
                
                self.responseString = LoginView.logResponse?.response
                DispatchQueue.main.async(execute: {
                    indicator.stopAnimating()
                })
                if LoginView.logResponse?.response == "valid" {
                   
                    self.userDetails = (LoginView.logResponse?.user)
                    userDetailVal = (LoginView.logResponse?.user)
                   let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(self.userDetails) {
                        userDefaults.set(encoded,forKey: "userVal")
                     //   userValArray = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String:Any] ?? [:]
                      //  self.userDetails =  User(data: userValArray)
                        
                        
                    }
                    
                    self.userDetails?.userId = LoginView.logResponse?.user?.userId
                    completion(self.responseString)
                    
                }
                else {
                    if #available(iOS 13.0, *) {
                        showAlert(message: self.responseString)
                    } else {
                        // Fallback on earlier versions
                    }
                }
                    
            }catch{
                print(error)
            }
        }
       
       }
    
    
    @IBAction func onLogin(_ sender: Any) {
        callLoginService { (responseString) in
            
            userDefaults.set(true, forKey: "isLogged")
            
            let alertController = UIAlertController(title: "Login", message:
                      responseString, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                 UIAlertAction in
              //  print("ok")
               if #available(iOS 13.0, *) {
                        sceneDelegate.createMainView()
                } else {
                    appDelegate.createMainView()
                }
             }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
          
        }
    }
    
   
}
extension UIViewController {
    
@objc func setIndicator(indicatorColor:UIColor? = nil){

       indicator.color = UIColor.white
       indicator.frame = CGRect(x: 0.0, y: 0.0, width: 75.0, height: 75.0)
       indicator.center = self.view.center
       self.view.addSubview(indicator)
       indicator.bringSubviewToFront(self.view)
   }
    
    
}
