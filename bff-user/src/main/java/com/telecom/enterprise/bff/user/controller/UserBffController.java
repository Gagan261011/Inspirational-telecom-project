package com.telecom.enterprise.bff.user.controller;

import com.telecom.enterprise.bff.user.dto.*;
import com.telecom.enterprise.bff.user.service.UserBffService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "User BFF", description = "Backend for Frontend - User Operations")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class UserBffController {
    
    private final UserBffService userBffService;
    
    @PostMapping("/auth/login")
    @Operation(summary = "User login")
    public Mono<ResponseEntity<AuthResponse>> login(@RequestBody LoginRequest request) {
        return userBffService.login(request)
                .map(response -> response.isSuccess() 
                        ? ResponseEntity.ok(response) 
                        : ResponseEntity.status(401).body(response));
    }
    
    @PostMapping("/auth/register")
    @Operation(summary = "User registration")
    public Mono<ResponseEntity<AuthResponse>> register(@RequestBody RegisterRequest request) {
        return userBffService.register(request)
                .map(response -> response.isSuccess() 
                        ? ResponseEntity.ok(response) 
                        : ResponseEntity.badRequest().body(response));
    }
    
    @GetMapping("/users/{userId}/profile")
    @Operation(summary = "Get user profile")
    public Mono<ResponseEntity<UserDTO>> getProfile(@PathVariable Long userId) {
        return userBffService.getProfile(userId)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/users/{userId}/profile")
    @Operation(summary = "Update user profile")
    public Mono<ResponseEntity<UserDTO>> updateProfile(
            @PathVariable Long userId,
            @RequestBody UserDTO updates) {
        return userBffService.updateProfile(userId, updates)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @PostMapping("/users/{userId}/password")
    @Operation(summary = "Update user password")
    public Mono<ResponseEntity<String>> updatePassword(
            @PathVariable Long userId,
            @RequestParam String currentPassword,
            @RequestParam String newPassword) {
        return userBffService.updatePassword(userId, currentPassword, newPassword)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.badRequest().body(e.getMessage())));
    }
    
    @GetMapping("/users/{userId}/billing")
    @Operation(summary = "Get user billing history")
    public Mono<ResponseEntity<List<BillingDTO>>> getBillingHistory(@PathVariable Long userId) {
        return userBffService.getBillingHistory(userId)
                .map(ResponseEntity::ok);
    }
    
    @PostMapping("/billing/{recordId}/pay")
    @Operation(summary = "Pay a bill")
    public Mono<ResponseEntity<BillingDTO>> payBill(
            @PathVariable Long recordId,
            @RequestParam String paymentMethod) {
        return userBffService.payBill(recordId, paymentMethod)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
}
