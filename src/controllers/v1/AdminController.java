package controllers.v1;

import entities.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import payloads.response.ApiResponse;
import services.AdminService;

import java.util.Map;

/**
 * Controller for admin operations
 * 
 */
@RestController
@RequestMapping("/api/v1/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private AdminService adminService;

    /**
     * Updates user ban status
     * 
     * @param id the ID of the user to update
     * @param requestBody map containing isBanned boolean
     * @return ResponseEntity with API response
     */
    @PatchMapping("/users/{id}")
    public ResponseEntity<ApiResponse<User>> updateUserBanStatus(
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> requestBody) {
        try {
            Boolean isBanned = requestBody.get("is_banned");
            if (isBanned == null) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(400, "is_banned field is required"));
            }
            
            User updatedUser = adminService.updateUserBanStatus(id, isBanned);
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "User status updated successfully", updatedUser));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, e.getMessage()));
        }
    }

    /**
     * Updates item status (approve/reject)
     * 
     * @param id the ID of the item
     * @param requestBody map containing status and type strings
     * @return ResponseEntity with API response
     */
    @PatchMapping("/items/{id}")
    public ResponseEntity<ApiResponse<Map<String, String>>> updateItemStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> requestBody) {
        try {
            String status = requestBody.get("status");
            String type = requestBody.get("type");
            
            if (status == null || type == null) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(400, "status and type fields are required"));
            }
            
            adminService.updateItemStatus(id, status, type);
            
            Map<String, String> message = Map.of("message", "Item status updated successfully");
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Item status updated successfully", message));
        } catch (Exception e) {
            if (e.getMessage().contains("Status must be") || e.getMessage().contains("Type must be")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(400, e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, e.getMessage()));
        }
    }

    /**
     * Gets system reports
     * 
     * @return ResponseEntity with API response
     */
    @GetMapping("/reports")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSystemReports() {
        try {
            Map<String, Object> reports = adminService.getSystemReports();
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "System reports retrieved successfully", reports));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, e.getMessage()));
        }
    }
}
