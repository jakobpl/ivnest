//
//  BaseViewController.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    var blurOverlay: BlurOverlayView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
    }
    
    // MARK: - Base UI Setup
    private func setupBaseUI() {
        view.backgroundColor = .black
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.barStyle = .black
    }
    
    // MARK: - Blur Overlay Management
    func setupBlurOverlay() {
        blurOverlay = BlurOverlayView()
        guard let blurOverlay = blurOverlay else { return }
        
        blurOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurOverlay)
        
        NSLayoutConstraint.activate([
            blurOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            blurOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func showBlurOverlay(animated: Bool = true) {
        blurOverlay?.show(animated: animated)
    }
    
    func hideBlurOverlay(animated: Bool = true) {
        blurOverlay?.hide(animated: animated)
    }
    
    // MARK: - Common UI Helpers
    func setupTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: - Common Constraints
    func setupStandardMargins(for view: UIView, in container: UIView, topConstant: CGFloat = 20, bottomConstant: CGFloat = -20) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor, constant: topConstant),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            view.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: bottomConstant)
        ])
    }
} 