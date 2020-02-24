//
//  CategoryPopoverController.swift
//  NoteStack
//
//  Created by Griffin Healy on 2/17/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData
import LBTATools
import AudioToolbox

protocol PickCategoryDelegate {
    func retrievedCategory(locationCategory: String)
}


class CategoryPopoverController: LBTAFormController, UINavigationControllerDelegate {
    
    var delegate: PickCategoryDelegate?
    
    // CurrentOrSearchDetailController
    var createCategoryController:CurrentOrSearchDetailController?
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var noCategoryButton = UIButton(title: "No Category", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var bankButton = UIButton(title: "Bank", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var barButton = UIButton(title: "Bar", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var bookstoreButton = UIButton(title: "Book Store", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var clubButton = UIButton(title: "Club", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var coffeeButton = UIButton(title: "Coffee", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var gasstationButton = UIButton(title: "Gas Station", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var groceriesButton = UIButton(title: "Groceries", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var historicButton = UIButton(title: "Historic Building", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var hospitalButton = UIButton(title: "Hospital", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var houseButton = UIButton(title: "House", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var landmarkButton = UIButton(title: "Landmark", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var mallButton = UIButton(title: "Mall", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var museumButton = UIButton(title: "Museum", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var parkinglotButton = UIButton(title: "Parking Lot", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var parkButton = UIButton(title: "Park", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var postofficeButton = UIButton(title: "Post Office", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var restaurantButton = UIButton(title: "Restaurant", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var stadiumButton = UIButton(title: "Stadium", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    lazy var workButton = UIButton(title: "Work", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 172, blue: 237), target: self, action: #selector(theCategory(_:)))
    
    var soundID: SystemSoundID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Categories"
        noCategoryButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        noCategoryButton.contentHorizontalAlignment = .left
        noCategoryButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        bankButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        bankButton.contentHorizontalAlignment = .left
        bankButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        barButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        barButton.contentHorizontalAlignment = .left
        barButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        bookstoreButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        bookstoreButton.contentHorizontalAlignment = .left
        bookstoreButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        clubButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        clubButton.contentHorizontalAlignment = .left
        clubButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        coffeeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        coffeeButton.contentHorizontalAlignment = .left
        coffeeButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        gasstationButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        gasstationButton.contentHorizontalAlignment = .left
        gasstationButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        groceriesButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        groceriesButton.contentHorizontalAlignment = .left
        groceriesButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        historicButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        historicButton.contentHorizontalAlignment = .left
        historicButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        hospitalButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        hospitalButton.contentHorizontalAlignment = .left
        hospitalButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        houseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        houseButton.contentHorizontalAlignment = .left
        houseButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        landmarkButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        landmarkButton.contentHorizontalAlignment = .left
        landmarkButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        mallButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        mallButton.contentHorizontalAlignment = .left
        mallButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        museumButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        museumButton.contentHorizontalAlignment = .left
        museumButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        parkinglotButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        parkinglotButton.contentHorizontalAlignment = .left
        parkinglotButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        parkButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        parkButton.contentHorizontalAlignment = .left
        parkButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        postofficeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        postofficeButton.contentHorizontalAlignment = .left
        postofficeButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        restaurantButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        restaurantButton.contentHorizontalAlignment = .left
        restaurantButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        stadiumButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        stadiumButton.contentHorizontalAlignment = .left
        stadiumButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        workButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        workButton.contentHorizontalAlignment = .left
        workButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelController))
    
        let formView = UIView()
        formView.stack(UIView().withHeight(30), noCategoryButton.withHeight(50), UIView().withHeight(10),
                       bankButton.withHeight(50), UIView().withHeight(10) ,barButton.withHeight(50), UIView().withHeight(10), bookstoreButton.withHeight(50),UIView().withHeight(10), clubButton.withHeight(50), UIView().withHeight(10), coffeeButton.withHeight(50), UIView().withHeight(10), gasstationButton.withHeight(50), UIView().withHeight(10), historicButton.withHeight(50), UIView().withHeight(10), hospitalButton.withHeight(50), UIView().withHeight(10), landmarkButton.withHeight(50), UIView().withHeight(10), mallButton.withHeight(50), UIView().withHeight(10), museumButton.withHeight(50), UIView().withHeight(10), parkinglotButton.withHeight(50), UIView().withHeight(10), parkButton.withHeight(50), UIView().withHeight(10), postofficeButton.withHeight(50), UIView().withHeight(10), restaurantButton.withHeight(50), UIView().withHeight(10), stadiumButton.withHeight(50), UIView().withHeight(10), workButton.withHeight(50)).withMargins(.init(top: 0, left: 15, bottom: 0, right: 15))
                     formContainerStackView.addArrangedSubview(formView)
    }
    
    @objc func cancelController() {
        dismiss(animated: true)
    }
    
    @objc func theCategory(_ sender: UIButton) {
        loadSoundEffect("pin_low2.mp3")
        playSoundEffect()
        if let buttonTitle = sender.title(for: .normal) {
            pickedCategory(category: buttonTitle)
        }
    }
    
    @objc func pickedCategory(category: String) {
        let createCategoryContrl = createCategoryController
        createCategoryContrl?.managedObjectContext = managedObjectContext
        self.delegate = createCategoryContrl
        delegate?.retrievedCategory(locationCategory: category)
        dismiss(animated: true)
    }
    
    // MARK:- Sound effects
          func loadSoundEffect(_ name: String) {
              if let path = Bundle.main.path(forResource: name,
                                             ofType: nil) {
                  let fileURL = URL(fileURLWithPath: path, isDirectory: false)
                  let error = AudioServicesCreateSystemSoundID(
                      fileURL as CFURL, &soundID)
                  if error != kAudioServicesNoError {
                      print("Error code \(error) loading sound: \(path)")
                  }
              } }
          func unloadSoundEffect() {
              AudioServicesDisposeSystemSoundID(soundID)
              soundID = 0 }
          func playSoundEffect() {
              AudioServicesPlaySystemSound(soundID)
          }
}

