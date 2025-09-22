import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/models/my_order.dart';
import 'package:admin_my_store/app/routes/app_routes.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final MyOrder order;
  final bool isMobile;

  const OrderCard({super.key, required this.order, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.toNamed(Routes.orderDetails, arguments: order.id),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Order #${order.orderNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    backgroundColor: _getStatusColor(),
                    label: Text(
                      order.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(order.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerEmail,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order.customerName,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        order.customerPhone,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(height: 24),
                      
                      Text(
                        '\$${_calculateTotal().toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "order.paymentMethod",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              if (!isMobile) const SizedBox(height: 16),
              if (!isMobile)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed:
                          () => Get.toNamed(
                            Routes.orderDetails,
                            arguments: order.id,
                          ),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 12),
                    if (order.status.toLowerCase() != 'completed')
                      ElevatedButton(
                        onPressed: () => _updateOrderStatus(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                        ),
                        child: const Text('Mark Completed'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'processing':
        return Colors.blue.shade600;
      case 'completed':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'shipped':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  double _calculateTotal() {
    return order.items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void _updateOrderStatus() {
    Get.dialog(
      AlertDialog(
        title: const Text('Update Order Status'),
        content: const Text(
          'Are you sure you want to mark this order as completed?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Implement status update logic
              Get.back();
              Get.snackbar(
                'Success',
                'Order marked as completed',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
