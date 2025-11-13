import 'package:quiz_app/my_page.dart';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/quiz_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const QuizListPage(),
    );
  }
}

class Quiz {
  final String title;
  final List<Question> questions;

  Quiz({required this.title, required this.questions});
}

class Question {
  final int level;
  final String title;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;

  Question({
    required this.level,
    required this.title,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      level: json['level'],
      title: json['title'],
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
      explanation: json['explanation'],
    );
  }
}

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  late Future<Quiz> _quiz;
  Map<String, String> _quizStatus = {};

  @override
  void initState() {
    super.initState();
    _quiz = loadQuiz();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchQuizStatus();
  }

  Future<void> _fetchQuizStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final quizEnds = await FirebaseFirestore.instance
        .collection('quiz_ends')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    final status = <String, String>{};
    for (final doc in quizEnds.docs) {
      final data = doc.data();
      final title = data['quizTitle'] as String;
      if (!status.containsKey(title)) {
        status[title] = data['isCorrect'] ? 'correct' : 'incorrect';
      }
    }

    if (mounted) {
      setState(() {
        _quizStatus = status;
      });
    }
  }

  Future<Quiz> loadQuiz() async {
    final String response = await rootBundle.loadString(
      'assets/critical_thinking_quiz.json',
    );
    final data = await json.decode(response) as List;
    List<Question> questions = data.map((i) => Question.fromJson(i)).toList();
    return Quiz(title: "クリティカルシンキングクイズ", questions: questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('クリティカルシンキングクイズ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Quiz>(
        future: _quiz,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.questions.length,
              itemBuilder: (BuildContext context, int index) {
                final question = snapshot.data!.questions[index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          "Lv.${question.level}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    title: Text(
                      question.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: _quizStatus[question.title] == 'correct'
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : _quizStatus[question.title] == 'incorrect'
                        ? const Icon(Icons.cancel, color: Colors.red)
                        : const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        FirebaseFirestore.instance
                            .collection('quiz_starts')
                            .add({
                              'userId': user.uid,
                              'quizTitle': question.title,
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                      }
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuizDetailPage(question: question),
                        ),
                      ).then((_) {
                        _fetchQuizStatus();
                      });
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
