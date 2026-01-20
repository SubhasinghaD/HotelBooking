import 'package:buscatelo/bloc/booking_bloc.dart';
import 'package:buscatelo/data/network/payment_api.dart';
import 'package:buscatelo/model/booking_model.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  final HotelModel hotel;

  const BookingPage({Key? key, required this.hotel}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTimeRange? _dateRange;
  int _guests = 2;
  Room? _selectedRoom;

  int get _totalPrice {
    final nights = _dateRange == null
        ? 1
        : _dateRange!.duration.inDays.clamp(1, 365);
    return widget.hotel.price * nights;
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      appBar: AppBar(title: const Text('Complete booking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(hotel.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Dates'),
            subtitle: Text(
              _dateRange == null
                  ? 'Select check-in and check-out'
                  : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}',
            ),
            trailing: const Icon(Icons.date_range),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
              }
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Guests'),
            subtitle: Text('$_guests guests'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _guests > 1
                      ? () => setState(() => _guests--)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _guests++),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Room type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final room in hotel.rooms)
                ChoiceChip(
                  label: Text(room.name),
                  selected: _selectedRoom == room,
                  onSelected: (_) => setState(() => _selectedRoom = room),
                ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Total'),
            trailing: Text('S/ $_totalPrice',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Confirm booking'),
            onPressed: _selectedRoom == null || _dateRange == null
                ? null
                : () => _confirmBooking(context),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Pay with Stripe'),
            onPressed: _selectedRoom == null || _dateRange == null
                ? null
                : () => _payWithStripe(context),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context) {
    final bookingBloc = context.read<BookingBloc>();
    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hotelId: widget.hotel.id,
      hotelName: widget.hotel.name,
      roomName: _selectedRoom!.name,
      checkIn: _dateRange!.start,
      checkOut: _dateRange!.end,
      guests: _guests,
      totalPrice: _totalPrice,
      status: 'confirmed',
    );

    bookingBloc.addBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmed (email queued)')),
    );

    Navigator.pop(context);
  }

  void _showPaymentNotConfigured(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Stripe not configured'),
        content: const Text(
          'Add your Stripe publishable key and backend integration to enable payments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _payWithStripe(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Create payment intent
      final clientSecret = await PaymentApi.createPaymentIntent(
        amount: _totalPrice * 100, // Convert to cents
        currency: 'usd',
        metadata: {
          'hotel_id': widget.hotel.id,
          'hotel_name': widget.hotel.name,
          'room': _selectedRoom!.name,
          'guests': _guests.toString(),
        },
      );

      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Hotel Booking',
          paymentIntentClientSecret: clientSecret,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful
      if (context.mounted) {
        _confirmBooking(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Booking confirmed.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading if still open
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
