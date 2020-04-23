//
//  SignUpView.swift
//  VirtualStock
//
//  Created by Hariharan Kuppuraj on 3/26/20.
//  Copyright © 2020 Hariharan Kuppuraj. All rights reserved.
//

import UIKit
import Alamofire

class SignUpView: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var unameTxt: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var mailTxt: UITextField!
    static var signupResponse : LoginResponse?
    var responseString : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndicator()
        self.unameTxt.delegate = self
        self.pwdText.delegate = self
        self.mailTxt.delegate = self
        self.unameTxt.attributedPlaceholder = NSAttributedString(string: "Username",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.mailTxt.attributedPlaceholder = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        self.pwdText.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    private func callSignupService (completion: @escaping (String) -> Void) {
        indicator.startAnimating()
        let url = "user/register"
        let parameters: Parameters = ["name":unameTxt.text!,"email":mailTxt.text!,"password":pwdText.text!]
        loginService(url1: url, parameters: parameters) { (jsonDict) in
         
         let decoder = JSONDecoder()
         
            do{
                SignUpView.signupResponse = try decoder.decode(LoginResponse.self, from: jsonDict!)
                
                self.responseString = SignUpView.signupResponse?.response
                print("the response string is",self.responseString)
                DispatchQueue.main.async(execute: {
                    indicator.stopAnimating()
                })
                if SignUpView.signupResponse?.success == true {
                   
                    completion(self.responseString)
                    
                }
                else {
                 //   self.showAlert(message: self.responseString)
                }
      
                    
            }catch{
                print(error)
            }
        }
       
       }
    
    @IBAction func onSignUp(_ sender: Any) {
        callSignupService { (responseString) in
            
            userDefaults.set(true, forKey: "isLogged")
            
            let alertController = UIAlertController(title: "SignUp", message:
                      responseString, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                 UIAlertAction in
                if #available(iOS 13.0, *) {
                    sceneDelegate.createMainView()
                } else {
                    appDelegate.createMainView()
                }
             /*   let dashboardView = self.storyboard?.instantiateViewController(identifier: "dashboard") as! DashboardView
                 let navi = UINavigationController(rootViewController: dashboardView)
                 self.present(navi, animated: true, completion: nil)*/
             }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
          
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
