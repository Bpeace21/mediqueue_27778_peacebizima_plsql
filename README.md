# 🏥 MediQueue Hospital Queue Management System

<p align="center">
  <b>Oracle 21c & PL/SQL Capstone Project</b><br>
  Adventist University of Central Africa (AUCA)
</p>

---

## 📌 Project Information

| Item | Details |
|-----|--------|
| **Student Name** | Peace Bizima |
| **Student ID** | 27778 |
| **Course** | Database Development with PL/SQL (INSY 8311) |
| **Lecturer** | Eric Maniraguha |
| **Institution** | Adventist University of Central Africa (AUCA) |
| **Academic Year** | 2025–2026 |

---

## 🎯 Project Overview

**MediQueue** is a hospital queue and appointment management system developed using **Oracle Database 21c** and **PL/SQL**.  
The system is designed to improve patient flow, reduce waiting times, manage appointments efficiently, and provide real-time operational insights for hospital staff.

The project strictly follows the **8-phase capstone structure** defined in the course lectures and demonstrates advanced database design, programming, auditing, and analytics skills.

---

## 🚀 Key Features

- Patient registration and medical profile management
- Doctor and department management
- Appointment scheduling and queue processing
- Priority-based queue handling (Emergency, Senior, Regular)
- Real-time queue status tracking
- Automated auditing and security enforcement
- Analytical queries and performance reporting

---

## 🏗️ System Architecture

The system follows a **database-centric layered architecture**:

- **Presentation Layer** – Users (Patients, Reception, Doctors)
- **Business Logic Layer** – PL/SQL procedures, functions, packages, triggers
- **Data Layer** – Oracle 21c Pluggable Database (PDB)

📸 **Screenshot Location:**  
`screenshots/er_diagram/`

---

## 🗂️ Repository Structure

```text
mediqueue_27778_peacebizima_plsql/
│
├── README.md
│
├── database/
│   ├── scripts/              # CREATE TABLE, INSERT scripts
│   └── documentation/        # Data dictionary, schema notes
│
├── plsql/
│   ├── procedures/           # Stored procedures
│   ├── functions/            # PL/SQL functions
│   ├── packages/             # Package specs & bodies
│   └── triggers/             # Triggers & auditing logic
│
├── queries/
│   ├── analytics/            # KPI & BI queries
│   ├── audit/                # Audit log queries
│   └── testing/              # Validation & test queries
│
├── screenshots/
│   ├── er_diagram/
│   ├── database_objects/
│   ├── plsql_execution/
│   ├── triggers_audit/
│   └── bi_reports/
│
└── business_process/
    └── bpmn/                 # BPMN swimlane diagrams

-----------------------------
-----------------------------
### Project Screenshots

