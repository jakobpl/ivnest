//
//  ViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the main tab bar controller
        let tabBarController = MainTabBarController()
        
        // Add the tab bar controller as a child
        addChild(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.view.frame = view.bounds
        tabBarController.didMove(toParent: self)
    }
}

