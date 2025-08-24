import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/entities/schedule.dart';
import '../domain/entities/loan.dart';
import 'formatters.dart';

class CsvExportService {
  static Future<void> exportSchedule(Loan loan, Schedule schedule) async {
    try {
      // Prepare CSV data
      final List<List<String>> csvData = [
        // Header row
        [
          'numero',
          'fecha',
          'saldo_inicial',
          'interes',
          'amortizacion',
          'cuota',
          'seguro',
          'total_mes',
          'saldo_final',
        ],
        // Data rows
        ...schedule.installments.map((installment) => [
          installment.numero.toString(),
          LoanFormatters.formatDate(installment.fecha),
          installment.saldoInicial.toString(),
          installment.interes.toString(),
          installment.amortizacion.toString(),
          installment.pagoCuota.toString(),
          installment.seguro.toString(),
          installment.totalMes.toString(),
          installment.saldoFinal.toString(),
        ]),
      ];

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'loan_schedule_${loan.titulo.replaceAll(' ', '_')}.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV to file
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Loan Schedule: ${loan.titulo}',
        text: 'Payment schedule for loan: ${loan.titulo}',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  static Future<void> exportAllLoansSchedules(
    List<Loan> loans, 
    List<Schedule> schedules,
  ) async {
    try {
      final List<List<String>> csvData = [
        // Header row
        [
          'loan_title',
          'numero',
          'fecha',
          'saldo_inicial',
          'interes',
          'amortizacion',
          'cuota',
          'seguro',
          'total_mes',
          'saldo_final',
        ],
      ];

      // Add data for each loan
      for (int i = 0; i < loans.length; i++) {
        final loan = loans[i];
        final schedule = schedules[i];
        
        for (final installment in schedule.installments) {
          csvData.add([
            loan.titulo,
            installment.numero.toString(),
            LoanFormatters.formatDate(installment.fecha),
            installment.saldoInicial.toString(),
            installment.interes.toString(),
            installment.amortizacion.toString(),
            installment.pagoCuota.toString(),
            installment.seguro.toString(),
            installment.totalMes.toString(),
            installment.saldoFinal.toString(),
          ]);
        }
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'all_loans_schedules.csv';
      final file = File('${directory.path}/$fileName');

      // Write CSV to file
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'All Loans Schedules',
        text: 'Payment schedules for all loans',
      );
    } catch (e) {
      throw Exception('Failed to export all schedules CSV: $e');
    }
  }
}
