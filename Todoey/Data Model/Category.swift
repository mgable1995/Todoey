//
//  Category.swift
//  Todoey
//
//  Created by Michael Gable on 10/8/18.
//  Copyright © 2018 Michael Gable. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
}
