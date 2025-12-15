package com.telecom.enterprise.bff.user.service;

import com.telecom.enterprise.bff.user.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserBffService {
    
    private final WebClient backendWebClient;
    
    public Mono<AuthResponse> login(LoginRequest request) {
        log.info("BFF: Processing login for {}", request.getEmail());
        return backendWebClient.post()
                .uri("/api/users/login")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(AuthResponse.class)
                .doOnError(e -> log.error("Login failed: {}", e.getMessage()));
    }
    
    public Mono<AuthResponse> register(RegisterRequest request) {
        log.info("BFF: Processing registration for {}", request.getEmail());
        return backendWebClient.post()
                .uri("/api/users/register")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(AuthResponse.class)
                .doOnError(e -> log.error("Registration failed: {}", e.getMessage()));
    }
    
    public Mono<UserDTO> getProfile(Long userId) {
        log.info("BFF: Getting profile for user {}", userId);
        return backendWebClient.get()
                .uri("/api/users/{id}", userId)
                .retrieve()
                .bodyToMono(UserDTO.class);
    }
    
    public Mono<UserDTO> updateProfile(Long userId, UserDTO updates) {
        log.info("BFF: Updating profile for user {}", userId);
        return backendWebClient.put()
                .uri("/api/users/{id}", userId)
                .bodyValue(updates)
                .retrieve()
                .bodyToMono(UserDTO.class);
    }
    
    public Mono<String> updatePassword(Long userId, String currentPassword, String newPassword) {
        log.info("BFF: Updating password for user {}", userId);
        return backendWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/users/{id}/password")
                        .queryParam("currentPassword", currentPassword)
                        .queryParam("newPassword", newPassword)
                        .build(userId))
                .retrieve()
                .bodyToMono(String.class);
    }
    
    public Mono<List<BillingDTO>> getBillingHistory(Long userId) {
        log.info("BFF: Getting billing history for user {}", userId);
        return backendWebClient.get()
                .uri("/api/billing/user/{userId}", userId)
                .retrieve()
                .bodyToFlux(BillingDTO.class)
                .collectList();
    }
    
    public Mono<BillingDTO> payBill(Long recordId, String paymentMethod) {
        log.info("BFF: Processing bill payment for record {}", recordId);
        return backendWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/billing/{id}/pay")
                        .queryParam("paymentMethod", paymentMethod)
                        .build(recordId))
                .retrieve()
                .bodyToMono(BillingDTO.class);
    }
}
