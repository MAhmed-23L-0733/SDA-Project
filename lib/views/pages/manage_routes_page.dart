import 'package:flutter/material.dart';
import 'package:flutter_template/models/admin_model.dart';
import 'package:flutter_template/models/routes_model.dart';
import 'package:intl/intl.dart';

class ManageRoutesPage extends StatefulWidget {
  const ManageRoutesPage({super.key});

  @override
  State<ManageRoutesPage> createState() => _ManageRoutesPageState();
}

class _ManageRoutesPageState extends State<ManageRoutesPage> {
  List<Routes> _routes = [];
  List<Routes> _filteredRoutes = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _sortOption =
      'date_newest'; // date_newest, date_oldest, name_az, name_za

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _timeController = TextEditingController();
  final _economyTicketsController = TextEditingController();
  final _businessTicketsController = TextEditingController();
  final _firstTicketsController = TextEditingController();
  final _economyPriceController = TextEditingController();
  final _businessPriceController = TextEditingController();
  final _firstPriceController = TextEditingController();
  DateTime? _selectedDate;
  Routes? _editingRoute;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _timeController.dispose();
    _economyTicketsController.dispose();
    _businessTicketsController.dispose();
    _firstTicketsController.dispose();
    _economyPriceController.dispose();
    _businessPriceController.dispose();
    _firstPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final routesData = await Admin.getAllRoutes();
      if (mounted) {
        setState(() {
          _routes = routesData.map((json) => Routes.fromJson(json)).toList();
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Routes> filtered = List.from(_routes);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((route) {
        final origin = route.origin?.toLowerCase() ?? '';
        final destination = route.destination?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return origin.contains(query) || destination.contains(query);
      }).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'date_newest':
        filtered.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
        break;
      case 'date_oldest':
        filtered.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.date!.compareTo(b.date!);
        });
        break;
      case 'name_az':
        filtered.sort((a, b) {
          final aName = '${a.origin ?? ''} ${a.destination ?? ''}';
          final bName = '${b.origin ?? ''} ${b.destination ?? ''}';
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        });
        break;
      case 'name_za':
        filtered.sort((a, b) {
          final aName = '${a.origin ?? ''} ${a.destination ?? ''}';
          final bName = '${b.origin ?? ''} ${b.destination ?? ''}';
          return bName.toLowerCase().compareTo(aName.toLowerCase());
        });
        break;
    }

    setState(() {
      _filteredRoutes = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onSortChanged(String? newSort) {
    if (newSort != null) {
      setState(() {
        _sortOption = newSort;
      });
      _applyFilters();
    }
  }

  void _clearForm() {
    _originController.clear();
    _destinationController.clear();
    _timeController.clear();
    _economyTicketsController.clear();
    _businessTicketsController.clear();
    _firstTicketsController.clear();
    _economyPriceController.clear();
    _businessPriceController.clear();
    _firstPriceController.clear();
    setState(() {
      _selectedDate = null;
      _editingRoute = null;
    });
  }

  void _editRoute(Routes route) {
    setState(() {
      _editingRoute = route;
      _originController.text = route.origin ?? '';
      _destinationController.text = route.destination ?? '';
      _timeController.text = route.time ?? '';
      _selectedDate = route.date;
      // Note: For editing, we only allow updating prices, not ticket quantities
      // Leave ticket quantity fields empty
      _economyTicketsController.clear();
      _businessTicketsController.clear();
      _firstTicketsController.clear();
      // Prices can be set to defaults or left empty for admin to input
      _economyPriceController.clear();
      _businessPriceController.clear();
      _firstPriceController.clear();
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    // Simple way to show form is ready
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form ready for editing. Scroll up to see the form.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (_editingRoute != null) {
        // Update existing route with prices
        await Admin.updateRoute(
          routeId: _editingRoute!.id!,
          origin: _originController.text.trim(),
          destination: _destinationController.text.trim(),
          date: _selectedDate!,
          time: _timeController.text.trim(),
          economyPrice: double.parse(_economyPriceController.text.trim()),
          businessPrice: double.parse(_businessPriceController.text.trim()),
          firstPrice: double.parse(_firstPriceController.text.trim()),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Route updated successfully'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new route with tickets and prices
        await Admin.addRoute(
          origin: _originController.text.trim(),
          destination: _destinationController.text.trim(),
          date: _selectedDate!,
          time: _timeController.text.trim(),
          economyTickets: int.parse(_economyTicketsController.text.trim()),
          businessTickets: int.parse(_businessTicketsController.text.trim()),
          firstTickets: int.parse(_firstTicketsController.text.trim()),
          economyPrice: double.parse(_economyPriceController.text.trim()),
          businessPrice: double.parse(_businessPriceController.text.trim()),
          firstPrice: double.parse(_firstPriceController.text.trim()),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Route added successfully'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      _clearForm();
      await _loadRoutes();
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

  Future<void> _deleteRoute(Routes route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Route'),
        content: Text(
          'Are you sure you want to delete this route?\n\n${route.origin} → ${route.destination}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Admin.deleteRoute(route.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Route deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadRoutes();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadRoutes,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add/Edit Route Form
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _editingRoute != null
                                  ? 'Edit Route'
                                  : 'Add New Route',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            if (_editingRoute != null)
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: _clearForm,
                                tooltip: 'Cancel Edit',
                              ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _originController,
                          decoration: InputDecoration(
                            labelText: 'Origin',
                            hintText: 'Enter origin city',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter origin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _destinationController,
                          decoration: InputDecoration(
                            labelText: 'Destination',
                            hintText: 'Enter destination city',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter destination';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _selectedDate != null
                                  ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_selectedDate!)
                                  : 'Select date',
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? theme.textTheme.bodyLarge?.color
                                    : theme.hintColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _timeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Time',
                            hintText: 'Select time',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onTap: () => _selectTime(context),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select time';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Ticket Quantities Section (only for adding, not editing)
                        if (_editingRoute == null) ...[
                          Text(
                            'Ticket Quantities',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _economyTicketsController,
                                  decoration: InputDecoration(
                                    labelText: 'Economy Tickets',
                                    hintText: '0',
                                    prefixIcon: Icon(
                                      Icons.airline_seat_recline_normal,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _businessTicketsController,
                                  decoration: InputDecoration(
                                    labelText: 'Business Tickets',
                                    hintText: '0',
                                    prefixIcon: Icon(Icons.business_center),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _firstTicketsController,
                                  decoration: InputDecoration(
                                    labelText: 'First Class Tickets',
                                    hintText: '0',
                                    prefixIcon: Icon(Icons.star),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Invalid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],

                        // Ticket Prices Section (for both adding and editing)
                        Text(
                          'Ticket Prices',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _economyPriceController,
                                decoration: InputDecoration(
                                  labelText: 'Economy Price (PKR)',
                                  hintText: '0.00',
                                  prefixText: 'PKR ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _businessPriceController,
                                decoration: InputDecoration(
                                  labelText: 'Business Price (PKR)',
                                  hintText: '0.00',
                                  prefixText: 'PKR ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _firstPriceController,
                                decoration: InputDecoration(
                                  labelText: 'First Class Price (PKR)',
                                  hintText: '0.00',
                                  prefixText: 'PKR ',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _editingRoute != null
                                  ? 'Update Route'
                                  : 'Add Route',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Search and Filter Section
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search routes by origin or destination...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _sortOption,
                      onChanged: _onSortChanged,
                      decoration: InputDecoration(
                        labelText: 'Sort By',
                        prefixIcon: Icon(Icons.sort),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'date_newest',
                          child: Text('Date: Newest'),
                        ),
                        DropdownMenuItem(
                          value: 'date_oldest',
                          child: Text('Date: Oldest'),
                        ),
                        DropdownMenuItem(
                          value: 'name_az',
                          child: Text('Name: A-Z'),
                        ),
                        DropdownMenuItem(
                          value: 'name_za',
                          child: Text('Name: Z-A'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Routes List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Routes (${_filteredRoutes.length})',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _loadRoutes,
                    tooltip: 'Refresh',
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Routes List
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRoutes,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_routes.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.route,
                          size: 64,
                          color: Color.fromRGBO(
                            theme.colorScheme.primary.red,
                            theme.colorScheme.primary.green,
                            theme.colorScheme.primary.blue,
                            0.3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No routes available',
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
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _filteredRoutes.length,
                  itemBuilder: (context, index) {
                    final route = _filteredRoutes[index];
                    return _buildRouteCard(route, theme);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(Routes route, ThemeData theme) {
    final formattedDate = route.date != null
        ? DateFormat('MMM dd, yyyy').format(route.date!)
        : 'N/A';

    // Format time to show AM/PM without seconds
    String formattedTime = 'N/A';
    if (route.time != null && route.time!.isNotEmpty) {
      try {
        // Parse the time string (format like "14:30:00" or "14:30")
        final parts = route.time!.split(':');
        if (parts.isNotEmpty) {
          int hour = int.parse(parts[0]);
          int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

          // Convert to 12-hour format with AM/PM
          final period = hour >= 12 ? 'PM' : 'AM';
          hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          formattedTime =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      } catch (e) {
        formattedTime = route.time ?? 'N/A';
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Route Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${route.origin} → ${route.destination}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editRoute(route),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteRoute(route),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
