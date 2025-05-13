package repositories;

import entities.LostItem;
import entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Date;
import java.util.List;

/**
 * Repository interface for LostItem entity
 * 
 */
@Repository
public interface LostItemRepository extends JpaRepository<LostItem, Long> {
    
    /**
     * Finds all lost items by user
     * 
     * @param user the user who created the lost items
     * @return List of lost items
     */
    List<LostItem> findByUser(User user);
    
    /**
     * Finds all lost items by status
     * 
     * @param status the status to filter by
     * @return List of lost items with the specified status
     */
    List<LostItem> findByStatus(String status);
    
    /**
     * Finds all lost items by location containing the given string (case insensitive)
     * 
     * @param location the location substring to search for
     * @return List of lost items matching the location
     */
    List<LostItem> findByLocationContainingIgnoreCase(String location);
    
    /**
     * Finds all lost items by category
     * 
     * @param category the category to filter by
     * @return List of lost items with the specified category
     */
    List<LostItem> findByCategory(String category);
    
    /**
     * Finds all lost items by title or description containing the given string (case insensitive)
     * 
     * @param keyword the keyword to search for in title or description
     * @return List of lost items matching the keyword
     */
    @Query("SELECT l FROM LostItem l WHERE LOWER(l.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(l.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<LostItem> searchByKeyword(@Param("keyword") String keyword);
    
    /**
     * Finds all lost items by date range
     * 
     * @param startDate the start date of the range
     * @param endDate the end date of the range
     * @return List of lost items within the date range
     */
    List<LostItem> findByLostDateBetween(Date startDate, Date endDate);
    
    /**
     * Counts lost items by status
     * 
     * @param status the status to count
     * @return count of lost items with the specified status
     */
    long countByStatus(String status);
}
