//
//  CSVSort.swift
//  RealtimeNumberReader
//
//  Created by Tyler Dakin on 12/9/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation

var databaseKeys: [String] = []

func csv(data: String) -> [String : [String : String]] {
    var result: [String : [String : String]] = [:]
    let rows = data.components(separatedBy: "\n")
    var keys = [String]()
    for i in 0..<rows.count {
        if i == 0 {
            keys = rows[i].components(separatedBy: ",")
            keys.removeFirst()
        }
        else {
            let allComponents = rows[i].components(separatedBy: ",")
            let setID = allComponents.first
            let rest = allComponents[1..<allComponents.count]
            var inner: [String : String] = [:]
            for i in 0..<rest.count {
                inner[keys[i]] = rest[i+1]
            }
            result[setID!] = inner
            
        }
    }
    databaseKeys = keys
    return result
}

func readDataFromCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }


func cleanRows(file:String)->String{
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    
    //        cleanFile = cleanFile.replacingOccurrences(of: ";;", with: "")
    //        cleanFile = cleanFile.replacingOccurrences(of: ";\n", with: "")
    return cleanFile
}
