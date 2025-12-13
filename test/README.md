# Apothy App - Test Suite

This directory contains the test suite for the Apothy Flutter application.

## Test Structure

```
test/
├── unit/
│   └── repositories/
│       └── auth_repository_test.dart    # AuthRepository unit tests
└── widget_test.dart                      # Basic widget test
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/repositories/auth_repository_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Install lcov if not already installed (macOS)
brew install lcov

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report in browser
open coverage/html/index.html
```

## Test Coverage

### AuthRepository Tests

**Current Coverage**: 8 test groups, 27 test cases

#### signInWithEmail (5 tests)
- ✓ Successful sign in returns AuthState
- ✓ Empty email returns ValidationFailure
- ✓ Empty password returns ValidationFailure
- ✓ Invalid credentials return AuthFailure
- ✓ Network errors return AuthFailure

#### signUpWithEmail (6 tests)
- ✓ Successful sign up returns AuthState
- ✓ Invalid email format returns ValidationFailure
- ✓ Weak password (< 8 chars) returns ValidationFailure
- ✓ Password without number returns ValidationFailure
- ✓ Password without special character returns ValidationFailure
- ✓ Account already exists returns AuthFailure

#### sendPasswordResetCode (3 tests)
- ✓ Successful code send returns Unit
- ✓ Invalid email returns ValidationFailure
- ✓ Network error returns AuthFailure

#### verifyPasswordResetCode (4 tests)
- ✓ Valid 6-digit code returns Unit
- ✓ Code with wrong length returns ValidationFailure
- ✓ Code with non-digits returns ValidationFailure
- ✓ Invalid code returns AuthFailure

#### resetPassword (2 tests)
- ✓ Valid password reset returns Unit
- ✓ Weak password returns ValidationFailure

#### getCurrentUser (3 tests)
- ✓ No stored user returns null
- ✓ Valid user and tokens return AuthState
- ✓ Empty tokens return null

#### signOut (2 tests)
- ✓ Successful sign out clears local data
- ✓ Sign out clears local data even if remote call fails

## Writing New Tests

### Using Mocktail

This project uses [mocktail](https://pub.dev/packages/mocktail) for mocking dependencies.

**Example Mock Setup:**
```dart
import 'package:mocktail/mocktail.dart';

// Create mock class
class MockAuthLocalDatasource extends Mock implements AuthLocalDatasource {}

void main() {
  late MockAuthLocalDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockAuthLocalDatasource();
  });

  test('example test', () {
    // Arrange
    when(() => mockDatasource.getUser())
        .thenAnswer((_) async => testUser);

    // Act
    final result = await someFunction();

    // Assert
    verify(() => mockDatasource.getUser()).called(1);
  });
}
```

### Test Naming Convention

Follow the **Given-When-Then** pattern in test descriptions:

```dart
test('should return X when Y happens', () async {
  // Arrange (Given)
  // Set up mocks and test data

  // Act (When)
  // Execute the function being tested

  // Assert (Then)
  // Verify the expected outcome
});
```

## Dependencies

Testing dependencies are defined in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.4  # Mocking library
```

## Best Practices

1. **Test Isolation**: Each test should be independent and not rely on other tests
2. **Mock External Dependencies**: Use mocktail to mock datasources, APIs, etc.
3. **Test Both Success and Failure Cases**: Cover happy path and error scenarios
4. **Use Descriptive Names**: Test names should clearly describe what is being tested
5. **Keep Tests Simple**: One concept per test
6. **Verify Side Effects**: Use `verify()` to ensure expected calls were made

## CI/CD Integration

Tests should be run automatically on:
- Every pull request
- Before merging to main branch
- Before production deployment

**Example GitHub Actions workflow:**
```yaml
- name: Run tests
  run: flutter test --coverage

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: coverage/lcov.info
```

## Next Steps

Additional test suites to implement:

1. **Repository Tests**:
   - [ ] EmotionChallengeRepository
   - [ ] DashboardRepository
   - [ ] ChatRepository
   - [ ] SubscriptionRepository

2. **Provider Tests**:
   - [ ] AuthProvider
   - [ ] ChatProvider
   - [ ] DashboardProvider
   - [ ] EmotionChallengeProvider

3. **Widget Tests**:
   - [ ] Login screen
   - [ ] Signup screen
   - [ ] Forgot password flow
   - [ ] Emotion compass
   - [ ] Chat interface

4. **Integration Tests**:
   - [ ] Complete auth flow
   - [ ] Emotion challenge journey
   - [ ] Chat conversation flow

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
