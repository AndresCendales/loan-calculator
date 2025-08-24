import 'package:decimal/decimal.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/early_repayment.dart';
import '../../domain/entities/insurance_config.dart';
import '../../domain/repositories/loans_repository.dart';
import '../datasources/loans_local_datasource.dart';

class LoansRepositoryImpl implements LoansRepository {
  final LoansLocalDatasource _localDatasource;

  LoansRepositoryImpl(this._localDatasource);

  @override
  Future<List<Loan>> getAllLoans() async {
    return await _localDatasource.getAllLoans();
  }

  @override
  Future<Loan?> getLoanById(String id) async {
    return await _localDatasource.getLoanById(id);
  }

  @override
  Future<void> saveLoan(Loan loan) async {
    await _localDatasource.saveLoan(loan);
  }

  @override
  Future<void> deleteLoan(String id) async {
    await _localDatasource.deleteLoan(id);
  }

  @override
  Future<void> addEarlyRepayment(String loanId, EarlyRepayment earlyRepayment) async {
    final loan = await _localDatasource.getLoanById(loanId);
    if (loan != null) {
      final updatedLoan = loan.copyWith(
        earlyRepayments: [...loan.earlyRepayments, earlyRepayment],
      );
      await _localDatasource.saveLoan(updatedLoan);
    }
  }

  @override
  Future<void> removeEarlyRepayment(String loanId, String earlyRepaymentId) async {
    final loan = await _localDatasource.getLoanById(loanId);
    if (loan != null) {
      final updatedLoan = loan.copyWith(
        earlyRepayments: loan.earlyRepayments
            .where((early) => early.id != earlyRepaymentId)
            .toList(),
      );
      await _localDatasource.saveLoan(updatedLoan);
    }
  }

  @override
  Future<void> updateInsuranceConfig(String loanId, InsuranceConfig insuranceConfig) async {
    final loan = await _localDatasource.getLoanById(loanId);
    if (loan != null) {
      final updatedLoan = loan.copyWith(seguroConfig: insuranceConfig);
      await _localDatasource.saveLoan(updatedLoan);
    }
  }

  @override
  Future<void> setInsuranceOverride(String loanId, int installmentNumber, Decimal amount) async {
    final loan = await _localDatasource.getLoanById(loanId);
    if (loan != null) {
      final updatedOverrides = Map<int, Decimal>.from(
        loan.seguroConfig.perInstallmentOverrides
      );
      updatedOverrides[installmentNumber] = amount;
      
      final updatedInsuranceConfig = loan.seguroConfig.copyWith(
        perInstallmentOverrides: updatedOverrides,
      );
      
      final updatedLoan = loan.copyWith(seguroConfig: updatedInsuranceConfig);
      await _localDatasource.saveLoan(updatedLoan);
    }
  }

  @override
  Future<void> removeInsuranceOverride(String loanId, int installmentNumber) async {
    final loan = await _localDatasource.getLoanById(loanId);
    if (loan != null) {
      final updatedOverrides = Map<int, Decimal>.from(
        loan.seguroConfig.perInstallmentOverrides
      );
      updatedOverrides.remove(installmentNumber);
      
      final updatedInsuranceConfig = loan.seguroConfig.copyWith(
        perInstallmentOverrides: updatedOverrides,
      );
      
      final updatedLoan = loan.copyWith(seguroConfig: updatedInsuranceConfig);
      await _localDatasource.saveLoan(updatedLoan);
    }
  }
}
