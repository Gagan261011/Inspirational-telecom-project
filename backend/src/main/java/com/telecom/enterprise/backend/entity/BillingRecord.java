package com.telecom.enterprise.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "billing_records")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillingRecord {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(unique = true, nullable = false)
    private String invoiceNumber;
    
    @Column(nullable = false)
    private BigDecimal amount;
    
    private BigDecimal tax;
    
    @Column(nullable = false)
    private BigDecimal totalAmount;
    
    @Enumerated(EnumType.STRING)
    private BillingStatus status;
    
    private LocalDate billingDate;
    
    private LocalDate dueDate;
    
    private LocalDate paidDate;
    
    private String description;
    
    @Enumerated(EnumType.STRING)
    private BillingType billingType;
    
    private String paymentMethod;
    
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) {
            status = BillingStatus.PENDING;
        }
        if (invoiceNumber == null) {
            invoiceNumber = "INV-" + System.currentTimeMillis();
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public enum BillingStatus {
        PENDING, PAID, OVERDUE, CANCELLED
    }
    
    public enum BillingType {
        SUBSCRIPTION, ONE_TIME, USAGE_BASED, RECURRING
    }
}
