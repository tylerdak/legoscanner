//
//  SetInfoTableViewController.swift
//  RealtimeNumberReader
//
//  Created by Tyler Dakin on 12/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import ProgressHUD


var database: [String : [String : String]] = [:]
var lastQueriedKey: String = "INVALIDKEY"

class SetInfoTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var currency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
    var currentPrice = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: currency, style: .plain, target: self, action: #selector(userChangingCurrency))
        tableView.isScrollEnabled = false
    }
    let presenting = ["name", "year","num_parts"]
    let presentableKeyNames = ["Set Name", "Year Released", "Number of Parts"]
    let expectedParts: (Double) -> Int = { (price) in
        return Int((8.3049 * price) + 24.333)
    }
    
    var choices = ["USD", "CAD", "AUD", "BGN", "BRL", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR", "ISK", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN", "RON", "RUB", "SEK", "SGD", "THB", "TRY", "ZAR"]
    var symbols: [String : String] = ["CAD":"$","HKD":"$","ISK":"kr","PHP":"₱","DKK":"kr","HUF":"ft","CZK":"Kč","GBP":"£","RON":"lei","SEK":"kr","IDR":"Rp","INR":"₹","BRL":"R$","RUB":"₽","HRK":"kn","JPY":"¥","THB":"฿","CHF":"CHF","EUR":"€","MYR":"RM","BGN":"лв","TRY":"₺","CNY":"¥","NOK":"kr","NZD":"$","ZAR":"R","USD":"$","MXN":"$","SGD":"$","AUD":"$","ILS":"₪","KRW":"₩","PLN":"zł"]
    var pickerView = UIPickerView()
    var typeValue = String()
    
    var exchangeRate = 1
    
    
    let priceByPartsScore: (Int,Int) -> Double = { (calculated, expected) in
        let first = (((Double(calculated) - Double(expected))/Double(expected)) * 1000.0)
        let second = first.rounded()
        return second/10.0
    }
    
    let evaluationString: (Double) -> String = { (score) in
        if score < -12.5 {
            return "Poor Price"
        }
        else if score > 12.5 {
            return "Great Price"
        }
        else {
            return "Fair Price"
        }
    }
    
    let evaluationColor: (Double) -> UIColor = { (score) in
        if score < -12.5 {
            return .systemRed
        }
        else if score > 12.5 {
            return .systemGreen
        }
        else {
            return .systemYellow
        }
    }
    
    var priceEntered: Bool = false
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if database.isEmpty || lastQueriedKey == "INVALIDKEY" {
            return 1
        }
        else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if database.isEmpty || lastQueriedKey == "INVALIDKEY" {
            switch section {
            case 0: //Set Info
                return 1
            case 1: //Amazon Info
                return 0
            case 2: //Store Info
                return 0
            default:
                return 0
            }
        }
        else {
            switch section {
            case 0: //Set Info
                return presenting.count
            case 1: //Amazon Info
                return 0
            case 2: //Store Info
                if priceEntered {
                    return 5
                }
                else {
                    return 1
                }
            default:
                return 1
            }
            
            
            
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if database.isEmpty || lastQueriedKey == "INVALIDKEY" {
            return nil
        }
        else {
            switch section {
            case 0:
                return "Set Info"
            case 1:
                return nil
            case 2:
                return "Store Info"
            default:
                return nil
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setInfo", for: indexPath)
        
        if lastQueriedKey == "INVALIDKEY" {
            cell.textLabel?.text = "Please scan a LEGO set first!"
            cell.detailTextLabel?.text = ""
        }
        else {
            switch indexPath.section {
            case 0: //Set Info
                let thisKey = presenting[indexPath.row]
                let keyName = presentableKeyNames[indexPath.row]
                
                let result = database[lastQueriedKey]![thisKey]!
                
                cell.textLabel?.text = "\(keyName):"
                cell.detailTextLabel?.text = "\(result)"
            case 1: //Amazon Info
                cell.textLabel?.text = "Amazon Info"
                cell.detailTextLabel?.text = "Amazon Detail"
            case 2: //Store Info
                cell.textLabel?.text = "Add Store Price +"
                cell.detailTextLabel?.text = ""
                cell.textLabel?.textColor = .systemBlue
                cell.textLabel?.textAlignment = .center
            default:
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = ""
            }
            
            
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if tableView.cellForRow(at: indexPath)?.textLabel?.text == "Add Store Price +" || tableView.cellForRow(at: indexPath)?.textLabel?.text == "Change Store Price" {
                addStorePrice()
            }
        }
        
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: false)
        
    }
    
    func addStorePrice() {
        let alert = UIAlertController(title: "Input the price of the set for the store where you found it:", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
        }
        
        let ok = UIAlertAction(title: "Done", style: .default) { (action) in
            if let text = alert.textFields![0].text {
                if let enteredPrice = (Double(text)) {
                    if self.tableView.numberOfRows(inSection: 2) < 5 {
                        //Anything that should only be done upon the first price entry goes here.
                        self.priceEntered = true
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: [IndexPath(row: 1, section: 2),IndexPath(row: 2, section: 2),IndexPath(row: 3, section: 2),IndexPath(row: 4,section: 2)], with: .left)
                        self.tableView.endUpdates()
                    }
                    
                    self.updateStorePriceDataWith(price: enteredPrice)
                    
                    self.currentPrice = enteredPrice
                    
                }
                else {
                    ProgressHUD.showError("Please enter a valid number!")
                }
            }
            else {
                ProgressHUD.showError("Please enter a valid number!")
            }
            
        
        }
        
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
    
    //MARK - PickerView
        
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return choices[row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeValue = choices[row]
    }
    
    @objc func userChangingCurrency() {
        let alert = UIAlertController(title: "Currency", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        
        
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alert.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            
            print("You selected " + self.typeValue )
        
            self.updateCurrencyTo(self.typeValue)
            
            if self.tableView.numberOfSections == 3 && self.tableView.numberOfRows(inSection: 2) == 5 {
                self.updateStorePriceDataWith(price: self.currentPrice)
            }
            
        }))
        typeValue = choices[0]
        self.present(alert,animated: true, completion: nil)
    }
    
    func updateCurrencyTo(_ new: String) {
        currency = new
        navigationItem.rightBarButtonItem?.title = new
        UserDefaults.standard.set(new, forKey: "currency")
    }
    
    func updateStorePriceDataWith(price enteredPrice: Double) {
        let priceCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2))
        let expectedPartsCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 2))
        let scoreCell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 2))
        let interpretationCell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 2))
        let changePrice = self.tableView.cellForRow(at: IndexPath(row: 4, section: 2))
        
        priceCell?.textLabel?.textAlignment = .left
        priceCell?.textLabel?.text = "Store Price:"
        priceCell?.textLabel?.textColor = .label
        priceCell?.detailTextLabel?.text = "Calculating..."
        
        
        expectedPartsCell?.textLabel?.textColor = .label
        expectedPartsCell?.textLabel?.text = "Expected Number of Parts:"
        expectedPartsCell?.detailTextLabel?.text = "Calculating..."
        
        scoreCell?.textLabel?.textColor = .label
        scoreCell?.textLabel?.text = "Price to Parts Score:"
        scoreCell?.detailTextLabel?.text = "Calculating..."
        
        interpretationCell?.textLabel?.text = "Evaluation:"
        interpretationCell?.textLabel?.textColor = .label
        interpretationCell?.detailTextLabel?.text = "Calculating..."
        
        getExchangeRates { (response) in
            if let rate = Double(response["rates"][self.currency].stringValue) {
                priceCell?.detailTextLabel?.text = String(format: "\(self.symbols[self.currency] ?? "$")%.2f", ((enteredPrice * 100).rounded()) / 100)
                
                expectedPartsCell?.detailTextLabel?.text = "\(self.expectedParts(enteredPrice / rate))"
                
                let score = self.priceByPartsScore(Int(database[lastQueriedKey]!["num_parts"]!)!,self.expectedParts(enteredPrice / rate))
                
                scoreCell?.detailTextLabel?.text = "\(score)%"
                
                interpretationCell?.detailTextLabel?.text = self.evaluationString(score)
                interpretationCell?.detailTextLabel?.textColor = self.evaluationColor(score)
            }
            else {
                priceCell?.detailTextLabel?.text = "ERROR"
                
                expectedPartsCell?.detailTextLabel?.text = "Exchange rates not available."
                expectedPartsCell?.textLabel?.text = ""
                
                scoreCell?.detailTextLabel?.text = "Please check your connection."
                scoreCell?.textLabel?.text = ""
                
                interpretationCell?.detailTextLabel?.text = "Then reenter the price."
                interpretationCell?.textLabel?.text = ""
                interpretationCell?.detailTextLabel?.textColor = .label
            }
        }
        
        
        
        
        changePrice?.textLabel?.text = "Change Store Price"
        changePrice?.textLabel?.textColor = .systemBlue
        changePrice?.detailTextLabel?.text = ""
        changePrice?.textLabel?.textAlignment = .center
    }
}
