//
//  AssetTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class AssetTableViewCell: BaseTableViewCell {
    
    // MARK: - Configuration
    func configure(with stock: Stock) {
        let primaryValue = FormattingUtils.formatCurrency(stock.currentPrice)
        let secondaryValue = FormattingUtils.formatCurrency(stock.change)
        let tertiaryValue = String(format: "%.2f%%", stock.changePercent)
        
        let secondaryColor = FormattingUtils.colorForValueChange(stock.change)
        let tertiaryColor = FormattingUtils.colorForValueChange(stock.changePercent)
        
        super.configure(
            symbol: stock.symbol,
            name: stock.name,
            primaryValue: primaryValue,
            secondaryValue: secondaryValue,
            tertiaryValue: tertiaryValue,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor
        )
    }
    
    func configure(with crypto: Cryptocurrency) {
        let primaryValue = FormattingUtils.formatCurrency(crypto.currentPrice)
        let secondaryValue = FormattingUtils.formatCurrency(crypto.change24h)
        let tertiaryValue = String(format: "%.2f%%", crypto.changePercent24h)
        
        let secondaryColor = FormattingUtils.colorForValueChange(crypto.change24h)
        let tertiaryColor = FormattingUtils.colorForValueChange(crypto.changePercent24h)
        
        super.configure(
            symbol: crypto.symbol,
            name: crypto.name,
            primaryValue: primaryValue,
            secondaryValue: secondaryValue,
            tertiaryValue: tertiaryValue,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor
        )
    }
} 