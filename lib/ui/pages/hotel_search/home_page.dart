import 'package:buscatelo/bloc/hotel_bloc.dart';
import 'package:buscatelo/model/hotel_model.dart';
import 'package:buscatelo/ui/pages/hotel_search/hotel_item.dart';
import 'package:buscatelo/ui/pages/map/hotels_map_page.dart';
import 'package:buscatelo/ui/pages/hotel_detail/hotel_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({Key? key}) : super(key: key);

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  String _query = '';
  String _category = 'Popular';
  String _sortBy = 'rating';
  final Set<String> _amenityFilters = {};
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 2;

  @override
  Widget build(BuildContext context) {
    final hotelBloc = Provider.of<HotelBloc>(context);
    final hotels = hotelBloc.hotels
        .where((hotel) => hotel.name
                .toLowerCase()
                .contains(_query.toLowerCase()) ||
            hotel.address.toLowerCase().contains(_query.toLowerCase()))
        .where((hotel) {
      if (_category == 'Budget') return hotel.price <= 15000;
      if (_category == 'Luxury') return hotel.price >= 20000;
      return true;
    }).where((hotel) {
      if (_amenityFilters.isEmpty) return true;
      final amenities = hotel.amenities.map((a) => a.name.toLowerCase());
      return _amenityFilters.every((f) => amenities.contains(f.toLowerCase()));
    }).toList();

    hotels.sort((a, b) {
      if (_sortBy == 'price') return a.price.compareTo(b.price);
      if (_sortBy == 'rating') return _rating(b).compareTo(_rating(a));
      return 0;
    });
    return Scaffold(
      appBar: AppBar(title: const Text('HotelEase')),
      body: ListView(
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Image.asset('assets/img/home.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search destination',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(_checkInDate == null && _checkOutDate == null
                            ? 'Select dates'
                            : '${_checkInDate != null ? '${_checkInDate!.day}/${_checkInDate!.month}' : ''} - ${_checkOutDate != null ? '${_checkOutDate!.day}/${_checkOutDate!.month}' : ''}'),
                        onPressed: () => _selectDates(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.person),
                        label: Text('$_guests ${_guests == 1 ? 'Guest' : 'Guests'}'),
                        onPressed: () => _selectGuests(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Popular',
                      selected: _category == 'Popular',
                      onTap: () => setState(() => _category = 'Popular'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Budget',
                      selected: _category == 'Budget',
                      onTap: () => setState(() => _category = 'Budget'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Luxury',
                      selected: _category == 'Luxury',
                      onTap: () => setState(() => _category = 'Luxury'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Featured hotels',
                  action: TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hotels.take(6).length,
                    itemBuilder: (context, index) {
                      final hotel = hotels[index];
                      return _FeaturedHotelCard(hotel: hotel);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Sort by:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(value: 'price', child: Text('Price')),
                        DropdownMenuItem(
                            value: 'rating', child: Text('Rating')),
                        DropdownMenuItem(
                            value: 'distance', child: Text('Distance')),
                      ],
                      onChanged: (value) =>
                          setState(() => _sortBy = value ?? 'rating'),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filters'),
                      onPressed: () => _openFilters(context),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.map),
                      tooltip: 'View on Map',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelsMapPage(hotels: hotels),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                HotelListBody(hotelBloc: hotelBloc, filteredHotels: hotels),
          ),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelsMapPage(hotels: hotels),
            ),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  double _rating(HotelModel hotel) {
    if (hotel.reviews.isEmpty) return 0;
    final total = hotel.reviews.fold<int>(0, (sum, r) => sum + r.rate);
    return total / hotel.reviews.length;
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Amenities'),
              Wrap(
                spacing: 8,
                children: [
                  _AmenityChip(
                    label: 'Wi-Fi',
                    selected: _amenityFilters.contains('Wi-Fi'),
                    onSelected: (value) {
                      setModalState(() {
                        value
                            ? _amenityFilters.add('Wi-Fi')
                            : _amenityFilters.remove('Wi-Fi');
                      });
                      setState(() {});
                    },
                  ),
                  _AmenityChip(
                    label: 'Pool',
                    selected: _amenityFilters.contains('Pool'),
                    onSelected: (value) {
                      setModalState(() {
                        value
                            ? _amenityFilters.add('Pool')
                            : _amenityFilters.remove('Pool');
                      });
                      setState(() {});
                    },
                  ),
                  _AmenityChip(
                    label: 'Parking',
                    selected: _amenityFilters.contains('Parking'),
                    onSelected: (value) {
                      setModalState(() {
                        value
                            ? _amenityFilters.add('Parking')
                            : _amenityFilters.remove('Parking');
                      });
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(_amenityFilters.clear);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDates(BuildContext context) async {
    final DateTime? checkIn = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Check-in Date',
    );

    if (checkIn != null) {
      final DateTime? checkOut = await showDatePicker(
        context: context,
        initialDate: checkIn.add(const Duration(days: 1)),
        firstDate: checkIn.add(const Duration(days: 1)),
        lastDate: checkIn.add(const Duration(days: 30)),
        helpText: 'Select Check-out Date',
      );

      if (checkOut != null) {
        setState(() {
          _checkInDate = checkIn;
          _checkOutDate = checkOut;
        });
      }
    }
  }

  Future<void> _selectGuests(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number of Guests'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _guests > 1
                    ? () => setDialogState(() => _guests--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$_guests',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setDialogState(() => _guests++),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        action,
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip(
      {required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _FeaturedHotelCard extends StatelessWidget {
  const _FeaturedHotelCard({required this.hotel});

  final HotelModel hotel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelDetailPage(hotel),
          ),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                hotel.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/img/hotel1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
                child: Text(
                  hotel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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
        ListView.builder(
          itemCount: filteredHotels.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, index) => HotelItem(
            hotel: filteredHotels[index],
            key: UniqueKey(),
          ),
        ),
      ],
    );
  }
}
