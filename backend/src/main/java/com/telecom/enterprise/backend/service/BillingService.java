package com.telecom.enterprise.backend.service;

import com.telecom.enterprise.backend.dto.BillingDTO;
import com.telecom.enterprise.backend.entity.BillingRecord;
import com.telecom.enterprise.backend.entity.User;
import com.telecom.enterprise.backend.repository.BillingRepository;
import com.telecom.enterprise.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class BillingService {
    
    private final BillingRepository billingRepository;
    private final UserRepository userRepository;
    
    public List<BillingDTO> getUserBillingHistory(Long userId) {
        return userRepository.findById(userId)
                .map(user -> billingRepository.findByUserOrderByCreatedAtDesc(user).stream()
                        .map(this::toDTO)
                        .collect(Collectors.toList()))
                .orElse(List.of());
    }
    
    public BillingDTO getBillingRecord(Long recordId) {
        return billingRepository.findById(recordId)
                .map(this::toDTO)
                .orElse(null);
    }
    
    public BillingDTO getBillingByInvoice(String invoiceNumber) {
        return billingRepository.findByInvoiceNumber(invoiceNumber)
                .map(this::toDTO)
                .orElse(null);
    }
    
    @Transactional
    public BillingDTO createBillingRecord(Long userId, BigDecimal amount, String description, BillingRecord.BillingType type) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        BigDecimal tax = amount.multiply(new BigDecimal("0.08"));
        BigDecimal totalAmount = amount.add(tax);
        
        BillingRecord record = BillingRecord.builder()
                .user(user)
                .invoiceNumber("INV-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .amount(amount)
                .tax(tax)
                .totalAmount(totalAmount)
                .status(BillingRecord.BillingStatus.PENDING)
                .billingDate(LocalDate.now())
                .dueDate(LocalDate.now().plusDays(30))
                .description(description)
                .billingType(type)
                .build();
        
        record = billingRepository.save(record);
        return toDTO(record);
    }
    
    @Transactional
    public BillingDTO payBill(Long recordId, String paymentMethod) {
        return billingRepository.findById(recordId)
                .map(record -> {
                    record.setStatus(BillingRecord.BillingStatus.PAID);
                    record.setPaidDate(LocalDate.now());
                    record.setPaymentMethod(paymentMethod);
                    return toDTO(billingRepository.save(record));
                })
                .orElse(null);
    }
    
    public BillingDTO toDTO(BillingRecord record) {
        return BillingDTO.builder()
                .id(record.getId())
                .userId(record.getUser().getId())
                .invoiceNumber(record.getInvoiceNumber())
                .amount(record.getAmount())
                .tax(record.getTax())
                .totalAmount(record.getTotalAmount())
                .status(record.getStatus().name())
                .billingDate(record.getBillingDate())
                .dueDate(record.getDueDate())
                .paidDate(record.getPaidDate())
                .description(record.getDescription())
                .billingType(record.getBillingType() != null ? record.getBillingType().name() : null)
                .paymentMethod(record.getPaymentMethod())
                .createdAt(record.getCreatedAt())
                .build();
    }
}
