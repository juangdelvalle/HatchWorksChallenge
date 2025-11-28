//
//  TransformationTests.swift
//  HatchWorksChallengeTests
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import XCTest
@testable import HatchWorksChallenge

@MainActor
final class TransformationTests: XCTestCase {
    
    func testDecodeTransformation() {
        let character = TestFixtures.goku
        
        XCTAssertEqual(character.transformations?.count, 6)
        XCTAssertEqual(character.transformations?[0].name, "Goku SSJ")
        XCTAssertEqual(character.transformations?[3].ki, "2 Quadrillion")
    }
    
    @MainActor
    func testEncodeTransformation() throws {
        let character = TestFixtures.goku
        
        let data = try JSONEncoder().encode(character)
        let decodedTranformation = try JSONDecoder().decode(Character.self, from: data)
        
        XCTAssertEqual(character.transformations?[0].id, decodedTranformation.transformations?[0].id)
        XCTAssertEqual(character.transformations?[1].name, decodedTranformation.transformations?[1].name)
        XCTAssertEqual(character.transformations?[2].ki, decodedTranformation.transformations?[2].ki)
    }
}
