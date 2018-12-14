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
    
    static var isSQLite = true
    
    static var encryptDic: [String:String] = [:]
    static var decryptDic: [String:String] = [:]
    static var separator: Character = "/"
    
    static var missions: [Missiontype] = []
    
    static func initCipherAlgorithm() {
        let num = 120
        var temp: [Int:Int] = [:]
        var primeNumber: [Int] = []
        
        // make prime number
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
        encryptDic["@"] = "&"
        encryptDic["."] = "+"
        
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
    
    static func makeAgentEntity(_ context: NSManagedObjectContext, name: String, country: String, mission: Missiontype, email: String) {
        let df = DateFormatter()
        df.dateFormat = "ddMMyyyy"
        
        let agent = AgentEntity(context: context)
        agent.name = name
        agent.country = country
        agent.mission = mission.rawValue
        agent.date = df.string(from: Date())
        agent.email = email
        
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
        agent.email = StoreUtils.encrypt(agent.email!)
    }
    
    static func encryptAgent(_ agent: Agent) -> Agent {
        var change = agent
        change.name = StoreUtils.encrypt(agent.name)
        change.date = StoreUtils.encrypt(agent.date).replacingOccurrences(of: "/", with: "")
        change.email = StoreUtils.encrypt(agent.email)
        return change
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
        agent.email = StoreUtils.decrypt(agent.email!)
    }
    
    static func decryptAgent(_ agent: Agent) -> Agent {
        var change = agent
        change.name = StoreUtils.decrypt(agent.name)
        var strDate = ""
        for str in agent.date {
            if strDate != "" {
                strDate.append(separator)
            }
            strDate.append(str)
        }
        change.date = StoreUtils.decrypt(strDate)
        change.email = StoreUtils.decrypt(agent.email)
        
        return change
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
    
    static func countryImage(_ code: String) -> URL? {
        switch code {
        case "kr":
            return URL(string: "https://images.unsplash.com/photo-1506480932912-dbbe35e3e516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2550&q=80")
        case "jp":
            return URL(string: "https://images.unsplash.com/photo-1526481280693-3bfa7568e0f3?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2551&q=80")
        case "ca":
            return URL(string: "https://images.unsplash.com/photo-1505767595906-d27f4cf630a6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2550&q=80")
        case "cn":
            return URL(string: "https://images.unsplash.com/photo-1500297726361-1715d90aec00?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2547&q=80")
        case "br":
            return URL(string: "https://images.unsplash.com/photo-1518639192441-8fce0a366e2e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2551&q=80")
        case "us":
            return URL(string: "https://images.unsplash.com/photo-1436124026657-36828b43c7ce?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2550&q=80")
        case "in":
            return URL(string: "https://images.unsplash.com/photo-1524492412937-b28074a5d7da?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2551&q=80")
        case "au":
            return URL(string: "https://images.unsplash.com/photo-1524293581917-878a6d017c71?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2550&q=80")
        case "fr":
            return URL(string: "https://images.unsplash.com/photo-1431274172761-fca41d930114?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2550&q=80")
        default:
            return nil
        }
    }
    
}

enum Missiontype: String {
    case I = "I"
    case R = "R"
    case P = "P"
}
