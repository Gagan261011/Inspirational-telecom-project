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
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class CartService {
    
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    
    private static final BigDecimal TAX_RATE = new BigDecimal("0.08");
    
    public CartDTO getCart(Long userId) {
        return cartRepository.findByUserId(userId)
                .map(this::toDTO)
                .orElseGet(() -> createEmptyCart(userId));
    }
    
    @Transactional
    public CartDTO addToCart(Long userId, Long productId, Integer quantity) {
        log.info("Adding product {} to cart for user {}", productId, userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        
        Cart cart = cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Cart newCart = Cart.builder().user(user).build();
                    return cartRepository.save(newCart);
                });
        
        // Check if item already in cart
        Optional<CartItem> existingItem = cart.getItems().stream()
                .filter(item -> item.getProduct().getId().equals(productId))
                .findFirst();
        
        if (existingItem.isPresent()) {
            existingItem.get().setQuantity(existingItem.get().getQuantity() + quantity);
        } else {
            CartItem newItem = CartItem.builder()
                    .cart(cart)
                    .product(product)
                    .quantity(quantity)
                    .build();
            cart.addItem(newItem);
        }
        
        cart = cartRepository.save(cart);
        return toDTO(cart);
    }
    
    @Transactional
    public CartDTO updateCartItem(Long userId, Long itemId, Integer quantity) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        cart.getItems().stream()
                .filter(item -> item.getId().equals(itemId))
                .findFirst()
                .ifPresent(item -> {
                    if (quantity <= 0) {
                        cart.removeItem(item);
                        cartItemRepository.delete(item);
                    } else {
                        item.setQuantity(quantity);
                    }
                });
        
        cart = cartRepository.save(cart);
        return toDTO(cart);
    }
    
    @Transactional
    public CartDTO removeFromCart(Long userId, Long itemId) {
        Cart cart = cartRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Cart not found"));
        
        cart.getItems().stream()
                .filter(item -> item.getId().equals(itemId))
                .findFirst()
                .ifPresent(item -> {
                    cart.removeItem(item);
                    cartItemRepository.delete(item);
                });
        
        cart = cartRepository.save(cart);
        return toDTO(cart);
    }
    
    @Transactional
    public void clearCart(Long userId) {
        cartRepository.findByUserId(userId).ifPresent(cart -> {
            cart.getItems().clear();
            cartRepository.save(cart);
        });
    }
    
    private CartDTO createEmptyCart(Long userId) {
        return CartDTO.builder()
                .userId(userId)
                .items(List.of())
                .subtotal(BigDecimal.ZERO)
                .tax(BigDecimal.ZERO)
                .total(BigDecimal.ZERO)
                .itemCount(0)
                .build();
    }
    
    public CartDTO toDTO(Cart cart) {
        List<CartItemDTO> items = cart.getItems().stream()
                .map(item -> CartItemDTO.builder()
                        .id(item.getId())
                        .productId(item.getProduct().getId())
                        .productName(item.getProduct().getName())
                        .productImage(item.getProduct().getImageUrl())
                        .price(item.getProduct().getPrice())
                        .quantity(item.getQuantity())
                        .total(item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                        .build())
                .collect(Collectors.toList());
        
        BigDecimal subtotal = items.stream()
                .map(CartItemDTO::getTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal tax = subtotal.multiply(TAX_RATE).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = subtotal.add(tax);
        
        int itemCount = items.stream()
                .mapToInt(CartItemDTO::getQuantity)
                .sum();
        
        return CartDTO.builder()
                .id(cart.getId())
                .userId(cart.getUser().getId())
                .items(items)
                .subtotal(subtotal)
                .tax(tax)
                .total(total)
                .itemCount(itemCount)
                .build();
    }
}
