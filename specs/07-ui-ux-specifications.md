# MyCardBook - UI/UX Specifications

*Version: 1.0*
*Last Updated: 2025-07-14*

## Overview

This specification defines the user interface and user experience design for the MyCardBook iOS application. The design prioritizes simplicity, accessibility, and native iOS feel while maintaining the privacy-first and open source values of the product.

## Design Philosophy

### 1. **Simplicity First**
- **Every interaction MUST be intuitive** and require minimal cognitive load
- **Complex financial concepts MUST be presented simply** and clearly
- **The interface MUST feel effortless** and enjoyable to use
- **Visual clutter MUST be eliminated** in favor of clean, focused design

### 2. **Native iOS Experience**
- **Design MUST follow iOS Human Interface Guidelines** completely
- **Navigation MUST use standard iOS patterns** and gestures
- **Animations MUST feel native** and responsive
- **Accessibility MUST be built-in** from the ground up

### 3. **Privacy-First Design**
- **UI MUST communicate privacy** and data control clearly
- **Settings MUST be easily accessible** and understandable
- **Data handling MUST be transparent** through clear visual cues
- **User control MUST be prominent** in all interactions

### 4. **Accessibility by Design**
- **All features MUST be accessible** to users with disabilities
- **VoiceOver support MUST be comprehensive** and intuitive
- **Dynamic Type MUST be supported** throughout the app
- **Color contrast MUST meet WCAG AA standards**

## Design System

### 1. **Color Palette**

#### 1.1 Primary Colors
```swift
// Primary Brand Colors
let primaryBlue = Color(red: 0.0, green: 0.478, blue: 1.0)      // #007AFF
let primaryGreen = Color(red: 0.2, green: 0.8, blue: 0.4)       // #33CC66
let primaryOrange = Color(red: 1.0, green: 0.584, blue: 0.0)    // #FF9500

// Semantic Colors
let successGreen = Color(red: 0.2, green: 0.8, blue: 0.4)       // #33CC66
let warningOrange = Color(red: 1.0, green: 0.584, blue: 0.0)    // #FF9500
let errorRed = Color(red: 1.0, green: 0.231, blue: 0.188)       // #FF3B30
let infoBlue = Color(red: 0.0, green: 0.478, blue: 1.0)         // #007AFF
```

#### 1.2 Neutral Colors
```swift
// Background Colors
let systemBackground = Color(.systemBackground)
let secondaryBackground = Color(.secondarySystemBackground)
let tertiaryBackground = Color(.tertiarySystemBackground)

// Text Colors
let primaryText = Color(.label)
let secondaryText = Color(.secondaryLabel)
let tertiaryText = Color(.tertiaryLabel)
let quaternaryText = Color(.quaternaryLabel)
```

#### 1.3 Credit Category Colors
```swift
// Credit Category Colors
let diningColor = Color(red: 0.8, green: 0.2, blue: 0.2)        // #CC3333
let travelColor = Color(red: 0.2, green: 0.4, blue: 0.8)        // #3366CC
let shoppingColor = Color(red: 0.6, green: 0.2, blue: 0.8)      // #9933CC
let entertainmentColor = Color(red: 0.8, green: 0.4, blue: 0.2) // #CC6633
let wellnessColor = Color(red: 0.2, green: 0.8, blue: 0.6)      // #33CC99
```

### 2. **Typography**

#### 2.1 Font System
```swift
// Font Families
let primaryFont = Font.system(.body, design: .default)
let headingFont = Font.system(.title, design: .default)
let captionFont = Font.system(.caption, design: .default)

// Font Sizes (Dynamic Type Supported)
let largeTitle = Font.largeTitle
let title1 = Font.title
let title2 = Font.title2
let title3 = Font.title3
let headline = Font.headline
let body = Font.body
let callout = Font.callout
let subheadline = Font.subheadline
let footnote = Font.footnote
let caption1 = Font.caption
let caption2 = Font.caption2
```

#### 2.2 Text Hierarchy
- **Large Title**: App name and main headings
- **Title 1**: Section headers and card titles
- **Title 2**: Subsection headers
- **Title 3**: Card subtitles and important labels
- **Headline**: Emphasis text and key information
- **Body**: Main content and descriptions
- **Callout**: Highlighted information
- **Subheadline**: Secondary information
- **Footnote**: Supporting text and metadata
- **Caption**: Small labels and timestamps

### 3. **Spacing System**

#### 3.1 Spacing Scale
```swift
// Spacing Values (8pt grid system)
let spacing2 = CGFloat(2)   // 2pt
let spacing4 = CGFloat(4)   // 4pt
let spacing8 = CGFloat(8)   // 8pt
let spacing12 = CGFloat(12) // 12pt
let spacing16 = CGFloat(16) // 16pt
let spacing20 = CGFloat(20) // 20pt
let spacing24 = CGFloat(24) // 24pt
let spacing32 = CGFloat(32) // 32pt
let spacing40 = CGFloat(40) // 40pt
let spacing48 = CGFloat(48) // 48pt
let spacing64 = CGFloat(64) // 64pt
```

#### 3.2 Layout Guidelines
- **Content margins**: 16pt on all sides
- **Section spacing**: 24pt between major sections
- **Card spacing**: 12pt between cards
- **Element spacing**: 8pt between related elements
- **Touch targets**: Minimum 44pt height for interactive elements

### 4. **Component Library**

#### 4.1 Card Components

##### 4.1.1 Credit Card Display
```swift
struct CreditCardView: View {
    let card: Card
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing8) {
            HStack {
                Text(card.nickname)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Text(card.issuer)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Text(card.cardType)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            HStack {
                Text("\(card.credits.count) credits")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
                Spacer()
                Text("$\(card.totalValue)")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .padding(spacing16)
        .background(Color.secondaryBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.primaryBlue : Color.clear, lineWidth: 2)
        )
    }
}
```

##### 4.1.2 Credit Item Display
```swift
struct CreditItemView: View {
    let credit: Credit
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: spacing12) {
            // Category Icon
            Image(systemName: categoryIcon)
                .foregroundColor(categoryColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: spacing4) {
                Text(credit.name)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text("$\(credit.amount) \(credit.frequency)")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            // Usage Status
            Button(action: onToggle) {
                Image(systemName: credit.isUsed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(credit.isUsed ? .successGreen : .tertiaryText)
                    .font(.title2)
            }
        }
        .padding(spacing16)
        .background(Color.systemBackground)
        .cornerRadius(8)
    }
}
```

#### 4.2 Navigation Components

##### 4.2.1 Tab Bar
```swift
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            CardsView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Cards")
                }
                .tag(1)
            
            CreditsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Credits")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
    }
}
```

##### 4.2.2 Navigation Bar
```swift
struct CustomNavigationBar: View {
    let title: String
    let showBackButton: Bool
    let trailingButton: (() -> AnyView)?
    
    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { /* Navigation */ }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primaryBlue)
                }
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            if let trailingButton = trailingButton {
                trailingButton()
            } else {
                Color.clear
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, spacing16)
        .padding(.vertical, spacing8)
    }
}
```

#### 4.3 Form Components

##### 4.3.1 Text Input
```swift
struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.body)
        }
    }
}
```

##### 4.3.2 Button Styles
```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}
```

### 5. **Screen Designs**

#### 5.1 Dashboard Screen
```swift
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: spacing24) {
                    // Summary Cards
                    SummaryCardsView(summary: viewModel.summary)
                    
                    // Expiring Credits
                    ExpiringCreditsView(credits: viewModel.expiringCredits)
                    
                    // Recent Activity
                    RecentActivityView(activities: viewModel.recentActivities)
                }
                .padding(spacing16)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
}
```

#### 5.2 Cards Screen
```swift
struct CardsView: View {
    @StateObject private var viewModel = CardsViewModel()
    @State private var showingAddCard = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cards) { card in
                    CreditCardView(card: card, isSelected: false)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: spacing8, leading: spacing16, bottom: spacing8, trailing: spacing16))
                }
            }
            .listStyle(.plain)
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Card") {
                        showingAddCard = true
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView()
            }
        }
    }
}
```

#### 5.3 Credits Screen
```swift
struct CreditsView: View {
    @StateObject private var viewModel = CreditsViewModel()
    @State private var selectedFilter: CreditFilter = .all
    
    var body: some View {
        NavigationView {
            VStack(spacing: spacing16) {
                // Filter Pills
                FilterPillsView(selectedFilter: $selectedFilter)
                
                // Credits List
                List {
                    ForEach(viewModel.filteredCredits(selectedFilter)) { credit in
                        CreditItemView(credit: credit) {
                            viewModel.toggleCredit(credit)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: spacing8, leading: spacing16, bottom: spacing8, trailing: spacing16))
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
```

### 6. **Accessibility Guidelines**

#### 6.1 VoiceOver Support
```swift
// Example of VoiceOver implementation
Button(action: toggleCredit) {
    Image(systemName: credit.isUsed ? "checkmark.circle.fill" : "circle")
}
.accessibilityLabel("Mark \(credit.name) as used")
.accessibilityHint("Double tap to toggle usage status")
.accessibilityValue(credit.isUsed ? "Used" : "Available")
```

#### 6.2 Dynamic Type Support
```swift
// All text must support Dynamic Type
Text("Credit Amount")
    .font(.headline) // Automatically scales with system settings
    .lineLimit(nil) // Allows text to wrap if needed
```

#### 6.3 Color and Contrast
- **All text MUST have sufficient contrast** against backgrounds
- **Color MUST NOT be the only way** to convey information
- **Interactive elements MUST be clearly identifiable**
- **Focus indicators MUST be visible** for accessibility

### 7. **Animation Guidelines**

#### 7.1 Animation Principles
- **Animations MUST feel natural** and responsive
- **Duration MUST be appropriate** for the interaction (0.2-0.4s)
- **Easing MUST use standard iOS curves** (ease-in-out)
- **Animations MUST respect user preferences** (reduced motion)

#### 7.2 Common Animations
```swift
// Card selection animation
.animation(.easeInOut(duration: 0.2), value: isSelected)

// List item appearance
.animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.05), value: isVisible)

// Button press feedback
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.easeInOut(duration: 0.1), value: isPressed)
```

### 8. **Responsive Design**

#### 8.1 Device Support
- **iPhone SE (2nd generation) and newer**
- **iPad (6th generation) and newer**
- **All screen sizes and orientations**
- **Safe area and notch considerations**

#### 8.2 Adaptive Layout
```swift
// Responsive grid layout
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 300, maximum: 400))
], spacing: spacing16) {
    ForEach(cards) { card in
        CreditCardView(card: card)
    }
}
```

### 9. **Dark Mode Support**

#### 9.1 Color Adaptation
```swift
// All colors must work in both light and dark modes
Color(.systemBackground) // Automatically adapts
Color(.label) // Automatically adapts
Color(.secondaryLabel) // Automatically adapts
```

#### 9.2 Image Adaptation
```swift
// Icons and images must be visible in both modes
Image(systemName: "creditcard.fill")
    .foregroundColor(.primaryText) // Adapts automatically
```

## Success Metrics

### 1. **Usability Metrics**
- **Task completion rate**: > 95%
- **Time to complete key tasks**: < 30 seconds
- **Error rate**: < 2%
- **User satisfaction**: > 4.5/5

### 2. **Accessibility Metrics**
- **VoiceOver compatibility**: 100%
- **Dynamic Type support**: 100%
- **Color contrast compliance**: WCAG AA
- **Keyboard navigation**: 100%

### 3. **Performance Metrics**
- **Animation frame rate**: 60fps
- **UI response time**: < 100ms
- **Memory usage**: < 100MB
- **Battery impact**: < 5% daily usage

## Related Specifications

- See [02-brand-identity.md](02-brand-identity.md) for brand guidelines and visual identity
- See [04-user-journey.md](04-user-journey.md) for user experience flows
- See [06-technical-architecture.md](06-technical-architecture.md) for technical implementation details
- See [08-security-privacy.md](08-security-privacy.md) for security and privacy considerations

---

*This specification ensures that MyCardBook's user interface and experience prioritize simplicity, accessibility, and native iOS feel while maintaining the privacy-first and open source values of the product.* 