package com.telecom.enterprise.bff.order.dto;

import lombok.*;
import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderDTO {
    private Long id;
    private String orderNumber;
    private Long userId;
    private List<OrderItemDTO> items;
    private BigDecimal subtotal;
    private BigDecimal tax;
    private BigDecimal shipping;
    private BigDecimal discount;
    private BigDecimal total;
    private String status;
    private String paymentStatus;
    private String paymentMethod;
    private String transactionId;
    private AddressDTO shippingAddress;
    private AddressDTO billingAddress;
    private String notes;
    private String trackingNumber;
    private String carrier;
    private String createdAt;
    private String shippedAt;
    private String deliveredAt;
}
