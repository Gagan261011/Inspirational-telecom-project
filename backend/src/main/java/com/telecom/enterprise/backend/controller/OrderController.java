package com.telecom.enterprise.backend.controller;

import com.telecom.enterprise.backend.dto.*;
import com.telecom.enterprise.backend.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
@Tag(name = "Order Management", description = "Order processing and tracking")
@CrossOrigin(origins = "*")
public class OrderController {
    
    private final OrderService orderService;
    
    @PostMapping
    @Operation(summary = "Create a new order")
    public ResponseEntity<OrderDTO> createOrder(@RequestBody CreateOrderRequest request) {
        return ResponseEntity.ok(orderService.createOrder(request));
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get order by ID")
    public ResponseEntity<OrderDTO> getOrder(@PathVariable Long id) {
        OrderDTO order = orderService.getOrderById(id);
        return order != null 
                ? ResponseEntity.ok(order) 
                : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/number/{orderNumber}")
    @Operation(summary = "Get order by order number")
    public ResponseEntity<OrderDTO> getOrderByNumber(@PathVariable String orderNumber) {
        OrderDTO order = orderService.getOrderByNumber(orderNumber);
        return order != null 
                ? ResponseEntity.ok(order) 
                : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/user/{userId}")
    @Operation(summary = "Get orders for a user")
    public ResponseEntity<List<OrderDTO>> getUserOrders(@PathVariable Long userId) {
        return ResponseEntity.ok(orderService.getUserOrders(userId));
    }
    
    @GetMapping("/track/{trackingNumber}")
    @Operation(summary = "Track order by tracking number")
    public ResponseEntity<OrderDTO> trackOrder(@PathVariable String trackingNumber) {
        OrderDTO order = orderService.trackOrder(trackingNumber);
        return order != null 
                ? ResponseEntity.ok(order) 
                : ResponseEntity.notFound().build();
    }
    
    @PutMapping("/{id}/status")
    @Operation(summary = "Update order status")
    public ResponseEntity<OrderDTO> updateStatus(@PathVariable Long id, @RequestParam String status) {
        OrderDTO order = orderService.updateOrderStatus(id, status);
        return order != null 
                ? ResponseEntity.ok(order) 
                : ResponseEntity.notFound().build();
    }
    
    @PostMapping("/payment")
    @Operation(summary = "Process payment for an order")
    public ResponseEntity<PaymentResponse> processPayment(@RequestBody PaymentRequest request) {
        PaymentResponse response = orderService.processPayment(request);
        return response.isSuccess() 
                ? ResponseEntity.ok(response) 
                : ResponseEntity.badRequest().body(response);
    }
}
