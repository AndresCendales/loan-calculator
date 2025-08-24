import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/insurance_config.dart';
import '../../utils/formatters.dart';

class InsuranceOverridesTab extends ConsumerWidget {
  final Loan loan;
  final Schedule schedule;

  const InsuranceOverridesTab({
    super.key,
    required this.loan,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildInsuranceConfigCard(context),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Insurance per Installment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/loan/${loan.id}/insurance'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Overrides'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: schedule.installments.length,
            itemBuilder: (context, index) {
              final installment = schedule.installments[index];
              final hasOverride = loan.seguroConfig.perInstallmentOverrides
                  .containsKey(installment.numero);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: hasOverride 
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasOverride 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    child: Text(
                      installment.numero.toString(),
                      style: TextStyle(
                        color: hasOverride ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(LoanFormatters.formatDate(installment.fecha)),
                      Text(
                        LoanFormatters.formatCurrency(installment.seguro),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hasOverride 
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ],
                  ),
                  subtitle: hasOverride
                      ? Text(
                          'Custom override applied',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(_getInsuranceCalculationText()),
                  trailing: hasOverride 
                      ? Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsuranceConfigCard(BuildContext context) {
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
            'Insurance Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildConfigItem('Type', _getInsuranceModeText()),
          if (loan.seguroConfig.mode == InsuranceMode.flat)
            _buildConfigItem(
              'Fixed Amount',
              LoanFormatters.formatCurrency(
                loan.seguroConfig.flatAmountPerMonth ?? Decimal.zero,
              ),
            ),
          if (loan.seguroConfig.mode == InsuranceMode.percentOfBalance)
            _buildConfigItem(
              'Percentage',
              LoanFormatters.formatPercentage(
                loan.seguroConfig.monthlyPercentOfBalance ?? Decimal.zero,
              ),
            ),
          _buildConfigItem(
            'Overrides',
            '${loan.seguroConfig.perInstallmentOverrides.length} installments',
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getInsuranceModeText() {
    switch (loan.seguroConfig.mode) {
      case InsuranceMode.none:
        return 'No Insurance';
      case InsuranceMode.flat:
        return 'Fixed Monthly Amount';
      case InsuranceMode.percentOfBalance:
        return 'Percentage of Balance';
    }
  }

  String _getInsuranceCalculationText() {
    switch (loan.seguroConfig.mode) {
      case InsuranceMode.none:
        return 'No insurance';
      case InsuranceMode.flat:
        return 'Fixed amount';
      case InsuranceMode.percentOfBalance:
        return 'Calculated from balance';
    }
  }
}
