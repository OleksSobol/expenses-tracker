// lib/screens/bills_screen.dart
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/bill_service.dart';
import 'add_bill_screen.dart';
import 'package:url_launcher/url_launcher.dart';



class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> with TickerProviderStateMixin {
  final BillService _billService = BillService();
  List<Bill> _bills = [];
  bool _isLoading = true;
  bool _showSwipeHint = false;
  late AnimationController _payAnimationController;
  int? _payingBillId;

  @override
  void initState() {
    super.initState();
    _payAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _loadBills();
  }

  @override
  void dispose() {
    _payAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    try {
      setState(() => _isLoading = true);
      
      final billsData = await _billService.getAllBills();
      final bills = billsData.map((map) => Bill.fromMap(map)).toList();
      
      setState(() {
        _bills = bills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e')),
      );
    }
  }

  Future<void> _launchBillLink(String url) async {
  try {
    // Add https if missing
    if (!url.startsWith(RegExp(r'https?://'))) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      // Use externalApplication to ensure a browser is opened
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot open this link on your device.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening link: $e')),
    );
  }
}





  Color _getDueColor(Bill bill) {
    if (bill.isPaid) return Colors.green;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(bill.nextDueDate.year, bill.nextDueDate.month, bill.nextDueDate.day);
    final daysDiff = dueDate.difference(today).inDays;

    if (daysDiff < 0) return Colors.red; // overdue
    if (daysDiff <= 3) return Colors.orange; // due soon
    return Colors.grey[600]!; // normal
  }

  String _getDueText(Bill bill) {
    if (bill.isPaid) return 'Paid for this period';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(bill.nextDueDate.year, bill.nextDueDate.month, bill.nextDueDate.day);
    final daysDiff = dueDate.difference(today).inDays;

    if (daysDiff < 0) {
      return daysDiff == -1 ? 'Overdue by 1 day' : 'Overdue by ${-daysDiff} days';
    } else if (daysDiff == 0) {
      return 'Due today';
    } else if (daysDiff == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $daysDiff days';
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _navigateToAddBill([Bill? bill]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBillScreen(bill: bill),
      ),
    );

    if (result == true) {
      _loadBills();
    }
  }

  Future<void> _markBillAsPaid(Bill bill) async {
    if (bill.id == null || bill.isPaid) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark Bill as Paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark "${bill.name}" as paid?'),
            SizedBox(height: 8),
            Text(
              'Amount: \$${bill.amount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'This will create a transaction and move the bill to the next ${bill.frequency} period.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Mark as Paid'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _payingBillId = bill.id);
      _payAnimationController.forward();

      await _billService.markBillAsPaid(bill);
      
      await Future.delayed(Duration(milliseconds: 300)); // Animation delay
      
      _loadBills();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bill.name} marked as paid!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // Could navigate to transaction details
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking bill as paid: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _payingBillId = null);
      _payAnimationController.reset();
    }
  }

  Future<void> _deleteBill(Bill bill) async {
    if (bill.id == null) return;

    try {
      await _billService.deleteBill(bill.id!);
      _loadBills();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${bill.name} deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting bill: $e')),
      );
    }
  }

  Widget _buildPayBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'Mark as Paid',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.delete, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bills'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBills,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBill(),
        child: Icon(Icons.add),
        tooltip: 'Add Bill',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _bills.isEmpty
              ? _buildEmptyState()
              : _buildBillsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No bills yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the + button to add your first bill',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

    Widget _buildBillsList() {
    return RefreshIndicator(
      onRefresh: _loadBills,
      child: ListView.builder(
        itemCount: _bills.length + (_showSwipeHint ? 1 : 0), // +1 for hint banner
        padding: EdgeInsets.all(8),
        itemBuilder: (context, index) {
          if (_showSwipeHint && index == 0) {
            // Render the swipe hint as the first item
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              color: Colors.blue.shade50,
              child: ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text('Swipe → to pay, ← to delete bills'),
                trailing: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => setState(() => _showSwipeHint = false),
                ),
              ),
            );
          }

          // FIXED: Adjust the bill index when hint is shown
          final billIndex = _showSwipeHint ? index - 1 : index;
          final bill = _bills[billIndex];
          final dueColor = _getDueColor(bill);
          final isPayingThis = _payingBillId == bill.id;
          
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            elevation: bill.isPaid ? 1 : 2,
            color: bill.isPaid ? Colors.grey[50] : null,
            child: Dismissible(
              key: Key('bill_${bill.id}'),
              direction: bill.isPaid 
                  ? DismissDirection.endToStart
                  : DismissDirection.horizontal,
              background: _buildPayBackground(),
              secondaryBackground: _buildDeleteBackground(),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd && !bill.isPaid) {
                  _markBillAsPaid(bill);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Bill'),
                      content: Text('Delete "${bill.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                }
                return false;
              },
              onDismissed: (direction) => _deleteBill(bill),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: isPayingThis 
                      ? Border.all(color: Colors.green, width: 2)
                      : null,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: dueColor.withValues(alpha: 0.2),
                        child: Icon(
                          bill.isPaid ? Icons.check_circle : Icons.receipt,
                          color: dueColor,
                        ),
                      ),
                      if (isPayingThis)
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          bill.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                            color: bill.isPaid ? Colors.grey : null,
                          ),
                        ),
                      ),
                      if (bill.notes != null && bill.notes!.isNotEmpty)
                        Icon(
                          Icons.note,
                          size: 16,
                          color: const Color.fromARGB(255, 117, 117, 117),
                        ),
                      if (bill.link != null && bill.link!.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.link, size: 18, color: Colors.blue),
                          tooltip: 'Open Link',
                          onPressed: () => _launchBillLink(bill.link!),
                        ),
                    ],
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        _getDueText(bill),
                        style: TextStyle(
                          color: dueColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Repeats ${_capitalize(bill.frequency)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${bill.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: bill.isPaid
                              ? Theme.of(context).disabledColor       // lighter/disabled for paid bills
                              : Theme.of(context).colorScheme.primary // adapts to light/dark theme
                        ),
                      ),
                      if (!bill.isPaid && !isPayingThis)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: InkWell(
                            onTap: () => _markBillAsPaid(bill),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Pay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () => _navigateToAddBill(bill),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}