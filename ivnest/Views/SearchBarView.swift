//
//  SearchBarView.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

protocol SearchBarViewDelegate: AnyObject {
    func searchBarDidBeginEditing(_ searchBar: SearchBarView)
    func searchBarDidEndEditing(_ searchBar: SearchBarView)
    func searchBar(_ searchBar: SearchBarView, textDidChange text: String)
}

class SearchBarView: UIView {
    
    // MARK: - UI Components
    private let searchContainer = UIView()
    let searchTextField = UITextField()
    private let searchShadowView = UIView()
    
    // MARK: - Properties
    weak var delegate: SearchBarViewDelegate?
    private var isSearchFocused = false
    
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
        // Search container
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        searchContainer.backgroundColor = .clear
        searchContainer.layer.borderWidth = 1.0
        searchContainer.layer.borderColor = UIColor.white.cgColor
        searchContainer.layer.cornerRadius = 12
        searchContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        // Search shadow view
        searchShadowView.translatesAutoresizingMaskIntoConstraints = false
        searchShadowView.backgroundColor = .clear
        searchShadowView.layer.shadowColor = UIColor.white.cgColor
        searchShadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
        searchShadowView.layer.shadowRadius = 12
        searchShadowView.layer.shadowOpacity = 0
        searchShadowView.layer.cornerRadius = 12
        
        // Search text field
        searchTextField.placeholder = "ex. BTC, TSLA, SWPPX"
        searchTextField.font = .systemFont(ofSize: 16, weight: .medium)
        searchTextField.textColor = .white
        searchTextField.backgroundColor = .clear
        searchTextField.borderStyle = .none
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        searchTextField.autocapitalizationType = .allCharacters
        searchTextField.autocorrectionType = .no
        searchTextField.spellCheckingType = .no
        
        // Custom placeholder color
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "ex. BTC, TSLA, SWPPX",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)]
        )
        
        // Add subviews
        searchContainer.addSubview(searchShadowView)
        searchContainer.addSubview(searchTextField)
        addSubview(searchContainer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Search container
            searchContainer.topAnchor.constraint(equalTo: topAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Search shadow view
            searchShadowView.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchShadowView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchShadowView.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            searchShadowView.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            
            // Search text field
            searchTextField.topAnchor.constraint(equalTo: searchContainer.topAnchor, constant: 12),
            searchTextField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -16),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Public Methods
    func focusSearch() {
        isSearchFocused = true
        
        // Animate scale and effects
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.searchContainer.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.searchShadowView.layer.shadowOpacity = 0.3
        })
    }
    
    func unfocusSearch() {
        isSearchFocused = false
        
        // Animate back to normal state
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.searchContainer.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.searchShadowView.layer.shadowOpacity = 0
        })
    }
    
    func setPlaceholder(_ placeholder: String) {
        searchTextField.placeholder = placeholder
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)]
        )
    }
    
    func getText() -> String {
        return searchTextField.text ?? ""
    }
    
    func setText(_ text: String) {
        searchTextField.text = text
    }
    
    func clearText() {
        searchTextField.text = ""
    }
    
    func resignFirstResponder() {
        searchTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension SearchBarView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusSearch()
        delegate?.searchBarDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        unfocusSearch()
        delegate?.searchBarDidEndEditing(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Convert input to uppercase
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string.uppercased())
        textField.text = newText
        
        // Notify delegate of text change
        delegate?.searchBar(self, textDidChange: newText)
        
        return false // Prevent default behavior since we're manually setting the text
    }
} 