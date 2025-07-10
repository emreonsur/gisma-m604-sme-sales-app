package com.emreonsur.smesales.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "products")
@Data
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private Integer id;

    @Column(name = "formal_name", nullable = false, unique = true)
    private String formalName;

    @Column(name = "display_name", nullable = false, unique = true)
    private String displayName;

    @Column(name = "unit_price", nullable = false)
    private Double unitPrice;

    @Column(name = "stock_quantity", nullable = false)
    private Integer stockQuantity;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;
}