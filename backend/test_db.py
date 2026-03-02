from app.database import engine, USER, HOST, PORT, DB_NAME
from sqlalchemy import text

def test_connection():
    print(f"Connecting to: postgresql://{USER}:***@{HOST}:{PORT}/{DB_NAME}")
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            print("Database connection successful:", result.scalar())
    except Exception as e:
        print("Database connection failed:", e)

if __name__ == "__main__":
    test_connection()
