//
//  CharactersViewModelTests.swift
//  HatchWorksChallengeTests
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import XCTest
import Combine
@testable import HatchWorksChallenge

@MainActor
final class CharactersViewModelTests: XCTestCase {
    
    var sut: CharactersViewModel!
    var mockRepository: MockAppRepository!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockAppRepository()
        sut = CharactersViewModel(repository: mockRepository)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertTrue(sut.characters.isEmpty)
        XCTAssertNil(sut.selectedCharacter)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isLoadingMore)
        XCTAssertFalse(sut.isLoadingDetails)
        XCTAssertNil(sut.error)
        XCTAssertNil(sut.detailError)
    }
    
    func testFetchCharactersSuccess() async {
        let expectedCharacters = TestFixtures.successCharacters
        mockRepository.fetchCharactersResult = .success(expectedCharacters)
        
        await sut.fetchCharacters()
        
        XCTAssertEqual(sut.characters, expectedCharacters)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchCharactersReplaceExistingOnes() async {
        let initialCharacters = [TestFixtures.goku]
        let newCharacters = TestFixtures.firstPageCharacters
        mockRepository.fetchCharactersResult = .success(newCharacters)
        
        sut.characters = initialCharacters
        
        await sut.fetchCharacters()
        
        XCTAssertEqual(sut.characters, newCharacters)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testFetchCharactersLoadingStateTransition() async {
        mockRepository.fetchCharactersResult = .success(TestFixtures.successCharacters)
        let expectation = expectation(description: "Loading state changed")
        var loadingStates: [Bool] = []
        
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await sut.fetchCharacters()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
    
    func testFetchCharactersFetchesFirstPage() async {
        mockRepository.fetchCharactersResult = .success(TestFixtures.firstPageCharacters)
        
        await sut.fetchCharacters()
        
        XCTAssertEqual(sut.characters, TestFixtures.firstPageCharacters)
    }
    
    func testFetchCharactersError() async {
        let expectedError = NetworkError.invalidResponse
        mockRepository.fetchCharactersResult = .failure(expectedError)
        
        await sut.fetchCharacters()
        
        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.characters.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testFetchCharactersErrorClearsOnSuccess() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.badURL)
        await sut.fetchCharacters()
        
        mockRepository.fetchCharactersResult = .success(TestFixtures.successCharacters)
        
        await sut.fetchCharacters()
        
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.characters.isEmpty)
    }
    
    func testLoadMoreCharactersSuccess() async {
        let initialCharacters = TestFixtures.firstPageCharacters
        let moreCharacters = TestFixtures.secondPageCharacters
        
        sut.characters = initialCharacters
        mockRepository.fetchCharactersResult = .success(moreCharacters)
        
        await sut.loadMoreCharacters()
        
        XCTAssertEqual(sut.characters.count, 3)
        XCTAssertEqual(sut.characters[0].name, "Goku")
        XCTAssertEqual(sut.characters[1].name, "Bulma")
        XCTAssertEqual(sut.characters[2].name, "Zarbon")
        XCTAssertFalse(sut.isLoadingMore)
    }
    
    func testFetchCharactersPreventsMultipleSimultaneousCalls() async {
        mockRepository.fetchCharactersResult = .success(TestFixtures.successCharacters)
        mockRepository.shouldDelay = true
        
        async let call1: () = sut.fetchCharacters()
        async let call2: () = sut.fetchCharacters()
        
        await call1
        await call2
        
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1)
    }
    
    func testLoadMoreCharactersIncrementsPage() async {
        mockRepository.fetchCharactersResult = .success([])
        
        await sut.loadMoreCharacters()
        
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, 2)
    }
    
    func testLoadMoreCharactersIncrementsPageMultipleTimes() async {
        mockRepository.fetchCharactersResult = .success([])
        
        await sut.loadMoreCharacters()
        await sut.loadMoreCharacters()
        await sut.loadMoreCharacters()
        
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, 4)
    }
    
    func testLoadMoreCharactersLoadingStateTransition() async {
        mockRepository.fetchCharactersResult = .success([])
        let expectation = expectation(description: "Loading more state changed")
        var loadingStates: [Bool] = []
        
        sut.$isLoadingMore
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await sut.loadMoreCharacters()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
    
    func testLoadMoreCharactersPreventsMultipleSimultaneousCalls() async {
        mockRepository.fetchCharactersResult = .success([])
        mockRepository.shouldDelay = true
        
        async let call1: () = sut.loadMoreCharacters()
        async let call2: () = sut.loadMoreCharacters()
        
        await call1
        await call2
        
        XCTAssertEqual(mockRepository.fetchCharactersCallCount, 1)
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, 2)
    }
    
    func testLoadMoreCharactersError() async {
        let initialCharacters = [TestFixtures.goku]
        sut.characters = initialCharacters
        mockRepository.fetchCharactersResult = .failure(NetworkError.invalidResponse)
        
        await sut.loadMoreCharacters()
        
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.characters.isEmpty)
        XCTAssertFalse(sut.isLoadingMore)
    }
    
    func testLoadMoreCharactersErrorRollsBackPage() async {
        mockRepository.fetchCharactersResult = .success([])
        await sut.loadMoreCharacters()
        
        mockRepository.fetchCharactersResult = .failure(NetworkError.badURL)
        
        await sut.loadMoreCharacters()
        
        mockRepository.fetchCharactersResult = .success([])
        await sut.loadMoreCharacters()
        XCTAssertEqual(mockRepository.lastFetchCharactersPage, 3)
    }
    
    func testLoadMoreCharactersPreservesExistingCharactersOnError() async {
        let initialCharacters = TestFixtures.allCharacters
        sut.characters = initialCharacters
        mockRepository.fetchCharactersResult = .failure(NetworkError.invalidResponse)
        
        await sut.loadMoreCharacters()
        
        XCTAssertEqual(sut.characters, initialCharacters)
    }
    
    func testFetchCharacterDetailsSuccess() async {
        let expectedCharacter = TestFixtures.goku
        mockRepository.fetchCharacterDetailsResult = .success(expectedCharacter)
        
        await sut.fetchCharacterDetails(1)
        
        XCTAssertNotNil(sut.selectedCharacter)
        XCTAssertEqual(sut.selectedCharacter?.name, "Goku")
        XCTAssertFalse(sut.selectedCharacter?.transformations?.isEmpty ?? true)
        XCTAssertFalse(sut.isLoadingDetails)
        XCTAssertNil(sut.detailError)
    }
    
    func testFetchCharacterDetailsLoadingStateTransition() async {
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        let expectation = expectation(description: "Loading details state changed")
        var loadingStates: [Bool] = []
        
        sut.$isLoadingDetails
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await sut.fetchCharacterDetails(1)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
    
    func testFetchCharacterDetailsPreventsMultipleSimultaneousCalls() async {
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        mockRepository.shouldDelay = true
        
        async let call1: () = sut.fetchCharacterDetails(1)
        async let call2: () = sut.fetchCharacterDetails(2)
        
        await call1
        await call2
        
        XCTAssertEqual(mockRepository.fetchCharacterDetailsCallCount, 1)
    }
    
    func testFetchCharacterDetailsReplacesSelectedCharacter() async {
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        await sut.fetchCharacterDetails(1)
        
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.bulma)
        
        await sut.fetchCharacterDetails(4)
        
        XCTAssertEqual(sut.selectedCharacter?.name, "Bulma")
    }
        
    func testFetchCharacterDetailsError() async {
        let expectedError = NetworkError.invalidResponse
        mockRepository.fetchCharacterDetailsResult = .failure(expectedError)
        
        await sut.fetchCharacterDetails(1)
        
        XCTAssertNotNil(sut.detailError)
        XCTAssertNil(sut.selectedCharacter)
        XCTAssertFalse(sut.isLoadingDetails)
    }
    
    func testFetchCharacterDetailsErrorClearsOnSuccess() async {
        mockRepository.fetchCharacterDetailsResult = .failure(NetworkError.badURL)
        await sut.fetchCharacterDetails(1)
        
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        
        await sut.fetchCharacterDetails(1)
        
        XCTAssertNil(sut.detailError)
        XCTAssertNotNil(sut.selectedCharacter)
    }
    
    func testShouldLoadMoreCharactersReturnsTrueForLastCharacter() {
        sut.characters = TestFixtures.successCharacters
        let lastCharacter = TestFixtures.successCharacters.last!
        
        let result = sut.shouldLoadMoreCharacters(currentCharacter: lastCharacter)
        
        XCTAssertTrue(result)
    }
    
    func testShouldLoadMoreCharactersReturnsFalseForNonLastCharacter() {
        sut.characters = TestFixtures.successCharacters
        let firstCharacter = TestFixtures.successCharacters.first!
        
        let result = sut.shouldLoadMoreCharacters(currentCharacter: firstCharacter)
        
        XCTAssertFalse(result)
    }
    
    func testShouldLoadMoreCharactersReturnsFalseWhenAlreadyLoading() {
        sut.characters = TestFixtures.successCharacters
        sut.isLoadingMore = true
        let lastCharacter = TestFixtures.successCharacters.last!
        
        let result = sut.shouldLoadMoreCharacters(currentCharacter: lastCharacter)
        
        XCTAssertFalse(result)
    }
    
    func testShouldLoadMoreCharactersReturnsFalseForEmptyList() {
        sut.characters = []
        
        let result = sut.shouldLoadMoreCharacters(currentCharacter: TestFixtures.goku)
        
        XCTAssertFalse(result)
    }
        
    func testErrorAndDetailErrorAreIndependent() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.badURL)
        mockRepository.fetchCharacterDetailsResult = .failure(NetworkError.invalidResponse)
        
        await sut.fetchCharacters()
        await sut.fetchCharacterDetails(1)
        
        XCTAssertNotNil(sut.error)
        XCTAssertNotNil(sut.detailError)
    }
    
    func testDetailErrorDoesNotAffectCharactersError() async {
        mockRepository.fetchCharacterDetailsResult = .failure(NetworkError.badURL)
        
        await sut.fetchCharacterDetails(1)
        
        XCTAssertNotNil(sut.detailError)
        XCTAssertNil(sut.error)
    }
    
    func testCharactersErrorDoesNotAffectDetailError() async {
        mockRepository.fetchCharactersResult = .failure(NetworkError.invalidResponse)
        
        await sut.fetchCharacters()
        
        XCTAssertNotNil(sut.error)
        XCTAssertNil(sut.detailError)
    }
    
    func testLoadingStatesAreIndependent() async {
        mockRepository.fetchCharactersResult = .success([])
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        mockRepository.shouldDelay = true
        
        async let _: () = sut.fetchCharacters()
        async let _: () = sut.fetchCharacterDetails(1)
        
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        XCTAssertNotNil(sut)
    }
    
    func testFetchCharactersDoesNotAffectSelectedCharacter() async {
        mockRepository.fetchCharacterDetailsResult = .success(TestFixtures.goku)
        await sut.fetchCharacterDetails(1)
        
        mockRepository.fetchCharactersResult = .success(TestFixtures.successCharacters)
        
        await sut.fetchCharacters()
        
        XCTAssertEqual(sut.selectedCharacter?.name, "Goku")
    }
}
