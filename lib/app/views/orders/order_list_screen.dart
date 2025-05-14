import 'package:admin_my_store/app/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_my_store/app/controllers/order_controller.dart';

class OrderListScreen extends StatelessWidget {
  final OrderController _controller = Get.find();

  OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        centerTitle: !isMobile,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Orders',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search Orders',
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
              : isTablet
                  ? _buildTabletList()
                  : _buildDesktopGrid(),
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

  Widget _buildTabletList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.orders.length,
      itemBuilder: (context, index) {
        return OrderCard(
          order: _controller.orders[index],
          isMobile: false,
        );
      },
    );
  }

  Widget _buildDesktopGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _controller.orders.length,
        itemBuilder: (context, index) {
          return OrderCard(
            order: _controller.orders[index],
            isMobile: false,
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Orders'),
        content: Obx(
          () => SizedBox(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._controller.statusList.map(
                  (status) => CheckboxListTile(
                    title: Text(status),
                    value: _controller.selectedStatus.contains(status),
                    onChanged: (value) =>
                        _controller.toggleStatusFilter(status),
                  ),
                ).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () {
              _controller.applyFilters();
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
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