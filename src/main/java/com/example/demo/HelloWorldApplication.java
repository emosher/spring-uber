package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;

@SpringBootApplication
public class HelloWorldApplication {

    public static void main(String[] args) {
        SpringApplication.run(HelloWorldApplication.class, args);
    }
}

@Controller  // Change from @RestController to @Controller
class HelloWorldController {
    private final MessageRepository repository;

    HelloWorldController(MessageRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/")
    public String getMessages(Model model) {
        List<Message> messages = repository.findAll();
        model.addAttribute("messages", messages);
        return "index";
    }
}