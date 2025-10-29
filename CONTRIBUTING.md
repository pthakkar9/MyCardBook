# Contributing to MyCardBook

Thank you for your interest in contributing to MyCardBook! We're excited to have you help us build the best privacy-first credit card benefit tracking app.

## 🚀 Quick Start

### Ways to Contribute
- **Add New Cards** - Submit card benefit data for cards we don't support yet
- **Report Bugs** - Help us identify and fix issues
- **Suggest Features** - Share ideas for improving the app
- **Improve Documentation** - Help others understand the project better
- **Code Contributions** - Fix bugs, implement features, optimize performance

## 🐛 Reporting Bugs

### Before You Report
1. **Search Existing Issues** - Check if someone already reported it
2. **Use Latest Version** - Update to the newest version first
3. **Test Consistently** - Can you reproduce the issue?

### How to Report
1. Go to [Issues](https://github.com/pthakkar9/MyCardBook/issues)
2. Click "New Issue" → "Bug Report"
3. **Include Details**:
   - iOS version (e.g., iOS 17.2)
   - Device model (e.g., iPhone 15 Pro)
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if helpful

### Example Bug Report
```
**Bug**: Credits not loading for Chase Sapphire Reserve

**Environment**:
- iOS 17.2 
- iPhone 14 Pro
- MyCardBook v1.0

**Steps**:
1. Add Chase Sapphire Reserve card
2. Navigate to Credits tab
3. Filter by "Chase Sapphire Reserve"

**Expected**: Should show 4 credits
**Actual**: Shows empty state

**Screenshot**: [attached]
```

## 💳 Adding New Credit Cards

### Card Data Format
We use a JSON database at `MyCardBook/Resources/CardDatabase/cards.json`. Here's the structure:

```json
{
  "id": "unique-card-id",
  "name": "Card Display Name",
  "issuer": "Bank Name", 
  "network": "visa|mastercard|amex|discover",
  "category": "personal|business",
  "color": "#HEX_COLOR",
  "credits": [
    {
      "id": "unique-credit-id",
      "title": "Credit Name",
      "description": "What the credit covers",
      "value": "$Amount",
      "frequency": "monthly|quarterly|annual",
      "category": "dining|travel|streaming|other"
    }
  ]
}
```

### Adding a New Card
1. **Research Thoroughly** - Verify all credit details from official sources
2. **Follow Naming Conventions** - Use official card names
3. **Include All Credits** - Only trackable credits (not cashback percentages)
4. **Test Locally** - Ensure the card loads properly in the app

### Example Card Addition
```json
{
  "id": "discover-it-cash-back",
  "name": "Discover it Cash Back",
  "issuer": "Discover",
  "network": "discover", 
  "category": "personal",
  "color": "#ff6600",
  "credits": []
}
```

## 💡 Feature Requests

### Before Requesting
- Check existing issues and discussions
- Consider if it aligns with our privacy-first mission
- Think about how it benefits all users

### How to Request
1. Go to [Issues](https://github.com/pthakkar9/MyCardBook/issues)
2. Click "New Issue" → "Feature Request"
3. **Describe**:
   - What problem it solves
   - How you envision it working
   - Why it's valuable for users

## 🛠 Code Contributions

### Development Setup
```bash
git clone https://github.com/pthakkar9/MyCardBook.git
cd MyCardBook
open MyCardBook.xcodeproj
```

### Requirements
- Xcode 15.0+
- iOS 16.0+ deployment target
- Swift 5.9+

### Code Standards
- **SwiftUI + Combine** - Use reactive programming patterns
- **MVVM Architecture** - Follow existing patterns
- **Privacy First** - No data collection or external dependencies
- **Performance** - Keep operations under 1 second
- **Testing** - Maintain 80%+ code coverage

### Pull Request Process
1. **Fork the repo** and create a feature branch
2. **Make your changes** following our code standards
3. **Test thoroughly** - run unit tests and manual testing
4. **Update documentation** if needed
5. **Submit PR** with clear description

### Example PR Description
```
## Summary
- Adds support for Citi Double Cash card
- Includes proper JSON structure and validation

## Testing
- [x] Card loads in Add Card dropdown
- [x] Card displays correctly in Cards tab
- [x] No credits show (expected for cash back card)
- [x] Unit tests pass
```

## 📝 Documentation

### Areas for Improvement
- User guides and tutorials
- Technical architecture docs
- Code comments and examples
- README improvements

### Style Guide
- Use clear, concise language
- Include code examples where helpful
- Focus on practical how-to information
- Keep privacy focus prominent

## 🎯 Priorities

### High Priority
1. **New Popular Cards** - Cards with significant user bases
2. **Critical Bugs** - App crashes, data loss, core functionality
3. **Privacy/Security** - Any issues affecting user data protection

### Medium Priority  
- UI/UX improvements
- Performance optimizations
- Additional features
- Documentation improvements

### Low Priority
- Nice-to-have features
- Cosmetic improvements
- Advanced power-user features

## 🔒 Privacy Guidelines

### Core Principles
- **Local First** - All data stays on device
- **No Tracking** - Zero analytics or data collection
- **Open Source** - Full transparency
- **User Control** - Complete data ownership

### Code Requirements
- No external network calls (except card database updates)
- No third-party analytics or tracking SDKs
- All data storage must be local (Core Data)
- Encryption for sensitive data

## 📊 Testing

### Quick Reference

```bash
# Run all tests (fastest in Xcode)
⌘ + U

# Run credit renewal tests from command line
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MyCardBookTests/CreditRenewalTests \
  -parallel-testing-enabled NO

# Run all tests with clean output
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  2>&1 | grep -E "(✔|✘|passed|failed)"

# List available simulators
xcrun simctl list devices available
```

### Running Tests

#### In Xcode (Recommended)
```bash
# Run all tests
⌘ + U

# Run specific test suite
1. Click test diamond (◇) next to test class/method
2. Or use Test Navigator (⌘ + 6) → Right-click → Run

# View test results
⌘ + 9 (Report Navigator) → Latest test run
```

#### From Command Line
```bash
# Run all tests
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'

# Run specific test suite (e.g., Credit Renewal Tests)
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MyCardBookTests/CreditRenewalTests

# Run without parallel testing (more reliable for debugging)
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -parallel-testing-enabled NO

# Get clean output
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  2>&1 | grep -E "(✔|✘|passed|failed)"
```

#### Available Test Simulators
Choose any iPhone simulator from your Xcode installation:
- iPhone 17 Pro Max (recommended for testing latest iOS)
- iPhone 16 Pro
- iPhone 15 Pro
- iPhone 14 Pro
- Or any other available simulator

To list all available simulators:
```bash
xcrun simctl list devices available
```

### Test Suites

#### MyCardBookTests (Unit Tests)
Located in `MyCardBookTests/`

**CreditRenewalTests** - 15 comprehensive tests for credit renewal logic:
- ✅ Monthly credit should renew on calendar boundaries
- ✅ Quarterly credit should renew at quarter boundaries
- ✅ Semi-annual credit should renew at half-year boundaries
- ✅ Annual credit should renew on January 1st
- ✅ Manual credits (Per Stay, Every 4 Years) do not auto-renew
- ✅ Unused credits SHOULD renew when crossing period boundaries
- ✅ Credits do not renew within the same period
- ✅ Usage tracking works correctly
- ✅ Semi-annual credit NOT used till Dec 31, shows correctly on Jan 1
- ✅ Semi-annual credit USED on Dec 31, renews correctly on Jan 1
- ✅ Monthly credit unused in January, renews correctly on Feb 1
- ✅ Quarterly credit used in Q4, renews correctly in Q1
- ✅ Annual credit unused in 2024, renews correctly in 2025
- ✅ Credit marked as used stays used until next period
- ✅ Newly created credit does not immediately renew

Run with:
```bash
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MyCardBookTests/CreditRenewalTests \
  -parallel-testing-enabled NO
```

**Other Unit Tests**:
- CreditRepositoryIntegrationTests - Repository layer integration tests

#### MyCardBookUITests (UI Tests)
Located in `MyCardBookUITests/`

**CreditRenewalUITests** - End-to-end UI testing for credit renewal flows

### Test Requirements
- **New Features**: Must include unit tests for business logic
- **Bug Fixes**: Add regression test to prevent reoccurrence
- **UI Changes**: Update or add UI tests for user flows
- **Performance**: Test data operations stay under 1 second
- **Coverage**: Maintain 80%+ overall code coverage

### Writing Good Tests

#### Test Structure (Swift Testing Framework)
```swift
import Testing
@testable import MyCardBook

struct MyFeatureTests {
    @Test("Description of what this tests")
    func testSpecificBehavior() async throws {
        // Arrange - Set up test data
        let testData = createTestData()

        // Act - Perform the operation
        let result = performOperation(testData)

        // Assert - Verify expected behavior
        #expect(result == expectedValue)
    }
}
```

#### Best Practices
- ✅ **Descriptive Names**: Use clear test method names
- ✅ **One Assertion Focus**: Each test should verify one behavior
- ✅ **Isolated Tests**: Tests should not depend on each other
- ✅ **Clean Test Data**: Use test fixtures or in-memory persistence
- ✅ **Fast Execution**: Keep tests under 1 second each
- ✅ **Deterministic**: Tests should always produce same result

#### Example Test Pattern
```swift
@Test("Monthly credit renews at month boundary")
func testMonthlyRenewal() async throws {
    // Use shared test persistence controller
    let context = Self.testPersistenceController.viewContext
    let credit = CreditEntity(context: context)

    // Set up test data with period start date
    credit.frequency = "Monthly"
    credit.renewalDate = Calendar.current.date(
        from: DateComponents(year: 2024, month: 1, day: 1)
    )
    credit.isUsed = true

    try context.save()

    // Test renewal logic
    let shouldRenew = credit.shouldRenew()
    #expect(shouldRenew == true)

    // Verify credit resets
    credit.renew()
    #expect(credit.isUsed == false)
}
```

### Continuous Testing

#### Before Committing
```bash
# Always run relevant tests before committing
xcodebuild test -scheme MyCardBook \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MyCardBookTests
```

#### Regular Test Runs
- Run full test suite daily during active development
- Run specific test suites when working on related features
- Check test results before submitting pull requests
- Monitor for flaky tests and fix them immediately

### Debugging Test Failures

#### Common Issues
1. **Timing Issues**: Use `#expect(abs(date1.timeIntervalSince(date2)) < 1.0)` instead of `==`
2. **Core Data Context**: Use shared persistence controller for tests
3. **Parallel Test Conflicts**: Disable with `-parallel-testing-enabled NO`
4. **Date Dependencies**: Use dynamic date calculations, not hard-coded dates

#### Debugging in Xcode
1. Set breakpoint in test method
2. Click test diamond with ⌥ (Option) to debug
3. Step through code to find issue
4. Check variables in Debug Area (⌘ + Shift + Y)

## 📞 Getting Help

### Communication Channels
- **GitHub Issues** - Bug reports, feature requests
- **GitHub Discussions** - General questions, ideas

### Response Times
- **Issues**: Usually within 24 hours
- **Pull Requests**: 1-3 business days
- **Email**: 24-48 hours

## 🏆 Recognition

### Contributors
All contributors are recognized in our:
- GitHub repository contributors list
- App Store credits (for significant contributions)
- CHANGELOG.md for each release

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain the project's privacy-first mission

## 📅 Release Process

### Version Schedule
- **Patch releases** (1.0.x) - Bug fixes, new cards
- **Minor releases** (1.x.0) - New features, major improvements  
- **Major releases** (x.0.0) - Significant architecture changes

### Contributing to Releases
- Bug fixes can be included in next patch
- Features typically wait for next minor release
- All changes need thorough testing

---

**Thank you for helping make MyCardBook better for everyone! 🙏**

*Your contributions help maintain a privacy-first, user-empowering tool that helps people maximize their credit card benefits.* 