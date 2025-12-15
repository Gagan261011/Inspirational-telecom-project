package com.telecom.enterprise.backend.service;

import com.telecom.enterprise.backend.dto.*;
import com.telecom.enterprise.backend.entity.*;
import com.telecom.enterprise.backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {
    
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final CartRepository cartRepository;
    
    private static final BigDecimal TAX_RATE = new BigDecimal("0.08");
    private static final BigDecimal SHIPPING_COST = new BigDecimal("9.99");
    
    @Transactional
    public OrderDTO createOrder(CreateOrderRequest request) {
        log.info("Creating order for user: {}", request.getUserId());
        
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Order order = Order.builder()
                .user(user)
                .orderNumber("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .status(Order.OrderStatus.PENDING)
                .paymentStatus(Order.PaymentStatus.PENDING)
                .paymentMethod(request.getPaymentMethod())
                .notes(request.getNotes())
                .build();
        
        // Set shipping address
        if (request.getShippingAddress() != null) {
            AddressDTO addr = request.getShippingAddress();
            order.setShippingFirstName(addr.getFirstName());
            order.setShippingLastName(addr.getLastName());
            order.setShippingAddress(addr.getAddress());
            order.setShippingCity(addr.getCity());
            order.setShippingState(addr.getState());
            order.setShippingZipCode(addr.getZipCode());
            order.setShippingCountry(addr.getCountry());
            order.setShippingPhone(addr.getPhone());
        }
        
        // Set billing address
        if (request.getBillingAddress() != null) {
            AddressDTO addr = request.getBillingAddress();
            order.setBillingFirstName(addr.getFirstName());
            order.setBillingLastName(addr.getLastName());
            order.setBillingAddress(addr.getAddress());
            order.setBillingCity(addr.getCity());
            order.setBillingState(addr.getState());
            order.setBillingZipCode(addr.getZipCode());
            order.setBillingCountry(addr.getCountry());
        }
        
        // Calculate totals
        BigDecimal subtotal = BigDecimal.ZERO;
        
        for (OrderItemRequest itemRequest : request.getItems()) {
            Product product = productRepository.findById(itemRequest.getProductId())
                    .orElseThrow(() -> new RuntimeException("Product not found: " + itemRequest.getProductId()));
            
            BigDecimal itemTotal = product.getPrice().multiply(BigDecimal.valueOf(itemRequest.getQuantity()));
            subtotal = subtotal.add(itemTotal);
            
            OrderItem orderItem = OrderItem.builder()
                    .product(product)
                    .quantity(itemRequest.getQuantity())
                    .unitPrice(product.getPrice())
                    .totalPrice(itemTotal)
                    .productName(product.getName())
                    .productSku(product.getSku())
                    .build();
            
            order.addItem(orderItem);
        }
        
        BigDecimal tax = subtotal.multiply(TAX_RATE).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = subtotal.add(tax).add(SHIPPING_COST);
        
        order.setSubtotal(subtotal);
        order.setTax(tax);
        order.setShipping(SHIPPING_COST);
        order.setDiscount(BigDecimal.ZERO);
        order.setTotal(total);
        
        order = orderRepository.save(order);
        
        // Clear user's cart after order
        cartRepository.findByUserId(user.getId()).ifPresent(cart -> {
            cart.getItems().clear();
        });
        
        log.info("Order created: {}", order.getOrderNumber());
        return toDTO(order);
    }
    
    public OrderDTO getOrderById(Long orderId) {
        return orderRepository.findById(orderId)
                .map(this::toDTO)
                .orElse(null);
    }
    
    public OrderDTO getOrderByNumber(String orderNumber) {
        return orderRepository.findByOrderNumber(orderNumber)
                .map(this::toDTO)
                .orElse(null);
    }
    
    public List<OrderDTO> getUserOrders(Long userId) {
        return userRepository.findById(userId)
                .map(user -> orderRepository.findByUserOrderByCreatedAtDesc(user).stream()
                        .map(this::toDTO)
                        .collect(Collectors.toList()))
                .orElse(List.of());
    }
    
    public OrderDTO trackOrder(String trackingNumber) {
        return orderRepository.findByTrackingNumber(trackingNumber)
                .map(this::toDTO)
                .orElse(null);
    }
    
    @Transactional
    public OrderDTO updateOrderStatus(Long orderId, String status) {
        return orderRepository.findById(orderId)
                .map(order -> {
                    order.setStatus(Order.OrderStatus.valueOf(status));
                    if (status.equals("SHIPPED")) {
                        order.setShippedAt(LocalDateTime.now());
                        order.setTrackingNumber("TRK-" + UUID.randomUUID().toString().substring(0, 10).toUpperCase());
                        order.setCarrier("Enterprise Express");
                    } else if (status.equals("DELIVERED")) {
                        order.setDeliveredAt(LocalDateTime.now());
                    }
                    return toDTO(orderRepository.save(order));
                })
                .orElse(null);
    }
    
    @Transactional
    public PaymentResponse processPayment(PaymentRequest request) {
        log.info("Processing payment for order: {}", request.getOrderId());
        
        // Simulate payment processing
        try {
            Thread.sleep(500); // Simulate processing delay
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // In a real system, this would call a payment gateway
        Order order = orderRepository.findByOrderNumber(request.getOrderId()).orElse(null);
        
        if (order == null) {
            return PaymentResponse.builder()
                    .success(false)
                    .message("Order not found")
                    .status("FAILED")
                    .build();
        }
        
        // Simulate successful payment (90% success rate for demo)
        boolean isSuccessful = Math.random() < 0.9;
        
        if (isSuccessful) {
            String transactionId = "TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase();
            order.setTransactionId(transactionId);
            order.setPaymentStatus(Order.PaymentStatus.COMPLETED);
            order.setStatus(Order.OrderStatus.CONFIRMED);
            orderRepository.save(order);
            
            return PaymentResponse.builder()
                    .success(true)
                    .transactionId(transactionId)
                    .message("Payment processed successfully")
                    .status("COMPLETED")
                    .build();
        } else {
            order.setPaymentStatus(Order.PaymentStatus.FAILED);
            orderRepository.save(order);
            
            return PaymentResponse.builder()
                    .success(false)
                    .message("Payment declined. Please try again.")
                    .status("FAILED")
                    .build();
        }
    }
    
    public OrderDTO toDTO(Order order) {
        return OrderDTO.builder()
                .id(order.getId())
                .orderNumber(order.getOrderNumber())
                .userId(order.getUser().getId())
                .items(order.getItems().stream()
                        .map(item -> OrderItemDTO.builder()
                                .id(item.getId())
                                .productId(item.getProduct().getId())
                                .productName(item.getProductName())
                                .productSku(item.getProductSku())
                                .productImage(item.getProduct().getImageUrl())
                                .quantity(item.getQuantity())
                                .unitPrice(item.getUnitPrice())
                                .totalPrice(item.getTotalPrice())
                                .build())
                        .collect(Collectors.toList()))
                .subtotal(order.getSubtotal())
                .tax(order.getTax())
                .shipping(order.getShipping())
                .discount(order.getDiscount())
                .total(order.getTotal())
                .status(order.getStatus().name())
                .paymentStatus(order.getPaymentStatus().name())
                .paymentMethod(order.getPaymentMethod())
                .transactionId(order.getTransactionId())
                .shippingAddress(AddressDTO.builder()
                        .firstName(order.getShippingFirstName())
                        .lastName(order.getShippingLastName())
                        .address(order.getShippingAddress())
                        .city(order.getShippingCity())
                        .state(order.getShippingState())
                        .zipCode(order.getShippingZipCode())
                        .country(order.getShippingCountry())
                        .phone(order.getShippingPhone())
                        .build())
                .billingAddress(AddressDTO.builder()
                        .firstName(order.getBillingFirstName())
                        .lastName(order.getBillingLastName())
                        .address(order.getBillingAddress())
                        .city(order.getBillingCity())
                        .state(order.getBillingState())
                        .zipCode(order.getBillingZipCode())
                        .country(order.getBillingCountry())
                        .build())
                .notes(order.getNotes())
                .trackingNumber(order.getTrackingNumber())
                .carrier(order.getCarrier())
                .createdAt(order.getCreatedAt())
                .shippedAt(order.getShippedAt())
                .deliveredAt(order.getDeliveredAt())
                .build();
    }
}
