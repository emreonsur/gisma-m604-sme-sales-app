package com.emreonsur.smesales.controller;

import com.emreonsur.smesales.entity.Customer;
import com.emreonsur.smesales.repository.CustomerRepository;
import com.emreonsur.smesales.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {
    private final CustomerService customerService;
    private final CustomerRepository customerRepository;

    @Autowired
    public CustomerController(CustomerService customerService, CustomerRepository customerRepository) {
        this.customerService = customerService;
        this.customerRepository = customerRepository;
    }

    @GetMapping
    public List<Customer> getAllCustomers() {
        return customerService.getAllCustomers();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Customer> getCustomerById(@PathVariable Integer id) {
        return customerService.getCustomerById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/by-display-name/{displayName}")
    public ResponseEntity<Customer> getCustomerByDisplayName(@PathVariable String displayName) {
        return customerRepository.findByDisplayName(displayName)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/active")
    public List<Customer> getAllActiveCustomers() {
        return customerRepository.findByIsActiveTrue();
    }

    @GetMapping("/by-billing-entity/{billingEntityId}")
    public List<Customer> getCustomersByBillingEntityId(@PathVariable Integer billingEntityId) {
        return customerRepository.findByBillingEntity_Id(billingEntityId);
    }

    @GetMapping("/exists/{displayName}")
    public ResponseEntity<Boolean> checkCustomerExistsByDisplayName(@PathVariable String displayName) {
        boolean exists = customerRepository.existsByDisplayName(displayName);
        return ResponseEntity.ok(exists);
    }

    @PostMapping
    public Customer createCustomer(@RequestBody Customer customer) {
        return customerService.createCustomer(customer);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Customer> updateCustomer(@PathVariable Integer id,
                                                   @RequestBody Customer customer) {
        try {
            Customer updated = customerService.updateCustomer(id, customer);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCustomer(@PathVariable Integer id) {
        customerService.deleteCustomer(id);
        return ResponseEntity.noContent().build();
    }
}