//
//  SettingsViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by Denis Uncorner on 10.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class PickCityViewController: BaseViewController, MvvmBindableType {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var boxView: UIView!
    
    var viewModel: PickCityViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupOtherViews()
    }
    
    func bindViewModel() {
        let dataSource = RxTableViewSectionedAnimatedDataSource<CitySectionModel>{ [weak self] dataSource, tableView, indexPath, city in
            guard let self = self else {return UITableViewCell()}
            
            let cell = tableView.dequeueReusableCell(withIdentifier: PickCityTableViewCell.cellId, for: indexPath) as! PickCityTableViewCell
            cell.titleLabel.text = city.name
            cell.checkboxImage.isHidden = city.id != self.viewModel.selectedCityId
            return cell
        }
        
        viewModel.filteredCities
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(City.self)
            .asDriver()
            .drive { [weak self] city in
                self?.viewModel.selectedCityId = city.id
                //self?.setSelectedCityIdCallback?(city.id)
                self?.viewModel.setSelectedCityIdCallback(city.id)
                self?.tableView.reloadData()
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)

        // scroll after content binding
        scrollTableViewToSelectedItem()
    }
    
    private func scrollTableViewToSelectedItem() {
        if let selectedId = viewModel.selectedCityId {
            let selectedIndex = viewModel.cities.firstIndex(where: { item in
                item.id == selectedId
            })
            
            if let index = selectedIndex {
                tableView.scrollToRow(at: IndexPath.init(row: index, section: 0), at: .middle, animated: false)
            }
        }
    }
    
    private func setupOtherViews() {
        title = "Ваш город"
        boxView.backgroundColor = Styles.PickCityViewController.boxViewBackColor
        boxView.layer.cornerRadius = Styles.cornerRadius1
    }
    
    private func setupSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .black
        searchBar.placeholder = "Искать"
        
        searchBar.setupStyle(style: Styles.PickCityViewController.searchBarStyle)
    }
    
    private func setupTableView() {
        tableView.register(PickCityTableViewCell.nib(), forCellReuseIdentifier: PickCityTableViewCell.cellId)
        tableView.backgroundColor = .clear
        tableView.separatorColor = Styles.PickCityViewController.tableSeparatorColor
    }
    
}
