package com.emreonsur.smesales.controller;

import com.emreonsur.smesales.entity.Product;
import com.emreonsur.smesales.repository.ProductRepository;
import com.emreonsur.smesales.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;
    private final ProductRepository productRepository;

    @Autowired
    public ProductController(ProductService productService, ProductRepository productRepository) {
        this.productService = productService;
        this.productRepository = productRepository;
    }

    @GetMapping
    public List<Product> getAllProducts() {
        return productService.getAllProducts();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Integer id) {
        return productService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/by-formal-name/{formalName}")
    public ResponseEntity<Product> getProductByFormalName(@PathVariable String formalName) {
        return productRepository.findByFormalName(formalName)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/by-display-name/{displayName}")
    public ResponseEntity<Product> getProductByDisplayName(@PathVariable String displayName) {
        return productRepository.findByDisplayName(displayName)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/active")
    public List<Product> getAllActiveProducts() {
        return productRepository.findByIsActiveTrue();
    }

    @GetMapping("/exists/{displayName}")
    public ResponseEntity<Boolean> checkProductExistsByDisplayName(@PathVariable String displayName) {
        boolean exists = productRepository.existsByDisplayName(displayName);
        return ResponseEntity.ok(exists);
    }

    @PostMapping
    public Product createProduct(@RequestBody Product product) {
        return productService.createProduct(product);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Integer id,
                                                 @RequestBody Product product) {
        try {
            Product updated = productService.updateProduct(id, product);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Integer id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }
}
