//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Griffin Healy on 2/1/19.
//  Copyright © 2019 Griffin Healy. All rights reserved.
//

import UIKit
class MyTabBarController: UITabBarController {
    // does whatever UITabBarController normally does, except override preferredStatusBarStyle to change status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childForStatusBarStyle: UIViewController? {
        return nil
    } }
