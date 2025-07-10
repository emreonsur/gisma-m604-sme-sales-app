package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Payment;

import java.util.List;
import java.util.Optional;

public interface PaymentService {
    List<Payment> getAllPayments();

    Optional<Payment> getPaymentById(Integer id);

    List<Payment> getPaymentsByCustomerId(Integer customerId);

    Payment createPayment(Payment payment);

    Payment updatePayment(Integer id, Payment payment);

    void deletePayment(Integer id);
}