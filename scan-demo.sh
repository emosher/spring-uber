#!/usr/bin/env bash

echo "=== Vulnerability Scanning Demo ==="
echo "Comparing DockerHub vs Bitnami Secure Images"
echo

# Build both versions
echo "Building applications..."
docker compose build

echo
echo "Scanning images for vulnerabilities..."
echo

# Function to count vulnerabilities by severity
count_vulnerabilities() {
    local image=$1
    local temp_file="/tmp/grype_output_$(basename $image).json"
    
    # Run grype and save JSON output
    grype "$image" --output json > "$temp_file" 2>/dev/null
    
    # Count vulnerabilities by severity using jq
    local critical=$(jq '[.matches[] | select(.vulnerability.severity == "Critical")] | length' "$temp_file" 2>/dev/null || echo 0)
    local high=$(jq '[.matches[] | select(.vulnerability.severity == "High")] | length' "$temp_file" 2>/dev/null || echo 0)
    local medium=$(jq '[.matches[] | select(.vulnerability.severity == "Medium")] | length' "$temp_file" 2>/dev/null || echo 0)
    local low=$(jq '[.matches[] | select(.vulnerability.severity == "Low")] | length' "$temp_file" 2>/dev/null || echo 0)
    local negligible=$(jq '[.matches[] | select(.vulnerability.severity == "Negligible")] | length' "$temp_file" 2>/dev/null || echo 0)
    
    # Calculate total
    local total=$((critical + high + medium + low + negligible))
    
    # Clean up temp file
    rm -f "$temp_file"
    
    echo "$critical,$high,$medium,$low,$negligible,$total"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required for JSON processing. Please install jq first."
    echo "  Ubuntu/Debian: apt-get install jq"
    echo "  macOS: brew install jq"
    echo "  RHEL/CentOS: yum install jq"
    exit 1
fi

# Scan DockerHub version
echo "Scanning DockerHub image..."
dhb_results=$(count_vulnerabilities "spring-uber-app-dhb:latest")

# Scan Bitnami Secure Images version  
echo "Scanning Bitnami Secure Images..."
bsi_results=$(count_vulnerabilities "spring-uber-app-bsi:latest")

# Parse results
IFS=',' read -r dhb_crit dhb_high dhb_med dhb_low dhb_negl dhb_total <<< "$dhb_results"
IFS=',' read -r bsi_crit bsi_high bsi_med bsi_low bsi_negl bsi_total <<< "$bsi_results"

# Calculate differences
crit_diff=$((dhb_crit - bsi_crit))
high_diff=$((dhb_high - bsi_high))
med_diff=$((dhb_med - bsi_med))
low_diff=$((dhb_low - bsi_low))
negl_diff=$((dhb_negl - bsi_negl))
total_diff=$((dhb_total - bsi_total))

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo
echo "=== VULNERABILITY COMPARISON SUMMARY ==="
echo

# Print header
printf "%-25s | %-10s | %-10s | %-12s\n" "SEVERITY" "DOCKERHUB" "BITNAMI" "DIFFERENCE"
printf "%-25s-+-%-10s-+-%-10s-+-%-12s\n" "-------------------------" "----------" "----------" "------------"

# Print rows with color coding for differences
print_row() {
    local severity=$1
    local dhb_count=$2
    local bsi_count=$3
    local diff=$4
    
    if [ $diff -gt 0 ]; then
        diff_color=$GREEN
        diff_text="-$diff"
    elif [ $diff -lt 0 ]; then
        diff_color=$RED
        diff_text="+$((-diff))"
    else
        diff_color=$NC
        diff_text="0"
    fi
    
    printf "%-25s | %-10s | %-10s | ${diff_color}%-12s${NC}\n" "$severity" "$dhb_count" "$bsi_count" "$diff_text"
}

print_row "Critical" "$dhb_crit" "$bsi_crit" "$crit_diff"
print_row "High" "$dhb_high" "$bsi_high" "$high_diff"
print_row "Medium" "$dhb_med" "$bsi_med" "$med_diff"
print_row "Low" "$dhb_low" "$bsi_low" "$low_diff"
print_row "Negligible" "$dhb_negl" "$bsi_negl" "$negl_diff"
printf "%-25s-+-%-10s-+-%-10s-+-%-12s\n" "-------------------------" "----------" "----------" "------------"
print_row "TOTAL" "$dhb_total" "$bsi_total" "$total_diff"

echo
if [ $total_diff -gt 0 ]; then
    echo -e "${GREEN}✓ Bitnami Secure Images reduced total vulnerabilities by $total_diff${NC}"
elif [ $total_diff -lt 0 ]; then
    echo -e "${RED}✗ Total vulnerabilities increased by $((-total_diff))${NC}"
else
    echo -e "${YELLOW}○ No change in total vulnerability count${NC}"
fi

echo
echo "Note: Positive difference means Bitnami has fewer vulnerabilities"
echo "      Negative difference means Bitnami has more vulnerabilities"