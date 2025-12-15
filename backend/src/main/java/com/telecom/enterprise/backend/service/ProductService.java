package com.telecom.enterprise.backend.service;

import com.telecom.enterprise.backend.dto.ProductDTO;
import com.telecom.enterprise.backend.entity.Product;
import com.telecom.enterprise.backend.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ProductService {
    
    private final ProductRepository productRepository;
    
    public List<ProductDTO> getAllProducts() {
        return productRepository.findByActiveTrue().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }
    
    public Page<ProductDTO> getProducts(Pageable pageable) {
        return productRepository.findByActiveTrue(pageable)
                .map(this::toDTO);
    }
    
    public ProductDTO getProductById(Long id) {
        return productRepository.findById(id)
                .filter(Product::isActive)
                .map(this::toDTO)
                .orElse(null);
    }
    
    public List<ProductDTO> getProductsByCategory(String category) {
        return productRepository.findByCategoryAndActiveTrue(category).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }
    
    public List<ProductDTO> getFeaturedProducts() {
        return productRepository.findByFeaturedTrue().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }
    
    public List<ProductDTO> searchProducts(String query) {
        return productRepository.searchProducts(query).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }
    
    public List<String> getAllCategories() {
        return productRepository.findAllCategories();
    }
    
    public ProductDTO toDTO(Product product) {
        return ProductDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .description(product.getDescription())
                .price(product.getPrice())
                .originalPrice(product.getOriginalPrice())
                .category(product.getCategory())
                .subcategory(product.getSubcategory())
                .imageUrl(product.getImageUrl())
                .additionalImages(product.getAdditionalImages())
                .features(product.getFeatures())
                .brand(product.getBrand())
                .stock(product.getStock())
                .sku(product.getSku())
                .rating(product.getRating())
                .reviewCount(product.getReviewCount())
                .featured(product.isFeatured())
                .active(product.isActive())
                .createdAt(product.getCreatedAt())
                .build();
    }
}
