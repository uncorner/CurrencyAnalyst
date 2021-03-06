//
//  DetailBankViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by Denis Uncorner on 27.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import Alamofire

class DetailBankViewController: BaseViewController {
    
    @IBOutlet weak var detailBoxTitleLabel: UILabel!
    @IBOutlet weak var exchangeBoxView: ExchangeBoxView!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var officeTableView: UITableView!
    @IBOutlet weak var exchangeExtraInfoStackView: UIStackView!
    @IBOutlet weak var detailBoxView: UIView!
    @IBOutlet weak var officeTableBoxView: UIView!
    @IBOutlet weak var officeTableBoxWrapperView: UIView!
    @IBOutlet weak var officeTableHeaderView: UIView!
    @IBOutlet weak var officeTableTitleLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!
    
    var exchange: CurrencyExchange = CurrencyExchange()
    var officeCellDatas = [ExpandedCellData]()
    var mapUrl: URL?
    let showMapSegue = "showMapSegue"
    private var shouldBeDisplayedOfficeTableBoxView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = exchange.bankName
        setupOfficeTable()
        setupDetailBoxView()
        setupOfficeTableBoxView()
        setupOtherViews()
        loadBankDetailedData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        print(#function)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let strongSelf = self else {return}
            
            if UIWindow.isLandscape {
                strongSelf.officeTableBoxView.isHidden = true
            } else {
                // portrait mode
                if strongSelf.shouldBeDisplayedOfficeTableBoxView {
                    strongSelf.showOfficeTableBoxView()
                }
            }
        })
    }

    private func setupOfficeTable() {
        officeTableView.register(OfficeTableViewCell.nib(), forCellReuseIdentifier: OfficeTableViewCell.cellId)
        officeTableView.register(OfficeTableViewCellHeader.nib(), forCellReuseIdentifier: OfficeTableViewCellHeader.cellId)
        officeTableView.tableFooterView = UIView()
        officeTableView.delegate = self
        officeTableView.dataSource = self
        
        officeTableView.rowHeight = UITableView.automaticDimension
        officeTableView.estimatedRowHeight = 44
        
        officeTableView.backgroundColor = .clear
        officeTableView.separatorStyle = .none
    }
    
    private func setupDetailBoxView() {
        detailBoxView.layer.cornerRadius = Styles.DetailBankViewController.DetailBoxView.cornerRadius
        detailBoxView.backgroundColor = Styles.DetailBankViewController.DetailBoxView.backgroundColor
        
        exchangeBoxView.defaultRateColor = Styles.DetailBankViewController.DetailBoxView.defaultRateColor
        exchangeBoxView.bestRateColor = Styles.DetailBankViewController.DetailBoxView.bestRateColor
        exchangeBoxView.setBuyAtAndSellAtLabel(textColor: Styles.DetailBankViewController.DetailBoxView.buyAtAndSellAtLabelColor)
        exchangeBoxView.setRubleSign(textColor: Styles.DetailBankViewController.DetailBoxView.rubleSignColor)
        
        detailBoxTitleLabel.textColor = Styles.DetailBankViewController.titleLabelColor
        detailBoxTitleLabel.font = Styles.DetailBankViewController.boxTitleFont
        
        exchangeBoxView.setData(exchange, bestRateBackColor: Styles.DetailBankViewController.DetailBoxView.bestRateBackColor)
        updatedTimeLabel.text = "Обновлено \(exchange.updatedTime)"
        updatedTimeLabel.textColor = Styles.DetailBankViewController.DetailBoxView.updatedTimeLabelColor
        
        let euroMessage = getBestExchangeMessage(currencyKind: .Euro, currencyExchange: exchange.euroExchange)
        if !euroMessage.isEmpty {
            addExtraInfo(euroMessage)
        }
        
        let usdMessage = getBestExchangeMessage(currencyKind: .DollarUSA, currencyExchange: exchange.usdExchange)
        if !usdMessage.isEmpty {
            addExtraInfo(usdMessage)
        }
    }
    
    private func setupOfficeTableBoxView() {
        officeTableBoxView.layer.cornerRadius = Styles.cornerRadius1
        officeTableHeaderView.layer.cornerRadius = Styles.cornerRadius1
        officeTableHeaderView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        officeTableBoxView.backgroundColor = Styles.DetailBankViewController.OfficeTableBoxView.backgroundColor
        officeTableHeaderView.backgroundColor = .clear
        officeTableTitleLabel.font = Styles.DetailBankViewController.boxTitleFont
        officeTableTitleLabel.textColor = Styles.DetailBankViewController.titleLabelColor
        
        officeTableBoxWrapperView.backgroundColor = .clear
        officeTableBoxView.isHidden = true
        shouldBeDisplayedOfficeTableBoxView = false
    }
    
    private func setupOtherViews() {
        exchangeExtraInfoStackView.alignment = .leading
        
        mapButton.backgroundColor = Styles.DetailBankViewController.OfficeTableBoxView.mapButtonBackColor
        mapButton.setTitleColor(Styles.DetailBankViewController.OfficeTableBoxView.mapButtonColor, for: .normal)
        mapButton.layer.cornerRadius = mapButton.frame.height / 2

        shareBarButtonItem.image = UIImage(systemName: "square.and.arrow.up")
    }
    
    @IBAction func shareCurrencyRates(_ sender: UIBarButtonItem) {
        let contentText = "\(exchange.bankName) курсы валют на \(exchange.updatedTime) / USD покупка \(exchange.usdExchange.strAmountBuy) ₽ / USD продажа \(exchange.usdExchange.strAmountSell) ₽ / Euro покупка \(exchange.euroExchange.strAmountBuy) ₽ / Euro продажа \(exchange.euroExchange.strAmountSell) ₽"
        
        let vc = UIActivityViewController(activityItems: [contentText], applicationActivities: [])
        
        present(vc, animated: true)
    }
    
    private func addExtraInfo(_ message: String) {
        let button = UIButton()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        button.setTitle(message, for: .normal)
        button.setTitleColor(Styles.DetailBankViewController.DetailBoxView.bestRateColor, for: .normal)
        button.backgroundColor = Styles.DetailBankViewController.DetailBoxView.bestRateBackColor
        button.titleLabel?.font = updatedTimeLabel.font
        
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
        button.layer.cornerRadius = 7
        
        //extraInfoStackView.addArrangedSubview(myLabel)
        exchangeExtraInfoStackView.insertArrangedSubview(button, at: 0)
    }
    
    private func getBestExchangeMessage(currencyKind: CurrencyKind, currencyExchange: CurrencyExchangeUnit) -> String {
        if currencyExchange.isBestBuy == false && currencyExchange.isBestSell == false {
            return ""
        }
        
        var currency = ""
        switch currencyKind {
        case .DollarUSA:
            currency = "USD"
        case .Euro:
            currency = "Euro"
        }
        var text = "Лучший курс"
        
        var text2 = ""
        if currencyExchange.isBestBuy {
            text2 += " покупки"
        }
        if currencyExchange.isBestSell {
            if text2.isEmpty == false {
                text2 += " и"
            }
            text2 += " продажи"
        }
        
        text += text2 + " \(currency)"
        return text
    }

    private func loadBankDetailedData() {
        guard let url = URL(string: self.exchange.fullBankUrl) else {return}
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        activityStartAnimating()
        
        AF.request(url).validate().responseString(completionHandler: { [weak self] response in
            guard let strongSelf = self else {return}
            
            defer {
                strongSelf.navigationController?.navigationBar.isUserInteractionEnabled = true
                strongSelf.activityStopAnimating()
            }
            
            switch response.result {
            case .success(let value):
                let dataSource = strongSelf.getExchangeDataSource()
                var result: BankDetailResult
                do {
                    result = try dataSource.getBankDetail(html: value, url: url)
                }
                catch {
                    strongSelf.processError(error)
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.officeCellDatas = result.dataTables.map({
                        ExpandedCellData(isExpanded: false, officeDataTable: $0)
                    })
                    strongSelf.mapUrl = result.mapUrl
                    
                    strongSelf.shouldBeDisplayedOfficeTableBoxView = true
                    if UIWindow.isLandscape == false {
                        // portrait mode
                        strongSelf.showOfficeTableBoxView()
                    }
                }
            case .failure(let error):
                print(error)
                strongSelf.processError(error)
            }
        })
    }
    
    private func showOfficeTableBoxView() {
        if officeCellDatas.isEmpty {
            return
        }
        
        if mapUrl == nil {
            mapButton.isHidden = true
        }
        
        officeTableBoxView.isHidden = false
        officeTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showMapSegue {
            guard let destination = segue.destination as? MapViewController else { return }
            destination.mapUrl = mapUrl
            destination.title = "\(exchange.bankName) Офисы"
        }
    }
    
}

// MARK: UITableViewDelegate
extension DetailBankViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = officeCellDatas[indexPath.section]
        
        if data.isExpanded == true {
            officeCellDatas[indexPath.section].isExpanded = false
            let sections = IndexSet.init(integer: indexPath.section)
            officeTableView.reloadSections(sections, with: .automatic)
        }
        else {
            officeCellDatas[indexPath.section].isExpanded = true
            let sections = IndexSet.init(integer: indexPath.section)
            officeTableView.reloadSections(sections, with: .automatic)
        }
    }
    
}

// MARK: UITableViewDataSource
extension DetailBankViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return officeCellDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = officeCellDatas[section]
        if data.isExpanded {
            return 2
        }
        return 1
    }
    
    // show cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = officeCellDatas[indexPath.section]
        
        // header cell
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: OfficeTableViewCellHeader.cellId, for: indexPath) as! OfficeTableViewCellHeader
            
            headerCell.headerLabel.text = data.officeDataTable.header
            headerCell.show(isExpanded: data.isExpanded)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            headerCell.selectedBackgroundView = backgroundView
            
            return headerCell
        }
        else {
            // content cell
            let cell = tableView.dequeueReusableCell(withIdentifier: OfficeTableViewCell.cellId, for: indexPath) as! OfficeTableViewCell
            cell.contentStackView.removeAllArrangedSubviews()
            
            for row in data.officeDataTable.rows {
                let label = UILabel()
                label.font = Styles.DetailBankViewController.OfficeTableBoxView.OfficeTableViewCell.contentLabelFont
                label.textColor = Styles.DetailBankViewController.OfficeTableBoxView.OfficeTableViewCell.contentLabelColor
                label.numberOfLines = 0
                label.text = row.header + " " + row.getCombinedDatas()
                cell.contentStackView.addArrangedSubview(label)
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = .clear
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
}
