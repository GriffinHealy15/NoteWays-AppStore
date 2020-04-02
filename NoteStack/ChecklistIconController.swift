//
//  ChecklistIconController.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/30/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData
import LBTATools
import AudioToolbox

protocol PickIconDelegate {
    func retrievedIcon(ChecklistIcon: String)
}


class ChecklistIconController: LBTAFormController, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var delegate: PickIconDelegate?
    
    // CurrentOrSearchDetailController
    var checklistNameController:ChecklistNameController?
    
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    lazy var noCategoryButtonFake = UIButton(title: "Default1", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var noCategoryButton = UIButton(title: "Default", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var appointmentButton = UIButton(title: "Appointments", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var birthdayButton = UIButton(title: "Birthdays", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var bookstoreButton = UIButton(title: "Books", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var choresButton = UIButton(title: "Chores", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var clothingButton = UIButton(title: "Clothing", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var drinkButton = UIButton(title: "Drinks", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var groceriesButton = UIButton(title: "Groceries", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var InboxButton = UIButton(title: "Inbox", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var kitchenButton = UIButton(title: "Kitchen", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var officeButton = UIButton(title: "Office", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var photosButton = UIButton(title: "Photos", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var shoppingButton = UIButton(title: "Shopping", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    lazy var tripsButton = UIButton(title: "Trips", titleColor: .white, font: .boldSystemFont(ofSize: 20), backgroundColor: .rgb(red: 46, green: 205, blue: 187), target: self, action: #selector(theCategory(_:)))
    
    var noCategoryImageFake = UIButton(image: #imageLiteral(resourceName: "Default"), tintColor: .white, target: self)
    var noCategoryImage = UIButton(image: #imageLiteral(resourceName: "Default"), tintColor: .white, target: self)
    var appointmentImage = UIButton(image: #imageLiteral(resourceName: "Appointments"), tintColor: .white, target: self)
    var birthdayImage = UIButton(image: #imageLiteral(resourceName: "Birthdays"), tintColor: .white, target: self)
    var bookImage = UIButton(image: #imageLiteral(resourceName: "Books"), tintColor: .white, target: self)
    var choresImage = UIButton(image: #imageLiteral(resourceName: "Chores"), tintColor: .white, target: self)
    var clothingImage = UIButton(image: #imageLiteral(resourceName: "Clothing"), tintColor: .white, target: self)
    var drinkImage = UIButton(image: #imageLiteral(resourceName: "Drinks"), tintColor: .white, target: self)
    var groceriesImage = UIButton(image: #imageLiteral(resourceName: "Groceries"), tintColor: .white, target: self)
    var inboxImage = UIButton(image: #imageLiteral(resourceName: "Inbox"), tintColor: .white, target: self)
    var kitchenImage = UIButton(image: #imageLiteral(resourceName: "Kitchen"), tintColor: .white, target: self)
    var officeImage = UIButton(image: #imageLiteral(resourceName: "Office"), tintColor: .white, target: self)
    var photosImage = UIButton(image: #imageLiteral(resourceName: "Photos"), tintColor: .white, target: self)
    var shoppingImage = UIButton(image: #imageLiteral(resourceName: "Shopping"), tintColor: .white, target: self)
    var tripImage = UIButton(image: #imageLiteral(resourceName: "Trips"), tintColor: .white, target: self)

    var soundID: SystemSoundID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Checklist Icons"
        
        noCategoryButtonFake.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        noCategoryButtonFake.contentHorizontalAlignment = .left
        noCategoryButtonFake.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        noCategoryImageFake.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        noCategoryButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        noCategoryButton.contentHorizontalAlignment = .left
        noCategoryButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        noCategoryImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        appointmentButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        appointmentButton.contentHorizontalAlignment = .left
        appointmentButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        appointmentImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        birthdayButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        birthdayButton.contentHorizontalAlignment = .left
        birthdayButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        birthdayImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        bookstoreButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        bookstoreButton.contentHorizontalAlignment = .left
        bookstoreButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        bookImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        choresButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        choresButton.contentHorizontalAlignment = .left
        choresButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        choresImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        clothingButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        clothingButton.contentHorizontalAlignment = .left
        clothingButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        clothingImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        groceriesButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        groceriesButton.contentHorizontalAlignment = .left
        groceriesButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        groceriesImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        drinkButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        drinkButton.contentHorizontalAlignment = .left
        drinkButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        drinkImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        InboxButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        InboxButton.contentHorizontalAlignment = .left
        InboxButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        inboxImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        kitchenButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        kitchenButton.contentHorizontalAlignment = .left
        kitchenButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        kitchenImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        officeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        officeButton.contentHorizontalAlignment = .left
        officeButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        officeImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        photosButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        photosButton.contentHorizontalAlignment = .left
        photosButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        photosImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        shoppingButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        shoppingButton.contentHorizontalAlignment = .left
        shoppingButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        shoppingImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        tripsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 7)
        tripsButton.contentHorizontalAlignment = .left
        tripsButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 22)
        tripImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelController))
        navigationItem.rightBarButtonItem?.tintColor = .rgb(red: 0, green: 197, blue: 255)
        
        let noCategoryFakeView = UIView()
        noCategoryFakeView.hstack(noCategoryImageFake.withHeight(0), UIView().withWidth(25), noCategoryButtonFake.withHeight(0))
        noCategoryFakeView.layer.cornerRadius = 10
        noCategoryFakeView.clipsToBounds = true
        noCategoryFakeView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let noCategoryView = UIView()
        noCategoryView.hstack(noCategoryImage.withHeight(50), UIView().withWidth(25),  noCategoryButton.withHeight(50))
        noCategoryView.layer.cornerRadius = 10
        noCategoryView.clipsToBounds = true
        noCategoryView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let appointmentView = UIView()
        appointmentView.hstack(appointmentImage.withHeight(50), UIView().withWidth(25),appointmentButton.withHeight(50))
        appointmentView.layer.cornerRadius = 10
        appointmentView.clipsToBounds = true
        appointmentView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
     
        let birthdayView = UIView()
        birthdayView.hstack(birthdayImage.withHeight(50), UIView().withWidth(25), birthdayButton.withHeight(50))
        birthdayView.layer.cornerRadius = 10
        birthdayView.clipsToBounds = true
        birthdayView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let bookView = UIView()
        bookView.hstack(bookImage.withHeight(50), UIView().withWidth(25), bookstoreButton.withHeight(50))
        bookView.layer.cornerRadius = 10
        bookView.clipsToBounds = true
        bookView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let choresView = UIView()
        choresView.hstack(choresImage.withHeight(50), UIView().withWidth(25), choresButton.withHeight(50))
        choresView.layer.cornerRadius = 10
        choresView.clipsToBounds = true
        choresView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let clothingView = UIView()
        clothingView.hstack(clothingImage.withHeight(50), UIView().withWidth(25), clothingButton.withHeight(50))
        clothingView.layer.cornerRadius = 10
        clothingView.clipsToBounds = true
        clothingView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let drinkingView = UIView()
        drinkingView.hstack(drinkImage.withHeight(50), UIView().withWidth(25), drinkButton.withHeight(50))
        drinkingView.layer.cornerRadius = 10
        drinkingView.clipsToBounds = true
        drinkingView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let groceriesView = UIView()
        groceriesView.hstack(groceriesImage.withHeight(50), UIView().withWidth(25), groceriesButton.withHeight(50))
        groceriesView.layer.cornerRadius = 10
        groceriesView.clipsToBounds = true
        groceriesView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let inboxView = UIView()
        inboxView.hstack(inboxImage.withHeight(50), UIView().withWidth(25), InboxButton.withHeight(50))
        inboxView.layer.cornerRadius = 10
        inboxView.clipsToBounds = true
        inboxView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let kitchenView = UIView()
        kitchenView.hstack(kitchenImage.withHeight(50), UIView().withWidth(25), kitchenButton.withHeight(50))
        kitchenView.layer.cornerRadius = 10
        kitchenView.clipsToBounds = true
        kitchenView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let officeView = UIView()
        officeView.hstack(officeImage.withHeight(50), UIView().withWidth(25), officeButton.withHeight(50))
        officeView.layer.cornerRadius = 10
        officeView.clipsToBounds = true
        officeView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let photosView = UIView()
        photosView.hstack(photosImage.withHeight(50), UIView().withWidth(25), photosButton.withHeight(50))
        photosView.layer.cornerRadius = 10
        photosView.clipsToBounds = true
        photosView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let shoppingView = UIView()
        shoppingView.hstack(shoppingImage.withHeight(50), UIView().withWidth(25), shoppingButton.withHeight(50))
        shoppingView.layer.cornerRadius = 10
        shoppingView.clipsToBounds = true
        shoppingView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let tripView = UIView()
        tripView.hstack(tripImage.withHeight(50), UIView().withWidth(25), tripsButton.withHeight(50))
        tripView.layer.cornerRadius = 10
        tripView.clipsToBounds = true
        tripView.backgroundColor = .rgb(red: 46, green: 205, blue: 187)
        
        let formView2 = UIView()
        formView2.stack(noCategoryFakeView, UIView().withHeight(10), noCategoryView, UIView().withHeight(10), appointmentView, UIView().withHeight(10), birthdayView, UIView().withHeight(10), bookView, UIView().withHeight(10) ,choresView, UIView().withHeight(10) ,clothingView, UIView().withHeight(10), drinkingView, UIView().withHeight(10), groceriesView, UIView().withHeight(10), inboxView, UIView().withHeight(10), kitchenView, UIView().withHeight(10), officeView, UIView().withHeight(10), photosView, UIView().withHeight(10), shoppingView, UIView().withHeight(10), tripView)
        
        let formView = UIView()
        formView.stack(UIView().withHeight(30),UIView().withHeight(10), formView2, UIView().withHeight(10)).withMargins(.init(top: 10, left: 25, bottom: 10, right: 25))
                     formContainerStackView.addArrangedSubview(formView)
    }
    
    @objc func cancelController() {
        dismiss(animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
    
    @objc func theCategory(_ sender: UIButton) {
        if let buttonTitle = sender.title(for: .normal) {
            pickedCategory(category: buttonTitle)
        }
    }
    
    @objc func pickedCategory(category: String) {
        let createCategoryContrl = checklistNameController
        createCategoryContrl?.managedObjectContext = managedObjectContext
        self.delegate = createCategoryContrl
        delegate?.retrievedIcon(ChecklistIcon: category)
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


