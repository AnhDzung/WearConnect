package servlet;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class CacheControlFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialize filter
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Lấy URI để kiểm tra
        String uri = httpRequest.getRequestURI();
        
        // Áp dụng cache control cho các trang đã authenticate (không phải login/register)
        if (!uri.contains("login") && !uri.contains("register") && !uri.contains("home") && !uri.contains("search")) {
            // Check xem có session hay không
            HttpSession session = httpRequest.getSession(false);
            if (session != null && session.getAttribute("account") != null) {
                // User đã login - prevent cache
                httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private");
                httpResponse.setHeader("Pragma", "no-cache");
                httpResponse.setDateHeader("Expires", 0);
            }
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Cleanup
    }
}
