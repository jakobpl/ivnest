//
//  FormattingUtils.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import Foundation
import UIKit

struct FormattingUtils {
    
    // MARK: - Currency Formatting
    static func formatCurrency(_ amount: Double, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    // MARK: - Number Formatting
    static func formatNumber(_ number: Double, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    // MARK: - Percentage Formatting
    static func formatPercentage(_ value: Double, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: NSNumber(value: value / 100)) ?? "0%"
    }
    
    // MARK: - Date Formatting
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
    
    static func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Large Number Formatting
    static func formatLargeNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        let absNumber = abs(number)
        let sign = number < 0 ? "-" : ""
        
        switch absNumber {
        case 1_000_000_000_000...:
            return "\(sign)$\(formatter.string(from: NSNumber(value: absNumber / 1_000_000_000_000))!)T"
        case 1_000_000_000...:
            return "\(sign)$\(formatter.string(from: NSNumber(value: absNumber / 1_000_000_000))!)B"
        case 1_000_000...:
            return "\(sign)$\(formatter.string(from: NSNumber(value: absNumber / 1_000_000))!)M"
        case 1_000...:
            return "\(sign)$\(formatter.string(from: NSNumber(value: absNumber / 1_000))!)K"
        default:
            return formatCurrency(number)
        }
    }
    
    // MARK: - Quantity Formatting
    static func formatQuantity(_ quantity: Double, assetType: AssetType) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        
        let formattedQuantity = formatter.string(from: NSNumber(value: quantity)) ?? "0"
        
        switch assetType {
        case .stock:
            return "\(formattedQuantity) shares"
        case .cryptocurrency:
            return "\(formattedQuantity) coins"
        }
    }
    
    // MARK: - Color for Value Changes
    static func colorForValueChange(_ change: Double) -> UIColor {
        return change >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Time Ago Formatting
    static func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        switch interval {
        case 0..<60:
            return "Just now"
        case 60..<3600:
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        case 3600..<86400:
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        case 86400..<2592000:
            let days = Int(interval / 86400)
            return "\(days)d ago"
        case 2592000..<31536000:
            let months = Int(interval / 2592000)
            return "\(months)mo ago"
        default:
            let years = Int(interval / 31536000)
            return "\(years)y ago"
        }
    }
} 
