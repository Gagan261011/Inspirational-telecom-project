package com.telecom.enterprise.middleware.config;

import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;

@Configuration
@Profile("!dev")
@Slf4j
public class WebClientConfig {
    
    @Value("${backend.url}")
    private String backendUrl;
    
    @Value("${backend.ssl.key-store}")
    private String keyStorePath;
    
    @Value("${backend.ssl.key-store-password}")
    private String keyStorePassword;
    
    @Value("${backend.ssl.trust-store}")
    private String trustStorePath;
    
    @Value("${backend.ssl.trust-store-password}")
    private String trustStorePassword;
    
    @Bean
    public WebClient backendWebClient() throws Exception {
        SslContext sslContext = createSslContext();
        
        HttpClient httpClient = HttpClient.create()
                .secure(spec -> spec.sslContext(sslContext));
        
        return WebClient.builder()
                .baseUrl(backendUrl)
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .build();
    }
    
    private SslContext createSslContext() throws Exception {
        // Load keystore
        KeyStore keyStore = KeyStore.getInstance("PKCS12");
        String keyStoreResource = keyStorePath.replace("classpath:", "");
        try (InputStream keyStoreStream = new ClassPathResource(keyStoreResource).getInputStream()) {
            keyStore.load(keyStoreStream, keyStorePassword.toCharArray());
        }
        
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, keyStorePassword.toCharArray());
        
        // Load truststore
        KeyStore trustStore = KeyStore.getInstance("PKCS12");
        String trustStoreResource = trustStorePath.replace("classpath:", "");
        try (InputStream trustStoreStream = new ClassPathResource(trustStoreResource).getInputStream()) {
            trustStore.load(trustStoreStream, trustStorePassword.toCharArray());
        }
        
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(trustStore);
        
        return SslContextBuilder.forClient()
                .keyManager(keyManagerFactory)
                .trustManager(trustManagerFactory)
                .build();
    }
}
