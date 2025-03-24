// customer_card.dart
import 'package:flutter/material.dart';
import 'package:admin_my_store/app/models/address.dart';

class CustomerCard extends StatelessWidget {
  final String customerId;
  final String name;
  final String email;
  final int orderCount;
  final Address primaryAddress;

  const CustomerCard({
    required this.customerId,
    required this.name,
    required this.email,
    required this.orderCount,
    required this.primaryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                ),
                Chip(
                  label: Text('$orderCount orders'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(email),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    primaryAddress.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('View Details'),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('Send Message'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}