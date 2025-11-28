# HatchWorksChallenge

A SwiftUI iOS application that consumes the Dragon Ball API to display character information with pagination support.

## Features

- Browse Dragon Ball characters with infinite scroll pagination
- View detailed character information including:
  - Basic stats (name, race, gender, affiliation)
  - Power levels (ki, max ki)
  - Character transformations
  - Character images
- Clean, native SwiftUI interface
- Comprehensive error handling
- Offline-first ready architecture with repository pattern

## Technology Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Async/Concurrency**: Swift Concurrency (async/await)
- **Reactive Programming**: Combine framework
- **Networking**: URLSession
- **Testing**: XCTest with protocol-based mocking
- **Architecture**: MVVM (Model-View-ViewModel)

## Architecture

The application follows MVVM architecture with clear separation of concerns:

### Layer Structure

```
┌─────────────────────────────────────┐
│           Views (SwiftUI)           │
│  CharactersListView, DetailsView    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│          ViewModels                 │
│      CharactersViewModel            │
│  (@Published, Combine, @MainActor)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Repository Layer            │
│  AppRepository (Protocol-based DI)  │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│        Network Service              │
│   NetworkService (URLSession)       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│          Dragon Ball API            │
│   dragonball-api.com/api            │
└─────────────────────────────────────┘
```

### Key Components

- **Models**: `Character`, `Transformation` - Codable data structures
- **Services**: `NetworkService` - HTTP communication layer with error handling
- **Repository**: `AppRepository` - Data access abstraction layer
- **ViewModels**: `CharactersViewModel` - Business logic and state management
- **Views**: SwiftUI views for UI presentation

## API Integration

### Dragon Ball API

- **Base URL**: `https://dragonball-api.com/api/`
- **Endpoints Used**:
  - `GET /characters?page={page}` - Paginated character list
  - `GET /characters/{id}` - Individual character details with transformations

### Pagination Strategy

- Infinite scroll implementation
- Automatic loading when user reaches last item
- Page tracking in ViewModel
- Separate loading states for initial load vs. pagination

## Design Decisions

### 1. Protocol-Based Dependency Injection

All service layers use protocols (`NetworkServiceProtocol`, `AppRepositoryProtocol`, `URLSessionProtocol`) enabling:

- Easy unit testing with mocks
- Flexibility to swap implementations
- Clear contracts between layers

### 2. Repository Pattern

`AppRepository` provides abstraction between ViewModels and network layer:

- Future-ready for caching, offline support, data transformation
- Single source of truth for data access
- Testable business logic

### 3. Swift Concurrency (Async/Await)

Modern async/await instead of completion handlers:

- Cleaner, more readable code
- Better error handling
- Structured concurrency

### 4. MainActor for UI Updates

ViewModel methods marked `@MainActor` ensure:

- Thread-safe UI updates
- No manual dispatch to main queue
- Compiler-enforced UI thread safety

### 5. Separate Error States

Distinct error properties (`error`, `detailError`) for different operations:

- Granular error handling
- Better UX with targeted error messages
- Independent error recovery

### 6. Comprehensive Mock Objects

Test mocks track call counts and parameters:

- Verify correct method calls
- Test async behavior with configurable delays
- Flexible success/failure configuration via `Result<T, Error>`

## Prerequisites

- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later (deployment target)
- **macOS**: Monterey or later (for development)
- **Swift**: 5.9+

## Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/HatchWorksChallenge.git
cd HatchWorksChallenge
```

2. Open the project in Xcode:

```bash
open HatchWorksChallenge/HatchWorksChallenge.xcodeproj
```

3. Build and run:
   - Select a simulator or device
   - Press `⌘R` or click the Run button

No external dependencies or package managers required - the project uses only native iOS frameworks.

## Running Tests

### Run All Tests

```bash
xcodebuild test \
  -project HatchWorksChallenge/HatchWorksChallenge.xcodeproj \
  -scheme HatchWorksChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run Specific Test Class

```bash
xcodebuild test \
  -project HatchWorksChallenge/HatchWorksChallenge.xcodeproj \
  -scheme HatchWorksChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:HatchWorksChallengeTests/CharactersViewModelTests
```

### Run Single Test Method

```bash
xcodebuild test \
  -project HatchWorksChallenge/HatchWorksChallenge.xcodeproj \
  -scheme HatchWorksChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:HatchWorksChallengeTests/CharactersViewModelTests/testFetchCharacters
```

### Test Coverage

The project includes comprehensive unit tests for:

- **Models**: Character and Transformation decoding
- **Services**: NetworkService with mocked URLSession
- **Repository**: AppRepository with mocked NetworkService
- **ViewModels**: CharactersViewModel with mocked Repository

## Project Structure

```
HatchWorksChallenge/
├── HatchWorksChallenge/          # Main app target
│   ├── Models/                   # Data models (Character, Transformation)
│   ├── Services/                 # Network layer (NetworkService, NetworkError)
│   ├── Repository/               # Data access (AppRepository)
│   ├── ViewModels/               # Business logic (CharactersViewModel)
│   ├── Views/                    # SwiftUI views
│   └── HatchWorksChallengeApp.swift
├── HatchWorksChallengeTests/     # Unit tests
│   ├── Models/                   # Model tests
│   ├── Services/                 # Service layer tests
│   ├── Repositories/             # Repository tests
│   ├── ViewModels/               # ViewModel tests
│   ├── Mocks/                    # Mock implementations
│   └── Fixtures/                 # Test data
└── HatchWorksChallengeUITests/   # UI tests

```

## Author

**Juan del Valle Ruiz**

## License

This project is created as a technical challenge. License terms to be determined.
