package dev.emosher.springuber.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import dev.emosher.springuber.model.UberPickup;

public interface UberPickupRepository extends JpaRepository<UberPickup, Integer> {
}