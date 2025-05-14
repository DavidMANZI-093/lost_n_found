import os
import json
import argparse
from tqdm import tqdm
import time
from colorama import Fore, Style, init
import pyfiglet

from .db_manager import DatabaseManager
from .api_client import APIClient

# Initialize colorama
init(autoreset=True)

def setup_project_scaffold():
    """Create the project structure and setup necessary files"""
    title = pyfiglet.figlet_format("Test Setup", font="slant", width=100)
    print(f"{Fore.CYAN}{title}{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'=' * 80}{Style.RESET_ALL}")
    
    # Create directories
    directories = ["tests", "data", "reports"]
    print(f"{Fore.YELLOW}Creating directory structure...{Style.RESET_ALL}")
    
    for directory in tqdm(directories, desc="Creating directories", ncols=80):
        os.makedirs(directory, exist_ok=True)
        time.sleep(0.5)  # Simulate work
    
    print(f"{Fore.GREEN}✓ Directory structure created{Style.RESET_ALL}")
    
    # Check database connection
    print(f"{Fore.YELLOW}Checking database connection...{Style.RESET_ALL}")
    db_manager = DatabaseManager()
    cursor = db_manager.connect()
    
    if cursor:
        print(f"{Fore.GREEN}✓ Database connection successful{Style.RESET_ALL}")
        db_manager.close()
    else:
        print(f"{Fore.RED}❌ Database connection failed{Style.RESET_ALL}")
        print(f"  • Please check your database configuration in config.json")
    
    # Check API connection
    print(f"{Fore.YELLOW}Checking API connection...{Style.RESET_ALL}")
    api_client = APIClient()
    
    try:
        # Try to access a simple endpoint to verify API is running
        with tqdm(total=100, desc="Testing API connection", ncols=80) as pbar:
            pbar.update(50)
            response = requests.get(f"{api_client.base_url}/items/stats", timeout=5)
            pbar.update(50)
            
        if response.status_code < 500:  # Accept any non-server error response as "API is running"
            print(f"{Fore.GREEN}✓ API connection successful{Style.RESET_ALL}")
        else:
            print(f"{Fore.RED}❌ API connection failed with status code {response.status_code}{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}❌ API connection failed: {str(e)}{Style.RESET_ALL}")
        print(f"  • Please check if the Spring Boot API is running at {api_client.base_url}")
    
    print(f"\n{Fore.GREEN}Setup complete! You can now run the tests with:{Style.RESET_ALL}")
    print(f"  python main.py")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Lost & Found API Testing Framework")
    parser.add_argument("--setup", action="store_true", help="Setup project scaffold")
    
    args = parser.parse_args()
    
    if args.setup:
        setup_project_scaffold()
    else:
        from main import run_tests
        run_tests()