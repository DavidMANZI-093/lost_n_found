package payloads.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

/**
 * Request payload for lost item operations
 * 
 */
@Data
public class LostItemRequest {
    
    @NotBlank(message = "Title is required")
    private String title;
    
    @NotBlank(message = "Description is required")
    private String description;
    
    @NotBlank(message = "Category is required")
    private String category;
    
    @NotBlank(message = "Location is required")
    private String location;
    
    private String imageUrl;
    
    @NotNull(message = "Lost date is required")
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
    private Date lostDate;
}
