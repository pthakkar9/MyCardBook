# Contributing to MyCardBook Card Database

Thank you for your interest in contributing to the MyCardBook card database! This community-driven database helps users track credit card benefits accurately and comprehensively.

## Overview

The MyCardBook card database is designed to be maintained by the community, similar to Wikipedia. All contributions are welcome, from adding new cards to updating existing benefit information.

## How to Contribute

### 1. Adding New Cards

To add a new credit card to the database:

1. **Fork the Repository** - Fork the MyCardBook repository on GitHub
2. **Locate the Database** - Navigate to `MyCardBook/Resources/CardDatabase/cards.json`
3. **Add Your Card** - Follow the JSON schema defined in `schema.json`
4. **Test Your Changes** - Validate your JSON using the provided schema
5. **Submit a Pull Request** - Include a clear description of the card you're adding

### 2. Updating Existing Cards

To update benefit information for existing cards:

1. **Verify Information** - Ensure all benefit details are accurate and current
2. **Update the JSON** - Modify the appropriate card entry in `cards.json`
3. **Document Sources** - Include links to official sources in your pull request
4. **Submit Changes** - Create a pull request with detailed change notes

### 3. Card Information Requirements

All card entries must include:

#### Required Fields
- **Card Type**: Full official name of the card
- **Issuer**: Bank or financial institution (e.g., "American Express", "Chase")
- **Network**: Payment network (e.g., "Amex", "Visa", "Mastercard")
- **Variant**: "Personal" or "Business"
- **Category**: Card category (e.g., "Travel Rewards", "Cash Back")
- **Annual Fee**: Fee in USD (use 0 for no fee)

#### Credit Benefits
For each credit benefit, include:
- **Name**: Clear, descriptive name
- **Amount**: Dollar amount of the benefit (USD only)
- **Category**: Benefit category (Dining, Travel, Transportation, etc.)
- **Frequency**: How often the benefit renews (Monthly, Quarterly, Annual)
- **Description**: Optional brief description
- **Terms**: Optional key terms and conditions

### 4. Data Quality Standards

#### Accuracy Requirements
- **Official Sources Only**: All information must come from official bank websites, terms and conditions, or verified public sources
- **Current Information**: Benefits must be current as of the contribution date
- **US Market Focus**: Currently focusing on cards available in the US market

#### Formatting Standards
- **Consistent Naming**: Use official card names as they appear on bank websites
- **Standardized Categories**: Use existing categories when possible
- **Clear Descriptions**: Write clear, concise benefit descriptions
- **Proper JSON**: Ensure all JSON is properly formatted and validates against the schema

### 5. Validation Process

#### Before Submitting
1. **Schema Validation**: Ensure your JSON validates against `schema.json`
2. **Duplicate Check**: Verify the card doesn't already exist in the database
3. **Accuracy Review**: Double-check all benefit amounts and terms
4. **Format Check**: Ensure consistent formatting with existing entries

#### Review Process
1. **Community Review**: Other contributors will review your submission
2. **Source Verification**: Links to official sources may be requested
3. **Testing**: Changes will be tested in the app environment
4. **Approval**: Approved changes will be merged into the main database

### 6. Example Card Entry

```json
{
  "id": "chase-sapphire-preferred",
  "cardType": "Chase Sapphire Preferred",
  "issuer": "Chase",
  "network": "Visa",
  "variant": "Personal",
  "category": "Travel Rewards",
  "annualFee": 95,
  "credits": [
    {
      "id": "csp-travel-credit",
      "name": "Annual Travel Credit",
      "amount": 50.0,
      "currency": "USD",
      "category": "Travel",
      "frequency": "Annual",
      "description": "Annual travel credit for eligible purchases",
      "terms": "Credit applied to eligible travel purchases annually"
    }
  ]
}
```

### 7. Card Categories

Use these standardized categories:

#### Card Types
- **Cash Back**: Cards focused on cash back rewards
- **Travel Rewards**: Cards with travel-focused benefits
- **Premium Travel**: High-end travel cards with extensive benefits
- **Business Rewards**: Cards designed for business use
- **No Annual Fee**: Cards with no annual fee
- **Other**: Cards that don't fit other categories

#### Credit Categories
- **Dining**: Restaurant and food delivery credits
- **Travel**: Airlines, hotels, and travel-related credits
- **Transportation**: Uber, Lyft, and other transport credits
- **Entertainment**: Streaming, media, and entertainment credits
- **Shopping**: Retail and shopping credits
- **Wellness**: Health and wellness related credits
- **Other**: Miscellaneous credits

### 8. Reporting Issues

#### Found Incorrect Information?
- **Create an Issue**: Open a GitHub issue describing the problem
- **Include Sources**: Provide links to correct information
- **Be Specific**: Clearly identify which card and benefit needs updating

#### Suggesting Improvements
- **Feature Requests**: Suggest new fields or categories
- **Process Improvements**: Recommend better contribution workflows
- **Tool Suggestions**: Propose tools for validation or automation

### 9. Recognition

#### Contributors
- All contributors will be recognized in the repository
- Significant contributors may be listed as database maintainers
- Community recognition for high-quality contributions

#### Credit
- This database is maintained by the MyCardBook community
- Individual contributions are tracked through Git history
- Contributors retain no ownership over submitted information

### 10. Legal and Privacy

#### Information Usage
- All submitted information becomes part of the open source database
- Information must be publicly available and not proprietary
- No personal account information should ever be included

#### Liability
- Contributors are responsible for accuracy of submitted information
- The MyCardBook project is not responsible for financial decisions based on this database
- Users should always verify benefit information with their card issuer

## Getting Started

Ready to contribute? Here's how to get started:

1. **Read the Documentation**: Review the schema and existing cards
2. **Set Up Your Environment**: Fork the repository and clone locally
3. **Start Small**: Begin with a card you're familiar with
4. **Join the Community**: Participate in discussions and reviews
5. **Stay Updated**: Follow repository updates and community guidelines

## Questions?

- **Documentation Issues**: Open an issue for unclear documentation
- **Technical Questions**: Ask in the repository discussions
- **General Questions**: Contact the maintainers through GitHub

Thank you for helping make MyCardBook the most accurate and comprehensive card database available!