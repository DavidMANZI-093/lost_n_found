import requests

def __main__(self):
    self.cursor = PSQLConn().connect().cursor()
    self.base_url = "http://localhost:8080/api/v1"
    self.user_token = None
    self.admin_token = None

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
        },
        headers={
            "Content-Type": "application/json"
        }
    )

    response = requests.post(
        f"{self.base_url}/auth/login",
        json={
            "email": "johndoe@gmail.com",
            "password": "john123"
        },
        headers={
            "Content-Type": "application/json"
        }
    )

    self.user_token = response.json().get("jwt_token")

    requests.post(
        f"{self.base_url}/lost-items",
        json={
            "title": "Lost Wallet",
            "description": "Lost wallet with some cash and some cards",
            "category": "Wallet",
            "location": "UNILAK, Central Park",
            "imageUrl": "https://dummywallet.com/image.jpg",
            "lostDate": "2025-005-13T15:30:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )

    requests.post(
        f"{self.base_url}/lost-items",
        json={
            "title": "Lost Card",
            "description": "Lost student card with reg no 11471/2017",
            "category": "Card",
            "location": "UNILAK, Administrative Building",
            "imageUrl": "https://dummycard.com/image.jpg",
            "lostDate": "2025-05-11T13:00:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )

    requests.post(
        f"{self.base_url}/found-items",
        json={
            "title": "Found Phone",
            "description": "iPhone 13, black case",
            "category": "Electronics",
            "location": "UNILAK, Coffee House",
            "imageUrl": "https://dummyphone.com/image.jpg",
            "foundDate": "2025-05-14T12:00:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )

    response = requests.post(
        f"{self.base_url}/auth/login",
        json={
            "email": "adminlostnfound@gmail.com",
            "password": "admin123"
        },
        headers={
            "Content-Type": "application/json"
        }
    )

    self.admin_token = response.json().get("jwt_token")

    requests.patch(
        f"{self.base_url}/admin/users/2",
        json={
            "is_banned": True
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )

    requests.patch(
        f"{self.base_url}/admin/users/2",
        json={
            "is_banned": False
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )

    requests.patch(
        f"{self.base_url}/admin/lost-items/1",
        json={
            "status": "approved",
            "type": "lost"
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )

    Cleaner(self.cursor)

if __name__ == "__main__":
    __main__()