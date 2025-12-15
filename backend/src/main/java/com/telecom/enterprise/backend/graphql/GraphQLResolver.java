package com.telecom.enterprise.backend.graphql;

import com.telecom.enterprise.backend.dto.*;
import com.telecom.enterprise.backend.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.math.BigDecimal;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class GraphQLResolver {
    
    private final UserService userService;
    private final ProductService productService;
    private final OrderService orderService;
    private final CartService cartService;
    private final BillingService billingService;
    
    // User Queries
    @QueryMapping
    public UserDTO user(@Argument Long id) {
        return userService.getUserById(id);
    }
    
    @QueryMapping
    public UserDTO userByEmail(@Argument String email) {
        return userService.getUserByEmail(email);
    }
    
    // Product Queries
    @QueryMapping
    public List<ProductDTO> products() {
        return productService.getAllProducts();
    }
    
    @QueryMapping
    public ProductDTO product(@Argument Long id) {
        return productService.getProductById(id);
    }
    
    @QueryMapping
    public List<ProductDTO> productsByCategory(@Argument String category) {
        return productService.getProductsByCategory(category);
    }
    
    @QueryMapping
    public List<ProductDTO> featuredProducts() {
        return productService.getFeaturedProducts();
    }
    
    @QueryMapping
    public List<ProductDTO> searchProducts(@Argument String query) {
        return productService.searchProducts(query);
    }
    
    @QueryMapping
    public List<String> categories() {
        return productService.getAllCategories();
    }
    
    // Order Queries
    @QueryMapping
    public OrderDTO order(@Argument Long id) {
        return orderService.getOrderById(id);
    }
    
    @QueryMapping
    public OrderDTO orderByNumber(@Argument String orderNumber) {
        return orderService.getOrderByNumber(orderNumber);
    }
    
    @QueryMapping
    public List<OrderDTO> userOrders(@Argument Long userId) {
        return orderService.getUserOrders(userId);
    }
    
    // Cart Queries
    @QueryMapping
    public CartDTO cart(@Argument Long userId) {
        return cartService.getCart(userId);
    }
    
    // Billing Queries
    @QueryMapping
    public List<BillingDTO> billingHistory(@Argument Long userId) {
        return billingService.getUserBillingHistory(userId);
    }
    
    @QueryMapping
    public BillingDTO billingRecord(@Argument Long id) {
        return billingService.getBillingRecord(id);
    }
    
    // User Mutations
    @MutationMapping
    public AuthResponse register(@Argument("input") RegisterRequest input) {
        return userService.register(input);
    }
    
    @MutationMapping
    public AuthResponse login(@Argument String email, @Argument String password) {
        return userService.login(LoginRequest.builder().email(email).password(password).build());
    }
    
    @MutationMapping
    public UserDTO updateProfile(@Argument Long userId, @Argument("input") UserDTO input) {
        return userService.updateProfile(userId, input);
    }
    
    // Cart Mutations
    @MutationMapping
    public CartDTO addToCart(@Argument Long userId, @Argument Long productId, @Argument Integer quantity) {
        return cartService.addToCart(userId, productId, quantity);
    }
    
    @MutationMapping
    public CartDTO updateCartItem(@Argument Long userId, @Argument Long itemId, @Argument Integer quantity) {
        return cartService.updateCartItem(userId, itemId, quantity);
    }
    
    @MutationMapping
    public CartDTO removeFromCart(@Argument Long userId, @Argument Long itemId) {
        return cartService.removeFromCart(userId, itemId);
    }
    
    @MutationMapping
    public Boolean clearCart(@Argument Long userId) {
        cartService.clearCart(userId);
        return true;
    }
    
    // Order Mutations
    @MutationMapping
    public OrderDTO createOrder(@Argument("input") CreateOrderRequest input) {
        return orderService.createOrder(input);
    }
    
    @MutationMapping
    public PaymentResponse processPayment(@Argument("input") PaymentRequest input) {
        return orderService.processPayment(input);
    }
}
