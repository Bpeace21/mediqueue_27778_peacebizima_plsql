-- Clean up existing objects if they exist
BEGIN
    -- Drop tables in correct order due to foreign key constraints
    EXECUTE IMMEDIATE 'DROP TABLE DOCTOR_DEPARTMENT CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE QUEUES CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE APPOINTMENTS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE HOLIDAYS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DOCTORS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PATIENTS CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DEPARTMENTS CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    -- Drop sequences
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_doctor_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_patient_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_appointment_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_queue_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_dept_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_audit_id';
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_holiday_id';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

-- Create tables
CREATE TABLE DOCTORS (
    doctor_id NUMBER(10) PRIMARY KEY,
    license_number VARCHAR2(20) UNIQUE NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(15) NOT NULL,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PATIENTS (
    patient_id NUMBER(10) PRIMARY KEY,
    patient_code VARCHAR2(20) UNIQUE NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR2(10) NOT NULL,
    email VARCHAR2(100),
    phone VARCHAR2(15) NOT NULL,
    medical_history CLOB,
    blood_type VARCHAR2(5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE APPOINTMENTS (
    appointment_id NUMBER(10) PRIMARY KEY,
    doctor_id NUMBER(10) NOT NULL,
    patient_id NUMBER(10) NOT NULL,
    appointment_date TIMESTAMP NOT NULL,
    appointment_type VARCHAR2(50) NOT NULL,
    status VARCHAR2(20) DEFAULT 'SCHEDULED',
    reason CLOB NOT NULL,
    notes CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appt_doctor FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id),
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id)
);

CREATE TABLE QUEUES (
    queue_id NUMBER(10) PRIMARY KEY,
    doctor_id NUMBER(10) NOT NULL,
    appointment_id NUMBER(10),
    patient_id NUMBER(10) NOT NULL,
    queue_number NUMBER(5) NOT NULL,
    queue_type VARCHAR2(20) DEFAULT 'REGULAR',
    status VARCHAR2(20) DEFAULT 'WAITING',
    check_in_time TIMESTAMP NOT NULL,
    called_time TIMESTAMP,
    completed_time TIMESTAMP,
    estimated_wait_time NUMBER(5),
    priority_level NUMBER(2) DEFAULT 5,
    CONSTRAINT fk_queue_doctor FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id),
    CONSTRAINT fk_queue_appt FOREIGN KEY (appointment_id) REFERENCES APPOINTMENTS(appointment_id),
    CONSTRAINT fk_queue_patient FOREIGN KEY (patient_id) REFERENCES PATIENTS(patient_id)
);

CREATE TABLE DEPARTMENTS (
    dept_id NUMBER(5) PRIMARY KEY,
    dept_name VARCHAR2(100) NOT NULL,
    location VARCHAR2(200),
    phone VARCHAR2(15)
);

CREATE TABLE DOCTOR_DEPARTMENT (
    doctor_id NUMBER(10),
    dept_id NUMBER(5),
    is_primary CHAR(1) DEFAULT 'N',
    CONSTRAINT pk_doc_dept PRIMARY KEY (doctor_id, dept_id),
    CONSTRAINT fk_dd_doctor FOREIGN KEY (doctor_id) REFERENCES DOCTORS(doctor_id),
    CONSTRAINT fk_dd_dept FOREIGN KEY (dept_id) REFERENCES DEPARTMENTS(dept_id)
);

CREATE TABLE AUDIT_LOG (
    audit_id NUMBER(15) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL,
    old_values CLOB,
    new_values CLOB,
    user_id VARCHAR2(50),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE HOLIDAYS (
    holiday_id NUMBER(5) PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR2(200),
    year NUMBER(4)
);

-- Create sequences
CREATE SEQUENCE seq_doctor_id START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_patient_id START WITH 5000 INCREMENT BY 1;
CREATE SEQUENCE seq_appointment_id START WITH 10000 INCREMENT BY 1;
CREATE SEQUENCE seq_queue_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_dept_id START WITH 10 INCREMENT BY 10;
CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_holiday_id START WITH 1 INCREMENT BY 1;

-- Create indexes
CREATE INDEX idx_appt_doctor ON APPOINTMENTS(doctor_id);
CREATE INDEX idx_appt_patient ON APPOINTMENTS(patient_id);
CREATE INDEX idx_appt_date ON APPOINTMENTS(appointment_date);
CREATE INDEX idx_queue_status ON QUEUES(status);
CREATE INDEX idx_queue_doctor ON QUEUES(doctor_id);
CREATE INDEX idx_queue_checkin ON QUEUES(check_in_time);

-- Insert departments FIRST (no dependencies)
INSERT INTO DEPARTMENTS VALUES (10, 'Cardiology', 'Building A, Floor 2', '0783003001');
INSERT INTO DEPARTMENTS VALUES (20, 'Pediatrics', 'Building A, Floor 1', '0783003002');
INSERT INTO DEPARTMENTS VALUES (30, 'Orthopedics', 'Building B, Floor 1', '0783003003');
INSERT INTO DEPARTMENTS VALUES (40, 'Emergency', 'Main Building', '0783003004');
INSERT INTO DEPARTMENTS VALUES (50, 'Radiology', 'Building C, Floor 1', '0783003005');
INSERT INTO DEPARTMENTS VALUES (60, 'Neurology', 'Building D, Floor 3', '0783003006');
INSERT INTO DEPARTMENTS VALUES (70, 'Dermatology', 'Building E, Floor 2', '0783003007');

COMMIT;
DBMS_OUTPUT.PUT_LINE('Departments inserted: 7 rows');

-- Insert 20 doctors
DECLARE
    v_doctor_count NUMBER := 0;
BEGIN
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED001', 'John', 'Smith', 'Cardiology', 'john.smith@hospital.com', '0781001001', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED002', 'Sarah', 'Johnson', 'Pediatrics', 'sarah.j@hospital.com', '0781001002', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED003', 'Robert', 'Williams', 'Orthopedics', 'robert.w@hospital.com', '0781001003', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED004', 'Emily', 'Davis', 'Emergency', 'emily.d@hospital.com', '0781001004', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED005', 'Michael', 'Brown', 'Radiology', 'michael.b@hospital.com', '0781001005', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED006', 'Jennifer', 'Miller', 'Neurology', 'jennifer.m@hospital.com', '0781001006', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED007', 'David', 'Wilson', 'Dermatology', 'david.w@hospital.com', '0781001007', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED008', 'Lisa', 'Taylor', 'Cardiology', 'lisa.t@hospital.com', '0781001008', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED009', 'James', 'Anderson', 'Pediatrics', 'james.a@hospital.com', '0781001009', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED010', 'Patricia', 'Thomas', 'Orthopedics', 'patricia.t@hospital.com', '0781001010', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED011', 'Christopher', 'Jackson', 'Emergency', 'chris.j@hospital.com', '0781001011', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED012', 'Barbara', 'White', 'Radiology', 'barbara.w@hospital.com', '0781001012', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED013', 'Daniel', 'Harris', 'Neurology', 'daniel.h@hospital.com', '0781001013', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED014', 'Susan', 'Martin', 'Dermatology', 'susan.m@hospital.com', '0781001014', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED015', 'Paul', 'Thompson', 'Cardiology', 'paul.t@hospital.com', '0781001015', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED016', 'Margaret', 'Garcia', 'Pediatrics', 'margaret.g@hospital.com', '0781001016', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED017', 'Mark', 'Martinez', 'Orthopedics', 'mark.m@hospital.com', '0781001017', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED018', 'Nancy', 'Robinson', 'Emergency', 'nancy.r@hospital.com', '0781001018', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED019', 'Steven', 'Clark', 'Radiology', 'steven.c@hospital.com', '0781001019', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    INSERT INTO DOCTORS VALUES (seq_doctor_id.NEXTVAL, 'MED020', 'Betty', 'Rodriguez', 'Neurology', 'betty.r@hospital.com', '0781001020', 'ACTIVE', SYSTIMESTAMP); v_doctor_count := v_doctor_count + 1;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Doctors inserted: ' || v_doctor_count || ' rows');
END;
/

-- Insert 100 patients
DECLARE
    v_patient_count NUMBER := 0;
BEGIN
    -- First 50 patients
    FOR i IN 1..50 LOOP
        INSERT INTO PATIENTS VALUES (
            seq_patient_id.NEXTVAL,
            'PAT' || (4999 + i),
            CASE MOD(i, 10)
                WHEN 0 THEN 'John' WHEN 1 THEN 'Mary' WHEN 2 THEN 'David' WHEN 3 THEN 'Lisa'
                WHEN 4 THEN 'Robert' WHEN 5 THEN 'Sarah' WHEN 6 THEN 'Michael' WHEN 7 THEN 'Emily'
                WHEN 8 THEN 'James' WHEN 9 THEN 'Jennifer' END,
            CASE MOD(i, 10)
                WHEN 0 THEN 'Doe' WHEN 1 THEN 'Smith' WHEN 2 THEN 'Johnson' WHEN 3 THEN 'Williams'
                WHEN 4 THEN 'Brown' WHEN 5 THEN 'Jones' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
                WHEN 8 THEN 'Wilson' WHEN 9 THEN 'Taylor' END,
            TO_DATE('1980-01-01', 'YYYY-MM-DD') + (i * 100),
            CASE MOD(i, 2) WHEN 0 THEN 'Male' ELSE 'Female' END,
            'patient' || i || '@email.com',
            '0782002' || LPAD(i, 3, '0'),
            'Medical history for patient ' || i,
            CASE MOD(i, 4)
                WHEN 0 THEN 'A+' WHEN 1 THEN 'B+' WHEN 2 THEN 'O+' WHEN 3 THEN 'AB+' END,
            SYSTIMESTAMP
        );
        v_patient_count := v_patient_count + 1;
    END LOOP;
    
    -- Next 50 patients
    FOR i IN 51..100 LOOP
        INSERT INTO PATIENTS VALUES (
            seq_patient_id.NEXTVAL,
            'PAT' || (4999 + i),
            CASE MOD(i, 15)
                WHEN 0 THEN 'Thomas' WHEN 1 THEN 'Patricia' WHEN 2 THEN 'Christopher' WHEN 3 THEN 'Barbara'
                WHEN 4 THEN 'Daniel' WHEN 5 THEN 'Susan' WHEN 6 THEN 'Paul' WHEN 7 THEN 'Margaret'
                WHEN 8 THEN 'Mark' WHEN 9 THEN 'Nancy' WHEN 10 THEN 'Steven' WHEN 11 THEN 'Betty'
                WHEN 12 THEN 'Andrew' WHEN 13 THEN 'Sandra' WHEN 14 THEN 'Kenneth' END,
            CASE MOD(i, 15)
                WHEN 0 THEN 'Anderson' WHEN 1 THEN 'Thomas' WHEN 2 THEN 'Jackson' WHEN 3 THEN 'White'
                WHEN 4 THEN 'Harris' WHEN 5 THEN 'Martin' WHEN 6 THEN 'Thompson' WHEN 7 THEN 'Garcia'
                WHEN 8 THEN 'Martinez' WHEN 9 THEN 'Robinson' WHEN 10 THEN 'Clark' WHEN 11 THEN 'Rodriguez'
                WHEN 12 THEN 'Lewis' WHEN 13 THEN 'Lee' WHEN 14 THEN 'Walker' END,
            TO_DATE('1970-01-01', 'YYYY-MM-DD') + (i * 95),
            CASE MOD(i, 2) WHEN 0 THEN 'Male' ELSE 'Female' END,
            'patient' || i || '@email.com',
            '0782003' || LPAD(MOD(i, 1000), 3, '0'),
            'Medical condition ' || i,
            CASE MOD(i, 4)
                WHEN 0 THEN 'A-' WHEN 1 THEN 'B-' WHEN 2 THEN 'O-' WHEN 3 THEN 'AB-' END,
            SYSTIMESTAMP
        );
        v_patient_count := v_patient_count + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patients inserted: ' || v_patient_count || ' rows');
END;
/

-- Insert 30 appointments (only for existing doctors 1000-1019 and patients 5000-5029)
DECLARE
    v_appointment_count NUMBER := 0;
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO APPOINTMENTS VALUES (
            seq_appointment_id.NEXTVAL,
            1000 + MOD(i-1, 20),  -- Doctor IDs 1000-1019
            5000 + MOD(i-1, 30),  -- Patient IDs 5000-5029
            TO_TIMESTAMP('2025-12-' || LPAD(10 + MOD(i-1, 15), 2, '0') || ' ' || 
                        LPAD(8 + MOD(i-1, 8), 2, '0') || ':00:00', 'YYYY-MM-DD HH24:MI:SS'),
            CASE MOD(i, 5)
                WHEN 0 THEN 'Consultation' WHEN 1 THEN 'Follow-up' WHEN 2 THEN 'Checkup'
                WHEN 3 THEN 'Emergency' WHEN 4 THEN 'Surgical' END,
            'SCHEDULED',
            'Reason for appointment ' || i,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );
        v_appointment_count := v_appointment_count + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointments inserted: ' || v_appointment_count || ' rows');
END;
/

-- Insert doctor-department assignments (only for existing doctors 1000-1019)
DECLARE
    v_assignment_count NUMBER := 0;
BEGIN
    FOR i IN 0..19 LOOP
        INSERT INTO DOCTOR_DEPARTMENT VALUES (
            1000 + i,
            10 + (MOD(i, 7) * 10),
            CASE WHEN MOD(i, 7) = 0 THEN 'Y' ELSE 'N' END
        );
        v_assignment_count := v_assignment_count + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Doctor-Department assignments inserted: ' || v_assignment_count || ' rows');
END;
/

-- Insert holidays
DECLARE
    v_holiday_count NUMBER := 0;
BEGIN
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2025-12-25', 'Christmas Day', 2025); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-01-01', 'New Year', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-04-18', 'Good Friday', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-04-21', 'Easter Monday', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-05-01', 'Labor Day', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-07-01', 'National Holiday', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-08-15', 'Assumption Day', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-12-25', 'Christmas Day', 2026); v_holiday_count := v_holiday_count + 1;
    INSERT INTO HOLIDAYS VALUES (seq_holiday_id.NEXTVAL, DATE '2026-12-26', 'Boxing Day', 2026); v_holiday_count := v_holiday_count + 1;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Holidays inserted: ' || v_holiday_count || ' rows');
END;
/

-- Insert sample queue data (only after appointments are created)
DECLARE
    v_queue_count NUMBER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO QUEUES VALUES (
            seq_queue_id.NEXTVAL,
            1000 + MOD(i-1, 20),
            10000 + MOD(i-1, 30),
            5000 + MOD(i-1, 30),
            i,
            'REGULAR',
            CASE MOD(i, 3)
                WHEN 0 THEN 'WAITING' WHEN 1 THEN 'IN_PROGRESS' WHEN 2 THEN 'COMPLETED' END,
            SYSTIMESTAMP - INTERVAL '30' MINUTE,
            CASE WHEN MOD(i, 3) != 0 THEN SYSTIMESTAMP - INTERVAL '15' MINUTE ELSE NULL END,
            CASE WHEN MOD(i, 3) = 2 THEN SYSTIMESTAMP ELSE NULL END,
            30,
            CASE MOD(i, 3)
                WHEN 0 THEN 5 WHEN 1 THEN 3 WHEN 2 THEN 1 END
        );
        v_queue_count := v_queue_count + 1;
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Queue entries inserted: ' || v_queue_count || ' rows');
END;
/

-- Display sample data
DECLARE
    v_doctor_count NUMBER;
    v_patient_count NUMBER;
    v_appointment_count NUMBER;
    v_department_count NUMBER;
    v_queue_count NUMBER;
BEGIN
    -- Count records
    SELECT COUNT(*) INTO v_doctor_count FROM DOCTORS;
    SELECT COUNT(*) INTO v_patient_count FROM PATIENTS;
    SELECT COUNT(*) INTO v_appointment_count FROM APPOINTMENTS;
    SELECT COUNT(*) INTO v_department_count FROM DEPARTMENTS;
    SELECT COUNT(*) INTO v_queue_count FROM QUEUES;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '========== MEDIQUEUE DATABASE SUMMARY ==========');
    DBMS_OUTPUT.PUT_LINE('Doctors: ' || v_doctor_count || ' records');
    DBMS_OUTPUT.PUT_LINE('Patients: ' || v_patient_count || ' records');
    DBMS_OUTPUT.PUT_LINE('Appointments: ' || v_appointment_count || ' records');
    DBMS_OUTPUT.PUT_LINE('Departments: ' || v_department_count || ' records');
    DBMS_OUTPUT.PUT_LINE('Queue entries: ' || v_queue_count || ' records');
    DBMS_OUTPUT.PUT_LINE('===================================================' || CHR(10));
    
    -- Verify data exists
    IF v_doctor_count > 0 AND v_patient_count > 0 AND v_appointment_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Database successfully populated!');
        
        -- Show first 3 records from each main table
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- FIRST 3 DOCTORS ---');
        FOR doc IN (SELECT * FROM DOCTORS WHERE ROWNUM <= 3 ORDER BY doctor_id) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || doc.doctor_id || ' | Name: ' || doc.first_name || ' ' || doc.last_name || 
                               ' | Specialization: ' || doc.specialization || ' | Status: ' || doc.status);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- FIRST 3 PATIENTS ---');
        FOR pat IN (SELECT * FROM PATIENTS WHERE ROWNUM <= 3 ORDER BY patient_id) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || pat.patient_id || ' | Name: ' || pat.first_name || ' ' || pat.last_name || 
                               ' | DOB: ' || TO_CHAR(pat.date_of_birth, 'YYYY-MM-DD') || ' | Gender: ' || pat.gender);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- FIRST 3 APPOINTMENTS ---');
        FOR appt IN (
            SELECT a.appointment_id, a.doctor_id, a.patient_id, 
                   TO_CHAR(a.appointment_date, 'YYYY-MM-DD HH24:MI') as appt_date,
                   a.appointment_type, a.status
            FROM APPOINTMENTS a 
            WHERE ROWNUM <= 3 
            ORDER BY a.appointment_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || appt.appointment_id || ' | Doctor: ' || appt.doctor_id || 
                               ' | Patient: ' || appt.patient_id || ' | Date: ' || appt.appt_date || 
                               ' | Type: ' || appt.appointment_type);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- ALL DEPARTMENTS ---');
        FOR dept IN (SELECT * FROM DEPARTMENTS ORDER BY dept_id) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || dept.dept_id || ' | Name: ' || dept.dept_name || ' | Location: ' || dept.location);
        END LOOP;
        
    ELSE
        DBMS_OUTPUT.PUT_LINE('❌ Database population failed!');
    END IF;
END;
/

-- Simple verification queries
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '========== DATA VERIFICATION ==========');
    
    -- Check if tables have data
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM DOCTORS;
        DBMS_OUTPUT.PUT_LINE('DOCTORS table has ' || v_count || ' records');
        
        SELECT COUNT(*) INTO v_count FROM PATIENTS;
        DBMS_OUTPUT.PUT_LINE('PATIENTS table has ' || v_count || ' records');
        
        SELECT COUNT(*) INTO v_count FROM APPOINTMENTS;
        DBMS_OUTPUT.PUT_LINE('APPOINTMENTS table has ' || v_count || ' records');
        
        SELECT COUNT(*) INTO v_count FROM QUEUES;
        DBMS_OUTPUT.PUT_LINE('QUEUES table has ' || v_count || ' records');
        
        SELECT COUNT(*) INTO v_count FROM DEPARTMENTS;
        DBMS_OUTPUT.PUT_LINE('DEPARTMENTS table has ' || v_count || ' records');
        
        SELECT COUNT(*) INTO v_count FROM DOCTOR_DEPARTMENT;
        DBMS_OUTPUT.PUT_LINE('DOCTOR_DEPARTMENT table has ' || v_count || ' records');
        
        SELECT COUNT(*) INTO v_count FROM HOLIDAYS;
        DBMS_OUTPUT.PUT_LINE('HOLIDAYS table has ' || v_count || ' records');
    END;
END;
/
