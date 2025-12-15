package com.telecom.enterprise.backend.service;

import com.telecom.enterprise.backend.dto.*;
import com.telecom.enterprise.backend.entity.User;
import com.telecom.enterprise.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Registering new user: {}", request.getEmail());
        
        if (userRepository.existsByEmail(request.getEmail())) {
            return AuthResponse.builder()
                    .success(false)
                    .message("Email already registered")
                    .build();
        }
        
        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .role(User.UserRole.CUSTOMER)
                .active(true)
                .build();
        
        user = userRepository.save(user);
        
        String token = generateToken(user);
        
        return AuthResponse.builder()
                .success(true)
                .token(token)
                .user(toDTO(user))
                .message("Registration successful")
                .build();
    }
    
    public AuthResponse login(LoginRequest request) {
        log.info("Login attempt for user: {}", request.getEmail());
        
        return userRepository.findByEmail(request.getEmail())
                .filter(user -> passwordEncoder.matches(request.getPassword(), user.getPassword()))
                .filter(User::isActive)
                .map(user -> AuthResponse.builder()
                        .success(true)
                        .token(generateToken(user))
                        .user(toDTO(user))
                        .message("Login successful")
                        .build())
                .orElse(AuthResponse.builder()
                        .success(false)
                        .message("Invalid credentials")
                        .build());
    }
    
    public UserDTO getUserById(Long id) {
        return userRepository.findById(id)
                .map(this::toDTO)
                .orElse(null);
    }
    
    public UserDTO getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(this::toDTO)
                .orElse(null);
    }
    
    @Transactional
    public UserDTO updateProfile(Long userId, UserDTO updates) {
        return userRepository.findById(userId)
                .map(user -> {
                    if (updates.getFirstName() != null) user.setFirstName(updates.getFirstName());
                    if (updates.getLastName() != null) user.setLastName(updates.getLastName());
                    if (updates.getPhone() != null) user.setPhone(updates.getPhone());
                    if (updates.getAddress() != null) user.setAddress(updates.getAddress());
                    if (updates.getCity() != null) user.setCity(updates.getCity());
                    if (updates.getState() != null) user.setState(updates.getState());
                    if (updates.getZipCode() != null) user.setZipCode(updates.getZipCode());
                    if (updates.getCountry() != null) user.setCountry(updates.getCountry());
                    return toDTO(userRepository.save(user));
                })
                .orElse(null);
    }
    
    @Transactional
    public boolean updatePassword(Long userId, String currentPassword, String newPassword) {
        return userRepository.findById(userId)
                .filter(user -> passwordEncoder.matches(currentPassword, user.getPassword()))
                .map(user -> {
                    user.setPassword(passwordEncoder.encode(newPassword));
                    userRepository.save(user);
                    return true;
                })
                .orElse(false);
    }
    
    private String generateToken(User user) {
        // Simple token generation - in production use JWT
        return UUID.randomUUID().toString() + "-" + user.getId();
    }
    
    public UserDTO toDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .email(user.getEmail())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .address(user.getAddress())
                .city(user.getCity())
                .state(user.getState())
                .zipCode(user.getZipCode())
                .country(user.getCountry())
                .role(user.getRole().name())
                .active(user.isActive())
                .build();
    }
}
