import 'dart:convert';

import 'package:admin_my_store/app/controllers/orde_detailes_controller.dart';
import 'package:admin_my_store/app/models/address.dart';
import 'package:admin_my_store/app/models/my_order.dart';
import 'package:admin_my_store/app/models/product.dart';
import 'package:admin_my_store/app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class OrderDetailsScreen extends StatelessWidget {
  final orderId = Get.arguments as String;
  final OrderDetailsController _controller = Get.find();

  OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    
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
        
        if (isDesktop) {
          return _buildDesktopLayout(context, order);
        } else {
          return _buildMobileLayout(order);
        }
      }),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, MyOrder order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left half - Order details
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfo(order),
                const SizedBox(height: 24),
                _buildStatusSelector(order),
                const SizedBox(height: 24),
                _buildOrderItems(order, _controller.products),
                const SizedBox(height: 24),
                _buildCustomerInfo(order),
                const SizedBox(height: 24),
                _buildActions(order),
              ],
            ),
          ),
        ),
        // Right half - Map
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 32,
              child: _buildMapSection(order),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(MyOrder order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderInfo(order),
          const SizedBox(height: 24),
          _buildStatusSelector(order),
          const SizedBox(height: 24),
          _buildOrderItems(order, _controller.products),
          const SizedBox(height: 24),
          _buildCustomerInfo(order),
          const SizedBox(height: 24),
          _buildMapSection(order),
          const SizedBox(height: 24),
          _buildActions(order),
        ],
      ),
    );
  }

  Widget _buildMapSection(MyOrder order) {
    Address address = Address.fromCompactAddress(order.shippingAddress);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
                  height: 600,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(address.latitude, address.longitude),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: LatLng(address.latitude, address.longitude),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
          ],
        ),
      ),
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
              initialValue: order.status,
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

  Widget _buildOrderItems(MyOrder order, List<Product> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items:', style: TextStyle(fontSize: 16)),
            ...order.items.map((item) {
              final product = products.firstWhere(
                (p) =>
                    p.id ==
                    item.productId, // Adjust this condition based on your IDs
                orElse: () => Product(
                  id: '0',
                  colors: [],
                  title: 'Unknown Product',
                  imagesUrl: [],
                  category: 'Unknown',
                  price: 0.0,
                ),
              );
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imagesUrl[0],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                
                title: Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${product.category}'),
                    Text('Options: ${item.getVariantsString()}'),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Quantity: ${item.quantity}'),
                    Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                  ],
                ),
              );
            }),
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
            const Text('Customer Info:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildInfoRow('Name:', order.customerName),
            _buildInfoRow('Email:', order.customerEmail),
            _buildInfoRow('Phone:', order.customerPhone),
            const SizedBox(height: 16),
            _buildShippingAddressSection(order),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressSection(MyOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shipping Address:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => _copyAddressToClipboard(Address.fromCompactAddress(order.shippingAddress).getCopyAddressString()),
              icon: const Icon(Icons.copy, size: 20),
              tooltip: 'Copy Address',
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.1),
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _buildAddressContent(Address.fromCompactAddress(order.shippingAddress) ),
        ),
        
      ],
    );
  }

  Widget _buildAddressContent(Address address) {
    final fields = [
      {'label': 'Name', 'value': address.name},
      {'label': 'Area', 'value': address.area},
      {'label': 'Street', 'value': address.street},
      {'label': 'Building', 'value': address.building},
      {'label': 'Floor', 'value': address.floor},
      {'label': 'Apartment', 'value': address.apartment},
      {'label': 'Landmark', 'value': address.landmark},
      {'label': 'Phone', 'value': address.phoneNumber},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields
          .where((f) => (f['value'] as String).isNotEmpty)
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        '${f['label']}:',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SelectableText(
                        f['value'] as String,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

 
  void _copyAddressToClipboard(String address) {
    String formattedAddress = _getFormattedAddressForCopy(address);
    Clipboard.setData(ClipboardData(text: formattedAddress));
    Get.snackbar(
      'Copied!',
      'Address copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.all(16),
    );
  }

  String _getFormattedAddressForCopy(String address) {
    try {
      if (address.contains('{') && address.contains('}')) {
        // JSON-based address; format the key fields only
        final addressData = json.decode(address) as Map<String, dynamic>;
        final parts = <String>[];
        void addPart(String label, dynamic value) {
          if (value != null && value.toString().isNotEmpty) {
            parts.add('$label: ${value.toString()}');
          }
        }
        addPart('Name', addressData['name']);
        addPart('Area', addressData['area']);
        addPart('Street', addressData['street']);
        addPart('Building', addressData['building']);
        addPart('Floor', addressData['floor']);
        addPart('Apartment', addressData['apartment']);
        addPart('Landmark', addressData['landmark']);
        addPart('Phone', addressData['phoneNumber']);
        return parts.join('\n');
      }

      // Fallback to compact string format
      final parsed = Address.fromCompactAddress(address);
      return parsed.getCopyAddressString();
    } catch (e) {
      // Fallback to original address string
      return address;
    }
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
