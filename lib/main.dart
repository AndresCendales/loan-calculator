import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'features/loans/domain/entities/loan.dart';
import 'features/loans/domain/entities/insurance_config.dart';
import 'features/loans/domain/entities/early_repayment.dart';
import 'features/loans/data/adapters/decimal_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(DecimalAdapter());
  Hive.registerAdapter(LoanAdapter());
  Hive.registerAdapter(InsuranceConfigAdapter());
  Hive.registerAdapter(InsuranceModeAdapter());
  Hive.registerAdapter(EarlyRepaymentAdapter());
  Hive.registerAdapter(EarlyTypeAdapter());

  runApp(
    const ProviderScope(
      child: LoanCalculatorApp(),
    ),
  );
}
