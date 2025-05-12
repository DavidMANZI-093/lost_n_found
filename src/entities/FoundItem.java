package entities;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Date;

/**
 * FoundItem entity for the Lost and Found application
 * 
 * @author KASOGA Justesse
 * @reg 11471/2024
 */
@Entity
@Table(name = "found_items")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FoundItem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(nullable = false)
    private String title;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;
    
    @Column(nullable = false)
    private String category;
    
    @Column(nullable = false)
    private String location;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(name = "found_date", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date foundDate;
    
    @Column(name = "storage_location", nullable = false)
    private String storageLocation;
    
    @Column(nullable = false)
    private String status = "pending"; // "pending", "active", "claimed", "rejected"
    
    @Column(name = "created_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createdAt = new Date();
    
    @Column(name = "updated_at")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updatedAt = new Date();
}
