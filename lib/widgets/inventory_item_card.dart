// widgets/inventory_item_card.dart
import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class InventoryItemCard extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback? onMarkAsSold;
  final VoidCallback onEdit;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onMarkAsSold,
    required this.onEdit,
  });

  Color _getStatusColor(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    if (daysUntilExpiry < 0) {
      return Colors.red;
    } else if (daysUntilExpiry <= 3) {
      return Colors.orange;
    } else if (daysUntilExpiry <= 7) {
      return Colors.yellow;
    }
    return Colors.green;
  }

  String _getStatusText(DateTime expiryDate) {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    if (daysUntilExpiry < 0) {
      return 'Expired';
    } else if (daysUntilExpiry <= 3) {
      return 'Near Expiry';
    } else if (daysUntilExpiry <= 7) {
      return 'Expiring Soon';
    }
    return 'Fresh';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.expiryDate);
    final statusText = _getStatusText(item.expiryDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: item.isSold ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  if (!item.isSold && onMarkAsSold != null)
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: onMarkAsSold,
                      tooltip: 'Mark as sold',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(Icons.inventory, 'Quantity: ${item.quantity}'),
                  const SizedBox(width: 8),
          
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    'Expires: ${item.expiryDate.toString().substring(0, 10)}',
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor == Colors.yellow 
                            ? Colors.black 
                            : Colors.white,
                      ),
                    ),
                    backgroundColor: statusColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.grey[200],
    );
  }
}