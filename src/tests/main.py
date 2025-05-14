def __main__(self):
    self.cursor = PSQLConn().connect().cursor()
    self.base_url = "http://localhost:8080/api/v1"

    requests.post(
        f"{self.base_url}/auth/signup",
        json={
            "email": "adminlostnfound@gmail.com",
            "password": "admin123",
            "firstName": "CIZA",
            "lastName": "Justesse",
            "phoneNumber": "0791111111",
            "address": "KK 508 St, Kigali"
        }
    )

    Cleaner(self.cursor)

if __name__ == "__main__":
    __main__()