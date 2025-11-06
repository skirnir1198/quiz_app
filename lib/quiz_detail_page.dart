import 'package:flutter/material.dart';
import 'package:quiz_app/main.dart';

import 'package:quiz_app/result_page.dart';



class QuizDetailPage extends StatefulWidget {

  final Question question;



  const QuizDetailPage({super.key, required this.question});



  @override

  State<QuizDetailPage> createState() => _QuizDetailPageState();

}



class _QuizDetailPageState extends State<QuizDetailPage> {

  String? _selectedOption;



  void _checkAnswer() {

    if (_selectedOption == null) {

      ScaffoldMessenger.of(

        context,

      ).showSnackBar(const SnackBar(content: Text('Please select an option.')));

      return;

    }



    final bool isCorrect = _selectedOption == widget.question.answer;



    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (context) => ResultPage(question: widget.question, isCorrect: isCorrect),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  widget.question.question,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ...widget.question.options.map((option) {
                return Card(
                  elevation: _selectedOption == option ? 4.0 : 1.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: _selectedOption == option
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _checkAnswer,
                child: const Text('答え合わせ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
