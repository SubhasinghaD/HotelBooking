import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({Key? key}) : super(key: key);

  Future<void> _updateStatus(
      String bookingId, String status, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  Future<void> _refundBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'refunded'});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        final docs = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final status = (data['status'] as String?) ?? 'pending';
            
            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'confirmed':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              case 'refunded':
                statusColor = Colors.blue;
                statusIcon = Icons.payment;
                break;
              default:
                statusColor = Colors.orange;
                statusIcon = Icons.pending;
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['hotelName'] ?? 'Unknown hotel',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 16, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.meeting_room, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          data['roomName'] ?? '-',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          '${data['guests'] ?? '-'} guests',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${data['checkIn'] ?? '-'} → ${data['checkOut'] ?? '-'}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.payments, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'LKR ${data['totalPrice'] ?? '-'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (status != 'confirmed')
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Confirm'),
                            onPressed: () => _updateStatus(
                                docs[index].id, 'confirmed', context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (status != 'cancelled')
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cancel, size: 16),
                            label: const Text('Cancel'),
                            onPressed: () => _updateStatus(
                                docs[index].id, 'cancelled', context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        if (status != 'refunded')
                          OutlinedButton.icon(
                            icon: const Icon(Icons.payment, size: 16),
                            label: const Text('Refund'),
                            onPressed: () => _refundBooking(docs[index].id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
