//
//  CountryCell.swift
//  RestCountries
//
//  Created by Filipp Milovanov on 27.04.2022.
//

import Foundation
import UIKit

class CountryCell:UITableViewCell{
    @IBOutlet weak var flag : UIView?
    @IBOutlet weak var name : UILabel?
    @IBOutlet weak var nativeName : UILabel?
}

class EmptyCell:UITableViewCell{
    @IBOutlet weak var name : UILabel?
    @IBOutlet weak var loading: UIActivityIndicatorView?
}
