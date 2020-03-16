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


class CategoryPopoverController: LBTAFormController, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, CreateOtherDelegate {
    
    var delegate: PickCategoryDelegate?
    
    // CurrentOrSearchDetailController
    var createCategoryController:CurrentOrSearchDetailController?
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var otherCategoryButton = UIButton(title: "Create Category", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(otherCategory))
    lazy var noCategoryButton = UIButton(title: "No Category", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var bankButton = UIButton(title: "Bank", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var barButton = UIButton(title: "Bar", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var bookstoreButton = UIButton(title: "Book Store", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var clubButton = UIButton(title: "Club", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var coffeeButton = UIButton(title: "Coffee", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var foodButton = UIButton(title: "Food", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var gasstationButton = UIButton(title: "Gas Station", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var groceriesButton = UIButton(title: "Groceries", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var historicButton = UIButton(title: "Historic Building", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var hospitalButton = UIButton(title: "Hospital", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var houseButton = UIButton(title: "Home", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var landmarkButton = UIButton(title: "Landmark", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var mallButton = UIButton(title: "Mall", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var museumButton = UIButton(title: "Museum", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var parkinglotButton = UIButton(title: "Parking Lot", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var parkButton = UIButton(title: "Park", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var postofficeButton = UIButton(title: "Post Office", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var restaurantButton = UIButton(title: "Restaurant", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var stadiumButton = UIButton(title: "Stadium", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var storeButton = UIButton(title: "Store", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    lazy var workButton = UIButton(title: "Work", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 0, green: 197, blue: 255), target: self, action: #selector(theCategory(_:)))
    
    var soundID: SystemSoundID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Categories"
        
        otherCategoryButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        otherCategoryButton.contentHorizontalAlignment = .left
        otherCategoryButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        otherCategoryButton.layer.cornerRadius = 20
        otherCategoryButton.clipsToBounds = true
        
        noCategoryButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        noCategoryButton.contentHorizontalAlignment = .left
        noCategoryButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        noCategoryButton.layer.cornerRadius = 20
        noCategoryButton.clipsToBounds = true
        
        bankButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        bankButton.contentHorizontalAlignment = .left
        bankButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        bankButton.layer.cornerRadius = 20
        bankButton.clipsToBounds = true
        
        barButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        barButton.contentHorizontalAlignment = .left
        barButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        barButton.layer.cornerRadius = 20
        barButton.clipsToBounds = true
        
        bookstoreButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        bookstoreButton.contentHorizontalAlignment = .left
        bookstoreButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        bookstoreButton.layer.cornerRadius = 20
        bookstoreButton.clipsToBounds = true
        
        clubButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        clubButton.contentHorizontalAlignment = .left
        clubButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        clubButton.layer.cornerRadius = 20
        clubButton.clipsToBounds = true
        
        coffeeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        coffeeButton.contentHorizontalAlignment = .left
        coffeeButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        coffeeButton.layer.cornerRadius = 20
        coffeeButton.clipsToBounds = true
        
        gasstationButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        gasstationButton.contentHorizontalAlignment = .left
        gasstationButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        gasstationButton.layer.cornerRadius = 20
        gasstationButton.clipsToBounds = true
        
        groceriesButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        groceriesButton.contentHorizontalAlignment = .left
        groceriesButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        groceriesButton.layer.cornerRadius = 20
        groceriesButton.clipsToBounds = true
        
        foodButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        foodButton.contentHorizontalAlignment = .left
        foodButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        foodButton.layer.cornerRadius = 20
        foodButton.clipsToBounds = true
        
        historicButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        historicButton.contentHorizontalAlignment = .left
        historicButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        historicButton.layer.cornerRadius = 20
        historicButton.clipsToBounds = true
        
        hospitalButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        hospitalButton.contentHorizontalAlignment = .left
        hospitalButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        hospitalButton.layer.cornerRadius = 20
        hospitalButton.clipsToBounds = true
        
        houseButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        houseButton.contentHorizontalAlignment = .left
        houseButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        houseButton.layer.cornerRadius = 20
        houseButton.clipsToBounds = true
        
        landmarkButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        landmarkButton.contentHorizontalAlignment = .left
        landmarkButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        landmarkButton.layer.cornerRadius = 20
        landmarkButton.clipsToBounds = true
        
        mallButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        mallButton.contentHorizontalAlignment = .left
        mallButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        mallButton.layer.cornerRadius = 20
        mallButton.clipsToBounds = true
        
        museumButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        museumButton.contentHorizontalAlignment = .left
        museumButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        museumButton.layer.cornerRadius = 20
        museumButton.clipsToBounds = true
        
        parkinglotButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        parkinglotButton.contentHorizontalAlignment = .left
        parkinglotButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        parkinglotButton.layer.cornerRadius = 20
        parkinglotButton.clipsToBounds = true
        
        parkButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        parkButton.contentHorizontalAlignment = .left
        parkButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        parkButton.layer.cornerRadius = 20
        parkButton.clipsToBounds = true
        
        postofficeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        postofficeButton.contentHorizontalAlignment = .left
        postofficeButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        postofficeButton.layer.cornerRadius = 20
        postofficeButton.clipsToBounds = true
        
        restaurantButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        restaurantButton.contentHorizontalAlignment = .left
        restaurantButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        restaurantButton.layer.cornerRadius = 20
        restaurantButton.clipsToBounds = true
        
        stadiumButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        stadiumButton.contentHorizontalAlignment = .left
        stadiumButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        stadiumButton.layer.cornerRadius = 20
        stadiumButton.clipsToBounds = true
        
        storeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        storeButton.contentHorizontalAlignment = .left
        storeButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        storeButton.layer.cornerRadius = 20
        storeButton.clipsToBounds = true
        
        workButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        workButton.contentHorizontalAlignment = .left
        workButton.titleLabel?.font = UIFont(name: "PingFangHK-Regular", size: 20)
        workButton.layer.cornerRadius = 20
        workButton.clipsToBounds = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelController))
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
    
        let formView = UIView()
        formView.stack(UIView().withHeight(30),
                       otherCategoryButton.withHeight(50), UIView().withHeight(10),
                       noCategoryButton.withHeight(50), UIView().withHeight(10),
                       bankButton.withHeight(50), UIView().withHeight(10) ,barButton.withHeight(50), UIView().withHeight(10), bookstoreButton.withHeight(50),UIView().withHeight(10), clubButton.withHeight(50), UIView().withHeight(10), coffeeButton.withHeight(50), UIView().withHeight(10),
                           foodButton.withHeight(50), UIView().withHeight(10),
                           gasstationButton.withHeight(50), UIView().withHeight(10),
                           groceriesButton.withHeight(50), UIView().withHeight(10),
                           historicButton.withHeight(50), UIView().withHeight(10),
                           houseButton.withHeight(50), UIView().withHeight(10),
                           hospitalButton.withHeight(50), UIView().withHeight(10), landmarkButton.withHeight(50), UIView().withHeight(10), mallButton.withHeight(50), UIView().withHeight(10), museumButton.withHeight(50), UIView().withHeight(10), parkinglotButton.withHeight(50), UIView().withHeight(10), parkButton.withHeight(50), UIView().withHeight(10), postofficeButton.withHeight(50), UIView().withHeight(10), restaurantButton.withHeight(50), UIView().withHeight(10), stadiumButton.withHeight(50), UIView().withHeight(10),
                           storeButton.withHeight(50), UIView().withHeight(10),
                           workButton.withHeight(50)).withMargins(.init(top: 10, left: 25, bottom: 10, right: 25))
                     formContainerStackView.addArrangedSubview(formView)
    }
    
    @objc func cancelController() {
        dismiss(animated: true)
    }
    
    @objc func otherCategory() {
        //loadSoundEffect("pin_low2.mp3")
        //playSoundEffect()
        
        let vc = CategoryOtherPopover()
        vc.managedObjectContext = managedObjectContext
        vc.preferredContentSize = CGSize(width: 275, height: 260)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.createCategoryNameContrll = self
        let ppc = vc.popoverPresentationController
        ppc?.permittedArrowDirections = .init(rawValue: 0)
        ppc?.delegate = self
        ppc!.sourceView = self.view
        ppc?.passthroughViews = nil
        ppc?.sourceRect =  CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY - 80, width: 0, height: 0)
        present(vc, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }

    func retrievedOtherCategoryName(otherCategoryText: String) {
        pickedCategory(category: otherCategoryText)
        dismiss(animated: true)
    }
    
    @objc func theCategory(_ sender: UIButton) {
        //loadSoundEffect("pin_low2.mp3")
        //playSoundEffect()
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

