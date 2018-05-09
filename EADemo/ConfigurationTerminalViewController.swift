//
//  ConfigurationTerminalViewController.swift
//  EADemo
//
//  Created by Farhad Rismanchian on 10/12/16.
//  Licence MIT
//


import UIKit
import ExternalAccessory

class ConfigurationTerminalViewController: UIViewController {
    
    enum commandTypes {
        case            string
        case            hexString
    }

    var sessionController:                              SessionController!
    var accessory:                                      EAAccessory?
    
    @IBOutlet var stringCommandTextField:               UITextField!
    @IBOutlet var hexStringCommandTextField:            UITextField!
    @IBOutlet var responseTextView:                     UITextView!
    @IBOutlet var hexResponseTextView:                  UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionDataReceived), name: NSNotification.Name(rawValue: "BESessionDataReceivedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(accessoryDidDisconnect), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        sessionController = SessionController.sharedController
        
        accessory = sessionController._accessory
        _ = sessionController.openSession()
        
        
        stringCommandTextField.addTarget(nil, action:#selector(ConfigurationTerminalViewController.firstResponderAction(_:)), for:.editingDidEndOnExit)
        hexStringCommandTextField.addTarget(nil, action:#selector(ConfigurationTerminalViewController.firstResponderAction(_:)), for:.editingDidEndOnExit)


        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "BESessionDataReceivedNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        sessionController.closeSession()
        
        super.viewWillDisappear(animated)
    }

    
    func configureAccessoryWithString(string: String, stringType: commandTypes? = commandTypes.string ) {
        
        if stringType == commandTypes.string {
            let data = string.data(using: .utf8)
            sessionController.writeData(data: data!)
        } else {
            let data = string.dataFromHexadecimalString()
            sessionController.writeData(data: data!)
        }
    }
    
    // MARK: - Session Updates
    
    @objc func sessionDataReceived(notification: NSNotification) {
        
        if sessionController._dataAsString != nil {
            responseTextView.textStorage.beginEditing()
            responseTextView.textStorage.mutableString.append(sessionController._dataAsString!)
            responseTextView.textStorage.endEditing()
            responseTextView.scrollRangeToVisible(NSMakeRange(responseTextView.textStorage.length, 0))
            
            hexResponseTextView.textStorage.beginEditing()
            hexResponseTextView.textStorage.mutableString.append(sessionController._dataAsHexString!)
            hexResponseTextView.textStorage.endEditing()
            hexResponseTextView.scrollRangeToVisible(NSMakeRange(responseTextView.textStorage.length, 0))
        }
    }
    
    // MARK: - EAAccessory Disconnection
    
    @objc func accessoryDidDisconnect(notification: NSNotification) {
        
        if navigationController?.topViewController == self {
            let disconnectedAccessory = notification.userInfo![EAAccessoryKey]
            if (disconnectedAccessory as! EAAccessory).connectionID == accessory?.connectionID {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func firstResponderAction(_ sender: Any){
        stringCommandTextField.resignFirstResponder()
        hexStringCommandTextField.resignFirstResponder()

    }

    @IBAction func sendStringCommandButtonTapped(_ sender: Any) {
        configureAccessoryWithString(string: stringCommandTextField.text ?? "", stringType: commandTypes.string)
    }
    
    
    @IBAction func sendHexStringCommandButtonTapped(_ sender: Any) {
        configureAccessoryWithString(string: hexStringCommandTextField.text ?? "", stringType: commandTypes.hexString)
    }
    

    @IBAction func clearButtonTapped(_ sender: Any) {
        responseTextView.text =         ""
        hexResponseTextView.text =      ""
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
