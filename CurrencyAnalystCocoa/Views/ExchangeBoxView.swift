//
//  ExchangeBoxView.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 20.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class ExchangeBoxView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var dollarStackView: UIStackView!
    @IBOutlet weak var euroStackView: UIStackView!
    
    @IBOutlet weak var usdRateRubleSignLabel: UILabel!
    @IBOutlet weak var usdRubleSignGapView: UIView!
    @IBOutlet weak var euroRateRubleSignLabel: UILabel!
    @IBOutlet weak var euroRubleSignGapView: UIView!
    
    @IBOutlet weak var usdBuyAtLabel: UILabel!
    @IBOutlet weak var usdSellAtLabel: UILabel!
    @IBOutlet weak var euroBuyAtLabel: UILabel!
    @IBOutlet weak var euroSellAtLabel: UILabel!
    
    var defaultRateColor = Styles.ExchangeBoxView.defaultRateColor
    var bestRateColor = Styles.ExchangeBoxView.bestRateColor
    
    let rateLabelPaddingWidth: CGFloat = 5
    
    @IBOutlet weak var usdBuyRateLabel: UILabel! {
        didSet {
            usdBuyRateLabel.font = usdBuyRateLabel.font.monospacedDigitFont
        }
    }
    
    @IBOutlet weak var usdSellRateLabel: UILabel! {
        didSet {
            usdSellRateLabel.font = usdSellRateLabel.font.monospacedDigitFont
        }
    }
    
    @IBOutlet weak var euroBuyRateLabel: UILabel! {
        didSet {
            euroBuyRateLabel.font = euroBuyRateLabel.font.monospacedDigitFont
        }
    }
    
    @IBOutlet weak var euroSellRateLabel: UILabel! {
        didSet {
            euroSellRateLabel.font = euroSellRateLabel.font.monospacedDigitFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("ExchangeBoxView", owner: self, options: nil)![0] as! UIView
                
        viewFromXib.frame = self.bounds
        viewFromXib.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(viewFromXib)
        //invalidateIntrinsicContentSize()
        
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        setBuyAtAndSellAtLabel(textColor: Styles.ExchangeBoxView.buyAtAndSellAtLabelColor)
        
        setupRateLabel(label: usdBuyRateLabel)
        setupRateLabel(label: usdSellRateLabel)
        setupRateLabel(label: euroBuyRateLabel)
        setupRateLabel(label: euroSellRateLabel)
    }
    
    private func setupRateLabel(label: UILabel) {
        let paddedWidth = label.intrinsicContentSize.width + 2 * rateLabelPaddingWidth
        label.widthAnchor.constraint(equalToConstant: paddedWidth).isActive = true
        label.textAlignment = .center
        label.layer.cornerRadius = label.frame.height / 2
        label.layer.masksToBounds = true
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: stackView.frame.width + rateLabelPaddingWidth*2*2,
                      height: stackView.frame.height)
    }
    
    func hideRubleSign() {
        usdRubleSignGapView.isHidden = true
        usdRateRubleSignLabel.isHidden = true
        euroRubleSignGapView.isHidden = true
        euroRateRubleSignLabel.isHidden = true
    }
    
    fileprivate func setAsBestRateLabel(label: UILabel, backColor: UIColor) {
        label.textColor = bestRateColor
        label.backgroundColor = backColor
    }
    
    fileprivate func setAsDefaultRateLabel(label: UILabel) {
        label.textColor = defaultRateColor
        label.backgroundColor = .clear
    }
    
    func setData(_ exchange: CurrencyExchange, bestRateBackColor: UIColor = .clear) {
        usdBuyRateLabel.text = exchange.usdExchange.strAmountBuy
        if exchange.usdExchange.isBestBuy {
            setAsBestRateLabel(label: usdBuyRateLabel, backColor: bestRateBackColor)
        }
        else {
            setAsDefaultRateLabel(label: usdBuyRateLabel)
        }
        
        usdSellRateLabel.text = exchange.usdExchange.strAmountSell
        if exchange.usdExchange.isBestSell {
            setAsBestRateLabel(label: usdSellRateLabel, backColor: bestRateBackColor)
        }
        else {
            setAsDefaultRateLabel(label: usdSellRateLabel)
        }
        
        euroBuyRateLabel.text = exchange.euroExchange.strAmountBuy
        if exchange.euroExchange.isBestBuy {
            setAsBestRateLabel(label: euroBuyRateLabel, backColor: bestRateBackColor)
        }
        else {
            setAsDefaultRateLabel(label: euroBuyRateLabel)
        }
        
        euroSellRateLabel.text = exchange.euroExchange.strAmountSell
        if exchange.euroExchange.isBestSell {
            setAsBestRateLabel(label: euroSellRateLabel, backColor: bestRateBackColor)
        }
        else {
            setAsDefaultRateLabel(label: euroSellRateLabel)
        }
    }
    
    func setBuyAtAndSellAtLabel(textColor: UIColor) {
        usdBuyAtLabel.textColor = textColor
        usdSellAtLabel.textColor = textColor
        euroBuyAtLabel.textColor = textColor
        euroSellAtLabel.textColor = textColor
    }
    
    func setRubleSign(textColor: UIColor) {
        usdRateRubleSignLabel.textColor = textColor
        euroRateRubleSignLabel.textColor = textColor
    }
    
}
