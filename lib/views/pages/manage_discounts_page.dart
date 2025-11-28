import 'package:flutter/material.dart';
import 'package:flutter_template/models/discount_model.dart';
import 'package:intl/intl.dart';

class ManageDiscountsPage extends StatefulWidget {
  const ManageDiscountsPage({super.key});

  @override
  State<ManageDiscountsPage> createState() => _ManageDiscountsPageState();
}

class _ManageDiscountsPageState extends State<ManageDiscountsPage> {
  List<Discount> _discounts = [];
  bool _isLoading = true;
  String? _error;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _loadDiscounts();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscounts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final discounts = await Discount.getAllDiscounts();
      if (!mounted) return;

      setState(() {
        _discounts = discounts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _codeController.clear();
    _valueController.clear();
    setState(() {
      _selectedExpiryDate = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedExpiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an expiry date'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      try {
        final value = int.parse(_valueController.text);

        await Discount.addDiscount(
          code: _codeController.text.toUpperCase(),
          value: value,
          expiryDate: _selectedExpiryDate!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Discount code added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
          _loadDiscounts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteDiscount(Discount discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Discount'),
        content: Text(
          'Are you sure you want to delete discount code "${discount.code}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && discount.id != null) {
      try {
        await Discount.deleteDiscount(discount.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Discount deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDiscounts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickExpiryDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedExpiryDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading discounts',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(_error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDiscounts,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manage Discounts',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: _loadDiscounts,
                        icon: Icon(Icons.refresh),
                        color: theme.colorScheme.primary,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Add Discount Form
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Discount',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Code and Value Row
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _codeController,
                                  decoration: InputDecoration(
                                    labelText: 'Discount Code',
                                    hintText: 'e.g., SUMMER2025',
                                    prefixIcon: Icon(Icons.confirmation_number),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Code is required';
                                    }
                                    if (value.length < 3) {
                                      return 'Code must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _valueController,
                                  decoration: InputDecoration(
                                    labelText: 'Discount %',
                                    hintText: '0-100',
                                    prefixIcon: Icon(Icons.percent),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final intValue = int.tryParse(value);
                                    if (intValue == null) {
                                      return 'Invalid';
                                    }
                                    if (intValue < 1 || intValue > 100) {
                                      return '1-100';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Expiry Date
                          InkWell(
                            onTap: _pickExpiryDate,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Expiry Date',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _selectedExpiryDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(_selectedExpiryDate!)
                                    : 'Select expiry date',
                                style: TextStyle(
                                  color: _selectedExpiryDate != null
                                      ? theme.textTheme.bodyLarge?.color
                                      : theme.textTheme.bodyMedium?.color
                                            ?.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _clearForm,
                                child: Text('Clear'),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: Icon(Icons.add),
                                label: Text('Add Discount'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Discounts List
                  Text(
                    'All Discounts (${_discounts.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  SizedBox(height: 12),

                  _discounts.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.discount_outlined,
                                  size: 60,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No discounts available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _discounts.length,
                          itemBuilder: (context, index) {
                            final discount = _discounts[index];
                            final isExpired =
                                discount.expiryDate != null &&
                                discount.expiryDate!.isBefore(DateTime.now());

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[850] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isExpired
                                    ? Border.all(
                                        color: const Color.fromRGBO(255, 0, 0, 0.3),
                                        width: 1,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromRGBO(0, 0, 0, 0.05),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isExpired
                                        ? const Color.fromRGBO(255, 0, 0, 0.1)
                                        : const Color.fromRGBO(0, 255, 0, 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isExpired ? Icons.cancel : Icons.discount,
                                    color: isExpired
                                        ? Colors.red
                                        : Colors.green,
                                    size: 28,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      discount.code ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${discount.value}% OFF',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    if (isExpired) ...[
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(255, 0, 0, 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'EXPIRED',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Expires: ${discount.expiryDate != null ? DateFormat('MMM dd, yyyy').format(discount.expiryDate!) : 'N/A'}',
                                    style: TextStyle(
                                      color: isExpired
                                          ? Colors.red
                                          : theme.textTheme.bodyMedium?.color
                                                ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () => _deleteDiscount(discount),
                                  icon: Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  tooltip: 'Delete',
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
