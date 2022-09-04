//
//  DetailBankViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by Denis Uncorner on 27.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import Alamofire
import RxDataSources
import RxSwift
import Foundation

class DetailBankViewController: BaseViewController, MvvmBindableType {
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
    
    var viewModel: DetailBankViewModel!
    
    func bindViewModel() {
        setupBindingsForTableView()
        
        viewModel.exchange.asDriver()
            .drive { [weak self] exchange in
                guard let self = self else {return}
                self.title = exchange.bankName
                self.setDetailBoxViewData(exchange: exchange)
            }
            .disposed(by: disposeBag)
        
        viewModel.loadingStatus
            .asDriver()
            .drive(onNext: { [weak self] status in
                guard let self = self else {return}
                switch status {
                case .loading:
                    self.startActivityAnimatingAndLock()
                case .success:
                    self.stopActivityAnimatingAndUnlock()
                case .fail(let error):
                    self.stopActivityAnimatingAndUnlock()
                    self.processResponseError(error)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOfficeTable()
        setupDetailBoxView()
        setupOfficeTableBoxView()
        setupOtherViews()
        viewModel.loadBankOfficeData()
    }
    
    private func setupBindingsForTableView() {
        let dataSource = RxTableViewSectionedAnimatedDataSource<BankOfficeTableViewSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                guard let self = self else {return UITableViewCell()}
                
                if let headerItem = item as? BankOfficeTableViewItemHeader {
                    let headerCell = tableView.dequeueReusableCell(withIdentifier: OfficeTableViewCellHeader.cellId, for: indexPath) as! OfficeTableViewCellHeader
                    let section = self.viewModel.bankOfficeItemsValue[indexPath.section]
                    headerCell.headerLabel.text = headerItem.text
                    headerCell.show(isExpanded: section.isExpanded)
                    //print("isExpanded: \(section.isExpanded)")
                    
                    let backgroundView = UIView()
                    backgroundView.backgroundColor = .clear
                    headerCell.selectedBackgroundView = backgroundView
                    return headerCell
                }
                else if let dataItem = item as? BankOfficeTableViewItemData {
                    let cell = tableView.dequeueReusableCell(withIdentifier: OfficeTableViewCell.cellId, for: indexPath) as! OfficeTableViewCell
                    cell.contentStackView.removeAllArrangedSubviews()
                    
                    for row in dataItem.officeDataTable.rows {
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
                
                return UITableViewCell()
            })
        
        viewModel.bankOfficeItems
            .asDriver()
            .drive(officeTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // officeTableView.rx.modelSelected(BankOfficeTableViewItem.self)
        officeTableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self = self else {return}
                guard let indexPath = event.element else {return}
                //print(indexPath)
                var sections = self.viewModel.bankOfficeItems.value
                sections[indexPath.section].isExpanded = !sections[indexPath.section].isExpanded
                sections[indexPath.section].uniqueId = UUID().uuidString
                
                let sectionIndex = IndexSet.init(integer: indexPath.section)
                self.officeTableView.reloadSections(sectionIndex, with: .automatic)
                
                self.viewModel.bankOfficeItems.accept(sections)
            }
            .disposed(by: disposeBag)
    }

    private func setupOfficeTable() {
        officeTableView.register(OfficeTableViewCell.nib(), forCellReuseIdentifier: OfficeTableViewCell.cellId)
        officeTableView.register(OfficeTableViewCellHeader.nib(), forCellReuseIdentifier: OfficeTableViewCellHeader.cellId)
        officeTableView.tableFooterView = UIView()
        
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
        updatedTimeLabel.textColor = Styles.DetailBankViewController.DetailBoxView.updatedTimeLabelColor
    }
    
    private func setDetailBoxViewData(exchange: CurrencyExchange) {
        exchangeBoxView.setData(exchange, bestRateBackColor: Styles.DetailBankViewController.DetailBoxView.bestRateBackColor)
        updatedTimeLabel.text = "Обновлено \(exchange.updatedTime)"
        
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
        //officeTableBoxView.isHidden = true
    }
    
    private func setupOtherViews() {
        exchangeExtraInfoStackView.alignment = .leading
        
        mapButton.backgroundColor = Styles.DetailBankViewController.OfficeTableBoxView.mapButtonBackColor
        mapButton.setTitleColor(Styles.DetailBankViewController.OfficeTableBoxView.mapButtonColor, for: .normal)
        mapButton.layer.cornerRadius = mapButton.frame.height / 2
        mapButton.rx.action = viewModel.onShowOfficeMapScreen

        shareBarButtonItem.image = UIImage(systemName: "square.and.arrow.up")
    }
    
    @IBAction func shareCurrencyRates(_ sender: UIBarButtonItem) {
        let exchange = viewModel.exchange.value
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
    
}
