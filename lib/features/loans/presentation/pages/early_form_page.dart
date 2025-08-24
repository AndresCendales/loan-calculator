import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/early_repayment.dart';
import '../../domain/entities/loan.dart';
import '../../domain/services/schedule_calculator.dart';
import '../providers/loans_providers.dart';
import '../../utils/formatters.dart';

class EarlyFormPage extends ConsumerStatefulWidget {
  final String loanId;
  final String? earlyRepaymentId;

  const EarlyFormPage({
    super.key,
    required this.loanId,
    this.earlyRepaymentId,
  });

  @override
  ConsumerState<EarlyFormPage> createState() => _EarlyFormPageState();
}

class _EarlyFormPageState extends ConsumerState<EarlyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();

  DateTime _fecha = DateTime.now();
  EarlyType _tipo = EarlyType.reducePayment;
  bool _isLoading = false;
  EarlyRepayment? _existingEarly;
  Loan? _loan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repository = ref.read(loansRepositoryProvider);
    final loan = await repository.getLoanById(widget.loanId);
    
    if (loan != null) {
      setState(() {
        _loan = loan;
        _fecha = loan.fechaInicio;
      });

      if (widget.earlyRepaymentId != null) {
        final existingEarly = loan.earlyRepayments
            .where((early) => early.id == widget.earlyRepaymentId)
            .firstOrNull;
        
        if (existingEarly != null) {
          setState(() {
            _existingEarly = existingEarly;
            _montoController.text = existingEarly.monto.toString();
            _fecha = existingEarly.fecha;
            _tipo = existingEarly.tipo;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.earlyRepaymentId == null 
              ? 'Add Early Payment' 
              : 'Edit Early Payment',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildImpactPreviewSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Early Payment Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                hintText: 'Enter early payment amount',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Payment amount is required';
                }
                final amount = Decimal.tryParse(value);
                if (amount == null || amount <= Decimal.zero) {
                  return 'Enter a valid amount greater than 0';
                }
                if (amount > _loan!.principal) {
                  return 'Amount cannot exceed loan principal';
                }
                return null;
              },
              onChanged: (value) => setState(() {}), // Trigger rebuild for preview
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Payment Date'),
              subtitle: Text(LoanFormatters.formatDate(_fecha)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            RadioListTile<EarlyType>(
              title: const Text('Reduce Payment Amount'),
              subtitle: const Text('Keep the same loan term, reduce monthly payment'),
              value: EarlyType.reducePayment,
              groupValue: _tipo,
              onChanged: (value) => setState(() => _tipo = value!),
            ),
            RadioListTile<EarlyType>(
              title: const Text('Reduce Loan Term'),
              subtitle: const Text('Keep the same monthly payment, finish loan earlier'),
              value: EarlyType.reduceTerm,
              groupValue: _tipo,
              onChanged: (value) => setState(() => _tipo = value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildImpactContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactContent() {
    final montoText = _montoController.text;
    if (montoText.isEmpty) {
      return const Text('Enter payment amount to see impact');
    }

    final monto = Decimal.tryParse(montoText);
    if (monto == null || monto <= Decimal.zero) {
      return const Text('Enter a valid payment amount');
    }

    try {
      final calculator = const ScheduleCalculator();
      final originalSchedule = calculator.buildInitialSchedule(_loan!);
      
      // Create a temporary early repayment to calculate impact
      final tempEarly = EarlyRepayment(
        id: 'temp',
        fecha: _fecha,
        monto: monto,
        tipo: _tipo,
      );
      
      final newSchedule = calculator.applyEarlyRepayments(
        originalSchedule,
        _loan!,
        [tempEarly],
      );

      return Column(
        children: [
          _buildImpactItem(
            'Original Payment',
            LoanFormatters.formatCurrency(originalSchedule.cuota),
          ),
          _buildImpactItem(
            'New Payment',
            LoanFormatters.formatCurrency(newSchedule.cuota),
          ),
          _buildImpactItem(
            'Original Term',
            '${originalSchedule.installments.length} months',
          ),
          _buildImpactItem(
            'New Term',
            '${newSchedule.installments.length} months',
          ),
          const Divider(),
          _buildImpactItem(
            _tipo == EarlyType.reducePayment ? 'Payment Reduction' : 'Term Reduction',
            _tipo == EarlyType.reducePayment
                ? LoanFormatters.formatCurrency(originalSchedule.cuota - newSchedule.cuota)
                : '${originalSchedule.installments.length - newSchedule.installments.length} months',
            isHighlight: true,
          ),
        ],
      );
    } catch (e) {
      return Text('Error calculating impact: $e');
    }
  }

  Widget _buildImpactItem(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? Theme.of(context).colorScheme.primary : null,
              fontSize: isHighlight ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            onPressed: _isLoading ? null : _saveEarlyRepayment,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.earlyRepaymentId == null ? 'Add' : 'Update'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: _loan!.fechaInicio,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _saveEarlyRepayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final monto = Decimal.parse(_montoController.text);
      
      final earlyRepayment = EarlyRepayment(
        id: _existingEarly?.id ?? const Uuid().v4(),
        fecha: _fecha,
        monto: monto,
        tipo: _tipo,
      );

      final repository = ref.read(loansRepositoryProvider);
      
      if (widget.earlyRepaymentId == null) {
        // Add new early repayment
        await repository.addEarlyRepayment(widget.loanId, earlyRepayment);
      } else {
        // Update existing - remove old and add new
        await repository.removeEarlyRepayment(widget.loanId, widget.earlyRepaymentId!);
        await repository.addEarlyRepayment(widget.loanId, earlyRepayment);
      }

      // Refresh the loan detail
      ref.read(loanDetailProvider(widget.loanId).notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Early payment ${widget.earlyRepaymentId == null ? 'added' : 'updated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save early payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
