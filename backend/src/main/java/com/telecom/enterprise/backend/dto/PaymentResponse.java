package com.telecom.enterprise.backend.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentResponse {
    private boolean success;
    private String transactionId;
    private String message;
    private String status;
}
