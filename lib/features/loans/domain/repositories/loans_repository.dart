import 'package:decimal/decimal.dart';
import '../entities/loan.dart';
import '../entities/early_repayment.dart';
import '../entities/insurance_config.dart';

abstract class LoansRepository {
  Future<List<Loan>> getAllLoans();
  Future<Loan?> getLoanById(String id);
  Future<void> saveLoan(Loan loan);
  Future<void> deleteLoan(String id);
  Future<void> addEarlyRepayment(String loanId, EarlyRepayment earlyRepayment);
  Future<void> removeEarlyRepayment(String loanId, String earlyRepaymentId);
  Future<void> updateInsuranceConfig(String loanId, InsuranceConfig insuranceConfig);
  Future<void> setInsuranceOverride(String loanId, int installmentNumber, Decimal amount);
  Future<void> removeInsuranceOverride(String loanId, int installmentNumber);
}
