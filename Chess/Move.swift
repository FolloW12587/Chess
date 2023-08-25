//
//  Move.swift
//  Chess
//
//  Created by Сергей Дубовой on 23.08.2023.
//

import Foundation


struct Move: Hashable {
    let from: Coordinate
    let to: Coordinate
    let figureTaken: Figure?
    
    init(from: Coordinate, to: Coordinate, figureTaken: Figure? = nil) {
        self.from = from
        self.to = to
        self.figureTaken = figureTaken
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
}
