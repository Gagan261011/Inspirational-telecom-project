package com.telecom.enterprise.backend.controller;

import com.telecom.enterprise.backend.dto.*;
import com.telecom.enterprise.backend.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Tag(name = "User Management", description = "User authentication and profile management")
@CrossOrigin(origins = "*")
public class UserController {
    
    private final UserService userService;
    
    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        AuthResponse response = userService.register(request);
        return response.isSuccess() 
                ? ResponseEntity.ok(response) 
                : ResponseEntity.badRequest().body(response);
    }
    
    @PostMapping("/login")
    @Operation(summary = "Login with email and password")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        AuthResponse response = userService.login(request);
        return response.isSuccess() 
                ? ResponseEntity.ok(response) 
                : ResponseEntity.status(401).body(response);
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    public ResponseEntity<UserDTO> getUser(@PathVariable Long id) {
        UserDTO user = userService.getUserById(id);
        return user != null 
                ? ResponseEntity.ok(user) 
                : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/email/{email}")
    @Operation(summary = "Get user by email")
    public ResponseEntity<UserDTO> getUserByEmail(@PathVariable String email) {
        UserDTO user = userService.getUserByEmail(email);
        return user != null 
                ? ResponseEntity.ok(user) 
                : ResponseEntity.notFound().build();
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update user profile")
    public ResponseEntity<UserDTO> updateProfile(@PathVariable Long id, @RequestBody UserDTO updates) {
        UserDTO user = userService.updateProfile(id, updates);
        return user != null 
                ? ResponseEntity.ok(user) 
                : ResponseEntity.notFound().build();
    }
    
    @PostMapping("/{id}/password")
    @Operation(summary = "Update user password")
    public ResponseEntity<String> updatePassword(
            @PathVariable Long id,
            @RequestParam String currentPassword,
            @RequestParam String newPassword) {
        boolean success = userService.updatePassword(id, currentPassword, newPassword);
        return success 
                ? ResponseEntity.ok("Password updated successfully") 
                : ResponseEntity.badRequest().body("Current password is incorrect");
    }
}
