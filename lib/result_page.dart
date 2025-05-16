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

  @override
  void initState() {
    super.initState();
    fetchRecommendation();
  }

  Future<void> fetchRecommendation() async {
    final url = Uri.parse("http://192.168.0.8:8001/recommend_diet");

    // TODO: Replace with actual user input or state management for these
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
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text("Test Results")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(  // Added scroll in case recommendation is long
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mental Health Scores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("BAI Score: ${widget.baiScore}"),
              Text("BDI Score: ${widget.bdiScore}"),
              Text("Total Score: ${widget.baiScore + widget.bdiScore}"),
              SizedBox(height: 20),
              Text(
                "Recommendation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(recommendations),
            ],
          ),
        ),
      ),
    );
  }
}
