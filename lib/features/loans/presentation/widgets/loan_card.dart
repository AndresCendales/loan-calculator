import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/loan.dart';
import '../../domain/services/schedule_calculator.dart';
import '../../utils/formatters.dart';

class LoanCard extends ConsumerWidget {
  final Loan loan;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LoanCard({
    super.key,
    required this.loan,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculator = const ScheduleCalculator();
    final monthlyRate = calculator.monthlyRateFromTea(loan.tea);
    final fixedPayment = calculator.computeFixedInstallment(
      loan.principal,
      monthlyRate,
      loan.plazoMeses,
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      loan.titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: const Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
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
                        case 'view':
                          onTap?.call();
                          break;
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Principal',
                      value: LoanFormatters.formatCurrency(loan.principal),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Term',
                      value: '${loan.plazoMeses} months',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'TEA',
                      value: LoanFormatters.formatPercentage(loan.tea),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Monthly Payment',
                      value: LoanFormatters.formatCurrency(fixedPayment),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      label: 'Start Date',
                      value: LoanFormatters.formatDate(loan.fechaInicio),
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      label: 'Early Payments',
                      value: '${loan.earlyRepayments.length}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
