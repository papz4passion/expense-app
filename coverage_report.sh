#!/bin/bash

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Remove old coverage data
rm -rf coverage
mkdir -p coverage

# Run tests with coverage
flutter test --coverage

# Remove unwanted files from the coverage report
if [ -f "lcov.info" ]; then
  echo "Filtering coverage data..."
  lcov --remove coverage/lcov.info --output-file coverage/lcov.info $(cat lcov.info | grep -v "^#" | sed 's/^SF://')
fi

# Generate HTML report (if lcov is installed)
if command -v lcov >/dev/null 2>&1; then
  echo "Generating HTML report..."
  genhtml coverage/lcov.info -o coverage/html
  echo "HTML report generated at coverage/html/index.html"
  
  # Open the report on macOS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open coverage/html/index.html
  fi
else
  echo "lcov not found. Install it to generate HTML reports:"
  echo "  - macOS: brew install lcov"
  echo "  - Ubuntu/Debian: sudo apt-get install lcov"
  echo "  - Windows: See https://github.com/linux-test-project/lcov"
fi

# Show a summary of the coverage
echo -e "\nCoverage Summary:"
lcov --summary coverage/lcov.info 2>/dev/null || echo "Install lcov for a detailed summary"

echo -e "\nCoverage data saved to coverage/lcov.info"
