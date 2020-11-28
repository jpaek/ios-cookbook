//
//  Recipe+Extensions.swift
//  ios-cookbook
//
//  Created by Jae Paek on 11/27/20.
//

import Foundation
import CoreData

extension Recipe {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
