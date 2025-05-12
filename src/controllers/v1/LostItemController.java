package controllers.v1;

import entities.LostItem;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import payloads.response.ApiResponse;
import services.LostItemService;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for managing lost items
 * 
 * @author KASOGA Justesse
 * @reg 11471/2024
 */
@RestController
@RequestMapping("/api/v1/lost-items")
public class LostItemController {

    @Autowired
    private LostItemService lostItemService;

    /**
     * Create a new lost item
     * 
     * @param lostItem the lost item to create
     * @param authHeader the authorization header with JWT token
     * @return ResponseEntity with API response
     */
    @PostMapping
    public ResponseEntity<ApiResponse<LostItem>> createLostItem(
            @Valid @RequestBody LostItem lostItem, 
            @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.substring(7);
            LostItem createdLostItem = lostItemService.createLostItem(lostItem, token);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(201, "Lost item created successfully", createdLostItem));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, e.getMessage()));
        }
    }

    /**
     * Get a lost item by ID
     * 
     * @param id the ID of the lost item
     * @return ResponseEntity with API response
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<LostItem>> getLostItemById(@PathVariable Long id) {
        try {
            LostItem lostItem = lostItemService.getLostItemById(id);
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Lost item retrieved successfully", lostItem));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, e.getMessage()));
        }
    }

    /**
     * Update a lost item
     * 
     * @param id the ID of the lost item to update
     * @param lostItemDetails the updated lost item details
     * @param authHeader the authorization header with JWT token
     * @return ResponseEntity with API response
     */
    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<LostItem>> updateLostItem(
            @PathVariable Long id,
            @RequestBody LostItem lostItemDetails,
            @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.substring(7);
            LostItem updatedLostItem = lostItemService.updateLostItem(id, lostItemDetails, token);
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Lost item updated successfully", updatedLostItem));
        } catch (Exception e) {
            if (e.getMessage().contains("authorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(ApiResponse.error(403, e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, e.getMessage()));
        }
    }

    /**
     * Delete a lost item
     * 
     * @param id the ID of the lost item to delete
     * @param authHeader the authorization header with JWT token
     * @return ResponseEntity with API response
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, String>>> deleteLostItem(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.substring(7);
            lostItemService.deleteLostItem(id, token);
            
            Map<String, String> message = new HashMap<>();
            message.put("message", "Lost item deleted successfully");
            
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Lost item deleted successfully", message));
        } catch (Exception e) {
            if (e.getMessage().contains("authorized")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(ApiResponse.error(403, e.getMessage()));
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, e.getMessage()));
        }
    }
}
