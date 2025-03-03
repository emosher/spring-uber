package dev.emosher.springuber.controller;

import dev.emosher.springuber.model.UberPickup;
import dev.emosher.springuber.repository.UberPickupRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import java.util.List;

@Controller
public class UberPickupController {
    private final UberPickupRepository repository;

    public UberPickupController(UberPickupRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/")
    public String getPickups(Model model) {
        List<UberPickup> pickups = repository.findAll();
        model.addAttribute("messages", pickups);
        return "index";
    }
}