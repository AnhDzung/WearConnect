package com.wearconnect.chatbot.exception;

public class InvalidInternalTokenException extends RuntimeException {

    public InvalidInternalTokenException() {
        super("Invalid internal API token");
    }
}
