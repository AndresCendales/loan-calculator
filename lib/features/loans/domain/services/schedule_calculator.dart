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
    
    // Use higher precision for large loan calculations
    final teaDouble = tea.toDouble();
    final monthlyRate = math.pow(1 + teaDouble, 1.0 / 12.0) - 1;
    
    // Round to prevent precision issues with very small rates
    final roundedRate = (monthlyRate * 1e15).round() / 1e15;
    return Decimal.parse(roundedRate.toString());
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
      
      // Ensure balance precision doesn't degrade
      if (currentBalance <= Decimal.zero) break;
      
      final interest = currentBalance * monthlyRate;
      var amortization = fixedPayment - interest;
      
      // Round interest to reasonable precision to avoid extreme decimal places
      final interestRounded = Decimal.parse(interest.toDouble().toStringAsFixed(2));
      
      // Recalculate amortization with rounded interest
      var amortizationRounded = fixedPayment - interestRounded;
      
      // Handle final installment adjustment
      if (amortizationRounded > currentBalance) {
        amortizationRounded = currentBalance;
      }
      
      // Ensure amortization is valid
      if (amortizationRounded < Decimal.zero) {
        amortizationRounded = Decimal.zero;
      }
      
      final actualPayment = interestRounded + amortizationRounded;
      var finalBalance = currentBalance - amortizationRounded;
      
      // Round very small balances to zero to prevent precision issues
      if (finalBalance < Decimal.parse('0.01')) {
        finalBalance = Decimal.zero;
        amortizationRounded = currentBalance; // Adjust amortization to match
      }
      
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
        interes: interestRounded,
        amortizacion: amortizationRounded,
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
      final ratio = (monthlyRate * newBalance / currentPayment).toDouble();
      final logArg = 1 - ratio;
      
      // Validate mathematical inputs
      if (logArg <= 0 || logArg >= 1) {
        // Fallback to simple division if log calculation would fail
        newRemainingTerms = (newBalance / currentPayment).ceil().toInt();
      } else {
        final numerator = math.log(logArg);
        final denominator = math.log(1 + monthlyRate.toDouble());
        
        if (!numerator.isFinite || !denominator.isFinite || denominator == 0) {
          newRemainingTerms = (newBalance / currentPayment).ceil().toInt();
        } else {
          final result = -numerator / denominator;
          if (!result.isFinite || result <= 0) {
            newRemainingTerms = (newBalance / currentPayment).ceil().toInt();
          } else {
            newRemainingTerms = result.ceil();
          }
        }
      }
    } else {
      newRemainingTerms = (newBalance / currentPayment).ceil().toInt();
    }
    
    // Ensure reasonable bounds
    if (newRemainingTerms <= 0) {
      newRemainingTerms = 1;
    }
    if (newRemainingTerms > 1000) { // Reasonable maximum
      newRemainingTerms = 1000;
    }

    // Generate remaining installments with fixed payment
    var currentBalance = newBalance;
    
    for (int i = 0; i < newRemainingTerms; i++) {
      final installmentNumber = targetIndex + i + 1;
      final installmentDate = nthInstallmentDate(loan.fechaInicio, installmentNumber);
      
      final interest = currentBalance * monthlyRate;
      
      // Round interest to reasonable precision to avoid extreme decimal places
      final interestRounded = Decimal.parse(interest.toDouble().toStringAsFixed(2));
      
      // Recalculate amortization with rounded interest
      var amortizationRounded = currentPayment - interestRounded;
      
      // Adjust final installment
      if (i == newRemainingTerms - 1 || amortizationRounded > currentBalance) {
        amortizationRounded = currentBalance;
      }
      
      // Ensure amortization is valid
      if (amortizationRounded < Decimal.zero) {
        amortizationRounded = Decimal.zero;
      }
      
      final actualPayment = interestRounded + amortizationRounded;
      var finalBalance = currentBalance - amortizationRounded;
      
      // Round very small balances to zero to prevent precision issues
      if (finalBalance < Decimal.parse('0.01')) {
        finalBalance = Decimal.zero;
        amortizationRounded = currentBalance;
      }
      
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
        interes: interestRounded,
        amortizacion: amortizationRounded,
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
      
      // Round interest to reasonable precision to avoid extreme decimal places
      final interestRounded = Decimal.parse(interest.toDouble().toStringAsFixed(2));
      
      // Recalculate amortization with rounded interest
      var amortizationRounded = newPayment - interestRounded;
      
      // Adjust final installment
      if (i == remainingTerms - 1 || amortizationRounded > currentBalance) {
        amortizationRounded = currentBalance;
      }
      
      // Ensure amortization is valid
      if (amortizationRounded < Decimal.zero) {
        amortizationRounded = Decimal.zero;
      }
      
      final actualPayment = interestRounded + amortizationRounded;
      var finalBalance = currentBalance - amortizationRounded;
      
      // Round very small balances to zero to prevent precision issues
      if (finalBalance < Decimal.parse('0.01')) {
        finalBalance = Decimal.zero;
        amortizationRounded = currentBalance;
      }
      
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
        interes: interestRounded,
        amortizacion: amortizationRounded,
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
    if (target.isBefore(start) || target.isAtSameMomentAs(start)) return 0;
    
    int index = 0;
    while (true) {
      index++;
      final installmentDate = nthInstallmentDate(start, index);
      if (target.isBefore(installmentDate) || target.isAtSameMomentAs(installmentDate)) {
        return index - 1;
      }
    }
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
    
    // Validate inputs to prevent mathematical errors
    if (rDouble <= 0 || nDouble <= 0) {
      return Decimal.zero;
    }
    
    final onePlusR = 1 + rDouble;
    final powerResult = math.pow(onePlusR, -nDouble);
    
    // Check for edge cases that could cause infinite values
    if (!powerResult.isFinite || powerResult >= 1.0 || powerResult <= 0) {
      // Fallback to simple division if power calculation fails
      return Decimal.parse((principal.toDouble() / terms).toString());
    }
    
    final numerator = principal.toDouble() * rDouble;
    final denominator = 1 - powerResult;
    
    if (denominator <= 0 || !denominator.isFinite) {
      // Fallback calculation
      return Decimal.parse((principal.toDouble() / terms).toString());
    }
    
    final result = numerator / denominator;
    
    if (!result.isFinite) {
      // Fallback calculation
      return Decimal.parse((principal.toDouble() / terms).toString());
    }
    
    return Decimal.parse(result.toString());
  }
}
