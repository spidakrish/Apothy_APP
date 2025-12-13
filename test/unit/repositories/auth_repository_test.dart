import 'package:apothy/core/error/failures.dart';
import 'package:apothy/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:apothy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:apothy/features/auth/data/models/auth_tokens_model.dart';
import 'package:apothy/features/auth/data/models/user_model.dart';
import 'package:apothy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:apothy/features/auth/domain/entities/user.dart';
import 'package:apothy/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockAuthLocalDatasource extends Mock implements AuthLocalDatasource {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late AuthRepository repository;
  late MockAuthLocalDatasource mockLocalDatasource;
  late MockAuthRemoteDatasource mockRemoteDatasource;

  // Test data
  final testEmail = 'test@apothy.ai';
  final testPassword = 'Test123!@#';
  final testDisplayName = 'Test User';

  final testUserModel = UserModel(
    id: 'test_user_id',
    email: testEmail,
    displayName: testDisplayName,
    provider: AuthProvider.email,
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime(2024, 1, 1),
  );

  final testTokensModel = AuthTokensModel(
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  final testAuthResult = AuthResult(
    user: testUserModel,
    tokens: testTokensModel,
  );

  setUp(() {
    mockLocalDatasource = MockAuthLocalDatasource();
    mockRemoteDatasource = MockAuthRemoteDatasource();

    repository = AuthRepositoryImpl(
      localDatasource: mockLocalDatasource,
      remoteDatasource: mockRemoteDatasource,
      useMock: true, // Use mock mode to avoid platform SDK calls
    );

    // Register fallback values for mocktail
    registerFallbackValue(testUserModel);
    registerFallbackValue(testTokensModel);
  });

  group('AuthRepository - signInWithEmail', () {
    test('should return AuthState when sign in is successful', () async {
      // Arrange
      when(() => mockRemoteDatasource.signInWithEmail(
            email: testEmail,
            password: testPassword,
          )).thenAnswer((_) async => testAuthResult);

      when(() => mockLocalDatasource.saveUser(any()))
          .thenAnswer((_) async => Future.value());

      when(() => mockLocalDatasource.saveTokens(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.signInWithEmail(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return AuthState, got failure: $failure'),
        (authState) {
          expect(authState.user.email, testEmail);
          expect(authState.user.displayName, testDisplayName);
          expect(authState.tokens.accessToken, 'test_access_token');
        },
      );

      // Verify interactions
      verify(() => mockRemoteDatasource.signInWithEmail(
            email: testEmail,
            password: testPassword,
          )).called(1);
      verify(() => mockLocalDatasource.saveUser(any())).called(1);
      verify(() => mockLocalDatasource.saveTokens(any())).called(1);
    });

    test('should return ValidationFailure when email is empty', () async {
      // Act
      final result = await repository.signInWithEmail(
        email: '',
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('Email'));
        },
        (authState) => fail('Should return failure, got AuthState'),
      );

      // Verify remote datasource was NOT called
      verifyNever(() => mockRemoteDatasource.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('should return ValidationFailure when password is empty', () async {
      // Act
      final result = await repository.signInWithEmail(
        email: testEmail,
        password: '',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('Password'));
        },
        (authState) => fail('Should return failure, got AuthState'),
      );

      // Verify remote datasource was NOT called
      verifyNever(() => mockRemoteDatasource.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      when(() => mockRemoteDatasource.signInWithEmail(
            email: testEmail,
            password: testPassword,
          )).thenThrow(const AuthException(
        'Invalid credentials',
        code: 'unauthorized',
      ));

      // Act
      final result = await repository.signInWithEmail(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect((failure as AuthFailure).code, 'unauthorized');
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });

    test('should return AuthFailure when remote datasource throws unknown error',
        () async {
      // Arrange
      when(() => mockRemoteDatasource.signInWithEmail(
            email: testEmail,
            password: testPassword,
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await repository.signInWithEmail(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });
  });

  group('AuthRepository - signUpWithEmail', () {
    test('should return AuthState when sign up is successful', () async {
      // Arrange
      when(() => mockRemoteDatasource.signUpWithEmail(
            email: testEmail,
            password: testPassword,
            displayName: testDisplayName,
          )).thenAnswer((_) async => testAuthResult);

      when(() => mockLocalDatasource.saveUser(any()))
          .thenAnswer((_) async => Future.value());

      when(() => mockLocalDatasource.saveTokens(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.signUpWithEmail(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return AuthState, got failure: $failure'),
        (authState) {
          expect(authState.user.email, testEmail);
          expect(authState.user.displayName, testDisplayName);
        },
      );

      verify(() => mockRemoteDatasource.signUpWithEmail(
            email: testEmail,
            password: testPassword,
            displayName: testDisplayName,
          )).called(1);
    });

    test('should return ValidationFailure when email is invalid', () async {
      // Act
      final result = await repository.signUpWithEmail(
        email: 'invalid-email',
        password: testPassword,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('email'));
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });

    test('should return ValidationFailure when password is weak', () async {
      // Act - password with less than 8 characters
      final result = await repository.signUpWithEmail(
        email: testEmail,
        password: 'weak',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('password'));
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });

    test('should return ValidationFailure when password has no number',
        () async {
      // Act - password without number
      final result = await repository.signUpWithEmail(
        email: testEmail,
        password: 'Password!@#',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });

    test('should return ValidationFailure when password has no special character',
        () async {
      // Act - password without special character
      final result = await repository.signUpWithEmail(
        email: testEmail,
        password: 'Password123',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });

    test('should return AuthFailure when account already exists', () async {
      // Arrange
      when(() => mockRemoteDatasource.signUpWithEmail(
            email: testEmail,
            password: testPassword,
            displayName: testDisplayName,
          )).thenThrow(const AuthException(
        'Account already exists',
        code: 'conflict',
      ));

      // Act
      final result = await repository.signUpWithEmail(
        email: testEmail,
        password: testPassword,
        displayName: testDisplayName,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect((failure as AuthFailure).code, 'conflict');
        },
        (authState) => fail('Should return failure, got AuthState'),
      );
    });
  });

  group('AuthRepository - sendPasswordResetCode', () {
    test('should return Unit when reset code is sent successfully', () async {
      // Arrange
      when(() => mockRemoteDatasource.sendPasswordResetCode(testEmail))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.sendPasswordResetCode(email: testEmail);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Unit, got failure: $failure'),
        (unit) => expect(unit, equals(unit)),
      );

      verify(() => mockRemoteDatasource.sendPasswordResetCode(testEmail))
          .called(1);
    });

    test('should return ValidationFailure when email is invalid', () async {
      // Act
      final result = await repository.sendPasswordResetCode(
        email: 'invalid-email',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (unit) => fail('Should return failure, got Unit'),
      );

      verifyNever(() => mockRemoteDatasource.sendPasswordResetCode(any()));
    });

    test('should return AuthFailure when remote datasource fails', () async {
      // Arrange
      when(() => mockRemoteDatasource.sendPasswordResetCode(testEmail))
          .thenThrow(const AuthException(
        'Failed to send code',
        code: 'network_error',
      ));

      // Act
      final result = await repository.sendPasswordResetCode(email: testEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
        },
        (unit) => fail('Should return failure, got Unit'),
      );
    });
  });

  group('AuthRepository - verifyPasswordResetCode', () {
    const testCode = '123456';

    test('should return Unit when code is verified successfully', () async {
      // Arrange
      when(() => mockRemoteDatasource.verifyPasswordResetCode(
            email: testEmail,
            code: testCode,
          )).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.verifyPasswordResetCode(
        email: testEmail,
        code: testCode,
      );

      // Assert
      expect(result.isRight(), true);

      verify(() => mockRemoteDatasource.verifyPasswordResetCode(
            email: testEmail,
            code: testCode,
          )).called(1);
    });

    test('should return ValidationFailure when code is not 6 digits', () async {
      // Act
      final result = await repository.verifyPasswordResetCode(
        email: testEmail,
        code: '12345', // Only 5 digits
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).message, contains('6 digits'));
        },
        (unit) => fail('Should return failure, got Unit'),
      );

      verifyNever(() => mockRemoteDatasource.verifyPasswordResetCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ));
    });

    test('should return ValidationFailure when code contains non-digits',
        () async {
      // Act
      final result = await repository.verifyPasswordResetCode(
        email: testEmail,
        code: '12a456', // Contains letter
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (unit) => fail('Should return failure, got Unit'),
      );
    });

    test('should return AuthFailure when code is invalid', () async {
      // Arrange
      when(() => mockRemoteDatasource.verifyPasswordResetCode(
            email: testEmail,
            code: testCode,
          )).thenThrow(const AuthException(
        'Invalid code',
        code: 'invalid_code',
      ));

      // Act
      final result = await repository.verifyPasswordResetCode(
        email: testEmail,
        code: testCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
        },
        (unit) => fail('Should return failure, got Unit'),
      );
    });
  });

  group('AuthRepository - resetPassword', () {
    const testCode = '123456';
    const newPassword = 'NewPass123!@#';

    test('should return Unit when password is reset successfully', () async {
      // Arrange
      when(() => mockRemoteDatasource.resetPassword(
            email: testEmail,
            code: testCode,
            newPassword: newPassword,
          )).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.resetPassword(
        email: testEmail,
        code: testCode,
        newPassword: newPassword,
      );

      // Assert
      expect(result.isRight(), true);

      verify(() => mockRemoteDatasource.resetPassword(
            email: testEmail,
            code: testCode,
            newPassword: newPassword,
          )).called(1);
    });

    test('should return ValidationFailure when new password is weak', () async {
      // Act
      final result = await repository.resetPassword(
        email: testEmail,
        code: testCode,
        newPassword: 'weak',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
        },
        (unit) => fail('Should return failure, got Unit'),
      );

      verifyNever(() => mockRemoteDatasource.resetPassword(
            email: any(named: 'email'),
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          ));
    });
  });

  group('AuthRepository - getCurrentUser', () {
    test('should return null when no user is stored', () async {
      // Arrange
      when(() => mockLocalDatasource.getTokens())
          .thenAnswer((_) async => null);
      when(() => mockLocalDatasource.getUser()).thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return null, got failure: $failure'),
        (authState) => expect(authState, isNull),
      );
    });

    test('should return AuthState when valid user and tokens exist', () async {
      // Arrange
      when(() => mockLocalDatasource.getTokens())
          .thenAnswer((_) async => testTokensModel);
      when(() => mockLocalDatasource.getUser())
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return AuthState, got failure: $failure'),
        (authState) {
          expect(authState, isNotNull);
          expect(authState!.user.email, testEmail);
          expect(authState.tokens.accessToken, 'test_access_token');
        },
      );
    });

    test('should return null when tokens are empty', () async {
      // Arrange
      final emptyTokens = AuthTokensModel(
        accessToken: '',
        refreshToken: '',
        expiresAt: DateTime.now(),
      );

      when(() => mockLocalDatasource.getTokens())
          .thenAnswer((_) async => emptyTokens);
      when(() => mockLocalDatasource.getUser())
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return null, got failure: $failure'),
        (authState) => expect(authState, isNull),
      );
    });
  });

  group('AuthRepository - signOut', () {
    test('should clear local data and return Unit on successful sign out',
        () async {
      // Arrange
      when(() => mockLocalDatasource.getTokens())
          .thenAnswer((_) async => testTokensModel);

      when(() => mockRemoteDatasource.signOut(any()))
          .thenAnswer((_) async => Future.value());

      when(() => mockLocalDatasource.clearAll())
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result.isRight(), true);

      verify(() => mockLocalDatasource.getTokens()).called(1);
      verify(() => mockRemoteDatasource.signOut(testTokensModel.accessToken))
          .called(1);
      verify(() => mockLocalDatasource.clearAll()).called(1);
    });

    test('should still clear local data even if remote signOut fails',
        () async {
      // Arrange
      when(() => mockLocalDatasource.getTokens())
          .thenAnswer((_) async => testTokensModel);

      when(() => mockRemoteDatasource.signOut(any()))
          .thenThrow(Exception('Network error'));

      when(() => mockLocalDatasource.clearAll())
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.signOut();

      // Assert - Should still succeed because local data is cleared
      expect(result.isRight(), true);

      verify(() => mockLocalDatasource.clearAll()).called(1);
    });
  });
}
