# MetaMove Aptos Tokens

A Move smart contract project for managing tokens on the Aptos blockchain, part of the MetaMove ecosystem.

## Overview

This project contains Move smart contracts for token management on the Aptos blockchain. It's designed to integrate with the MetaMove platform, which provides AI-powered fitness coaching and movement analysis.

## Project Structure

```
aptostokens2/
├── sources/      # Move smart contract source files
│   └── tokenget.move  # Main token contract implementation
├── build/        # Compiled artifacts
├── scripts/      # Deployment and interaction scripts
├── tests/        # Test files
└── Move.toml     # Project configuration file
```

## Prerequisites

- [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli)
- [Move Language](https://move-language.github.io/move/)
- Node.js and npm (for running scripts)

## Getting Started

1. Clone the repository:
```bash
git clone <repository-url>
cd aptostokens2
```

2. Install dependencies:
```bash
aptos move compile
```

3. Run tests:
```bash
aptos move test
```

## Smart Contract Details

The main contract `tokenget.move` provides token management functionality on the Aptos blockchain. The contract is deployed at:
```
launchpad_addr = "e2a0c91e582c6c62ae09fac1eb98c2a47dcca0df997007eb7d84f66b69d94ada"
```

## Development

### Building the Contract

```bash
aptos move compile
```

### Testing

Run the test suite:
```bash
aptos move test
```

### Deployment

To deploy to Aptos mainnet:
```bash
aptos move publish
```

## Security Considerations

⚠️ Important Security Notes:
- Never commit private keys or sensitive credentials
- Always review contract code before deployment
- Follow Aptos security best practices
- Test thoroughly on testnet before mainnet deployment

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

[Add your license here]

## Support

For support, please open an issue in the repository or contact the development team.

## Related Projects

- [MetaMove Frontend](https://github.com/yourusername/metamove-frontend)
- [MetaMove AI Agent](https://github.com/yourusername/metamove-agent) 