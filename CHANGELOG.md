# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2025-10-28
### Fixed
- ✅ **Credit Renewal Test Suite**: Fixed all 15 unit tests for credit renewal logic
  - Fixed date normalization issues in test data (using period start dates instead of arbitrary dates)
  - Implemented tolerance-based date comparisons to handle microsecond timing differences
  - Fixed Core Data context lifecycle issues by using shared test persistence controller
  - All credit renewal scenarios now properly tested and verified
- 🧪 **UI Test Suite**: Fixed failing `testCreditsDisplayCorrectly()` UI test
  - Added accessibility identifiers to CreditsView components
  - Updated test to work with SwiftUI components instead of UIKit
  - All 4 UI tests now pass reliably

### Improved
- 🧪 **Test Infrastructure**: Enhanced test reliability and maintainability
  - Tests now run consistently with deterministic results
  - Proper Core Data context management for unit tests
  - Dynamic date calculations ensure tests remain valid over time
- 📚 **Documentation**: Comprehensive testing documentation added to CONTRIBUTING.md
  - Quick reference commands for common test operations
  - Detailed guide for running tests in Xcode and command-line
  - Best practices for writing and debugging tests
  - Full listing of all 15 credit renewal test cases

### Added
- 💳 **New Card**: Added Citi Advantage Globe card to database
- 🔄 **Updated Credits**: Refreshed benefits for:
  - American Express Platinum Personal
  - American Express Platinum Business
  - American Express Gold Business
- 👁️ **Manual Reset Credit Indicators**: Clear visual guidance for non-auto-resetting credits
  - Orange "Manual" badge with hand icon for "Every 4 Years" and "Per Stay" credits
  - Explanatory text: "This credit stays used until you manually reset it"
  - Helps users understand the difference between auto-reset and manual-reset credits

### Fixed
- 🐛 **iOS Compatibility**: Resolved iOS 17+ API compatibility issues for iOS 16.0 deployment
- 🐛 **Frequency Standardization**: Standardized credit frequency naming in card database
  - "Every 4 years" → "Every 4 Years" for consistency
  - "Semi-Annual" → "Semi-annual" for consistency
- 🐛 **Calendar Renewal Logic**: Fixed credit renewal to use calendar periods instead of relative dates
  - Monthly credits now reset on the 1st of each month
  - Quarterly credits reset at quarter boundaries (Jan 1, Apr 1, Jul 1, Oct 1)
  - Semi-annual credits reset at half-year boundaries (Jan 1, Jul 1)
  - Annual credits reset on January 1st each year

### Improved
- 🎯 **User Experience**: Better understanding of credit reset behavior
- 📊 **Data Consistency**: Standardized frequency handling across the entire app
- 🔧 **Code Quality**: Enhanced calendar period calculation logic
- ✅ **Testing**: Comprehensive build and test verification for iOS 16+ compatibility

### Technical Details
- **Minimum iOS**: 16.0 (previously 18.0)
- **Target iOS**: 18.0+ (unchanged)
- **Calendar Logic**: Implemented proper period boundary calculations
- **UI Enhancements**: Added conditional visual indicators for manual-reset credits
- **Build Verification**: Full clean build and test suite passing

## [1.0.0] - 2025-01-20
### Added
- 🎉 **Initial Release**: Privacy-first credit card benefit tracking app
- 📱 **Native iOS App**: Built with SwiftUI for iOS 16.0+
- 💳 **Comprehensive Card Database**: 23+ popular credit cards supported
  - American Express: Gold, Platinum, Business Gold, Business Platinum
  - Chase: Sapphire Preferred, Sapphire Reserve, United Explorer, Freedom cards
  - Capital One: Venture X, Savor Cash Rewards
  - Citi: Premier, Double Cash
  - Others: Discover, Wells Fargo, Bank of America
- 🎯 **Credit Tracking**: 40+ real credit benefits and allowances
  - Dining credits (Amex Gold $10/month Uber Eats, etc.)
  - Travel credits (Chase Sapphire Reserve $300/year, etc.)
  - Streaming credits (Amex Platinum entertainment, etc.)
  - Other valuable benefits across all supported cards
- 🔒 **Privacy-First Architecture**:
  - All data stored locally on device using Core Data
  - Zero data collection or tracking
  - No analytics or user behavior monitoring
  - Complete data ownership and control
- 📊 **Smart Features**:
  - One-tap credit usage tracking
  - Filter credits by card, category, or status
  - Search functionality across all credits
  - Renewal period tracking (monthly, quarterly, annual)
  - Total benefit value overview
- 🔄 **Data Portability**:
  - Export data in JSON format
  - Export data in CSV format
  - Import data for seamless backup restoration
  - Complete data control and migration support
- ⚡️ **Performance Optimized**:
  - Sub-2-second app launch time
  - Real-time search with <500ms response
  - Smooth 60 FPS animations and transitions
  - Efficient Core Data implementation
- 🎨 **Beautiful Native Design**:
  - iOS Human Interface Guidelines compliance
  - Dynamic Type and accessibility support
  - Dark mode support
  - Intuitive navigation with tab-based architecture
- 🏗 **Technical Foundation**:
  - MVVM architecture with Combine reactive programming
  - Repository pattern for clean data access
  - Comprehensive unit and UI test coverage
  - JSON-based card database for community contributions

### Technical Details
- **Language**: Swift 5.9+
- **Framework**: SwiftUI with Combine
- **Architecture**: MVVM + Repository Pattern
- **Data**: Core Data for local persistence
- **Minimum iOS**: 16.0
- **Target iOS**: 18.0
- **Testing**: XCTest with 80%+ coverage

### Security & Privacy
- **Local Storage**: All data encrypted and stored locally
- **No Network**: App functions completely offline
- **Open Source**: Full code transparency and auditability
- **iOS Keychain**: Sensitive data protected by iOS security
- **No Tracking**: Zero analytics, cookies, or data collection

### User Experience
- **Dashboard**: Overview of all cards and available credits
- **Cards Tab**: Manage your credit card collection
- **Credits Tab**: Track and filter all available benefits
- **Settings**: Data export/import and app preferences
- **Add Card**: Simple flow to add cards from supported database

### Open Source
- **MIT License**: Fully open source and community-driven
- **GitHub Repository**: Public development and contribution
- **Community Database**: JSON-based card database for easy updates
- **Contribution Guidelines**: Clear process for adding new cards and features
- **Documentation**: Comprehensive technical and user documentation

---

## Version History Summary
- **v1.2.0**: Expanded device support (iOS 16+), enhanced credit renewal logic, and manual reset indicators
- **v1.0.0**: Initial public release with 23+ cards, privacy-first design, and full feature set

---

*For detailed technical information, see [ARCHITECTURE.md](ARCHITECTURE.md)*  
*For contributing guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md)* 