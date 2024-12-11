import psycopg2

def connect_to_db():
    # Database connection settings
    db_settings = {
        "dbname": "postgres",
        "user": "postgres",
        "password": "lana_lana67",
        "host": "localhost",
        "port": "5432"  # PostgreSQL Standard Port
    }

    try:
        # Establishing a connection to the database
        connection = psycopg2.connect(**db_settings)
        print("The connection to the database has been established successfully.")
        return connection
    except psycopg2.Error as e:
        print(f" Error connecting to database: {e}")
        return None

def fetch_students(connection):
    try:
        # Create a cursor to execute queries
        cursor = connection.cursor()

        # We execute a SQL query
        query = "SELECT student_numb, firstname, surname FROM student ORDER BY student_numb;"
        cursor.execute(query)

        # We get results
        students = cursor.fetchall()
        print("List of students:")
        for student in students:
            print(f"ID: {student[0]}, Name: {student[1]}, Surname: {student[2]}")

    except psycopg2.Error as e:
        print(f" Error executing request: {e}")
    finally:
        # Close the cursor
        cursor.close()

def main():
    # Connecting to the database
    connection = connect_to_db()
    if connection:
        # We execute requests
        fetch_students(connection)

        # Closing the connection
        connection.close()
        print("The database connection was closed.")

if __name__ == "__main__":
    main()
