//
//  Item.swift
//  Todoey
//
//  Created by Michael Gable on 9/26/18.
//  Copyright © 2018 Michael Gable. All rights reserved.
//

import Foundation

class Item: Encodable, Decodable {
    var title : String = ""
    var done: Bool = false
}
