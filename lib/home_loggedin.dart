import 'package:flutter/material.dart';

class HomeLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Welcome Home'),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHomeOption(
              context,
              title: 'Profile Page',
              icon: Icons.person,
              route: '/profile',
              color: colorScheme.primaryContainer,
            ),
            SizedBox(height: 20),
            _buildHomeOption(
              context,
              title: 'Take Mental Health Test',
              icon: Icons.psychology,
              route: '/test',
              color: colorScheme.secondaryContainer,
            ),
            SizedBox(height: 20),
            _buildHomeOption(
              context,
              title: 'Previous Diet Recommendation',
              icon: Icons.restaurant_menu,
              route: '/diet',
              color: colorScheme.tertiaryContainer ?? Colors.purple.shade200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeOption(BuildContext context,
      {required String title,
      required IconData icon,
      required String route,
      required Color color}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
