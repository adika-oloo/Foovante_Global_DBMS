-- Core User Management
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR (255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM ( 'admin','farmer_agent','finance', 'tech', 'ops') NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR (100),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_user_role (role),
    INDEX idx_user_email (email)
);

-- Farmer Management
CREATE TABLE farmers (
farmer_id INT AUTO_INCREMENT PRIMARY KEY,
national_id VARCHAR(100) UNIQUE,
first_name VARCHAR(100) NOT NULL,
last_name VARCHAR(100) NOT NULL,
phone VARCHAR(50),
email VARCHAR(255),
latitude DECIMAL(10, 8),
longitude DECIMAL(11, 8),
land_size_hectares DECIMAL(10, 2),
land_details JSON, 
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
INDEX idx_farmer_location (latitude, longitude),
INDEX idx_farmer_name (first_name, last_name)
);

-- Project Management
CREATE TABLE projects (
project_id INT AUTO_INCREMENT PRIMARY KEY,
project_name VARCHAR(255) NOT NULL,
project_type ENUM(
		'regenerative_agriculture',
        'waste_management',
        'biochar',
        'renewable_energy'
) NOT NULL,
project_stage ENUM(
        'pre_verification',
        'verification',
        'credit_issuance'
) NOT NULL,
start_date DATE,
end_dte DATE,
status VARCHAR(50) DEFAULT 'active',
boundary_coordinates JSON, -- store polygon coordinates as JSON
satellite_data_links JSON,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
INDEX idx_project_type ( project_type),
INDEX idx_project_stage (project_stage),
INDEX idx_project_status(status)

);
-- Partners and Buyers(created first for foreign key references)
CREATE TABLE partners (
partner_id INT AUTO_INCREMENT PRIMARY KEY,
partner_name VARCHAR(255) NOT NULL,
partner_type ENUM('buyer','institution', 'partner'),
contact_email VARCHAR (255),
contact_phone VARCHAR(50),
address TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
INDEX idx_partner_type (partner_type)
);
-- Carbon credits
CREATE TABLE carbon_credits (
credit_id INT AUTO_INCREMENT PRIMARY KEY,
project_id INT NOT NULL,
credit_amount DECIMAL(12,2) NOT NULL,
credit_status ENUM( 'generated','verified','issued','sold', 'retired') NOT NULL,
generation_date DATE,
verification_date DATE,
issuance_date DATE,
registry_id VARCHAR(255), -- link to external registry
current_owner_id INT, 
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (project_id) REFERENCES projects(project_id)  ON DELETE CASCADE,
FOREIGN KEY (current_owner_id) REFERENCES partners(partner_id) ON DELETE SET NULL,
INDEX idx_credits_project (project_id), 
INDEX idx_credits_status (credit_status),
INDEX  idx_credits_dates(generation_date, verification_date, issuance_date)

);
-- Transaction History
CREATE TABLE credit_transactions (
transaction_id INT AUTO_INCREMENT PRIMARY KEY,
credit_id INT NOT NUll,
buyer_id INT NOT NUll,
transaction_amount DECIMAL(12 ,2) NOT NULL,
price_per_credit DECIMAL ( 10,2),
transaction_date DATE NOT NULL,
transaction_type ENUM( 'sale','transfer', 'retirement'),
status VARCHAR(50) DEFAULT 'completed',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (created_id) REFERENCES carbon_credits(credit_id) ON DELETE CASCADE,
FOREIGN KEY (buyer_id) REFERENCES partners(partner_id) ON DELETE CASCADE,
INDEX idx_transactions_date (transactions_date),
INDEX idx_transactions_type(transactions_type)
);
-- Finacial Tracking 
CREATE TABLE financial_records(
finance_id INT AUTO_INCREMENT PRIMARY KEY,
project_id INT NOT NULL,
amount DECIMAL (15 ,2) NOT NULL,
record_type ENUM( 'expenditure','revenue','forecast'),
category VARCHAR(100),
record_date DATE NOT NULL,
description TEXT,
currency VARCHAR(3) DEFAULT 'USD',
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (project_id) REFERENCES projects(project_id)ON DELETE CASCADE,
INDEX idx_finance_project (project_id),
INDEX idx_finance_type (record_type),
INDEX idx_finance_date (record_date)
);
-- Relationship Tables
CREATE TABLE farmer_assignments (
assigment_id INT AUTO_INCREMENT PRIMARY KEY,
farmer_id INT NOT NULL,
agent_id INT NOT NULL,
assigned_date DATE DEFAULT (CURRENT_DATE),
assignment_notes TEXT,
FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id) ON DELETE CASCADE,
FOREIGN KEY (agent_id) REFERENCES users(user_id) ON DELETE CASCADE,
INDEX idx_assignments_farmers (farmer_id),
INDEX idx_assignments_agents (agent_id)
);
CREATE TABLE project_farmers (
project_id INT NOT NULL,
farmer_id INT NOT NULL,
joined_date DATE DEFAULT (CURRENT_DATE),
participation_type VARCHAR(100),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (project_id, farmer_id),
FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id) ON DELETE CASCADE,
INDEX idx_project_farmers_farmers(farmer_id)
);

-- Document Management
CREATE TABLE project_documents (
document_id INT AUTO_INCREMENT PRIMARY KEY,
project_id INT NOT NULL,
document_type VARCHAR(100),
document_url VARCHAR(500),
filename VARCHAR(255),
Uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Uploaded_by INT,
FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE,
FOREIGN KEY (uploaded_by) REFERENCES users(user_id) ON DELETE SET NULL,
INDEX idx_documents_project(project_id),
INDEX idx_documents_type (document_type)
);

-- Contract Management
CREATE TABLE contracts (
contract_id INT AUTO_INCREMENT PRIMARY KEY,
partner_id INT NOT NULL,
contract_ref VARCHAR(255),
contract_terms TEXT,
start_date DATE,
end_date DATE,
status VARCHAR(50),
committed_credits DECIMAL(12,2),
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (partner_id) REFERENCES partners(partner_id) ON DELETE CASCADE,
INDEX idx_contracts_partner (partner_id),
INDEX idx_contracts_dates (start_date, end_date)
);

-- Communication Logs
CREATE TABLE communication_logs (
log_id INT AUTO_INCREMENT PRIMARY KEY,
partner_id INT NOT NULL,
communication_date DATETIME,
communication_type VARCHAR (100),
notes  TEXT,
logged_by INT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (partner_id) REFERENCES partners(partner_id) ON DELETE CASCADE,
FOREIGN KEY (logged_by) REFERENCES users(user_id) ON DELETE SET NULL,
INDEX idx_comms_partner (partner_id),
INDEX idx_comms_date (communication_date)
);
-- Audit Log Table (I'll Recommend for compliance)
CREATE TABLE audit_logs (
audit_id INT AUTO_INCREMENT PRIMARY KEY,
table_name VARCHAR(100) NOT NULL,
record_id INT NOT NULL,
action ENUM( 'INSERT', 'UPDATE', 'DELETE'),
old_values JSON,
new_values JSON,
changed_by INT,
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
INDEX idx_audit_table (table_name),
INDEX idx_audit_record(record_id),
INDEX idx_audit_date(changed_at)
);



			
