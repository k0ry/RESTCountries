//
//  CountryDetailsViewController.swift
//  RestCountries
//
//  Created by Filipp Milovanov on 27.04.2022.
//

import Foundation
import MapKit

class CountryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RegionProcessorDelegate{
    @IBOutlet weak var countryFlag: UIView!
    @IBOutlet weak var countryCurrencies: UILabel!
    @IBOutlet weak var countryLanguages: UILabel!
    @IBOutlet weak var countryMap: MKMapView!
    @IBOutlet weak var localTableView: UITableView!
    @IBOutlet weak var favoritesButton: UIButton!
    var isFavorite = false
    var country: Country?
    var currentList:[Country]?

    @IBAction func favoritesAction(_ sender: Any) {
        isFavorite = !isFavorite
        
        if let code = country?.cca2{
            var object = UserDefaults.standard.object(forKey: "Favorites") as? [String:Bool]
            if (object == nil){
                object = [String:Bool]()
            }
            if (isFavorite){
                object![code] = true
            }
            else{
                object?.removeValue(forKey: code)
            }
            UserDefaults.standard.set(object, forKey: "Favorites")
            UserDefaults.standard.synchronize()
        }
        self.setFavoritesImage()
    }
    
    func setFavoritesImage(){
        if (isFavorite) {
            favoritesButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        else{
            favoritesButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    func downloadFinished(_ list:[Country]) {
        currentList = list
        localTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        regionProcessor.delegate=self
        self.updateCountry()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        regionProcessor.delegate=nil
        super.viewWillDisappear(animated)
    }
    
    func updateCountry(){
        if let country = country {
            navigationItem.title = country.name.common
            
            var currencie = ""
            if let currencies = country.currencies{
                for (_, item) in currencies{
                    if (currencie != ""){
                        currencie = currencie + ", "
                    }
                    currencie = currencie + item.name
                }
                if (currencie != ""){
                    currencie = "Currencies: \(currencie)"
                }
            }
            self.countryCurrencies.text = currencie

            var languages = ""
            for (_, item) in country.languages{
                if (languages != ""){
                    languages = languages + ", "
                }
                languages = languages + item
            }
            if (languages != ""){
                languages = "Languages: \(languages)"
            }
            self.countryLanguages.text = languages
            
            if let url = country.flags["png"]{
                let flag = AsyncImage(url: URL(string:url))
                self.countryFlag.layer.cornerRadius = 20
                self.countryFlag.clipsToBounds = true
                flag.frame = CGRect(x: 0, y: 0, width: self.countryFlag.frame.width, height: self.countryFlag.frame.height)
                self.countryFlag.subviews.forEach{$0.removeFromSuperview()}
                self.countryFlag.addSubview(flag)
            }
            self.countryMap.layer.cornerRadius = 20
            self.countryMap.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: country.latlng[0], longitude: country.latlng[1]), latitudinalMeters: 200000, longitudinalMeters: 200000), animated: true)
            
            regionProcessor.fetchNeighbors(country)
            
            let object = UserDefaults.standard.object(forKey: "Favorites") as? [String:Bool]
            if (object != nil){
                if let val = object![country.cca2]{
                    isFavorite = val
                }
                else{
                    isFavorite = false
                }
            }
            self.setFavoritesImage()
        }

    }
    override func viewDidLoad() {
        self.navigationItem.largeTitleDisplayMode = .never
        self.updateCountry()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        if let list = currentList{
            if (list.count == 0){
                cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
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
        }
        return cell
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let list = currentList{
            if (indexPath.row<list.count){
                self.country = list[indexPath.row]
                self.updateCountry()
            }
        }
    }
    
}
