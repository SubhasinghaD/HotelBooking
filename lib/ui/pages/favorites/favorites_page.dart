import 'package:buscatelo/bloc/favorites_bloc.dart';
import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/ui/pages/hotel_search/hotel_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hotelBloc = context.watch<HotelBloc>();
    final favoritesBloc = context.watch<FavoritesBloc>();
    final hotels = hotelBloc.hotels
        .where((hotel) => favoritesBloc.isFavorite(hotel))
        .toList();

    if (hotels.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }

    return ListView.builder(
      itemCount: hotels.length,
      itemBuilder: (_, index) => HotelItem(hotel: hotels[index]),
    );
  }
}
