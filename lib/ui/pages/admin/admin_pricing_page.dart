import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPricingPage extends StatelessWidget {
  const AdminPricingPage({Key? key}) : super(key: key);

  Future<void> _addSeasonalPrice(BuildContext context) async {
    final nameController = TextEditingController();
    final multiplierController = TextEditingController(text: '1.2');
    final startController = TextEditingController();
    final endController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Seasonal Pricing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Season name'),
            ),
            TextField(
              controller: multiplierController,
              decoration: const InputDecoration(labelText: 'Multiplier (e.g. 1.2)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(labelText: 'Start date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: 'End date (YYYY-MM-DD)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final multiplier = double.tryParse(multiplierController.text) ?? 1.0;
              await FirebaseFirestore.instance.collection('pricing_rules').add({
                'name': nameController.text.trim(),
                'multiplier': multiplier,
                'startDate': startController.text.trim(),
                'endDate': endController.text.trim(),
                'createdAt': DateTime.now().toIso8601String(),
              });
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addBlackoutDate(BuildContext context) async {
    final dateController = TextEditingController();
    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blackout Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('blackout_dates').add({
                'date': dateController.text.trim(),
                'reason': reasonController.text.trim(),
                'createdAt': DateTime.now().toIso8601String(),
              });
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade100, Colors.orange.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.orange.shade700, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seasonal Pricing',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Manage peak season rates',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('pricing_rules')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'No seasonal pricing rules yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.local_offer, color: Colors.orange.shade700),
                      ),
                      title: Text(
                        data['name'] ?? 'Season',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Multiplier: ${data['multiplier'] ?? 1.0}x',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${data['startDate'] ?? '-'} to ${data['endDate'] ?? '-'}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance
                            .collection('pricing_rules')
                            .doc(doc.id)
                            .delete(),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade100, Colors.red.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.block, color: Colors.red.shade700, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blackout Dates',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Block dates for bookings',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('blackout_dates')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'No blackout dates configured',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.event_busy, color: Colors.red.shade700),
                      ),
                      title: Text(
                        data['date'] ?? 'Date',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        data['reason'] ?? 'No reason',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance
                            .collection('blackout_dates')
                            .doc(doc.id)
                            .delete(),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _addSeasonalPrice(context),
            label: const Text('Add Season'),
            icon: const Icon(Icons.add),
            heroTag: 'season',
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: () => _addBlackoutDate(context),
            label: const Text('Add Blackout'),
            icon: const Icon(Icons.block),
            heroTag: 'blackout',
          ),
        ],
      ),
    );
  }
}
