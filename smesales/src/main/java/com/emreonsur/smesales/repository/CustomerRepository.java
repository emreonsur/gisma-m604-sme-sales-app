package com.emreonsur.smesales.repository;

import com.emreonsur.smesales.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {

    // Find by display name
    Optional<Customer> findByDisplayName(String displayName);

    // List all active customers
    List<Customer> findByIsActiveTrue();

    // List customers by billing entity ID
    List<Customer> findByBillingEntity_Id(Integer billingEntityId);

    // Check if customer exists, by display name
    boolean existsByDisplayName(String displayName);
}