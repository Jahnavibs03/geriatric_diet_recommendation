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

  @override
  void initState() {
    super.initState();
    email = userBox.get('currentUser', defaultValue: 'N/A');
    scores = scoresBox.get(email, defaultValue: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileCard(Icons.email, 'Email', email),
            SizedBox(height: 20),
            _buildActionButton(
              icon: Icons.lock_reset,
              label: showChangePassword
                  ? 'Cancel Password Change'
                  : 'Change Password',
              onTap: () {
                setState(() {
                  showChangePassword = !showChangePassword;
                });
              },
              color: Colors.deepOrange,
            ),
            if (showChangePassword) _buildPasswordForm(),
            SizedBox(height: 20),
            _buildScoreSection(scores),
            Spacer(),
            _buildActionButton(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.teal[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 3))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.teal[800]),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800])),
              Text(value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(2, 3))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
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
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                userBox.put(email, _newPassController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Password updated successfully")),
                );
                setState(() {
                  showChangePassword = false;
                });
                _currentPassController.clear();
                _newPassController.clear();
                _confirmPassController.clear();
              }
            },
            child:
                Text("Update Password", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required bool obscure,
      required FormFieldValidator<String> validator}) {
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
          fillColor: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildScoreSection(List<dynamic> scores) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Previous Mental Health Scores",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900])),
            SizedBox(height: 12),
            Expanded(
              child: scores.isEmpty
                  ? Text("No scores available",
                      style: TextStyle(color: Colors.black54))
                  : ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.bar_chart, color: Colors.purple),
                          title: Text("Score ${index + 1}: ${scores[index]}"),
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
