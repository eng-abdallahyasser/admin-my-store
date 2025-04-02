// order_card.dart
import 'package:flutter/material.dart';
import 'package:admin_my_store/app/models/order.dart';

class OrderCard extends StatelessWidget {
  final MyOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                ),
                Chip(
                  backgroundColor: _getStatusColor(),
                  label: const Text(
                    'Status',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items: ${order.items.length}'),
                Text('Total: \$${_calculateTotal()}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Customer ID: ${order.customerId.substring(0, 8)}...'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('VIEW DETAILS'),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
                  child: const Text('MARK COMPLETED'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    // Implement status color logic
    return Colors.blue;
  }

  double _calculateTotal() {
    return order.items.fold(0, (sum, item) => sum + item.totalPrice);
  }
}