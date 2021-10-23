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
import RxDataSources
import Action


class ExchangeListViewController: BaseViewController, MvvmBindableType {
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
    
    var viewModel: ExchangeListViewModel!
    private let showBankDetailSegue = "showBankDetail"
    //private let showPickCitySegue = "showPickCitySegue"
    private let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad(isRoot: true)

        setupTableView()
        setupOtherViews()
        setupSettingsButton()
        setupNavigationBar()
        viewModel.loadAppSettings()
    }
    
    func bindViewModel() {
        setupBindingsForTableView()
        
        viewModel.cbDollarRate
            .do(onNext: { [weak self] _ in
                self?.cbBoxView.isHidden = false
            })
            .drive(cbDollarRateLabel.rx.text)
            .disposed(by: disposedBag)
        
        viewModel.cbEuroRate
            .drive(cbEuroRateLabel.rx.text)
            .disposed(by: disposedBag)
        
        var settingsButton = navigationItem.rightBarButtonItem
        settingsButton?.rx.action = viewModel.onShowPickCity
    }
    
    private func setupBindingsForTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<ExchangeTableViewSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, item in
                switch item {
                case .ExchangeItem(let exchange):
                    let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.cellId, for: indexPath) as! ExchangeTableViewCell
                    cell.backgroundColor = UIColor.clear
                    let backgroundView = UIView()
                    backgroundView.backgroundColor = Styles.MainViewController.TableView.exchangeTableViewCellSelectionColor
                    cell.selectedBackgroundView = backgroundView
                    cell.exchangeBoxView.setData(exchange)
                    cell.bankTitleLabel.text = exchange.bankName
                    cell.exchangeBoxView.hideRubleSign()
                    self?.setBankLogoImage(exchange: exchange, cell: cell)
                    return cell
                    
                case .HeadItem(let cityName):
                    let cell = tableView.dequeueReusableCell(withIdentifier: HeadExchangeTableViewCell.cellId, for: indexPath) as! HeadExchangeTableViewCell
                    cell.locationLabel.text = cityName
                    return cell
                }
            })
        
        viewModel.exchangeItems
            .do(afterNext: { [weak self] _ in
                self?.tableView.scrollOnTop()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ExchangeTableViewItem.self)
            .asDriver()
            .drive { [weak self] item in
                guard let self = self else {return}
                switch item{
                case .HeadItem(_):
                    // do nothing
                    break
                case .ExchangeItem(let exchange):
                    self.performSegue(withIdentifier: self.showBankDetailSegue, sender: exchange)
                    break
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.loadingStatus
            .drive(onNext: { [weak self] status in
                guard let self = self else {return}
                
                switch status {
                case .loading:
                    if self.viewModel.isNeedAutoUpdate {
                        self.startActivityAnimatingAndLock()
                    }
                    break
                case .success:
                    self.stopAllActivityAnimationAndUnlock()
                    break
                case .fail(let error):
                    self.stopAllActivityAnimationAndUnlock()
                    self.processResponseError(error)
                    break
                default:
                    break
                }
            })
            .disposed(by: disposedBag)
    }
    
    private func stopAllActivityAnimationAndUnlock() {
        if viewModel.isNeedAutoUpdate {
            stopActivityAnimatingAndUnlock()
        }
        else {
            tableView.refreshControl?.endRefreshing()
        }
        viewModel.isNeedAutoUpdate = false
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
        
        var refreshControl = UIRefreshControl()
        refreshControl.tintColor = Styles.CommonActivityAnimating.activityColor
        //refreshControl.addTarget(self, action: #selector(refreshTableView(sender:)), for: .valueChanged)
        refreshControl.rx.action = viewModel.onLoadCitiesAndExchanges
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings_image-1"), style: UIBarButtonItem.Style.plain, target: self, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.isNeedAutoUpdate {
            viewModel.onLoadCitiesAndExchanges.execute()
        }
        
        tableView.deselectRowIfSelected()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showBankDetailSegue {
            guard let exchange = sender as? CurrencyExchange else {return}
            guard let controller = segue.destination as? DetailBankViewController else { return }
            controller.exchange = exchange
        }
        /*
        else if segue.identifier == showPickCitySegue {
            guard viewModel.cities.count > 0 else {
                return
            }
            guard let controller = segue.destination as? PickCityViewController else { return }
            
            //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            //controller.cities = viewModel.cities
            //controller.selectedCityId = viewModel.selectedCityId
            controller.modelView = PickCityViewModel(cities: viewModel.cities)
            controller.modelView.selectedCityId = viewModel.selectedCityId
            
            // set callback
            controller.setSelectedCityIdCallback = { [weak self] cityId in
                guard let self = self else {return}
                
                self.isNeedAutoUpdate = self.viewModel.selectedCityId != cityId
                
                if self.isNeedAutoUpdate {
                    self.viewModel.selectedCityId = cityId
                    
                    let userDefaults = UserDefaults.standard
                    userDefaults.setCityId(cityId: cityId)
                }
            }
        }*/
    }
    
}

