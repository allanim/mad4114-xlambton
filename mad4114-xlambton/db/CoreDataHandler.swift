//
//  CoreDataManager.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-13.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler {
    
    static func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // drop agent entity
    static func dropAgent(context: NSManagedObjectContext) {
        let dropAgents: [AgentEntity] = try! context.fetch(AgentEntity.fetchRequest())
        if dropAgents.count > 0 {
            for dropAgent in dropAgents {
                context.delete(dropAgent)
            }
        }
    }
    
    // add temp agent entity
    static func initAgent(context: NSManagedObjectContext) {
        let agents = try! context.count(for: AgentEntity.fetchRequest())
        if agents == 0 {
            StoreUtils.makeAgentEntity(context, name: "Seongyeob Im", country: "kr", mission: .I, email: "allan@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Taro Suzuki", country: "jp", mission: .P, email: "suzuki@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Zhangwei Chen", country: "cn", mission: .R, email: "chen@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Maple Smith", country: "ca", mission: .I, email: "smith@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Marcos Bittencourt", country: "br", mission: .P, email: "marcos@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Alex Wilson", country: "us", mission: .R, email: "alex@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Mitali Patel", country: "in", mission: .I, email: "mitali@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Noah Jones", country: "au", mission: .P, email: "noah@vogle.com")
            StoreUtils.makeAgentEntity(context, name: "Dior Martin", country: "fr", mission: .R, email: "dior@vogle.com")
            saveContext(context)
        }
    }
    
    // drop country entity
    static func dropCountry(context: NSManagedObjectContext) {
        let dropCountries: [CountryEntity] = try! context.fetch(CountryEntity.fetchRequest())
        if dropCountries.count > 0 {
            for dropCountry in dropCountries {
                context.delete(dropCountry)
            }
        }
    }
    
    // add country entity
    static func initCountry(context: NSManagedObjectContext) {
        let countries = try! context.count(for: CountryEntity.fetchRequest())
        if countries == 0 {
            StoreUtils.makeCountryEntity(context, code: "kr", name: "Korea", latitude: 37.5652894, longitude: 126.8494676)
            StoreUtils.makeCountryEntity(context, code: "jp", name: "Japan", latitude: 35.6735408, longitude: 139.5703055)
            StoreUtils.makeCountryEntity(context, code: "ca", name: "Canada", latitude: 45.2487863, longitude: -76.3606642)
            StoreUtils.makeCountryEntity(context, code: "cn", name: "China", latitude: 39.9390731, longitude: 116.1172817)
            StoreUtils.makeCountryEntity(context, code: "br", name: "Brazil", latitude: -22.4736177, longitude: -53.1278237)
            StoreUtils.makeCountryEntity(context, code: "us", name: "USA", latitude: 38.8935559, longitude: -77.0846815)
            StoreUtils.makeCountryEntity(context, code: "in", name: "India", latitude: 28.5272181, longitude: 77.0689009)
            StoreUtils.makeCountryEntity(context, code: "au", name: "Australia", latitude: -35.2813043, longitude: 149.1204446)
            StoreUtils.makeCountryEntity(context, code: "fr", name: "France", latitude: 48.8588377, longitude: 2.2770205)
            saveContext(context)
        }
    }
    
    // get Agents
    static func getAgents(_ context: NSManagedObjectContext) -> [Agent] {
        let list = try! context.fetch(AgentEntity.fetchRequest()).sorted(by: { $0.name! < $1.name! })
        
        var result: [Agent] = []
        for entity in list {
            result.append(Agent(entity: entity))
        }
        return result
    }
    
    // get Countries
    static func getCountries(_ context: NSManagedObjectContext) -> [CountryEntity] {
        return try! context.fetch(CountryEntity.fetchRequest()).sorted(by: { $0.name! < $1.name! })
    }

}
