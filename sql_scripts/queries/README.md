# MEDIQUEUE – Hospital Queue & Appointment Management System

## 📌 Overview

**MEDIQUEUE** is a comprehensive Oracle SQL / PL/SQL–based hospital management database designed to handle:

* Doctors & departments
* Patients & appointments
* Queue management
* Audit logging & holidays
* Real‑time notifications
* Doctor daily & weekly performance reports

This project demonstrates **enterprise‑grade database design**, **data generation**, **business logic with triggers**, and **analytics-ready reporting**.

---

## 🧱 System Architecture

The system is divided into the following logical layers:

1. **Core Master Data** – Doctors, Patients, Departments
2. **Transactional Data** – Appointments, Queues, Visits
3. **Operational Logic** – Triggers, Procedures, Notifications
4. **Analytics & Reporting** – Daily & Weekly Doctor Reports
5. **Utilities & Verification** – Data checks, summaries, tests

---

## 🔄 1. Cleanup & Reset Scripts

### Purpose

Ensures a **clean rebuild** of the database by safely removing existing objects.

### Key Features

* Drops tables in **FK-safe order**
* Handles `ORA-00942` and `ORA-02289` gracefully
* Drops all dependent sequences

```sql
-- Drop tables using dynamic SQL to avoid runtime errors
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE DOCTOR_DEPARTMENT CASCADE CONSTRAINTS';
  ...
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
```

✔ Safe for re‑execution

---

## 🗄️ 2. Core Table Definitions

### Main Tables

| Table             | Description                    |
| ----------------- | ------------------------------ |
| DOCTORS           | Doctor master records          |
| PATIENTS          | Patient demographics & history |
| APPOINTMENTS      | Doctor–patient scheduling      |
| QUEUES            | Live queue & wait tracking     |
| DEPARTMENTS       | Hospital departments           |
| DOCTOR_DEPARTMENT | Many‑to‑many mapping           |
| AUDIT_LOG         | Change tracking                |
| HOLIDAYS          | Non‑working days               |

### Design Highlights

* Strong **primary & foreign key constraints**
* Use of `CLOB` for medical notes
* Automatic timestamps (`created_at`, `updated_at`)
* Status‑driven workflows

---

## 🔢 3. Sequences & Indexing

### Sequences

Used for scalable, collision‑free primary keys.

```sql
CREATE SEQUENCE seq_doctor_id START WITH 1000;
CREATE SEQUENCE seq_patient_id START WITH 5000;
```

### Indexes

Optimized for **high‑frequency queries**:

* Appointments by doctor, patient & date
* Queue status & check‑in time

✔ Improves performance for real‑time dashboards

---

## 📥 4. Sample Data Population

### Inserted Data Volume

* **7 Departments**
* **20 Doctors**
* **100 Patients**
* **30 Appointments**
* **Doctor–Department assignments**
* **Holiday calendar (2025–2026)**
* **Queue simulation data**

### Technique Used

* Controlled loops (`FOR i IN`) for realism
* Deterministic ID usage
* Randomized but valid attributes

```sql
FOR i IN 1..100 LOOP
  INSERT INTO PATIENTS VALUES (...);
END LOOP;
```

---

## 📊 5. Verification & Data Summary

Built‑in validation blocks confirm:

* All tables populated successfully
* Sample records printed to console
* Counts per entity

```sql
DBMS_OUTPUT.PUT_LINE('Doctors: ' || v_doctor_count);
```

✔ Ensures correctness before enabling advanced logic

---

## 🔔 6. Notification System

### Purpose

Provides **real‑time patient notifications** for:

* Appointment booking & reminders
* Queue joins
* Queue status changes

### Components

#### Triggers

| Trigger                          | Fires On                |
| -------------------------------- | ----------------------- |
| trg_new_appointment_notification | INSERT on APPOINTMENTS  |
| trg_all_queue_notifications      | INSERT/UPDATE on QUEUES |

#### Notification Types

* `APPOINTMENT_BOOKED`
* `APPOINTMENT_REMINDER`
* `QUEUE_JOINED`
* `QUEUE_UPDATE`
* `TREATMENT_COMPLETE`

✔ Defensive coding with exception handling

---

## 🔁 7. Backfill & Testing Utilities

### Backfill Procedures

Automatically generate notifications for **existing data**:

* `proc_backfill_appointment_notifications`
* `proc_backfill_queue_notifications`

### Test Harness

* Inserts test appointment & queue
* Updates statuses to trigger notifications
* Verifies unread counts

```sql
EXEC proc_test_notification_system;
```

✔ Production‑safe verification

---

## 📈 8. Monitoring & Analytics

### Monitoring View

```sql
CREATE VIEW v_notification_monitor AS
SELECT 'TOTAL', COUNT(*) FROM NOTIFICATIONS
UNION ALL ...
```

Tracks:

* Total notifications
* Unread messages
* Activity per hour/day

---

## 🏥 9. Doctor Weekly Reporting Engine

### Data Generation Logic

Procedure: `proc_generate_patient_visits`

Key guarantees:

* **No zero‑patient days**
* **Minimum 3 patients per doctor per day**
* Age‑aware priority assignment
* Realistic consultation timings

### Reporting Views

* `v_doctor_daily_report`
* `DOCTOR_DAILY_ACTIVITY`
* `PATIENT_VISIT_DETAILS`

---

## 📅 10. Reports Provided

### Reports Available

1. **Today’s Doctor Summary**
2. **7‑Day Hospital Summary**
3. **Doctor Performance Rankings**
4. **Patient‑level visit details**
5. **Data quality verification**

### Example Output

```
Doctor: Dr. John Smith
Patients: 14 | Shift: 8 AM – 5 PM
Priority: H=4 M=6 L=4
```

---

## 🧪 11. Utility Reporting Procedure

Procedure: `proc_simple_report`

* Console‑friendly output
* Totals & breakdowns
* Ideal for ops & audits

```sql
EXEC proc_simple_report(SYSDATE);
```

---

## ✅ Final Capabilities Summary

✔ Fully normalized schema
✔ Safe rebuild & rerun
✔ Real‑time notifications
✔ Automated data generation
✔ Zero‑null reporting guarantees
✔ Analytics‑ready views
✔ Enterprise‑grade PL/SQL patterns

---

## 🚀 Recommended Usage

1. Run cleanup & schema scripts
2. Populate base & sample data
3. Enable notification triggers
4. Generate visit data
5. Query reports & dashboards

---

## 🏁 Status

**MEDIQUEUE is production‑ready for demos, learning, and system design interviews.**

> Built with Oracle SQL & PL/SQL best practices 💼
