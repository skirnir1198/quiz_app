import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:quiz_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  final Question question;
  final bool isCorrect;
  final String selectedOption;

  const ResultPage({
    super.key,
    required this.question,
    required this.isCorrect,
    required this.selectedOption,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    _saveQuizResult();
    _requestReviewIfAppropriate();
  }

  Future<void> _saveQuizResult() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('quiz_ends').add({
        'userId': user.uid,
        'quizTitle': widget.question.title,
        'isCorrect': widget.isCorrect,
        'selectedOption': widget.selectedOption,
        'level': widget.question.level,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _requestReviewIfAppropriate() async {
    // 正解した時のみレビューを依頼
    if (!widget.isCorrect) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      const lastRequestKey = 'last_review_request_timestamp';
      const correctAnswersKey = 'correct_answers_count';

      // 正解回数をインクリメント
      final correctAnswersCount = (prefs.getInt(correctAnswersKey) ?? 0) + 1;
      await prefs.setInt(correctAnswersKey, correctAnswersCount);

      final lastRequestTimestamp = prefs.getInt(lastRequestKey);
      final thirtyDaysInMillis = 30 * 24 * 60 * 60 * 1000;

      // 最後に依頼してから30日以上経過しているかチェック
      if (lastRequestTimestamp != null &&
          DateTime.now().millisecondsSinceEpoch - lastRequestTimestamp <
              thirtyDaysInMillis) {
        return;
      }

      // 正解回数が3回に達したらレビューを依頼
      if (correctAnswersCount >= 3) {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
          await prefs.setInt(
            lastRequestKey,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
    } catch (e) {
      // エラーが発生してもアプリの動作に影響を与えないようにする
      debugPrint('Error requesting review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final criticalThinkingLevel = (widget.question.level / 20 * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isCorrect ? 'Correct!' : 'Incorrect'),
        backgroundColor: widget.isCorrect ? Colors.green : Colors.red,
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
              if (widget.isCorrect) ...[
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
              ] else ...[
                Text(
                  '残念！',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(widget.question.explanation, textAlign: TextAlign.center),
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
