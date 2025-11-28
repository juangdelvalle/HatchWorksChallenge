//
//  NetworkServiceTests.swift
//  HatchWorksChallengeTests
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import XCTest
@testable import HatchWorksChallenge

@MainActor
final class NetworkServiceTests: XCTestCase {

    var sut: NetworkService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        sut = NetworkService(session: mockURLSession)
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - FetchCharacters success tests
    func testFetchCharactersSuccess() async throws {
        let expectedCharacters = TestFixtures.successCharacters
        let jsonData = TestFixtures.charactersWrapperJson
        mockURLSession.setupSuccess(data: jsonData)
        
        let characters = try await sut.fetchCharacters()
        
        XCTAssertEqual(characters.count, expectedCharacters.count)
        XCTAssertEqual(characters, expectedCharacters)
    }
    
    func testFetchCharactersFirstPage() async throws {
        let jsonData = TestFixtures.charactersWrapperJson
        mockURLSession.setupSuccess(data: jsonData,statusCode: 200)
        
        _ = try await sut.fetchCharacters()
        
        XCTAssertTrue(mockURLSession.lastURL == URL(string:"https://dragonball-api.com/api/characters?page=1"))
    }

    func testFetchCharactersThirdPage() async throws {
        let jsonData = TestFixtures.charactersWrapperJson
        mockURLSession.setupSuccess(data: jsonData,statusCode: 200)
        
        _ = try await sut.fetchCharacters(3)
        
        XCTAssertTrue(mockURLSession.lastURL == URL(string:"https://dragonball-api.com/api/characters?page=3"))
    }
    
    func testFetchCharacterDetailsCorrectURL() async throws {
        let jsonData = TestFixtures.bulmaJson
        mockURLSession.setupSuccess(data: jsonData, statusCode: 200)
        
        _ = try await sut.fetchCharacterDetails(4)
        
        XCTAssertEqual(mockURLSession.lastURL?.absoluteString, "https://dragonball-api.com/api/characters/4")
    }
    
    func testFetchCharacterDetailsSuccess() async throws {
        let jsonData = TestFixtures.gokuJson
        mockURLSession.setupSuccess(data: jsonData, statusCode: 200)
        
        let character = try await sut.fetchCharacterDetails(4)
        
        XCTAssertTrue(!(character.transformations?.isEmpty ?? true))
    }
    
    func testFetchCharactersNetworkError() async throws {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        mockURLSession.setupFailure(error: networkError)
        
        do {
            _ = try await sut.fetchCharacters()
            XCTFail("Expected to throw network error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testFetchCharactersInvalidResponse() async throws {
        mockURLSession.setupInvalidResponse()
        
        do {
            _ = try await sut.fetchCharacters()
            XCTFail("Expected to throw invalidResponse error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        }
    }
    
    func testFetchCharactersInvalidJSON() async throws {
        let invalidJson = TestFixtures.invalidJson
        mockURLSession.setupSuccess(data: invalidJson, statusCode: 200)
        
        do {
            _ = try await sut.fetchCharacters()
            XCTFail("Expected to throw decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testFetchCharacterDetailsInvalidResponse() async throws {
        mockURLSession.setupInvalidResponse()
        
        do {
            _ = try await sut.fetchCharacterDetails(1)
            XCTFail("Expected to throw invalidResponse error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.invalidResponse)
        }
    }
    
    func testFetchCharacterDetailsInvalidJSON() async throws {
        let invalidJson = TestFixtures.invalidJson
        mockURLSession.setupSuccess(data: invalidJson, statusCode: 200)
        
        do {
            _ = try await sut.fetchCharacterDetails(1)
            XCTFail("Expected to throw decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testMultipleSequentialRequests() async throws {
        let characterJSON = TestFixtures.charactersWrapperJson
        let detailsJSON = TestFixtures.gokuJson
        
        mockURLSession.setupSuccess(data: characterJSON, statusCode: 200)
        let characters = try await sut.fetchCharacters()
        
        mockURLSession.setupSuccess(data: detailsJSON, statusCode: 200)
        let details = try await sut.fetchCharacterDetails(1)
        
        XCTAssertFalse(characters.isEmpty)
        XCTAssertNotNil(details)
        XCTAssertEqual(mockURLSession.requestCount, 2)
    }
    
    func testHTTPStatusCodeRange() async throws {
        let jsonData = TestFixtures.charactersWrapperJson
        
        for statusCode in 200...299 {
            mockURLSession.setupSuccess(data: jsonData, statusCode: statusCode)
            
            do {
                _ = try await sut.fetchCharacters()
            } catch {
                XCTFail("Status code \(statusCode) should succeed but threw: \(error)")
            }
        }
    }
    
    func testHTTPStatusCodeOutsideRange() async throws {
        let jsonData = "{}".data(using: .utf8)!
        let invalidCodes: [Int] = [199, 300, 301, 400, 404, 500, 503]
        
        for statusCode in invalidCodes {
            mockURLSession.setupSuccess(data: jsonData, statusCode: statusCode)
            
            do {
                _ = try await sut.fetchCharacters()
                XCTFail("Status code \(statusCode) should throw invalidResponse error")
            } catch let error as NetworkError {
                XCTAssertEqual(error, NetworkError.invalidResponse)
            }
        }
    }
}
