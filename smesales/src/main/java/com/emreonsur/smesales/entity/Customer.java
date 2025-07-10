package com.emreonsur.smesales.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "customers")
@Data
public class Customer {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_id")
    private Integer id;

    @Column(name = "display_name", nullable = false, unique = true)
    private String displayName;

    @ManyToOne
    @JoinColumn(name = "billing_entity_id", nullable = false)
    private BillingEntity billingEntity;

    @Column(name = "delivery_address", nullable = false, columnDefinition = "TEXT")
    private String deliveryAddress;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;
}