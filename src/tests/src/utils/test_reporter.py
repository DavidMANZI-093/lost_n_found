import time
import sys
from colorama import Fore, Style, init
import pyfiglet
from prettytable import PrettyTable

# Initialize colorama
init(autoreset=True)

class TestReporter:
    def __init__(self):
        """Initialize test reporter for tracking test results"""
        self.tests_passed = 0
        self.tests_failed = 0
        self.test_results = []
        self.current_stage = None
        self.start_time = time.time()
    
    def set_stage(self, stage_name):
        """Set the current test stage"""
        self.current_stage = stage_name
        title = f"Stage: {stage_name}"
        print(f"\n{Fore.CYAN}{title}{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'=' * 80}{Style.RESET_ALL}\n")
    
    def start_test(self, test_name):
        """Initialize a test with a progress bar"""
        sys.stdout.write(f"{Fore.YELLOW}▶ Running: {test_name}{Style.RESET_ALL}")
        sys.stdout.flush()
        return time.time()
    
    def end_test(self, test_name, start_time, passed, message=""):
        """Record test completion and result"""
        elapsed = time.time() - start_time
        
        if passed:
            self.tests_passed += 1
            status = f"{Fore.GREEN}✓ PASS{Style.RESET_ALL}"
        else:
            self.tests_failed += 1
            status = f"{Fore.RED}✗ FAIL{Style.RESET_ALL}"
        
        # Clear the previous line and print result
        sys.stdout.write("\r" + " " * 100 + "\r")
        print(f"{status} | {test_name} [{elapsed:.3f}s]")
        
        if message:
            print(f"    {Fore.BLUE}▹ {message}{Style.RESET_ALL}")
        
        self.test_results.append({
            "stage": self.current_stage,
            "name": test_name,
            "status": "PASS" if passed else "FAIL",
            "time": elapsed,
            "message": message
        })
    
    def assert_status_code(self, response, expected_status_code):
        """Assert that the response has the expected status code"""
        actual = response.status_code
        return actual == expected_status_code, f"Expected status {expected_status_code}, got {actual}"
    
    def assert_json_key(self, response_json, key, expected_value=None):
        """Assert that the JSON response contains the specified key and optionally has the expected value"""
        if key not in response_json:
            return False, f"Expected key '{key}' not found in response"
        
        if expected_value is not None and response_json[key] != expected_value:
            return False, f"Expected '{key}' to be '{expected_value}', got '{response_json[key]}'"
            
        return True, f"Found key '{key}'" + (f" with value '{expected_value}'" if expected_value is not None else "")
    
    def summarize(self):
        """Print a summary of all test results"""
        title = pyfiglet.figlet_format("Test Summary", font="slant", width=100)
        print(f"\n{Fore.CYAN}{title}{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'=' * 80}{Style.RESET_ALL}\n")
        
        # Create stage summary table
        stage_results = {}
        for result in self.test_results:
            stage = result["stage"]
            status = result["status"]
            
            if stage not in stage_results:
                stage_results[stage] = {"PASS": 0, "FAIL": 0}
            
            stage_results[stage][status] += 1
        
        stage_table = PrettyTable()
        stage_table.field_names = ["Stage", "Passed", "Failed", "Total", "Success Rate"]
        
        for stage, counts in stage_results.items():
            total = counts["PASS"] + counts["FAIL"]
            success_rate = (counts["PASS"] / total) * 100 if total > 0 else 0
            
            stage_table.add_row([
                stage,
                f"{Fore.GREEN}{counts['PASS']}{Style.RESET_ALL}",
                f"{Fore.RED}{counts['FAIL']}{Style.RESET_ALL}",
                total,
                f"{success_rate:.1f}%"
            ])
        
        print(stage_table)
        
        # Print overall summary
        total_tests = self.tests_passed + self.tests_failed
        success_rate = (self.tests_passed / total_tests) * 100 if total_tests > 0 else 0
        total_time = time.time() - self.start_time
        
        print(f"\n{Fore.YELLOW}Summary:{Style.RESET_ALL}")
        print(f"  • Total Tests: {total_tests}")
        print(f"  • {Fore.GREEN}Passed: {self.tests_passed}{Style.RESET_ALL}")
        print(f"  • {Fore.RED}Failed: {self.tests_failed}{Style.RESET_ALL}")
        print(f"  • Success Rate: {success_rate:.1f}%")
        print(f"  • Total Time: {total_time:.2f}s")
        
        # Final message based on success rate
        if success_rate == 100:
            print(f"\n{Fore.GREEN}✓ All tests passed successfully!{Style.RESET_ALL}")
        elif success_rate >= 80:
            print(f"\n{Fore.YELLOW}⚠ Most tests passed, but some failures occurred.{Style.RESET_ALL}")
        else:
            print(f"\n{Fore.RED}✗ Significant test failures detected!{Style.RESET_ALL}")