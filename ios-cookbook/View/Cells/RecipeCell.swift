//
//  RecipeCell.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/27/20.
//
import UIKit

internal final class RecipeCell: UITableViewCell, Cell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        dateLabel.text = nil
    }
}
