//
//  DBManager.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-13.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteManager {
    var db: OpaquePointer?
    
    
    init(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("xlambton.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Agent (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, country TEXT, mission TEXT, email TEXT, date DATETIME DEFAULT (DATETIME('now','localtime')))", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
    }
    
    func save(_ agent: Agent) -> Bool {
        let id = agent.id
        let name = agent.name
        let country = agent.country
        let mission = agent.mission
        let email = agent.email
        let date = agent.date
        
        if name.isEmpty {
            return false
        }
        
        // New Agent
        if id == 0 {
            var saveNew: OpaquePointer?
            let query = "INSERT INTO Agent (name, country, mission, email, date) VALUES ('\(name)', '\(country)', '\(mission)', '\(email)', '\(date)')"
            
            if sqlite3_prepare(db, query, -1, &saveNew, nil) == SQLITE_OK {
                if sqlite3_step(saveNew) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting Agent: \(errmsg)")
                    return false
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return false
            }
            
            sqlite3_finalize(saveNew)
            
        }
        // Update a Agent
        else {
            var updateStatement: OpaquePointer?
            let query = "UPDATE Agent SET name = '\(name)', country = '\(country)', mission = '\(mission)', email = '\(email)', date = '\(date)' WHERE id = \(id);"
            
            if sqlite3_prepare_v2(db, query, -1, &updateStatement, nil) == SQLITE_OK {
                if sqlite3_step(updateStatement) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure update Agent: \(errmsg)")
                    return false
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing update: \(errmsg)")
                return false
            }
            sqlite3_finalize(updateStatement)
        }
        
        return true
    }
    
    func delete (_ agent: Agent) {
        var deleteStatement: OpaquePointer?
        let query = "DELETE FROM Agent WHERE id = \(agent.id);"
        
        if sqlite3_prepare_v2(db, query, -1, &deleteStatement, nil) == SQLITE_OK {
            if sqlite3_step(deleteStatement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure delete Agent: \(errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing update: \(errmsg)")
        }
        
        sqlite3_finalize(deleteStatement)
    }
    
    func getAgents() -> [Agent] {
        var agents: [Agent] = []
        
        var readStatement: OpaquePointer?
        let query = "SELECT id, name, country, mission, email, date FROM Agent"
        
        if sqlite3_prepare(db, query, -1, &readStatement, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        while(sqlite3_step(readStatement) == SQLITE_ROW) {
            let id = sqlite3_column_int(readStatement, 0)
            let name = String(cString: sqlite3_column_text(readStatement, 1))
            let country = String(cString: sqlite3_column_text(readStatement, 2))
            let mission = String(cString: sqlite3_column_text(readStatement, 3))
            let email = String(cString: sqlite3_column_text(readStatement, 4))
            let date = String(cString: sqlite3_column_text(readStatement, 5))
            
            let agent = Agent(id: Int(id), name: name, country: country, mission: Missiontype(rawValue: mission)!, date: date, email: email)
            
            agents.append(agent)
        }
        sqlite3_finalize(readStatement)
        return agents
    }
    
}
