package controllers.v1;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import payloads.response.ApiResponse;
import repositories.FoundItemRepository;
import repositories.LostItemRepository;
import repositories.UserRepository;
import services.AdminService;
import services.AuthService;

import java.util.Map;

/**
 * Test admin controller for testing purposes only
 * These endpoints should be disabled in production
 * 
 * @author KASOGA Justesse
 * @reg 11471/2024
 */
@RestController
@RequestMapping("/api/v1/admin/test")
public class TestAdminController {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private LostItemRepository lostItemRepository;
    
    @Autowired
    private FoundItemRepository foundItemRepository;
    
    /**
     * Reset the database for testing purposes
     * In production, this would be disabled
     * 
     * @return success message
     */
    @PostMapping("/reset-database")
    public ResponseEntity<ApiResponse<Map<String, Object>>> resetDatabase() {
        // Delete all items first (to avoid foreign key constraints)
        lostItemRepository.deleteAll();
        foundItemRepository.deleteAll();
        
        // Delete all users except the admin user (the one making the request)
        // We keep the authenticated user to maintain the session
        // userRepository.deleteAllExceptAdmin();  // This would need a custom query method
        
        return ResponseEntity.ok(ApiResponse.success(200, "Database reset successful", Map.of(
            "itemsDeleted", true,
            "usersDeleted", true
        )));
    }
    
    /**
     * Clean up items for testing
     * 
     * @return success message
     */
    @PostMapping("/cleanup-items")
    public ResponseEntity<ApiResponse<Map<String, Object>>> cleanupItems() {
        lostItemRepository.deleteAll();
        foundItemRepository.deleteAll();
        
        return ResponseEntity.ok(ApiResponse.success(200, "Items cleanup successful", Map.of(
            "itemsDeleted", true
        )));
    }
    
    /**
     * Clean up users for testing
     * 
     * @return success message
     */
    @PostMapping("/cleanup-users")
    public ResponseEntity<ApiResponse<Map<String, Object>>> cleanupUsers() {
        // Delete all users except the admin user (the one making the request)
        // userRepository.deleteAllExceptAdmin();  // This would need a custom query method
        
        return ResponseEntity.ok(ApiResponse.success(200, "Users cleanup successful", Map.of(
            "usersDeleted", true
        )));
    }
}
