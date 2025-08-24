import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/loans_providers.dart';
import '../widgets/payment_schedule_tab.dart';
import '../widgets/early_repayments_tab.dart';
import '../widgets/insurance_overrides_tab.dart';
import '../../utils/formatters.dart';

class LoanDetailPage extends ConsumerWidget {
  final String loanId;

  const LoanDetailPage({super.key, required this.loanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanDetailAsync = ref.watch(loanDetailProvider(loanId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        actions: [
          IconButton(
            onPressed: () => context.go('/loan/$loanId/edit'),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => ref.read(loanDetailProvider(loanId).notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loanDetailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(loanDetailProvider(loanId).notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data == null) {
            return const Center(
              child: Text('Loan not found'),
            );
          }

          final (loan, schedule) = data;

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                _buildLoanHeader(context, loan, schedule),
                const TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.table_chart),
                      text: 'Payment Schedule',
                    ),
                    Tab(
                      icon: Icon(Icons.payment),
                      text: 'Early Payments',
                    ),
                    Tab(
                      icon: Icon(Icons.security),
                      text: 'Insurance',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      PaymentScheduleTab(loan: loan, schedule: schedule),
                      EarlyRepaymentsTab(loan: loan),
                      InsuranceOverridesTab(loan: loan, schedule: schedule),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoanHeader(BuildContext context, loan, schedule) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loan.titulo,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HeaderItem(
                  label: 'Principal',
                  value: LoanFormatters.formatCurrency(loan.principal),
                ),
              ),
              Expanded(
                child: _HeaderItem(
                  label: 'Current Payment',
                  value: LoanFormatters.formatCurrency(schedule.cuota),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _HeaderItem(
                  label: 'Term',
                  value: '${loan.plazoMeses} months',
                ),
              ),
              Expanded(
                child: _HeaderItem(
                  label: 'TEA',
                  value: LoanFormatters.formatPercentage(loan.tea),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _HeaderItem(
                  label: 'Start Date',
                  value: LoanFormatters.formatDate(loan.fechaInicio),
                ),
              ),
              Expanded(
                child: _HeaderItem(
                  label: 'Recalculations',
                  value: '${schedule.recalculos}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderItem extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderItem({
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
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
