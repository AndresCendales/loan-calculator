import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import '../entities/loan.dart';
import '../entities/schedule.dart';
import '../entities/installment.dart';
import '../entities/early_repayment.dart';
import '../entities/insurance_config.dart';

class ScheduleCalculator {
  const ScheduleCalculator();

  /// Convert TEA (annual effective rate) to TEM (monthly effective rate)
  /// Formula: r_m = (1 + TEA)^(1/12) - 1
  Decimal monthlyRateFromTea(Decimal tea) {
    if (tea == Decimal.zero) return Decimal.zero;
    
    final teaDouble = tea.toDouble();
    final monthlyRate = math.pow(1 + teaDouble, 1.0 / 12.0) - 1;
    return Decimal.parse(monthlyRate.toString());
  }

  /// Build initial schedule without early repayments
  Schedule buildInitialSchedule(Loan loan) {
    final monthlyRate = monthlyRateFromTea(loan.tea);
    final fixedPayment = computeFixedInstallment(
      loan.principal, 
      monthlyRate, 
      loan.plazoMeses
    );

    final installments = <Installment>[];
    var currentBalance = loan.principal;

    for (int i = 1; i <= loan.plazoMeses; i++) {
      final installmentDate = nthInstallmentDate(loan.fechaInicio, i);
      final interest = currentBalance * monthlyRate;
      var amortization = fixedPayment - interest;
      
      // Handle final installment adjustment
      if (amortization > currentBalance) {
        amortization = currentBalance;
      }
      
      final actualPayment = interest + amortization;
      final finalBalance = currentBalance - amortization;
      
      // Calculate insurance
      final insurance = calculateInsurance(
        loan.seguroConfig, 
        i, 
        currentBalance, 
        installmentDate
      );
      
      final totalMonth = actualPayment + insurance;

      installments.add(Installment(
        numero: i,
        fecha: installmentDate,
        saldoInicial: currentBalance,
        interes: interest,
        amortizacion: amortization,
        pagoCuota: actualPayment,
        seguro: insurance,
        totalMes: totalMonth,
        saldoFinal: finalBalance,
      ));

      currentBalance = finalBalance;
      
      // Break if loan is paid off
      if (currentBalance <= Decimal.zero) break;
    }

    return Schedule(
      loanId: loan.id,
      installments: installments,
      cuota: fixedPayment,
      ultimaActualizacion: DateTime.now(),
      recalculos: 0,
    );
  }

  /// Apply early repayments to a base schedule
  Schedule applyEarlyRepayments(
    Schedule base,
    Loan loan,
    List<EarlyRepayment> events,
  ) {
    if (events.isEmpty) return base;

    // Sort early repayments by date
    final sortedEvents = [...events]..sort((a, b) => a.fecha.compareTo(b.fecha));
    
    var currentSchedule = base;
    int recalculations = 0;

    for (final early in sortedEvents) {
      currentSchedule = _applySingleEarlyRepayment(currentSchedule, loan, early);
      recalculations++;
    }

    return currentSchedule.copyWith(
      recalculos: recalculations,
      ultimaActualizacion: DateTime.now(),
    );
  }

  /// Apply a single early repayment
  Schedule _applySingleEarlyRepayment(
    Schedule schedule,
    Loan loan,
    EarlyRepayment early,
  ) {
    final targetInstallmentIndex = mapDateToInstallmentIndex(
      loan.fechaInicio, 
      early.fecha
    );

    if (targetInstallmentIndex >= schedule.installments.length) {
      return schedule; // Early payment date is after loan completion
    }

    final monthlyRate = monthlyRateFromTea(loan.tea);
    final installments = <Installment>[];
    
    // Add installments before early repayment unchanged
    for (int i = 0; i < targetInstallmentIndex; i++) {
      installments.add(schedule.installments[i]);
    }

    // Apply early repayment at target installment
    final targetInstallment = schedule.installments[targetInstallmentIndex];
    var newBalance = targetInstallment.saldoInicial - early.monto;
    
    if (newBalance <= Decimal.zero) {
      // Early payment covers remaining balance - close loan
      final finalInstallment = targetInstallment.copyWith(
        amortizacion: targetInstallment.saldoInicial,
        pagoCuota: targetInstallment.interes + targetInstallment.saldoInicial,
        saldoFinal: Decimal.zero,
        totalMes: targetInstallment.interes + targetInstallment.saldoInicial + targetInstallment.seguro,
      );
      installments.add(finalInstallment);
      
      return Schedule(
        loanId: schedule.loanId,
        installments: installments,
        cuota: schedule.cuota,
        ultimaActualizacion: DateTime.now(),
        recalculos: schedule.recalculos + 1,
      );
    }

    // Recalculate remaining schedule based on early repayment type
    if (early.tipo == EarlyType.reduceTerm) {
      return _recalculateWithReducedTerm(
        schedule, loan, installments, targetInstallmentIndex, 
        newBalance, monthlyRate, early
      );
    } else {
      return _recalculateWithReducedPayment(
        schedule, loan, installments, targetInstallmentIndex, 
        newBalance, monthlyRate, early
      );
    }
  }

  /// Recalculate schedule with reduced term (maintain payment amount)
  Schedule _recalculateWithReducedTerm(
    Schedule schedule,
    Loan loan,
    List<Installment> installments,
    int targetIndex,
    Decimal newBalance,
    Decimal monthlyRate,
    EarlyRepayment early,
  ) {
    final currentPayment = schedule.cuota;
    
    // Calculate new term
    int newRemainingTerms;
    if (monthlyRate > Decimal.zero) {
      final numerator = math.log(1 - (monthlyRate * newBalance / currentPayment).toDouble());
      final denominator = math.log(1 + monthlyRate.toDouble());
      newRemainingTerms = (-numerator / denominator).ceil();
    } else {
      newRemainingTerms = (newBalance / currentPayment).ceil().toInt();
    }

    // Generate remaining installments with fixed payment
    var currentBalance = newBalance;
    
    for (int i = 0; i < newRemainingTerms; i++) {
      final installmentNumber = targetIndex + i + 1;
      final installmentDate = nthInstallmentDate(loan.fechaInicio, installmentNumber);
      
      final interest = currentBalance * monthlyRate;
      var amortization = currentPayment - interest;
      
      // Adjust final installment
      if (i == newRemainingTerms - 1 || amortization > currentBalance) {
        amortization = currentBalance;
      }
      
      final actualPayment = interest + amortization;
      final finalBalance = currentBalance - amortization;
      
      final insurance = calculateInsurance(
        loan.seguroConfig, 
        installmentNumber, 
        currentBalance, 
        installmentDate
      );
      
      installments.add(Installment(
        numero: installmentNumber,
        fecha: installmentDate,
        saldoInicial: currentBalance,
        interes: interest,
        amortizacion: amortization,
        pagoCuota: actualPayment,
        seguro: insurance,
        totalMes: actualPayment + insurance,
        saldoFinal: finalBalance,
      ));

      currentBalance = finalBalance;
      if (currentBalance <= Decimal.zero) break;
    }

    return Schedule(
      loanId: schedule.loanId,
      installments: installments,
      cuota: currentPayment,
      ultimaActualizacion: DateTime.now(),
      recalculos: schedule.recalculos + 1,
    );
  }

  /// Recalculate schedule with reduced payment (maintain term)
  Schedule _recalculateWithReducedPayment(
    Schedule schedule,
    Loan loan,
    List<Installment> installments,
    int targetIndex,
    Decimal newBalance,
    Decimal monthlyRate,
    EarlyRepayment early,
  ) {
    final remainingTerms = schedule.installments.length - targetIndex;
    final newPayment = computeFixedInstallment(newBalance, monthlyRate, remainingTerms);
    
    var currentBalance = newBalance;
    
    for (int i = 0; i < remainingTerms; i++) {
      final installmentNumber = targetIndex + i + 1;
      final installmentDate = nthInstallmentDate(loan.fechaInicio, installmentNumber);
      
      final interest = currentBalance * monthlyRate;
      var amortization = newPayment - interest;
      
      // Adjust final installment
      if (i == remainingTerms - 1 || amortization > currentBalance) {
        amortization = currentBalance;
      }
      
      final actualPayment = interest + amortization;
      final finalBalance = currentBalance - amortization;
      
      final insurance = calculateInsurance(
        loan.seguroConfig, 
        installmentNumber, 
        currentBalance, 
        installmentDate
      );
      
      installments.add(Installment(
        numero: installmentNumber,
        fecha: installmentDate,
        saldoInicial: currentBalance,
        interes: interest,
        amortizacion: amortization,
        pagoCuota: actualPayment,
        seguro: insurance,
        totalMes: actualPayment + insurance,
        saldoFinal: finalBalance,
      ));

      currentBalance = finalBalance;
      if (currentBalance <= Decimal.zero) break;
    }

    return Schedule(
      loanId: schedule.loanId,
      installments: installments,
      cuota: newPayment,
      ultimaActualizacion: DateTime.now(),
      recalculos: schedule.recalculos + 1,
    );
  }

  /// Calculate insurance for a specific installment
  Decimal calculateInsurance(
    InsuranceConfig config,
    int installmentNumber,
    Decimal initialBalance,
    DateTime installmentDate,
  ) {
    // Check for override first
    if (config.perInstallmentOverrides.containsKey(installmentNumber)) {
      return config.perInstallmentOverrides[installmentNumber]!;
    }

    switch (config.mode) {
      case InsuranceMode.none:
        return Decimal.zero;
      case InsuranceMode.flat:
        return config.flatAmountPerMonth ?? Decimal.zero;
      case InsuranceMode.percentOfBalance:
        final percentage = config.monthlyPercentOfBalance ?? Decimal.zero;
        return initialBalance * percentage;
    }
  }

  /// Map a date to the corresponding installment index
  int mapDateToInstallmentIndex(DateTime start, DateTime target) {
    if (target.isBefore(start)) return 0;
    
    var current = start;
    int index = 0;
    
    while (current.isBefore(target) || current.isAtSameMomentAs(target)) {
      index++;
      current = nthInstallmentDate(start, index + 1);
      if (current.isAfter(target)) break;
    }
    
    return index;
  }

  /// Calculate the date for the nth installment
  DateTime nthInstallmentDate(DateTime start, int n) {
    var year = start.year;
    var month = start.month + (n - 1);
    var day = start.day;

    // Handle month overflow
    while (month > 12) {
      month -= 12;
      year++;
    }

    // Handle day overflow (e.g., Jan 31 -> Feb 28/29)
    final daysInMonth = DateTime(year, month + 1, 0).day;
    if (day > daysInMonth) {
      day = daysInMonth;
    }

    return DateTime(year, month, day);
  }

  /// Compute fixed installment using French amortization system
  Decimal computeFixedInstallment(Decimal principal, Decimal monthlyRate, int terms) {
    if (monthlyRate == Decimal.zero) {
      return Decimal.parse((principal.toDouble() / terms).toString());
    }

    final rDouble = monthlyRate.toDouble();
    final nDouble = terms.toDouble();
    
    final numerator = principal.toDouble() * rDouble;
    final denominator = 1 - math.pow(1 + rDouble, -nDouble);
    
    return Decimal.parse((numerator / denominator).toString());
  }
}
