//
//  CharacterDetailsView.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import SwiftUI

@MainActor
struct CharacterDetailsView: View {
    
    @ObservedObject var viewModel: CharactersViewModel
    let character: Character
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10.0) {
                VStack(alignment: .leading, spacing: 6.0) {
                    characterImage(character.image)
                    bodyTitleText("Description:")
                    bodyText(character.description)
                        .frame(maxWidth: .infinity)
                }
                HStack(spacing: 6.0) {
                    bodyTitleText("Race:")
                    bodyText(character.race)
                }
                HStack(spacing: 6.0) {
                    bodyTitleText("Gender:")
                    bodyText(character.gender)
                }
                HStack(spacing: 6.0) {
                    bodyTitleText("Affiliation:")
                    bodyText(character.affiliation)
                }
                HStack(spacing: 6.0) {
                    bodyTitleText("Ki:")
                    bodyText(character.ki)
                }
                HStack(spacing: 6.0) {
                    bodyTitleText("Max Ki:")
                    bodyText(character.maxKi)
                }
                VStack(alignment: .leading, spacing: 6.0) {
                    if viewModel.isLoadingDetails {
                        loadingView
                    } else if let error = viewModel.detailError {
                        errorView(error)
                    } else if (viewModel.selectedCharacter?.transformations ?? []).isEmpty {
                        HStack(spacing: 6.0) {
                            bodyTitleText("Transformations:")
                            bodyText("No transformations available.")
                        }
                    } else {
                        bodyTitleText("Transformations:")
                        ForEach(viewModel.selectedCharacter?.transformations ?? []) { transformation in
                            VStack(alignment: .leading) {
                                Text(transformation.name)
                                    .font(.headline)
                                characterImage(transformation.image)
                            }
                        }
                    }
                }
                
            }
        }
        .task {
            await viewModel.fetchCharacterDetails(character.id)
        }
        .navigationTitle(character.name)
        .foregroundStyle(.secondary)
        .padding()
    }
    
    private var loadingView: some View {
        VStack(spacing: 8.0) {
            Spacer()
            ProgressView()
                .padding()
            Text("Loading transformations...")
            Spacer()
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text("\(error.localizedDescription)")
        } actions: {
            Button("Try again") {
                Task {
                    await viewModel.fetchCharacters()
                }
            }
        }
    }
    
    private func bodyTitleText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .fontWeight(.bold)
    }
    
    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.body)
    }
    
    private func characterImage(_ url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 100, height: 100)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
