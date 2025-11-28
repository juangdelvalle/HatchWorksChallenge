//
//  Character.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation

struct Character: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let ki: String
    let maxKi: String
    let race: String
    let gender: String
    let description: String
    let image: URL?
    let affiliation: String
    let transformations: [Transformation]?
}

struct CharactersWrapper: Codable {
    let items: [Character]
}
