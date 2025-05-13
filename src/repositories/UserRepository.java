package repositories;

import entities.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

/**
 * Repository interface for User entity
 * 
 * @author KASOGA Justesse
 * @reg 11471/2017
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * Finds a user by email
     * 
     * @param email the email to search for
     * @return Optional containing the user if found
     */
    Optional<User> findByEmail(String email);
    
    /**
     * Checks if a user exists with the given email
     * 
     * @param email the email to check
     * @return true if a user exists with the email
     */
    boolean existsByEmail(String email);
    
    /**
     * Counts active users (not banned)
     * 
     * @return count of active users
     */
    long countByIsBannedFalse();
    
    /**
     * Counts banned users
     * 
     * @return count of banned users
     */
    long countByIsBannedTrue();
}
