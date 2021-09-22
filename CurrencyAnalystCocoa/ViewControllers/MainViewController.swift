//
//  MainViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by Denis Uncorner on 05.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import Alamofire
import SwiftEntryKit
import RxAlamofire
import RxSwift
import RxCocoa


class MainViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButtonItem: UIBarButtonItem!
    @IBOutlet weak var cbDollarImageView: UIImageView!
    @IBOutlet weak var cbEuroImageView: UIImageView!
    @IBOutlet weak var cbBoxView: UIView!
    @IBOutlet weak var cbLabel: UILabel!
    @IBOutlet weak var cbRubleSign1Label: UILabel!
    @IBOutlet weak var cbRubleSign2Label: UILabel!
        
    @IBOutlet weak var cbDollarRateLabel: UILabel! {
        didSet {
            cbDollarRateLabel.font = cbDollarRateLabel.font.monospacedDigitFont
        }
    }
    
    @IBOutlet weak var cbEuroRateLabel: UILabel! {
        didSet {
            cbEuroRateLabel.font = cbEuroRateLabel.font.monospacedDigitFont
        }
    }
    
    private let showBankDetailSegue = "showBankDetail"
    private let showPickCitySegue = "showPickCitySegue"
    private var exchangeListResult = ExchangeListResult()
    private var cities = [City]()
    private var selectedCityId = Constants.defaultCityId
    private var isNeedUpdate = true
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad(isRoot: true)

        setupTableView()
        setupOtherViews()
        setupSettingsButton()
        setupNavigationBar()
        loadAppSettings()
        
        setupBinding()
    }
    
    //>>>>>>>
    private let viewModel = MyViewModel()
    
//    private func setupTableViewBinding() {
//
//            viewModel.dataSource
//                .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier,
//                                              cellType: UITableViewCell.self)) {  row, element, cell in
//                    cell.textLabel?.text = "\(element) \(row)"
//                }
//                .addDisposableTo(disposeBag)
//        }
    
    private func setupBinding() {
//        let cities = Observable.of(["Lisbon", "Copenhagen", "London",
//        "Madrid", "Vienna"])
//          cities
//            .bind(to: tableView.rx.items) {
//              (tableView: UITableView, index: Int, element: String) in
//              let cell = UITableViewCell(style: .default,
//        reuseIdentifier: "cell")
//              cell.textLabel?.text = element
//        return cell }
//            .disposed(by: disposeBag)
//        }
        
//        viewModel.dataSource.bind(to: self.tableView.rx.items(cellIdentifier: ExchangeTableViewCell.cellId, cellType: ExchangeTableViewCell.Type)) {row, element, cell in
//
//            //let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.cellId, for: indexPath) as! ExchangeTableViewCell
//
//
//            return cell
//
//        }
        
        //Observable.of(["Lisbon", "Copenhagen", "London", "Madrid", "Vienna"])
        
        viewModel.dataSource.bind(to: self.tableView.rx.items) {(tableView: UITableView, index: Int, element: String) in
            let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.cellId, for: IndexPath(index: index)) as! ExchangeTableViewCell
            cell.bankTitleLabel.text = element
            return cell
        }
        .disposed(by: disposeBag)
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.cellId, for: indexPath) as! ExchangeTableViewCell
        
//        tableView.rx.items(viewModel.exchangeList).(T##source: (UITableView, Int, _) -> UITableViewCell##(UITableView, Int, _) -> UITableViewCell)
        
//        viewModel.exchangeList.bind(to: tableView.rx.items) {
//            (tableView: UITableView, index: Int, element: String) in
//
//
//        }
        
//        var s: Observable<[String]> = Observable.just(["sddd"])
//        s.bind(to: tableView.rx.items(cellIdentifier: String, cellType: Cell.Type)){
//
//        }
        
        //tableView.rx.bind
        
        
        
        
    }
    
    
    
    private func loadAppSettings() {
        let userDefaults = UserDefaults.standard
               selectedCityId = userDefaults.getCityId() ?? Constants.defaultCityId
    }
    
    private func setupNavigationBar() {
        // navigationItem
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = Styles.MainViewController.NavigationBar.titleColor
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Styles.MainViewController.NavigationBar.titleColor,
            NSAttributedString.Key.font: UIFont(name: "Avenir-Oblique", size: 19)! ]
        
        navigationController?.navigationBar.barStyle = .black
    }
    
    private func setupTableView() {
        tableView.register(ExchangeTableViewCell.nib(), forCellReuseIdentifier: ExchangeTableViewCell.cellId)
        tableView.register(InfoExchangeTableViewCell.nib(), forCellReuseIdentifier: InfoExchangeTableViewCell.cellId)
        tableView.register(HeadExchangeTableViewCell.nib(), forCellReuseIdentifier: HeadExchangeTableViewCell.cellId)
        
//        tableView.delegate = self
//        tableView.dataSource = self
//
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Styles.CommonActivityAnimating.activityColor
        refreshControl.addTarget(self, action: #selector(refreshTableView(sender:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.separatorStyle = .none
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.backgroundColor = .clear
    }
    
    private func setupOtherViews() {
        title = "Курсы валют"
        cbDollarImageView.image = UIImage(systemName: "dollarsign.circle")
        cbDollarImageView.tintColor = Styles.MainViewController.Cb.currencySignColor
        cbEuroImageView.image = UIImage(systemName: "eurosign.circle")
        cbEuroImageView.tintColor = Styles.MainViewController.Cb.currencySignColor
        
        cbDollarRateLabel.textColor = Styles.MainViewController.Cb.currencyRateLabelColor
            
        cbEuroRateLabel.textColor = Styles.MainViewController.Cb.currencyRateLabelColor
        
        cbLabel.textColor = Styles.MainViewController.Cb.cbLabelColor
        cbRubleSign1Label.textColor = Styles.MainViewController.Cb.cbRubleSignLabelColor
        cbRubleSign2Label.textColor = Styles.MainViewController.Cb.cbRubleSignLabelColor
        
        cbBoxView.isHidden = true
    }
    
    private func setupSettingsButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(settingsButtonPressed), imageName: "settings_image-1")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isNeedUpdate {
            loadCitiesAndExchanges(isShownMainActivity: true)
        }
        
        deselectTableRow()
    }
    
    private func deselectTableRow() {
        // deselect rows
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: false)
        }
    }
    
    @objc private func refreshTableView(sender: UIRefreshControl) {
        loadCitiesAndExchanges(isShownMainActivity: false)
    }
    
    @objc func settingsButtonPressed() {
        performSegue(withIdentifier: showPickCitySegue, sender: self)
    }
    
    private func loadCitiesAndExchanges(isShownMainActivity: Bool) {
        print(#function)
        guard let exchangeUrl = selectedCityId.toSiteURL() else {return}
        print("loadExchanges url: \(exchangeUrl.absoluteString); selected city id: \(selectedCityId)")
        startActivityAnimatingAndLock(isActivityAnimating: isShownMainActivity)
        
        var citiesSeq: Single<[City]?> = Single.just(nil)
        if cities.isEmpty {
            citiesSeq = networkService.getCitiesSeq()
        }
        let exchangesSeq = networkService.getExchangesSeq(exchangeUrl: exchangeUrl)
        
        // комбинируем две последовательности: города и курсы валют, запросы будут выполняться параллельно
        Single.zip(citiesSeq, exchangesSeq)
            .subscribe { [weak self] cities, exchangeListResult in
                guard let self = self else {return}
                DispatchQueue.printCurrentQueue()
                
                if let cities = cities {
                    print("cities loaded")
                    self.cities = cities
                }
                self.exchangeListResult = exchangeListResult
                self.cbDollarRateLabel.text = self.getCbExchangeRateAsText( self.exchangeListResult.cbInfo.usdExchangeRate )
                self.cbEuroRateLabel.text = self.getCbExchangeRateAsText( self.exchangeListResult.cbInfo.euroExchangeRate )
                self.cbBoxView.isHidden = false
                // update table
                self.isNeedUpdate = false
                self.tableView.reloadData()
                // scroll table on top
                if self.tableView.numberOfRows(inSection: 0) > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
                }
                print("exchange list loaded")
                
                
                //>>>>>>>>>>>>>>
                let arr = exchangeListResult.exchanges.map { exchange in
                    exchange.bankName
                }
                
                self.viewModel.dataSource.onNext(arr)
                
                
            } onFailure: { [weak self] (error) in
                self?.processResponseError(error)
            } onDisposed: { [weak self] in
                self?.stopAllActivityAnimatingAndUnlock()
            }
            .disposed(by: disposeBag)
    }
    
    private func getCbExchangeRateAsText(_ exchangeRate: CbCurrencyExchangeRate) -> String {
        if exchangeRate.rate == 0 {
            return Constants.cbRateStub
        }
        return exchangeRate.rateStr
    }
    
    private func stopAllActivityAnimatingAndUnlock() {
        tableView.refreshControl?.endRefreshing()
        stopActivityAnimatingAndUnlock()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showBankDetailSegue {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let controller = segue.destination as? DetailBankViewController else { return }
                controller.exchange = exchangeListResult.exchanges[indexPath.row]
            }
        }
        else if segue.identifier == showPickCitySegue {
            guard cities.count > 0 else {
                return
            }
            guard let controller = segue.destination as? PickCityViewController else { return }
            controller.cities = cities
            controller.selectedCityId = selectedCityId
            
            // set callback
            controller.setSelectedCityIdCallback = { [weak self] cityId in
                guard let strongSelf = self else {return}
                
                strongSelf.isNeedUpdate = strongSelf.selectedCityId != cityId
                if strongSelf.isNeedUpdate {
                    strongSelf.selectedCityId = cityId
                    
                    let userDefaults = UserDefaults.standard
                    userDefaults.setCityId(cityId: cityId)
                }
            }
        }
    }
    
}

// MARK: UITableViewDelegate
//extension MainViewController : UITableViewDelegate {
//
//    // selected row
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 1 && exchangeListResult.exchanges.count > 0 {
//            performSegue(withIdentifier: showBankDetailSegue, sender: self)
//        }
//    }
//
//}

/*
// MARK: UITableViewDataSource
extension MainViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            let exchangeCount = exchangeListResult.exchanges.count
            if exchangeCount > 0 {
                return exchangeCount
            }
            
            if isNeedUpdate {
                return 0
            }
            else {
                // exchanges is empty
                return 1
            }
        }
        else if section == 0 {
            return 1
        }
        
        return 0
    }
    
    // show cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            
            if exchangeListResult.exchanges.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.cellId, for: indexPath) as! ExchangeTableViewCell
                cell.backgroundColor = UIColor.clear
                let backgroundView = UIView()
                backgroundView.backgroundColor = Styles.MainViewController.TableView.exchangeTableViewCellSelectionColor
                cell.selectedBackgroundView = backgroundView
                
                let exchange = exchangeListResult.exchanges[indexPath.row]
                cell.exchangeBoxView.setData(exchange)
                cell.bankTitleLabel.text = exchange.bankName
                cell.exchangeBoxView.hideRubleSign()
                setBankLogoImage(exchange: exchange, cell: cell)
                return cell
            }
            
            // exchanges is empty
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoExchangeTableViewCell.cellId, for: indexPath) as! InfoExchangeTableViewCell
            cell.infoLabel.text = "Не найдено предложений по обмену валюты"
            
            return cell
        }
        else if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HeadExchangeTableViewCell.cellId, for: indexPath) as! HeadExchangeTableViewCell
            
            let city = cities.first(where: {
                $0.id == selectedCityId
            })
            
            let cityName = city?.name ?? ""
            cell.locationLabel.text = cityName
            return cell
        }
        
        return UITableViewCell()
    }
    
    private func setBankLogoImage(exchange: CurrencyExchange, cell: ExchangeTableViewCell) {
        if let logoUrl = exchange.bankLogoUrl?.toSiteURL() {
            cell.logoImageUrl = logoUrl
            
            imageLoader.getImage(imageUrl: logoUrl, completion: { image, imageUrl in
                DispatchQueue.main.async {
                    guard let cellLogoUrl = cell.logoImageUrl else {return}
                    if cellLogoUrl != imageUrl {return}
                    
                    guard let image = image else {
                        // error loading image
                        cell.logoImageView.isHidden = true
                        cell.logoImageView.image = nil
                        return
                    }
                    
                    //cell.logoImageView.image = nil
                    cell.logoImageView.isHidden = false
                    cell.logoImageView.image = image
                }
            })
        }
        else {
            cell.logoImageView.isHidden = true
            cell.logoImageView.image = nil
        }
    }
    
}
 */
