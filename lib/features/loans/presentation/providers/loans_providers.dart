import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/loans_local_datasource.dart';
import '../../data/repositories/loans_repository_impl.dart';
import '../../domain/repositories/loans_repository.dart';
import '../../domain/services/schedule_calculator.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/schedule.dart';

// Repository providers
final loansLocalDatasourceProvider = Provider<LoansLocalDatasource>((ref) {
  return LoansLocalDatasourceImpl();
});

final loansRepositoryProvider = Provider<LoansRepository>((ref) {
  final datasource = ref.watch(loansLocalDatasourceProvider);
  return LoansRepositoryImpl(datasource);
});

// Service providers
final scheduleCalculatorProvider = Provider<ScheduleCalculator>((ref) {
  return const ScheduleCalculator();
});

// State providers
final loansListProvider = AsyncNotifierProvider<LoansListNotifier, List<Loan>>(() {
  return LoansListNotifier();
});

final loanDetailProvider = AsyncNotifierProvider.family<LoanDetailNotifier, (Loan, Schedule)?, String>(() {
  return LoanDetailNotifier();
});

// Notifiers
class LoansListNotifier extends AsyncNotifier<List<Loan>> {
  @override
  Future<List<Loan>> build() async {
    final repository = ref.read(loansRepositoryProvider);
    return await repository.getAllLoans();
  }

  Future<void> createLoan(Loan loan) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(loansRepositoryProvider);
      await repository.saveLoan(loan);
      state = AsyncValue.data([...?state.value, loan]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateLoan(Loan loan) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(loansRepositoryProvider);
      await repository.saveLoan(loan);
      
      final currentLoans = state.value ?? [];
      final updatedLoans = currentLoans.map((l) => l.id == loan.id ? loan : l).toList();
      state = AsyncValue.data(updatedLoans);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteLoan(String loanId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(loansRepositoryProvider);
      await repository.deleteLoan(loanId);
      
      final currentLoans = state.value ?? [];
      final updatedLoans = currentLoans.where((l) => l.id != loanId).toList();
      state = AsyncValue.data(updatedLoans);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(loansRepositoryProvider);
      final loans = await repository.getAllLoans();
      state = AsyncValue.data(loans);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class LoanDetailNotifier extends FamilyAsyncNotifier<(Loan, Schedule)?, String> {
  @override
  Future<(Loan, Schedule)?> build(String loanId) async {
    final repository = ref.read(loansRepositoryProvider);
    final calculator = ref.read(scheduleCalculatorProvider);
    
    final loan = await repository.getLoanById(loanId);
    if (loan == null) return null;

    final baseSchedule = calculator.buildInitialSchedule(loan);
    final finalSchedule = calculator.applyEarlyRepayments(
      baseSchedule, 
      loan, 
      loan.earlyRepayments
    );

    return (loan, finalSchedule);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final result = await build(arg);
    state = AsyncValue.data(result);
  }
}
