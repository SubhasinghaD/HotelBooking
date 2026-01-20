import 'package:buscatelo/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingBloc = context.watch<BookingBloc>();
    final bookings = bookingBloc.bookings;

    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings yet'));
    }

    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final dateRange =
            '${DateFormat.yMMMd().format(booking.checkIn)} - ${DateFormat.yMMMd().format(booking.checkOut)}';
        return ListTile(
          title: Text(booking.hotelName),
          subtitle: Text('${booking.roomName}\n$dateRange'),
          trailing: Text('S/ ${booking.totalPrice}'),
          isThreeLine: true,
        );
      },
    );
  }
}
