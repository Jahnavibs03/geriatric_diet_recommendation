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
    "1. Numbness or tingling",
    "2. Feeling hot",
    "3. Wobbliness in legs",
    "4. Unable to relax",
    "5. Fear of worst happening",
    "6. Dizzy or lightheaded",
    "7. Heart pounding / racing",
    "8. Unsteady",
    "9. Terrified or afraid",
    "10. Nervous",
    "11. Feeling of choking",
    "12. Hands trembling",
    "13. Shaky / unsteady",
    "14. Fear of losing control",
    "15. Difficulty in breathing",
    "16. Fear of dying",
    "17. Scared",
    "18. Indigestion",
    "19. Faint / lightheaded",
    "20. Face flushed",
    "21. Hot / cold sweats"
  ];

  final List<String> bdiQuestions = [
    "1. Sadness",
    "2. Pessimism",
    "3. Past failure",
    "4. Loss of pleasure",
    "5. Guilty feelings",
    "6. Punishment feelings",
    "7. Self-dislike",
    "8. Self-criticalness",
    "9. Suicidal thoughts",
    "10. Crying",
    "11. Agitation",
    "12. Loss of interest",
    "13. Indecisiveness",
    "14. Worthlessness",
    "15. Loss of energy",
    "16. Changes in sleeping pattern",
    "17. Irritability",
    "18. Changes in appetite",
    "19. Difficulty concentrating",
    "20. Tiredness or fatigue",
    "21. Loss of interest in sex"
  ];

  Widget buildQuestion(String question, int index, bool isBai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text("Mental Health Test")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Enter your height (cm):"),
            TextField(
                controller: heightController,
                keyboardType: TextInputType.number),
            SizedBox(height: 10),
            Text("Enter your weight (kg):"),
            TextField(
                controller: weightController,
                keyboardType: TextInputType.number),
            SizedBox(height: 20),
            Text("BAI Questionnaire",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...List.generate(baiQuestions.length,
                (i) => buildQuestion(baiQuestions[i], i, true)),
            SizedBox(height: 20),
            Text("BDI Questionnaire",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...List.generate(bdiQuestions.length,
                (i) => buildQuestion(bdiQuestions[i], i, false)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateAndNavigate,
              child: Text("Submit"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            )
          ],
        ),
      ),
    );
  }
}
