# Hardhat Project Documentation

This directory contains a Hardhat project for Ethereum smart contract development, testing, and deployment. The project is set up with a basic time-locked contract that demonstrates key Solidity concepts and Hardhat features.

## Project Structure

```
hardhat/
├── contracts/          # Smart contract source files
│   └── Lock.sol       # Time-locked contract implementation
├── scripts/           # Deployment and interaction scripts
├── test/             # Test files for contracts
├── artifacts/        # Compiled contract artifacts
├── cache/           # Hardhat cache files
├── hardhat.config.js # Hardhat configuration
└── package.json     # Project dependencies and scripts
```

## Smart Contracts

### Lock.sol
A time-locked contract that implements a simple escrow mechanism:

- **Purpose**: Holds ETH until a specified unlock time
- **Key Features**:
  - Time-based locking mechanism
  - Owner-only withdrawal
  - Event emission for withdrawals
  - Payable constructor for initial deposit

#### Contract Functions

1. **Constructor**
   ```solidity
   constructor(uint _unlockTime) payable
   ```
   - Initializes the contract with a future unlock time
   - Accepts initial ETH deposit
   - Sets the contract owner
   - Requires unlock time to be in the future

2. **withdraw**
   ```solidity
   function withdraw() public
   ```
   - Allows the owner to withdraw locked ETH
   - Only executable after unlock time
   - Emits Withdrawal event
   - Transfers entire contract balance to owner

#### State Variables
- `unlockTime`: Timestamp when funds can be withdrawn
- `owner`: Address of the contract owner

#### Events
- `Withdrawal`: Emitted when funds are withdrawn
  - Parameters: amount, timestamp

## Configuration

### hardhat.config.js
Configures the Hardhat development environment:

- **Solidity Version**: 0.8.20
- **Networks**:
  - Hardhat Network (chainId: 31337)
  - Localhost Network (chainId: 1337)
    - URL: http://127.0.0.1:8545
    - Pre-configured test account

## Development Workflow

1. **Installation**
   ```bash
   npm install
   ```

2. **Compile Contracts**
   ```bash
   npx hardhat compile
   ```

3. **Run Tests**
   ```bash
   npx hardhat test
   ```

4. **Deploy to Local Network**
   ```bash
   npx hardhat node
   npx hardhat run scripts/deploy.js --network localhost
   ```

## Testing

The project includes a test suite for the Lock contract:

- Deployment tests
- Time-lock functionality tests
- Owner-only access tests
- Event emission tests

## Security Considerations

1. **Access Control**
   - Owner-only withdrawal
   - Time-based restrictions

2. **Input Validation**
   - Future unlock time requirement
   - Owner verification

3. **State Management**
   - Clear ownership model
   - Immutable unlock time

## Best Practices

1. **Code Organization**
   - Clear contract structure
   - Well-documented functions
   - Event emission for important actions

2. **Error Handling**
   - Descriptive error messages
   - Require statements for validations
   - Clear function requirements

3. **Testing**
   - Comprehensive test coverage
   - Edge case testing
   - Network-specific tests

## Deployment

### Local Development
1. Start local node:
   ```bash
   npx hardhat node
   ```

2. Deploy contract:
   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

### Production Deployment
1. Configure network in hardhat.config.js
2. Set up environment variables for private keys
3. Run deployment script with target network:
   ```bash
   npx hardhat run scripts/deploy.js --network <network-name>
   ```

## Maintenance

1. **Regular Updates**
   - Keep dependencies updated
   - Monitor Solidity version compatibility
   - Update Hardhat plugins

2. **Code Quality**
   - Run linters regularly
   - Maintain test coverage
   - Review security best practices

3. **Documentation**
   - Keep README updated
   - Document new features
   - Maintain deployment instructions

## Troubleshooting

1. **Compilation Issues**
   - Check Solidity version compatibility
   - Verify import paths
   - Check for syntax errors

2. **Deployment Problems**
   - Verify network configuration
   - Check account balances
   - Validate gas settings

3. **Test Failures**
   - Review test environment setup
   - Check for timing issues
   - Verify test account configuration 