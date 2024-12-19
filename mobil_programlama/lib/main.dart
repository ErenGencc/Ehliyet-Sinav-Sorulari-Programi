import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobil_programlama/database.dart';
import 'package:mobil_programlama/sorular.dart';
import 'ScoreHistory.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sınav Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sınav Uygulaması'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hoşgeldiniz',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizPage()), //
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Başlat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScoreHistoryPage()), //
                );
              },
              child: Container(
                width: 120,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Sonuçlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
//
class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double _score = 0; // Puanı double olarak tutuyoruz
  int _currentQuestionIndex = 0;

  // sorular.dart dosyasından tüm soruları alıyoruz
  final List<Map<String, dynamic>> _allQuestions = questions;

  // Rastgele 40 soru seçmek için kullanılacak liste
  List<Map<String, dynamic>> _selectedQuestions = [];

  @override
  void initState() {
    super.initState();
    _selectedQuestions = _selectRandomQuestions();
  }

  // Rastgele 40 soru seçen fonksiyon
  List<Map<String, dynamic>> _selectRandomQuestions() {
    // Tüm soruların sayısı
    int totalQuestions = _allQuestions.length;

    // Rastgele sıralama için bir liste indeksi oluştur
    List<int> indices = List<int>.generate(totalQuestions, (int index) => index);

    // Karıştır
    indices.shuffle();

    // İlk 40 indeksi al (rastgele 40 soru)
    List<Map<String, dynamic>> selected = [];
    for (int i = 0; i < min(40, totalQuestions); i++) {
      selected.add(_allQuestions[indices[i]]);
    }

    return selected;
  }

  void _checkAnswer(String selectedOption) {
    if (_selectedQuestions.isEmpty) return;

    if (_selectedQuestions[_currentQuestionIndex]['answer'] == selectedOption) {
      setState(() {
        _score += 2.5;  // Her doğru cevap için 2.5 puan artır
      });
    }

    if (_currentQuestionIndex < _selectedQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _saveScore();
      _showResultDialog();
    }
  }

  void _saveScore() async {
    await _databaseHelper.insertScore(_score);
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sınav Bitti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Aldığınız Puan: $_score'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScoreHistoryPage()),
                );
              },
              child: Text('Sonuçlara Git'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _selectedQuestions = _selectRandomQuestions(); // Yeni soruları seç
    });
  }

  @override
  Widget build(BuildContext context) {
    // Eğer _selectedQuestions boşsa, yani soru yoksa, bir şey göstermeyi durdur
    if (_selectedQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Sınav Uygulaması'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final question = _selectedQuestions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Sınav Uygulaması'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (question.containsKey('image'))
              Image.asset(
                question['image'],
                height: 200,
              ),
            SizedBox(height: 20),
            Text(
              'Soru ${_currentQuestionIndex + 1}/${_selectedQuestions.length}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              question['question'],
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ...question['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
