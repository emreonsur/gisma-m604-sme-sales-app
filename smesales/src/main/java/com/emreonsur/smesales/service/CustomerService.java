package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Customer;

import java.util.List;
import java.util.Optional;

public interface CustomerService {
    List<Customer> getAllCustomers();

    Optional<Customer> getCustomerById(Integer id);

    Customer createCustomer(Customer customer);

    Customer updateCustomer(Integer id, Customer customer);

    void deleteCustomer(Integer id);
}