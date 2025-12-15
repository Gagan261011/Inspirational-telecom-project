package com.telecom.enterprise.backend.controller;

import com.telecom.enterprise.backend.dto.BillingDTO;
import com.telecom.enterprise.backend.entity.BillingRecord;
import com.telecom.enterprise.backend.service.BillingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/billing")
@RequiredArgsConstructor
@Tag(name = "Billing", description = "Billing and invoice management")
@CrossOrigin(origins = "*")
public class BillingController {
    
    private final BillingService billingService;
    
    @GetMapping("/user/{userId}")
    @Operation(summary = "Get billing history for user")
    public ResponseEntity<List<BillingDTO>> getUserBillingHistory(@PathVariable Long userId) {
        return ResponseEntity.ok(billingService.getUserBillingHistory(userId));
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get billing record by ID")
    public ResponseEntity<BillingDTO> getBillingRecord(@PathVariable Long id) {
        BillingDTO record = billingService.getBillingRecord(id);
        return record != null 
                ? ResponseEntity.ok(record) 
                : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/invoice/{invoiceNumber}")
    @Operation(summary = "Get billing by invoice number")
    public ResponseEntity<BillingDTO> getBillingByInvoice(@PathVariable String invoiceNumber) {
        BillingDTO record = billingService.getBillingByInvoice(invoiceNumber);
        return record != null 
                ? ResponseEntity.ok(record) 
                : ResponseEntity.notFound().build();
    }
    
    @PostMapping
    @Operation(summary = "Create billing record")
    public ResponseEntity<BillingDTO> createBillingRecord(
            @RequestParam Long userId,
            @RequestParam BigDecimal amount,
            @RequestParam String description,
            @RequestParam(defaultValue = "ONE_TIME") String billingType) {
        return ResponseEntity.ok(billingService.createBillingRecord(
                userId, amount, description, BillingRecord.BillingType.valueOf(billingType)));
    }
    
    @PostMapping("/{id}/pay")
    @Operation(summary = "Pay a bill")
    public ResponseEntity<BillingDTO> payBill(
            @PathVariable Long id,
            @RequestParam String paymentMethod) {
        BillingDTO record = billingService.payBill(id, paymentMethod);
        return record != null 
                ? ResponseEntity.ok(record) 
                : ResponseEntity.notFound().build();
    }
}
