package com.wearconnect.boot.config;

import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;

@Configuration
public class LegacyDatabaseCompatibilityConfig {

    @Bean
    ApplicationRunner legacyDatabasePropertyBridge(Environment environment) {
        return args -> {
            bridge(environment, "spring.datasource.url", "wearconnect.db.url");
            bridge(environment, "spring.datasource.username", "wearconnect.db.username");
            bridge(environment, "spring.datasource.password", "wearconnect.db.password");
            bridge(environment, "wearconnect.db.server", "wearconnect.db.server");
            bridge(environment, "wearconnect.db.port", "wearconnect.db.port");
            bridge(environment, "wearconnect.db.name", "wearconnect.db.name");
        };
    }

    private void bridge(Environment environment, String sourceKey, String targetKey) {
        String value = environment.getProperty(sourceKey);
        if (value != null && !value.isBlank() && System.getProperty(targetKey) == null) {
            System.setProperty(targetKey, value);
        }
    }
}