import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/widgets/shared/app_bar/custom_app_bar.dart';
import 'package:frontend/features/teams/presentation/widgets/team_card.dart';
import 'package:frontend/features/notifications/presentation/pages/notifications_page.dart';
import 'package:frontend/features/user/presentation/pages/profile_page.dart';

class TeamsListPage extends StatefulWidget {
  const TeamsListPage({super.key});

  @override
  State<TeamsListPage> createState() => _TeamsListPageState();
}

class _TeamsListPageState extends State<TeamsListPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TeamsListContent(), // Home tab - teams list
    const NotificationsPage(), // Notifications tab
    const ProfilePage(), // Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? CustomAppBar(title: 'Teams', showSearchIcon: true)
          : null,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () async {
                final storage = FlutterSecureStorage();
                await storage.delete(key: 'auth_token');
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            )
          : _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to create team page
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: _currentIndex == 2
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.startFloat,
    );
  }
}

class TeamsListContent extends StatelessWidget {
  const TeamsListContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data - will be replaced with actual data from backend
    final teams = [
      {
        'id': '1',
        'name': 'Google Team',
        'initial': 'G',
        'logo': 'assets/images/logos/google_g.png',
      },
      {'id': '2', 'name': 'Design Squad', 'initial': 'D', 'logo': null},
      {'id': '3', 'name': 'Dev Masters', 'initial': 'D', 'logo': null},
      {'id': '4', 'name': 'Mobile Team', 'initial': 'M', 'logo': null},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TeamCard(
              teamName: team['name']!,
              teamInitial: team['initial']!,
              logoPath: team['logo'],
              onTap: () {
                // TODO: Navigate to team details
              },
            ),
          );
        },
      ),
    );
  }
}
