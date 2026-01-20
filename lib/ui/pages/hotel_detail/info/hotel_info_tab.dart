import 'package:buscatelo/model/hotel_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelInformationTab extends StatelessWidget {
  const HotelInformationTab({
    Key? key,
    required this.hotel,
  }) : super(key: key);

  final HotelModel hotel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          hotel.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w700,
          ),
        ),
        Divider(
          height: 2,
          color: Colors.grey,
        ),
        SizedBox(height: 16),
        Text(hotel.description),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.map),
          label: const Text('Open in Maps'),
          onPressed: () => _openMaps(hotel.address),
        ),
      ],
    );
  }

  Future<void> _openMaps(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch maps');
    }
  }
}
