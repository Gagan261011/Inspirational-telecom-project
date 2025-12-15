package com.telecom.enterprise.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillingDTO {
    private Long id;
    private Long userId;
    private String invoiceNumber;
    private BigDecimal amount;
    private BigDecimal tax;
    private BigDecimal totalAmount;
    private String status;
    private LocalDate billingDate;
    private LocalDate dueDate;
    private LocalDate paidDate;
    private String description;
    private String billingType;
    private String paymentMethod;
    private LocalDateTime createdAt;
}
