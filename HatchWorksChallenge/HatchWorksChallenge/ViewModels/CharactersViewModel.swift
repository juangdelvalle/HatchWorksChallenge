//
//  CharactersViewModel.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import Foundation
import Combine

final class CharactersViewModel: ObservableObject {
    
    @Published var characters: [Character] = []
    @Published var selectedCharacter: Character? = nil
    @Published var isLoadingDetails: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var isLoading: Bool = false
    @Published var detailError: Error? = nil
    @Published var error: Error? = nil
    
    private let repository: AppRepositoryProtocol
    private var currentPage: Int = 1
    
    init(repository: AppRepositoryProtocol = AppRepository()) {
        self.repository = repository
    }
    
    @MainActor
    func fetchCharacters() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            self.characters = try await repository.fetchCharacters(page: 1)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    @MainActor
    func loadMoreCharacters() async {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        error = nil
        
        do {
            let nextPageCharacters = try await repository.fetchCharacters(page: currentPage)
            self.characters.append(contentsOf: nextPageCharacters)
        } catch {
            self.error = error
            self.currentPage -= 1
        }
        
        isLoadingMore = false
    }
    @MainActor
    func fetchCharacterDetails(_ id: Int) async {
        guard !isLoadingDetails else { return }
        
        isLoadingDetails = true
        detailError = nil
        
        do {
            self.selectedCharacter = try await repository.fetchCharacterDetails(id)
        } catch {
            self.detailError = error
        }
        
        isLoadingDetails = false
    }
    
    func shouldLoadMoreCharacters(currentCharacter: Character) -> Bool {
        guard !isLoadingMore else { return false }
        guard let lastCharacter = characters.last else { return false }
        
        return currentCharacter.id == lastCharacter.id
    }
}
