#!/usr/bin/env python3

import re

def analyze_lcov_file(filename):
    """Analyze lcov.info file and calculate coverage percentage."""
    files_coverage = {}
    current_file = None
    lines_found = 0
    lines_hit = 0
    
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            
            # Source file
            if line.startswith('SF:'):
                current_file = line[3:]
                files_coverage[current_file] = {'lines_found': 0, 'lines_hit': 0}
            
            # Line data
            elif line.startswith('DA:'):
                parts = line[3:].split(',')
                if len(parts) >= 2:
                    hit_count = int(parts[1])
                    files_coverage[current_file]['lines_found'] += 1
                    if hit_count > 0:
                        files_coverage[current_file]['lines_hit'] += 1
            
            # Lines found
            elif line.startswith('LF:'):
                files_coverage[current_file]['lines_found'] = int(line[3:])
            
            # Lines hit
            elif line.startswith('LH:'):
                files_coverage[current_file]['lines_hit'] = int(line[3:])
    
    # Calculate totals
    total_lines_found = sum(f['lines_found'] for f in files_coverage.values())
    total_lines_hit = sum(f['lines_hit'] for f in files_coverage.values())
    
    # Print summary
    print("Test Coverage Report")
    print("=" * 80)
    
    # Sort files by path
    for file_path in sorted(files_coverage.keys()):
        data = files_coverage[file_path]
        if data['lines_found'] > 0:
            coverage = (data['lines_hit'] / data['lines_found']) * 100
            print(f"{file_path}")
            print(f"  Lines: {data['lines_hit']}/{data['lines_found']} ({coverage:.1f}%)")
    
    print("=" * 80)
    
    if total_lines_found > 0:
        total_coverage = (total_lines_hit / total_lines_found) * 100
        print(f"Total Coverage: {total_lines_hit}/{total_lines_found} lines ({total_coverage:.1f}%)")
    else:
        print("No coverage data found")

if __name__ == "__main__":
    analyze_lcov_file("coverage/lcov.info")
