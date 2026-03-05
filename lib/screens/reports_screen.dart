import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/transaction_service.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TransactionService _transactionService = TransactionService();
  Map<String, double> _categoryExpenses = {};
  double _totalIncome = 0;
  double _totalExpenses = 0;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _transactionService.getAllTransactions();
    
    // Filter transactions for selected month
    final filteredTransactions = transactions.where((transaction) {
      final date = DateTime.parse(transaction['date']);
      return date.year == _selectedMonth.year && date.month == _selectedMonth.month;
    }).toList();

    double income = 0;
    double expenses = 0;
    Map<String, double> categoryExpenses = {};

    for (var transaction in filteredTransactions) {
      final amount = (transaction['amount'] as num).toDouble();
      if (transaction['type'] == 'income') {
        income += amount;
      } else {
        expenses += amount;
        
        // Group by category for expenses
        final categoryId = transaction['categoryId'] as int?;
        final category = CategoryService.getCategoryById(categoryId ?? 1);
        final categoryName = category?.name ?? 'Other';
        
        categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + amount;
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpenses = expenses;
      _categoryExpenses = categoryExpenses;
    });
  }

  Widget _buildIncomeExpenseChart() {
    if (_totalIncome == 0 && _totalExpenses == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No data for this month'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [_totalIncome, _totalExpenses].reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Income');
                            case 1:
                              return const Text('Expenses');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: _totalIncome,
                          color: Colors.green,
                          width: 60,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: _totalExpenses,
                          color: Colors.red,
                          width: 60,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '\$${_totalIncome.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Income'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${_totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text('Expenses'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${(_totalIncome - _totalExpenses).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (_totalIncome - _totalExpenses) >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const Text('Net'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryExpensesChart() {
    if (_categoryExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    List<PieChartSectionData> sections = [];
    int colorIndex = 0;
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];

    _categoryExpenses.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '\$${amount.toStringAsFixed(0)}',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...(_categoryExpenses.entries.map((entry) {
              final colorIndex = _categoryExpenses.keys.toList().indexOf(entry.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: colors[colorIndex % colors.length],
                    ),
                    const SizedBox(width: 8),
                    Text(entry.key),
                    const Spacer(),
                    Text('\$${entry.value.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  _selectedMonth = picked;
                });
                _loadData();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildIncomeExpenseChart(),
            const SizedBox(height: 16),
            _buildCategoryExpensesChart(),
          ],
        ),
      ),
    );
  }
}
