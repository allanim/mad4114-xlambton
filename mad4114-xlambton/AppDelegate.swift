//
//  AppDelegate.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-09.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Launch screen, Reference from https://github.com/ameli90/launch-screen-animation
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        // rootViewController from StoryBoard
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "first")
        self.window!.rootViewController = navigationController
        
        // logo mask
        navigationController.view.layer.mask = CALayer()
        navigationController.view.layer.mask?.contents = UIImage(named: "star.png")!.cgImage
        navigationController.view.layer.mask?.bounds = CGRect(x: 0, y: 0, width: 70, height: 70)
        navigationController.view.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        navigationController.view.layer.mask?.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)
        
        // logo mask background view
        let maskBgView = UIView(frame: navigationController.view.frame)
        maskBgView.backgroundColor = UIColor.white
        navigationController.view.addSubview(maskBgView)
        navigationController.view.bringSubviewToFront(maskBgView)
        
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self as? CAAnimationDelegate
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 3 //add delay of 3 second
        let initalBounds = NSValue(cgRect: (navigationController.view.layer.mask?.bounds)!)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut), CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = CAMediaTimingFillMode.forwards
        navigationController.view.layer.mask?.add(transformAnimation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.1,
                       delay: 1.35,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { maskBgView.alpha = 0.0 },
                       completion: { finished in maskBgView.removeFromSuperview()
        })
        
        // root view animation
        UIView.animate(withDuration: 0.25,
                       delay: 1.3,
                       options: [],
                       animations: {
                        self.window!.rootViewController!.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        },
                       completion: { finished in
                        UIView.animate(withDuration: 0.3,
                                       delay: 0.0,
                                       options: UIView.AnimationOptions.curveEaseInOut,
                                       animations: { self.window!.rootViewController!.view.transform = .identity },
                                       completion: nil)
        })
        
        
        // init cipher
        StoreUtils.initCipherAlgorithm()
        StoreUtils.initMissions()
        
        // core data
        let context = persistentContainer.viewContext
        
        // drop agent entity
//        let dropAgents: [AgentEntity] = try! context.fetch(AgentEntity.fetchRequest())
//        if dropAgents.count > 0 {
//            for dropAgent in dropAgents {
//                context.delete(dropAgent)
//            }
//        }
        
        // add temp agent entity
        let agents = try! context.count(for: AgentEntity.fetchRequest())
        if agents == 0 {
            StoreUtils.makeAgentEntity(context, name: "Seongyeob Im", country: "kr", mission: .I)
            StoreUtils.makeAgentEntity(context, name: "Suzuki Taro", country: "jp", mission: .P)
            StoreUtils.makeAgentEntity(context, name: "Zhangwei Chen", country: "cn", mission: .R)
            StoreUtils.makeAgentEntity(context, name: "Maple Smith", country: "ca", mission: .I)
            StoreUtils.makeAgentEntity(context, name: "Marcos Bittencourt", country: "br", mission: .P)
            StoreUtils.makeAgentEntity(context, name: "Alex Wilson", country: "us", mission: .R)
            StoreUtils.makeAgentEntity(context, name: "Mitali Patel", country: "in", mission: .I)
            StoreUtils.makeAgentEntity(context, name: "Noah Jones", country: "au", mission: .P)
            StoreUtils.makeAgentEntity(context, name: "Dior Martin", country: "fr", mission: .R)
            saveContext()
        }
        
        // drop country entity
        let dropCountries: [CountryEntity] = try! context.fetch(CountryEntity.fetchRequest())
        if dropCountries.count > 0 {
            for dropCountry in dropCountries {
                context.delete(dropCountry)
            }
        }
        
        // add country entity
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
            saveContext()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "mad4114_xlambton")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

