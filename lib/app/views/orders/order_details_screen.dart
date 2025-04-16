import 'package:admin_my_store/app/controllers/orde_detailes_controller.dart';
import 'package:admin_my_store/app/models/order.dart';
import 'package:admin_my_store/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final orderId = Get.arguments as String;
  final OrderDetailsController _controller = Get.find();

  OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.error.isNotEmpty) {
          return Center(child: Text(_controller.error.value));
        }
        final order = _controller.order.value;
        if (order == null) {
          _controller.loadOrderDetails(orderId);
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo(order),
              const SizedBox(height: 24),
              _buildStatusSelector(order),
              const SizedBox(height: 24),
              _buildOrderItems(order),
              const SizedBox(height: 24),
              _buildCustomerInfo(order),
              const SizedBox(height: 24),
              _buildActions(order),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderInfo(MyOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Order ID:', order.id),
            _buildInfoRow('Date:', DateFormat.yMMMd().format(order.createdAt)),
            _buildInfoRow('Total:', '\$${order.total.toStringAsFixed(2)}'),
            _buildInfoRow('Payment Status:', order.paymentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector(MyOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Status:', style: TextStyle(fontSize: 16)),
            DropdownButtonFormField<String>(
              value: order.status,
              items:
                  _controller.statusList
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
              onChanged: (value) => _controller.updateOrderStatus(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(MyOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items:', style: TextStyle(fontSize: 16)),
            ...order.items.map(
              (item) => ListTile(
                title: Text(item.productId),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(MyOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Info:', style: TextStyle(fontSize: 16)),
            _buildInfoRow('Name:', order.customerName),
            _buildInfoRow('Email:', order.customerId),
            _buildInfoRow('Phone:', order.customerPhone),
            const SizedBox(height: 8),
            const Text('Shipping Address:', style: TextStyle(fontSize: 16)),
            Text(order.shippingAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActions(MyOrder order) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Send Notification',
            onPressed: () => {_controller.sendNotification()},
          ),
        ),
      ],
    );
  }
}
