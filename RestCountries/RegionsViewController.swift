//
//  RegionsViewController.swift
//  RestCountries
//
//  Created by Filipp Milovanov on 26.04.2022.
//

import Foundation
import UIKit

class RegionsViewController: UITableViewController{
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = regions[indexPath.row]
        cell?.accessoryType = .disclosureIndicator

        return cell!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let countriesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountriesViewController") as! CountriesViewController
        countriesViewController.region=regions[indexPath.row]
        navigationController?.pushViewController(countriesViewController, animated: true)
    }
}
