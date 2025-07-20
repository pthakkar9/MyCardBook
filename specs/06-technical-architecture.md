# MyCardBook - Technical Architecture Specification

*Version: 1.0*
*Last Updated: 2025-07-14*

## Overview

This specification defines the technical architecture for the MyCardBook iOS application. The architecture prioritizes privacy, performance, and maintainability while supporting the open source community-driven development model.

## Core Architectural Principles

### 1. **Privacy-First Design**
- **All data MUST be stored locally by default**
- **No data transmission unless user explicitly opts in**
- **End-to-end encryption for all cloud communications**
- **Zero tracking or analytics collection**

### 2. **Local-First Architecture**
- **App MUST function completely offline**
- **Local data serves as the source of truth**
- **Cloud sync is optional and additive**
- **No dependency on external services for core functionality**

### 3. **Open Source Transparency**
- **All code MUST be publicly accessible and reviewable**
- **Architecture decisions MUST be documented with rationale**
- **Security practices MUST be transparent and verifiable**
- **Community contributions MUST be facilitated**

### 4. **Performance and Reliability**
- **App MUST launch within 2 seconds**
- **All operations MUST complete within 1 second**
- **App MUST handle 100+ cards and 500+ credits efficiently**
- **App MUST work smoothly on all supported iOS devices**

## System Architecture

### 1. **High-Level Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    MyCardBook iOS App                       │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (SwiftUI)                               │
│  ├── Views and ViewModels                                  │
│  ├── Navigation and Routing                                │
│  └── UI Components and Animations                          │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer (MVVM)                               │
│  ├── ViewModels                                            │
│  ├── Services and Managers                                 │
│  └── Business Rules and Validation                         │
├─────────────────────────────────────────────────────────────┤
│  Data Layer (Core Data + CloudKit)                         │
│  ├── Core Data Stack                                       │
│  ├── Local Data Models                                     │
│  ├── CloudKit Integration (Optional)                       │
│  └── Data Migration and Sync                               │
├─────────────────────────────────────────────────────────────┤
│  Security Layer                                            │
│  ├── iOS Keychain Integration                              │
│  ├── Data Encryption                                       │
│  └── Authentication Services                               │
└─────────────────────────────────────────────────────────────┘
```

### 2. **Component Architecture**

#### 2.1 Presentation Layer
- **Technology**: SwiftUI
- **Pattern**: MVVM with Combine
- **Responsibility**: User interface, navigation, user interactions
- **Key Components**:
  - Dashboard Views
  - Card Management Views
  - Credit Tracking Views
  - Settings and Preferences Views

#### 2.2 Business Logic Layer
- **Technology**: Swift with Combine
- **Pattern**: Service-oriented architecture
- **Responsibility**: Business rules, data processing, state management
- **Key Components**:
  - Card Management Service
  - Credit Tracking Service
  - Authentication Service
  - Data Sync Service

#### 2.3 Data Layer
- **Technology**: Core Data + CloudKit (optional)
- **Pattern**: Repository pattern
- **Responsibility**: Data persistence, querying, synchronization
- **Key Components**:
  - Core Data Stack
  - Data Models
  - Repository Classes
  - Migration Manager

#### 2.4 Security Layer
- **Technology**: iOS Keychain, CryptoKit
- **Pattern**: Service layer
- **Responsibility**: Authentication, encryption, secure storage
- **Key Components**:
  - Keychain Service
  - Encryption Service
  - Authentication Manager

## Data Models

### 1. **Core Data Models**

#### 1.1 User Entity
```swift
User {
    id: UUID (primary key)
    username: String (generated)
    passwordHash: String (12-word password hash)
    createdAt: Date
    lastLoginAt: Date
    isCloudSyncEnabled: Bool
    localData: [Card] (relationship)
}
```

#### 1.2 Card Entity
```swift
Card {
    id: UUID (primary key)
    cardType: String (e.g., "Amex Personal Gold")
    nickname: String (user-assigned)
    issuer: String (e.g., "American Express")
    network: String (e.g., "Amex")
    variant: String (e.g., "Personal", "Business")
    addedAt: Date
    isActive: Bool
    user: User (relationship)
    credits: [Credit] (relationship)
}
```

#### 1.3 Credit Entity
```swift
Credit {
    id: UUID (primary key)
    name: String (e.g., "Dining Credit")
    amount: Decimal
    currency: String (e.g., "USD")
    category: String (e.g., "Dining", "Travel")
    frequency: String (e.g., "Monthly", "Quarterly", "Annual")
    renewalDate: Date
    expirationDate: Date
    isUsed: Bool
    usedAt: Date?
    card: Card (relationship)
    usageHistory: [CreditUsage] (relationship)
}
```

#### 1.4 CreditUsage Entity
```swift
CreditUsage {
    id: UUID (primary key)
    usedAt: Date
    amount: Decimal
    notes: String?
    credit: Credit (relationship)
}
```

### 2. **Card Benefits Database**

#### 2.1 Card Definition (JSON)
```json
{
  "id": "amex-personal-gold",
  "name": "American Express Personal Gold Card",
  "issuer": "American Express",
  "network": "Amex",
  "variant": "Personal",
  "annualFee": 250,
  "credits": [
    {
      "id": "dining-credit",
      "name": "Dining Credit",
      "amount": 120,
      "currency": "USD",
      "category": "Dining",
      "frequency": "Annual",
      "description": "$10 monthly dining credit",
      "terms": "Valid at select restaurants and food delivery services"
    }
  ]
}
```

## Technology Stack

### 1. **Core Technologies**

#### 1.1 iOS Development
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Minimum iOS Version**: iOS 16.0
- **Target iOS Version**: iOS 18.0
- **Development Environment**: Xcode 16.0+

#### 1.2 Data Persistence
- **Local Storage**: Core Data
- **Cloud Storage**: CloudKit (optional)
- **Keychain**: iOS Keychain for credentials
- **File Storage**: iOS Documents directory

#### 1.3 Security
- **Encryption**: CryptoKit for data encryption
- **Authentication**: BIP-39 mnemonic generation
- **Key Management**: iOS Keychain
- **Network Security**: HTTPS/TLS 1.3

### 2. **Dependencies**

#### 2.1 Core Dependencies
- **SwiftUI**: Native iOS UI framework
- **Combine**: Reactive programming framework
- **Core Data**: Data persistence framework
- **CloudKit**: Cloud synchronization (optional)

#### 2.2 Security Dependencies
- **CryptoKit**: Cryptographic operations
- **Security Framework**: Keychain access
- **CommonCrypto**: Additional encryption utilities

#### 2.3 Development Dependencies
- **SwiftLint**: Code style enforcement
- **SwiftGen**: Asset and string generation
- **XCTest**: Unit and integration testing

## Security Architecture

### 1. **Authentication System**

#### 1.1 Credential Generation
- **Username**: Randomly generated 16-character string
- **Password**: BIP-39 mnemonic (12 words)
- **Storage**: iOS Keychain with biometric protection
- **Validation**: Local validation without network calls

#### 1.2 Data Protection
- **Local Data**: Encrypted using iOS Data Protection
- **Cloud Data**: End-to-end encrypted using CloudKit
- **Credentials**: Stored in iOS Keychain with biometric access
- **Backup**: Encrypted local backup with user control

### 2. **Privacy Measures**

#### 2.1 Data Minimization
- **No personal information collected**
- **No analytics or tracking**
- **No third-party data sharing**
- **Local-first data storage**

#### 2.2 Transparency
- **All code publicly accessible**
- **Security practices documented**
- **Data handling transparent**
- **Community audit capabilities**

## Performance Architecture

### 1. **Performance Requirements**

#### 1.1 Response Times
- **App Launch**: < 2 seconds
- **Search Operations**: < 500ms
- **Data Operations**: < 1 second
- **UI Interactions**: < 100ms

#### 1.2 Scalability
- **Support 100+ cards per user**
- **Support 500+ credits per user**
- **Efficient memory usage**
- **Battery optimization**

### 2. **Optimization Strategies**

#### 2.1 Data Optimization
- **Lazy loading for large datasets**
- **Efficient Core Data queries**
- **Background processing for sync**
- **Memory-efficient data structures**

#### 2.2 UI Optimization
- **SwiftUI performance best practices**
- **Efficient list rendering**
- **Background image processing**
- **Smooth animations and transitions**

## Cloud Integration (Optional)

### 1. **CloudKit Architecture**

#### 1.1 Sync Strategy
- **Local-first with cloud backup**
- **Conflict resolution with user choice**
- **Incremental sync for efficiency**
- **Offline capability maintained**

#### 1.2 Data Flow
```
Local Device ←→ CloudKit ←→ Other Devices
     ↑              ↑              ↑
  Primary      Backup/Sync     Secondary
  Storage                     Storage
```

### 2. **Sync Implementation**

#### 2.1 Sync Triggers
- **App launch and background refresh**
- **Manual sync initiation**
- **Data changes detection**
- **Network availability**

#### 2.2 Conflict Resolution
- **Timestamp-based conflict detection**
- **User choice for resolution**
- **Data integrity preservation**
- **Audit trail maintenance**

## Error Handling and Recovery

### 1. **Error Categories**

#### 1.1 Data Errors
- **Corruption detection and recovery**
- **Migration failures**
- **Sync conflicts**
- **Validation errors**

#### 1.2 System Errors
- **Memory pressure**
- **Disk space issues**
- **Network failures**
- **Authentication failures**

### 2. **Recovery Strategies**

#### 2.1 Data Recovery
- **Automatic backup restoration**
- **Manual data import/export**
- **Cloud backup recovery**
- **Corruption repair tools**

#### 2.2 System Recovery
- **Graceful degradation**
- **Retry mechanisms**
- **User notification**
- **Recovery guidance**

## Testing Architecture

### 1. **Testing Strategy**

#### 1.1 Unit Testing
- **Business logic testing**
- **Data model validation**
- **Service layer testing**
- **Security testing**

#### 1.2 Integration Testing
- **Core Data operations**
- **CloudKit integration**
- **Authentication flow**
- **Data migration**

#### 1.3 UI Testing
- **User journey testing**
- **Accessibility testing**
- **Performance testing**
- **Cross-device testing**

### 2. **Test Coverage Requirements**

#### 2.1 Code Coverage
- **Minimum 80% code coverage**
- **100% coverage for security-critical code**
- **100% coverage for data models**
- **Comprehensive UI testing**

#### 2.2 Test Quality
- **Fast test execution**
- **Reliable test results**
- **Comprehensive test scenarios**
- **Automated test execution**

## Deployment Architecture

### 1. **Build and Distribution**

#### 1.1 Build Process
- **Automated CI/CD pipeline**
- **Code quality checks**
- **Security scanning**
- **Performance testing**

#### 1.2 Distribution
- **App Store distribution**
- **TestFlight for beta testing**
- **Enterprise distribution (if needed)**
- **Open source code distribution**

### 2. **Monitoring and Analytics**

#### 2.1 App Performance
- **Crash reporting (privacy-focused)**
- **Performance metrics**
- **User engagement (anonymous)**
- **Error tracking**

#### 2.2 Community Metrics
- **GitHub activity tracking**
- **Community contribution metrics**
- **Issue resolution tracking**
- **Documentation usage**

## Success Metrics

### 1. **Technical Metrics**
- **App launch time**: < 2 seconds
- **Search response time**: < 500ms
- **Data operation time**: < 1 second
- **Memory usage**: < 100MB typical
- **Battery impact**: < 5% daily usage

### 2. **Quality Metrics**
- **Code coverage**: > 80%
- **Crash rate**: < 0.1%
- **Security vulnerabilities**: 0
- **Performance regressions**: 0

### 3. **Community Metrics**
- **GitHub stars**: Track and encourage
- **Community contributions**: Active participation
- **Issue resolution time**: < 24 hours
- **Documentation quality**: Comprehensive and clear

## Related Specifications

- See [01-product-vision.md](01-product-vision.md) for overall product vision
- See [03-functional-requirements.md](03-functional-requirements.md) for detailed functional requirements
- See [05-open-source-standards.md](05-open-source-standards.md) for open source development standards
- See [07-ui-ux-specifications.md](07-ui-ux-specifications.md) for UI/UX implementation guidelines

---

*This specification ensures that MyCardBook's technical architecture prioritizes privacy, performance, and community-driven development while maintaining enterprise-grade quality standards.* 