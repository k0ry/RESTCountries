//
//  CountriesViewController.swift
//  RestCountries
//
//  Created by Filipp Milovanov on 26.04.2022.
//

import Foundation
import UIKit
import SwiftUI

class CountriesViewController: UIViewController, RegionProcessorDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var localTableView: UITableView!

    var region: String?
    var isDownloadFinished = false
    var anySearch = false
    var currentList: [Country]?
    
    override func viewDidAppear(_ animated: Bool) {
        regionProcessor.delegate=self
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        regionProcessor.delegate=self
        isDownloadFinished = false
        self.localTableView.needsUpdateConstraints()
        
        if (self.navigationController!.tabBarItem.tag == 0) {
            if let curRegion = region{
                regionProcessor.fetchCountries(region)
                self.navigationItem.title="Countries in \(curRegion)"
            }
            searchBar.isHidden = true
        }
        else if (self.navigationController!.tabBarItem.tag == 1) {
            searchBar.isHidden = false
            self.navigationItem.title="Search"
        }
        else {
            regionProcessor.fetchFavourites()
            self.navigationItem.title="Favorites"
            searchBar.isHidden = true
        }
        self.localTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        regionProcessor.delegate=nil
    }
    
    func search(_ phrase: String){
        regionProcessor.searchCountries(phrase)
        self.anySearch = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text{
            self.search(text)
        }
        self.view.endEditing(true)
    }
    
    func emptyCellText()->String{
        var retval = "Loading..."
        let tag = self.navigationController!.tabBarItem.tag
        if (isDownloadFinished){
            if (tag == 0){
                retval = "Download failed"
            }
            else if (tag == 1 && (searchBar.text?.count == 0 || searchBar.text == nil)){
                retval = "Enter search string"
            }
            else if (tag == 1 && searchBar.text!.count > 0 ){
                retval = "Search string not found"
            }
            else if (tag == 2){
                let object = UserDefaults.standard.object(forKey: "Favorites") as? [String:Bool]
                if (object == nil || object!.count == 0){
                    retval = "No favorites found"
                }
                else{
                    retval = "Download failed"
                }
            }
        }
        else{
            if (tag == 0){
                retval = "Loading..."
            }
            else if (tag == 1){
                retval = "Enter search string"
            }
            else if (tag == 2){
                retval = "Loading..."
            }

        }
        return retval
    }
    
    func setupEmptyCell(_ cell: EmptyCell){
        cell.name!.text = self.emptyCellText()
        cell.loading!.startAnimating()
        if (isDownloadFinished){
            cell.loading!.isHidden = true
        }
        else if (self.navigationController!.tabBarItem.tag == 1){
            cell.loading!.isHidden = true
        }
        else{
            cell.loading!.isHidden = false
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if let list = currentList{
            if (list.count == 0){
                cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                if let ccell = cell as? EmptyCell{
                    self.setupEmptyCell(ccell)
                }
            }
            else{
                cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
                
                if let ccell = cell as? CountryCell{
                    let item = list[indexPath.row]
                    ccell.name!.text = item.name.common
                    
                    var nativeName = ""
                    for (_, nName) in item.name.nativeName {
                        if (nName.common != "") {
                            if (nativeName != ""){
                                nativeName = nativeName + ", "
                            }
                            nativeName = nativeName + nName.common
                        }
                    }
                    ccell.nativeName!.text = nativeName
                    
                    ccell.flag!.subviews.forEach{$0.removeFromSuperview()}
                    ccell.flag!.layer.cornerRadius=8
                    ccell.flag!.clipsToBounds = true
                    if let url = item.flags["png"]{
                        let flag = AsyncImage(url: URL(string: url))
                        flag.frame=CGRect(x:0, y:0, width:ccell.flag!.frame.width, height:ccell.flag!.frame.height)
                        ccell.flag!.addSubview(flag)
                    }
                }
            }
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            if let ccell = cell as? EmptyCell{
                self.setupEmptyCell(ccell)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let list = currentList{
            if (indexPath.row < list.count){
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let detailController : CountryDetailsViewController = mainStoryboard.instantiateViewController(withIdentifier: "CountryDetailsViewController") as! CountryDetailsViewController
                self.navigationController?.pushViewController(detailController, animated: true)
                detailController.country = list[indexPath.row]
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = currentList{
            if (list.count == 0){
                return 1
            }
            else{
                return list.count
            }
        }
        else{
            return 1
        }
    }
    
    func downloadFinished(_ list:[Country]) {
        currentList = list
        self.localTableView.reloadData()
        isDownloadFinished = true
    }
}
