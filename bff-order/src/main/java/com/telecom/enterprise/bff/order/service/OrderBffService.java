package com.telecom.enterprise.bff.order.service;

import com.telecom.enterprise.bff.order.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderBffService {
    
    private final WebClient backendWebClient;
    
    // Product operations
    public Mono<List<ProductDTO>> getAllProducts() {
        log.info("BFF: Getting all products");
        return backendWebClient.get()
                .uri("/api/products")
                .retrieve()
                .bodyToFlux(ProductDTO.class)
                .collectList();
    }
    
    public Mono<ProductDTO> getProduct(Long productId) {
        log.info("BFF: Getting product {}", productId);
        return backendWebClient.get()
                .uri("/api/products/{id}", productId)
                .retrieve()
                .bodyToMono(ProductDTO.class);
    }
    
    public Mono<List<ProductDTO>> getProductsByCategory(String category) {
        log.info("BFF: Getting products by category {}", category);
        return backendWebClient.get()
                .uri("/api/products/category/{category}", category)
                .retrieve()
                .bodyToFlux(ProductDTO.class)
                .collectList();
    }
    
    public Mono<List<ProductDTO>> getFeaturedProducts() {
        log.info("BFF: Getting featured products");
        return backendWebClient.get()
                .uri("/api/products/featured")
                .retrieve()
                .bodyToFlux(ProductDTO.class)
                .collectList();
    }
    
    public Mono<List<ProductDTO>> searchProducts(String query) {
        log.info("BFF: Searching products for: {}", query);
        return backendWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/products/search")
                        .queryParam("query", query)
                        .build())
                .retrieve()
                .bodyToFlux(ProductDTO.class)
                .collectList();
    }
    
    public Mono<List<String>> getCategories() {
        log.info("BFF: Getting categories");
        return backendWebClient.get()
                .uri("/api/products/categories")
                .retrieve()
                .bodyToFlux(String.class)
                .collectList();
    }
    
    // Cart operations
    public Mono<CartDTO> getCart(Long userId) {
        log.info("BFF: Getting cart for user {}", userId);
        return backendWebClient.get()
                .uri("/api/cart/{userId}", userId)
                .retrieve()
                .bodyToMono(CartDTO.class);
    }
    
    public Mono<CartDTO> addToCart(Long userId, Long productId, Integer quantity) {
        log.info("BFF: Adding product {} to cart for user {}", productId, userId);
        return backendWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/cart/{userId}/items")
                        .queryParam("productId", productId)
                        .queryParam("quantity", quantity)
                        .build(userId))
                .retrieve()
                .bodyToMono(CartDTO.class);
    }
    
    public Mono<CartDTO> updateCartItem(Long userId, Long itemId, Integer quantity) {
        log.info("BFF: Updating cart item {} for user {}", itemId, userId);
        return backendWebClient.put()
                .uri(uriBuilder -> uriBuilder
                        .path("/api/cart/{userId}/items/{itemId}")
                        .queryParam("quantity", quantity)
                        .build(userId, itemId))
                .retrieve()
                .bodyToMono(CartDTO.class);
    }
    
    public Mono<CartDTO> removeFromCart(Long userId, Long itemId) {
        log.info("BFF: Removing item {} from cart for user {}", itemId, userId);
        return backendWebClient.delete()
                .uri("/api/cart/{userId}/items/{itemId}", userId, itemId)
                .retrieve()
                .bodyToMono(CartDTO.class);
    }
    
    public Mono<Void> clearCart(Long userId) {
        log.info("BFF: Clearing cart for user {}", userId);
        return backendWebClient.delete()
                .uri("/api/cart/{userId}", userId)
                .retrieve()
                .bodyToMono(Void.class);
    }
    
    // Order operations
    public Mono<OrderDTO> createOrder(CreateOrderRequest request) {
        log.info("BFF: Creating order for user {}", request.getUserId());
        return backendWebClient.post()
                .uri("/api/orders")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(OrderDTO.class);
    }
    
    public Mono<OrderDTO> getOrder(Long orderId) {
        log.info("BFF: Getting order {}", orderId);
        return backendWebClient.get()
                .uri("/api/orders/{id}", orderId)
                .retrieve()
                .bodyToMono(OrderDTO.class);
    }
    
    public Mono<OrderDTO> getOrderByNumber(String orderNumber) {
        log.info("BFF: Getting order by number {}", orderNumber);
        return backendWebClient.get()
                .uri("/api/orders/number/{orderNumber}", orderNumber)
                .retrieve()
                .bodyToMono(OrderDTO.class);
    }
    
    public Mono<List<OrderDTO>> getUserOrders(Long userId) {
        log.info("BFF: Getting orders for user {}", userId);
        return backendWebClient.get()
                .uri("/api/orders/user/{userId}", userId)
                .retrieve()
                .bodyToFlux(OrderDTO.class)
                .collectList();
    }
    
    public Mono<OrderDTO> trackOrder(String trackingNumber) {
        log.info("BFF: Tracking order {}", trackingNumber);
        return backendWebClient.get()
                .uri("/api/orders/track/{trackingNumber}", trackingNumber)
                .retrieve()
                .bodyToMono(OrderDTO.class);
    }
    
    // Payment operations
    public Mono<PaymentResponse> processPayment(PaymentRequest request) {
        log.info("BFF: Processing payment for order {}", request.getOrderId());
        return backendWebClient.post()
                .uri("/api/orders/payment")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(PaymentResponse.class);
    }
}
