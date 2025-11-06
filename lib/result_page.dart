
import 'package:flutter/material.dart';
import 'package:quiz_app/main.dart';

class ResultPage extends StatelessWidget {
  final Question question;
  final bool isCorrect;

  const ResultPage({super.key, required this.question, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final criticalThinkingLevel = (question.level / 20 * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        foregroundColor: theme.colorScheme.onPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isCorrect)
                ...[
                  Text(
                    'クリティカルシンキング度',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$criticalThinkingLevel%',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('クイズ一覧に戻る'),
                  ),
                ]
              else
                ...[
                  Text(
                    '残念！',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.explanation,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('もう一度問題を解く'),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
