package controllers.v1;

import entities.FoundItem;
import entities.LostItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import payloads.response.ApiResponse;
import services.FoundItemService;
import services.LostItemService;

import java.util.List;
import java.util.Map;

/**
 * Controller for managing both lost and found items
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@RestController
@RequestMapping("/api/v1/items")
public class ItemController {

    @Autowired
    private LostItemService lostItemService;

    @Autowired
    private FoundItemService foundItemService;

    /**
     * Get all items (both lost and found)
     * 
     * @param type optional filter by type (lost/found)
     * @return ResponseEntity with API response
     */
    @GetMapping
    public ResponseEntity<?> getAllItems(@RequestParam(required = false) String type) {
        try {
            if (type == null || type.isEmpty()) {
                // Get both lost and found items
                List<LostItem> lostItems = lostItemService.getAllLostItems();
                List<FoundItem> foundItems = foundItemService.getAllFoundItems();
                
                Map<String, Object> data = Map.of(
                    "lost_items", lostItems,
                    "found_items", foundItems
                );
                
                return ResponseEntity.ok()
                        .body(ApiResponse.success(200, "All items retrieved successfully", data));
            } else if (type.equalsIgnoreCase("lost")) {
                // Get only lost items
                List<LostItem> lostItems = lostItemService.getAllLostItems();
                return ResponseEntity.ok()
                        .body(ApiResponse.success(200, "Lost items retrieved successfully", lostItems));
            } else if (type.equalsIgnoreCase("found")) {
                // Get only found items
                List<FoundItem> foundItems = foundItemService.getAllFoundItems();
                return ResponseEntity.ok()
                        .body(ApiResponse.success(200, "Found items retrieved successfully", foundItems));
            } else {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(400, "Invalid type. Must be 'lost' or 'found'"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, e.getMessage()));
        }
    }

    /**
     * Get statistics about items
     * 
     * @return ResponseEntity with API response
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getItemStats() {
        try {
            long totalLostItems = lostItemService.getAllLostItems().size();
            long totalFoundItems = foundItemService.getAllFoundItems().size();
            long totalItems = totalLostItems + totalFoundItems;
            
            Map<String, Object> stats = Map.of(
                "total_items", totalItems,
                "total_lost_items", totalLostItems,
                "total_found_items", totalFoundItems
            );
            
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Item statistics retrieved successfully", stats));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, e.getMessage()));
        }
    }
}
