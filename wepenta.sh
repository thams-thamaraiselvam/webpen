#!/bin/bash

# Use the first argument as the domain name
domain=$1

# Define colors
RED="\033[1;31m"
GREEN="\033[1;32m"
RESET="\033[0m"

# Define directories
base_dir="$domain"
info_path="$base_dir/info"
subdomain_path="$base_dir/subdomains"
screenshot_path="$base_dir/screenshots"
nmap_path="$base_dir/nmap"
report_path="$base_dir/report"

# Create directories if they don't exist
for path in "$info_path" "$subdomain_path" "$screenshot_path" "$nmap_path" "$report_path"; do
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
        echo "Created directory: $path"
    fi
done

# Function to generate a report
generate_report() {
    echo -e "${GREEN} [+] Generating report ... ${RESET}"
    report_md_file="$report_path/report.md"
    report_pdf_file="$report_path/report.pdf"
    
    echo "# Pentesting Report for $domain" > "$report_md_file"
    
    echo "## WHOIS Information" >> "$report_md_file"
    cat "$info_path/whois.txt" >> "$report_md_file"

    echo -e "\n## Subdomain Enumeration" >> "$report_md_file"
    cat "$subdomain_path/found.txt" >> "$report_md_file"

    echo -e "\n## Live Subdomains" >> "$report_md_file"
    cat "$subdomain_path/alive.txt" >> "$report_md_file"

    echo -e "\n## Nmap Scan Results" >> "$report_md_file"
    for file in "$nmap_path"/*.txt; do
        echo -e "\n### $(basename $file)" >> "$report_md_file"
        cat "$file" >> "$report_md_file"
    done

    echo -e "\n## SSL Certificate Information" >> "$report_md_file"
    cat "$info_path/ssl_info.txt" >> "$report_md_file"

    echo -e "\n## HTTP Response Headers" >> "$report_md_file"
    cat "$info_path/headers.txt" >> "$report_md_file"

    # Embedding Screenshots
    echo -e "\n## Screenshots" >> "$report_md_file"
    for screenshot in "$screenshot_path"/*.png; do
        if [ -f "$screenshot" ]; then
            echo "![Screenshot of $(basename $screenshot)]($screenshot)" >> "$report_md_file"
        else
            echo "No screenshots found." >> "$report_md_file"
        fi
    done

    # Convert the Markdown report to PDF using Pandoc
    echo -e "${GREEN} [+] Converting Markdown report to PDF ... ${RESET}"
    pandoc "$report_md_file" -o "$report_pdf_file" --pdf-engine=pdflatex

    echo -e "${GREEN} [+] Report generated at $report_pdf_file ${RESET}"
}

# WHOIS Lookup
echo -e "${RED} [+] Checking WHOIS information ... ${RESET}"
whois "$domain" > "$info_path/whois.txt"

# Subdomain Enumeration
echo -e "${RED} [+] Launching Subfinder ... ${RESET}"
subfinder -d "$domain" > "$subdomain_path/found.txt"

echo -e "${RED} [+] Running Assetfinder ... ${RESET}"
assetfinder "$domain" | grep "$domain" >> "$subdomain_path/found.txt"

# Check for live subdomains
echo -e "${RED} [+] Checking what's alive ... ${RESET}"
cat "$subdomain_path/found.txt" | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a "$subdomain_path/alive.txt"

# SSL Certificate Information
echo -e "${RED} [+] Fetching SSL certificate details ... ${RESET}"
> "$info_path/ssl_info.txt"
while read -r subdomain; do
    echo -e "${GREEN} [*] Checking SSL for $subdomain ... ${RESET}"
    echo "$subdomain" >> "$info_path/ssl_info.txt"
    echo | openssl s_client -connect "$subdomain:443" 2>/dev/null | openssl x509 -noout -dates -issuer -subject >> "$info_path/ssl_info.txt"
    echo "----------------------------------------" >> "$info_path/ssl_info.txt"
done < "$subdomain_path/alive.txt"

# HTTP Response Headers
echo -e "${RED} [+] Checking HTTP response headers ... ${RESET}"
> "$info_path/headers.txt"
while read -r subdomain; do
    echo -e "${GREEN} [*] Fetching headers for $subdomain ... ${RESET}"
    echo "$subdomain" >> "$info_path/headers.txt"
    curl -I -s "https://$subdomain" >> "$info_path/headers.txt"
    echo "----------------------------------------" >> "$info_path/headers.txt"
done < "$subdomain_path/alive.txt"

# Port Scanning with Nmap
echo -e "${RED} [+] Running Nmap scan on live subdomains ... ${RESET}"
while read -r subdomain; do
    echo -e "${GREEN} [*] Scanning $subdomain for open ports ... ${RESET}"
    nmap -Pn -p 80,443 "$subdomain" -oN "$nmap_path/$subdomain.txt"
done < "$subdomain_path/alive.txt"

# Taking Screenshots with GoWitness
echo -e "${RED} [+] Taking screenshots ... ${RESET}"
gowitness file -f "$subdomain_path/alive.txt" -P "$screenshot_path/" --no-http 2>>"$screenshot_path/gowitness_errors.log" || echo -e "${RED} [!] Some screenshots failed, check the log for details. ${RESET}"

# Verify screenshots are in the directory
echo -e "${GREEN} [+] Verifying screenshots ... ${RESET}"
if [ "$(ls -A $screenshot_path)" ]; then
    echo -e "${GREEN} [+] Screenshots found in $screenshot_path ${RESET}"
else
    echo -e "${RED} [!] No screenshots found in $screenshot_path ${RESET}"
fi

# Generate the Report
generate_report

echo -e "${GREEN} [+] Pentesting completed for $domain! ${RESET}"
