package com.telecom.enterprise.middleware.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.security.Principal;

@RestController
@RequestMapping("/gateway")
@RequiredArgsConstructor
@Slf4j
public class GatewayController {
    
    private final WebClient backendWebClient;
    
    @RequestMapping(value = "/**", method = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE})
    public Mono<ResponseEntity<String>> proxyRequest(
            @RequestBody(required = false) String body,
            @RequestHeader("Content-Type") String contentType,
            HttpMethod method,
            Principal principal,
            @RequestParam(required = false) String path) {
        
        String clientCN = principal != null ? principal.getName() : "anonymous";
        log.info("Gateway request from client: {} - Method: {} - Path: {}", clientCN, method, path);
        
        // Validate mTLS client certificate
        if (principal == null) {
            log.warn("Request rejected - no valid client certificate");
            return Mono.just(ResponseEntity.status(401)
                    .body("{\"error\": \"mTLS authentication required\"}"));
        }
        
        // Forward request to backend
        return backendWebClient
                .method(method)
                .uri(path != null ? path : "")
                .contentType(MediaType.valueOf(contentType != null ? contentType : "application/json"))
                .bodyValue(body != null ? body : "")
                .header("X-Client-CN", clientCN)
                .header("X-Gateway-Forwarded", "true")
                .retrieve()
                .toEntity(String.class)
                .doOnError(e -> log.error("Backend request failed: {}", e.getMessage()))
                .onErrorResume(e -> Mono.just(ResponseEntity.status(502)
                        .body("{\"error\": \"Backend service unavailable\"}")));
    }
    
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("{\"status\": \"UP\", \"service\": \"Security Gateway\"}");
    }
    
    @GetMapping("/info")
    public ResponseEntity<String> info(Principal principal) {
        String clientInfo = principal != null ? principal.getName() : "No certificate";
        return ResponseEntity.ok(String.format(
                "{\"service\": \"Security Gateway\", \"mtls\": \"enabled\", \"client\": \"%s\"}", 
                clientInfo));
    }
}
