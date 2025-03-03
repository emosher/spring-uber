package com.example.demo;

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
    CommandLineRunner initDatabase(MessageRepository repository) {
        return args -> {
            try (CSVReader reader = new CSVReader(new FileReader(new ClassPathResource("data.csv").getFile()))) {
                // Skip header
                reader.readNext();
                
                String[] line;
                while ((line = reader.readNext()) != null) {
                    Message message = new Message();
                    message.setHour(Integer.parseInt(line[0]));
                    message.setCount(Integer.parseInt(line[1]));
                    repository.save(message);
                }
            } catch (IOException | CsvValidationException e) {
                throw new RuntimeException("Error loading CSV data", e);
            }
        };
    }
}