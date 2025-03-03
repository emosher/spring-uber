package dev.emosher.springuber.config;

import dev.emosher.springuber.model.UberPickup;
import dev.emosher.springuber.repository.UberPickupRepository;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvValidationException;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import java.io.FileReader;
import java.io.IOException;

@Configuration
public class DataLoader {
    @Bean
    CommandLineRunner initDatabase(UberPickupRepository repository) {
        return args -> {
            try (CSVReader reader = new CSVReader(new FileReader(new ClassPathResource("data.csv").getFile()))) {
                reader.readNext(); // Skip header
                String[] line;
                while ((line = reader.readNext()) != null) {
                    UberPickup pickup = new UberPickup();
                    pickup.setHour(Integer.parseInt(line[0]));
                    pickup.setCount(Integer.parseInt(line[1]));
                    repository.save(pickup);
                }
            }
        };
    }
}