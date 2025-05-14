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
            self.c

    