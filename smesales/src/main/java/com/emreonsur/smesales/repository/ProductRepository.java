package com.emreonsur.smesales.repository;

import com.emreonsur.smesales.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Integer> {
    // Find by formal name
    Optional<Product> findByFormalName(String formalName);

    // Find by display name
    Optional<Product> findByDisplayName(String displayName);

    // List all active products
    List<Product> findByIsActiveTrue();

    // Check if product exists, by display name
    boolean existsByDisplayName(String displayName);
}