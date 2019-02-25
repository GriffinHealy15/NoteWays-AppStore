//
//  String+AddText.swift
//  MyLocations
//
//  Created by Griffin Healy on 2/1/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import Foundation

//You don’t need to use the mutating keyword on methods inside a class because classes are reference types and can always be mutated, even if they are declared with let.
extension String {
    mutating func add(text: String?, // use mutating because were chaning the value of the String struct. add can only be used with strings made with var
        separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text }
    } }
