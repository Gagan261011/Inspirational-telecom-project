package com.telecom.enterprise.backend.repository;

import com.telecom.enterprise.backend.entity.BillingRecord;
import com.telecom.enterprise.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BillingRepository extends JpaRepository<BillingRecord, Long> {
    List<BillingRecord> findByUser(User user);
    List<BillingRecord> findByUserOrderByCreatedAtDesc(User user);
    Optional<BillingRecord> findByInvoiceNumber(String invoiceNumber);
    List<BillingRecord> findByStatus(BillingRecord.BillingStatus status);
}
