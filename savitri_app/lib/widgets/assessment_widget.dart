import 'dart:async';
import 'package:flutter/material.dart';

enum AssessmentType { phq9, gad7 }

class AssessmentQuestion {
  final String id;
  final String question;
  final List<String> options;
  final List<int> scores;

  const AssessmentQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.scores,
  });
}

class AssessmentWidget extends StatefulWidget {
  final AssessmentType type;
  final Function(Map<String, int>)? onCompleted;
  final Function(String, int)? onAnswerChanged;

  const AssessmentWidget({
    super.key,
    required this.type,
    this.onCompleted,
    this.onAnswerChanged,
  });

  @override
  State<AssessmentWidget> createState() => _AssessmentWidgetState();
}

class _AssessmentWidgetState extends State<AssessmentWidget> {
  int currentQuestionIndex = 0;
  Map<String, int> answers = {};
  Timer? _autoAdvanceTimer;
  
  static const List<AssessmentQuestion> phq9Questions = [
    AssessmentQuestion(
      id: 'phq9_1',
      question: 'Little interest or pleasure in doing things',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'phq9_2',
      question: 'Feeling down, depressed, or hopeless',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'phq9_3',
      question: 'Trouble falling or staying asleep, or sleeping too much',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'phq9_4',
      question: 'Feeling tired or having little energy',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'phq9_5',
      question: 'Poor appetite or overeating',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
  ];

  static const List<AssessmentQuestion> gad7Questions = [
    AssessmentQuestion(
      id: 'gad7_1',
      question: 'Feeling nervous, anxious, or on edge',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'gad7_2',
      question: 'Not being able to stop or control worrying',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'gad7_3',
      question: 'Worrying too much about different things',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'gad7_4',
      question: 'Trouble relaxing',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
    AssessmentQuestion(
      id: 'gad7_5',
      question: 'Being so restless that it is hard to sit still',
      options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'],
      scores: [0, 1, 2, 3],
    ),
  ];

  List<AssessmentQuestion> get questions {
    return widget.type == AssessmentType.phq9 ? phq9Questions : gad7Questions;
  }

  String get assessmentTitle {
    return widget.type == AssessmentType.phq9 
        ? 'PHQ-9 Depression Assessment' 
        : 'GAD-7 Anxiety Assessment';
  }

  AssessmentQuestion get currentQuestion => questions[currentQuestionIndex];

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _selectAnswer(int score) {
    // Cancel any existing timer
    _autoAdvanceTimer?.cancel();
    
    setState(() {
      answers[currentQuestion.id] = score;
    });
    
    widget.onAnswerChanged?.call(currentQuestion.id, score);
    
    // Auto-advance after selection
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
          });
        } else {
          _completeAssessment();
        }
      }
    });
  }

  void _completeAssessment() {
    _autoAdvanceTimer?.cancel();
    widget.onCompleted?.call(answers);
  }

  void _previousQuestion() {
    _autoAdvanceTimer?.cancel();
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  int get totalScore {
    return answers.values.fold(0, (sum, score) => sum + score);
  }

  String get scoreInterpretation {
    if (widget.type == AssessmentType.phq9) {
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          
          const SizedBox(height: 20),
          
          // Assessment title and progress
          Text(
            assessmentTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Question ${currentQuestionIndex + 1} of ${questions.length}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Question
          Text(
            'Over the last 2 weeks, how often have you been bothered by:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            currentQuestion.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Answer options
          ...List.generate(currentQuestion.options.length, (index) {
            final isSelected = answers[currentQuestion.id] == currentQuestion.scores[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                elevation: isSelected ? 4 : 1,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _selectAnswer(currentQuestion.scores[index]),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected ? Colors.blue[50] : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey[400]!,
                              width: 2,
                            ),
                            color: isSelected ? Colors.blue : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            currentQuestion.options[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.blue[700] : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              TextButton.icon(
                key: const Key('assessment_previous_button'),
                onPressed: currentQuestionIndex > 0 ? _previousQuestion : null,
                icon: const Icon(Icons.arrow_back),
                label: Text('Previous'),
              ),
              
              // Progress text
              Text(
                '${answers.length}/${questions.length} answered',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // Show results if completed
          if (answers.length == questions.length) ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assessment Complete',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Score: $totalScore',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Interpretation: $scoreInterpretation',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
