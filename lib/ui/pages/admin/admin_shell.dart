import 'package:buscatelo/bloc/auth_bloc.dart';
import 'package:buscatelo/ui/pages/admin/admin_bookings_page.dart';
import 'package:buscatelo/ui/pages/admin/admin_hotels_page.dart';
import 'package:buscatelo/ui/pages/admin/admin_pricing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({Key? key}) : super(key: key);

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    AdminHotelsPage(),
    AdminBookingsPage(),
    AdminPricingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.orange.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Admin Panel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  authBloc.displayName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => authBloc.signOut(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel_rounded),
            label: 'Hotels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.price_change_rounded),
            label: 'Pricing',
          ),
        ],
      ),
    );
  }
}
