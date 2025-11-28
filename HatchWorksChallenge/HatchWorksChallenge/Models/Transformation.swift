//
//  Transformation.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation

struct Transformation: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let image: URL
    let ki: String
}
