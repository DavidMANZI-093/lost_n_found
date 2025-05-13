package services;

import entities.User;
import exceptions.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import repositories.FoundItemRepository;
import repositories.LostItemRepository;
import repositories.UserRepository;

import java.util.HashMap;
import java.util.Map;

/**
 * Service for admin operations
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@Service
public class AdminService {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private LostItemRepository lostItemRepository;
    
    @Autowired
    private FoundItemRepository foundItemRepository;

    /**
     * Updates user ban status
     * 
     * @param userId the ID of the user to update
     * @param isBanned the new ban status
     * @return the updated user
     */
    public User updateUserBanStatus(Long userId, boolean isBanned) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        
        user.setBanned(isBanned);
        return userRepository.save(user);
    }

    /**
     * Updates item status (approve/reject)
     * 
     * @param itemId the ID of the item
     * @param status the new status
     * @param type the type of item (lost/found)
     * @return true if update successful
     */
    public boolean updateItemStatus(Long itemId, String status, String type) {
        if (!status.equals("active") && !status.equals("rejected")) {
            throw new IllegalArgumentException("Status must be 'active' or 'rejected'");
        }
        
        if (type.equals("lost")) {
            var lostItem = lostItemRepository.findById(itemId)
                    .orElseThrow(() -> new ResourceNotFoundException("Lost item not found with id: " + itemId));
            
            lostItem.setStatus(status);
            lostItemRepository.save(lostItem);
            return true;
        } else if (type.equals("found")) {
            var foundItem = foundItemRepository.findById(itemId)
                    .orElseThrow(() -> new ResourceNotFoundException("Found item not found with id: " + itemId));
            
            foundItem.setStatus(status);
            foundItemRepository.save(foundItem);
            return true;
        }
        
        throw new IllegalArgumentException("Type must be 'lost' or 'found'");
    }

    /**
     * Gets system reports
     * 
     * @return map of system statistics
     */
    public Map<String, Object> getSystemReports() {
        Map<String, Object> reports = new HashMap<>();
        
        // User statistics
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.countByIsBannedFalse();
        long bannedUsers = userRepository.countByIsBannedTrue();
        
        // Lost item statistics
        long totalLostItems = lostItemRepository.count();
        long claimedLostItems = lostItemRepository.countByStatus("claimed");
        long activeLostItems = lostItemRepository.countByStatus("active");
        long pendingLostItems = lostItemRepository.countByStatus("pending");
        long rejectedLostItems = lostItemRepository.countByStatus("rejected");
        
        // Found item statistics
        long totalFoundItems = foundItemRepository.count();
        long claimedFoundItems = foundItemRepository.countByStatus("claimed");
        long activeFoundItems = foundItemRepository.countByStatus("active");
        long pendingFoundItems = foundItemRepository.countByStatus("pending");
        long rejectedFoundItems = foundItemRepository.countByStatus("rejected");
        
        // Add to reports map
        reports.put("total_users", totalUsers);
        reports.put("active_users", activeUsers);
        reports.put("banned_users", bannedUsers);
        
        reports.put("total_lost_items", totalLostItems);
        reports.put("claimed_lost_items", claimedLostItems);
        reports.put("active_lost_items", activeLostItems);
        reports.put("pending_lost_items", pendingLostItems);
        reports.put("rejected_lost_items", rejectedLostItems);
        
        reports.put("total_found_items", totalFoundItems);
        reports.put("claimed_found_items", claimedFoundItems);
        reports.put("active_found_items", activeFoundItems);
        reports.put("pending_found_items", pendingFoundItems);
        reports.put("rejected_found_items", rejectedFoundItems);
        
        return reports;
    }
}
