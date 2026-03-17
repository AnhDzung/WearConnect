package com.wearconnect.chatbot.config;

import com.wearconnect.chatbot.security.InternalApiTokenInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    private final InternalApiTokenInterceptor internalApiTokenInterceptor;

    public WebMvcConfig(InternalApiTokenInterceptor internalApiTokenInterceptor) {
        this.internalApiTokenInterceptor = internalApiTokenInterceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(internalApiTokenInterceptor)
                .addPathPatterns("/internal/**");
    }
}
