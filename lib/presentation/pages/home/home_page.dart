import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../movies/movies_page.dart';
import '../rankings/rankings_page.dart';

// Tela inicial com navegação lateral (NavigationRail) para Desktop.
// 📖 NavigationRail é o padrão Material para Desktop; substitui BottomNavigationBar
// que é otimizado para telas pequenas/touch.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _pages = [MoviesPage(), RankingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.kSpacingLarge,
              ),
              child: Text(
                'CR',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.movie_outlined),
                selectedIcon: Icon(Icons.movie),
                label: Text('Filmes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.format_list_numbered_outlined),
                selectedIcon: Icon(Icons.format_list_numbered),
                label: Text('Rankings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
