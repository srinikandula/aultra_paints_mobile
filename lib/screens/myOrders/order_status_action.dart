import 'package:flutter/material.dart';

class OrderStatusActionSheet extends StatelessWidget {
  final void Function(String action) onAction;
  const OrderStatusActionSheet({Key? key, required this.onAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Update Order Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  onPressed: () => onAction('APPROVED'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  onPressed: () => onAction('REJECTED'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
