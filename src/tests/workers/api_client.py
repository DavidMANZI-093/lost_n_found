import requests
import json
import time
from colorama import Fore, Style

class APIClient:
    def __init__(self, config_path="../info/config.json"):
        """Initialize API client with base URL from configuration file"""
        with open(config_path, 'r') as config_file:
            config = json.load(config_file)
        
        self.base_url = config["base_url"]
        self.admin_token = None
        self.user_token = None
        self.response_times = {}
    
    def _record_response_time(self, endpoint, method, start_time):
        """Record response time for metrics"""
        elapsed = time.time() - start_time
        key = f"{method} {endpoint}"
        
        if key not in self.response_times:
            self.response_times[key] = []
        
        self.response_times[key].append(elapsed)
        return elapsed
    
    def register_user(self, user_data):
        """Register a new user"""
        start_time = time.time()
        endpoint = "/auth/signup"
        
        response = requests.post(
            f"{self.base_url}{endpoint}",
            json=user_data,
            headers={"Content-Type": "application/json"}
        )
        
        elapsed = self._record_response_time(endpoint, "POST", start_time)
        return response, elapsed
    
    def login_user(self, credentials):
        """Log in a user and store their JWT token"""
        start_time = time.time()
        endpoint = "/auth/login"
        
        response = requests.post(
            f"{self.base_url}{endpoint}",
            json=credentials,
            headers={"Content-Type": "application/json"}
        )
        
        elapsed = self._record_response_time(endpoint, "POST", start_time)
        
        if response.status_code == 200:
            token = response.json().get("jwt_token")
            if "adminlostnfound@gmail.com" in credentials["email"]:
                self.admin_token = token
            else:
                self.user_token = token
        
        return response, elapsed
    
    def create_lost_item(self, item_data):
        """Create a new lost item"""
        start_time = time.time()
        endpoint = "/lost-items"
        
        response = requests.post(
            f"{self.base_url}{endpoint}",
            json=item_data,
            headers={
                "Authorization": f"Bearer {self.user_token}",
                "Content-Type": "application/json"
            }
        )
        
        elapsed = self._record_response_time(endpoint, "POST", start_time)
        return response, elapsed
    
    def update_lost_item(self, item_id, item_data):
        """Update an existing lost item"""
        start_time = time.time()
        endpoint = f"/lost-items/{item_id}"
        
        response = requests.patch(
            f"{self.base_url}{endpoint}",
            json=item_data,
            headers={
                "Authorization": f"Bearer {self.user_token}",
                "Content-Type": "application/json"
            }
        )
        
        elapsed = self._record_response_time(endpoint, "PATCH", start_time)
        return response, elapsed
    
    def get_lost_item(self, item_id):
        """Get a lost item by ID"""
        start_time = time.time()
        endpoint = f"/lost-items/{item_id}"
        
        response = requests.get(f"{self.base_url}{endpoint}")
        
        elapsed = self._record_response_time(endpoint, "GET", start_time)
        return response, elapsed
    
    def delete_lost_item(self, item_id):
        """Delete a lost item"""
        start_time = time.time()
        endpoint = f"/lost-items/{item_id}"
        
        response = requests.delete(
            f"{self.base_url}{endpoint}",
            headers={"Authorization": f"Bearer {self.user_token}"}
        )
        
        elapsed = self._record_response_time(endpoint, "DELETE", start_time)
        return response, elapsed
    
    def create_found_item(self, item_data):
        """Create a new found item"""
        start_time = time.time()
        endpoint = "/found-items"
        
        response = requests.post(
            f"{self.base_url}{endpoint}",
            json=item_data,
            headers={
                "Authorization": f"Bearer {self.user_token}",
                "Content-Type": "application/json"
            }
        )
        
        elapsed = self._record_response_time(endpoint, "POST", start_time)
        return response, elapsed
    
    def update_found_item(self, item_id, item_data):
        """Update an existing found item"""
        start_time = time.time()
        endpoint = f"/found-items/{item_id}"
        
        response = requests.patch(
            f"{self.base_url}{endpoint}",
            json=item_data,
            headers={
                "Authorization": f"Bearer {self.user_token}",
                "Content-Type": "application/json"
            }
        )
        
        elapsed = self._record_response_time(endpoint, "PATCH", start_time)
        return response, elapsed
    
    def get_found_item(self, item_id):
        """Get a found item by ID"""
        start_time = time.time()
        endpoint = f"/found-items/{item_id}"
        
        response = requests.get(f"{self.base_url}{endpoint}")
        
        elapsed = self._record_response_time(endpoint, "GET", start_time)
        return response, elapsed
    
    def delete_found_item(self, item_id):
        """Delete a found item"""
        start_time = time.time()
        endpoint = f"/found-items/{item_id}"
        
        response = requests.delete(
            f"{self.base_url}{endpoint}",
            headers={"Authorization": f"Bearer {self.user_token}"}
        )
        
        elapsed = self._record_response_time(endpoint, "DELETE", start_time)
        return response, elapsed
    
    def search_items(self, query_params):
        """Search for items based on query parameters"""
        start_time = time.time()
        endpoint = "/search"
        
        response = requests.get(
            f"{self.base_url}{endpoint}",
            params={"query": query_params}
        )
        
        elapsed = self._record_response_time(endpoint, "GET", start_time)
        return response, elapsed
    
    def update_user_ban_status(self, user_id, is_banned):
        """Update a user's ban status (admin only)"""
        start_time = time.time()
        endpoint = f"/admin/users/{user_id}"
        
        response = requests.patch(
            f"{self.base_url}{endpoint}",
            json={"is_banned": is_banned},
            headers={
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
        )
        
        elapsed = self._record_response_time(endpoint, "PATCH", start_time)
        return response, elapsed
    
    def update_item_status(self, item_id, status, item_type):
        """Update an item's status (admin only)"""
        start_time = time.time()
        endpoint = f"/admin/items/{item_id}"
        
        response = requests.patch(
            f"{self.base_url}{endpoint}",
            json={"status": status, "type": item_type},
            headers={
                "Authorization": f"Bearer {self.admin_token}",
                "Content-Type": "application/json"
            }
        )
        
        elapsed = self._record_response_time(endpoint, "PATCH", start_time)
        return response, elapsed
    
    def get_system_reports(self):
        """Get system reports (admin only)"""
        start_time = time.time()
        endpoint = "/admin/reports"
        
        response = requests.get(
            f"{self.base_url}{endpoint}",
            headers={"Authorization": f"Bearer {self.admin_token}"}
        )
        
        elapsed = self._record_response_time(endpoint, "GET", start_time)
        return response, elapsed
    
    def get_all_items(self):
        """Get all items"""
        start_time = time.time()
        endpoint = "/items"
        
        response = requests.get(f"{self.base_url}{endpoint}")
        
        elapsed = self._record_response_time(endpoint, "GET", start_time)
        return response, elapsed
    
    def get_items_stats(self):
        """Get item statistics"""
        start_time = time.time()
        endpoint = "/items/stats"
        
        response = requests.get(f"{self.base_url}{endpoint}")
        
        elapsed = self._record_response_time(endpoint, "GET", start_time)
        return response, elapsed
    
    def print_metrics(self):
        """Print API response time metrics"""
        print(f"\n{Fore.CYAN}📊 API RESPONSE TIME METRICS:{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'=' * 50}{Style.RESET_ALL}")
        
        for endpoint, times in self.response_times.items():
            avg_time = sum(times) / len(times)
            max_time = max(times)
            min_time = min(times)
            
            print(f"{Fore.YELLOW}{endpoint}{Style.RESET_ALL}")
            print(f"  • Average: {avg_time:.3f}s")
            print(f"  • Min: {min_time:.3f}s")
            print(f"  • Max: {max_time:.3f}s")
            print(f"  • Requests: {len(times)}")
            print("")