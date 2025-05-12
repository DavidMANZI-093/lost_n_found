package controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import payloads.response.ApiResponse;

import java.util.HashMap;
import java.util.Map;

/**
 * Home controller for the Lost and Found application
 * Provides basic application information and API documentation
 * 
 * @author KASOGA Justesse
 * @reg 11471/2024
 */
@RestController
@RequestMapping("/api")
public class HomeController {

    /**
     * Get application information
     * 
     * @return basic application information
     */
    @GetMapping("/")
    public ResponseEntity<ApiResponse<Map<String, Object>>> home() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "Lost and Found Application");
        info.put("version", "1.0.0");
        info.put("description", "REST API for managing lost and found items");
        
        return ResponseEntity.ok(ApiResponse.success(200, "Welcome to Lost & Found API", info));
    }
    
    /**
     * Get API version information
     * 
     * @return API version information
     */
    @GetMapping("/version")
    public ResponseEntity<ApiResponse<Map<String, Object>>> version() {
        Map<String, Object> version = new HashMap<>();
        version.put("version", "1.0.0");
        version.put("released", "2025-05-12");
        
        return ResponseEntity.ok(ApiResponse.success(200, "API version information", version));
    }
}
