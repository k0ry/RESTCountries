//
//  ViewController.swift
//  RestCountries
//
//  Created by Filipp Milovanov on 26.04.2022.
//

import UIKit

class ViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        createInterface()
    }
    
    func createInterface(){
        viewControllers = [
            createNavigationController(for: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegionsViewController") as! RegionsViewController, title: "Explore", image: UIImage(systemName: "sun.min.fill")!, tag: 0),
            createNavigationController(for: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountriesViewController") as! CountriesViewController, title: "Search", image: UIImage(systemName:"location.magnifyingglass")!, tag: 1),
            createNavigationController(for: UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CountriesViewController") as! CountriesViewController, title: "Favorites", image: UIImage(systemName: "star")!, tag: 2)
        ]
    }
    
    func createNavigationController(for rootViewController:UIViewController, title: String, image: UIImage, tag: Int)->UIViewController{
        let navController=UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.tabBarItem.tag = tag
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title=title
        return navController
    }
    
}

