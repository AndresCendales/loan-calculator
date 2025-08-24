import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/schedule.dart';
import '../providers/loans_providers.dart';
import '../../utils/formatters.dart';

class InsuranceEditorPage extends ConsumerStatefulWidget {
  final String loanId;

  const InsuranceEditorPage({super.key, required this.loanId});

  @override
  ConsumerState<InsuranceEditorPage> createState() => _InsuranceEditorPageState();
}

class _InsuranceEditorPageState extends ConsumerState<InsuranceEditorPage> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, Decimal?> _overrides = {};
  bool _isLoading = false;
  Loan? _loan;
  Schedule? _schedule;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loanDetailAsync = ref.read(loanDetailProvider(widget.loanId));
    final data = loanDetailAsync.value;
    
    if (data != null) {
      final (loan, schedule) = data;
      setState(() {
        _loan = loan;
        _schedule = schedule;
        _overrides.addAll(loan.seguroConfig.perInstallmentOverrides);
        
        // Initialize controllers for existing overrides
        for (final entry in loan.seguroConfig.perInstallmentOverrides.entries) {
          final controller = TextEditingController(text: entry.value.toString());
          _controllers[entry.key] = controller;
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loan == null || _schedule == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Editor'),
        actions: [
          TextButton(
            onPressed: _clearAllOverrides,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInstructionsCard(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _schedule!.installments.length,
              itemBuilder: (context, index) {
                final installment = _schedule!.installments[index];
                return _buildInstallmentCard(installment);
              },
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
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
            'Insurance Override Instructions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Enter a custom insurance amount for specific installments\n'
            '• Leave empty to use the default calculation\n'
            '• Changes will recalculate the total payment for each installment',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentCard(installment) {
    final installmentNumber = installment.numero;
    final hasOverride = _overrides.containsKey(installmentNumber);
    
    // Get or create controller for this installment
    if (!_controllers.containsKey(installmentNumber)) {
      _controllers[installmentNumber] = TextEditingController();
    }
    final controller = _controllers[installmentNumber]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: hasOverride 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: hasOverride 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  radius: 20,
                  child: Text(
                    installmentNumber.toString(),
                    style: TextStyle(
                      color: hasOverride ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LoanFormatters.formatDate(installment.fecha),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Default: ${LoanFormatters.formatCurrency(installment.seguro)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Custom Insurance Amount',
                hintText: 'Enter custom amount or leave empty for default',
                prefixText: '\$ ',
                suffixIcon: hasOverride
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _clearOverride(installmentNumber),
                      )
                    : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) => _updateOverride(installmentNumber, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveOverrides,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateOverride(int installmentNumber, String value) {
    if (value.trim().isEmpty) {
      _overrides.remove(installmentNumber);
    } else {
      final amount = Decimal.tryParse(value);
      if (amount != null && amount >= Decimal.zero) {
        _overrides[installmentNumber] = amount;
      }
    }
  }

  void _clearOverride(int installmentNumber) {
    setState(() {
      _overrides.remove(installmentNumber);
      _controllers[installmentNumber]?.clear();
    });
  }

  void _clearAllOverrides() {
    setState(() {
      _overrides.clear();
      for (final controller in _controllers.values) {
        controller.clear();
      }
    });
  }

  Future<void> _saveOverrides() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(loansRepositoryProvider);
      
      // Update insurance config with new overrides
      final updatedConfig = _loan!.seguroConfig.copyWith(
        perInstallmentOverrides: Map<int, Decimal>.from(_overrides),
      );
      
      await repository.updateInsuranceConfig(widget.loanId, updatedConfig);
      
      // Refresh the loan detail
      ref.read(loanDetailProvider(widget.loanId).notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insurance overrides saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save overrides: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
