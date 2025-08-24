import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:loan_calculator/features/loans/domain/entities/loan.dart';
import 'package:loan_calculator/features/loans/domain/entities/insurance_config.dart';
import 'package:loan_calculator/features/loans/domain/entities/early_repayment.dart';
import 'package:loan_calculator/features/loans/domain/services/schedule_calculator.dart';

void main() {
  group('ScheduleCalculator', () {
    late ScheduleCalculator calculator;

    setUp(() {
      calculator = const ScheduleCalculator();
    });

    group('monthlyRateFromTea', () {
      test('converts TEA to TEM correctly', () {
        // TEA of 12% should give TEM of approximately 0.9489%
        final tea = Decimal.parse('0.12');
        final tem = calculator.monthlyRateFromTea(tea);
        
        expect(tem.toDouble(), closeTo(0.009489, 0.0001));
      });

      test('returns zero for zero TEA', () {
        final tea = Decimal.zero;
        final tem = calculator.monthlyRateFromTea(tea);
        
        expect(tem, equals(Decimal.zero));
      });
    });

    group('computeFixedInstallment', () {
      test('calculates fixed installment with interest', () {
        final principal = Decimal.parse('100000');
        final monthlyRate = Decimal.parse('0.01'); // 1% monthly
        const terms = 12;

        final payment = calculator.computeFixedInstallment(principal, monthlyRate, terms);
        
        // Expected payment for 100k at 1% monthly for 12 months
        expect(payment.toDouble(), closeTo(8884.88, 0.01));
      });

      test('calculates fixed installment with zero interest', () {
        final principal = Decimal.parse('100000');
        final monthlyRate = Decimal.zero;
        const terms = 12;

        final payment = calculator.computeFixedInstallment(principal, monthlyRate, terms);
        
        expect(payment, equals(Decimal.parse('8333.33')));
      });
    });

    group('buildInitialSchedule', () {
      test('builds schedule with correct number of installments', () {
        final loan = Loan(
          id: 'test-1',
          titulo: 'Test Loan',
          principal: Decimal.parse('100000'),
          plazoMeses: 12,
          tea: Decimal.parse('0.12'),
          fechaInicio: DateTime(2024, 1, 1),
          seguroConfig: const InsuranceConfig(mode: InsuranceMode.none),
        );

        final schedule = calculator.buildInitialSchedule(loan);

        expect(schedule.installments.length, equals(12));
        expect(schedule.loanId, equals('test-1'));
        expect(schedule.recalculos, equals(0));
      });

      test('builds schedule with flat insurance', () {
        final loan = Loan(
          id: 'test-2',
          titulo: 'Test Loan with Insurance',
          principal: Decimal.parse('100000'),
          plazoMeses: 12,
          tea: Decimal.parse('0.12'),
          fechaInicio: DateTime(2024, 1, 1),
          seguroConfig: InsuranceConfig(
            mode: InsuranceMode.flat,
            flatAmountPerMonth: Decimal.fromInt(50),
          ),
        );

        final schedule = calculator.buildInitialSchedule(loan);
        
        // All installments should have $50 insurance
        for (final installment in schedule.installments) {
          expect(installment.seguro, equals(Decimal.fromInt(50)));
        }
      });

      test('builds schedule with percentage insurance', () {
        final loan = Loan(
          id: 'test-3',
          titulo: 'Test Loan with Percentage Insurance',
          principal: Decimal.parse('100000'),
          plazoMeses: 12,
          tea: Decimal.parse('0.12'),
          fechaInicio: DateTime(2024, 1, 1),
          seguroConfig: InsuranceConfig(
            mode: InsuranceMode.percentOfBalance,
            monthlyPercentOfBalance: Decimal.parse('0.001'), // 0.1%
          ),
        );

        final schedule = calculator.buildInitialSchedule(loan);
        
        // First installment should have insurance based on full principal
        final firstInstallment = schedule.installments.first;
        expect(firstInstallment.seguro.toDouble(), closeTo(100.0, 0.01)); // 0.1% of 100,000
        
        // Insurance should decrease as balance decreases
        final lastInstallment = schedule.installments.last;
        expect(lastInstallment.seguro < firstInstallment.seguro, isTrue);
      });

      test('final installment has zero balance', () {
        final loan = Loan(
          id: 'test-4',
          titulo: 'Test Final Balance',
          principal: Decimal.parse('100000'),
          plazoMeses: 12,
          tea: Decimal.parse('0.12'),
          fechaInicio: DateTime(2024, 1, 1),
          seguroConfig: const InsuranceConfig(mode: InsuranceMode.none),
        );

        final schedule = calculator.buildInitialSchedule(loan);
        final finalInstallment = schedule.installments.last;
        
        expect(finalInstallment.saldoFinal.toDouble(), closeTo(0.0, 0.01));
      });
    });

    group('applyEarlyRepayments', () {
      late Loan baseLoan;
      // late Schedule baseSchedule;

      setUp(() {
        baseLoan = Loan(
          id: 'test-early',
          titulo: 'Test Early Payment',
          principal: Decimal.parse('100000'),
          plazoMeses: 24,
          tea: Decimal.parse('0.12'),
          fechaInicio: DateTime(2024, 1, 1),
          seguroConfig: const InsuranceConfig(mode: InsuranceMode.none),
        );
        // baseSchedule = calculator.buildInitialSchedule(baseLoan);
      });

      test('reduce payment early repayment decreases monthly payment', () {
        final baseSchedule = calculator.buildInitialSchedule(baseLoan);
        final earlyRepayment = EarlyRepayment(
          id: 'early-1',
          fecha: DateTime(2024, 6, 1), // 6 months in
          monto: Decimal.parse('20000'),
          tipo: EarlyType.reducePayment,
        );

        final newSchedule = calculator.applyEarlyRepayments(
          baseSchedule,
          baseLoan,
          [earlyRepayment],
        );

        expect(newSchedule.cuota < baseSchedule.cuota, isTrue);
        expect(newSchedule.recalculos, equals(1));
      });

      test('reduce term early repayment decreases number of installments', () {
        final baseSchedule = calculator.buildInitialSchedule(baseLoan);
        final earlyRepayment = EarlyRepayment(
          id: 'early-2',
          fecha: DateTime(2024, 6, 1), // 6 months in
          monto: Decimal.parse('20000'),
          tipo: EarlyType.reduceTerm,
        );

        final newSchedule = calculator.applyEarlyRepayments(
          baseSchedule,
          baseLoan,
          [earlyRepayment],
        );

        expect(newSchedule.installments.length < baseSchedule.installments.length, isTrue);
        expect(newSchedule.cuota, equals(baseSchedule.cuota)); // Payment stays same
        expect(newSchedule.recalculos, equals(1));
      });

      test('multiple early repayments are processed in order', () {
        final baseSchedule = calculator.buildInitialSchedule(baseLoan);
        final early1 = EarlyRepayment(
          id: 'early-1',
          fecha: DateTime(2024, 3, 1),
          monto: Decimal.parse('10000'),
          tipo: EarlyType.reduceTerm,
        );

        final early2 = EarlyRepayment(
          id: 'early-2',
          fecha: DateTime(2024, 9, 1),
          monto: Decimal.parse('15000'),
          tipo: EarlyType.reducePayment,
        );

        final newSchedule = calculator.applyEarlyRepayments(
          baseSchedule,
          baseLoan,
          [early1, early2],
        );

        expect(newSchedule.recalculos, equals(2));
        expect(newSchedule.installments.length < baseSchedule.installments.length, isTrue);
      });

      test('early repayment larger than balance closes loan', () {
        final baseSchedule = calculator.buildInitialSchedule(baseLoan);
        final earlyRepayment = EarlyRepayment(
          id: 'early-large',
          fecha: DateTime(2024, 6, 1),
          monto: Decimal.parse('200000'), // More than principal
          tipo: EarlyType.reduceTerm,
        );

        final newSchedule = calculator.applyEarlyRepayments(
          baseSchedule,
          baseLoan,
          [earlyRepayment],
        );

        // Should have fewer installments than the early repayment date
        expect(newSchedule.installments.length <= 6, isTrue);
        expect(newSchedule.installments.last.saldoFinal, equals(Decimal.zero));
      });
    });

    group('mapDateToInstallmentIndex', () {
      test('maps dates to correct installment indices', () {
        final startDate = DateTime(2024, 1, 15);
        
        // Same date should map to index 0 (first installment)
        expect(calculator.mapDateToInstallmentIndex(startDate, startDate), equals(0));
        
        // One month later should map to index 1 (second installment)
        final oneMonthLater = DateTime(2024, 2, 15);
        expect(calculator.mapDateToInstallmentIndex(startDate, oneMonthLater), equals(1));
        
        // Date before start should map to index 0
        final beforeStart = DateTime(2023, 12, 15);
        expect(calculator.mapDateToInstallmentIndex(startDate, beforeStart), equals(0));
      });
    });

    group('nthInstallmentDate', () {
      test('calculates nth installment dates correctly', () {
        final startDate = DateTime(2024, 1, 15);
        
        expect(calculator.nthInstallmentDate(startDate, 1), equals(startDate));
        expect(calculator.nthInstallmentDate(startDate, 2), equals(DateTime(2024, 2, 15)));
        expect(calculator.nthInstallmentDate(startDate, 13), equals(DateTime(2025, 1, 15)));
      });

      test('handles month overflow correctly', () {
        final startDate = DateTime(2024, 1, 31);
        
        // February doesn't have 31 days, should use last day of February
        expect(calculator.nthInstallmentDate(startDate, 2), equals(DateTime(2024, 2, 29))); // 2024 is leap year
        
        // March has 31 days, should use 31st
        expect(calculator.nthInstallmentDate(startDate, 3), equals(DateTime(2024, 3, 31)));
      });
    });
  });
}
