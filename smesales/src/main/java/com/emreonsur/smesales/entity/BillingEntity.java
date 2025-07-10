package com.emreonsur.smesales.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "billing_entities")
@Data
public class BillingEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "billing_entity_id")
    private Integer id;

    @Column(name = "trade_number_or_citizen_id", nullable = false, unique = true, length = 11)
    private String tradeNumberOrCitizenId;

    @Column(name = "entity_type")
    private String entityType;

    @Column(name = "trade_name", nullable = false)
    private String tradeName;

    @Column(name = "tax_office")
    private String taxOffice;

    @Column(name = "billing_address", nullable = false, columnDefinition = "TEXT")
    private String billingAddress;

    @Column(name = "current_balance", nullable = false)
    private Double currentBalance;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;
}