# AgriTraceSystem

AgriTraceSystem is a blockchain-based traceability solution built on the Stacks blockchain that enables transparent verification and certification of agricultural products from farm to table.

## Features

- **Crop Registration**: Farmers can register their crops with detailed information
- **Transparent Traceability**: Complete visibility of cultivation methods and harvest details
- **Third-party Certification**: Independent certifiers can verify agricultural practices
- **Immutable Records**: Blockchain-based records ensure data integrity

## Smart Contract Functions

### Administration
- `add-certifier`: Register authorized certifiers who can verify crop information

### Farmer Functions
- `register-crop`: Add a new crop with cultivation details and harvest information
- `get-farmer-crops`: View all crops registered by a specific farmer

### Certification
- `certify-crop`: Authorized certifiers can validate crop information
- `is-certifier`: Check if an address is an authorized certifier

### Data Retrieval
- `get-crop`: View complete details about a specific crop

## Getting Started

1. Clone this repository
2. Install [Clarinet](https://github.com/hirosystems/clarinet) for local development
3. Run `clarinet check` to verify the contract
4. Deploy using Clarinet or the Stacks CLI

## For Farmers

Farmers can register their crops by providing:
- Crop name
- Cultivation methods used
- Harvest date
- Farm location

## For Certifiers

Authorized certifiers can review and certify crops, providing consumers with confidence in the agricultural practices used.