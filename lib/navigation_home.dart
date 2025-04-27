import 'package:flutter/material.dart';
import 'home/my_home_page.dart';
import 'edit/edit_page.dart'; // Import EditPage
import 'stats/stats_page.dart';

class NavigationHome extends StatefulWidget {
  const NavigationHome({super.key});

  @override
  State<NavigationHome> createState() => _NavigationHomeState();
}

class _NavigationHomeState extends State<NavigationHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MyHomePage(),
    const EditPage(), // Edit page
    const StatsPage(), // Statistics page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit), // Edit icon
            label: 'Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events), // Trophy icon
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
