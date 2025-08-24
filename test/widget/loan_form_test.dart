import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:loan_calculator/features/loans/presentation/pages/loan_form_page.dart';
import 'package:loan_calculator/features/loans/domain/repositories/loans_repository.dart';
import 'package:loan_calculator/features/loans/presentation/providers/loans_providers.dart';

class MockLoansRepository extends Mock implements LoansRepository {}

void main() {
  group('LoanFormPage Widget Tests', () {
    late MockLoansRepository mockRepository;

    setUp(() {
      mockRepository = MockLoansRepository();
      registerFallbackValue(MockLoan());
    });

    testWidgets('displays create loan form correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loansRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: const LoanFormPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check if form fields are present
      expect(find.text('Create Loan'), findsOneWidget);
      expect(find.text('Loan Information'), findsOneWidget);
      expect(find.text('Insurance Configuration'), findsOneWidget);
      expect(find.text('Payment Preview'), findsOneWidget);
      
      // Check form fields
      expect(find.byType(TextFormField), findsAtLeastNWidgets(4));
      expect(find.text('Loan Title'), findsOneWidget);
      expect(find.text('Principal Amount'), findsOneWidget);
      expect(find.text('Term'), findsOneWidget);
      expect(find.text('Annual Interest Rate (TEA)'), findsOneWidget);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loansRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: const LoanFormPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit without filling fields
      final createButton = find.text('Create');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('Principal amount is required'), findsOneWidget);
      expect(find.text('Term is required'), findsOneWidget);
      expect(find.text('TEA is required'), findsOneWidget);
    });

    testWidgets('shows payment preview when valid data is entered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loansRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: const LoanFormPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill in form fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Loan Title'), 'Test Loan');
      await tester.enterText(find.widgetWithText(TextFormField, 'Principal Amount'), '100000');
      await tester.enterText(find.widgetWithText(TextFormField, 'Term'), '12');
      await tester.enterText(find.widgetWithText(TextFormField, 'Annual Interest Rate (TEA)'), '12');

      await tester.pumpAndSettle();

      // Should show payment preview
      expect(find.text('Monthly Payment'), findsOneWidget);
      expect(find.text('Total Term'), findsOneWidget);
      expect(find.text('Monthly Rate (TEM)'), findsOneWidget);
    });

    testWidgets('switches between months and years', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loansRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: const LoanFormPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should be in months
      expect(find.text('Months'), findsOneWidget);
      
      // Tap on dropdown
      await tester.tap(find.text('Months'));
      await tester.pumpAndSettle();
      
      // Select years
      await tester.tap(find.text('Years').last);
      await tester.pumpAndSettle();
      
      expect(find.text('Years'), findsOneWidget);
    });

    testWidgets('configures insurance options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            loansRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: const LoanFormPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find insurance dropdown
      final insuranceDropdown = find.widgetWithText(DropdownButtonFormField, 'Insurance Type');
      
      // Tap on dropdown
      await tester.tap(insuranceDropdown);
      await tester.pumpAndSettle();
      
      // Select flat insurance
      await tester.tap(find.text('Fixed Monthly Amount').last);
      await tester.pumpAndSettle();
      
      // Should show flat amount field
      expect(find.text('Fixed Monthly Insurance'), findsOneWidget);
    });
  });
}

// Mock class for Loan entity
class MockLoan extends Mock {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}
