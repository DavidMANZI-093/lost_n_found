package controllers.v1;

import entities.User;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import payloads.request.LoginRequest;
import payloads.request.SignupRequest;
import payloads.response.ApiResponse;
import services.AuthService;

import java.util.Map;

/**
 * Authentication controller for signup and signin endpoints
 * 
 * @author KASOGA Justesse
 * @reg 11471/2024
 */
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    @Autowired
    private AuthService authService;

    /**
     * Register a new user
     * 
     * @param request the signup request
     * @return ResponseEntity with API response
     */
    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<User>> registerUser(@Valid @RequestBody SignupRequest request) {
        try {
            User user = authService.registerUser(request);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success(201, "User registered successfully", user));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(400, e.getMessage()));
        }
    }

    /**
     * Authenticate user and generate JWT token
     * 
     * @param request the login request
     * @return ResponseEntity with API response
     */
    @PostMapping("/signin")
    public ResponseEntity<ApiResponse<Map<String, Object>>> authenticateUser(@Valid @RequestBody LoginRequest request) {
        try {
            Map<String, Object> response = authService.authenticateUser(request);
            return ResponseEntity.ok()
                    .body(ApiResponse.success(200, "Authentication successful", response));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error(401, e.getMessage()));
        }
    }
}
