//
//  Item.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
