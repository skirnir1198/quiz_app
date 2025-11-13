import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  final _formKey = GlobalKey<FormState>();
  final _inquiryController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _inquiryController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ログインしていません。')));
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('inquiries').add({
          'userId': user.uid,
          'content': _inquiryController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('お問い合わせを送信しました。')));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('お問い合わせ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _inquiryController,
              decoration: const InputDecoration(
                labelText: 'お問い合わせ内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'お問い合わせ内容を入力してください。';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitInquiry,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
