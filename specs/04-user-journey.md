# MyCardBook - User Journey Specification

*Version: 1.0*
*Last Updated: 2025-07-14*

## Overview

This specification defines the complete user journey for the MyCardBook iOS app, from initial download through advanced usage scenarios. The journey prioritizes immediate usability while offering optional cloud sync for users who need cross-device functionality.

## Core User Journey Principles

### 1. **Immediate Usability**
- Users MUST be able to use the app instantly upon download
- No signup, login, or authentication barriers
- All core functionality available immediately

### 2. **Local-First Data Storage**
- All user data stored locally on device by default
- Complete privacy and offline functionality
- No data transmitted to external servers unless user explicitly opts in

### 3. **Optional Cloud Sync**
- Cloud sync only available when user explicitly chooses to sign up
- Seamless transition from local to cloud storage
- No data loss during transition

### 4. **Anonymous Authentication**
- When users choose to sign up, app generates credentials automatically
- No personal information required at any point
- Users can continue using app locally even after signing up

## User Journey Flows

### Flow 1: First-Time User (Local-Only)

#### 1.1 App Download & Launch
**User Action**: Downloads app from App Store and opens it
**App Response**: 
- App launches immediately to main dashboard
- No welcome screen, no signup prompts
- Shows empty state with "Add Your First Card" button
**Data Storage**: No user data yet

#### 1.2 First Card Addition
**User Action**: Taps "Add Your First Card" button
**App Response**:
- Shows card selection screen with searchable list
- User can search by issuer (Amex, Chase, etc.) or card name
- User selects card (e.g., "Amex Personal Gold")
**Data Storage**: Card information stored locally on device

#### 1.3 Card Configuration
**User Action**: Assigns nickname to card (optional)
**App Response**:
- Shows card benefits automatically loaded from local database
- Displays available credits with usage tracking interface
- User can start tracking credit usage immediately
**Data Storage**: Card nickname and usage data stored locally

#### 1.4 Ongoing Usage (Local)
**User Action**: Uses app to track credits, add more cards, mark credits as used
**App Response**:
- All functionality available immediately
- Data persists locally across app launches
- No internet connection required
**Data Storage**: All card data, usage history, and preferences stored locally

### Flow 2: Optional Signup for Cloud Sync

#### 2.1 Signup Discovery
**User Action**: Discovers signup option in Settings or when trying to use on another device
**App Response**:
- Shows clear explanation of benefits (cross-device sync, backup)
- Emphasizes that local usage continues unchanged
- No pressure to sign up
**Data Storage**: Local data remains unchanged

#### 2.2 Signup Process
**User Action**: Chooses to sign up
**App Response**:
- Generates unique username automatically
- Generates 12-word password using BIP-39 standard
- Displays credentials clearly for user to save
- Explains that existing local data will be synced to cloud
**Data Storage**: Credentials stored securely in iOS Keychain

#### 2.3 Data Migration
**User Action**: Confirms signup
**App Response**:
- Uploads existing local data to cloud (encrypted)
- Maintains local copy as backup
- Shows sync status and completion
- App continues to work exactly as before
**Data Storage**: Data now stored both locally and in cloud

#### 2.4 Post-Signup Usage
**User Action**: Continues using app normally
**App Response**:
- All functionality remains the same
- Data automatically syncs between devices
- Local data serves as backup and offline access
- User can access data on multiple devices
**Data Storage**: Data synchronized between local device and cloud

### Flow 3: Multi-Device Usage

#### 3.1 Second Device Setup
**User Action**: Downloads app on second device (iPhone, iPad, etc.)
**App Response**:
- App launches to main dashboard
- Shows option to sign in with existing credentials
- No pressure to sign in immediately
**Data Storage**: No local data on new device yet

#### 3.2 Sign In Process
**User Action**: Chooses to sign in with generated credentials
**App Response**:
- Validates username and 12-word password
- Downloads and syncs all data from cloud
- Shows sync progress and completion
- App now shows all cards and usage data
**Data Storage**: All data now available locally on new device

#### 3.3 Cross-Device Synchronization
**User Action**: Uses app on multiple devices
**App Response**:
- Changes sync automatically between devices
- Local data serves as backup and offline access
- Seamless experience across all devices
**Data Storage**: Data synchronized across all signed-in devices

### Flow 4: Privacy-Focused User

#### 4.1 Local-Only Usage
**User Action**: Chooses to never sign up, uses app only locally
**App Response**:
- All functionality available without any limitations
- Data remains completely private on device
- No data transmitted to external servers
**Data Storage**: All data stored locally only

#### 4.2 Data Export/Import
**User Action**: Exports data for backup or transfer
**App Response**:
- Exports all data as JSON or CSV
- User can import data on new device manually
- No cloud dependency for data portability
**Data Storage**: Export files stored in user's chosen location

## Key User Experience Moments

### 1. **Zero-Friction Onboarding**
- **Moment**: First app launch
- **User Expectation**: "I want to start using this immediately"
- **App Response**: Immediate access to all features
- **Success Metric**: Time from download to first card addition

### 2. **Privacy Confidence**
- **Moment**: User realizes no signup is required
- **User Expectation**: "My data stays private"
- **App Response**: Clear local-only data storage
- **Success Metric**: User continues using app without signup

### 3. **Optional Value Discovery**
- **Moment**: User discovers signup benefits
- **User Expectation**: "What's in it for me?"
- **App Response**: Clear value proposition without pressure
- **Success Metric**: Signup conversion rate

### 4. **Seamless Transition**
- **Moment**: User chooses to sign up
- **User Expectation**: "Don't break what's working"
- **App Response**: Smooth migration with no data loss
- **Success Metric**: Zero data loss during signup

### 5. **Cross-Device Delight**
- **Moment**: User accesses data on second device
- **User Expectation**: "Everything should be there"
- **App Response**: Complete data synchronization
- **Success Metric**: Time to full sync on new device

## Data Storage Implications

### Local-Only Users
- **Data Location**: Device storage only
- **Privacy Level**: Maximum (no external data transmission)
- **Functionality**: Complete app functionality
- **Limitations**: No cross-device sync, manual backup required

### Cloud Sync Users
- **Data Location**: Local device + encrypted cloud
- **Privacy Level**: High (encrypted cloud storage)
- **Functionality**: Complete app functionality + cross-device sync
- **Benefits**: Automatic backup, multi-device access

## User Journey Success Metrics

### 1. **Immediate Usability**
- Time from app launch to first card addition: < 30 seconds
- Percentage of users who add a card without signup: > 80%

### 2. **Privacy Adoption**
- Percentage of users who never sign up: Track and optimize
- User satisfaction with local-only experience: > 4.5/5

### 3. **Optional Signup**
- Signup conversion rate: Track and optimize
- Time from signup decision to completion: < 2 minutes
- Data migration success rate: 100%

### 4. **Cross-Device Experience**
- Time to full sync on new device: < 1 minute
- Cross-device usage satisfaction: > 4.5/5

## Related Specifications

- See [01-product-vision.md](01-product-vision.md) for overall product vision
- See [03-functional-requirements.md](03-functional-requirements.md) for detailed functional requirements
- See [02-brand-identity.md](02-brand-identity.md) for UI/UX guidelines

---

*This specification ensures the user journey prioritizes privacy, immediate usability, and optional value-add features.* 