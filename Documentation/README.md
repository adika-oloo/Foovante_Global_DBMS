Foovante Global - Centralized Database Management System

Project Overview
Foovante Global is building West Africa's leading climate-tech platform, focused on:
1.Carbon credit pre-verification
2.Farmer onboarding
3.Data-driven MRV (Measurement, Reporting, and Verification)

This MySQL database serves as the centralized backbone for all operational data — replacing fragmented spreadsheets and Google Workspace forms.  
It provides a single source of truth for managing farmers, projects, and carbon credits across multiple regions.

Business Objectives
-Single Source of Truth (Unify farmer, project, and carbon credit data in one platform).  
-Streamlined Operations (Reduce farmer onboarding time from 3 days to 4 hours).  
- Real-time Analytics (Enable live dashboards for stakeholders, registries, and carbon buyers).  
-Audit Compliance (Align with international carbon standards such as Verra and Gold Standard).

 Database Schema Documentation
Entity Relationship Diagram
The schema follows a modular design for scalability and easy integration with APIs or BI tools.
Core Table Structures
 1. User Management — `users`
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'farmer_agent', 'finance', 'tech', 'ops') NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

Purpose: Manages system users with role-based access control.
2. Farmer Management — farmers

CREATE TABLE farmers (
    farmer_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(100) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    land_size_hectares DECIMAL(10,2),
    land_details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

Purpose: Stores farmer profiles with geolocation and land details for project mapping.
3.Project Management — projects

CREATE TABLE projects (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    project_type ENUM('regenerative_agriculture', 'waste_management', 'biochar', 'renewable_energy'),
    project_stage ENUM('pre_verification', 'verification', 'credit_issuance'),
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) DEFAULT 'active',
    boundary_coordinates JSON,
    satellite_data_links JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

Purpose: Tracks carbon projects from pre-verification to credit issuance.
4. Carbon Credit Tracking — carbon_credits

CREATE TABLE carbon_credits (
    credit_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    credit_amount DECIMAL(12,2) NOT NULL,
    credit_status ENUM('generated', 'verified', 'issued', 'sold', 'retired') NOT NULL,
    generation_date DATE,
    verification_date DATE,
    issuance_date DATE,
    registry_id VARCHAR(255),
    current_owner_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (current_owner_id) REFERENCES partners(partner_id) ON DELETE SET NULL
);

Purpose: Manages the full lifecycle of carbon credits and ownership transitions.
