//
//  BlurOverlayView.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class BlurOverlayView: UIView {
    
    // MARK: - UI Components
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    // MARK: - Properties
    private var isVisible = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        // Blur effect view
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.alpha = 0 // Start hidden
        
        addSubview(blurEffectView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func show(animated: Bool = true, duration: TimeInterval = 0.3, alpha: CGFloat = 0.6) {
        guard !isVisible else { return }
        isVisible = true
        
        if animated {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                self.blurEffectView.alpha = alpha
            })
        } else {
            blurEffectView.alpha = alpha
        }
    }
    
    func hide(animated: Bool = true, duration: TimeInterval = 0.3) {
        guard isVisible else { return }
        isVisible = false
        
        if animated {
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                self.blurEffectView.alpha = 0
            })
        } else {
            blurEffectView.alpha = 0
        }
    }
    
    func toggle(animated: Bool = true, duration: TimeInterval = 0.3, alpha: CGFloat = 0.6) {
        if isVisible {
            hide(animated: animated, duration: duration)
        } else {
            show(animated: animated, duration: duration, alpha: alpha)
        }
    }
} 