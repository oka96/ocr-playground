# OCR Playground

A Spring Boot demo for reviewing changes to an order quote API with Open Code Review.

Run the application with Java 21 and Maven.

```sh
mvn spring-boot:run
```

`GET /api/quotes` accepts a nonnegative `subtotalCents` and returns the subtotal, discount, and total in cents.

```sh
curl 'http://localhost:8080/api/quotes?subtotalCents=10000'
```
