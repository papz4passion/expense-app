import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_list.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter transactions based on search and filters
          var filteredTransactions = provider.transactions;

          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            filteredTransactions = filteredTransactions
                .where(
                  (t) => t.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();
          }

          // Apply category filter
          if (_selectedCategoryId != null) {
            filteredTransactions = filteredTransactions
                .where((t) => t.categoryId == _selectedCategoryId)
                .toList();
          }

          // Apply type filter
          if (_selectedType != null) {
            filteredTransactions = filteredTransactions
                .where((t) => t.type == _selectedType)
                .toList();
          }

          // Apply date range filter
          if (_selectedDateRange != null) {
            filteredTransactions = filteredTransactions
                .where(
                  (t) =>
                      t.date.isAfter(
                        _selectedDateRange!.start.subtract(
                          const Duration(days: 1),
                        ),
                      ) &&
                      t.date.isBefore(
                        _selectedDateRange!.end.add(const Duration(days: 1)),
                      ),
                )
                .toList();
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Filter chips
              if (_hasActiveFilters())
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (_selectedCategoryId != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                provider
                                        .getCategoryById(_selectedCategoryId!)
                                        ?.name ??
                                    'Unknown',
                              ),
                              onSelected: (bool selected) {},
                              onDeleted: () {
                                setState(() {
                                  _selectedCategoryId = null;
                                });
                              },
                              selected: true,
                            ),
                          ),
                        if (_selectedType != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(_selectedType!.name.capitalize()),
                              onSelected: (bool selected) {},
                              onDeleted: () {
                                setState(() {
                                  _selectedType = null;
                                });
                              },
                              selected: true,
                            ),
                          ),
                        if (_selectedDateRange != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(
                                '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                              ),
                              onSelected: (bool selected) {},
                              onDeleted: () {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                              },
                              selected: true,
                            ),
                          ),
                        TextButton(
                          onPressed: _clearAllFilters,
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Transaction List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first transaction to get started',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddTransactionScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Transaction'),
                            ),
                          ],
                        ),
                      )
                    : TransactionList(transactions: filteredTransactions),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategoryId != null ||
        _selectedType != null ||
        _selectedDateRange != null;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedType = null;
      _selectedDateRange = null;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<TransactionProvider>(
        builder: (context, provider, child) => AlertDialog(
          title: const Text('Filter Transactions'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Filter
                const Text('Category'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('All categories'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...provider.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Row(
                          children: [
                            Text(category.icon),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Type Filter
                const Text('Type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<TransactionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('All types'),
                  items: const [
                    DropdownMenuItem<TransactionType>(
                      value: null,
                      child: Text('All types'),
                    ),
                    DropdownMenuItem<TransactionType>(
                      value: TransactionType.expense,
                      child: Text('Expense'),
                    ),
                    DropdownMenuItem<TransactionType>(
                      value: TransactionType.income,
                      child: Text('Income'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date Range Filter
                const Text('Date Range'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDateRange == null
                              ? 'Select date range'
                              : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
