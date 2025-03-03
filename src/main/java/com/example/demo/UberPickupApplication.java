package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;

@SpringBootApplication
public class UberPickupApplication {

    public static void main(String[] args) {
        SpringApplication.run(UberPickupApplication.class, args);
    }
}

@Controller
class UberPickupController {
    private final UberPickupRepository repository;

    UberPickupController(UberPickupRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/")
    public String getPickups(Model model) {
        List<UberPickup> pickups = repository.findAll();
        model.addAttribute("messages", pickups); // Keep "messages" for now to avoid template changes
        return "index";
    }
}