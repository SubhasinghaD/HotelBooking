import 'package:buscatelo/bloc/auth_bloc.dart';
import 'package:buscatelo/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();
    final bookingBloc = context.watch<BookingBloc>();
    final bookings = bookingBloc.bookings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: authBloc.photoUrl == null
                  ? null
                  : NetworkImage(authBloc.photoUrl!),
              child: authBloc.photoUrl == null
                  ? Text(authBloc.displayName.characters.first)
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authBloc.displayName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(authBloc.email,
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('My bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (bookings.isEmpty)
          const Text('No bookings yet')
        else
          ...bookings.map((booking) {
            final dateRange =
                '${DateFormat.yMMMd().format(booking.checkIn)} - ${DateFormat.yMMMd().format(booking.checkOut)}';
            return Card(
              child: ListTile(
                title: Text(booking.hotelName),
                subtitle: Text('${booking.roomName}\n$dateRange'),
                trailing: Text('LKR ${booking.totalPrice}'),
                isThreeLine: true,
              ),
            );
          }).toList(),
        const SizedBox(height: 16),
        const Text('Payment methods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Visa •••• 4242'),
            subtitle: const Text('Default payment method'),
            trailing: TextButton(onPressed: () {}, child: const Text('Edit')),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Notifications'),
          value: true,
          onChanged: (_) {},
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: const Text('English'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () => _confirmLogout(context, authBloc),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthBloc authBloc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authBloc.signOut();
    }
  }
}
