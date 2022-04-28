//
//  RegionProcessor.swift
//  Countries
//
//  Created by Filipp Milovanov on 26.04.2022.
//

import Foundation

let regions=["Africa", "Americas", "Asia", "Europe", "Oceania"]

var regionProcessor=RegionProcessor()

struct Currency: Codable{
    let name: String
    let symbol: String?
}

struct AnyName: Codable{
    let common: String
    let official: String
}

struct CountryName: Codable{
    let common: String
    let official: String
    let nativeName: [String: AnyName]
}

class Country: Codable{
    let cca2: String
    let name: CountryName
    let flags: [String: String]
    let currencies: [String: Currency]?
    let languages: [String: String]
    let latlng: [Double]
    let borders: [String]?
    var neighbors : [Country]?
    let flag: String?
}

struct Region: Codable{
    let userId: Int
    let id: Int
    let title: String
}

protocol RegionProcessorDelegate{
    func downloadFinished(_ countryList:[Country])
}

class RegionProcessor: ObservableObject{
    var delegate: RegionProcessorDelegate?

    func internalFetch(_ url:URL){
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.handleClientError(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      self.handleServerError(response)
                      return
                  }
            if let data = data
            {
                DispatchQueue.main.async {
                    let decoder=JSONDecoder()
                    let decodedCountries=try! decoder.decode([Country].self, from: data)
                    self.finishDownload(decodedCountries)
                }
            }
        }
        task.resume()

    }
    func fetchCountries(_ region:String! ) {
        let url = URL(string: "https://restcountries.com/v3.1/region/"+region)!
        self.internalFetch(url)
    }

    func searchCountries(_ phrase: String ) {
        let url = URL(string: "https://restcountries.com/v3.1/name/"+phrase)!
        self.internalFetch(url)
    }

    func fetchNeighbors(_ country: Country ) {
        var neighbors = ""
        if let borders = country.borders{
            for item in borders {
                if (neighbors != ""){
                    neighbors = neighbors + ","
                }
                neighbors = neighbors + item
            }
        }
        if (neighbors != "") {
            let url = URL(string: "https://restcountries.com/v3.1/alpha?codes="+neighbors)!
            self.internalFetch(url)
        }
    }

    func fetchFavourites() {
        let object = UserDefaults.standard.object(forKey: "Favorites") as? [String:Bool]
        if (object == nil){
            self.finishDownload([Country]())
        }
        else{
            var favourites = ""
            for item in object! {
                if (item.value){
                if (favourites != ""){
                    favourites = favourites + ","
                }
                    favourites = favourites + item.key
                    
                }
            }
            if (favourites != "") {
                let url = URL(string: "https://restcountries.com/v3.1/alpha?codes="+favourites)!
                self.internalFetch(url)
            }
            else{
                self.finishDownload([Country]())
            }
        }
    }

    func finishDownload(_ array:[Country]){
        if let unwrappedDelegate = self.delegate {
            unwrappedDelegate.downloadFinished(array)
        }
    }
    func handleServerError(_ response:URLResponse?){
        DispatchQueue.main.async {
            self.finishDownload([Country]())
        }
    }
    func handleClientError(_ error:Error){
        DispatchQueue.main.async {
            self.finishDownload([Country]())
        }
    }
}
