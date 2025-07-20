# MyCardBook Architecture

This document provides a comprehensive overview of MyCardBook's technical architecture, design patterns, and implementation details.

## 🏗 Overview

MyCardBook is built as a privacy-first, local-first iOS application using modern Swift and SwiftUI technologies. The architecture prioritizes user privacy, performance, and maintainability while providing a delightful user experience.

### Core Principles
- **Privacy First**: All data stays on device, no external dependencies
- **Local First**: Complete offline functionality  
- **Performance**: Sub-second response times for all operations
- **Maintainability**: Clean, testable, and well-documented code
- **User Control**: Complete data ownership and portability

## 📱 Technology Stack

### Frameworks & Languages
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI with iOS 16.0+ deployment target
- **Reactive Programming**: Combine framework
- **Data Persistence**: Core Data
- **Testing**: XCTest framework
- **Development Tools**: Xcode 15.0+

### Key Dependencies
- **Zero External Dependencies**: No third-party frameworks or libraries
- **iOS Native Only**: Uses only Apple's first-party frameworks

## 🎯 Architecture Pattern

### MVVM + Repository Pattern

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│     Views       │───▶│   ViewModels    │───▶│  Repositories   │
│   (SwiftUI)     │    │   (Combine)     │    │   (Core Data)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│    Services     │    │     Models      │    │   Core Data     │
│  (Business      │    │  (Data Types)   │    │   (Storage)     │
│   Logic)        │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Layer Responsibilities

#### Views (SwiftUI)
- **Purpose**: User interface and user interaction
- **Responsibilities**: 
  - Render UI components
  - Handle user gestures and inputs
  - Display data from ViewModels
  - Navigation between screens

#### ViewModels (Combine)
- **Purpose**: Business logic and state management
- **Responsibilities**:
  - Manage UI state using `@Published` properties
  - Transform data for display
  - Handle user actions and commands
  - Coordinate with Repositories and Services

#### Repositories (Data Access)
- **Purpose**: Data access abstraction layer
- **Responsibilities**:
  - Abstract Core Data implementation details
  - Provide clean API for data operations
  - Handle data mapping between entities and models
  - Ensure data consistency and validation

#### Services (Business Logic)
- **Purpose**: Specialized business operations
- **Responsibilities**:
  - Card database management
  - Data import/export functionality
  - Complex business rules and calculations
  - File system operations

#### Models (Data Types)
- **Purpose**: Core data structures
- **Responsibilities**:
  - Define app's domain objects
  - Provide data validation
  - Ensure type safety
  - Support Codable for serialization

## 📂 Project Structure

```
MyCardBook/
├── MyCardBook/                 # Main application code
│   ├── MyCardBookApp.swift     # App entry point and configuration
│   ├── ContentView.swift       # Root SwiftUI view
│   │
│   ├── Views/                  # SwiftUI Views
│   │   ├── DashboardView.swift
│   │   ├── CardsView.swift
│   │   ├── CreditsView.swift
│   │   ├── SettingsView.swift
│   │   ├── LaunchScreenView.swift
│   │   └── Components/         # Reusable UI components
│   │       ├── CreditCardView.swift
│   │       ├── CreditItemView.swift
│   │       ├── EditCardView.swift
│   │       └── SmartCardView.swift
│   │
│   ├── ViewModels/            # MVVM ViewModels
│   │   ├── DashboardViewModel.swift
│   │   ├── CardsViewModel.swift
│   │   └── CreditsViewModel.swift
│   │
│   ├── Models/                # Core data models
│   │   ├── User.swift
│   │   ├── Card.swift
│   │   └── Credit.swift
│   │
│   ├── Core/                  # Core data infrastructure
│   │   ├── Persistence/
│   │   │   ├── PersistenceController.swift
│   │   │   ├── Entities/      # Core Data entity definitions
│   │   │   └── Extensions/    # Core Data extensions
│   │   └── Repositories/      # Data access layer
│   │       ├── CardRepository.swift
│   │       └── CreditRepository.swift
│   │
│   ├── Services/              # Business logic services
│   │   ├── CardDatabaseService.swift
│   │   ├── DataExportService.swift
│   │   └── DataImportService.swift
│   │
│   ├── Design/                # UI design system
│   │   └── Colors.swift
│   │
│   ├── Resources/             # App resources
│   │   ├── CardDatabase/      # JSON card database
│   │   │   ├── cards.json
│   │   │   ├── schema.json
│   │   │   ├── README.md
│   │   │   └── CONTRIBUTING.md
│   │   └── Assets.xcassets/   # Images and app icons
│   │
│   └── ...
│
├── MyCardBookTests/           # Unit tests
├── MyCardBookUITests/         # UI integration tests
└── specs/                     # Product specifications
```

## 💾 Data Architecture

### Core Data Stack

```
┌─────────────────────────────────────────────────────┐
│                   SwiftUI Views                     │
└──────────────────┬──────────────────────────────────┘
                   │
┌─────────────────────────────────────────────────────┐
│              ViewModels (ObservableObject)          │
└──────────────────┬──────────────────────────────────┘
                   │
┌─────────────────────────────────────────────────────┐
│            Repositories (Data Access)               │
└──────────────────┬──────────────────────────────────┘
                   │
┌─────────────────────────────────────────────────────┐
│         PersistenceController (Core Data)           │
├─────────────────────────────────────────────────────┤
│  NSManagedObjectContext (Main + Background)         │
│  NSPersistentContainer                              │
│  SQLite Database (Local Storage)                    │
└─────────────────────────────────────────────────────┘
```

### Data Models

#### User Entity
```swift
// Core Data Entity
@NSManaged public var id: UUID
@NSManaged public var createdAt: Date
@NSManaged public var cards: NSSet?

// Domain Model
struct User: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    var cards: [Card]
}
```

#### Card Entity
```swift
// Core Data Entity  
@NSManaged public var id: UUID
@NSManaged public var name: String
@NSManaged public var issuer: String
@NSManaged public var nickname: String?
@NSManaged public var dateAdded: Date
@NSManaged public var credits: NSSet?

// Domain Model
struct Card: Identifiable, Codable {
    let id: UUID
    let name: String
    let issuer: String
    let network: CardNetwork
    let category: CardCategory
    let color: String
    var nickname: String?
    let dateAdded: Date
    var credits: [Credit]
}
```

#### Credit Entity
```swift
// Core Data Entity
@NSManaged public var id: UUID
@NSManaged public var title: String
@NSManaged public var cardId: UUID
@NSManaged public var isUsed: Bool
@NSManaged public var usedDate: Date?

// Domain Model
struct Credit: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let value: String
    let frequency: CreditFrequency
    let category: CreditCategory
    var isUsed: Bool
    var usedDate: Date?
}
```

### Data Flow

1. **User Interaction** → SwiftUI View captures user action
2. **Command** → View calls ViewModel method
3. **Business Logic** → ViewModel processes command, updates state
4. **Data Operation** → ViewModel calls Repository method
5. **Persistence** → Repository performs Core Data operation
6. **State Update** → Repository returns result to ViewModel
7. **UI Update** → ViewModel publishes state change via `@Published`
8. **View Refresh** → SwiftUI automatically updates UI

## 🔧 Services Architecture

### CardDatabaseService
**Purpose**: Manages the JSON-based card benefits database

```swift
class CardDatabaseService: ObservableObject {
    static let shared = CardDatabaseService()
    
    @Published var availableCards: [Card] = []
    
    private init() {
        loadCardDatabase()
    }
    
    private func loadCardDatabase() {
        // Load from bundle resources
        // Parse JSON into Card models
        // Publish updates to subscribers
    }
}
```

### DataExportService
**Purpose**: Exports user data for portability and backup

```swift
class DataExportService {
    func exportToJSON() async throws -> Data
    func exportToCSV() async throws -> Data
    func exportAllData() async throws -> ExportPackage
}
```

### DataImportService  
**Purpose**: Imports user data from backups

```swift
class DataImportService {
    func importFromJSON(_ data: Data) async throws -> ImportResult
    func importFromCSV(_ data: Data) async throws -> ImportResult
    func validateImportData(_ data: Data) throws -> ValidationResult
}
```

## 🔒 Security & Privacy Architecture

### Privacy-First Design
- **Local Storage Only**: All user data stored in Core Data SQLite database
- **No Network Requests**: App functions completely offline
- **No Analytics**: Zero data collection or user tracking
- **Data Encryption**: Core Data uses iOS built-in encryption
- **Keychain Integration**: Sensitive data protected by iOS Keychain

### Security Measures
- **Input Validation**: All user inputs validated at multiple layers
- **Type Safety**: Swift's type system prevents many runtime errors
- **Memory Safety**: ARC and Swift prevent memory leaks and corruption
- **Sandboxing**: iOS app sandbox prevents unauthorized data access

## ⚡️ Performance Architecture

### Performance Targets
- **App Launch**: < 2 seconds cold start
- **Search Operations**: < 500ms for any search query
- **Data Operations**: < 1 second for CRUD operations
- **UI Responsiveness**: 60 FPS with smooth animations

### Optimization Strategies

#### Core Data Performance
- **Batch Operations**: Use NSBatchInsertRequest for bulk data
- **Faulting**: Lazy loading of relationships
- **Indexes**: Strategic indexing on frequently queried fields
- **Background Context**: Heavy operations on background queue

#### SwiftUI Performance
- **Lazy Loading**: Use LazyVStack/LazyHStack for large lists
- **Identity**: Proper `id` usage for efficient updates
- **State Management**: Minimize unnecessary view updates
- **Asset Optimization**: Optimized images and assets

#### Memory Management
- **Weak References**: Prevent retain cycles in closures
- **Resource Cleanup**: Proper cleanup of observers and subscriptions
- **Image Caching**: Efficient image loading and caching

## 🧪 Testing Architecture

### Testing Strategy
- **Unit Tests**: 80%+ code coverage for business logic
- **Integration Tests**: Repository and service layer testing
- **UI Tests**: Critical user flows and accessibility
- **Performance Tests**: Core Data operations and UI responsiveness

### Test Structure
```
MyCardBookTests/
├── ViewModelTests/           # ViewModel unit tests
├── RepositoryTests/          # Data layer tests
├── ServiceTests/            # Business logic tests
├── ModelTests/              # Data model tests
└── Mocks/                   # Test doubles and mocks

MyCardBookUITests/
├── UserFlowTests/           # End-to-end user flows
├── AccessibilityTests/      # Accessibility compliance
└── PerformanceTests/        # UI performance tests
```

## 🔄 State Management

### Reactive Data Flow with Combine

```swift
// ViewModel publishes state changes
class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadCards() {
        isLoading = true
        
        cardRepository.getAllCards()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] cards in
                    self?.cards = cards
                }
            )
            .store(in: &cancellables)
    }
}
```

### State Management Patterns
- **Single Source of Truth**: ViewModels own UI state
- **Unidirectional Data Flow**: Actions → State Changes → UI Updates
- **Reactive Updates**: Combine publishers drive UI updates
- **Error Handling**: Consistent error state management

## 📈 Scalability Considerations

### Current Capacity
- **Cards**: Efficiently handle 100+ cards
- **Credits**: Support 500+ individual credits
- **Search**: Real-time search across all data
- **Performance**: Maintain responsiveness at scale

### Future Scalability
- **Modular Architecture**: Easy to add new features
- **Plugin System**: Extensible for new card types
- **Database Evolution**: Core Data migration support
- **API Ready**: Architecture supports future cloud sync

## 🔮 Future Architecture Enhancements

### Planned Improvements
- **Core Data CloudKit**: Optional cloud sync
- **WidgetKit**: Home screen widgets
- **Shortcuts**: Siri integration
- **Background Refresh**: Automatic credit renewal
- **Push Notifications**: Expiration reminders

### Architectural Evolution
- **SwiftUI 6.0**: Adopt latest SwiftUI features
- **Swift 6.0**: Strict concurrency and performance improvements
- **iOS 18+**: New platform capabilities
- **Modularization**: Extract reusable frameworks

---

## 🤝 Contributing to Architecture

### Guidelines for Architectural Changes
1. **Maintain Privacy**: No external dependencies
2. **Preserve Performance**: Meet performance targets
3. **Follow Patterns**: Use established architectural patterns
4. **Document Changes**: Update this document for major changes
5. **Test Thoroughly**: Maintain test coverage standards

### Architecture Decision Process
1. **Problem Identification**: Clearly define the issue
2. **Options Analysis**: Consider multiple solutions
3. **Impact Assessment**: Evaluate performance, privacy, maintainability
4. **Community Input**: Discuss in GitHub issues
5. **Implementation**: Follow established patterns
6. **Documentation**: Update architectural documentation

---

*This architecture enables MyCardBook to be a fast, private, and maintainable application that puts user control and privacy first while providing excellent performance and user experience.*