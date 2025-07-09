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
        
        // Analytics Tab (placeholder for future)
        let analyticsVC = AnalyticsViewController()
        let analyticsNav = UINavigationController(rootViewController: analyticsVC)
        analyticsNav.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "chart.bar.fill"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )
        
        viewControllers = [portfolioNav, tradeNav, watchlistNav, analyticsNav]
    }
}

// MARK: - Analytics View Controller (Placeholder)
class AnalyticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        title = "Analytics"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        
        let label = UILabel()
        label.text = "Analytics Coming Soon"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
} 