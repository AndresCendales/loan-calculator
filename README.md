# Loan Calculator App

A comprehensive Flutter mobile application for loan amortization calculations with support for multiple loans, payment schedules, customizable insurance, and early repayments.

## Features

### Core Functionality
- **Multiple Loans**: Create and manage multiple loans simultaneously
- **French Amortization**: Uses the French amortization system (fixed monthly payments)
- **TEA to TEM Conversion**: Automatically converts annual effective rate (TEA) to monthly effective rate (TEM)
- **Payment Schedules**: Detailed monthly payment schedules showing principal, interest, insurance, and balances
- **Early Repayments**: Support for early payments with two strategies:
  - **Reduce Payment**: Maintain loan term, reduce monthly payment amount
  - **Reduce Term**: Maintain payment amount, finish loan earlier
- **Customizable Insurance**: Three insurance modes:
  - No insurance
  - Fixed monthly amount
  - Percentage of remaining balance
  - Per-installment overrides

### Data Management
- **Local Persistence**: Uses Hive for local data storage
- **CSV Export**: Export payment schedules to CSV files
- **Share Functionality**: Share exported files via system share dialog

### User Interface
- **Material Design 3**: Modern, responsive UI with light/dark theme support
- **Tabbed Interface**: Organized loan details with tabs for schedule, early payments, and insurance
- **Form Validation**: Comprehensive input validation with user-friendly error messages
- **Real-time Preview**: Live payment calculations as you enter loan parameters

## Technical Architecture

### Project Structure
```
lib/
├── app/                          # App bootstrap and configuration
│   ├── app.dart                 # Main app widget
│   ├── router/                  # Navigation routing
│   └── theme/                   # App theming
├── features/loans/              # Loan feature module
│   ├── data/                    # Data layer
│   │   ├── adapters/           # Hive type adapters
│   │   ├── datasources/        # Local data sources
│   │   └── repositories/       # Repository implementations
│   ├── domain/                  # Domain layer
│   │   ├── entities/           # Core business models
│   │   ├── repositories/       # Repository interfaces
│   │   └── services/           # Business logic services
│   ├── presentation/            # Presentation layer
│   │   ├── pages/              # UI pages
│   │   ├── widgets/            # Reusable UI components
│   │   └── providers/          # Riverpod state providers
│   └── utils/                   # Utility functions
test/                            # Test files
├── unit/                        # Unit tests
└── widget/                      # Widget tests
```

### Key Technologies
- **Flutter 3.x**: Cross-platform mobile framework
- **Dart 3.x**: Programming language
- **Riverpod**: State management
- **Go Router**: Navigation and routing
- **Freezed**: Immutable data classes with code generation
- **Hive**: Local NoSQL database
- **Decimal**: Precise decimal calculations
- **CSV**: Export functionality
- **Share Plus**: File sharing capabilities

### Architecture Patterns
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **Repository Pattern**: Abstraction over data sources
- **Provider Pattern**: State management with Riverpod
- **Immutable Data**: Using Freezed for immutable models

## Business Logic

### Loan Calculations

#### TEA to TEM Conversion
```dart
r_m = (1 + TEA)^(1/12) - 1
```
Where:
- `r_m` = Monthly effective rate (TEM)
- `TEA` = Annual effective rate

#### Fixed Payment Calculation (French Amortization)
```dart
// With interest
cuota = P * r / (1 - (1 + r)^(-n))

// Without interest (TEA = 0)
cuota = P / n
```
Where:
- `P` = Principal amount
- `r` = Monthly interest rate
- `n` = Number of payments

#### Insurance Calculation
- **Fixed**: Same amount each month
- **Percentage**: `insurance = balance * percentage`
- **Override**: Custom amount for specific installments

#### Early Repayment Processing
1. Apply payment to principal at target installment
2. Recalculate remaining schedule based on type:
   - **Reduce Payment**: Keep term, calculate new payment amount
   - **Reduce Term**: Keep payment, calculate new term length

### Data Models

#### Loan
```dart
class Loan {
  String id;
  String titulo;
  Decimal principal;          // Initial loan amount
  int plazoMeses;            // Term in months
  Decimal tea;               // Annual effective rate (0.12 = 12%)
  DateTime fechaInicio;      // Start date
  InsuranceConfig seguroConfig;
  List<EarlyRepayment> earlyRepayments;
}
```

#### Insurance Configuration
```dart
class InsuranceConfig {
  InsuranceMode mode;                    // none, flat, percentOfBalance
  Decimal? flatAmountPerMonth;           // For flat mode
  Decimal? monthlyPercentOfBalance;      // For percentage mode
  Map<int, Decimal> perInstallmentOverrides; // Custom overrides
}
```

#### Early Repayment
```dart
class EarlyRepayment {
  String id;
  DateTime fecha;            // Payment date
  Decimal monto;            // Payment amount
  EarlyType tipo;           // reducePayment or reduceTerm
}
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- iOS development setup (for iOS builds)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd loan-calculator
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code (Freezed, Hive adapters):
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
# Follow iOS signing and distribution guidelines
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/schedule_calculator_test.dart

# Run with coverage
flutter test --coverage
```

### Code Generation
When modifying Freezed models or Hive adapters:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Usage Examples

### Creating a Basic Loan
1. Tap the FAB on the loans list page
2. Fill in loan details:
   - Title: "Home Mortgage"
   - Principal: $200,000
   - Term: 30 years (360 months)
   - TEA: 4.5%
   - Start date: Today
3. Configure insurance if needed
4. Tap "Create"

### Adding Early Repayments
1. Open loan details
2. Go to "Early Payments" tab
3. Tap "Add Early Payment"
4. Enter payment details:
   - Date: When to apply payment
   - Amount: Extra payment amount
   - Type: Reduce payment or reduce term
5. View impact preview
6. Tap "Add"

### Customizing Insurance
1. Open loan details
2. Go to "Insurance" tab
3. Tap "Edit Overrides"
4. Modify specific installment amounts
5. Tap "Save Changes"

### Exporting Data
1. Open loan details
2. Go to "Payment Schedule" tab
3. Tap "Export CSV"
4. Share via email, cloud storage, etc.

## Validation Rules

### Loan Parameters
- Title: Required, non-empty
- Principal: > 0
- Term: ≥ 1 month
- TEA: 0% ≤ TEA ≤ 200%
- Start date: Valid date

### Early Repayments
- Amount: > 0 and ≤ remaining balance
- Date: ≥ loan start date
- Cannot exceed remaining principal

### Insurance
- Fixed amount: ≥ 0
- Percentage: ≥ 0%
- Overrides: ≥ 0 per installment

## Performance Considerations

- **Schedule Generation**: Optimized for loans up to 360 months
- **Memory Usage**: Efficient with Hive local storage
- **UI Responsiveness**: ListView.builder for large payment schedules
- **Calculations**: Uses Decimal library for precision

## Known Limitations

1. **Currency**: Currently supports USD format only
2. **Interest Compounding**: Monthly compounding only
3. **Payment Frequency**: Monthly payments only
4. **Rounding**: Final installment may have small adjustments for rounding
5. **Backup**: No cloud backup (local storage only)

## Troubleshooting

### Common Issues

**Build errors after cloning:**
- Run `flutter clean && flutter pub get`
- Regenerate code: `flutter packages pub run build_runner build --delete-conflicting-outputs`

**iOS build issues:**
- Ensure Xcode license is accepted: `sudo xcodebuild -license`
- Update iOS deployment target if needed

**Test failures:**
- Ensure all dependencies are installed
- Check for platform-specific test requirements

### Debug Mode
Enable debug logging by setting environment variables:
```bash
flutter run --debug
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the existing architecture
4. Add tests for new functionality
5. Update documentation
6. Submit a pull request

### Code Style
- Follow Dart/Flutter conventions
- Use `flutter analyze` to check for issues
- Format code with `dart format`
- Add documentation for public APIs

## License

See LICENSE file for details.

## Support

For issues and questions:
1. Check existing GitHub issues
2. Create a new issue with:
   - Flutter/Dart version
   - Device/platform information
   - Steps to reproduce
   - Expected vs actual behavior