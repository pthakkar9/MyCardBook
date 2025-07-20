# MyCardBook - Functional Requirements Specification

*Version: 1.0*
*Last Updated: 2025-07-14*

## Overview

This specification defines the functional requirements for the MyCardBook iOS application. The app provides anonymous authentication, local data storage, and credit card benefit tracking without requiring any personal information. All code and documentation will be open source and publicly available on GitHub.

## Core Functional Requirements

### 1. Anonymous Authentication System

#### 1.1 Optional User Registration
- **FR-1.1.1**: The app must allow immediate usage without any authentication
- **FR-1.1.2**: The app must generate a unique username automatically when user chooses to sign up
- **FR-1.1.3**: The app must generate a 12-word password phrase using BIP-39 mnemonic standard when user chooses to sign up
- **FR-1.1.4**: Users must be able to regenerate their username and password if desired
- **FR-1.1.5**: The app must display the username and 12-word password clearly for user to save
- **FR-1.1.6**: No personal information (email, phone, name) shall be required or collected

#### 1.2 User Login
- **FR-1.2.1**: Users must be able to login using their generated username and 12-word password
- **FR-1.2.2**: The app must validate the 12-word password against BIP-39 standard
- **FR-1.2.3**: Users must be able to reset their credentials if forgotten (generates new username/password)
- **FR-1.2.4**: Login must work offline without internet connection
- **FR-1.2.5**: Failed login attempts must be handled gracefully with clear error messages

#### 1.3 Data Persistence
- **FR-1.3.1**: All user data must be stored locally on the device using iOS Core Data by default
- **FR-1.3.2**: User credentials must be stored securely using iOS Keychain when user chooses to sign up
- **FR-1.3.3**: Data must persist across app launches and device restarts
- **FR-1.3.4**: Users must be able to export their data as JSON or CSV
- **FR-1.3.5**: Users must be able to import data from exported files
- **FR-1.3.6**: When user chooses to sign up, existing local data must be migrated to cloud storage
- **FR-1.3.7**: Local data must be maintained as backup even after cloud sync is enabled

### 2. Credit Card Management

#### 2.1 Card Addition
- **FR-2.1.1**: Users must be able to add credit cards by selecting from a predefined list
- **FR-2.1.2**: The card list must be searchable and filterable by issuer (Amex, Chase, etc.)
- **FR-2.1.3**: Users must be able to assign custom nicknames to their cards
- **FR-2.1.4**: Users must be able to add multiple instances of the same card type
- **FR-2.1.5**: No actual card numbers, CVVs, or sensitive information shall be stored

#### 2.2 Card Information Display
- **FR-2.2.1**: Each card must display its full name and user-assigned nickname
- **FR-2.2.2**: Cards must show the total number of available credits
- **FR-2.2.3**: Cards must display usage status (e.g., "3 of 5 credits used")
- **FR-2.2.4**: Cards must be sortable by name, nickname, or usage status
- **FR-2.2.5**: Cards must be searchable by nickname or card name

#### 2.3 Card Management
- **FR-2.3.1**: Users must be able to edit card nicknames
- **FR-2.3.2**: Users must be able to delete cards and all associated credit data
- **FR-2.3.3**: Users must be able to duplicate cards (useful for multiple instances)
- **FR-2.3.4**: Card deletion must require confirmation to prevent accidental loss
- **FR-2.3.5**: Users must be able to archive cards instead of deleting them

### 3. Credit Tracking System

#### 3.1 Credit Display
- **FR-3.1.1**: Each credit must display its name, amount, and renewal frequency
- **FR-3.1.2**: Credits must show current status (Available, Used, Expired)
- **FR-3.1.3**: Credits must display renewal dates and expiration warnings
- **FR-3.1.4**: Credits must be grouped by card and sortable by various criteria
- **FR-3.1.5**: Credits must show usage history and dates

#### 3.2 Credit Usage Tracking
- **FR-3.2.1**: Users must be able to mark credits as "used" with a single tap
- **FR-3.2.2**: Users must be able to specify the date when a credit was used
- **FR-3.2.3**: Users must be able to mark credits as used for past periods
- **FR-3.2.4**: The app must automatically track renewal periods and update status
- **FR-3.2.5**: Users must be able to undo credit usage actions

#### 3.3 Credit Categories
- **FR-3.3.1**: Credits must be categorized by type (Dining, Travel, Shopping, etc.)
- **FR-3.3.2**: Users must be able to filter credits by category
- **FR-3.3.3**: Credits must show category-specific icons and colors
- **FR-3.3.4**: Users must be able to view credits by category across all cards

### 4. Dashboard and Overview

#### 4.1 Main Dashboard
- **FR-4.1.1**: Dashboard must show total available credits across all cards
- **FR-4.1.2**: Dashboard must display expiring credits prominently
- **FR-4.1.3**: Dashboard must show recent activity and usage
- **FR-4.1.4**: Dashboard must provide quick access to add new cards
- **FR-4.1.5**: Dashboard must show usage statistics and insights

#### 4.2 Credit Summary
- **FR-4.2.1**: Users must see total value of available credits
- **FR-4.2.2**: Users must see total value of used credits
- **FR-4.2.3**: Users must see credit utilization percentage
- **FR-4.2.4**: Users must see upcoming renewals and expirations
- **FR-4.2.5**: Users must see credit usage trends over time

#### 4.3 Quick Actions
- **FR-4.3.1**: Users must be able to mark credits as used from dashboard
- **FR-4.3.2**: Users must be able to add new cards from dashboard
- **FR-4.3.3**: Users must be able to view detailed credit information
- **FR-4.3.4**: Users must be able to search across all cards and credits
- **FR-4.3.5**: Users must be able to access settings and help from dashboard

### 5. Card Benefits Database

#### 5.1 Built-in Database
- **FR-5.1.1**: The app must include a comprehensive database of credit card benefits
- **FR-5.1.2**: Database must be stored locally and updated with app updates
- **FR-5.1.3**: Database must include major issuers (Amex, Chase, Citi, etc.)
- **FR-5.1.4**: Database must include popular premium and business cards
- **FR-5.1.5**: Database must be open source and community-contributable

#### 5.2 Database Structure
- **FR-5.2.1**: Each card must have a unique identifier and display name
- **FR-5.2.2**: Each credit must have name, amount, frequency, and category
- **FR-5.2.3**: Credits must include renewal periods and terms
- **FR-5.2.4**: Database must support multiple card variants (Personal, Business, etc.)
- **FR-5.2.5**: Database must include card issuer and network information

#### 5.3 Database Updates
- **FR-5.3.1**: Database must be updatable through app updates
- **FR-5.3.2**: Users must be notified of new cards and benefits
- **FR-5.3.3**: Database must be versioned and trackable
- **FR-5.3.4**: Database must be exportable and importable
- **FR-5.3.5**: Database must support community contributions through GitHub
- **FR-5.3.6**: Database must be publicly accessible and editable by the community
- **FR-5.3.7**: Database changes must be tracked and versioned through Git

### 6. User Interface Requirements

#### 6.1 Navigation
- **FR-6.1.1**: App must use iOS native navigation patterns
- **FR-6.1.2**: App must have clear tab bar navigation
- **FR-6.1.3**: App must support swipe gestures for common actions
- **FR-6.1.4**: App must provide clear back navigation
- **FR-6.1.5**: App must support deep linking for specific cards/credits

#### 6.2 Search and Filter
- **FR-6.2.1**: Users must be able to search cards by name or nickname
- **FR-6.2.2**: Users must be able to search credits by name or category
- **FR-6.2.3**: Users must be able to filter by credit status
- **FR-6.2.4**: Users must be able to filter by card issuer
- **FR-6.2.5**: Search must work offline and be fast

#### 6.3 Accessibility
- **FR-6.3.1**: App must support VoiceOver for screen readers
- **FR-6.3.2**: App must support Dynamic Type for text scaling
- **FR-6.3.3**: App must have sufficient color contrast
- **FR-6.3.4**: App must support reduced motion preferences
- **FR-6.3.5**: App must be navigable by keyboard and switch control

### 7. Data Management

#### 7.1 Local Storage
- **FR-7.1.1**: All data must be stored locally using Core Data by default
- **FR-7.1.2**: Data must be encrypted at rest
- **FR-7.1.3**: Data must be backed up with iCloud (optional)
- **FR-7.1.4**: Data must be exportable in multiple formats
- **FR-7.1.5**: Data must be importable from exported files
- **FR-7.1.6**: Local data must serve as primary storage for users who don't sign up
- **FR-7.1.7**: Local data must serve as backup for users who do sign up

#### 7.2 Data Export/Import
- **FR-7.2.1**: Users must be able to export all data as JSON
- **FR-7.2.2**: Users must be able to export all data as CSV
- **FR-7.2.3**: Users must be able to import data from exported files
- **FR-7.2.4**: Import must validate data integrity
- **FR-7.2.5**: Import must handle conflicts gracefully

#### 7.3 Data Privacy
- **FR-7.3.1**: No data shall be transmitted to external servers unless user explicitly chooses to sign up
- **FR-7.3.2**: No analytics or tracking shall be implemented
- **FR-7.3.3**: No personal information shall be collected
- **FR-7.3.4**: All data shall remain on the user's device by default
- **FR-7.3.5**: Users shall have complete control over their data
- **FR-7.3.6**: Users shall be able to use the app completely offline without any limitations

### 8. Settings and Preferences

#### 8.1 App Settings
- **FR-8.1.1**: Users must be able to regenerate their credentials
- **FR-8.1.2**: Users must be able to export their data
- **FR-8.1.3**: Users must be able to import data
- **FR-8.1.4**: Users must be able to clear all data
- **FR-8.1.5**: Users must be able to view app version and database version

#### 8.2 Display Preferences
- **FR-8.2.1**: Users must be able to choose date format
- **FR-8.2.2**: Users must be able to choose currency display
- **FR-8.2.3**: Users must be able to set default sorting preferences
- **FR-8.2.4**: Users must be able to customize dashboard layout
- **FR-8.2.5**: Users must be able to set notification preferences

#### 8.3 Help and Support
- **FR-8.3.1**: App must include built-in help documentation
- **FR-8.3.2**: App must provide direct links to GitHub repository and documentation
- **FR-8.3.3**: App must include privacy policy and terms
- **FR-8.3.4**: App must provide contact information for support and community
- **FR-8.3.5**: App must include tutorial for first-time users
- **FR-8.3.6**: App must provide links to community contribution guidelines
- **FR-8.3.7**: App must include links to report issues or suggest features on GitHub

## Non-Functional Requirements

### Performance
- **NFR-1**: App must launch within 2 seconds on supported devices
- **NFR-2**: Search must respond within 500ms
- **NFR-3**: Data operations must complete within 1 second
- **NFR-4**: App must work smoothly with 100+ cards and 500+ credits
- **NFR-5**: App must use minimal battery and storage

### Reliability
- **NFR-6**: App must work offline without internet connection
- **NFR-7**: App must handle data corruption gracefully
- **NFR-8**: App must provide data backup and recovery options
- **NFR-9**: App must not crash or lose data
- **NFR-10**: App must handle edge cases and invalid data

### Security
- **NFR-11**: User credentials must be stored securely in Keychain
- **NFR-12**: Local data must be encrypted
- **NFR-13**: No sensitive data shall be transmitted
- **NFR-14**: App must validate all input data
- **NFR-15**: App must handle authentication failures gracefully

## User Stories

### Authentication Stories
- **US-1**: As a new user, I want to get started immediately without providing personal information
- **US-2**: As a user, I want to login securely using my generated credentials
- **US-3**: As a user, I want to reset my credentials if I forget them
- **US-4**: As a user, I want my data to stay private and local to my device

### Card Management Stories
- **US-5**: As a user, I want to add my credit cards by selecting from a list
- **US-6**: As a user, I want to give my cards custom nicknames
- **US-7**: As a user, I want to add multiple cards of the same type
- **US-8**: As a user, I want to see all my cards in one organized view

### Credit Tracking Stories
- **US-9**: As a user, I want to see all my available credits in one place
- **US-10**: As a user, I want to mark credits as used with a simple tap
- **US-11**: As a user, I want to track when I used each credit
- **US-12**: As a user, I want to see which credits are expiring soon

### Dashboard Stories
- **US-13**: As a user, I want to see my total credit value at a glance
- **US-14**: As a user, I want to quickly access my most important information
- **US-15**: As a user, I want to search and filter my cards and credits
- **US-16**: As a user, I want to export my data for backup

## Related Specifications

- See [01-product-vision.md](01-product-vision.md) for product vision and core principles
- See [02-brand-identity.md](02-brand-identity.md) for brand guidelines and visual identity
- See [05-open-source-standards.md](05-open-source-standards.md) for open source development standards

---

*This specification defines all functional requirements for the MyCardBook iOS application.* 