# This script scans a log file for errors

# Define path to log file
log_file = "app.log"

# Define keywords to search for
error_keywords = ["ERROR", "FAIL", "CRITICAL"]

try:
    # Open file in read mode
    with open(log_file, "r") as file:

        print("Scanning log file for errors...\n")

        # Loop through each line in file
        for line_number, line in enumerate(file, start=1):

            # Check if any keyword exists in the line
            if any(keyword in line for keyword in error_keywords):

                # Print line number and content
                print(f"[Line {line_number}] {line.strip()}")

except FileNotFoundError:
    print("Log file not found. Check path.")
