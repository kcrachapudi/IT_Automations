# Import pyodbc to connect to SQL Server
import pyodbc

# Define connection string
# Trusted_Connection=yes means Windows Authentication
conn_str = (
    "DRIVER={SQL Server};"
    "SERVER=localhost;"
    "DATABASE=AdventureWorks;"
    "Trusted_Connection=yes;"
)

try:
    # Establish connection
    conn = pyodbc.connect(conn_str)

    print("Connected to database successfully")

    # Create a cursor (used to execute queries)
    cursor = conn.cursor()

    # Define SQL query
    query = "SELECT TOP 5 FirstName, LastName FROM Person.Person"

    # Execute query
    cursor.execute(query)

    # Fetch all results
    rows = cursor.fetchall()

    # Loop through results and print each row
    for row in rows:
        print(f"Name: {row.FirstName} {row.LastName}")

except Exception as e:
    print("Database connection failed:", e)

finally:
    # Always close connection
    conn.close()
