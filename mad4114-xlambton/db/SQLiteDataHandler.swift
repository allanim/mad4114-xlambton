//
//  SQLiteDataHandler.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-14.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import Foundation

class SQLiteDatahandler {
    
    static var manager = SQLiteManager()
    
    // drop agent entity
    static func dropAgent() {
        let dropAgents: [Agent] = manager.getAgents()
        if dropAgents.count > 0 {
            for dropAgent in dropAgents {
                manager.delete(dropAgent)
            }
        }
    }
    
    // add temp agent entity
    static func initAgent() {
        let agents = manager.getAgents()
        if agents.count == 0 {
            let df = DateFormatter()
            df.dateFormat = "ddMMyyyy"
            let now = df.string(from: Date())
            
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Seongyeob Im", country: "kr", mission: .I, date: now, email: "allan@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Taro Suzuki", country: "jp", mission: .P, date: now, email: "suzuki@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Zhangwei Chen", country: "cn", mission: .R, date: now, email: "chen@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Maple Smith", country: "ca", mission: .I, date: now, email: "smith@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Marcos Bittencourt", country: "br", mission: .P, date: now, email: "marcos@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Alex Wilson", country: "us", mission: .R, date: now, email: "alex@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Mitali Patel", country: "in", mission: .I, date: now, email: "mitali@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Noah Jones", country: "au", mission: .P, date: now, email: "noah@vogle.com")))
            var _ = manager.save(StoreUtils.encryptAgent(Agent(id: 0, name: "Dior Martin", country: "fr", mission: .R, date: now, email: "dior@vogle.com")))
        }
    }
    
    
    // get Agents
    static func getAgents() -> [Agent] {
        return manager.getAgents().sorted(by: { $0.id > $1.id })
    }
    
    static func saveAent(_ agent: Agent) -> Bool {
        return manager.save(agent)
    }

}
