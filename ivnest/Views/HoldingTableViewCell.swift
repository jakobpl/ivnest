//
//  HoldingTableViewCell.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit

class HoldingTableViewCell: BaseTableViewCell {
    
    // MARK: - Configuration
    func configure(with holding: Holding) {
        let primaryValue = FormattingUtils.formatCurrency(holding.currentValue)
        let secondaryValue = FormattingUtils.formatCurrency(holding.unrealizedGainLoss)
        let tertiaryValue = String(format: "%.2f%%", holding.unrealizedGainLossPercent)
        
        let secondaryColor = FormattingUtils.colorForValueChange(holding.unrealizedGainLoss)
        let tertiaryColor = FormattingUtils.colorForValueChange(holding.unrealizedGainLossPercent)
        
        super.configure(
            symbol: holding.symbol,
            name: holding.name,
            primaryValue: primaryValue,
            secondaryValue: secondaryValue,
            tertiaryValue: tertiaryValue,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor
        )
    }
} 