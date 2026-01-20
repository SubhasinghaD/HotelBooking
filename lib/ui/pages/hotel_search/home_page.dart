import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/hotel_search/hotel_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({Key? key}) : super(key: key);

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final hotelBloc = Provider.of<HotelBloc>(context);
    final hotels = hotelBloc.hotels
        .where((hotel) => hotel.name
                .toLowerCase()
                .contains(_query.toLowerCase()) ||
            hotel.address.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your hotel'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or address',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.asset(
              'assets/img/home.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: HotelListBody(hotelBloc: hotelBloc, filteredHotels: hotels),
          ),
        ],
      ),
    );
  }
}

class HotelListBody extends StatelessWidget {
  const HotelListBody({
    Key? key,
    required this.hotelBloc,
    required this.filteredHotels,
  }) : super(key: key);

  final HotelBloc hotelBloc;
  final List<HotelModel> filteredHotels;

  @override
  Widget build(BuildContext context) {
    if (hotelBloc.failure != null) {
      return Center(child: Text(hotelBloc.failure.toString()));
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: filteredHotels.length,
            itemBuilder: (_, index) => HotelItem(
              hotel: filteredHotels[index],
              key: UniqueKey(),
            ),
          ),
        ),
      ],
    );
  }
}
