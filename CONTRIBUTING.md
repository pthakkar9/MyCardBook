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

### Running Tests
```bash
# In Xcode
⌘ + U (Run all tests)

# Or specific test suites
- MyCardBookTests (Unit tests)
- MyCardBookUITests (UI tests)
```

### Test Requirements
- Unit tests for new business logic
- UI tests for new user flows
- Performance tests for data operations
- Security tests for sensitive features

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