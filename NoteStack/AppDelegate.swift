//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Griffin Healy on 1/21/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

//the app delegate is the object that gets notifications that concern the application as a whole. This is where iOS notifies the app that it has started up, for example.

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let storyboard_1 = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    //--------------------------------------------------------------------------------
    
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
    
    //--------------------------------------------------------------------------------
    
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
    
    //--------------------------------------------------------------------------------
     
    // this is a closure, so it is done with lazy loading, not performed right away
    lazy var persistentContainerChecklist: NSPersistentContainer = {
        // closure
        // Instantiate a new NSPersistentContainer object with the name of the data model you created earlier, DataModel.
        // says, look for data model "DataModel" and put into container
        let container = NSPersistentContainer(name: "TheChecklistDataModel")
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
    lazy var managedObjectContextChecklist: NSManagedObjectContext =
        persistentContainerChecklist.viewContext
    
    //--------------------------------------------------------------------------------
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // customize the navigation bar to black and text color to white
        customizeAppearance()
        
        // Notification set up
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
//        let bounds = UIScreen.main.bounds
//        self.window = UIWindow(frame: bounds)
//        self.window!.rootViewController = MainTabBarController()
//        self.window?.makeKeyAndVisible()
//        let mainTabBarController = MainTabBarController()
//        mainTabBarController.managedObjectContext = self.managedObjectContext
//        let homeController = HomeController()
//        homeController.managedObjectContext = managedObjectContext

        // access root view contoller, which is tab bar view controller
        let tabController = window!.rootViewController
            as! UITabBarController
        // find the first view controller of tab bar which is navigation controller

        if let tabViewControllers = tabController.viewControllers {

            // First tab
            var navController = tabViewControllers[0]
                as! UINavigationController
            let controller0 = navController.viewControllers.first
                as! LocationsViewController
            controller0.managedObjectContext = managedObjectContext
            controller0.storyboard_1 = storyboard_1
            let _ = controller0.view
            
            // Second tab
            navController = tabViewControllers[1] as! UINavigationController
            let controller1 = navController.viewControllers.first
                as! CreateNoteGroupController
            controller1.managedObjectContext = managedObjectContextNote
            
            // Third tab
            navController = tabViewControllers[2] as! UINavigationController
            let controller2 = navController.viewControllers.first
                as! ChecklistsViewController
            controller2.managedObjectContext = managedObjectContextChecklist
            
            // Third tab
//            navController = tabViewControllers[2] as! UINavigationController
//            let controller3 = navController.viewControllers.first
//                as! MapViewController
//            controller3.managedObjectContext = managedObjectContext
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

        // Tab Bar Color
        UITabBar.appearance().barTintColor = UIColor.white
        // Tab Bar Items Color
        UITabBar.appearance().tintColor = .rgb(red: 0, green: 224, blue: 255)
        // Tab Bar Items Unselected Color
        UITabBar.appearance().unselectedItemTintColor = .rgb(red: 125, green: 150, blue: 150)
   
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Bold", size: 21)!]
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
        })
        
//        NotificationCenter.default.addObserver(
//        self,
//        selector: #selector(keyboardWillShow),
//        name: UIResponder.keyboardWillShowNotification,
//        object: nil)
    }
    
//        @objc func keyboardWillShow(_ notification: Notification) {
//        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            print("HEIGHT")
//            print(keyboardHeight)
//        }
//    }
    
    // MARK:- User Notification Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      print("Received local notification \(notification)")
    }
}


