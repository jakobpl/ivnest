//
//  WatchlistTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class WatchlistTableViewCell: BaseTableViewCell {
    
    // MARK: - Configuration
    func configure(with watchlistItem: WatchlistItem) {
        let primaryValue = FormattingUtils.formatCurrency(watchlistItem.currentPrice)
        let secondaryValue = FormattingUtils.formatCurrency(watchlistItem.priceChange)
        let tertiaryValue = String(format: "%.2f%%", watchlistItem.priceChangePercent)
        
        let secondaryColor = FormattingUtils.colorForValueChange(watchlistItem.priceChange)
        let tertiaryColor = FormattingUtils.colorForValueChange(watchlistItem.priceChangePercent)
        
        super.configure(
            symbol: watchlistItem.symbol,
            name: watchlistItem.name,
            primaryValue: primaryValue,
            secondaryValue: secondaryValue,
            tertiaryValue: tertiaryValue,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor
        )
    }
} 