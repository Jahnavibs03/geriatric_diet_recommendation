import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Box userBox = Hive.box('users');
  final Box scoresBox = Hive.box('scores');

  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool showChangePassword = false;
  String email = '';
  List<dynamic> scores = [];

  final Color backgroundColor = const Color(0xFFF2FDF4);
  final Color appBarColor = Colors.greenAccent;
  final Color buttonColor = Colors.greenAccent;
  final Color buttonTextColor = Colors.white;
  final Color textFieldFillColor = Colors.white;

  @override
  void initState() {
    super.initState();
    email = userBox.get('currentUser', defaultValue: 'N/A');
    scores = scoresBox.get(email, defaultValue: []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: appBarColor,
        foregroundColor: buttonTextColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileCard(Icons.email, 'Email', email),
            const SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.lock_reset,
              label: showChangePassword ? 'Cancel Password Change' : 'Change Password',
              onTap: () {
                setState(() {
                  showChangePassword = !showChangePassword;
                });
              },
            ),
            if (showChangePassword) _buildPasswordForm(),
            const SizedBox(height: 20),
            _buildScoreSection(scores),
            const Spacer(),
            _buildActionButton(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: textFieldFillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: appBarColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  )),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: buttonTextColor, size: 24),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 18, color: buttonTextColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _currentPassController,
            label: "Current Password",
            obscure: true,
            validator: (value) {
              final correct = userBox.get(email);
              if (value == null || value.isEmpty) {
                return "Enter current password";
              } else if (value != correct) {
                return "Incorrect current password";
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _newPassController,
            label: "New Password",
            obscure: true,
            validator: (value) {
              if (value == null ||
                  value.length < 6 ||
                  !RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                return "Password must be at least 6 characters & include letters and numbers";
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _confirmPassController,
            label: "Confirm New Password",
            obscure: true,
            validator: (value) {
              if (value != _newPassController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                userBox.put(email, _newPassController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully")),
                );
                setState(() {
                  showChangePassword = false;
                });
                _currentPassController.clear();
                _newPassController.clear();
                _confirmPassController.clear();
              }
            },
            child: const Text("Update Password"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required FormFieldValidator<String> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: textFieldFillColor,
        ),
      ),
    );
  }

  Widget _buildScoreSection(List<dynamic> scores) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: textFieldFillColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Previous Mental Health Scores",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 18,
                )),
            const SizedBox(height: 12),
            Expanded(
              child: scores.isEmpty
                  ? Text("No scores available",
                      style: TextStyle(color: Colors.black54))
                  : ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.bar_chart, color: appBarColor),
                          title: Text("Score ${index + 1}: ${scores[index]}",
                              style: const TextStyle(color: Colors.black87)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
