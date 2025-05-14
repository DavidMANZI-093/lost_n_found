import json
from colorama import Fore, Style, init
import pyfiglet
import os
from datetime import datetime

from .utils.db_manager import DatabaseManager
from .workers.api_client import APIClient
from .utils.test_reporter import TestReporter

# Initialize colorama
init(autoreset=True)

def run_tests():
    """Main function to run all API tests"""
    # Print welcome banner

    root_dir = os.path.dirname(os.path.abspath(__file__))

    title = pyfiglet.figlet_format("Lost & Found API Tests", font="slant", width=100)
    print(f"{Fore.CYAN}{title}{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'=' * 80}{Style.RESET_ALL}")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Running tests against API at: {load_config(root_dir)['base_url']}")
    print(f"{Fore.CYAN}{'=' * 80}{Style.RESET_ALL}\n")
    
    # Initialize components
    db_manager = DatabaseManager(f"{root_dir}/info/config.json")
    api_client = APIClient(f"{root_dir}/info/config.json")
    reporter = TestReporter()
    
    try:
        # Load test data
        test_data = load_test_data(root_dir)
        config = load_config(root_dir)
        
        # Connect to database
        print(f"{Fore.YELLOW}Connecting to database...{Style.RESET_ALL}")
        cursor = db_manager.connect()
        if not cursor:
            print(f"{Fore.RED}❌ Failed to connect to database. Aborting tests.{Style.RESET_ALL}")
            return
        print(f"{Fore.GREEN}✓ Connected to database{Style.RESET_ALL}")
        
        # Clean database before starting tests
        print(f"{Fore.YELLOW}Cleaning database...{Style.RESET_ALL}")
        if db_manager.clean_database():
            print(f"{Fore.GREEN}✓ Database cleaned{Style.RESET_ALL}")
        else:
            print(f"{Fore.RED}❌ Failed to clean database{Style.RESET_ALL}")
        
        # Run tests in stages with progress bars
        run_authentication_tests(api_client, reporter, config, db_manager)
        run_lost_item_tests(api_client, reporter, test_data)
        run_found_item_tests(api_client, reporter, test_data)
        run_admin_tests(api_client, reporter)
        run_search_and_stats_tests(api_client, reporter, test_data)
        
        # Print metrics and summary
        api_client.print_metrics()
        reporter.summarize()
        
    finally:
        # Clean up
        print(f"\n{Fore.YELLOW}Cleaning up...{Style.RESET_ALL}")
        db_manager.clean_database()
        db_manager.close()
        print(f"{Fore.GREEN}✓ Cleanup complete{Style.RESET_ALL}")
        print(f"\nCompleted: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

def load_config(root_dir):
    """Load configuration from JSON file"""
    with open(f"{root_dir}/info/config.json", "r") as f:
        return json.load(f)

def load_test_data(root_dir):
    """Load test data from JSON file"""
    with open(f"{root_dir}/info/test_data.json", "r") as f:
        return json.load(f)

def run_authentication_tests(api_client, reporter, config, db_manager):
    """Run user authentication tests"""
    reporter.set_stage("Authentication")
    
    # Test user registration
    test_name = "Register Admin User"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.register_user(config["users"]["admin"])
    success, message = reporter.assert_status_code(response, 201)
    reporter.end_test(test_name, start_time, success, message)
    
    # Set admin privileges
    test_name = "Set Admin Role"
    start_time = reporter.start_test(test_name)
    success = db_manager.set_admin_role(config["users"]["admin"]["email"])
    reporter.end_test(test_name, start_time, success, "Successfully set admin role" if success else "Failed to set admin role")
    
    # Test regular user registration
    test_name = "Register Regular User"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.register_user(config["users"]["regular"])
    success, message = reporter.assert_status_code(response, 201)
    reporter.end_test(test_name, start_time, success, message)
    
    # Test regular user login
    test_name = "Login Regular User"
    start_time = reporter.start_test(test_name)
    credentials = {
        "email": config["users"]["regular"]["email"],
        "password": config["users"]["regular"]["password"]
    }
    response, _ = api_client.login_user(credentials)
    success, message = reporter.assert_status_code(response, 200)
    if success:
        success, message = reporter.assert_json_key(response.json().get("data"), "token")
    reporter.end_test(test_name, start_time, success, message)
    
    # Test admin user login
    test_name = "Login Admin User"
    start_time = reporter.start_test(test_name)
    credentials = {
        "email": config["users"]["admin"]["email"],
        "password": config["users"]["admin"]["password"]
    }
    response, _ = api_client.login_user(credentials)
    success, message = reporter.assert_status_code(response, 200)
    if success:
        success, message = reporter.assert_json_key(response.json().get("data"), "token")
    reporter.end_test(test_name, start_time, success, message)

def run_lost_item_tests(api_client, reporter, test_data):
    """Run lost item CRUD tests"""
    reporter.set_stage("Lost Items")
    
    # Create lost items
    lost_items = test_data["lost_items"]
    for i, item in enumerate(lost_items):
        test_name = f"Create Lost Item {i+1}"
        start_time = reporter.start_test(test_name)
        response, _ = api_client.create_lost_item(item)
        success, message = reporter.assert_status_code(response, 201)
        reporter.end_test(test_name, start_time, success, message)
    
    # Get lost item
    test_name = "Get Lost Item by ID"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.get_lost_item(2)
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Update lost item
    for update in test_data["lost_item_updates"]:
        item_id = update["id"]
        test_name = f"Update Lost Item {item_id}"
        start_time = reporter.start_test(test_name)
        response, _ = api_client.update_lost_item(item_id, update)
        success, message = reporter.assert_status_code(response, 200)
        reporter.end_test(test_name, start_time, success, message)
    
    # Delete lost item
    test_name = "Delete Lost Item"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.delete_lost_item(3)
    success, message = reporter.assert_status_code(response, 204)
    reporter.end_test(test_name, start_time, success, message)

def run_found_item_tests(api_client, reporter, test_data):
    """Run found item CRUD tests"""
    reporter.set_stage("Found Items")
    
    # Create found item
    test_name = "Create Found Item"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.create_found_item(test_data["found_items"][0])
    success, message = reporter.assert_status_code(response, 201)
    reporter.end_test(test_name, start_time, success, message)
    
    # Get found item
    test_name = "Get Found Item by ID"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.get_found_item(1)
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Update found item
    update = test_data["found_item_updates"][0]
    item_id = update["id"]
    test_name = f"Update Found Item {item_id}"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.update_found_item(item_id, update)
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Delete found item
    test_name = "Delete Found Item"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.delete_found_item(1)
    success, message = reporter.assert_status_code(response, 204)
    reporter.end_test(test_name, start_time, success, message)

def run_admin_tests(api_client, reporter):
    """Run admin functionality tests"""
    reporter.set_stage("Admin Operations")
    
    # Ban user
    test_name = "Ban User"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.update_user_ban_status(2, True)
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Unban user
    test_name = "Unban User"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.update_user_ban_status(2, False)
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Update item status (lost)
    test_name = "Update Lost Item Status"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.update_item_status(1, "approved", "lost")
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Update another item status (lost)
    test_name = "Update Another Lost Item Status"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.update_item_status(2, "approved", "lost")
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Get system reports
    test_name = "Get System Reports"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.get_system_reports()
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)

def run_search_and_stats_tests(api_client, reporter, test_data):
    """Run search and statistics tests"""
    reporter.set_stage("Search & Statistics")
    
    # Search items
    test_name = "Search Items"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.search_items(test_data["search_queries"][0])
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Get all items
    test_name = "Get All Items"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.get_all_items()
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)
    
    # Get items stats
    test_name = "Get Items Statistics"
    start_time = reporter.start_test(test_name)
    response, _ = api_client.get_items_stats()
    success, message = reporter.assert_status_code(response, 200)
    reporter.end_test(test_name, start_time, success, message)

if __name__ == "__main__":
    run_tests()