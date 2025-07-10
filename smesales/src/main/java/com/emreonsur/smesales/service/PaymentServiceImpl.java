package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Payment;
import com.emreonsur.smesales.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class PaymentServiceImpl implements PaymentService {
    private final PaymentRepository paymentRepository;

    @Autowired
    public PaymentServiceImpl(PaymentRepository paymentRepository) {
        this.paymentRepository = paymentRepository;
    }

    @Override
    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }

    @Override
    public Optional<Payment> getPaymentById(Integer id) {
        return paymentRepository.findById(id);
    }

    @Override
    public List<Payment> getPaymentsByCustomerId(Integer customerId) {
        return paymentRepository.findByCustomer_Id(customerId);
    }

    @Override
    public Payment createPayment(Payment payment) {
        return paymentRepository.save(payment);
    }

    @Override
    public Payment updatePayment(Integer id, Payment updatedPayment) {
        return paymentRepository.findById(id).map(existingPayment -> {
            existingPayment.setCustomer(updatedPayment.getCustomer());
            existingPayment.setPaymentDate(updatedPayment.getPaymentDate());
            existingPayment.setAmount(updatedPayment.getAmount());
            existingPayment.setMethod(updatedPayment.getMethod());
            existingPayment.setReferenceCode(updatedPayment.getReferenceCode());
            existingPayment.setNotes(updatedPayment.getNotes());
            return paymentRepository.save(existingPayment);
        }).orElseThrow(() -> new RuntimeException("Payment not found with id: " + id));
    }

    @Override
    public void deletePayment(Integer id) {
        paymentRepository.deleteById(id);
    }
}