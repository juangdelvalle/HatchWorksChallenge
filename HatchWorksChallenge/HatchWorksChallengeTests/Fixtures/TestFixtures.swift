//
//  TestFixtures.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation
@testable import HatchWorksChallenge

@MainActor
struct TestFixtures {
    
    static let gokuJson = """
        {
          "id": 1,
          "name": "Goku",
          "ki": "60.000.000",
          "maxKi": "90 Septillion",
          "race": "Saiyan",
          "gender": "Male",
          "description": "Test description",
          "image": "https://dragonball-api.com/characters/goku_normal.webp",
          "affiliation": "Z Fighter",
          "transformations": [
            {
              "id": 1,
              "name": "Goku SSJ",
              "image": "https://dragonball-api.com/transformaciones/goku_ssj.webp",
              "ki": "3 Billion",
              "deletedAt": null
            },
            {
              "id": 2,
              "name": "Goku SSJ2",
              "image": "https://dragonball-api.com/transformaciones/goku_ssj2.webp",
              "ki": "6 Billion",
              "deletedAt": null
            },
            {
              "id": 3,
              "name": "Goku SSJ3",
              "image": "https://dragonball-api.com/transformaciones/goku_ssj3.webp",
              "ki": "24 Billion",
              "deletedAt": null
            },
            {
              "id": 4,
              "name": "Goku SSJ4",
              "image": "https://dragonball-api.com/transformaciones/goku_ssj4.webp",
              "ki": "2 Quadrillion",
              "deletedAt": null
            },
            {
              "id": 5,
              "name": "Goku SSJB",
              "image": "https://dragonball-api.com/transformaciones/goku_ssjb.webp",
              "ki": "9 Quintillion",
              "deletedAt": null
            },
            {
              "id": 44,
              "name": "Goku Ultra Instinc",
              "image": "https://dragonball-api.com/transformaciones/goku_ultra.webp",
              "ki": "90 Septillion",
              "deletedAt": null
            }
          ]
        }
        """.data(using: .utf8)!
    
    static let bulmaJson = """
        {
          "id": 4,
          "name": "Bulma",
          "ki": "0",
          "maxKi": "0",
          "race": "Human",
          "gender": "Female",
          "description": "Bulma es la protagonista femenina de la serie manga Dragon Ball y sus adaptaciones al anime Dragon Ball, Dragon Ball Z, Dragon Ball Super y Dragon Ball GT. Es hija del Dr. Brief y su esposa Panchy, hermana menor de Tights y una gran amiga de Son Goku con quien inicia la búsqueda de las Esferas del Dragón. En Dragon Ball Z tuvo a Trunks, primogénito de quien sería su esposo Vegeta, a su hija Bra[3] y su hijo adulto del tiempo alterno Trunks del Futuro Alternativo.",
          "image": "https://dragonball-api.com/characters/bulma.webp",
          "affiliation": "Z Fighter",
          "deletedAt": null,
          "transformations": []
        }
        """.data(using: .utf8)!
    
    static let zarbonJson = """
            {
              "id": 6,
              "name": "Zarbon",
              "ki": "20.000",
              "maxKi": "30.000",
              "race": "Frieza Race",
              "gender": "Male",
              "description": "Zarbon es uno de los secuaces de Freezer y un luchador poderoso.",
              "image": "https://dragonball-api.com/characters/zarbon.webp",
              "affiliation": "Army of Frieza",
              "deletedAt": null,
              "transformations": [
                {
                  "id": 18,
                  "name": "Zarbon Monster",
                  "image": "https://dragonball-api.com/transformaciones/zarbon monster.webp",
                  "ki": "30.000",
                  "deletedAt": null
                }
              ]
            }
    """.data(using: .utf8)!
    
    static let characterWithoutImageJson = """
        {
          "id": 7,
          "name": "Dodoria",
          "ki": "18.000",
          "maxKi": "20.000",
          "race": "Frieza Race",
          "gender": "Male",
          "description": "Test character without image",
          "image": null,
          "affiliation": "Army of Frieza",
          "deletedAt": null,
        }
        """.data(using: .utf8)!
    
    static let charactersWrapperJson = """
        {
          "items": [
                {
                  "id": 4,
                  "name": "Bulma",
                  "ki": "0",
                  "maxKi": "0",
                  "race": "Human",
                  "gender": "Female",
                  "description": "Bulma es la protagonista femenina de la serie manga Dragon Ball y sus adaptaciones al anime Dragon Ball, Dragon Ball Z, Dragon Ball Super y Dragon Ball GT. Es hija del Dr. Brief y su esposa Panchy, hermana menor de Tights y una gran amiga de Son Goku con quien inicia la búsqueda de las Esferas del Dragón. En Dragon Ball Z tuvo a Trunks, primogénito de quien sería su esposo Vegeta, a su hija Bra[3] y su hijo adulto del tiempo alterno Trunks del Futuro Alternativo.",
                  "image": "https://dragonball-api.com/characters/bulma.webp",
                  "affiliation": "Z Fighter",
                  "deletedAt": null,
                  "transformations": []
                },
                {
                  "id": 7,
                  "name": "Dodoria",
                  "ki": "18.000",
                  "maxKi": "20.000",
                  "race": "Frieza Race",
                  "gender": "Male",
                  "description": "Test character without image",
                  "image": null,
                  "affiliation": "Army of Frieza",
                  "deletedAt": null,
                }
            ]
        }
        """.data(using: .utf8)!
    
    static let invalidJson = "This is not json".data(using: .utf8)!
    
    // MARK: - Characters fixtures
    static var goku: Character {
        try! JSONDecoder().decode(Character.self, from: gokuJson)
    }
    
    static var bulma: Character {
        try! JSONDecoder().decode(Character.self, from: bulmaJson)
    }
    
    static var zarbon: Character {
        try! JSONDecoder().decode(Character.self, from: zarbonJson)
    }
    
    static var characterWithoutImage: Character {
        try! JSONDecoder().decode(Character.self, from: characterWithoutImageJson)
    }
    
    // MARK: - Collections
    static var successCharacters: [Character] {
        [bulma, characterWithoutImage]
    }
    
    static var allCharacters: [Character] {
        [goku, bulma, zarbon]
    }
    
    static var firstPageCharacters: [Character] {
        [goku, bulma]
    }
    
    static var secondPageCharacters: [Character] {
        [zarbon]
    }
}
