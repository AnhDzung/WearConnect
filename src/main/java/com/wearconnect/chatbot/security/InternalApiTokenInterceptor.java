package com.wearconnect.chatbot.security;

import com.wearconnect.chatbot.config.InternalApiProperties;
import com.wearconnect.chatbot.exception.InvalidInternalTokenException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class InternalApiTokenInterceptor implements HandlerInterceptor {

    private static final String INTERNAL_TOKEN_HEADER = "X-Internal-Token";

    private final InternalApiProperties internalApiProperties;

    public InternalApiTokenInterceptor(InternalApiProperties internalApiProperties) {
        this.internalApiProperties = internalApiProperties;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String token = request.getHeader(INTERNAL_TOKEN_HEADER);
        if (token == null || !token.equals(internalApiProperties.getToken())) {
            throw new InvalidInternalTokenException();
        }
        return true;
    }
}
