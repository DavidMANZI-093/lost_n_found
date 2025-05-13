package services;

import entities.LostItem;
import entities.User;
import exceptions.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import repositories.LostItemRepository;
import repositories.UserRepository;
import utils.JwtUtils;

import java.util.Date;
import java.util.List;

/**
 * Service for managing lost items
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@Service
public class LostItemService {

    @Autowired
    private LostItemRepository lostItemRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * Create a new lost item
     * 
     * @param lostItem the lost item to create
     * @param token the JWT token
     * @return the created lost item
     */
    public LostItem createLostItem(LostItem lostItem, String token) {
        Long userId = jwtUtils.getUserIdFromJwtToken(token);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        
        lostItem.setUser(user);
        lostItem.setCreatedAt(new Date());
        lostItem.setUpdatedAt(new Date());
        
        return lostItemRepository.save(lostItem);
    }

    /**
     * Get all lost items
     * 
     * @return list of all lost items
     */
    public List<LostItem> getAllLostItems() {
        return lostItemRepository.findAll();
    }

    /**
     * Get lost item by ID
     * 
     * @param id the ID of the lost item
     * @return the lost item
     */
    public LostItem getLostItemById(Long id) {
        return lostItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lost item not found with id: " + id));
    }

    /**
     * Update a lost item
     * 
     * @param id the ID of the lost item to update
     * @param lostItemDetails the updated lost item details
     * @param token the JWT token
     * @return the updated lost item
     */
    public LostItem updateLostItem(Long id, LostItem lostItemDetails, String token) {
        Long userId = jwtUtils.getUserIdFromJwtToken(token);
        boolean isAdmin = jwtUtils.isAdminFromJwtToken(token);
        
        LostItem lostItem = lostItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lost item not found with id: " + id));
        
        // Check if user is the owner or an admin
        if (!lostItem.getUser().getId().equals(userId) && !isAdmin) {
            throw new IllegalArgumentException("You are not authorized to update this lost item");
        }
        
        // Update fields if provided
        if (lostItemDetails.getTitle() != null) {
            lostItem.setTitle(lostItemDetails.getTitle());
        }
        
        if (lostItemDetails.getDescription() != null) {
            lostItem.setDescription(lostItemDetails.getDescription());
        }
        
        if (lostItemDetails.getCategory() != null) {
            lostItem.setCategory(lostItemDetails.getCategory());
        }
        
        if (lostItemDetails.getLocation() != null) {
            lostItem.setLocation(lostItemDetails.getLocation());
        }
        
        if (lostItemDetails.getImageUrl() != null) {
            lostItem.setImageUrl(lostItemDetails.getImageUrl());
        }
        
        if (lostItemDetails.getLostDate() != null) {
            lostItem.setLostDate(lostItemDetails.getLostDate());
        }
        
        if (lostItemDetails.getStatus() != null && isAdmin) {
            lostItem.setStatus(lostItemDetails.getStatus());
        }
        
        lostItem.setUpdatedAt(new Date());
        
        return lostItemRepository.save(lostItem);
    }

    /**
     * Delete a lost item
     * 
     * @param id the ID of the lost item to delete
     * @param token the JWT token
     */
    public void deleteLostItem(Long id, String token) {
        Long userId = jwtUtils.getUserIdFromJwtToken(token);
        boolean isAdmin = jwtUtils.isAdminFromJwtToken(token);
        
        LostItem lostItem = lostItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Lost item not found with id: " + id));
        
        // Check if user is the owner or an admin
        if (!lostItem.getUser().getId().equals(userId) && !isAdmin) {
            throw new IllegalArgumentException("You are not authorized to delete this lost item");
        }
        
        lostItemRepository.delete(lostItem);
    }

    /**
     * Search lost items
     * 
     * @param keyword the keyword to search for
     * @param location the location to search in
     * @param startDate the start date of the range
     * @param endDate the end date of the range
     * @return list of matching lost items
     */
    public List<LostItem> searchLostItems(String keyword, String location, Date startDate, Date endDate) {
        // If all parameters are null, return all lost items with status "active"
        if (keyword == null && location == null && startDate == null && endDate == null) {
            return lostItemRepository.findByStatus("active");
        }
        
        // If only location is provided
        if (keyword == null && location != null && startDate == null && endDate == null) {
            return lostItemRepository.findByLocationContainingIgnoreCase(location);
        }
        
        // If only keyword is provided
        if (keyword != null && location == null && startDate == null && endDate == null) {
            return lostItemRepository.searchByKeyword(keyword);
        }
        
        // If only date range is provided
        if (keyword == null && location == null && startDate != null && endDate != null) {
            return lostItemRepository.findByLostDateBetween(startDate, endDate);
        }
        
        // For more complex searches, you might need to implement a custom repository method
        // or use criteria API for dynamic queries
        
        // Fallback to returning all active lost items
        return lostItemRepository.findByStatus("active");
    }
}
