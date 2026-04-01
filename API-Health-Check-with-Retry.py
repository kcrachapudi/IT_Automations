# Import requests library to call APIs
import requests

# Import time to add delays between retries
import time

# API endpoint to check
url = "http://localhost:5000/health"

# Number of retries if API fails
max_retries = 3

# Loop through retry attempts
for attempt in range(max_retries):

    try:
        # Send GET request to API
        response = requests.get(url)

        # Check if response is successful (HTTP 200)
        if response.status_code == 200:
            print("API is healthy ✅")
            break  # Exit loop if successful
        else:
            print(f"API returned unexpected status: {response.status_code}")

    except Exception as e:
        # Catch connection errors (API down, network issues, etc.)
        print(f"Attempt {attempt+1} failed: {e}")

    # Wait before retrying
    time.sleep(2)

else:
    # This runs if all retries fail
    print("API is DOWN after multiple attempts ❌")
