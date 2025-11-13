import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  List<Map<String, dynamic>> _quizHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizHistory();
  }

  Future<void> _fetchQuizHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final quizEnds = await FirebaseFirestore.instance
        .collection('quiz_ends')
        .where('userId', isEqualTo: user.uid)
        .where('isCorrect', isEqualTo: true)
        .get();

    final history = <Map<String, dynamic>>[];
    for (final doc in quizEnds.docs) {
      history.add(doc.data());
    }

    history.sort((a, b) {
      final aTimestamp = a['timestamp'] as Timestamp?;
      final bTimestamp = b['timestamp'] as Timestamp?;
      if (aTimestamp == null && bTimestamp == null) return 0;
      if (aTimestamp == null) return 1;
      if (bTimestamp == null) return -1;
      return bTimestamp.compareTo(aTimestamp); // Sort descending
    });

    if (mounted) {
      setState(() {
        _quizHistory = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('正解したクイズ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _quizHistory.length,
              itemBuilder: (context, index) {
                final item = _quizHistory[index];
                final timestamp = item['timestamp'] as Timestamp?;
                final date = timestamp?.toDate();
                final formattedDate = date != null
                    ? '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}'
                    : 'No date';

                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(item['quizTitle'] ?? 'No title'),
                  subtitle: Text(formattedDate),
                );
              },
            ),
    );
  }
}
