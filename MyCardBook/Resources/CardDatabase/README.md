# MyCardBook Card Database

This directory contains the community-driven card benefit database for MyCardBook. The database is structured as JSON files that define credit cards and their associated benefits.

## Database Structure

### cards.json
The main database file containing all supported credit cards and their benefits.

**Structure:**
```json
{
  "version": "1.2.0",
  "lastUpdated": "2025-08-01",
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

Currently supported cards (as of v1.2.0):

### American Express (6 cards)
- **Personal Gold Card** (5 credits) - Dining, Uber, Resy, Dunkin', Hotel Collection
- **Personal Platinum Card** (9 credits) - Airline, Hotel, Uber, CLEAR, Saks, Entertainment, Equinox, Walmart+, TSA PreCheck
- **Business Gold Card** (3 credits) - Flexible Business, Walmart+, Hotel Collection
- **Business Platinum Card** (8 credits) - Airline, Dell, Indeed, CLEAR, Hilton, Wireless, TSA PreCheck
- **Blue Cash Everyday** (1 credit) - Disney Streaming
- **Blue Cash Preferred** (1 credit) - Disney Streaming

### Chase (9 cards)
- **Sapphire Preferred** (2 credits) - Hotel Credit, DashPass
- **Sapphire Reserve** (9 credits) - Edit Hotels, Travel Credit, Apple Services, StubHub, DoorDash, DashPass, Lyft, Peloton, Global Entry
- **Sapphire Reserve for Business** (8 credits) - Edit Hotels, Travel Credit, ZipRecruiter, Google Workspace, DoorDash, DashPass, Lyft, Gift Cards
- **United Explorer** (6 credits) - Instacart, United Hotels, Rideshare, JSX, Avis/Budget, Global Entry
- **United Quest** (4 credits) - Travel Credit, Instacart, Rideshare, Global Entry
- **United Gateway** (1 credit) - DashPass
- **United Club** (3 credits) - Renowned Hotels, Instacart, Rideshare
- **United Business** (2 credits) - Travel Credit, DashPass
- **United Club Business** (2 credits) - Renowned Hotels, FareLock

### Capital One (2 cards)
- **Venture X Personal** (5 credits) - Travel Credit, Anniversary Bonus, TSA PreCheck, Premier Hotels, Lifestyle Hotels
- **Venture X Business** (5 credits) - Travel Credit, Anniversary Bonus, TSA PreCheck, Premier Hotels, Lifestyle Hotels

### Citi (1 card)
- **Strata Elite** (4 credits) - Hotel Benefit, Splurge Credit, Blacklane, Global Entry

**Total: 22 cards with 80+ credit benefits**

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
- **Wellness** - Health and wellness related credits
- **Business** - Business-specific credits and services
- **Technology** - Technology and software credits
- **Other** - Miscellaneous credits

## Credit Frequencies

- **Monthly** - Renews every month
- **Quarterly** - Renews every 3 months
- **Semi-Annual** - Renews every 6 months
- **Annual** - Renews once per year
- **Every 4 Years** - Renews every 4 years (TSA PreCheck/Global Entry)
- **Per Stay** - Applied per hotel stay

## Data Privacy

This database contains only publicly available information about credit card benefits. No personal user data is included in this database.