#!/bin/bash
cd /Users/abhilashchadhar/uncloud/savitri/savitri_app

echo "Fixing Color API for Flutter 3.22.2 compatibility..."

# For Flutter 3.22.2, we need to use withAlpha instead of withValues
# Convert .withValues(alpha: 0.x) to .withAlpha((0.x * 255).round())
# But since withOpacity already exists and works, let's keep using that

# First, revert any changes to restore original withValues calls
find lib test -name "*.dart" -type f -exec sed -i '' 's/\.withOpacity(\([0-9.]*\))/.withValues(alpha: \1)/g' {} \;

# Now fix withValues properly for Flutter 3.22.2
# Replace .withValues(alpha: x) with .withAlpha((x * 255).round())
echo "Converting withValues to withAlpha..."
find lib test -name "*.dart" -type f -exec perl -i -pe 's/\.withValues\(alpha:\s*([0-9.]+)\)/.withAlpha((($1 * 255).round()))/g' {} \;

# Fix toARGB32 - in Flutter 3.22.2, we should use .value
echo "Fixing toARGB32 to value..."
find lib test -name "*.dart" -type f -exec sed -i '' 's/\.toARGB32()/.value/g' {} \;

# Actually, let's just use withOpacity which should work in Flutter 3.22.2
echo "Using withOpacity for compatibility..."
find lib test -name "*.dart" -type f -exec perl -i -pe 's/\.withAlpha\(\(\(([0-9.]+) \* 255\)\.round\(\)\)\)/.withOpacity($1)/g' {} \;

echo "All fixes applied!"

# Run flutter analyze to check
echo "Running flutter analyze..."
flutter analyze --no-fatal-infos
