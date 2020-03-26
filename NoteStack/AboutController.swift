//
//  AboutController.swift
//  NoteStack
//
//  Created by Griffin Healy on 3/15/20.
//  Copyright © 2020 Griffin Healy. All rights reserved.
//

import UIKit
import CoreData
import LBTATools
import AudioToolbox

// -- ABOUT PAGE LISTING LICENSING CREDITS TO ALL 3RD PARTY LIBRARIES USED -- //
// VERSION 1.1 BUILD 9. Demo Complete.

class AboutController: LBTAFormController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UINavigationControllerDelegate {
    
    // MARK: UI Elements
    // Managed object context
    var managedObjectContext: NSManagedObjectContext!
    
    var currentNotesGroup: NotesGroup?
    
    var NoteGroupNamePassed: String = ""
    
    var singleController = CreateNoteControllerSingle()
    
    // delegate var for the protocol above
    var delegate: CreateNoteDelegate?
       
    var noteTextField = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var noteTextField2 = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var noteTextField3 = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var noteTextField4 = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var noteTextField5 = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var noteTextField6 = UITextView(text: "", font: UIFont(name: "PingFangHK-Regular", size: 20), textColor: .lightGray, textAlignment: .left)
    var lbtaToolsLabel = UILabel(backgroundColor: .white)
    var SDWebImageLabel = UILabel(backgroundColor: .white)
    var JGProgressHUD = UILabel(backgroundColor: .white)
    var Alamofire = UILabel(backgroundColor: .white)
    var icons8 = UILabel(backgroundColor: .white)

    var soundID: SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        noteTextField.backgroundColor = .white
        noteTextField2.backgroundColor = .white
        noteTextField3.backgroundColor = .white
        noteTextField4.backgroundColor = .white
        noteTextField5.backgroundColor = .white
        noteTextField6.backgroundColor = .white
        lbtaToolsLabel.textColor = .black
        SDWebImageLabel.textColor = .black
        JGProgressHUD.textColor = .black
        Alamofire.textColor = .black
        icons8.textColor = .black
        noteTextField.autocapitalizationType = .none
        noteTextField.font = UIFont(name: "PingFangHK-Regular", size: 14)
        noteTextField2.font = UIFont(name: "PingFangHK-Regular", size: 14)
        noteTextField3.font = UIFont(name: "PingFangHK-Regular", size: 14)
        noteTextField4.font = UIFont(name: "PingFangHK-Regular", size: 14)
        noteTextField5.font = UIFont(name: "PingFangHK-Regular", size: 18)
        noteTextField6.font = UIFont(name: "PingFangHK-Regular", size: 18)
        noteTextField.isEditable = false
        noteTextField2.isEditable = false
        noteTextField3.isEditable = false
        noteTextField4.isEditable = false
        noteTextField5.isEditable = false
        noteTextField6.isEditable = false
        noteTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSMutableAttributedString(string: "Link: https://icons8.com")
        let url = URL(string: "https://icons8.com")!

        // Set the 'click here' substring to be the link
        attributedString.setAttributes([.link: url], range: NSMakeRange(6, 18))

        self.noteTextField5.attributedText = attributedString
        self.noteTextField5.isUserInteractionEnabled = true

        // Set how links should appear: blue and underlined
        self.noteTextField5.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        lbtaToolsLabel.text = "LBTATools"
        SDWebImageLabel.text = "SDWebImageLabel"
        JGProgressHUD.text = "JGProgressHUD"
        Alamofire.text = "Alamofire"
        icons8.text = "Icons by Icons8"
        lbtaToolsLabel.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        SDWebImageLabel.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        JGProgressHUD.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        Alamofire.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        icons8.font = UIFont(name: "PingFangTC-Semibold", size: 16)
        
        //  LBTATOOLS
        noteTextField.text = "Copyright (c) 2019 Brian Voong <bhlvoong@gmail.com> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
        
        // SDWebImageLabel
        noteTextField2.text = "Copyright (c) 2009-2018 Olivier Poitrey rs@dailymotion.com Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
        
         // JGProgressHUD
         noteTextField3.text = "The MIT License (MIT) Copyright (c) 2014-2018 Jonas Gessner Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
        
        // Alamofire
        noteTextField4.text = "Copyright (c) 2014-2020 Alamofire Software Foundation (http://alamofire.org/) Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
        
        // icons8.com
        noteTextField6.text = "https://icons8.com"
        
        noteTextField.textColor = .black
        noteTextField2.textColor = .black
        noteTextField3.textColor = .black
        noteTextField4.textColor = .black
        noteTextField5.textColor = .black
        noteTextField6.textColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(cancelNote))
        navigationItem.leftBarButtonItem!.tintColor = .rgb(red: 0, green: 197, blue: 255)
        title = "Libraries"
        let formView = UIView()
        formView.stack(UIView().withHeight(5), lbtaToolsLabel.withHeight(19),
                       noteTextField.withHeight(530),
                       SDWebImageLabel.withHeight(19),
                       noteTextField2.withHeight(530),
                       JGProgressHUD.withHeight(19),
                       noteTextField3.withHeight(530),
                       Alamofire.withHeight(19),
                       noteTextField4.withHeight(530),
                       icons8.withHeight(19),
                       noteTextField6.withHeight(30),
        UIView().withHeight(0),spacing: 10).withMargins(.init(top: 0, left: 10, bottom: 0, right: 10))

        formContainerStackView.padBottom(0)
        formContainerStackView.addArrangedSubview(formView)
    }
    
    @objc func cancelNote() {
        //loadSoundEffect("swipe.mp3")
        //playSoundEffect()
        dismiss(animated: true)
    }

    
    // MARK:- Help Methods
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


