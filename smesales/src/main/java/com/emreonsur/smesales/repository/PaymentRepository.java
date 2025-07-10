package com.emreonsur.smesales.repository;

import com.emreonsur.smesales.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Integer> {

    // Find payments by customer ID
    List<Payment> findByCustomer_Id(Integer customerId);

    // List payments by method
    List<Payment> findByMethod(String method);
}