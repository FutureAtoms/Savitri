#!/bin/bash
cd /Users/abhilashchadhar/uncloud/savitri/savitri_app

# Fix the rest of the const constructors
sed -i '' 's/Text(/const Text(/g' lib/screens/biometric_enrollment_screen.dart
sed -i '' 's/SizedBox(/const SizedBox(/g' lib/widgets/assessment_widget.dart
sed -i '' 's/Icon(/const Icon(/g' lib/widgets/biometric_login_button.dart

# Fix const in tests
sed -i '' 's/questions = \[/questions = const \[/' test/widgets/assessment_widget_test.dart
sed -i '' 's/AssessmentQuestion(/const AssessmentQuestion(/' test/widgets/assessment_widget_test.dart

# Fix const declarations
sed -i '' '129s/final/const/; 314s/final/const/' test/widgets/emotion_indicator_test.dart

echo "Const constructor fixes applied!"
