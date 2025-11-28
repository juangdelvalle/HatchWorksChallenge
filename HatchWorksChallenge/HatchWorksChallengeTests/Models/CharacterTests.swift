//
//  CharacterTests.swift
//  HatchWorksChallengeTests
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import XCTest
@testable import HatchWorksChallenge

@MainActor
final class CharacterTests: XCTestCase {
    
    // MARK: - Decoding Tests
    func testDecodeCharacterFromJSON() {
        let character = TestFixtures.goku
        
        XCTAssertEqual(character.id, 1)
        XCTAssertEqual(character.name, "Goku")
        XCTAssertEqual(character.ki, "60.000.000")
        XCTAssertEqual(character.maxKi, "90 Septillion")
        XCTAssertEqual(character.race, "Saiyan")
        XCTAssertEqual(character.gender, "Male")
        XCTAssertEqual(character.description, "Test description")
        XCTAssertNotNil(character.image)
        XCTAssertEqual(character.affiliation, "Z Fighter")
        XCTAssertEqual(character.transformations?.count, 6)
    }
    
    func testDecodeCharacterWithoutImage() {
        let character = TestFixtures.characterWithoutImage
        
        XCTAssertEqual(character.id, 7)
        XCTAssertEqual(character.name, "Dodoria")
        XCTAssertNil(character.image)
        XCTAssertNil(character.transformations)
    }
    
    func testDecodeCharactersWrapper() throws {
        let json = TestFixtures.charactersWrapperJson
        
        guard let wrapper = try? JSONDecoder().decode(CharactersWrapper.self, from: json) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(wrapper.items.count, 2)
        XCTAssertEqual(wrapper.items[0].name, "Bulma")
        XCTAssertEqual(wrapper.items[1].name, "Dodoria")
    }
    
    func testDecodeInvalidJSON() {
        let json = TestFixtures.invalidJson
        
        XCTAssertThrowsError(try JSONDecoder().decode(Character.self, from: json)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    // MARK: - Encoding Tests
    func testEncodeCharacters() throws {
        let character = TestFixtures.goku
        
        let json = try JSONEncoder().encode(character)
        let decodedCharacter = try JSONDecoder().decode(Character.self, from: json)
        
        XCTAssertEqual(character.id, decodedCharacter.id)
        XCTAssertEqual(character.name, decodedCharacter.name)
        XCTAssertEqual(character.ki, decodedCharacter.ki)
        XCTAssertEqual(character.race, decodedCharacter.race)
    }
}
