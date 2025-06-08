import 'package:flutter/material.dart';
import '../widgets/assessment_widget.dart';

class AssessmentScreen extends StatefulWidget {
  final AssessmentType assessmentType;

  const AssessmentScreen({
    Key? key,
    required this.assessmentType,
  }) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  Map<String, int> assessmentResults = {};
  bool isCompleted = false;

  void _onAssessmentCompleted(Map<String, int> results) {
    setState(() {
      assessmentResults = results;
      isCompleted = true;
    });
    
    // Show completion dialog
    _showCompletionDialog();
  }

  void _onAnswerChanged(String questionId, int score) {
    setState(() {
      assessmentResults[questionId] = score;
    });
  }

  void _showCompletionDialog() {
    final totalScore = assessmentResults.values.fold(0, (sum, score) => sum + score);
    final interpretation = _getScoreInterpretation(totalScore);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Assessment Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your score: $totalScore'),
              const SizedBox(height: 8),
              Text('Assessment: $interpretation'),
              const SizedBox(height: 16),
              const Text(
                'This assessment is for informational purposes only and should not replace professional medical advice.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(assessmentResults); // Return to previous screen with results
              },
              child: const Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _retakeAssessment();
              },
              child: const Text('Retake'),
            ),
          ],
        );
      },
    );
  }

  void _retakeAssessment() {
    setState(() {
      assessmentResults = {};
      isCompleted = false;
    });
  }

  String _getScoreInterpretation(int totalScore) {
    if (widget.assessmentType == AssessmentType.phq9) {
      if (totalScore <= 4) return 'Minimal depression';
      if (totalScore <= 9) return 'Mild depression';
      if (totalScore <= 14) return 'Moderate depression';
      if (totalScore <= 19) return 'Moderately severe depression';
      return 'Severe depression';
    } else {
      if (totalScore <= 4) return 'Minimal anxiety';
      if (totalScore <= 9) return 'Mild anxiety';
      if (totalScore <= 14) return 'Moderate anxiety';
      return 'Severe anxiety';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.assessmentType == AssessmentType.phq9 
              ? 'Depression Assessment'
              : 'Anxiety Assessment'
        ),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        titleTextStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.assessmentType == AssessmentType.phq9 
                            ? 'PHQ-9 Depression Screening'
                            : 'GAD-7 Anxiety Screening',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.assessmentType == AssessmentType.phq9
                            ? 'This questionnaire helps assess symptoms of depression over the past 2 weeks.'
                            : 'This questionnaire helps assess symptoms of anxiety over the past 2 weeks.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please answer each question honestly. This is confidential and will help provide better support.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Assessment Widget
                AssessmentWidget(
                  type: widget.assessmentType,
                  onCompleted: _onAssessmentCompleted,
                  onAnswerChanged: _onAnswerChanged,
                ),
                
                const SizedBox(height: 32),
                
                // Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This screening tool is not a diagnostic instrument. If you are experiencing persistent symptoms, please consult with a healthcare professional.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
