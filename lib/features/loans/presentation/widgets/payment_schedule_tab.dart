import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/installment.dart';
import '../../domain/entities/early_repayment.dart';
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
  
  // Controllers for synchronized horizontal scrolling
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  
  // Flag to prevent infinite loop during synchronization
  bool _isSync = false;

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }
  
  void _syncScroll(ScrollController source, ScrollController target) {
    if (!_isSync && source.hasClients && target.hasClients) {
      _isSync = true;
      target.jumpTo(source.offset);
      _isSync = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with export button - Fixed height
        Container(
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
        // Table section - Flexible to prevent overflow
        Flexible(
          child: Column(
            children: [
              // Fixed header
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      _syncScroll(_headerScrollController, _bodyScrollController);
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _headerScrollController,
                    child: Row(
                    children: [
                      _buildHeaderCell('#', 60),
                      _buildHeaderCell('Date', 110),
                      _buildHeaderCell('Initial Balance', 140),
                      _buildHeaderCell('Interest', 120),
                      _buildHeaderCell('Principal', 120),
                      _buildHeaderCell('Payment', 120),
                      _buildHeaderCell('Insurance', 120),
                      _buildHeaderCell('Total', 120),
                      _buildHeaderCell('Final Balance', 150),
                    ],
                    ),
                  ),
                ),
              ),
              // Scrollable rows
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      _syncScroll(_bodyScrollController, _headerScrollController);
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _bodyScrollController,
                    child: SizedBox(
                    width: 1070, // Total width of all columns (60+110+140+120+120+120+120+120+150) + padding
                    child: ListView.builder(
                      itemCount: _getCombinedRowsCount(),
                      itemBuilder: (context, index) {
                        return _buildCombinedRow(context, index);
                      },
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Summary card - Flexible to prevent overflow
        Flexible(
          flex: 0,
          child: _buildSummaryCard(),
        ),
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 6),
          _SummaryItem(
            label: 'Total Amount to Pay',
            value: LoanFormatters.formatCurrency(totalPayments),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  // Create a combined list of installments and early repayments sorted by date
  List<dynamic> _getCombinedRows() {
    final List<dynamic> combinedRows = [];
    
    // Add all installments
    combinedRows.addAll(widget.schedule.installments);
    
    // Add all early repayments
    combinedRows.addAll(widget.loan.earlyRepayments);
    
    // Sort by date
    combinedRows.sort((a, b) {
      final dateA = a is Installment ? a.fecha : (a as EarlyRepayment).fecha;
      final dateB = b is Installment ? b.fecha : (b as EarlyRepayment).fecha;
      return dateA.compareTo(dateB);
    });
    
    return combinedRows;
  }
  
  int _getCombinedRowsCount() {
    return _getCombinedRows().length;
  }
  
  Widget _buildCombinedRow(BuildContext context, int index) {
    final combinedRows = _getCombinedRows();
    final item = combinedRows[index];
    
    if (item is Installment) {
      return _buildInstallmentRow(item, index);
    } else if (item is EarlyRepayment) {
      return _buildEarlyRepaymentRow(item, index);
    }
    
    return const SizedBox.shrink();
  }
  
  Widget _buildInstallmentRow(Installment installment, int index) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: index.isEven 
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(installment.numero.toString(), 60),
          _buildDataCell(LoanFormatters.formatDate(installment.fecha), 110),
          _buildDataCell(LoanFormatters.formatCurrency(installment.saldoInicial), 140, isNumeric: true),
          _buildDataCell(LoanFormatters.formatCurrency(installment.interes), 120, isNumeric: true),
          _buildDataCell(LoanFormatters.formatCurrency(installment.amortizacion), 120, isNumeric: true),
          _buildDataCell(LoanFormatters.formatCurrency(installment.pagoCuota), 120, isNumeric: true),
          _buildDataCell(LoanFormatters.formatCurrency(installment.seguro), 120, isNumeric: true),
          _buildDataCell(
            LoanFormatters.formatCurrency(installment.totalMes), 
            120, 
            isNumeric: true, 
            isBold: true
          ),
          _buildDataCell(LoanFormatters.formatCurrency(installment.saldoFinal), 150, isNumeric: true),
        ],
      ),
    );
  }
  
  Widget _buildEarlyRepaymentRow(EarlyRepayment earlyRepayment, int index) {
    // Calculate the balance at the time of early repayment
    final balanceAtEarlyDate = _getBalanceAtDate(earlyRepayment.fecha);
    final newBalance = balanceAtEarlyDate - earlyRepayment.monto;
    
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
          left: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell('EP', 60, isEarlyPayment: true),
          _buildDataCell(LoanFormatters.formatDate(earlyRepayment.fecha), 110, isEarlyPayment: true),
          _buildDataCell(LoanFormatters.formatCurrency(balanceAtEarlyDate), 140, isNumeric: true, isEarlyPayment: true),
          _buildDataCell('-', 120, isNumeric: true, isEarlyPayment: true), // Interest
          _buildDataCell(LoanFormatters.formatCurrency(earlyRepayment.monto), 120, isNumeric: true, isEarlyPayment: true, isBold: true), // Principal (Early Payment)
          _buildDataCell('-', 120, isNumeric: true, isEarlyPayment: true), // Payment
          _buildDataCell('-', 120, isNumeric: true, isEarlyPayment: true), // Insurance
          _buildDataCell(LoanFormatters.formatCurrency(earlyRepayment.monto), 120, isNumeric: true, isEarlyPayment: true, isBold: true), // Total
          _buildDataCell(LoanFormatters.formatCurrency(newBalance), 150, isNumeric: true, isEarlyPayment: true),
        ],
      ),
    );
  }
  
  // Calculate balance at a specific date
  Decimal _getBalanceAtDate(DateTime targetDate) {
    // Find the last installment before or on the target date
    Installment? lastInstallment;
    for (final installment in widget.schedule.installments) {
      if (installment.fecha.isBefore(targetDate) || installment.fecha.isAtSameMomentAs(targetDate)) {
        lastInstallment = installment;
      } else {
        break;
      }
    }
    
    if (lastInstallment != null) {
      return lastInstallment.saldoFinal;
    } else {
      // If no installment found, return the initial principal
      return widget.loan.principal;
    }
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataCell(String text, double width, {bool isNumeric = false, bool isBold = false, bool isEarlyPayment = false}) {
    return Container(
      width: width,
      height: 52,
      alignment: isNumeric ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: isBold ? FontWeight.bold : null,
          fontSize: 12,
          color: isEarlyPayment ? Theme.of(context).colorScheme.primary : null,
          fontStyle: isEarlyPayment ? FontStyle.italic : null,
        ),
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
