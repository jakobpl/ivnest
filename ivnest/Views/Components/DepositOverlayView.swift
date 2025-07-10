//
//  DepositOverlayView.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

protocol DepositOverlayViewDelegate: AnyObject {
    func depositOverlayDidCompleteDeposit(amount: Double)
    func depositOverlayDidCancel()
}

class DepositOverlayView: UIView {
    
    // MARK: - UI Components
    private let backgroundView = UIView()
    private let containerView = UIView()
    private let amountLabel = UILabel()
    private let keyboardView = UIView()
    private let depositButton = UIButton()
    private let cancelButton = UIButton()
    
    // MARK: - Properties
    weak var delegate: DepositOverlayViewDelegate?
    private var currentAmount: String = "0"
    private var hasDecimal = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupKeyboard()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupKeyboard()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        
        // Background view with blur effect
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        
        // Amount label
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = "$0.00"
        amountLabel.font = .systemFont(ofSize: 48, weight: .bold)
        amountLabel.textColor = .white
        amountLabel.textAlignment = .center
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.5
        
        // Keyboard view
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.backgroundColor = .clear
        
        // Deposit button
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        depositButton.setTitle("Deposit", for: .normal)
        depositButton.setTitleColor(.white, for: .normal)
        depositButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        depositButton.backgroundColor = UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0)
        depositButton.layer.cornerRadius = 12
        depositButton.addTarget(self, action: #selector(depositButtonTapped), for: .touchUpInside)
        
        // Cancel button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Add subviews
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(amountLabel)
        containerView.addSubview(keyboardView)
        containerView.addSubview(depositButton)
        containerView.addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background view
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container view
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            containerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
            
            // Amount label
            amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            amountLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Keyboard view
            keyboardView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 40),
            keyboardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            keyboardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            keyboardView.heightAnchor.constraint(equalToConstant: 300),
            
            // Deposit button
            depositButton.topAnchor.constraint(equalTo: keyboardView.bottomAnchor, constant: 30),
            depositButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            depositButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            depositButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel button
            cancelButton.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupKeyboard() {
        let buttonSize: CGFloat = 60
        let spacing: CGFloat = 10
        let buttonsPerRow = 3
        
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "0", "⌫"]
        
        for (index, number) in numbers.enumerated() {
            let row = index / buttonsPerRow
            let col = index % buttonsPerRow
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(number, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
            button.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            button.layer.cornerRadius = buttonSize / 2
            button.tag = index
            button.addTarget(self, action: #selector(keyboardButtonTapped(_:)), for: .touchUpInside)
            
            keyboardView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize),
                button.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: CGFloat(col) * (buttonSize + spacing)),
                button.topAnchor.constraint(equalTo: keyboardView.topAnchor, constant: CGFloat(row) * (buttonSize + spacing))
            ])
        }
    }
    
    // MARK: - Public Methods
    func show() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.alpha = 1
            self.transform = .identity
        })
    }
    
    func hide(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            completion?()
        }
    }
    
    // MARK: - Actions
    @objc private func keyboardButtonTapped(_ sender: UIButton) {
        let buttonText = sender.title(for: .normal) ?? ""
        
        switch buttonText {
        case "⌫":
            if currentAmount.count > 1 {
                currentAmount.removeLast()
                if currentAmount == "0" {
                    currentAmount = "0"
                }
            } else {
                currentAmount = "0"
            }
            hasDecimal = currentAmount.contains(".")
            
        case ".":
            if !hasDecimal {
                currentAmount += "."
                hasDecimal = true
            }
            
        default:
            if currentAmount == "0" && buttonText != "." {
                currentAmount = buttonText
            } else {
                currentAmount += buttonText
            }
        }
        
        updateAmountLabel()
    }
    
    @objc private func depositButtonTapped() {
        guard let amount = Double(currentAmount), amount > 0 else { return }
        delegate?.depositOverlayDidCompleteDeposit(amount: amount)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.depositOverlayDidCancel()
    }
    
    // MARK: - Helpers
    private func updateAmountLabel() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let number = Double(currentAmount) {
            amountLabel.text = "$\(formatter.string(from: NSNumber(value: number)) ?? "0.00")"
        } else {
            amountLabel.text = "$0.00"
        }
    }
} 