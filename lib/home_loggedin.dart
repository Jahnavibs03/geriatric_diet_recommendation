import 'package:flutter/material.dart';

class HomeLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Welcome Home',
          style: TextStyle(color: Colors.white), // dark green
        ),
        backgroundColor:  const Color.fromARGB(255, 37, 151, 222),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF225522)), // dark green for back button
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHomeOption(
                context,
                title: 'Profile Page',
                icon: Icons.person,
                route: '/profile',
                color:  const Color.fromARGB(255, 37, 151, 222),
              ),
              const SizedBox(height: 24),
              _buildHomeOption(
                context,
                title: 'Take Mental Health Test',
                icon: Icons.psychology,
                route: '/test',
                color:  const Color.fromARGB(255, 37, 151, 222),
              ),
              const SizedBox(height: 24),
              _buildHomeOption(
                context,
                title: 'Previous Diet Recommendation',
                icon: Icons.restaurant_menu,
                route: '/diet',
                color:  const Color.fromARGB(255, 37, 151, 222),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeOption(BuildContext context,
      {required String title,
      required IconData icon,
      required String route,
      required Color color}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // optional for safety
                maxLines: 1,
                softWrap: false,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
