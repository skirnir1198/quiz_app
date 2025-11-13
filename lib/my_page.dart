import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/inquiry_page.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:quiz_app/quiz_history_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = true;
  int _highestCriticalThinkingLevel = 0;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void initState() {
    super.initState();
    _fetchQuizHistory();
  }

  Future<void> _fetchQuizHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final quizEnds = await FirebaseFirestore.instance
        .collection('quiz_ends')
        .where('userId', isEqualTo: user.uid)
        .where('isCorrect', isEqualTo: true)
        .get();

    int maxLevel = 0;

    for (final doc in quizEnds.docs) {
      final data = doc.data();
      if (data['level'] > maxLevel) {
        maxLevel = data['level'];
      }
    }

    setState(() {
      _highestCriticalThinkingLevel = (maxLevel / 20 * 100).toInt();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Page')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizHistoryPage(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '最高クリティカルシンキング度',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_highestCriticalThinkingLevel%',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'タップして履歴を表示',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('アプリをレビューする'),
                    onPressed: () async {
                      if (await _inAppReview.isAvailable()) {
                        _inAppReview.requestReview();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('レビュー機能は現在ご利用いただけません。')),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('お問い合わせ'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InquiryPage(),
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
              ],
            ),
    );
  }
}
