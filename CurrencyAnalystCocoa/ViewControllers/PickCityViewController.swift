//
//  SettingsViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by Denis Uncorner on 10.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
//import Alamofire
import RxSwift
import RxCocoa

class PickCityViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var boxView: UIView!
    
    var cities = [City]()
    var filteredCities = [City]()
    var selectedCityId: String?
    
    var setSelectedCityIdCallback: ((String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupOtherViews()
        
        
//        searchBar.rx.text // Наблюдаемое свойство. Спасибо RxCocoa
//            .subscribeNext { [unowned self] (query) in // Здесь мы будем уведомлены о каждом новом значении
//                self.shownCities = self.allCities.filter { $0.hasPrefix(query) } // Здесь мы выполняем "запрос к API", чтобы найти города
//                self.tableView.reloadData() // И перезагружаем данные таблицы
//            }
//            .addDisposableTo(disposeBag)
        
        //        filteredCities = cities.filter({ city -> Bool in
        //            return city.name.caseInsensitiveHasPrefix(searchText)
        //        })

        
        searchBar.rx.text
            .subscribe(onNext: { [weak self] query in
                guard let self = self else {return}
                self.filteredCities = self.cities.filter { city in
                    city.name.caseInsensitiveHasPrefix(query ?? "")
                }
                
                self.tableView.reloadData()
                
            })
            .disposed(by: disposeBag)
    }
    
    private func setupOtherViews() {
        title = "Ваш город"
        boxView.backgroundColor = Styles.PickCityViewController.boxViewBackColor
        boxView.layer.cornerRadius = Styles.cornerRadius1
    }
    
    private func setupSearchBar() {
        //searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .black
        searchBar.placeholder = "Искать"
        
        searchBar.setupStyle(style: Styles.PickCityViewController.searchBarStyle)
    }
    
    private func setupTableView() {
        tableView.register(PickCityTableViewCell.nib(), forCellReuseIdentifier: PickCityTableViewCell.cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        tableView.separatorColor = Styles.PickCityViewController.tableSeparatorColor
        
        // copy array
        filteredCities = cities
        
        if let selectedId = selectedCityId {
            let selectedIndex = cities.firstIndex(where: { item in
                item.id == selectedId
            })
            
            if let index = selectedIndex {
                tableView.scrollToRow(at: IndexPath.init(row: index, section: 0), at: .middle, animated: false)
            }
        }
    }
    
}

// MARK: UITableViewDelegate
extension PickCityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = filteredCities[indexPath.row]
        selectedCityId = city.id
        setSelectedCityIdCallback?(city.id)
        
        tableView.reloadData()
    }
    
}

// MARK: UITableViewDataSource
extension PickCityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PickCityTableViewCell.cellId, for: indexPath) as! PickCityTableViewCell
        
        let city = filteredCities[indexPath.row]
        cell.titleLabel.text = city.name
        cell.checkboxImage.isHidden = city.id != selectedCityId
        
        return cell
    }
    
}

//// MARK: UISearchBarDelegate
//extension PickCityViewController : UISearchBarDelegate {
//    // Search Bar
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard searchText.isEmpty == false else {
//            filteredCities = cities
//            tableView.reloadData()
//            return
//        }
//
//        filteredCities = cities.filter({ city -> Bool in
//            return city.name.caseInsensitiveHasPrefix(searchText)
//        })
//
//        tableView.reloadData()
//    }
//}
