# OCR Playground

A Spring Boot demo for reviewing changes to an order quote API with Open Code Review.

Run the application with Java 21 and Maven.

```sh
mvn spring-boot:run
```

`GET /api/quotes` accepts a nonnegative `subtotalCents` and returns the subtotal, discount, and total in cents.

Orders with a subtotal of at least 10,000 cents receive a 10% discount. The discount is rounded down to a whole cent.

```sh
curl 'http://localhost:8080/api/quotes?subtotalCents=10000'
```
