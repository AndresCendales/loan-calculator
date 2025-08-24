import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/insurance_config.dart';
import '../../domain/services/schedule_calculator.dart';
import '../providers/loans_providers.dart';
import '../../utils/formatters.dart';

class LoanFormPage extends ConsumerStatefulWidget {
  final String? loanId;

  const LoanFormPage({super.key, this.loanId});

  @override
  ConsumerState<LoanFormPage> createState() => _LoanFormPageState();
}

class _LoanFormPageState extends ConsumerState<LoanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _principalController = TextEditingController();
  final _plazoController = TextEditingController();
  final _teaController = TextEditingController();
  final _flatInsuranceController = TextEditingController();
  final _percentInsuranceController = TextEditingController();

  bool _isYears = false;
  DateTime _fechaInicio = DateTime.now();
  InsuranceMode _insuranceMode = InsuranceMode.none;
  bool _isLoading = false;
  Loan? _existingLoan;

  @override
  void initState() {
    super.initState();
    _loadExistingLoan();
  }

  Future<void> _loadExistingLoan() async {
    if (widget.loanId != null) {
      final repository = ref.read(loansRepositoryProvider);
      final loan = await repository.getLoanById(widget.loanId!);
      if (loan != null) {
        setState(() {
          _existingLoan = loan;
          _tituloController.text = loan.titulo;
          _principalController.text = loan.principal.toString();
          _plazoController.text = loan.plazoMeses.toString();
          _teaController.text = (loan.tea * Decimal.fromInt(100)).toString();
          _fechaInicio = loan.fechaInicio;
          _insuranceMode = loan.seguroConfig.mode;
          
          if (loan.seguroConfig.flatAmountPerMonth != null) {
            _flatInsuranceController.text = 
                loan.seguroConfig.flatAmountPerMonth.toString();
          }
          
          if (loan.seguroConfig.monthlyPercentOfBalance != null) {
            _percentInsuranceController.text = 
                (loan.seguroConfig.monthlyPercentOfBalance! * Decimal.fromInt(100)).toString();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _principalController.dispose();
    _plazoController.dispose();
    _teaController.dispose();
    _flatInsuranceController.dispose();
    _percentInsuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loanId == null ? 'Create Loan' : 'Edit Loan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildInsuranceSection(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
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
              'Loan Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Loan Title',
                hintText: 'Enter loan title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _principalController,
              decoration: const InputDecoration(
                labelText: 'Principal Amount',
                hintText: 'Enter principal amount',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Principal amount is required';
                }
                final amount = Decimal.tryParse(value);
                if (amount == null || amount <= Decimal.zero) {
                  return 'Enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _plazoController,
                    decoration: const InputDecoration(
                      labelText: 'Term',
                      hintText: 'Enter term',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Term is required';
                      }
                      final term = int.tryParse(value);
                      if (term == null || term <= 0) {
                        return 'Enter a valid term';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<bool>(
                  value: _isYears,
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Months')),
                    DropdownMenuItem(value: true, child: Text('Years')),
                  ],
                  onChanged: (value) => setState(() => _isYears = value ?? false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teaController,
              decoration: const InputDecoration(
                labelText: 'Annual Interest Rate (TEA)',
                hintText: 'Enter annual interest rate',
                suffixText: '%',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'TEA is required';
                }
                final tea = Decimal.tryParse(value);
                if (tea == null || tea < Decimal.zero || tea > Decimal.fromInt(200)) {
                  return 'Enter a valid TEA between 0% and 200%';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date'),
              subtitle: Text(LoanFormatters.formatDate(_fechaInicio)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insurance Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InsuranceMode>(
              value: _insuranceMode,
              decoration: const InputDecoration(
                labelText: 'Insurance Type',
              ),
              items: const [
                DropdownMenuItem(
                  value: InsuranceMode.none,
                  child: Text('No Insurance'),
                ),
                DropdownMenuItem(
                  value: InsuranceMode.flat,
                  child: Text('Fixed Monthly Amount'),
                ),
                DropdownMenuItem(
                  value: InsuranceMode.percentOfBalance,
                  child: Text('Percentage of Balance'),
                ),
              ],
              onChanged: (value) {
                setState(() => _insuranceMode = value ?? InsuranceMode.none);
              },
            ),
            if (_insuranceMode == InsuranceMode.flat) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _flatInsuranceController,
                decoration: const InputDecoration(
                  labelText: 'Fixed Monthly Insurance',
                  hintText: 'Enter fixed monthly amount',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (_insuranceMode == InsuranceMode.flat &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Fixed insurance amount is required';
                  }
                  if (value != null && value.isNotEmpty) {
                    final amount = Decimal.tryParse(value);
                    if (amount == null || amount < Decimal.zero) {
                      return 'Enter a valid amount';
                    }
                  }
                  return null;
                },
              ),
            ],
            if (_insuranceMode == InsuranceMode.percentOfBalance) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentInsuranceController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Percentage of Balance',
                  hintText: 'Enter percentage (e.g., 0.1 for 0.1%)',
                  suffixText: '%',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                ],
                validator: (value) {
                  if (_insuranceMode == InsuranceMode.percentOfBalance &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Insurance percentage is required';
                  }
                  if (value != null && value.isNotEmpty) {
                    final percentage = Decimal.tryParse(value);
                    if (percentage == null || percentage < Decimal.zero) {
                      return 'Enter a valid percentage';
                    }
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildPreviewContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    try {
      final principal = Decimal.tryParse(_principalController.text);
      final plazoInput = int.tryParse(_plazoController.text);
      final teaInput = Decimal.tryParse(_teaController.text);

      if (principal == null || plazoInput == null || teaInput == null) {
        return const Text('Enter loan details to see preview');
      }

      final plazoMeses = _isYears ? plazoInput * 12 : plazoInput;
      final tea = Decimal.parse((teaInput.toDouble() / 100).toString());

      final calculator = const ScheduleCalculator();
      final monthlyRate = calculator.monthlyRateFromTea(tea);
      final fixedPayment = calculator.computeFixedInstallment(
        principal,
        monthlyRate,
        plazoMeses,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewItem('Monthly Payment', LoanFormatters.formatCurrency(fixedPayment)),
          _buildPreviewItem('Total Term', '$plazoMeses months'),
          _buildPreviewItem('Monthly Rate (TEM)', LoanFormatters.formatPercentage(monthlyRate)),
        ],
      );
    } catch (e) {
      return const Text('Invalid loan parameters');
    }
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
            onPressed: _isLoading ? null : _saveLoan,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.loanId == null ? 'Create' : 'Update'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _fechaInicio = picked);
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final principal = Decimal.parse(_principalController.text);
      final plazoInput = int.parse(_plazoController.text);
      final plazoMeses = _isYears ? plazoInput * 12 : plazoInput;
      final tea = Decimal.parse((double.parse(_teaController.text) / 100).toString());

      // Build insurance config
      InsuranceConfig insuranceConfig;
      switch (_insuranceMode) {
        case InsuranceMode.none:
          insuranceConfig = const InsuranceConfig(mode: InsuranceMode.none);
          break;
        case InsuranceMode.flat:
          insuranceConfig = InsuranceConfig(
            mode: InsuranceMode.flat,
            flatAmountPerMonth: Decimal.parse(_flatInsuranceController.text),
          );
          break;
        case InsuranceMode.percentOfBalance:
          insuranceConfig = InsuranceConfig(
            mode: InsuranceMode.percentOfBalance,
            monthlyPercentOfBalance: 
                Decimal.parse((double.parse(_percentInsuranceController.text) / 100).toString()),
          );
          break;
      }

      final loan = Loan(
        id: _existingLoan?.id ?? const Uuid().v4(),
        titulo: _tituloController.text.trim(),
        principal: principal,
        plazoMeses: plazoMeses,
        tea: tea,
        fechaInicio: _fechaInicio,
        seguroConfig: insuranceConfig,
        earlyRepayments: _existingLoan?.earlyRepayments ?? [],
      );

      if (widget.loanId == null) {
        await ref.read(loansListProvider.notifier).createLoan(loan);
      } else {
        await ref.read(loansListProvider.notifier).updateLoan(loan);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loan ${widget.loanId == null ? 'created' : 'updated'} successfully',
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
            content: Text('Failed to save loan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
