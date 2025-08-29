package dev.emosher.springuber.config;

import dev.emosher.springuber.model.UberPickup;
import dev.emosher.springuber.repository.UberPickupRepository;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ResourceLoader;
import org.springframework.core.io.Resource;

import java.io.InputStreamReader;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Component
public class DataLoader implements CommandLineRunner {
    
    @Autowired
    private ResourceLoader resourceLoader;
    
    @Autowired
    private UberPickupRepository repository;
    
    @Override
    public void run(String... args) throws Exception {
        Resource resource = resourceLoader.getResource("classpath:data.csv");
        
        try (CSVReader reader = new CSVReader(new InputStreamReader(resource.getInputStream()))) {
            String[] line;
            // Skip header row
            reader.readNext();
            
            while ((line = reader.readNext()) != null) {
                while ((line = reader.readNext()) != null) {
                    UberPickup pickup = new UberPickup();
                    pickup.setHour(Integer.parseInt(line[0]));
                    pickup.setCount(Integer.parseInt(line[1]));
                    repository.save(pickup);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to load CSV data", e);
        }
    }
    
}