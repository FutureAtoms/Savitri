#!/bin/bash
cd /Users/abhilashchadhar/uncloud/savitri/savitri_app

# Replace withOpacity with withValues
files=(
  "lib/widgets/biometric_login_button.dart"
  "lib/widgets/therapeutic_visual_3d.dart"
  "lib/screens/biometric_enrollment_screen.dart"
  "lib/screens/therapy_screen.dart"
  "lib/utils/theme.dart"
  "test/widgets/therapeutic_visual_3d_test.dart"
)

for file in "${files[@]}"; do
  echo "Processing $file..."
  # Replace withOpacity(x) with withValues(opacity: x)
  sed -i '' 's/\.withOpacity(\([^)]*\))/.withValues(opacity: \1)/g' "$file"
done

echo "All withOpacity deprecations fixed!"
