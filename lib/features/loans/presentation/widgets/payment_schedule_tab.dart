import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/schedule.dart';
import '../../utils/formatters.dart';
import '../../utils/csv_export_service.dart';

class PaymentScheduleTab extends StatefulWidget {
  final Loan loan;
  final Schedule schedule;

  const PaymentScheduleTab({
    super.key,
    required this.loan,
    required this.schedule,
  });

  @override
  State<PaymentScheduleTab> createState() => _PaymentScheduleTabState();
}

class _PaymentScheduleTabState extends State<PaymentScheduleTab> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.schedule.installments.length} installments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.file_download),
                label: const Text('Export CSV'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columnSpacing: 16,
                horizontalMargin: 16,
                columns: [
                  DataColumn(
                    label: const Text('#'),
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Date'),
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Initial Balance'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Interest'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Principal'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Payment'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Insurance'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Total'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Final Balance'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort(columnIndex, ascending),
                  ),
                ],
                rows: widget.schedule.installments.map((installment) {
                  return DataRow(
                    cells: [
                      DataCell(Text(installment.numero.toString())),
                      DataCell(Text(LoanFormatters.formatDate(installment.fecha))),
                      DataCell(Text(LoanFormatters.formatCurrency(installment.saldoInicial))),
                      DataCell(Text(LoanFormatters.formatCurrency(installment.interes))),
                      DataCell(Text(LoanFormatters.formatCurrency(installment.amortizacion))),
                      DataCell(Text(LoanFormatters.formatCurrency(installment.pagoCuota))),
                      DataCell(Text(LoanFormatters.formatCurrency(installment.seguro))),
                      DataCell(
                        Text(
                          LoanFormatters.formatCurrency(installment.totalMes),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(LoanFormatters.formatCurrency(installment.saldoFinal))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        _buildSummaryCard(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalInterest = widget.schedule.installments
        .fold(widget.loan.principal * Decimal.zero, (sum, installment) => sum + installment.interes);
    final totalInsurance = widget.schedule.installments
        .fold(widget.loan.principal * Decimal.zero, (sum, installment) => sum + installment.seguro);
    final totalPayments = widget.schedule.installments
        .fold(widget.loan.principal * Decimal.zero, (sum, installment) => sum + installment.totalMes);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Total Interest',
                  value: LoanFormatters.formatCurrency(totalInterest),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Total Insurance',
                  value: LoanFormatters.formatCurrency(totalInsurance),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SummaryItem(
            label: 'Total Amount to Pay',
            value: LoanFormatters.formatCurrency(totalPayments),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  void _sort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    
    // Note: For simplicity, we're not actually sorting the data here
    // In a production app, you would sort the installments list
  }

  Future<void> _exportToCsv() async {
    try {
      await CsvExportService.exportSchedule(widget.loan, widget.schedule);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 18 : null,
          ),
        ),
      ],
    );
  }
}
