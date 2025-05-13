package repositories;

import entities.FoundItem;
import entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Date;
import java.util.List;

/**
 * Repository interface for FoundItem entity
 * 
 */
@Repository
public interface FoundItemRepository extends JpaRepository<FoundItem, Long> {
    
    /**
     * Finds all found items by user
     * 
     * @param user the user who created the found items
     * @return List of found items
     */
    List<FoundItem> findByUser(User user);
    
    /**
     * Finds all found items by status
     * 
     * @param status the status to filter by
     * @return List of found items with the specified status
     */
    List<FoundItem> findByStatus(String status);
    
    /**
     * Finds all found items by location containing the given string (case insensitive)
     * 
     * @param location the location substring to search for
     * @return List of found items matching the location
     */
    List<FoundItem> findByLocationContainingIgnoreCase(String location);
    
    /**
     * Finds all found items by category
     * 
     * @param category the category to filter by
     * @return List of found items with the specified category
     */
    List<FoundItem> findByCategory(String category);
    
    /**
     * Finds all found items by title or description containing the given string (case insensitive)
     * 
     * @param keyword the keyword to search for in title or description
     * @return List of found items matching the keyword
     */
    @Query("SELECT f FROM FoundItem f WHERE LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(f.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<FoundItem> searchByKeyword(@Param("keyword") String keyword);
    
    /**
     * Finds all found items by date range
     * 
     * @param startDate the start date of the range
     * @param endDate the end date of the range
     * @return List of found items within the date range
     */
    List<FoundItem> findByFoundDateBetween(Date startDate, Date endDate);
    
    /**
     * Count found items by status
     * 
     * @param status the status to count
     * @return count of found items with the specified status
     */
    long countByStatus(String status);
}
