//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/21/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData

//the app delegate is the object that gets notifications that concern the application as a whole. This is where iOS notifies the app that it has started up, for example.

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storyboard_1 = UIStoryboard(name: "Main", bundle: Bundle.main)
    // this is a closure, so it is done with lazy loading, not performed right away
    lazy var persistentContainer: NSPersistentContainer = {
        // closure
        // Instantiate a new NSPersistentContainer object with the name of the data model you created earlier, DataModel.
        // says, look for data model "DataModel" and put into container
        let container = NSPersistentContainer(name: "DataModel")
        // Tell it to loadPersistentStores(), which loads the data from the database into memory and sets up the Core Data stack.
        container.loadPersistentStores(completionHandler: { // loads persistent data into memory
            // closure executed after loading persistent data into memory, looks for error basically
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    // persistent data put into the managedObjectContext lazy var
    lazy var managedObjectContext: NSManagedObjectContext =
        persistentContainer.viewContext
    
    // this is a closure, so it is done with lazy loading, not performed right away
    lazy var persistentContainerNote: NSPersistentContainer = {
        // closure
        // Instantiate a new NSPersistentContainer object with the name of the data model you created earlier, DataModel.
        // says, look for data model "DataModel" and put into container
        let container = NSPersistentContainer(name: "TheNoteDataModel")
        // Tell it to loadPersistentStores(), which loads the data from the database into memory and sets up the Core Data stack.
        container.loadPersistentStores(completionHandler: { // loads persistent data into memory
            // closure executed after loading persistent data into memory, looks for error basically
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    // persistent data put into the managedObjectContext lazy var
    lazy var managedObjectContextNote: NSManagedObjectContext =
        persistentContainerNote.viewContext

    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // customize the navigation bar to black and text color to white
        customizeAppearance()
        
//        let bounds = UIScreen.main.bounds
//        self.window = UIWindow(frame: bounds)
//        self.window!.rootViewController = MainTabBarController()
//        self.window?.makeKeyAndVisible()
//        let mainTabBarController = MainTabBarController()
//        mainTabBarController.managedObjectContext = self.managedObjectContext
//        let homeController = HomeController()
//        homeController.managedObjectContext = managedObjectContext
//
//        
        // access root view contoller, which is tab bar view controller
        let tabController = window!.rootViewController
            as! UITabBarController
        // find the first view controller of tab bar which is navigation controller

        if let tabViewControllers = tabController.viewControllers {
            // First tab
//            var navController = tabViewControllers[0]
//                as! UINavigationController
//            let controller1 = navController.viewControllers.first
//                as! CurrentLocationViewController
//            controller1.managedObjectContext = managedObjectContext

            // Second tab
            var navController = tabViewControllers[0]
                as! UINavigationController
            let controller2 = navController.viewControllers.first
                as! LocationsViewController
            controller2.managedObjectContext = managedObjectContext
            controller2.storyboard_1 = storyboard_1
            let _ = controller2.view
            
            // Third tab
            navController = tabViewControllers[1] as! UINavigationController
            let controller3 = navController.viewControllers.first
                as! MapViewController
            controller3.managedObjectContext = managedObjectContext

            // Fourth tab
//            navController = tabViewControllers[3] as! UINavigationController
//            let controller4 = navController.viewControllers.first
//                as! SearchViewController
//            controller4.managedObjectContext = managedObjectContext
            
            // Fifth tab
            navController = tabViewControllers[2] as! UINavigationController
            let controller6 = navController.viewControllers.first
                as! CreateNoteController
            controller6.managedObjectContext = managedObjectContextNote
            
            // Fifth tab
            navController = tabViewControllers[3] as! UINavigationController
            let controller7 = navController.viewControllers.first
                as! CreateNoteGroupController
            controller7.managedObjectContext = managedObjectContextNote
        }
       // notification handler is registered here with the notification center
        listenForFatalCoreDataNotifications()
        
        print("documents directory: \(applicationDocumentsDirectory)")
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
    }
    
    //MARK:- UI Apperance Changes
    // changes appearance of UINavigationBar
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor:
                UIColor.white ]
        UITabBar.appearance().barTintColor = UIColor.black
       // let tintColor = UIColor(red: 255/255.0, green: 238/255.0,
         //                       blue: 136/255.0, alpha: 1.0)
        let tintColor1 = UIColor(red: 74/255.0, green: 255/255.0,
                                blue: 255/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = tintColor1
    }
    
    // MARK:- Helper methods
    func listenForFatalCoreDataNotifications() {
        // 1
        // Tell NotificationCenter that you want to be notified whenever a CoreDataSaveFailedNotification is posted
        
        // since listenForFatalCoreDataNotifications() is registered, and the notification (name) sent to the center matches this functions name. This function is basically saying, I can handle this notification, I'll display an alert message, and close the app with 'Ok' button
        NotificationCenter.default.addObserver(
            forName: CoreDataSaveFailedNotification,
            object: nil, queue: OperationQueue.main,
            using: { notification in
                // 2
                let message = """
There was a fatal error in the app and it cannot continue.
Press OK to terminate the app. Sorry for the inconvenience.
"""
                // 3
                // show alert message to app
                let alert = UIAlertController(
                    title: "Internal Error", message: message,
                    preferredStyle: .alert)
                // 4
                let action = UIAlertAction(title: "OK",
                                           style: .default) { _ in
                                            let exception = NSException(
                                                name: NSExceptionName.internalInconsistencyException,
                                                reason: "Fatal Core Data error", userInfo: nil)
                                            exception.raise()
                }
                // add action (ns exception to close app) to the alert
                alert.addAction(action)
                // 5
                // show the alert through the tabController which is always open
                let tabController = self.window!.rootViewController!
                tabController.present(alert, animated: true, completion: nil)
        }) }


}

