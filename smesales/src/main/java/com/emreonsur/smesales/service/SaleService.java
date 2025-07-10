package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Sale;

import java.util.List;
import java.util.Optional;

public interface SaleService {
    List<Sale> getAllSales();

    Optional<Sale> getSaleById(Integer id);

    Sale createSale(Sale sale);

    Sale updateSale(Integer id, Sale sale);

    void deleteSale(Integer id);
}