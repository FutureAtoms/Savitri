#!/bin/bash
cd /Users/abhilashchadhar/uncloud/savitri/savitri_app

# Fix all withValues to withOpacity
echo "Fixing withValues to withOpacity..."

# Replace withValues(alpha: x) with withOpacity(x) 
find lib test -name "*.dart" -type f -exec sed -i '' 's/\.withValues(alpha:[[:space:]]*\([0-9.]*\))/.withOpacity(\1)/g' {} \;

# Fix toARGB32 - replace with value (which gives the 32-bit ARGB value)
echo "Fixing toARGB32..."
find lib test -name "*.dart" -type f -exec sed -i '' 's/\.toARGB32()/.value/g' {} \;

echo "All fixes applied!"

# Run flutter analyze to check if there are any remaining issues
echo "Running flutter analyze..."
flutter analyze
