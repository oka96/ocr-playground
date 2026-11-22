package com.example.ocrdemo.quote;

import org.springframework.stereotype.Service;

@Service
public class QuoteService {

    public Quote quote(int subtotalCents) {
        return new Quote(subtotalCents, 0, subtotalCents);
    }

    public record Quote(int subtotalCents, int discountCents, int totalCents) {
    }
}
