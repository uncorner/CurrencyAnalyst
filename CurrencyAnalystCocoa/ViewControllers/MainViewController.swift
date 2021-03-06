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
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        if isShownMainActivity {
            activityStartAnimating()
        }
        
        if cities.isEmpty {
            AF.request(Constants.Urls.citiesUrl)
                .validate().responseString(completionHandler: { [weak self] response in
                guard let strongSelf = self else {return}
                
                switch response.result {
                case .success(let value):
                    let dataSource = strongSelf.getExchangeDataSource()
                    var result: [City]
                    do {
                        result = try dataSource.getCities(html: value)
                    }
                    catch {
                        strongSelf.processError(error)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.cities = result
                        // load exchanges
                        strongSelf.loadExchanges()
                    }
                case .failure(let error):
                    print(error)
                    strongSelf.stopAllActivityAnimation(strongSelf)
                    strongSelf.processError(error)
                }
            })
        }
        else {
            loadExchanges()
        }
    }
    
    private func loadExchanges() {
        print(#function)
        let url = getFullBankUrl(bankUrl: selectedCityId)
        print("loadExchanges url: \(url.absoluteString); cityId: \(selectedCityId)")
        
        AF.request(url).validate().responseString(completionHandler: { [weak self] response in
            guard let strongSelf = self else {return}
            
            defer {
                strongSelf.navigationController?.navigationBar.isUserInteractionEnabled = true
                strongSelf.stopAllActivityAnimation(strongSelf)
            }
            
            switch response.result {
            case .success(let value):
                let result = strongSelf.getExchangesSafely(html: value)
                
                DispatchQueue.main.async {
                    strongSelf.exchangeListResult = result
                    
                    strongSelf.isNeedUpdate = false
                    // update table
                    strongSelf.tableView.reloadData()
                    
                    if strongSelf.tableView.numberOfRows(inSection: 0) > 0 {
                        strongSelf.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
                    }
                    
                    strongSelf.cbDollarRateLabel.text = result.cbInfo.usdExchangeRate.rateStr
                    strongSelf.cbEuroRateLabel.text = result.cbInfo.euroExchangeRate.rateStr
                    strongSelf.cbBoxView.isHidden = false
                }
            case .failure(let error):
                strongSelf.processError(error)
            }
        })
    }
    
    private func getExchangesSafely(html: String) -> ExchangeListResult {
        let dataSource = getExchangeDataSource()
        var result = ExchangeListResult()
        
        do {
            result = try dataSource.getExchanges(html: html)
        } catch {
            print("\(#function): \(error)")
            result.cbInfo.usdExchangeRate.rateStr = Constants.cbRateStub
            result.cbInfo.euroExchangeRate.rateStr = Constants.cbRateStub
        }
        
        return result
    }
    
    private func stopAllActivityAnimation(_ controller: MainViewController) {
        DispatchQueue.main.async {
            controller.activityStopAnimating()
            controller.tableView.refreshControl?.endRefreshing()
        }
    }
    
    private func getFullBankUrl(bankUrl: String) -> URL {
        let url = URL(string: bankUrl, relativeTo: URL(string: Constants.Urls.sourceSiteUrl) )!
        return url
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
extension MainViewController : UITableViewDelegate {
    
    // selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && exchangeListResult.exchanges.count > 0 {
            performSegue(withIdentifier: showBankDetailSegue, sender: self)
        }
    }
    
}

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
    
}
