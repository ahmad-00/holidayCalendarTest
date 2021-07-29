//
//  AppDelegate.swift
//  Test
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        let calendarVC = CalendarVC(viewModel: CalendarVM())
        
        let navController = UINavigationController(rootViewController: calendarVC)
        navController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        window?.rootViewController = navController

        return true
    }

}

