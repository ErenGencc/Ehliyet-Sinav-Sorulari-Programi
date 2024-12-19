import 'package:flutter/material.dart';
import 'package:mobil_programlama/database.dart';

class ScoreHistoryPage extends StatelessWidget {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sonuçlar'),
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _databaseHelper.getScores(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            final scores = snapshot.data!;
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                final double currentScore = score['score'];
                return ListTile(
                  title: Text('Puan: ${score['score']}'),
                  subtitle: Text(currentScore >= 70 ? 'Geçti' : 'Kaldı'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
