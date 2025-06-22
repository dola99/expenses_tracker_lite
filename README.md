# Expense Tracker

A comprehensive Flutter expense tracking application with real-time currency conversion, export capabilities, and beautiful visualizations.

## 🌟 Features

- **Expense & Income Tracking**: Add, edit, and delete transactions with categories
- **Real-time Currency Conversion**: Support for 10+ currencies with live exchange rates
- **Data Visualization**: Beautiful charts and statistics using FL Chart
- **Export Functionality**: Export data to CSV, PDF, and JSON formats
- **Offline Support**: Works offline with cached data and currency rates
- **Responsive Design**: Beautiful Material Design UI that works on all screen sizes
- **Data Import**: Import transactions from CSV files
- **Filtering & Pagination**: Advanced filtering by category and date with efficient pagination

## 📱 Screenshots

| Dashboard | Expenses List | Add Expense | Statistics | Export Options |
|-----------|---------------|-------------|------------|----------------|
| ![Dashboard](screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-06-22%20at%2003.04.32.png) | ![Expenses List](screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-06-22%20at%2003.04.38.png) | ![Add Expense](screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-06-22%20at%2003.04.47.png) | ![Statistics](screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-06-22%20at%2003.05.00.png) | ![Export Options](screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-06-22%20at%2003.05.04.png) |

## 🏗️ Architecture & Structure

The application follows **Clean Architecture** principles with a feature-based folder structure:

```text
lib/
├── core/                    # Shared utilities and services
│   ├── constants/          # App-wide constants
│   ├── events/            # Event bus for cross-feature communication
│   ├── network/           # Network service with Dio
│   ├── services/          # Shared services (export, import)
│   ├── storage/           # Hive database service
│   ├── theme/             # App theming
│   ├── utils/             # Utility functions
│   └── widgets/           # Reusable UI components
│
├── features/               # Feature modules
│   ├── currency/          # Currency conversion feature
│   │   ├── data/         # Data layer (API, caching)
│   │   ├── domain/       # Business logic and models
│   │   └── presentation/ # UI and BLoC
│   ├── dashboard/         # Main dashboard feature
│   ├── expenses/          # Expense management feature
│   ├── income/            # Income management feature
│   ├── export/            # Data export feature
│   └── import/            # Data import feature
│
└── main.dart              # App entry point
```

### Key Architectural Decisions

1. **Feature-based Structure**: Each feature is self-contained with its own data, domain, and presentation layers
2. **Separation of Concerns**: Clear separation between UI, business logic, and data layers
3. **Dependency Injection**: Services are injected into BLoCs for better testability
4. **Event-Driven Communication**: Features communicate through an event bus to maintain loose coupling

## 🎯 State Management Approach

The application uses **BLoC (Business Logic Component)** pattern with `flutter_bloc`:

### BLoC Implementation

- **ExpenseBloc**: Manages expense CRUD operations, filtering, and pagination
- **IncomeBloc**: Handles income tracking and management
- **DashboardBloc**: Aggregates data for dashboard statistics and charts
- **CurrencyBloc**: Manages currency rates and conversions

### State Management Benefits

- **Predictable State**: All state changes are explicit and traceable
- **Testability**: Business logic is separated from UI and easily testable
- **Reactive UI**: UI automatically updates when state changes
- **Event-Driven**: Clear separation between events and state changes

```dart
// Example BLoC usage
BlocProvider(
  create: (context) => ExpenseBloc()..add(LoadExpenses()),
  child: BlocBuilder<ExpenseBloc, ExpenseState>(
    builder: (context, state) {
      // UI renders based on state
    },
  ),
)
```

## 🌐 API Integration

### Currency Exchange API

- **API**: [Exchange Rates API (open.er-api.com)](https://open.er-api.com)
- **Base URL**: `https://open.er-api.com/v6/latest`
- **Base Currency**: USD

### Implementation Strategy

1. **Network Service**: Centralized HTTP client using Dio
2. **Error Handling**: Comprehensive error handling with network state awareness
3. **Offline Support**: Falls back to cached rates when offline
4. **Rate Limiting**: Respects API limits with intelligent caching

```dart
// Currency conversion example
final amountInUSD = await currencyService.convertToUSD(
  100.0, // amount
  'EUR', // from currency
);
```

### Network Features

- **Connectivity Checking**: Monitors internet connection status
- **Request/Response Logging**: Debug-friendly API logging
- **Timeout Handling**: Configurable timeouts (30s connect, 30s receive)
- **Retry Logic**: Automatic retry with exponential backoff

## 📄 Pagination Strategy

### Local Pagination Approach

The app implements **client-side pagination** for optimal performance:

#### Why Local Pagination?

1. **Data Size**: Expense data is typically manageable in size
2. **Offline Support**: All data is cached locally using Hive
3. **Filtering Performance**: Local filtering is faster than API calls
4. **User Experience**: Instant response without network delays

#### Implementation Details

```dart
static const int itemsPerPage = 10; // Configurable page size

// Pagination logic in ExpenseBloc
final paginatedExpenses = _paginateExpenses(
  filteredExpenses,
  page: event.page,
);

List<ExpenseModel> _paginateExpenses(
  List<ExpenseModel> expenses, 
  {required int page}
) {
  final startIndex = (page - 1) * _itemsPerPage;
  final endIndex = startIndex + _itemsPerPage;
  
  if (startIndex >= expenses.length) return [];
  
  return expenses.sublist(
    startIndex,
    endIndex > expenses.length ? expenses.length : endIndex,
  );
}
```

#### Pagination Features

- **Load More**: Infinite scroll with "Load More" functionality
- **Efficient Memory Usage**: Only renders visible items
- **Filter-Aware**: Pagination respects active filters
- **State Preservation**: Maintains scroll position across state changes

## 💾 Data Storage

### Hive Database

- **Local Storage**: Uses Hive for fast, lightweight local database
- **Type Safety**: Custom adapters for type-safe serialization
- **Offline-First**: All data is stored locally first
- **Multiple Boxes**: Separate storage boxes for different data types

```dart
// Storage boxes
- expenses: ExpenseModel objects
- incomes: Income transaction objects  
- user_preferences: App settings and preferences
- currency_rates: Cached exchange rates
```

## 🎨 UI Design & Components

### Design System

- **Material Design 3**: Modern Material Design components
- **Google Fonts**: Custom typography with Google Fonts
- **Consistent Theming**: Centralized theme configuration
- **Responsive Layout**: Adapts to different screen sizes

### Key UI Components

- **Custom Charts**: Beautiful data visualization with FL Chart
- **Animated Transitions**: Smooth navigation and state transitions
- **Form Validation**: Comprehensive input validation
- **Loading States**: Skeleton loading and progress indicators

## 🔄 Trade-offs & Assumptions

### Architecture Trade-offs

1. **Local vs API Pagination**
   - **Chosen**: Local pagination
   - **Trade-off**: More memory usage vs better offline experience
   - **Rationale**: Expense data is typically small, offline-first approach

2. **State Management**
   - **Chosen**: BLoC pattern
   - **Trade-off**: More boilerplate vs better testability and scalability
   - **Rationale**: Enterprise-grade solution with excellent testing support

3. **Database Choice**
   - **Chosen**: Hive (local)
   - **Trade-off**: No cloud sync vs simplicity and offline support
   - **Rationale**: Personal finance apps need offline reliability

### Assumptions

1. **Currency API**: Assumes Exchange Rates API remains free and available
2. **Data Volume**: Assumes typical personal expense data (< 10k transactions)
3. **Platform**: Optimized for mobile, basic desktop support
4. **Internet**: Designed to work offline but requires initial internet for currency rates

### Future Improvements

- **Cloud Sync**: Add cloud backup/sync functionality
- **API Pagination**: Implement server-side pagination for large datasets
- **Advanced Analytics**: More sophisticated reporting and insights
- **Multi-user Support**: Family/shared expense tracking

## 🚀 How to Run the Project

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (included with Flutter)
- iOS Simulator / Android Emulator / Physical Device

### Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone <repository-url>
   cd expense_tracker
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate Code (if needed)**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the Application**

   ```bash
   # For iOS Simulator
   flutter run -d ios
   
   # For Android Emulator
   flutter run -d android
   
   # For all available devices
   flutter devices
   flutter run -d <device-id>
   ```

### Development Setup

1. **Enable Developer Mode**

   ```bash
   flutter run --debug
   ```

2. **Hot Reload**
   - Press `r` in terminal for hot reload
   - Press `R` for hot restart

3. **Run Tests**

   ```bash
   flutter test
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# iOS (requires Xcode and Apple Developer Account)
flutter build ios --release

# Web
flutter build web --release
```

### Environment Configuration

The app uses default configurations, but you can customize:

- **API Endpoints**: Update `lib/core/constants/app_constants.dart`
- **Pagination Size**: Modify `itemsPerPage` constant
- **Supported Currencies**: Update `supportedCurrencies` list

## 📊 Performance Considerations

- **Lazy Loading**: Expenses are loaded on-demand with pagination
- **Image Optimization**: Optimized image assets
- **Memory Management**: Efficient state management with BLoC
- **Caching Strategy**: Smart caching for currency rates and user data

## 🧪 Testing

The app includes comprehensive testing:

- **Unit Tests**: Business logic and utility functions
- **Widget Tests**: UI component testing
- **BLoC Tests**: State management testing using `bloc_test`
- **Mock Services**: API and storage mocking with `mocktail`

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

---

## Made with ❤️ using Flutter

*For questions or support, please refer to the documentation or create an issue.*
