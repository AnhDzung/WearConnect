package com.wearconnect.boot.scheduler;

import Service.AIPaymentVerificationService;
import Service.AIPaymentVerificationService.ProcessingSummary;
import java.time.LocalDateTime;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class AIPaymentVerificationScheduler {

    @Value("${app.payment.ai-verification.enabled:true}")
    private boolean enabled;

    @Value("${app.payment.ai-verification.timeout-hours:24}")
    private int timeoutHours;

    @Value("${app.payment.ai-verification.max-per-run:20}")
    private int maxPerRun;

    @Scheduled(cron = "${app.payment.ai-verification.cron:0 */10 * * * *}")
    public void autoVerifyTimedOutSubmittedPayments() {
        if (!enabled) {
            return;
        }

        try {
            ProcessingSummary summary = AIPaymentVerificationService.processTimedOutSubmissions(timeoutHours, maxPerRun);
            if (summary.getProcessed() <= 0) {
                return;
            }

            System.out.println("[AIPaymentVerificationScheduler] processed=" + summary.getProcessed()
                    + ", verified=" + summary.getVerified()
                    + ", rejected=" + summary.getRejected()
                    + ", skipped=" + summary.getSkipped()
                    + " at " + LocalDateTime.now());
        } catch (Exception e) {
            System.err.println("[AIPaymentVerificationScheduler] Error while auto verifying payments: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
