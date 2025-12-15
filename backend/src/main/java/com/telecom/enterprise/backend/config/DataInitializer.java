package com.telecom.enterprise.backend.config;

import com.telecom.enterprise.backend.entity.*;
import com.telecom.enterprise.backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {
    
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final BillingRepository billingRepository;
    private final PasswordEncoder passwordEncoder;
    
    @Override
    public void run(String... args) {
        log.info("Initializing demo data...");
        
        // Create demo users
        User demoUser = userRepository.save(User.builder()
                .email("demo@telecom.com")
                .password(passwordEncoder.encode("demo123"))
                .firstName("John")
                .lastName("Smith")
                .phone("+1 (555) 123-4567")
                .address("123 Enterprise Blvd")
                .city("San Francisco")
                .state("CA")
                .zipCode("94102")
                .country("USA")
                .role(User.UserRole.CUSTOMER)
                .build());
        
        userRepository.save(User.builder()
                .email("admin@telecom.com")
                .password(passwordEncoder.encode("admin123"))
                .firstName("Admin")
                .lastName("User")
                .role(User.UserRole.ADMIN)
                .build());
        
        // Create products - Smartphones
        productRepository.save(Product.builder()
                .name("Galaxy Pro Max 5G")
                .description("Experience the ultimate in smartphone technology with our flagship Galaxy Pro Max 5G. Featuring a stunning 6.8-inch Dynamic AMOLED display, revolutionary 200MP camera system, and lightning-fast 5G connectivity. The powerful Snapdragon processor ensures seamless multitasking while the 5000mAh battery keeps you going all day.")
                .price(new BigDecimal("1299.99"))
                .originalPrice(new BigDecimal("1499.99"))
                .category("Smartphones")
                .subcategory("Flagship")
                .imageUrl("https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800")
                .additionalImages(Arrays.asList(
                    "https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800",
                    "https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=800"
                ))
                .features(Arrays.asList(
                    "6.8\" Dynamic AMOLED 2X Display",
                    "200MP Main Camera + 12MP Ultra Wide",
                    "Snapdragon 8 Gen 3 Processor",
                    "5000mAh Battery with 45W Fast Charging",
                    "5G Ultra Wideband Connectivity"
                ))
                .brand("TechCom")
                .stock(50)
                .sku("PHONE-GPM-001")
                .rating(4.8)
                .reviewCount(2547)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("iPhone 15 Pro Max")
                .description("The most powerful iPhone ever. Featuring the A17 Pro chip, a 48MP main camera with 5x optical zoom, and an aerospace-grade titanium design. Experience the future of mobile technology.")
                .price(new BigDecimal("1199.99"))
                .category("Smartphones")
                .subcategory("Flagship")
                .imageUrl("https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=800")
                .features(Arrays.asList(
                    "6.7\" Super Retina XDR Display",
                    "A17 Pro Chip",
                    "48MP Main Camera System",
                    "Titanium Design",
                    "USB-C with USB 3 Support"
                ))
                .brand("Apple")
                .stock(35)
                .sku("PHONE-IP15-001")
                .rating(4.9)
                .reviewCount(4823)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("Pixel 8 Pro")
                .description("Google's most advanced phone yet. With the Tensor G3 chip, Magic Eraser, and 7 years of OS updates, the Pixel 8 Pro delivers an AI-powered experience like no other.")
                .price(new BigDecimal("999.99"))
                .category("Smartphones")
                .subcategory("Flagship")
                .imageUrl("https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800")
                .features(Arrays.asList(
                    "6.7\" LTPO OLED Display",
                    "Google Tensor G3 Chip",
                    "50MP Main Camera with AI",
                    "7 Years of Updates",
                    "Magic Eraser & Best Take"
                ))
                .brand("Google")
                .stock(42)
                .sku("PHONE-PX8-001")
                .rating(4.7)
                .reviewCount(1892)
                .featured(true)
                .build());
        
        // Create products - Tablets
        productRepository.save(Product.builder()
                .name("Galaxy Tab Ultra")
                .description("Transform your productivity with the Galaxy Tab Ultra. The 14.6-inch Super AMOLED display and S Pen create the perfect canvas for creativity and work. Powered by the Snapdragon 8 Gen 2, it handles anything you throw at it.")
                .price(new BigDecimal("1099.99"))
                .originalPrice(new BigDecimal("1299.99"))
                .category("Tablets")
                .subcategory("Premium")
                .imageUrl("https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800")
                .features(Arrays.asList(
                    "14.6\" Super AMOLED Display",
                    "S Pen Included",
                    "Snapdragon 8 Gen 2",
                    "12GB RAM / 256GB Storage",
                    "DeX Mode for Desktop Experience"
                ))
                .brand("TechCom")
                .stock(25)
                .sku("TAB-GTU-001")
                .rating(4.6)
                .reviewCount(892)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("iPad Pro 12.9\"")
                .description("The ultimate iPad experience. With the M2 chip, Liquid Retina XDR display, and ProMotion technology, the iPad Pro sets a new standard for what a tablet can do.")
                .price(new BigDecimal("1099.99"))
                .category("Tablets")
                .subcategory("Premium")
                .imageUrl("https://images.unsplash.com/photo-1561154464-82e9adf32764?w=800")
                .features(Arrays.asList(
                    "12.9\" Liquid Retina XDR Display",
                    "Apple M2 Chip",
                    "ProMotion Technology",
                    "Face ID",
                    "Thunderbolt / USB 4"
                ))
                .brand("Apple")
                .stock(30)
                .sku("TAB-IPP-001")
                .rating(4.8)
                .reviewCount(3241)
                .featured(false)
                .build());
        
        // Create products - Internet & Network
        productRepository.save(Product.builder()
                .name("5G Home Internet Gateway")
                .description("Bring blazing-fast 5G speeds to your home. Our 5G Home Internet Gateway delivers up to 1Gbps download speeds without the need for cables or installation appointments. Simply plug in and connect.")
                .price(new BigDecimal("299.99"))
                .category("Internet")
                .subcategory("5G Home")
                .imageUrl("https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800")
                .features(Arrays.asList(
                    "Up to 1Gbps Download Speeds",
                    "Supports 128+ Devices",
                    "Wi-Fi 6E Technology",
                    "No Annual Contract Required",
                    "Self-Setup in Minutes"
                ))
                .brand("TelecomNet")
                .stock(100)
                .sku("NET-5GH-001")
                .rating(4.5)
                .reviewCount(1567)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("Mesh WiFi Pro System (3-Pack)")
                .description("Eliminate dead zones with our Mesh WiFi Pro System. Cover up to 7,500 sq ft with seamless WiFi 6E coverage. Each node works together to deliver fast, reliable internet throughout your entire home.")
                .price(new BigDecimal("449.99"))
                .originalPrice(new BigDecimal("549.99"))
                .category("Internet")
                .subcategory("WiFi Systems")
                .imageUrl("https://images.unsplash.com/photo-1606904825846-647eb07f5be2?w=800")
                .features(Arrays.asList(
                    "WiFi 6E Tri-Band Technology",
                    "7,500 sq ft Coverage",
                    "Supports 200+ Devices",
                    "Automatic Updates",
                    "Parental Controls Built-in"
                ))
                .brand("TelecomNet")
                .stock(75)
                .sku("NET-MWP-001")
                .rating(4.7)
                .reviewCount(2134)
                .featured(false)
                .build());
        
        // Create products - Plans & Services
        productRepository.save(Product.builder()
                .name("Unlimited Premium Plan")
                .description("Our most premium mobile plan. Enjoy truly unlimited 5G data, 100GB premium hotspot data, and HD streaming on America's fastest 5G network. Includes international texting to 200+ countries.")
                .price(new BigDecimal("89.99"))
                .category("Plans")
                .subcategory("Mobile")
                .imageUrl("https://images.unsplash.com/photo-1556656793-08538906a9f8?w=800")
                .features(Arrays.asList(
                    "Truly Unlimited 5G Data",
                    "100GB Premium Hotspot",
                    "HD/4K Video Streaming",
                    "International Texting",
                    "Priority Network Access"
                ))
                .brand("TelecomNet")
                .stock(9999)
                .sku("PLAN-UNL-001")
                .rating(4.4)
                .reviewCount(8923)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("Business Fiber 1Gbps")
                .description("Enterprise-grade fiber internet for your business. Symmetrical 1Gbps upload and download speeds with 99.99% uptime guarantee and 24/7 dedicated support.")
                .price(new BigDecimal("199.99"))
                .category("Plans")
                .subcategory("Business")
                .imageUrl("https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800")
                .features(Arrays.asList(
                    "1Gbps Symmetrical Speeds",
                    "99.99% Uptime SLA",
                    "24/7 Priority Support",
                    "Static IP Included",
                    "Business-Grade Security"
                ))
                .brand("TelecomNet")
                .stock(9999)
                .sku("PLAN-BIZ-001")
                .rating(4.6)
                .reviewCount(1234)
                .featured(false)
                .build());
        
        // Create products - Accessories
        productRepository.save(Product.builder()
                .name("Pro Wireless Earbuds")
                .description("Premium true wireless earbuds with active noise cancellation. Crystal-clear audio, 30-hour battery life, and seamless connectivity make these the perfect companion for your smartphone.")
                .price(new BigDecimal("249.99"))
                .originalPrice(new BigDecimal("299.99"))
                .category("Accessories")
                .subcategory("Audio")
                .imageUrl("https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800")
                .features(Arrays.asList(
                    "Active Noise Cancellation",
                    "30-Hour Total Battery",
                    "IPX5 Water Resistant",
                    "Spatial Audio",
                    "Wireless Charging Case"
                ))
                .brand("AudioTech")
                .stock(150)
                .sku("ACC-PWE-001")
                .rating(4.6)
                .reviewCount(3456)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("MagSafe Wireless Charger Stand")
                .description("Charge your phone and watch simultaneously with our premium MagSafe-compatible wireless charger. The elegant stand design keeps your devices visible and accessible while charging.")
                .price(new BigDecimal("79.99"))
                .category("Accessories")
                .subcategory("Chargers")
                .imageUrl("https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=800")
                .features(Arrays.asList(
                    "15W Fast Wireless Charging",
                    "MagSafe Compatible",
                    "Dual Device Charging",
                    "Premium Aluminum Design",
                    "LED Indicator"
                ))
                .brand("PowerTech")
                .stock(200)
                .sku("ACC-MWC-001")
                .rating(4.5)
                .reviewCount(892)
                .featured(false)
                .build());
        
        productRepository.save(Product.builder()
                .name("Premium Leather Phone Case")
                .description("Handcrafted from genuine Italian leather, this premium case offers sophisticated protection for your flagship phone. Develops a beautiful patina over time.")
                .price(new BigDecimal("59.99"))
                .category("Accessories")
                .subcategory("Cases")
                .imageUrl("https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=800")
                .features(Arrays.asList(
                    "Genuine Italian Leather",
                    "MagSafe Compatible",
                    "Microfiber Lining",
                    "Raised Camera Protection",
                    "Slim Profile Design"
                ))
                .brand("LuxCase")
                .stock(300)
                .sku("ACC-PLC-001")
                .rating(4.8)
                .reviewCount(567)
                .featured(false)
                .build());
        
        // Create products - Smart Home
        productRepository.save(Product.builder()
                .name("Smart Home Hub Pro")
                .description("The brain of your smart home. Control lights, thermostats, cameras, and more from one central hub. Works with Alexa, Google Assistant, and HomeKit.")
                .price(new BigDecimal("149.99"))
                .category("Smart Home")
                .subcategory("Hubs")
                .imageUrl("https://images.unsplash.com/photo-1558089687-f282ffcbc126?w=800")
                .features(Arrays.asList(
                    "Controls 100+ Smart Devices",
                    "Voice Assistant Compatible",
                    "Matter & Thread Support",
                    "Local Processing",
                    "Energy Monitoring"
                ))
                .brand("HomeTech")
                .stock(80)
                .sku("SH-HUB-001")
                .rating(4.4)
                .reviewCount(1234)
                .featured(true)
                .build());
        
        productRepository.save(Product.builder()
                .name("Smart Doorbell Camera Pro")
                .description("See who's at your door from anywhere. 2K HDR video, color night vision, and two-way talk keep you connected to your home. Includes 30-day cloud storage.")
                .price(new BigDecimal("199.99"))
                .originalPrice(new BigDecimal("249.99"))
                .category("Smart Home")
                .subcategory("Security")
                .imageUrl("https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800")
                .features(Arrays.asList(
                    "2K HDR Video",
                    "Color Night Vision",
                    "Two-Way Talk",
                    "Motion Detection Zones",
                    "30-Day Cloud Storage"
                ))
                .brand("SecureTech")
                .stock(60)
                .sku("SH-DBC-001")
                .rating(4.5)
                .reviewCount(2345)
                .featured(false)
                .build());
        
        // Create billing records for demo user
        billingRepository.save(BillingRecord.builder()
                .user(demoUser)
                .invoiceNumber("INV-2024-001")
                .amount(new BigDecimal("89.99"))
                .tax(new BigDecimal("7.20"))
                .totalAmount(new BigDecimal("97.19"))
                .status(BillingRecord.BillingStatus.PAID)
                .billingDate(LocalDate.now().minusMonths(2))
                .dueDate(LocalDate.now().minusMonths(2).plusDays(30))
                .paidDate(LocalDate.now().minusMonths(2).plusDays(15))
                .description("Unlimited Premium Plan - Monthly")
                .billingType(BillingRecord.BillingType.RECURRING)
                .paymentMethod("Credit Card ****4242")
                .build());
        
        billingRepository.save(BillingRecord.builder()
                .user(demoUser)
                .invoiceNumber("INV-2024-002")
                .amount(new BigDecimal("89.99"))
                .tax(new BigDecimal("7.20"))
                .totalAmount(new BigDecimal("97.19"))
                .status(BillingRecord.BillingStatus.PAID)
                .billingDate(LocalDate.now().minusMonths(1))
                .dueDate(LocalDate.now().minusMonths(1).plusDays(30))
                .paidDate(LocalDate.now().minusMonths(1).plusDays(10))
                .description("Unlimited Premium Plan - Monthly")
                .billingType(BillingRecord.BillingType.RECURRING)
                .paymentMethod("Credit Card ****4242")
                .build());
        
        billingRepository.save(BillingRecord.builder()
                .user(demoUser)
                .invoiceNumber("INV-2024-003")
                .amount(new BigDecimal("89.99"))
                .tax(new BigDecimal("7.20"))
                .totalAmount(new BigDecimal("97.19"))
                .status(BillingRecord.BillingStatus.PENDING)
                .billingDate(LocalDate.now())
                .dueDate(LocalDate.now().plusDays(30))
                .description("Unlimited Premium Plan - Monthly")
                .billingType(BillingRecord.BillingType.RECURRING)
                .build());
        
        log.info("Demo data initialized successfully!");
        log.info("Demo user: demo@telecom.com / demo123");
        log.info("Admin user: admin@telecom.com / admin123");
    }
}
