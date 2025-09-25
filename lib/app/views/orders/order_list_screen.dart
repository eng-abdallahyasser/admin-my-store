import 'package:admin_my_store/app/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/controllers/order_controller.dart';

class OrderListScreen extends StatelessWidget {
  final OrderController _controller = Get.find();
  final RxList<String> _leftFilters = <String>[].obs;
  final RxList<String> _rightFilters = <String>[].obs;

  OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        centerTitle: !isMobile,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search Orders',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.loadOrders,
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Orders Found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'When you receive orders, they will appear here',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _controller.loadOrders,
          child: isMobile
              ? _buildMobileList()
              : _buildTwoHalvesLayout(),
        );
      }),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _controller.orders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: _controller.orders[index],
          isMobile: true,
        );
      },
    );
  }

  Widget _buildTwoHalvesLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left Half
          Expanded(
            child: _buildHalfSection(
              title: 'Active Orders',
              filters: _leftFilters,
              orders: _getFilteredOrders(_leftFilters),
              onFilterChanged: (status) => _toggleLeftFilter(status),
            ),
          ),
          const SizedBox(width: 16),
          // Right Half
          Expanded(
            child: _buildHalfSection(
              title: 'Completed Orders',
              filters: _rightFilters,
              orders: _getFilteredOrders(_rightFilters),
              onFilterChanged: (status) => _toggleRightFilter(status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHalfSection({
    required String title,
    required RxList<String> filters,
    required List<dynamic> orders,
    required Function(String) onFilterChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _controller.statusList.map((status) {
                    final selected = filters.contains(status);
                    return FilterChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) => onFilterChanged(status),
                      selectedColor: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.15),
                      checkmarkColor: Theme.of(Get.context!).colorScheme.primary,
                    );
                  }).toList(),
                )),
                if (filters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () => filters.clear(),
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Orders list
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No orders found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: orders[index],
                        isMobile: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredOrders(RxList<String> filters) {
    if (filters.isEmpty) {
      return _controller.orders;
    }
    return _controller.orders.where((order) => filters.contains(order.status)).toList();
  }

  void _toggleLeftFilter(String status) {
    if (_leftFilters.contains(status)) {
      _leftFilters.remove(status);
    } else {
      _leftFilters.add(status);
    }
  }

  void _toggleRightFilter(String status) {
    if (_rightFilters.contains(status)) {
      _rightFilters.remove(status);
    } else {
      _rightFilters.add(status);
    }
  }


  void _showSearchDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by order number or customer...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) =>{
            
          },
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}