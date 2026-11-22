package com.example.ocrdemo.quote;

import org.springframework.stereotype.Service;

@Service
public class QuoteService {

    private static final int DISCOUNT_THRESHOLD_CENTS = 10_000;
    private static final int DISCOUNT_PERCENT = 10;

    public Quote quote(int subtotalCents) {
        int discountCents = subtotalCents > DISCOUNT_THRESHOLD_CENTS
                ? (int) ((long) subtotalCents * DISCOUNT_PERCENT / 100)
                : 0;
        return new Quote(subtotalCents, discountCents, subtotalCents - discountCents);
    }

    public record Quote(int subtotalCents, int discountCents, int totalCents) {
    }
}
