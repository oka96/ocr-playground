package com.example.ocrdemo.quote;

import com.example.ocrdemo.quote.QuoteService.Quote;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class QuoteController {

    private final QuoteService quoteService;

    public QuoteController(QuoteService quoteService) {
        this.quoteService = quoteService;
    }

    @GetMapping("/api/quotes")
    public Quote quote(@RequestParam int subtotalCents) {
        if (subtotalCents < 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Subtotal must be nonnegative");
        }
        return quoteService.quote(subtotalCents);
    }
}
