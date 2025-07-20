# MyCardBook Card Database

This directory contains the community-driven card benefit database for MyCardBook. The database is structured as JSON files that define credit cards and their associated benefits.

## Database Structure

### cards.json
The main database file containing all supported credit cards and their benefits.

**Structure:**
```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-19",
  "cards": [
    {
      "id": "unique-card-identifier",
      "cardType": "Full Card Name",
      "issuer": "Card Issuer",
      "network": "Payment Network",
      "variant": "Personal|Business",
      "category": "Card Category",
      "annualFee": 0,
      "credits": [
        {
          "id": "unique-credit-identifier",
          "name": "Credit Name",
          "amount": 0.0,
          "currency": "USD",
          "category": "Credit Category",
          "frequency": "Monthly|Quarterly|Annual",
          "description": "Optional description",
          "terms": "Optional terms and conditions"
        }
      ]
    }
  ]
}
```

## Supported Cards

Currently supported cards (as of v1.0.0):

- **American Express Personal Gold Card** - 2 credits (Dining, Uber)
- **American Express Business Gold Card** - 2 credits (Dining, Wireless)  
- **Chase Sapphire Preferred** - 1 credit (Travel)
- **Chase Sapphire Reserve** - 2 credits (Travel, DashPass)
- **Citi Double Cash** - 0 credits
- **Capital One Venture X** - 0 credits

## Community Contributions

This database is designed to be community-driven and open source. Future versions will include:

1. **GitHub Repository Structure** - Card database hosted separately on GitHub
2. **Validation Scripts** - Automated validation for card definitions
3. **Contribution Guidelines** - Process for community submissions
4. **Review Process** - Community review and approval workflow
5. **Version Control** - Proper versioning and change tracking

## Card Categories

- **Dining** - Restaurant and food delivery credits
- **Travel** - Airlines, hotels, and travel-related credits
- **Transportation** - Uber, Lyft, and other transport credits
- **Entertainment** - Streaming, media, and entertainment credits
- **Shopping** - Retail and shopping credits
- **Other** - Miscellaneous credits (wireless, etc.)

## Credit Frequencies

- **Monthly** - Renews every month
- **Quarterly** - Renews every 3 months
- **Annual** - Renews once per year

## Data Privacy

This database contains only publicly available information about credit card benefits. No personal user data is included in this database.