import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/early_repayment.dart';
import '../../domain/services/schedule_calculator.dart';
import '../../utils/formatters.dart';
import '../providers/loans_providers.dart';

class EarlyRepaymentsTab extends ConsumerWidget {
  final Loan loan;

  const EarlyRepaymentsTab({super.key, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${loan.earlyRepayments.length} early payments',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/loan/${loan.id}/early/create'),
                icon: const Icon(Icons.add),
                label: const Text('Add Early Payment'),
              ),
            ],
          ),
        ),
        // Savings summary section
        if (loan.earlyRepayments.isNotEmpty) _buildSavingsSummary(context),
        Expanded(
          child: loan.earlyRepayments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.payment_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No early payments yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add an early payment to reduce your loan term or payment amount',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: loan.earlyRepayments.length,
                  itemBuilder: (context, index) {
                    final earlyRepayment = loan.earlyRepayments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTypeColor(earlyRepayment.tipo),
                          child: Icon(
                            _getTypeIcon(earlyRepayment.tipo),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          LoanFormatters.formatCurrency(earlyRepayment.monto),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(LoanFormatters.formatDate(earlyRepayment.fecha)),
                            Text(
                              _getTypeDescription(earlyRepayment.tipo),
                              style: TextStyle(
                                color: _getTypeColor(earlyRepayment.tipo),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: const Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                context.go('/loan/${loan.id}/early/${earlyRepayment.id}/edit');
                                break;
                              case 'delete':
                                _showDeleteDialog(context, ref, earlyRepayment);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSavingsSummary(BuildContext context) {
    final calculator = const ScheduleCalculator();
    
    // Calculate original schedule without early repayments
    final originalSchedule = calculator.buildInitialSchedule(loan.copyWith(earlyRepayments: []));
    
    // Calculate current schedule with early repayments
    final currentSchedule = calculator.applyEarlyRepayments(originalSchedule, loan, loan.earlyRepayments);
    
    // Calculate savings based on remaining payments from the earliest early repayment date
    final earliestEarlyDate = loan.earlyRepayments.isNotEmpty 
        ? loan.earlyRepayments.map((e) => e.fecha).reduce((a, b) => a.isBefore(b) ? a : b)
        : loan.fechaInicio;
    
    // Find the installment index for the earliest early repayment
    final earlyInstallmentIndex = calculator.mapDateToInstallmentIndex(loan.fechaInicio, earliestEarlyDate);
    
    // Calculate what would have been paid from the early repayment date onwards (without early repayments)
    final originalRemainingTotal = originalSchedule.installments
        .where((installment) => installment.numero > earlyInstallmentIndex)
        .fold(Decimal.zero, (sum, installment) => sum + installment.totalMes);
    
    // Calculate what will actually be paid from now on (with early repayments)
    final currentRemainingTotal = currentSchedule.installments
        .where((installment) => installment.numero > earlyInstallmentIndex)
        .fold(Decimal.zero, (sum, installment) => sum + installment.totalMes);
    
    final moneySaved = originalRemainingTotal - currentRemainingTotal;
    final timeSaved = originalSchedule.installments
        .where((installment) => installment.numero > earlyInstallmentIndex).length - 
        currentSchedule.installments
        .where((installment) => installment.numero > earlyInstallmentIndex).length;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Savings Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SavingsItem(
                  icon: Icons.attach_money,
                  label: 'Money Saved',
                  value: LoanFormatters.formatCurrency(moneySaved),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              Expanded(
                child: _SavingsItem(
                  icon: Icons.schedule,
                  label: 'Time Saved',
                  value: '$timeSaved months',
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(EarlyType type) {
    switch (type) {
      case EarlyType.reducePayment:
        return Colors.blue;
      case EarlyType.reduceTerm:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(EarlyType type) {
    switch (type) {
      case EarlyType.reducePayment:
        return Icons.trending_down;
      case EarlyType.reduceTerm:
        return Icons.schedule;
    }
  }

  String _getTypeDescription(EarlyType type) {
    switch (type) {
      case EarlyType.reducePayment:
        return 'Reduce Payment Amount';
      case EarlyType.reduceTerm:
        return 'Reduce Loan Term';
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    EarlyRepayment earlyRepayment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Early Payment'),
        content: Text(
          'Are you sure you want to delete the early payment of '
          '${LoanFormatters.formatCurrency(earlyRepayment.monto)}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(loansRepositoryProvider);
        await repository.removeEarlyRepayment(loan.id, earlyRepayment.id);
        
        // Refresh the loan detail
        ref.read(loanDetailProvider(loan.id).notifier).refresh();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Early payment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete early payment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _SavingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SavingsItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
