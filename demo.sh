#!/bin/bash

########################
# Demo Magic Setup
########################

check_dependencies() {
    local tools=("vendir" "grype" "git")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "$tool not found. Please install $tool first."
            exit 1
        fi
    done
}



vendir sync 
. vendir/demo-magic/demo-magic.sh -n

# Configure demo-magic
TYPE_SPEED=20
NO_WAIT=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Temp files for scan results
DHB_APP_SCAN="/tmp/dhb-app-scan.json"
DHB_DB_SCAN="/tmp/dhb-db-scan.json"
BSI_APP_SCAN="/tmp/bsi-app-scan.json"
BSI_DB_SCAN="/tmp/bsi-db-scan.json"

cleanup() {
    docker compose -f docker-compose.dhb.yml down -v
    docker compose -f docker-compose.bsi.yml down -v
    rm -f $DHB_APP_SCAN $DHB_DB_SCAN $BSI_APP_SCAN $BSI_DB_SCAN
}

########################
# Helper Functions
########################

# Extract vulnerability counts by severity from Grype JSON output
extract_vuln_counts() {
    local scan_file=$1
    local critical=$(jq '[.matches[] | select(.vulnerability.severity == "Critical")] | length' "$scan_file")
    local high=$(jq '[.matches[] | select(.vulnerability.severity == "High")] | length' "$scan_file")
    local medium=$(jq '[.matches[] | select(.vulnerability.severity == "Medium")] | length' "$scan_file")
    local low=$(jq '[.matches[] | select(.vulnerability.severity == "Low")] | length' "$scan_file")
    local negligible=$(jq '[.matches[] | select(.vulnerability.severity == "Negligible")] | length' "$scan_file")
    local total=$(jq '.matches | length' "$scan_file")
    
    echo "$critical $high $medium $low $negligible $total"
}

# Print a section header
print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Print results table
print_results_table() {
    # Extract counts for each image
    read dhb_app_crit dhb_app_high dhb_app_med dhb_app_low dhb_app_neg dhb_app_total <<< $(extract_vuln_counts "$DHB_APP_SCAN")
    read dhb_db_crit dhb_db_high dhb_db_med dhb_db_low dhb_db_neg dhb_db_total <<< $(extract_vuln_counts "$DHB_DB_SCAN")
    read bsi_app_crit bsi_app_high bsi_app_med bsi_app_low bsi_app_neg bsi_app_total <<< $(extract_vuln_counts "$BSI_APP_SCAN")
    read bsi_db_crit bsi_db_high bsi_db_med bsi_db_low bsi_db_neg bsi_db_total <<< $(extract_vuln_counts "$BSI_DB_SCAN")
    
    # Calculate totals
    dhb_total=$((dhb_app_total + dhb_db_total))
    bsi_total=$((bsi_app_total + bsi_db_total))
    difference=$((dhb_total - bsi_total))
    
    dhb_crit_total=$((dhb_app_crit + dhb_db_crit))
    dhb_high_total=$((dhb_app_high + dhb_db_high))
    dhb_med_total=$((dhb_app_med + dhb_db_med))
    dhb_low_total=$((dhb_app_low + dhb_db_low))
    dhb_neg_total=$((dhb_app_neg + dhb_db_neg))
    
    bsi_crit_total=$((bsi_app_crit + bsi_db_crit))
    bsi_high_total=$((bsi_app_high + bsi_db_high))
    bsi_med_total=$((bsi_app_med + bsi_db_med))
    bsi_low_total=$((bsi_app_low + bsi_db_low))
    bsi_neg_total=$((bsi_app_neg + bsi_db_neg))
    
    diff_crit=$((dhb_crit_total - bsi_crit_total))
    diff_high=$((dhb_high_total - bsi_high_total))
    diff_med=$((dhb_med_total - bsi_med_total))
    diff_low=$((dhb_low_total - bsi_low_total))
    diff_neg=$((dhb_neg_total - bsi_neg_total))
    
    print_header "VULNERABILITY SCAN RESULTS"
    
    # Print detailed table
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                          DETAILED VULNERABILITY BREAKDOWN                          ║${NC}"
    echo -e "${PURPLE}╠═══════════════════════╦════════════╦════════════╦════════════╦════════════╦════════╣${NC}"
    echo -e "${PURPLE}║${NC} Image                 ${PURPLE}║${NC} Critical   ${PURPLE}║${NC} High       ${PURPLE}║${NC} Medium     ${PURPLE}║${NC} Low        ${PURPLE}║${NC} Total  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠═══════════════════════╬════════════╬════════════╬════════════╬════════════╬════════╣${NC}"
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${NC} %6s ${PURPLE}║${NC}\n" \
        "Dockerhub App" "$dhb_app_crit" "$dhb_app_high" "$dhb_app_med" "$dhb_app_low" "$dhb_app_total"
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${NC} %6s ${PURPLE}║${NC}\n" \
        "Dockerhub Database" "$dhb_db_crit" "$dhb_db_high" "$dhb_db_med" "$dhb_db_low" "$dhb_db_total"
    echo -e "${PURPLE}╠═══════════════════════╬════════════╬════════════╬════════════╬════════════╬════════╣${NC}"
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${NC} %6s ${PURPLE}║${NC}\n" \
        "BSI App" "$bsi_app_crit" "$bsi_app_high" "$bsi_app_med" "$bsi_app_low" "$bsi_app_total"
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${NC} %6s ${PURPLE}║${NC}\n" \
        "BSI Database" "$bsi_db_crit" "$bsi_db_high" "$bsi_db_med" "$bsi_db_low" "$bsi_db_total"
    echo -e "${PURPLE}╠═══════════════════════╬════════════╬════════════╬════════════╬════════════╬════════╣${NC}"
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${CYAN} %6s ${PURPLE}║${NC}\n" \
        "Dockerhub TOTAL" "$dhb_crit_total" "$dhb_high_total" "$dhb_med_total" "$dhb_low_total" "$dhb_total"
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${CYAN} %6s ${PURPLE}║${NC}\n" \
        "BSI TOTAL" "$bsi_crit_total" "$bsi_high_total" "$bsi_med_total" "$bsi_low_total" "$bsi_total"
    echo -e "${PURPLE}╠═══════════════════════╬════════════╬════════════╬════════════╬════════════╬════════╣${NC}"
    
    # Color the difference based on whether it's positive or negative
    if [ $difference -gt 0 ]; then
        diff_color=$GREEN
        diff_symbol="↓"
    else
        diff_color=$RED
        diff_symbol="↑"
    fi
    
    printf "${PURPLE}║${NC} %-21s ${PURPLE}║${RED} %10s ${PURPLE}║${YELLOW} %10s ${PURPLE}║${BLUE} %10s ${PURPLE}║${GREEN} %10s ${PURPLE}║${diff_color} %6s ${PURPLE}║${NC}\n" \
        "DIFFERENCE (Dockerhub-Bitnami)" "$diff_crit" "$diff_high" "$diff_med" "$diff_low" "$difference"
    echo -e "${PURPLE}╚═══════════════════════╩════════════╩════════════╩════════════╩════════════╩════════╝${NC}"
    
    echo ""
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                     SUMMARY                                        ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    
    if [ $difference -gt 0 ]; then
        echo -e "${GREEN}✓ Bitnami images have ${difference} FEWER vulnerabilities than DockerHub images!${NC}"
        echo -e "${GREEN}  ${diff_symbol} Critical: ${diff_crit} fewer${NC}"
        echo -e "${GREEN}  ${diff_symbol} High: ${diff_high} fewer${NC}"
        echo -e "${GREEN}  ${diff_symbol} Medium: ${diff_med} fewer${NC}"
    elif [ $difference -lt 0 ]; then
        echo -e "${RED}✗ Bitnami images have ${difference#-} MORE vulnerabilities than DockerHub images!${NC}"
    else
        echo -e "${YELLOW}= Both stacks have the same number of vulnerabilities${NC}"
    fi
    
    echo ""
}

########################
# Demo Script
########################

clear
cleanup

clear
print_header "Spring Uber: Comparing DockerHub vs Bitnami Images"

echo -e "${CYAN}This demo will:${NC}"
echo "  1. Build both application stacks (DockerHub and Bitnami)"
echo "  2. Scan all images for vulnerabilities using Grype"
echo "  3. Compare the results"
echo ""

wait

print_header "Step 1: Build DockerHub Stack"
pei "docker compose -f docker-compose.dhb.yml build"
pei "docker compose -f docker-compose.dhb.yml up -d"

print_header "Step 2: Build Bitnami Stack"
pei "docker compose -f docker-compose.bsi.yml build"
pei "docker compose -f docker-compose.bsi.yml up -d"

print_header "Step 3: Verify Both Stacks Are Running"
pei "docker compose ls"

print_header "Step 4: Scan DockerHub Stack Images"
pei "grype spring-uber-app-dhb:latest -o json > $DHB_APP_SCAN"
pei "grype postgres:16 -o json > $DHB_DB_SCAN"

print_header "Step 5: Scan Bitnami Stack Images"
pei "grype spring-uber-app-bsi:latest -o json > $BSI_APP_SCAN"
pei "grype us-east1-docker.pkg.dev/vmw-app-catalog/hosted-registry-e4c6ba6fd76/containers/photon-5/postgresql:16 -o json > $BSI_DB_SCAN"

print_header "Step 6: Analyze Results"

# Print the results table
print_results_table

print_header "Demo Complete!"
echo -e "${GREEN}Both stacks are running and ready for testing:${NC}"
echo -e "  ${CYAN}DockerHub App:${NC} http://localhost:8090"
echo -e "  ${CYAN}Bitnami App:${NC}       http://localhost:8091"
echo ""
echo -e "${YELLOW}To stop the stacks:${NC}"
echo "  docker compose -f docker-compose.dhb.yml down"
echo "  docker compose -f docker-compose.bsi.yml down"
echo ""

# Cleanup temp files
#rm -f $DHB_APP_SCAN $DHB_DB_SCAN $BSI_APP_SCAN $BSI_DB_SCAN