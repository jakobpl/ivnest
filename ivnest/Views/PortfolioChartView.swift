//
//  PortfolioChartView.swift
//  ivnest
//
//  Created by jakob n on 7/8/25.
//

import UIKit
import Foundation
import ivnest // If your models are in a module named ivnest

protocol PortfolioChartViewDelegate: AnyObject {
    func didSelectTimePeriod(_ period: TimePeriod)
}

enum TimePeriod: String, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case fiveYears = "5Y"
    case max = "MAX"
    
    var days: Int {
        switch self {
        case .oneDay: return 1
        case .oneWeek: return 7
        case .oneMonth: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .oneYear: return 365
        case .fiveYears: return 1825
        case .max: return 3650 // 10 years
        }
    }
}

class PortfolioChartView: UIView {
    
    // MARK: - UI Components
    private let chartContainerView = UIView()
    private let chartView = UIView()
    private let timePeriodStackView = UIStackView()
    private let valueLabel = UILabel()
    private let changeLabel = UILabel()
    private let changePercentLabel = UILabel()
    
    // MARK: - Properties
    weak var delegate: PortfolioChartViewDelegate?
    private var selectedPeriod: TimePeriod = .oneMonth
    private var portfolioData: [PortfolioDataPoint] = []
    private var chartLayer: CAShapeLayer?
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        generateEmptyData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        
        // Setup value labels
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        changeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        changePercentLabel.font = .systemFont(ofSize: 16, weight: .medium)
        changePercentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup chart container
        chartContainerView.translatesAutoresizingMaskIntoConstraints = false
        chartContainerView.backgroundColor = .clear
        
        // Setup chart view
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .clear
        
        // Setup time period stack view
        timePeriodStackView.translatesAutoresizingMaskIntoConstraints = false
        timePeriodStackView.axis = .horizontal
        timePeriodStackView.distribution = .fillEqually
        timePeriodStackView.spacing = 8
        
        // Add subviews
        addSubview(valueLabel)
        addSubview(changeLabel)
        addSubview(changePercentLabel)
        addSubview(chartContainerView)
        chartContainerView.addSubview(chartView)
        addSubview(timePeriodStackView)
        
        setupTimePeriodButtons()
        updateValueLabels()
    }
    
    private func setupTimePeriodButtons() {
        for period in TimePeriod.allCases {
            let button = createTimePeriodButton(for: period)
            timePeriodStackView.addArrangedSubview(button)
        }
    }
    
    private func createTimePeriodButton(for period: TimePeriod) -> UIButton {
        let button = UIButton()
        button.setTitle(period.rawValue, for: .normal)
        button.setTitleColor(UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0), for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.clear.cgColor
        button.tag = TimePeriod.allCases.firstIndex(of: period) ?? 0
        button.addTarget(self, action: #selector(timePeriodButtonTapped(_:)), for: .touchUpInside)
        
        // Set initial selection
        if period == selectedPeriod {
            button.isSelected = true
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
        }
        
        return button
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            changeLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            changeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            changePercentLabel.topAnchor.constraint(equalTo: changeLabel.topAnchor),
            changePercentLabel.leadingAnchor.constraint(equalTo: changeLabel.trailingAnchor, constant: 8),
            
            chartContainerView.topAnchor.constraint(equalTo: changeLabel.bottomAnchor, constant: 16),
            chartContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chartContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chartContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            chartView.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor),
            
            timePeriodStackView.topAnchor.constraint(equalTo: chartContainerView.bottomAnchor, constant: 16),
            timePeriodStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            timePeriodStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            timePeriodStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            timePeriodStackView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    // MARK: - Actions
    @objc private func timePeriodButtonTapped(_ sender: UIButton) {
        let selectedIndex = sender.tag
        let newPeriod = TimePeriod.allCases[selectedIndex]
        
        // Update button states with animation
        for (index, button) in timePeriodStackView.arrangedSubviews.enumerated() {
            if let button = button as? UIButton {
                button.isSelected = index == selectedIndex
                
                // Animate border and color changes
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                    if button.isSelected {
                        button.backgroundColor = .clear
                        button.layer.borderWidth = 1
                        button.layer.borderColor = UIColor.white.cgColor
                        button.setTitleColor(.white, for: .normal)
                    } else {
                        button.backgroundColor = .clear
                        button.layer.borderWidth = 0
                        button.layer.borderColor = UIColor.clear.cgColor
                        button.setTitleColor(UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0), for: .normal)
                    }
                })
            }
        }
        
        selectedPeriod = newPeriod
        delegate?.didSelectTimePeriod(newPeriod)
        updateChart()
    }
    
    // MARK: - Data Management
    private func generateEmptyData() {
        let calendar = Calendar.current
        let now = Date()
        
        portfolioData = []
        
        // Create empty data for the last 365 days
        for i in 0..<365 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            
            let dataPoint = PortfolioDataPoint(
                date: date,
                value: 0.0,
                change: 0.0,
                changePercent: 0.0
            )
            
            portfolioData.append(dataPoint)
        }
        
        portfolioData.reverse() // Oldest to newest
        updateChart()
    }
    
    private func updateValueLabels() {
        guard let latestData = portfolioData.last else { 
            // Show 0 values when no data
            valueLabel.text = FormattingUtils.formatCurrency(0.0)
            changeLabel.text = FormattingUtils.formatCurrency(0.0)
            changeLabel.textColor = .systemGray
            changePercentLabel.text = "0.00%"
            changePercentLabel.textColor = .systemGray
            return 
        }
        
        valueLabel.text = FormattingUtils.formatCurrency(latestData.value)
        changeLabel.text = FormattingUtils.formatCurrency(latestData.change)
        changeLabel.textColor = latestData.change >= 0 ? .systemGreen : .systemRed
        
        changePercentLabel.text = String(format: "%.2f%%", latestData.changePercent)
        changePercentLabel.textColor = latestData.changePercent >= 0 ? .systemGreen : .systemRed
    }
    
    // MARK: - Chart Drawing
    private func updateChart() {
        // Remove existing layers
        chartLayer?.removeFromSuperlayer()
        gradientLayer?.removeFromSuperlayer()
        
        // Filter data based on selected period
        let filteredData = filterDataForPeriod(selectedPeriod)
        
        // Draw new chart
        drawChart(with: filteredData)
        updateValueLabels()
    }
    
    private func filterDataForPeriod(_ period: TimePeriod) -> [PortfolioDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -period.days, to: now) ?? now
        
        return portfolioData.filter { $0.date >= startDate }
    }
    
    private func drawChart(with data: [PortfolioDataPoint]) {
        guard !data.isEmpty else { 
            // Draw empty chart
            drawEmptyChart()
            return 
        }
        
        let chartWidth = chartView.bounds.width
        let chartHeight = chartView.bounds.height
        
        guard chartWidth > 0 && chartHeight > 0 else { return }
        
        // Find min and max values for scaling
        let values = data.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let valueRange = maxValue - minValue
        
        // Create path
        let path = UIBezierPath()
        let pointSpacing = chartWidth / CGFloat(data.count - 1)
        
        for (index, dataPoint) in data.enumerated() {
            let x = CGFloat(index) * pointSpacing
            let normalizedValue = (dataPoint.value - minValue) / valueRange
            let y = chartHeight - (normalizedValue * chartHeight)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        // Create gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = chartView.bounds
        gradientLayer.colors = [
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.8).cgColor,
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.2).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Create mask for gradient
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = 2
        maskLayer.lineCap = .round
        maskLayer.lineJoin = .round
        
        // Create fill path
        let fillPath = UIBezierPath(cgPath: path.cgPath)
        fillPath.addLine(to: CGPoint(x: chartWidth, y: chartHeight))
        fillPath.addLine(to: CGPoint(x: 0, y: chartHeight))
        fillPath.close()
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = fillPath.cgPath
        fillLayer.fillColor = UIColor.white.cgColor
        
        // Add layers
        gradientLayer.mask = fillLayer
        chartView.layer.addSublayer(gradientLayer)
        chartView.layer.addSublayer(maskLayer)
        
        // Store references
        self.gradientLayer = gradientLayer
        self.chartLayer = maskLayer
        
        // Animate the chart
        animateChart()
    }
    
    private func drawEmptyChart() {
        // Remove existing layers
        chartLayer?.removeFromSuperlayer()
        gradientLayer?.removeFromSuperlayer()
        
        let chartWidth = chartView.bounds.width
        let chartHeight = chartView.bounds.height
        
        guard chartWidth > 0 && chartHeight > 0 else { return }
        
        // Create a flat line at the bottom
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: chartHeight))
        path.addLine(to: CGPoint(x: chartWidth, y: chartHeight))
        
        // Create the line layer
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.5).cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineCap = .round
        
        chartView.layer.addSublayer(lineLayer)
        self.chartLayer = lineLayer
    }
    
    private func animateChart() {
        guard let chartLayer = chartLayer else { return }
        
        // Reset stroke end
        chartLayer.strokeEnd = 0
        
        // Animate to full stroke
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        chartLayer.add(animation, forKey: "strokeAnimation")
        chartLayer.strokeEnd = 1
    }
    
    // MARK: - Public Methods
    func updatePortfolioValue(_ value: Double, change: Double, changePercent: Double) {
        // Update the latest data point
        if var latestData = portfolioData.last {
            latestData = PortfolioDataPoint(
                date: latestData.date,
                value: value,
                change: change,
                changePercent: changePercent
            )
            portfolioData[portfolioData.count - 1] = latestData
        }
        
        updateValueLabels()
        updateChart()
    }
    
    func updateWithPortfolioData(_ portfolioData: [PortfolioDataPoint]) {
        self.portfolioData = portfolioData
        updateValueLabels()
        updateChart()
    }
    
    func updateWithEmptyPortfolio() {
        generateEmptyData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw chart when view layout changes
        DispatchQueue.main.async { [weak self] in
            self?.updateChart()
        }
    }
} 