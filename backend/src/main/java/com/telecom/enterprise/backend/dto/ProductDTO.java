package com.telecom.enterprise.backend.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductDTO {
    private Long id;
    private String name;
    private String description;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private String category;
    private String subcategory;
    private String imageUrl;
    private List<String> additionalImages;
    private List<String> features;
    private String brand;
    private Integer stock;
    private String sku;
    private Double rating;
    private Integer reviewCount;
    private boolean featured;
    private boolean active;
    private LocalDateTime createdAt;
}
