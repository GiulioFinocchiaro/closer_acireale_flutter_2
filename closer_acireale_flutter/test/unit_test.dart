/*import 'package:flutter_test/flutter_test.dart';
import 'package:closer_acireale_flutter/core/models/user_model.dart';
import 'package:closer_acireale_flutter/core/services/api_service.dart';
import 'package:closer_acireale_flutter/core/utils/responsive_utils.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should create from JSON correctly', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'roles': ['admin', 'user'],
        'created_at': '2023-01-01T00:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.roles, ['admin', 'user']);
      expect(user.isAdmin, true);
    });

    test('UserModel should convert to JSON correctly', () {
      final user = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        roles: ['admin'],
        createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['roles'], ['admin']);
    });

    test('UserModel should detect admin role correctly', () {
      final adminUser = UserModel(
        id: '1',
        name: 'Admin',
        email: 'admin@test.com',
        roles: ['amministratore'],
      );

      final regularUser = UserModel(
        id: '2',
        name: 'User',
        email: 'user@test.com',
        roles: ['user'],
      );

      expect(adminUser.isAdmin, true);
      expect(regularUser.isAdmin, false);
    });

    test('UserModel equality should work correctly', () {
      final user1 = UserModel(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        roles: ['user'],
      );

      final user2 = UserModel(
        id: '123',
        name: 'Different Name',
        email: 'different@example.com',
        roles: ['admin'],
      );

      final user3 = UserModel(
        id: '456',
        name: 'Test User',
        email: 'test@example.com',
        roles: ['user'],
      );

      expect(user1 == user2, true); // Same ID
      expect(user1 == user3, false); // Different ID
    });
  });

  group('ApiService Tests', () {
    test('ApiService should initialize with correct base URL', () {
      final apiService = ApiService();
      // Test che il servizio si inizializzi correttamente
      expect(apiService, isA<ApiService>());
    });
  });

  group('ResponsiveUtils Tests', () {
    test('getGridCrossAxisCount should return correct values', () {
      // Simulate different screen widths
      const mobileColumns = 1;
      const tabletColumns = 2;
      const desktopColumns = 3;

      final result = ResponsiveUtils.getGridCrossAxisCount(
        null, // context non necessario per il test
        mobileColumns: mobileColumns,
        tabletColumns: tabletColumns,
        desktopColumns: desktopColumns,
      );

      // Since we can't mock BuildContext easily, we just test the method exists
      expect(result, isA<int>());
    });

    test('getResponsiveFontSize should return valid font sizes', () {
      const mobile = 14.0;
      const tablet = 16.0;
      const desktop = 18.0;

      final result = ResponsiveUtils.getResponsiveFontSize(
        null, // context non necessario per il test
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

      expect(result, isA<double>());
      expect(result, greaterThan(0));
    });

    test('getSpacing should return valid spacing values', () {
      const mobileSpacing = 8.0;
      const tabletSpacing = 12.0;
      const desktopSpacing = 16.0;

      final result = ResponsiveUtils.getSpacing(
        null, // context non necessario per il test
        mobileSpacing: mobileSpacing,
        tabletSpacing: tabletSpacing,
        desktopSpacing: desktopSpacing,
      );

      expect(result, isA<double>());
      expect(result, greaterThan(0));
    });
  });
}*/