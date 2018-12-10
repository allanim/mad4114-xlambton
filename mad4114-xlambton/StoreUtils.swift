//
//  StoreUtils.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-09.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import Foundation
import CoreData

struct StoreUtils {
    
    static var encryptDic: [String:String] = [:]
    static var decryptDic: [String:String] = [:]
    static var separator: Character = "/"
    
    static var missions: [Missiontype] = []
    
    static func initCipherAlgorithm() {
        let num = 120
        var temp: [Int:Int] = [:]
        var primeNumber: [Int] = []
        for i in 2...num {
            temp[i] = i
        }
        for i in 2...Int(sqrt(Double(num))) {
            if temp[i] == 0 {
                continue
            }
            for j in stride(from: i+i, to: num, by: i) {
                temp[j] = 0;
            }
        }
        for i in 2...num {
            if let num = temp[i] {
                if (num != 0) {
                    primeNumber.append(num)
                }
            }
        }
        
        // alpherbet
        for i in 65...90 {
            if let str = UnicodeScalar(i) {
                encryptDic[str.description] = String(primeNumber[i - 65])
            }
        }
        for i in 97...122 {
            if let str = UnicodeScalar(i) {
                encryptDic[str.description] = String(primeNumber[i - 97])
            }
        }
        
        // number
        for i in 1...9 {
            encryptDic[String(i)] = UnicodeScalar(65 + (i - 1) * 2)?.description
        }
        
        encryptDic["0"] = "S"
        encryptDic[" "] = "#"
        
        // reverse
        for (key, value) in encryptDic {
            let tmp: UInt32 = Unicode.Scalar(key)?.value ?? 0;
            if tmp < UInt32(97) || tmp > UInt32(122) {
                decryptDic[value] = key
            }
        }
        
    }
    
    static func encrypt(_ str: String) -> String {
        var result = ""
        for char in str {
            if result != "" {
                result.append(separator)
            }
            guard let strCipher = encryptDic[String(char)] else {
                return String(char)
            }
            result.append(strCipher)
        }
        return result
    }
    
    static func decrypt(_ str: String) -> String {
        var result = ""
        for char in str.split(separator: separator) {
            guard let strCipher = decryptDic[String(char)] else {
                return String(char)
            }
            result.append(strCipher)
        }
        return result
    }
    
    static func initMissions() {
        missions.append(Missiontype.I)
        missions.append(Missiontype.P)
        missions.append(Missiontype.R)
    }
    
    static func makeAgentEntity(_ context: NSManagedObjectContext, name: String, country: String, mission: Missiontype) {
        let df = DateFormatter()
        df.dateFormat = "ddMMyyyy"
        
        let agent = AgentEntity(context: context)
        agent.name = name
        agent.country = country
        agent.mission = mission.rawValue
        agent.date = df.string(from: Date())
        
        encryptAgent(agent)
    }
    
    static func makeCountryEntity(_ context: NSManagedObjectContext, code: String, name: String, latitude: Double, longitude: Double) {
        let country = CountryEntity(context: context)
        country.code = code
        country.name = name
        country.latitude = latitude
        country.longitude = longitude
    }
    
    static func encryptAgent(_ agent: AgentEntity) {
        agent.name = StoreUtils.encrypt(agent.name!)
        agent.date = StoreUtils.encrypt(agent.date!).replacingOccurrences(of: "/", with: "")
    }
    
    static func decryptAgent(_ agent: AgentEntity) {
        agent.name = StoreUtils.decrypt(agent.name!)
        var strDate = ""
        for str in agent.date! {
            if strDate != "" {
                strDate.append(separator)
            }
            strDate.append(str)
        }
        agent.date = StoreUtils.decrypt(strDate)
    }
    
    static func rowMissions(_ check: Missiontype) -> Int {
        var row = 0
        for mission in missions {
            if mission == check {
                return row
            } else {
                row += 1
            }
        }
        
        return row
    }
    
}

enum Missiontype: String {
    case I = "I"
    case R = "R"
    case P = "P"
}
