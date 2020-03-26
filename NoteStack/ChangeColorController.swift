//
//  ChangeColorController.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/25/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import LBTATools
import CoreData

protocol PickColorDelegate {
    func retrievedColor(red: Int, green: Int, blue: Int)
}

class ChangeColorController: LBTAFormController {
    
    var delegate2: PickColorDelegate?
    
    // SettingsPopupController
    var settingsViewController:SettingsPopupController?
    var settingsViewController2:SettingsPopupController2?
    
    // delegate var for the protocol above
    var delegate: PhotoOrLocationDelegate?
    
    var image: UIImage?
    
    var noteToEdit: Notes?
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
   // var delegate: EditNoteDelegate?
   
    var noteTextField = UITextView(text: "", font: .boldSystemFont(ofSize: 18), textColor: .black, textAlignment: .left)
    
    lazy var changeColorButton1 = UIButton(image: #imageLiteral(resourceName: "white").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorWhite(_:)))
    
    lazy var changeColorButton2 = UIButton(image: #imageLiteral(resourceName: "blue2").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorLightestBlue(_:)))
    
    lazy var changeColorButton3 = UIButton(image: #imageLiteral(resourceName: "red").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorRed(_:)))
    
    lazy var changeColorButton4 = UIButton(image: #imageLiteral(resourceName: "gray2").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorLightGrayish(_:)))
    
    lazy var changeColorButton5 = UIButton(image: #imageLiteral(resourceName: "green2").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorGreen(_:)))

    lazy var changeColorButton6 = UIButton(image: #imageLiteral(resourceName: "black2").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorNightishBlack(_:)))
    
    lazy var changeColorButton7 = UIButton(image: #imageLiteral(resourceName: "yellow").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorYellow(_:)))
    
    lazy var changeColorButton8 = UIButton(image: #imageLiteral(resourceName: "purple").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorPurple(_:)))
    
    lazy var changeColorButton9 = UIButton(image: #imageLiteral(resourceName: "navy").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorNavy(_:)))
    
    lazy var changeColorButton10 = UIButton(image: #imageLiteral(resourceName: "lgray").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorLightGray(_:)))
    
    lazy var changeColorButton11 = UIButton(image: #imageLiteral(resourceName: "blue").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorBlue(_:)))
    
    lazy var changeColorButton12 = UIButton(image: #imageLiteral(resourceName: "green").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorLightGreen(_:)))
    
    lazy var changeColorButton13 = UIButton(image: #imageLiteral(resourceName: "pink").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorPink(_:)))
    
    lazy var changeColorButton14 = UIButton(image: #imageLiteral(resourceName: "orange").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorOrange(_:)))
    
    lazy var changeColorButton15 = UIButton(image: #imageLiteral(resourceName: "aqua").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorLightBlue(_:)))
    
    lazy var changeColorButton16 = UIButton(image: #imageLiteral(resourceName: "black").withRenderingMode(.alwaysOriginal), tintColor: .none, target: self, action: #selector(changeColorBlack(_:)))
    
    let imageView = UIImageView(frame: CGRect(x: 42.5, y: 42.5, width: 20, height: 20))

    override func viewDidLoad() {
       super.viewDidLoad()

       view.backgroundColor = .white
       changeColorButton1.layer.borderColor = UIColor.clear.cgColor
       changeColorButton1.layer.borderWidth = 0.3
       changeColorButton1.withHeight(75).withWidth(75)
       changeColorButton2.layer.borderColor = UIColor.clear.cgColor
       changeColorButton2.layer.borderWidth = 0.3
       changeColorButton2.withHeight(75).withWidth(75)
       changeColorButton3.layer.borderColor = UIColor.clear.cgColor
       changeColorButton3.layer.borderWidth = 0.3
       changeColorButton3.withHeight(75).withWidth(75)
       changeColorButton4.layer.borderColor = UIColor.clear.cgColor
       changeColorButton4.layer.borderWidth = 0.3
       changeColorButton4.withHeight(75).withWidth(75)
       changeColorButton5.layer.borderColor = UIColor.clear.cgColor
       changeColorButton5.layer.borderWidth = 0.3
       changeColorButton5.withHeight(75).withWidth(75)
       changeColorButton6.layer.borderColor = UIColor.clear.cgColor
       changeColorButton6.layer.borderWidth = 0.3
       changeColorButton6.withHeight(75).withWidth(75)
       changeColorButton7.layer.borderColor = UIColor.clear.cgColor
       changeColorButton7.layer.borderWidth = 0.3
       changeColorButton7.withHeight(75).withWidth(75)
       changeColorButton8.layer.borderColor = UIColor.clear.cgColor
       changeColorButton8.layer.borderWidth = 0.3
       changeColorButton8.withHeight(75).withWidth(75)
       changeColorButton9.layer.borderColor = UIColor.clear.cgColor
       changeColorButton9.layer.borderWidth = 0.3
       changeColorButton9.withHeight(75).withWidth(75)
       changeColorButton10.layer.borderColor = UIColor.clear.cgColor
       changeColorButton10.layer.borderWidth = 0.3
       changeColorButton10.withHeight(75).withWidth(75)
       changeColorButton11.layer.borderColor = UIColor.clear.cgColor
       changeColorButton11.layer.borderWidth = 0.3
       changeColorButton11.withHeight(75).withWidth(75)
       changeColorButton12.layer.borderColor = UIColor.clear.cgColor
       changeColorButton12.layer.borderWidth = 0.3
       changeColorButton12.withHeight(75).withWidth(75)
       changeColorButton13.layer.borderColor = UIColor.clear.cgColor
       changeColorButton13.layer.borderWidth = 0.3
       changeColorButton13.withHeight(75).withWidth(75)
       changeColorButton14.layer.borderColor = UIColor.clear.cgColor
       changeColorButton14.layer.borderWidth = 0.3
       changeColorButton14.withHeight(75).withWidth(75)
       changeColorButton15.layer.borderColor = UIColor.clear.cgColor
       changeColorButton15.layer.borderWidth = 0.3
       changeColorButton15.withHeight(75).withWidth(75)
       changeColorButton16.layer.borderColor = UIColor.clear.cgColor
       changeColorButton16.layer.borderWidth = 0.3
       changeColorButton16.withHeight(75).withWidth(75)
        

       self.scrollView.isScrollEnabled = false
        
       let formView = UIView().withHeight(300)
        formView.stack(formView.hstack(changeColorButton1,changeColorButton2,changeColorButton3,changeColorButton4),
                       formView.hstack(changeColorButton5,changeColorButton6,changeColorButton7,changeColorButton8),
                       formView.hstack(changeColorButton9,changeColorButton10,changeColorButton11,changeColorButton12),
                       formView.hstack(changeColorButton13,changeColorButton14,changeColorButton15,changeColorButton16))
       
       formContainerStackView.padBottom(0)
       formContainerStackView.addArrangedSubview(formView)
       }
    
    @objc func changeColorWhite(_ sender: UIButton) {
        print("White")
        let red: Int = 255
        let green: Int = 255
        let blue: Int = 255
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        
    }
    
    @objc func changeColorLightestBlue(_ sender: UIButton) {
        print("Lightest Blue")
        let red: Int = 154
        let green: Int = 203
        let blue: Int = 255
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        }
    
    @objc func changeColorRed(_ sender: UIButton) {
        print("Red")
        let red: Int = 236
        let green: Int = 63
        let blue: Int = 63
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorLightGrayish(_ sender: UIButton) {
        print("Light Grayish")
        let red: Int = 102
        let green: Int = 102
        let blue: Int = 102
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorGreen(_ sender: UIButton) {
        print("Bright Green")
        let red: Int = 46
        let green: Int = 204
        let blue: Int = 113
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorNightishBlack(_ sender: UIButton) {
        print("Nightish Black")
        let red: Int = 51
        let green: Int = 51
        let blue: Int = 51
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorYellow(_ sender: UIButton) {
        print("Yellow")
        let red: Int = 241
        let green: Int = 196
        let blue: Int = 15
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorPurple(_ sender: UIButton) {
        print("Purple")
        let red: Int = 186
        let green: Int = 79
        let blue: Int = 185
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
       }
    
    @objc func changeColorNavy(_ sender: UIButton) {
        print("Navy")
        let red: Int = 52
        let green: Int = 73
        let blue: Int = 94
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
          }

    @objc func changeColorLightGray(_ sender: UIButton) {
        print("Light Gray")
        let red: Int = 204
        let green: Int = 204
        let blue: Int = 204
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorBlue(_ sender: UIButton) {
        print("Blue")
        let red: Int = 52
        let green: Int = 152
        let blue: Int = 219
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorLightGreen(_ sender: UIButton) {
        print("Light Green")
        let red: Int = 26
        let green: Int = 188
        let blue: Int = 156
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorPink(_ sender: UIButton) {
        print("Pink")
        let red: Int = 255
        let green: Int = 5
        let blue: Int = 253
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorOrange(_ sender: UIButton) {
        print("Orange")
        let red: Int = 230
        let green: Int = 126
        let blue: Int = 34
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorLightBlue(_ sender: UIButton) {
        print("Light Blue")
        let red: Int = 0
        let green: Int = 197
        let blue: Int = 204
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
    
    @objc func changeColorBlack(_ sender: UIButton) {
        print("Black")
        let red: Int = 0
        let green: Int = 0
        let blue: Int = 0
        if (settingsViewController != nil) {
        let settingsContrl = settingsViewController
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
        else {
        let settingsContrl = settingsViewController2
        settingsContrl?.managedObjectContext = managedObjectContext
        self.delegate2 = settingsContrl
        delegate2?.retrievedColor(red: red, green: green, blue: blue)
        dismiss(animated: true)
        }
    }
}


