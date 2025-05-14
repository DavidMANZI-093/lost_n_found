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

    self.cursor.execute("SELECT * FROM lost_n_found.user WHERE email = 'adminlostnfound@gmail.com SET is_admin = true'")
    
    requests.post(
        f"{self.base_url}/auth/signup",
        json={
            "email": "johndoe@gmail.com",
            "password": "john123",
            "firstName": "John",
            "lastName": "Doe",
            "phoneNumber": "0792222222",
            "address": "KK 38 Ave, Kigali"
        }
    )

    Cleaner(self.cursor)

if __name__ == "__main__":
    __main__()