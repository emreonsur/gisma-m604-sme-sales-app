package com.emreonsur.smesales.service;

import com.emreonsur.smesales.entity.Product;
import com.emreonsur.smesales.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductServiceImpl implements ProductService {
    private final ProductRepository productRepository;

    @Autowired
    public ProductServiceImpl(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    @Override
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @Override
    public Optional<Product> getProductById(Integer id) {
        return productRepository.findById(id);
    }

    @Override
    public Product createProduct(Product product) {
        return productRepository.save(product);
    }

    @Override
    public Product updateProduct(Integer id, Product updatedProduct) {
        return productRepository.findById(id).map(existingProduct -> {
            existingProduct.setFormalName(updatedProduct.getFormalName());
            existingProduct.setDisplayName(updatedProduct.getDisplayName());
            existingProduct.setUnitPrice(updatedProduct.getUnitPrice());
            existingProduct.setStockQuantity(updatedProduct.getStockQuantity());
            existingProduct.setIsActive(updatedProduct.getIsActive());
            return productRepository.save(existingProduct);
        }).orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
    }

    @Override
    public void deleteProduct(Integer id) {
        productRepository.deleteById(id);
    }
}