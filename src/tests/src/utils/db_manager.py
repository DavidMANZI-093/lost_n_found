import psycopg2
import json

class DatabaseManager:
    def __init__(self, config_path="../info/config.json"):
        """Initialize database connection manager with configuration from JSON file"""
        with open(config_path, 'r') as config_file:
            config = json.load(config_file)
        
        self.db_config = config["db_config"]
        self.conn = None
        self.cursor = None
    
    def connect(self):
        """Establish connection to the PostgreSQL database"""
        try:
            self.conn = psycopg2.connect(
                dbname=self.db_config["db_name"],
                user=self.db_config["user"],
                password=self.db_config["password"],
                host=self.db_config["host"],
                port=self.db_config["port"]
            )
            self.conn.autocommit = True
            self.cursor = self.conn.cursor()
            return self.cursor
        except Exception as e:
            print(f"❌ Error connecting to the database: {e}")
            return None
    
    def set_admin_role(self, email):
        """Set admin role for a user with the specified email"""
        try:
            self.cursor.execute(
                "UPDATE users SET is_admin = true WHERE email = %s",
                (email,)
            )
            return True
        except Exception as e:
            print(f"❌ Error setting admin role: {e}")
            return False
    
    def clean_database(self):
        """Clean up the database by removing all test data"""
        try:
            self.cursor.execute("TRUNCATE TABLE lost_items CASCADE")
            self.cursor.execute("TRUNCATE TABLE found_items CASCADE")
            self.cursor.execute("TRUNCATE TABLE users CASCADE")
            self.cursor.execute("ALTER SEQUENCE lost_items_id_seq RESTART WITH 1")
            self.cursor.execute("ALTER SEQUENCE found_items_id_seq RESTART WITH 1")
            self.cursor.execute("ALTER SEQUENCE users_id_seq RESTART WITH 1")
            return True
        except Exception as e:
            print(f"❌ Error cleaning database: {e}")
            return False
    
    def close(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()