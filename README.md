**# Wepenta:**
Webpen tool for basic web Pentesting Automation Tool

Pentesting Automation Tool is a comprehensive bash script that streamlines web penetration testing. With this tool, you can efficiently:

    Enumerate Subdomains: Identify and collect subdomains using **subfinder** and **assetfinder**.
    Check Availability: Validate which subdomains are live with **httprobe.**
    Perform Network Scanning: Run targeted **Nmap** scans to uncover open ports.
    Capture Screenshots: Automatically take screenshots of live subdomains using **GoWitness**.
    Analyze SSL Certificates: Retrieve and review** SSL certificate details**.
    Generate Detailed Reports: Produce informative Markdown reports and convert them to PDFs for easy sharing and review.

This tool simplifies the workflow for security professionals and enhances productivity by automating common tasks in web pen-testing.

**Dependencies and Tools:**
## Dependencies

Before running the script, ensure you have the following tools installed:

1. **GoWitness**
   - Captures screenshots of live subdomains.
   - Installation:
     ```bash
     git clone https://github.com/sensepost/gowitness.git
     cd gowitness
     go build
     sudo mv gowitness /usr/local/bin/
     ```

2. **Subfinder**
   - Finds subdomains for a given domain.
   - Installation:
     ```bash
     go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
     ```

3. **Assetfinder**
   - Identifies subdomains for a given domain.
   - Installation:
     ```bash
     go install github.com/assetfinder/assetfinder@latest
     ```

4. **httprobe**
   - Checks which URLs are alive.
   - Installation:
     ```bash
     go install github.com/tomnomnom/httprobe@latest
     ```

5. **Nmap**
   - Network scanning tool to find open ports.
   - Installation:
     - **On Debian/Ubuntu**:
       ```bash
       sudo apt-get install nmap
       ```
     - **On CentOS/RHEL**:
       ```bash
       sudo yum install nmap
       ```

6. **Pandoc**
   - Converts Markdown files to PDF.
   - Installation:
     ```bash
     sudo apt-get install pandoc
     ```

7. **PDF Engine (`pdflatex` or `xelatex`)**
   - Used by Pandoc to generate PDF files from Markdown.
   - **For `pdflatex`**:
     ```bash
     sudo apt-get install texlive
     ```
   - **For `xelatex`** (optional):
     ```bash
     sudo apt-get install texlive-xetex
     ```

8. **OpenSSL**
   - Fetches SSL certificate information.
   - Installation:
     - **On Debian/Ubuntu**:
       ```bash
       sudo apt-get install openssl
       ```
     - **On CentOS/RHEL**:
       ```bash
       sudo yum install openssl
       ```

9. **cURL**
   - Fetches HTTP headers.
   - Installation:
     - **On Debian/Ubuntu**:
       ```bash
       sudo apt-get install curl
       ```
     - **On CentOS/RHEL**:
       ```bash
       sudo yum install curl
       ```

10. **Git**
    - Required to clone repositories.
    - Installation:
      - **On Debian/Ubuntu**:
        ```bash
        sudo apt-get install git
        ```
      - **On CentOS/RHEL**:
        ```bash
        sudo yum install git
        ```

Make sure to install these dependencies before running the script. If you encounter any issues, refer to the documentation for each tool or seek help in their respective communities.
