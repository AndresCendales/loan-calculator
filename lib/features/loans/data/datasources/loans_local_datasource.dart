import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/loan.dart';

abstract class LoansLocalDatasource {
  Future<List<Loan>> getAllLoans();
  Future<Loan?> getLoanById(String id);
  Future<void> saveLoan(Loan loan);
  Future<void> deleteLoan(String id);
  Future<void> deleteAllLoans();
}

class LoansLocalDatasourceImpl implements LoansLocalDatasource {
  static const String _boxName = 'loans';
  
  Box<Loan>? _box;

  Future<Box<Loan>> get box async {
    _box ??= await Hive.openBox<Loan>(_boxName);
    return _box!;
  }

  @override
  Future<List<Loan>> getAllLoans() async {
    final loansBox = await box;
    return loansBox.values.toList();
  }

  @override
  Future<Loan?> getLoanById(String id) async {
    final loansBox = await box;
    return loansBox.get(id);
  }

  @override
  Future<void> saveLoan(Loan loan) async {
    final loansBox = await box;
    await loansBox.put(loan.id, loan);
  }

  @override
  Future<void> deleteLoan(String id) async {
    final loansBox = await box;
    await loansBox.delete(id);
  }

  @override
  Future<void> deleteAllLoans() async {
    final loansBox = await box;
    await loansBox.clear();
  }
}
