package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Sale;
import com.emreonsur.smesales.repository.SaleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class SaleServiceImpl implements SaleService {
    private final SaleRepository saleRepository;

    @Autowired
    public SaleServiceImpl(SaleRepository saleRepository) {
        this.saleRepository = saleRepository;
    }

    @Override
    public List<Sale> getAllSales() {
        return saleRepository.findAll();
    }

    @Override
    public Optional<Sale> getSaleById(Integer id) {
        return saleRepository.findById(id);
    }

    @Override
    public Sale createSale(Sale sale) {
        return saleRepository.save(sale);
    }

    @Override
    public Sale updateSale(Integer id, Sale updatedSale) {
        return saleRepository.findById(id).map(existingSale -> {
            existingSale.setCustomer(updatedSale.getCustomer());
            existingSale.setOrderDate(updatedSale.getOrderDate());
            existingSale.setInvoiceId(updatedSale.getInvoiceId());
            existingSale.setTotalAmount(updatedSale.getTotalAmount());
            return saleRepository.save(existingSale);
        }).orElseThrow(() -> new RuntimeException("Sale not found with id: " + id));
    }

    @Override
    public void deleteSale(Integer id) {
        saleRepository.deleteById(id);
    }
}