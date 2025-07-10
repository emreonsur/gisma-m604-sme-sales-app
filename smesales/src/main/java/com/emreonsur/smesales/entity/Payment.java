package com.emreonsur.smesales.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Data
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "payment_date", nullable = false)
    private LocalDateTime paymentDate;

    @Column(name = "amount", nullable = false)
    private Double amount;

    @Column(name = "method", nullable = false)
    private String method;

    @Column(name = "reference_code")
    private String referenceCode;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;
}