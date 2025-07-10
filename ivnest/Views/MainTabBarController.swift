//
//  MainTabBarController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupTabs()
    }
    
    private func setupTabBar() {
        // Make tab bar transparent with black background
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
        tabBar.barTintColor = .clear
        
        // Set icon colors: grey for unselected, white for selected
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        // Add a black background view behind the tab bar
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, belowSubview: tabBar)
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTabs() {
        // Portfolio Tab
        let portfolioVC = DashboardViewController()
        let portfolioNav = UINavigationController(rootViewController: portfolioVC)
        portfolioNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "chart.pie.fill"),
            selectedImage: UIImage(systemName: "chart.pie.fill")
        )
        
        // Trade Tab
        let tradeVC = TradeViewController()
        let tradeNav = UINavigationController(rootViewController: tradeVC)
        tradeNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis")
        )
        
        // Watchlist Tab
        let watchlistVC = WatchlistViewController()
        let watchlistNav = UINavigationController(rootViewController: watchlistVC)
        watchlistNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "eye.fill"),
            selectedImage: UIImage(systemName: "eye.fill")
        )
        
        // Search Tab
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        
        viewControllers = [portfolioNav, tradeNav, watchlistNav, searchNav]
    }
} 