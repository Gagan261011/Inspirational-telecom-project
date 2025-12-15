package com.telecom.enterprise.bff.order.controller;

import com.telecom.enterprise.bff.order.dto.*;
import com.telecom.enterprise.bff.order.service.OrderBffService;
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
@Tag(name = "Order BFF", description = "Backend for Frontend - Order & Product Operations")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:3000"})
public class OrderBffController {
    
    private final OrderBffService orderBffService;
    
    // Product endpoints
    @GetMapping("/products")
    @Operation(summary = "Get all products")
    public Mono<ResponseEntity<List<ProductDTO>>> getAllProducts() {
        return orderBffService.getAllProducts()
                .map(ResponseEntity::ok);
    }
    
    @GetMapping("/products/{productId}")
    @Operation(summary = "Get product by ID")
    public Mono<ResponseEntity<ProductDTO>> getProduct(@PathVariable Long productId) {
        return orderBffService.getProduct(productId)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/products/category/{category}")
    @Operation(summary = "Get products by category")
    public Mono<ResponseEntity<List<ProductDTO>>> getProductsByCategory(@PathVariable String category) {
        return orderBffService.getProductsByCategory(category)
                .map(ResponseEntity::ok);
    }
    
    @GetMapping("/products/featured")
    @Operation(summary = "Get featured products")
    public Mono<ResponseEntity<List<ProductDTO>>> getFeaturedProducts() {
        return orderBffService.getFeaturedProducts()
                .map(ResponseEntity::ok);
    }
    
    @GetMapping("/products/search")
    @Operation(summary = "Search products")
    public Mono<ResponseEntity<List<ProductDTO>>> searchProducts(@RequestParam String query) {
        return orderBffService.searchProducts(query)
                .map(ResponseEntity::ok);
    }
    
    @GetMapping("/categories")
    @Operation(summary = "Get all categories")
    public Mono<ResponseEntity<List<String>>> getCategories() {
        return orderBffService.getCategories()
                .map(ResponseEntity::ok);
    }
    
    // Cart endpoints
    @GetMapping("/cart/{userId}")
    @Operation(summary = "Get user cart")
    public Mono<ResponseEntity<CartDTO>> getCart(@PathVariable Long userId) {
        return orderBffService.getCart(userId)
                .map(ResponseEntity::ok);
    }
    
    @PostMapping("/cart/{userId}/items")
    @Operation(summary = "Add item to cart")
    public Mono<ResponseEntity<CartDTO>> addToCart(
            @PathVariable Long userId,
            @RequestParam Long productId,
            @RequestParam(defaultValue = "1") Integer quantity) {
        return orderBffService.addToCart(userId, productId, quantity)
                .map(ResponseEntity::ok);
    }
    
    @PutMapping("/cart/{userId}/items/{itemId}")
    @Operation(summary = "Update cart item quantity")
    public Mono<ResponseEntity<CartDTO>> updateCartItem(
            @PathVariable Long userId,
            @PathVariable Long itemId,
            @RequestParam Integer quantity) {
        return orderBffService.updateCartItem(userId, itemId, quantity)
                .map(ResponseEntity::ok);
    }
    
    @DeleteMapping("/cart/{userId}/items/{itemId}")
    @Operation(summary = "Remove item from cart")
    public Mono<ResponseEntity<CartDTO>> removeFromCart(
            @PathVariable Long userId,
            @PathVariable Long itemId) {
        return orderBffService.removeFromCart(userId, itemId)
                .map(ResponseEntity::ok);
    }
    
    @DeleteMapping("/cart/{userId}")
    @Operation(summary = "Clear cart")
    public Mono<ResponseEntity<Void>> clearCart(@PathVariable Long userId) {
        return orderBffService.clearCart(userId)
                .then(Mono.just(ResponseEntity.noContent().build()));
    }
    
    // Order endpoints
    @PostMapping("/orders")
    @Operation(summary = "Create a new order")
    public Mono<ResponseEntity<OrderDTO>> createOrder(@RequestBody CreateOrderRequest request) {
        return orderBffService.createOrder(request)
                .map(ResponseEntity::ok);
    }
    
    @GetMapping("/orders/{orderId}")
    @Operation(summary = "Get order by ID")
    public Mono<ResponseEntity<OrderDTO>> getOrder(@PathVariable Long orderId) {
        return orderBffService.getOrder(orderId)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/orders/number/{orderNumber}")
    @Operation(summary = "Get order by order number")
    public Mono<ResponseEntity<OrderDTO>> getOrderByNumber(@PathVariable String orderNumber) {
        return orderBffService.getOrderByNumber(orderNumber)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/orders/user/{userId}")
    @Operation(summary = "Get user orders")
    public Mono<ResponseEntity<List<OrderDTO>>> getUserOrders(@PathVariable Long userId) {
        return orderBffService.getUserOrders(userId)
                .map(ResponseEntity::ok);
    }
    
    @GetMapping("/orders/track/{trackingNumber}")
    @Operation(summary = "Track order by tracking number")
    public Mono<ResponseEntity<OrderDTO>> trackOrder(@PathVariable String trackingNumber) {
        return orderBffService.trackOrder(trackingNumber)
                .map(ResponseEntity::ok)
                .defaultIfEmpty(ResponseEntity.notFound().build());
    }
    
    // Payment endpoint
    @PostMapping("/payments")
    @Operation(summary = "Process payment")
    public Mono<ResponseEntity<PaymentResponse>> processPayment(@RequestBody PaymentRequest request) {
        return orderBffService.processPayment(request)
                .map(response -> response.isSuccess() 
                        ? ResponseEntity.ok(response) 
                        : ResponseEntity.badRequest().body(response));
    }
}
