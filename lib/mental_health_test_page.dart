import 'package:flutter/material.dart';
import 'result_page.dart';

class MentalHealthTestPage extends StatefulWidget {
  @override
  _MentalHealthTestPageState createState() => _MentalHealthTestPageState();
}

class _MentalHealthTestPageState extends State<MentalHealthTestPage> {
  List<int> baiResponses = List.filled(21, 0);
  List<int> bdiResponses = List.filled(21, 0);
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  final List<String> baiQuestions = [
    "1. Numbness or tingling", "2. Feeling hot", "3. Wobbliness in legs",
    "4. Unable to relax", "5. Fear of worst happening", "6. Dizzy or lightheaded",
    "7. Heart pounding / racing", "8. Unsteady", "9. Terrified or afraid",
    "10. Nervous", "11. Feeling of choking", "12. Hands trembling",
    "13. Shaky / unsteady", "14. Fear of losing control", "15. Difficulty in breathing",
    "16. Fear of dying", "17. Scared", "18. Indigestion", "19. Faint / lightheaded",
    "20. Face flushed", "21. Hot / cold sweats"
  ];

  final List<String> bdiQuestions = [
    "1. Sadness", "2. Pessimism", "3. Past failure", "4. Loss of pleasure",
    "5. Guilty feelings", "6. Punishment feelings", "7. Self-dislike",
    "8. Self-criticalness", "9. Suicidal thoughts", "10. Crying", "11. Agitation",
    "12. Loss of interest", "13. Indecisiveness", "14. Worthlessness",
    "15. Loss of energy", "16. Changes in sleeping pattern", "17. Irritability",
    "18. Changes in appetite", "19. Difficulty concentrating",
    "20. Tiredness or fatigue", "21. Loss of interest in sex"
  ];

  Widget buildQuestion(String question, int index, bool isBai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: RadioListTile<int>(
                value: i,
                groupValue: isBai ? baiResponses[index] : bdiResponses[index],
                title: Text(i.toString()),
                onChanged: (value) {
                  setState(() {
                    if (isBai) {
                      baiResponses[index] = value!;
                    } else {
                      bdiResponses[index] = value!;
                    }
                  });
                },
                activeColor: const Color.fromARGB(255, 37, 151, 222),
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
        ),
      ],
    );
  }

  void calculateAndNavigate() {
    int baiScore = baiResponses.reduce((a, b) => a + b);
    int bdiScore = bdiResponses.reduce((a, b) => a + b);
    double height = double.tryParse(heightController.text) ?? 0.0;
    double weight = double.tryParse(weightController.text) ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          baiScore: baiScore,
          bdiScore: bdiScore,
          height: height,
          weight: weight,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FDF4), // Same pastel bg as LoginPage
      appBar: AppBar(
        title: const Text("Mental Health Test"),
        backgroundColor: const Color.fromARGB(255, 37, 151, 222), // Same greenAccent as LoginPage
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Enter your height (cm)", Icons.height),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Enter your weight (kg)", Icons.monitor_weight),
            ),
            const SizedBox(height: 30),
            const Text(
              "BAI Questionnaire",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(baiQuestions.length,
                (i) => buildQuestion(baiQuestions[i], i, true)),
            const SizedBox(height: 30),
            const Text(
              "BDI Questionnaire",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(bdiQuestions.length,
                (i) => buildQuestion(bdiQuestions[i], i, false)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: calculateAndNavigate,
                child: const Text("Submit", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 37, 151, 222),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
