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

    self.cursor.execute("UPDATE lost_n_found.user SET is_admin = true WHERE email = 'adminlostnfound@gmail.com'")
    
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

    print(f"Create Lost Item 1: {requests.post(
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
    )}")

    print(f"Create Lost Item 2: {requests.post(
        f"{self.base_url}/lost-items",
        json={
            "title": "Lost Card",
            "description": "Lost student card with reg no 11471/2025",
            "category": "Card",
            "location": "UNILAK, Administrative Building",
            "imageUrl": "https://dummycard.com/image.jpg",
            "lostDate": "2025-05-11T13:00:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Update Lost Item 2: {requests.patch(
        f"{self.base_url}/lost-items/2",
        json={
            "title": "Lost Card - Updated",
            "description": "(Updated) Lost student card with reg no 11471/2017",
            "category": "Card",
            "location": "UNILAK, Administrative Building",
            "imageUrl": "https://dummycard.com/image.jpg",
            "lostDate": "2025-05-11T13:00:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Create Lost Item 3: {requests.post(
        f"{self.base_url}/lost-items",
        json={
            "title": "Lost Book",
            "description": "Lost book with title 'The Great Gatsby'",
            "category": "Book",
            "location": "UNILAK, Library",
            "imageUrl": "https://dummybook.com/image.jpg",
            "lostDate": "2025-05-11T13:00:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Get Lost Item by ID (2): {requests.get(
        f"{self.base_url}/lost-items/2"
    )}")

    print(f"Delete Lost Item: {requests.delete(
        f"{self.base_url}/lost-items/3",
        headers={
            "Authorization": f"Bearer {self.user_token}",
        }
    )}")

    print(f"Create Found Item: {requests.post(
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
    )}")

    print(f"Get Found Item: {requests.get(
        f"{self.base_url}/found-items/1"
    )}")

    print(f"Update Found Item: {requests.patch(
        f"{self.base_url}/found-items/1",
        json={
            "title": "Found Phone - Updated",
            "description": "(Updated) iPhone 13, red case",
            "category": "Electronics",
            "location": "UNILAK, Coffee House",
            "imageUrl": "https://dummyphone.com/image.jpg",
            "foundDate": "2025-05-14T12:00:00Z"
        },
        headers={
            "Authorization": f"Bearer {self.user_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Delete Found Item: {requests.delete(
        f"{self.base_url}/found-items/1",
        headers={
            "Authorization": f"Bearer {self.user_token}",
        }
    )}")

    print(f"Search Items: {requests.get(
        f"{self.base_url}/search",
        params={
            "query": {
                "type": "lost",
                "category": "Card",
                "keyword": "wallet",
                "location": "coffee",
                "status": "pending"
            }
        }
    )}")

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

    print(f"Admin Login: {response}")

    self.admin_token = response.json().get("jwt_token")

    print(f"Update User Ban Status: {requests.patch(
        f"{self.base_url}/admin/users/2",
        json={
            "is_banned": True
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Update User Ban Status: {requests.patch(
        f"{self.base_url}/admin/users/2",
        json={
            "is_banned": False
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Update Item Status: {requests.patch(
        f"{self.base_url}/admin/items/1",
        json={
            "status": "approved",
            "type": "lost"
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Update Item Status: {requests.patch(
        f"{self.base_url}/admin/items/2",
        json={
            "status": "approved",
            "type": "lost"
        },
        headers={
            "Authorization": f"Bearer {self.admin_token}",
            "Content-Type": "application/json"
        }
    )}")

    print(f"Get System Reports: {requests.get(
        f"{self.base_url}/admin/reports",
        headers={
            "Authorization": f"Bearer {self.admin_token}"
        }
    )}")

    print(f"Get All Items: {requests.get(
        f"{self.base_url}/items"
    )}")

    print(f"Get All Items Stats: {requests.get(
        f"{self.base_url}/items/stats"
    )}")

    Cleaner(self.cursor)

if __name__ == "__main__":
    __main__()