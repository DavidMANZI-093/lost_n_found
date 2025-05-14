def __main__(self):
    self.cursor = PSQLConn().connect().cursor()
    self.base_url = "http://localhost:8080/api/v1"

    

if __name__ == "__main__":
    __main__()