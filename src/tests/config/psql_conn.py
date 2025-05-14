class PSQLConn:
    def __init__(self):
        self.db_name = "lost_n_found"
        self.user = "postgres"
        self.password = "post093"
        self.host = "localhost"
        self.port = "5432"

        self.conn = None

    def connect(self):
        try:
            self.conn = psycopg2.connect(
                dbname=self.db_name,
                user=self.user,
                password=self.password,
                host=self.host,
                port=self.port
            )
        except Exception as e:
            print(f"Error connecting to the database: {e}")
            self.conn = None

    def close(self):
        if self.conn:
            self.conn.close()

    