package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Product;

import java.util.List;
import java.util.Optional;

public interface ProductService {
    List<Product> getAllProducts();

    Optional<Product> getProductById(Integer id);

    Product createProduct(Product product);

    Product updateProduct(Integer id, Product product);

    void deleteProduct(Integer id);
}