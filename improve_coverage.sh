#!/bin/bash

# Function to display help information
display_help() {
  echo "Coverage Improvement Script"
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help       Display this help message"
  echo "  -u, --uncovered  Show uncovered files and their coverage"
  echo "  -t, --top N      Show top N files with lowest coverage (default: 5)"
  echo "  -r, --run        Run coverage and generate report"
  echo "  -a, --all        Show details for all files"
  echo ""
}

# Default values
SHOW_UNCOVERED=false
SHOW_TOP=false
TOP_COUNT=5
RUN_COVERAGE=false
SHOW_ALL=false
TARGET_COVERAGE=80  # Target coverage percentage

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      display_help
      exit 0
      ;;
    -u|--uncovered)
      SHOW_UNCOVERED=true
      shift
      ;;
    -t|--top)
      SHOW_TOP=true
      if [[ $2 =~ ^[0-9]+$ ]]; then
        TOP_COUNT=$2
        shift
      fi
      shift
      ;;
    -r|--run)
      RUN_COVERAGE=true
      shift
      ;;
    -a|--all)
      SHOW_ALL=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help to see available options"
      exit 1
      ;;
  esac
done

# Run coverage if requested
if [ "$RUN_COVERAGE" = true ]; then
  ./coverage_report.sh
fi

# Check if coverage data exists
if [ ! -f "coverage/lcov.info" ]; then
  echo "Coverage data not found. Run with -r or --run option first."
  exit 1
fi

# Function to extract and display coverage statistics by file
analyze_coverage() {
  echo "Analyzing coverage data..."
  echo ""

  # Create a temporary file to store coverage info
  tmpfile=$(mktemp)
  
  # Extract coverage information by file
  echo "Coverage by file:"
  echo "----------------"
  echo "Coverage | Lines    | File"
  echo "---------|----------|------------------------------"

  awk '/SF:/ {file=$0}
       /LH:/ {hit=$0; getline; total=$0; 
              gsub("SF:", "", file); 
              gsub("LH:", "", hit); 
              gsub("LF:", "", total);
              percent = total > 0 ? (hit/total)*100 : 0;
              printf "%7.1f%% | %4s/%-4s | %s\n", percent, hit, total, file > "'"$tmpfile"'";
              printf "%.1f|%s|%s|%s\n", percent, hit, total, file > "'"$tmpfile.data"'";
             }' coverage/lcov.info

  # Sort by coverage percentage and display
  if [ "$SHOW_ALL" = true ]; then
    sort -n "$tmpfile"
  else
    sort -n "$tmpfile" | head -n 10
  fi

  # Show uncovered files if requested
  if [ "$SHOW_UNCOVERED" = true ]; then
    echo ""
    echo "Files with no coverage:"
    echo "----------------------"
    grep "^    0.0%" "$tmpfile" | sort -k5
    echo ""
  fi

  # Show top files with lowest coverage
  if [ "$SHOW_TOP" = true ]; then
    echo ""
    echo "Top $TOP_COUNT files with lowest coverage (excluding 0%):"
    echo "--------------------------------------------------------"
    grep -v "^    0.0%" "$tmpfile" | head -n "$TOP_COUNT"
    echo ""
  fi

  # Calculate coverage improvement needed to reach target
  echo ""
  echo "Coverage gap analysis (target: ${TARGET_COVERAGE}%):"
  echo "----------------------------------------------"
  echo "File | Current | Missing | Lines Needed"
  echo "-----|---------|---------|-------------"
  
  awk -F'|' '{ 
    current=$1; 
    hit=$2; 
    total=$3; 
    file=$4;
    gap='$TARGET_COVERAGE'-current;
    if (gap > 0) {
      missing_lines_exact=(gap/100)*total;
      missing_lines=int(missing_lines_exact + 0.999);  # ceiling
      printf "%-50s | %6.1f%% | %6.1f%% | %5d\n", file, current, gap, missing_lines;
    }
  }' "$tmpfile.data" | sort -t'|' -k3nr | head -n 10
  
  # Overall coverage summary
  echo ""
  echo "Overall coverage summary:"
  echo "-----------------------"
  lcov --summary coverage/lcov.info 2>/dev/null
  echo ""

  # Clean up
  rm "$tmpfile" "$tmpfile.data"
}

analyze_coverage

echo ""
echo "Recommendations for improving coverage:"
echo "-------------------------------------"
echo "1. Focus on add_transaction_screen.dart - very low coverage ($(grep "add_transaction_screen.dart" "$tmpfile" | awk '{print $1}'))"
echo "2. Improve database_helper.dart coverage - critical component"
echo "3. Add more widget tests for screens and widgets"
echo "4. Test error conditions and edge cases in all components"
echo ""
echo "Additional testing strategies:"
echo "----------------------------"
echo "1. Create a test_screen.dart helper to test UI components"
echo "2. Mock external dependencies (database, providers)"
echo "3. Test navigation and user interactions"
echo "4. Check error handling and loading states"
echo ""
echo "To run a specific test file:"
echo "  flutter test test/path/to/test_file.dart"
echo ""
