//
//  GetCurrencyExchangeRate.swift
//  RealtimeNumberReader
//
//  Created by Tyler Dakin on 12/23/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let requestURL = "https://api.exchangeratesapi.io/latest?base=USD"

func getExchangeRates(completion: @escaping (JSON) -> Void) {
    Alamofire.request(URL(string: requestURL)!, method: .get)
        .responseJSON { (response) in
            if response.result.isSuccess {
                let json: JSON = JSON(response.result.value!)
                completion(json)
            }
            else {
                completion(JSON(response.error ?? "No internet connection!"))
            }
    
        }
    
}
