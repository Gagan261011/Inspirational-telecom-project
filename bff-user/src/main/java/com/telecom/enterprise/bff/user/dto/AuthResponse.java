package com.telecom.enterprise.bff.user.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private boolean success;
    private String token;
    private UserDTO user;
    private String message;
}
