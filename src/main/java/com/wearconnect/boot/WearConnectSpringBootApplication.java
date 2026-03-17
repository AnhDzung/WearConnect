package com.wearconnect.boot;

import java.io.File;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication(scanBasePackages = "com.wearconnect")
@EnableScheduling
public class WearConnectSpringBootApplication extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(WearConnectSpringBootApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(WearConnectSpringBootApplication.class);
    }

    /**
     * Points embedded Tomcat's document root to the web/ directory so that
     * JSP files (web/WEB-INF/jsp/**) and static assets are found at runtime
     * during `mvn spring-boot:run`. Has no effect when deployed as a WAR to
     * an external container.
     */
    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> webDocumentRootCustomizer() {
        return factory -> {
            File webDir = new File("web");
            if (webDir.isDirectory()) {
                factory.setDocumentRoot(webDir);
            }
        };
    }
}