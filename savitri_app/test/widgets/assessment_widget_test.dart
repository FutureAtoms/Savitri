import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:savitri_app/widgets/assessment_widget.dart';

void main() {
  group('AssessmentWidget', () {
    testWidgets('renders correctly with 5 PHQ-9 questions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Verify the assessment title and question counter
      expect(find.text('PHQ-9 Depression Assessment'), findsOneWidget);
      expect(find.text('Question 1 of 5'), findsOneWidget);
      
      // Verify progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Verify first question is displayed
      expect(find.text('Little interest or pleasure in doing things'), findsOneWidget);
      
      // Verify all answer options are present
      expect(find.text('Not at all'), findsOneWidget);
      expect(find.text('Several days'), findsOneWidget);
      expect(find.text('More than half the days'), findsOneWidget);
      expect(find.text('Nearly every day'), findsOneWidget);
    });

    testWidgets('renders correctly with 5 GAD-7 questions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.gad7,
            ),
          ),
        ),
      );

      // Verify the assessment title and question counter
      expect(find.text('GAD-7 Anxiety Assessment'), findsOneWidget);
      expect(find.text('Question 1 of 5'), findsOneWidget);
      
      // Verify first question is displayed
      expect(find.text('Feeling nervous, anxious, or on edge'), findsOneWidget);
    });

    testWidgets('advances to next question after selecting answer', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Initially should show question 1
      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.text('Little interest or pleasure in doing things'), findsOneWidget);

      // Select first answer option
      await tester.tap(find.text('Not at all'));
      await tester.pump();
      
      // Wait for auto-advance
      await tester.pump(const Duration(milliseconds: 800));

      // Should now show question 2
      expect(find.text('Question 2 of 5'), findsOneWidget);
      expect(find.text('Feeling down, depressed, or hopeless'), findsOneWidget);
    });

    testWidgets('can navigate back to previous question', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Answer first question
      await tester.tap(find.text('Not at all'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Should be on question 2
      expect(find.text('Question 2 of 5'), findsOneWidget);

      // Tap previous button
      await tester.tap(find.text('Previous'));
      await tester.pump();

      // Should be back to question 1
      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.text('Little interest or pleasure in doing things'), findsOneWidget);
    });

    testWidgets('previous button is disabled on first question', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      final button = tester.widget<TextButton>(find.byKey(const Key('assessment_previous_button')));
      expect(button.onPressed, isNull);
    });

    testWidgets('tracks progress correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Initially 0 answered
      expect(find.text('0/5 answered'), findsOneWidget);

      // Answer first question
      await tester.tap(find.text('Not at all'));
      await tester.pump();

      // Should show 1 answered
      expect(find.text('1/5 answered'), findsOneWidget);
      
      // Wait for auto-advance and answer second question
      await tester.pump(const Duration(milliseconds: 800));
      await tester.tap(find.text('Several days'));
      await tester.pump();

      // Should show 2 answered
      expect(find.text('2/5 answered'), findsOneWidget);
      
      // Clean up the timer
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('calls onAnswerChanged callback when answer is selected', (WidgetTester tester) async {
      String? lastQuestionId;
      int? lastScore;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
              onAnswerChanged: (questionId, score) {
                lastQuestionId = questionId;
                lastScore = score;
              },
            ),
          ),
        ),
      );

      // Select first answer (score 0)
      await tester.tap(find.text('Not at all'));
      await tester.pump();

      expect(lastQuestionId, equals('phq9_1'));
      expect(lastScore, equals(0));
      
      // Clean up the timer
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('calls onCompleted callback when all questions answered', (WidgetTester tester) async {
      Map<String, int>? completedAnswers;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
              onCompleted: (answers) {
                completedAnswers = answers;
              },
            ),
          ),
        ),
      );

      // Answer all 5 questions
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Not at all'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
      }

      expect(completedAnswers, isNotNull);
      expect(completedAnswers!.length, equals(5));
      expect(completedAnswers!['phq9_1'], equals(0));
    });

    testWidgets('shows completion summary with correct score', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Answer all questions with different scores
      final scores = [0, 1, 2, 3, 1]; // Total = 7
      
      for (int i = 0; i < 5; i++) {
        final options = ['Not at all', 'Several days', 'More than half the days', 'Nearly every day'];
        await tester.tap(find.text(options[scores[i]]));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
      }

      // Should show completion summary
      expect(find.text('Assessment Complete'), findsOneWidget);
      expect(find.text('Total Score: 7'), findsOneWidget);
      expect(find.text('Interpretation: Mild depression'), findsOneWidget);
    });

    testWidgets('shows correct interpretation for different score ranges', (WidgetTester tester) async {
      // Test minimal depression (score 0-4)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Answer all with "Not at all" (score 0 each)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Not at all'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
      }

      expect(find.text('Interpretation: Minimal depression'), findsOneWidget);
    });

    testWidgets('handles GAD-7 scoring correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.gad7,
            ),
          ),
        ),
      );

      // Answer all with "Several days" (score 1 each, total 5)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Several days'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
      }

      expect(find.text('Total Score: 5'), findsOneWidget);
      expect(find.text('Interpretation: Mild anxiety'), findsOneWidget);
    });

    testWidgets('maintains selected answer highlighting', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Select "Several days" option
      await tester.tap(find.text('Several days'));
      await tester.pump();

      // Find the container that should be highlighted
      final containers = find.byType(Container);
      bool foundHighlightedContainer = false;
      
      for (var container in tester.widgetList<Container>(containers)) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          if (decoration.border is Border) {
            final border = decoration.border as Border;
            if (border.top.color == Colors.blue && border.top.width == 2) {
              foundHighlightedContainer = true;
              break;
            }
          }
        }
      }
      
      expect(foundHighlightedContainer, isTrue);
      
      // Clean up the timer
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('preserves answers when navigating back and forth', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Answer first question with "Several days"
      await tester.tap(find.text('Several days'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Answer second question with "Not at all"
      await tester.tap(find.text('Not at all'));
      await tester.pump();

      // Go back to first question
      await tester.tap(find.text('Previous'));
      await tester.pump();

      // Verify first question still has "Several days" selected
      // This is checked by looking for the highlighted container
      final containers = find.byType(Container);
      bool foundCorrectHighlight = false;
      
      for (var container in tester.widgetList<Container>(containers)) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.color == Colors.blue[50]) {
          foundCorrectHighlight = true;
          break;
        }
      }
      
      expect(foundCorrectHighlight, isTrue);
      
      // Clean up the timer
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('updates progress indicator correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssessmentWidget(
              type: AssessmentType.phq9,
            ),
          ),
        ),
      );

      // Initially progress should be 1/5 = 0.2
      var progressIndicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, equals(0.2));

      // Answer first question
      await tester.tap(find.text('Not at all'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      // Progress should now be 2/5 = 0.4
      progressIndicator = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, equals(0.4));
    });
  });
}
