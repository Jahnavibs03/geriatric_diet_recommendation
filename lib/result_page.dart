import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultPage extends StatefulWidget {
  final int baiScore;
  final int bdiScore;
  final double height;
  final double weight;

  ResultPage({
    required this.baiScore,
    required this.bdiScore,
    required this.height,
    required this.weight,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String recommendations = "Loading...";

  final Color backgroundColor = const Color(0xFFF2FDF4);
  final Color appBarColor = const Color.fromARGB(255, 37, 151, 222);
  final Color titleColor = const Color.fromARGB(255, 37, 151, 222);
  final Color bodyTextColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    fetchRecommendation();
  }

  Future<void> fetchRecommendation() async {
    final url = Uri.parse("https://geriatric-diet-recommendation-2.onrender.com/recommend_diet");

    final int gender = 0; // 0 = Male, 1 = Female
    final int age = 65;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "bai_score": widget.baiScore.toDouble(),
          "bdi_score": widget.bdiScore.toDouble(),
          "height": widget.height,
          "weight": widget.weight,
          "gender": gender,
          "age": age,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendations = data['recommendation'] ?? "No recommendation provided.";
        });

        final scoresBox = Hive.box('scores');
        final usersBox = Hive.box('users');
        final currentUser = usersBox.get('currentUser');

        if (currentUser != null) {
          final prevScores = scoresBox.get(currentUser, defaultValue: []);
          scoresBox.put(currentUser, [...prevScores, widget.baiScore + widget.bdiScore]);
        }
      } else {
        setState(() {
          recommendations = "Failed to fetch recommendations.";
        });
      }
    } catch (e) {
      setState(() {
        recommendations = "Error connecting to server: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Test Results"),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mental Health Scores",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 12),
              Text("BAI Score: ${widget.baiScore}",
                  style: TextStyle(color: bodyTextColor, fontSize: 16)),
              Text("BDI Score: ${widget.bdiScore}",
                  style: TextStyle(color: bodyTextColor, fontSize: 16)),
              Text("Total Score: ${widget.baiScore + widget.bdiScore}",
                  style: TextStyle(color: bodyTextColor, fontSize: 16)),
              const SizedBox(height: 24),
              Text(
                "Recommendation",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                recommendations,
                style: TextStyle(color: bodyTextColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
