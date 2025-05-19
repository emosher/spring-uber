package dev.emosher.springuber.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.boot.context.event.ApplicationStartedEvent;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

@Configuration
public class DatabaseConfig {
    
    @Value("${spring.datasource.username}")
    private String username;
    
    private final DataSource dataSource;
    
    public DatabaseConfig(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    @EventListener(ApplicationStartedEvent.class)
    public void createDatabase() {
        try (Connection connection = dataSource.getConnection()) {
            Statement statement = connection.createStatement();
            // First check if database exists
            ResultSet resultSet = statement.executeQuery(
                "SELECT 1 FROM pg_database WHERE datname = 'springuber'"
            );
            
            if (!resultSet.next()) {
                // Database doesn't exist, so create it
                statement.execute("CREATE DATABASE springuber");
            }
        } catch (SQLException e) {
            throw new RuntimeException("Failed to create database", e);
        }
    }
}