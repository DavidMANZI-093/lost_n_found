package services;

import entities.FoundItem;
import entities.User;
import exceptions.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import repositories.FoundItemRepository;
import repositories.UserRepository;
import utils.JwtUtils;

import java.util.Date;
import java.util.List;

/**
 * Service for managing found items
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@Service
public class FoundItemService {

    @Autowired
    private FoundItemRepository foundItemRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * Creates a new found item
     * 
     * @param foundItem the found item to create
     * @param token the JWT token
     * @return the created found item
     */
    public FoundItem createFoundItem(FoundItem foundItem, String token) {
        Long userId = jwtUtils.getUserIdFromJwtToken(token);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        
        foundItem.setUser(user);
        foundItem.setCreatedAt(new Date());
        foundItem.setUpdatedAt(new Date());
        
        return foundItemRepository.save(foundItem);
    }

    /**
     * Gets all found items
     * 
     * @return list of all found items
     */
    public List<FoundItem> getAllFoundItems() {
        return foundItemRepository.findAll();
    }

    /**
     * Gets a found item by ID
     * 
     * @param id the ID of the found item
     * @return the found item
     */
    public FoundItem getFoundItemById(Long id) {
        return foundItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Found item not found with id: " + id));
    }

    /**
     * Updates a found item
     * 
     * @param id the ID of the found item to update
     * @param foundItemDetails the updated found item details
     * @param token the JWT token
     * @return the updated found item
     */
    public FoundItem updateFoundItem(Long id, FoundItem foundItemDetails, String token) {
        Long userId = jwtUtils.getUserIdFromJwtToken(token);
        boolean isAdmin = jwtUtils.isAdminFromJwtToken(token);
        
        FoundItem foundItem = foundItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Found item not found with id: " + id));
        
        // Check if user is the owner or an admin
        if (!foundItem.getUser().getId().equals(userId) && !isAdmin) {
            throw new IllegalArgumentException("You are not authorized to update this found item");
        }
        
        // Update fields if provided
        if (foundItemDetails.getTitle() != null) {
            foundItem.setTitle(foundItemDetails.getTitle());
        }
        
        if (foundItemDetails.getDescription() != null) {
            foundItem.setDescription(foundItemDetails.getDescription());
        }
        
        if (foundItemDetails.getCategory() != null) {
            foundItem.setCategory(foundItemDetails.getCategory());
        }
        
        if (foundItemDetails.getLocation() != null) {
            foundItem.setLocation(foundItemDetails.getLocation());
        }
        
        if (foundItemDetails.getImageUrl() != null) {
            foundItem.setImageUrl(foundItemDetails.getImageUrl());
        }
        
        if (foundItemDetails.getFoundDate() != null) {
            foundItem.setFoundDate(foundItemDetails.getFoundDate());
        }
        
        if (foundItemDetails.getStorageLocation() != null) {
            foundItem.setStorageLocation(foundItemDetails.getStorageLocation());
        }
        
        if (foundItemDetails.getStatus() != null && isAdmin) {
            foundItem.setStatus(foundItemDetails.getStatus());
        }
        
        foundItem.setUpdatedAt(new Date());
        
        return foundItemRepository.save(foundItem);
    }

    /**
     * Deletes a found item
     * 
     * @param id the ID of the found item to delete
     * @param token the JWT token
     */
    public void deleteFoundItem(Long id, String token) {
        Long userId = jwtUtils.getUserIdFromJwtToken(token);
        boolean isAdmin = jwtUtils.isAdminFromJwtToken(token);
        
        FoundItem foundItem = foundItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Found item not found with id: " + id));
        
        // Check if user is the owner or an admin
        if (!foundItem.getUser().getId().equals(userId) && !isAdmin) {
            throw new IllegalArgumentException("You are not authorized to delete this found item");
        }
        
        foundItemRepository.delete(foundItem);
    }

    /**
     * Searches for found items
     * 
     * @param keyword the keyword to search for
     * @param location the location to search in
     * @param startDate the start date of the range
     * @param endDate the end date of the range
     * @return list of matching found items
     */
    public List<FoundItem> searchFoundItems(String keyword, String location, Date startDate, Date endDate) {
        // If all parameters are null, return all found items with status "active"
        if (keyword == null && location == null && startDate == null && endDate == null) {
            return foundItemRepository.findByStatus("active");
        }
        
        // If only location is provided
        if (keyword == null && location != null && startDate == null && endDate == null) {
            return foundItemRepository.findByLocationContainingIgnoreCase(location);
        }
        
        // If only keyword is provided
        if (keyword != null && location == null && startDate == null && endDate == null) {
            return foundItemRepository.searchByKeyword(keyword);
        }
        
        // If only date range is provided
        if (keyword == null && location == null && startDate != null && endDate != null) {
            return foundItemRepository.findByFoundDateBetween(startDate, endDate);
        }
        
        // Fallback to returning all active found items
        return foundItemRepository.findByStatus("active");
    }
}
