//
//  CharactersListView.swift
//  HatchWorksChallenge
//
//  Created by Juan del Valle Ruiz on 11/28/25.
//

import SwiftUI

@MainActor
struct CharactersListView: View {
    
    @StateObject var viewModel: CharactersViewModel = CharactersViewModel()
    
    var body: some View {
         NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView("Loading characters...")
                } else if let error = viewModel.error {
                    errorView(error)
                } else if viewModel.characters.isEmpty {
                    emptyView
                } else {
                    listView
                }
            }
            .navigationTitle("Characters")
            .refreshable {
                await viewModel.fetchCharacters()
            }
        }
         .task {
             await viewModel.fetchCharacters()
         }
    }
    
    private var emptyView: some View {
        ContentUnavailableView {
            Label("No characters available", systemImage: "exclamationmark.circle")
        } description: {
            Text("Try again later")
        }
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink(value: character) {
                    CharacterRowView(character: character)
                }
                .task {
                    if viewModel.shouldLoadMoreCharacters(currentCharacter: character) {
                        await viewModel.loadMoreCharacters()
                    }
                }
            }
            if viewModel.isLoadingMore {
                loadingView()
            }
        }
        .navigationDestination(for: Character.self) { character in
            CharacterDetailsView(viewModel: viewModel, character: character)
        }
    }
    
    private func loadingView(_ loadingText: String? = nil) -> some View {
        VStack(spacing: 8.0) {
            Spacer()
            ProgressView()
                .padding()
            if let text = loadingText {
                Text(text)
            }
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
}

struct CharacterRowView: View {
    let character: Character
    
    var body: some View {
        HStack(spacing: 8.0) {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(character.name)
                .font(.headline)
        }
        .padding(.vertical, 8.0)
    }
}

#Preview {
    CharactersListView()
}
