//
//  CategoryCell.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/27/20.
//

import UIKit

internal final class CategoryCell: UITableViewCell, Cell {
    // Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pageCountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        pageCountLabel.text = nil
    }

}

