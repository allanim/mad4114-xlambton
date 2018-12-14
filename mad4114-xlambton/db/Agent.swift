//
//  Agent.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-13.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import Foundation

struct Agent {
    let id: Int
    var name: String
    var country: String
    var mission: String
    var date: String
    var email: String
    
    let entity: AgentEntity?
    
    func getEntity() -> AgentEntity? {
        if entity != nil {
            entity?.name = self.name
            entity?.country = self.country
            entity?.mission = self.mission
            entity?.date = self.date
            entity?.email = self.email
        }
        return entity
    }
    
    init(entity: AgentEntity) {
        self.id = 0
        self.name = entity.name!
        self.country = entity.country!
        self.mission = entity.mission!
        self.date = entity.date!
        self.email = entity.email!
        self.entity = entity
    }
    
    init(id: Int, name: String, country: String, mission: Missiontype, date: String, email: String) {
        self.id = id
        self.name = name
        self.country = country
        self.mission = mission.rawValue
        self.date = date
        self.email = email
        self.entity = nil
    }
    
}
