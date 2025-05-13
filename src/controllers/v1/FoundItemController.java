package controllers.v1;

import entities.FoundItem;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import payloads.response.ApiResponse;
import services.FoundItemService;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for managing found items
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@RestController
@RequestMapping("/api/v1/found-items")
public class FoundItemController {

    @Autowired
    private FoundItemService foundItemService;

    /**
     * Creates a new found item
     * 
     * @param foundItem the found item to create
     * @param authHeader the authorization header with JWT token
     * @return ResponseEntity with API response
     */
    @PostMapping
    public ResponseEntity<ApiResponse<FoundItem>> createFoundItem(
            @Valid @RequestBody FoundItem foundItem, 
            @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.substring(7);
            FoundItem createdFoundItem = foundItemService.createFoundItem(foundItem, token);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(201, "Found item created successfully", createdFoundItem));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, e.getMessage()));
        }
    }

    /**
     * Gets a found item by ID
     * 
     * @param id the ID of the found item
     * @return ResponseEntity with API response
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<FoundItem>> getFoundItemById(@PathVariable Long id) {
        try {
            FoundItem foundItem = foundItemService.getFoundItemById(id);
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Found item retrieved successfully", foundItem));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(404, e.getMessage()));
        }
    }

    /**
     * Updates a found item
     * 
     * @param id the ID of the found item to update
     * @param foundItemDetails the updated found item details
     * @param authHeader the authorization header with JWT token
     * @return ResponseEntity with API response
     */
    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<FoundItem>> updateFoundItem(
            @PathVariable Long id,
            @RequestBody FoundItem foundItemDetails,
            @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.substring(7);
            FoundItem updatedFoundItem = foundItemService.updateFoundItem(id, foundItemDetails, token);
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Found item updated successfully", updatedFoundItem));
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
     * Deletes a found item
     * 
     * @param id the ID of the found item to delete
     * @param authHeader the authorization header with JWT token
     * @return ResponseEntity with API response
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Map<String, String>>> deleteFoundItem(
            @PathVariable Long id,
            @RequestHeader("Authorization") String authHeader) {
        try {
            String token = authHeader.substring(7);
            foundItemService.deleteFoundItem(id, token);
            
            Map<String, String> message = new HashMap<>();
            message.put("message", "Found item deleted successfully");
            
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Found item deleted successfully", message));
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
