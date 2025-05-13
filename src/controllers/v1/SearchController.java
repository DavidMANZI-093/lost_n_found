package controllers.v1;

import entities.FoundItem;
import entities.LostItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import payloads.response.ApiResponse;
import services.FoundItemService;
import services.LostItemService;

import java.util.Date;
import java.util.List;

/**
 * Controller for searching lost and found items
 * 
 */
@RestController
@RequestMapping("/api/v1/search")
public class SearchController {

    @Autowired
    private LostItemService lostItemService;

    @Autowired
    private FoundItemService foundItemService;

    /**
     * Searches for lost or found items based on criteria
     * 
     * @param type the type of items to search (lost/found)
     * @param keyword keyword to search in title or description
     * @param location location to search
     * @param startDate start date of range
     * @param endDate end date of range
     * @return ResponseEntity with API response
     */
    @GetMapping
    public ResponseEntity<?> searchItems(
            @RequestParam String type,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date endDate) {
        
        try {
            if (type.equalsIgnoreCase("lost")) {
                List<LostItem> results = lostItemService.searchLostItems(keyword, location, startDate, endDate);
                return ResponseEntity.ok()
                        .body(ApiResponse.success(200, "Search results for lost items", results));
            } else if (type.equalsIgnoreCase("found")) {
                List<FoundItem> results = foundItemService.searchFoundItems(keyword, location, startDate, endDate);
                return ResponseEntity.ok()
                        .body(ApiResponse.success(200, "Search results for found items", results));
            } else {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error(400, "Type must be 'lost' or 'found'"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, e.getMessage()));
        }
    }
}
