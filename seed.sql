-- ============================================================
-- SEED SCRIPT — School Management Database (PostgreSQL)
-- ============================================================
-- IDs are omitted where SERIAL/auto-increment handles them.
-- Uses OVERRIDING SYSTEM VALUE only for tables referenced by FK
-- so we can control the exact IDs used in dependent inserts.
-- Single-quote escaping uses standard SQL '' notation.
-- ============================================================

-- ------------------------------------------------------------
-- LOOKUP / REFERENCE TABLES
-- ------------------------------------------------------------

DO
$$
    DECLARE
        r RECORD;
    BEGIN
        FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public')
            LOOP
                EXECUTE format('TRUNCATE TABLE %I.%I RESTART IDENTITY CASCADE;', 'public', r.tablename);
            END LOOP;
    END
$$;


INSERT INTO program_type (name)
VALUES ('Bachelor'),
       ('Master'),
       ('MBA'),
       ('Certificate'),
       ('Doctorate');

INSERT INTO department (name)
VALUES ('Computer Science'),
       ('Business Administration'),
       ('Engineering'),
       ('Arts & Humanities'),
       ('Health Sciences');

INSERT INTO specialization (name)
VALUES ('Software Engineering'),
       ('Data Science'),
       ('Cybersecurity'),
       ('Marketing'),
       ('Finance'),
       ('Mechanical Engineering'),
       ('Biomedical'),
       ('Literature');

INSERT INTO payment_method (name)
VALUES ('Credit Card'),
       ('Bank Transfer'),
       ('Cash'),
       ('Check'),
       ('Online Payment');

INSERT INTO role (name, description)
VALUES ('admin', 'Full system access'),
       ('instructor', 'Can manage courses and grades'),
       ('student', 'Can view own data and enroll'),
       ('staff', 'Administrative staff access');

-- ------------------------------------------------------------
-- CAMPUSES
-- ------------------------------------------------------------

INSERT INTO campus (name, address, city, zip_code, region, director, phone, email, student_capacity, opening_date,
                    status, created_at, updated_at)
VALUES ('Paris Main Campus', '12 Rue de Rivoli', 'Paris', '75001', 'Ile-de-France', 'Marie Dupont', '+33 1 40 00 01 01',
        'paris@school.edu', 2000, '2005-09-01', 'Active', '2005-09-01 08:00:00', '2024-01-10 09:00:00'),
       ('Lyon Tech Campus', '8 Avenue Berthelot', 'Lyon', '69007', 'Auvergne-Rhone-Alpes', 'Jean-Pierre Martin',
        '+33 4 72 00 02 02', 'lyon@school.edu', 1200, '2010-09-01', 'Active', '2010-09-01 08:00:00',
        '2024-01-10 09:00:00'),
       ('Bordeaux Campus', '3 Cours de la Marne', 'Bordeaux', '33000', 'Nouvelle-Aquitaine', 'Sophie Laurent',
        '+33 5 56 00 03 03', 'bordeaux@school.edu', 800, '2015-09-01', 'Active', '2015-09-01 08:00:00',
        '2024-01-10 09:00:00'),
       ('Marseille Campus', '21 Boulevard Longchamp', 'Marseille', '13001', 'Provence-Alpes-Cote d''Azur',
        'Paul Bernard', '+33 4 91 00 04 04', 'marseille@school.edu', 600, '2018-09-01', 'Active', '2018-09-01 08:00:00',
        '2024-01-10 09:00:00'),
       ('Lille Campus', '55 Rue Nationale', 'Lille', '59000', 'Hauts-de-France', 'Claire Morel', '+33 3 20 00 05 05',
        'lille@school.edu', 400, '2020-09-01', 'Inactive', '2020-09-01 08:00:00', '2024-01-10 09:00:00');

-- ------------------------------------------------------------
-- BUILDINGS
-- ------------------------------------------------------------

INSERT INTO building (campus_id, name)
VALUES (1, 'Building A - Sciences'),
       (1, 'Building B - Humanities'),
       (2, 'Tower North'),
       (2, 'Tower South'),
       (3, 'Main Hall'),
       (4, 'East Wing'),
       (5, 'Central Block');

-- ------------------------------------------------------------
-- ROOM TYPES
-- ------------------------------------------------------------

INSERT INTO room_type (campus_id, name)
VALUES (1, 'Lecture Hall'),
       (1, 'Computer Lab'),
       (2, 'Seminar Room'),
       (2, 'Amphitheatre'),
       (3, 'Workshop'),
       (4, 'Conference Room'),
       (5, 'Study Room');

-- ------------------------------------------------------------
-- ROOMS
-- ------------------------------------------------------------

INSERT INTO room (name, campus_id, building_id, floor, capacity, room_type_id, equipement, status, created_at,
                  updated_at)
VALUES ('A101', 1, 1, 1, 120, 1, 'Projector, Whiteboard, AC', 0, '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('A102', 1, 1, 1, 40, 2, '30 PCs, Dual Screens, AC', 0, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('B201', 1, 2, 2, 30, 3, 'Projector, Whiteboard', 0, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('B301', 1, 2, 3, 200, 4, 'Stage, Microphone, 200 seats', 0, '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('TN01', 2, 3, 1, 80, 1, 'Projector, Smartboard', 0, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('TS01', 2, 4, 1, 25, 3, 'Whiteboard, TV Screen', 0, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('MH01', 3, 5, 0, 150, 1, 'Projector, AC, Microphone', 0, '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('EW01', 4, 6, 1, 50, 6, 'Conference Table, Video System', 0, '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('CB01', 5, 7, 0, 20, 7, 'Study Tables, Whiteboards', 1, '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('A103', 1, 1, 1, 35, 2, '20 PCs, Linux/Windows dual boot', 0, '2023-01-01 08:00:00',
        '2024-01-01 08:00:00');

-- ------------------------------------------------------------
-- PROGRAMS
-- ------------------------------------------------------------

INSERT INTO program (name, program_type_id, duration_in_years, annual_tuition_fee, department, coordinator,
                     max_students, status, created_at, updated_at)
VALUES ('BSc Computer Science', 1, 3, 8500, 'Computer Science', 'Alice Renard', 120, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('MSc Data Science', 2, 2, 12000, 'Computer Science', 'Bruno Leclerc', 60, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('MBA Business Administration', 3, 2, 18000, 'Business Administration', 'Carole Petit', 80, 'Active',
        '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('BSc Mechanical Engineering', 1, 3, 9000, 'Engineering', 'Denis Fourier', 100, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('Certificate Cybersecurity', 4, 1, 5000, 'Computer Science', 'Eva Marchand', 40, 'Active',
        '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('BA Literature', 1, 3, 6000, 'Arts & Humanities', 'Francois Gabin', 80, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('MSc Biomedical Engineering', 2, 2, 14000, 'Health Sciences', 'Gaelle Roux', 50, 'Active',
        '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('PhD Computer Science', 5, 4, 500, 'Computer Science', 'Henri Blanc', 20, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00');

-- ------------------------------------------------------------
-- USERS  (admin + instructors + students)
-- IDs are controlled here because instructors/students FK to user.id
-- ------------------------------------------------------------

INSERT INTO "user" (id, first_name, last_name, email, password, phone, birthday, campus_id, is_active, created_at,
                    updated_at)
    OVERRIDING SYSTEM VALUE
VALUES
    -- Admin
    (1, 'Admin', 'Root', 'admin@school.edu', '$2b$12$admin_hash_placeholder_1', '+33600000001', '1980-01-01', 1, true,
     '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    -- Instructors
    (2, 'Thomas', 'Girard', 'thomas.girard@school.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000002', '1975-03-15', 1,
     true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (3, 'Isabelle', 'Moreau', 'isabelle.moreau@school.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000003', '1978-07-22',
     1, true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (4, 'Nicolas', 'Lemaire', 'nicolas.lemaire@school.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000004', '1982-11-05',
     2, true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (5, 'Aurelie', 'Bonnet', 'aurelie.bonnet@school.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000005', '1979-04-18',
     2, true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (6, 'Marc', 'Fontaine', 'marc.fontaine@school.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000006', '1985-09-30', 3,
     true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (7, 'Celine', 'Rousseau', 'celine.rousseau@school.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000007', '1977-12-12',
     1, true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (8, 'Pierre', 'Dubois', 'pierre.dubois@school.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000008', '1983-06-25', 1,
     true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (9, 'Amelie', 'Perrin', 'amelie.perrin@school.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000009', '1981-02-14', 4,
     true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (10, 'Laurent', 'Chevalier', 'laurent.chev@school.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000010', '1976-08-08',
     4, true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    (11, 'Nathalie', 'Colin', 'nathalie.colin@school.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000011', '1980-05-20',
     2, true, '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
    -- Students
    (12, 'Lucas', 'Martin', 'lucas.martin@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000012', '2001-03-10', 1,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (13, 'Emma', 'Bernard', 'emma.bernard@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000013', '2000-07-14', 1,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (14, 'Hugo', 'Thomas', 'hugo.thomas@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000014', '2002-01-22', 1,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (15, 'Lea', 'Petit', 'lea.petit@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000015', '2001-11-03', 2, true,
     '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (16, 'Nathan', 'Robert', 'nathan.robert@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000016', '2000-05-17',
     2, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (17, 'Camille', 'Richard', 'camille.richard@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000017',
     '2003-09-28', 1, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (18, 'Theo', 'Simon', 'theo.simon@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000018', '2001-04-05', 3,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (19, 'Alice', 'Laurent', 'alice.laurent@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000019', '2002-08-19',
     1, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (20, 'Romain', 'Michel', 'romain.michel@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000020', '2000-12-31',
     1, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (21, 'Ines', 'Lefebvre', 'ines.lefebvre@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000021', '2001-06-06',
     2, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (22, 'Maxime', 'Leroy', 'maxime.leroy@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000022', '2003-02-28', 4,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (23, 'Manon', 'Roux', 'manon.roux@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000023', '2002-10-10', 1,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (24, 'Antoine', 'David', 'antoine.david@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000024', '2001-01-15',
     3, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (25, 'Juliette', 'Bertrand', 'juliette.bert@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000025',
     '2000-03-22', 1, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (26, 'Baptiste', 'Morel', 'baptiste.morel@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000026', '2002-07-07',
     2, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (27, 'Chloe', 'Fournier', 'chloe.fournier@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000027', '2001-09-09',
     1, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (28, 'Valentin', 'Girard', 'valentin.gir@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000028', '2003-11-20',
     4, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (29, 'Pauline', 'Bonnet', 'pauline.bonnet@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000029', '2000-04-04',
     1, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (30, 'Kevin', 'Dupont', 'kevin.dupont@student.edu', '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC',
     '+33600000030', '2002-06-30', 2,
     true, '2023-09-01 08:00:00', '2024-01-01 08:00:00'),
    (31, 'Sarah', 'Mercier', 'sarah.mercier@student.edu',
     '$2b$10$P5mg8CkemtA19uxXrA85ReCz/LEgIlHHkRKqrq/QyCIPTb5E4SoSC', '+33600000031', '2001-08-15',
     3, true, '2023-09-01 08:00:00', '2024-01-01 08:00:00');

-- Advance the sequence past the manually inserted IDs
SELECT setval(pg_get_serial_sequence('"user"', 'id'), 31);

-- ------------------------------------------------------------
-- USER ROLES
-- ------------------------------------------------------------

INSERT INTO user_role (user_id, role_id)
VALUES (1, 1),
       (2, 2),
       (3, 2),
       (4, 2),
       (5, 2),
       (6, 2),
       (7, 2),
       (8, 2),
       (9, 2),
       (10, 2),
       (11, 2),
       (12, 3),
       (13, 3),
       (14, 3),
       (15, 3),
       (16, 3),
       (17, 3),
       (18, 3),
       (19, 3),
       (20, 3),
       (21, 3),
       (22, 3),
       (23, 3),
       (24, 3),
       (25, 3),
       (26, 3),
       (27, 3),
       (28, 3),
       (29, 3),
       (30, 3),
       (31, 3);

-- ------------------------------------------------------------
-- INSTRUCTORS
-- ------------------------------------------------------------

INSERT INTO instructor (user_id, department_id, status, hire_date, specialization_id)
VALUES (2, 1, 'Active', '2015-09-01', 1),
       (3, 1, 'Active', '2018-09-01', 2),
       (4, 3, 'Active', '2016-09-01', 6),
       (5, 2, 'Active', '2019-09-01', 4),
       (6, 2, 'Active', '2017-09-01', 5),
       (7, 1, 'Active', '2014-09-01', 3),
       (8, 4, 'Active', '2020-09-01', 8),
       (9, 5, 'Active', '2021-09-01', 7),
       (10, 2, 'Active', '2013-09-01', 5),
       (11, 1, 'Active', '2022-09-01', 2);

-- ------------------------------------------------------------
-- STUDENTS
-- ------------------------------------------------------------

INSERT INTO student (user_id, program_id, enrollment_year, status, address, city, zip_code,
                     emergency_contact, emergency_phone)
VALUES (12, 1, 2022, 'Active', '10 Rue de la Paix', 'Paris', '75002', 'Marie Martin', '+33611000001'),
       (13, 2, 2023, 'Active', '5 Avenue Foch', 'Paris', '75008', 'Jean Bernard', '+33611000002'),
       (14, 1, 2023, 'Active', '22 Rue du Temple', 'Paris', '75003', 'Anne Thomas', '+33611000003'),
       (15, 3, 2022, 'Active', '14 Cours Gambetta', 'Lyon', '69007', 'Noel Petit', '+33611000004'),
       (16, 4, 2021, 'Active', '3 Rue Garibaldi', 'Lyon', '69003', 'Claire Robert', '+33611000005'),
       (17, 1, 2023, 'Active', '7 Boulevard Haussmann', 'Paris', '75009', 'Luc Richard', '+33611000006'),
       (18, 5, 2023, 'Active', '18 Allee des Pins', 'Bordeaux', '33200', 'Sylvie Simon', '+33611000007'),
       (19, 2, 2023, 'Active', '2 Rue des Fleurs', 'Paris', '75015', 'Eric Laurent', '+33611000008'),
       (20, 6, 2021, 'Active', '9 Impasse Voltaire', 'Paris', '75011', 'Danielle Michel', '+33611000009'),
       (21, 3, 2022, 'Active', '33 Rue Victor Hugo', 'Lyon', '69006', 'Paul Lefebvre', '+33611000010'),
       (22, 4, 2023, 'Active', '11 Bd de la Liberation', 'Marseille', '13004', 'Rita Leroy',
        '+33611000011'),
       (23, 1, 2022, 'Active', '6 Rue Lepic', 'Paris', '75018', 'Jules Roux', '+33611000012'),
       (24, 7, 2022, 'Active', '25 Allee des Roses', 'Bordeaux', '33000', 'Irene David', '+33611000013'),
       (25, 6, 2021, 'Active', '4 Rue Nationale', 'Paris', '75013', 'Victor Bertrand', '+33611000014'),
       (26, 2, 2023, 'Active', '17 Bd du President', 'Lyon', '69002', 'Helene Morel', '+33611000015'),
       (27, 5, 2023, 'Active', '30 Rue des Lilas', 'Paris', '75020', 'Andre Fournier', '+33611000016'),
       (28, 4, 2023, 'Active', '8 Cours Mirabeau', 'Marseille', '13001', 'Sophie Girard', '+33611000017'),
       (29, 8, 2022, 'Active', '12 Rue Oberkampf', 'Paris', '75011', 'Pierre Bonnet', '+33611000018'),
       (30, 3, 2022, 'Active', '21 Rue de la Republique', 'Lyon', '69001', 'Mireille Dupont',
        '+33611000019'),
       (31, 7, 2023, 'Active', '5 Rue de Bretagne', 'Bordeaux', '33800', 'Francois Mercier',
        '+33611000020');

-- ------------------------------------------------------------
-- COURSES
-- ------------------------------------------------------------

INSERT INTO course (name, code, program_id, semester, credits, total_hours, instructor_id, room_id, status, created_at,
                    updated_at)
VALUES ('Introduction to Programming', 'CS101', 1, 1, 6, 60, 2, 2, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('Data Structures & Algorithms', 'CS201', 1, 2, 6, 60, 2, 2, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('Machine Learning Fundamentals', 'DS101', 2, 1, 6, 55, 3, 10, 'Active', '2023-01-01 08:00:00',
        '2024-01-01 08:00:00'),
       ('Deep Learning', 'DS201', 2, 2, 6, 55, 3, 10, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Strategic Management', 'MBA101', 3, 1, 5, 45, 5, 3, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Corporate Finance', 'MBA201', 3, 2, 5, 45, 6, 3, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Thermodynamics', 'ME101', 4, 1, 6, 60, 4, 5, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Fluid Mechanics', 'ME201', 4, 2, 6, 60, 4, 5, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Network Security', 'CYB101', 5, 1, 6, 50, 7, 2, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Ethical Hacking', 'CYB201', 5, 2, 6, 50, 7, 2, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Modern Literature', 'LIT101', 6, 1, 4, 40, 8, 3, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Creative Writing', 'LIT201', 6, 2, 4, 40, 8, 3, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Biomechanics', 'BME101', 7, 1, 6, 55, 9, 5, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Medical Imaging', 'BME201', 7, 2, 6, 55, 9, 5, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00'),
       ('Research Methodology', 'PHD101', 8, 1, 6, 30, 11, 3, 'Active', '2023-01-01 08:00:00', '2024-01-01 08:00:00');

-- ------------------------------------------------------------
-- ENROLLMENTS
-- ------------------------------------------------------------

INSERT INTO enrollment (student_id, course_id, semester, academic_year, status, enrollment_date, created_at,
                        updated_at)
VALUES (12, 1, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (12, 2, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (13, 3, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (13, 4, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (14, 1, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (15, 5, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (15, 6, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (16, 7, 1, 2022, 'Validated', '2022-09-05', '2022-09-05 08:00:00', '2023-01-01 08:00:00'),
       (16, 8, 2, 2022, 'Validated', '2023-02-05', '2023-02-05 08:00:00', '2023-07-01 08:00:00'),
       (17, 1, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (18, 9, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (18, 10, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (19, 3, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (20, 11, 1, 2021, 'Validated', '2021-09-05', '2021-09-05 08:00:00', '2022-01-01 08:00:00'),
       (21, 5, 1, 2022, 'Validated', '2022-09-05', '2022-09-05 08:00:00', '2023-01-01 08:00:00'),
       (22, 7, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (23, 1, 1, 2022, 'Validated', '2022-09-05', '2022-09-05 08:00:00', '2023-01-01 08:00:00'),
       (24, 13, 1, 2022, 'Validated', '2022-09-05', '2022-09-05 08:00:00', '2023-01-01 08:00:00'),
       (25, 12, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (26, 4, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (27, 9, 1, 2023, 'Validated', '2023-09-05', '2023-09-05 08:00:00', '2024-01-01 08:00:00'),
       (28, 8, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00'),
       (29, 15, 1, 2022, 'Validated', '2022-09-05', '2022-09-05 08:00:00', '2023-01-01 08:00:00'),
       (30, 6, 2, 2022, 'Validated', '2023-02-05', '2023-02-05 08:00:00', '2023-07-01 08:00:00'),
       (31, 14, 2, 2023, 'In progress', '2024-02-05', '2024-02-05 08:00:00', '2024-06-01 08:00:00');

-- ------------------------------------------------------------
-- GRADES  (enrollment_id matches insertion order above: 1..25)
-- ------------------------------------------------------------

INSERT INTO grade (enrollment_id, grade, name)
VALUES (1, 16, 'Midterm Exam'),
       (1, 14, 'Final Exam'),
       (3, 18, 'Project'),
       (3, 15, 'Final Exam'),
       (5, 12, 'Midterm Exam'),
       (6, 17, 'Case Study'),
       (8, 14, 'Lab Work'),
       (9, 13, 'Final Exam'),
       (10, 11, 'Midterm Exam'),
       (11, 19, 'Practical Assessment'),
       (13, 16, 'Final Project'),
       (14, 15, 'Essay'),
       (15, 18, 'Presentation'),
       (17, 13, 'Midterm Exam'),
       (18, 14, 'Lab Report'),
       (21, 17, 'Security Audit'),
       (23, NULL, 'Thesis Draft'),
       (24, 16, 'Group Project');

-- ------------------------------------------------------------
-- SCHEDULES
-- ------------------------------------------------------------

INSERT INTO schedule (event_id, course_id, instructor_id, room_id, start_date, end_date, semester, academic_year,
                      status, last_modified, created_at, updated_at)
VALUES (1, 1, 2, 2, '2023-09-11 09:00:00', '2023-09-11 12:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (2, 2, 2, 2, '2024-02-12 09:00:00', '2024-02-12 12:00:00', 2, 2023, 0, '2024-01-15 08:00:00',
        '2024-01-15 08:00:00', '2024-06-01 08:00:00'),
       (3, 3, 3, 10, '2023-09-12 14:00:00', '2023-09-12 17:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (4, 4, 3, 10, '2024-02-13 14:00:00', '2024-02-13 17:00:00', 2, 2023, 0, '2024-01-15 08:00:00',
        '2024-01-15 08:00:00', '2024-06-01 08:00:00'),
       (5, 5, 5, 3, '2023-09-13 09:00:00', '2023-09-13 12:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (6, 7, 4, 5, '2023-09-14 09:00:00', '2023-09-14 12:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (7, 9, 7, 2, '2023-09-15 14:00:00', '2023-09-15 17:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (8, 11, 8, 3, '2023-09-18 10:00:00', '2023-09-18 12:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (9, 13, 9, 5, '2023-09-19 09:00:00', '2023-09-19 12:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00'),
       (10, 15, 11, 3, '2023-09-20 14:00:00', '2023-09-20 16:00:00', 1, 2023, 0, '2023-08-01 08:00:00',
        '2023-08-01 08:00:00', '2024-01-01 08:00:00');

-- ------------------------------------------------------------
-- ATTENDANCE  (schedule_id matches insertion order above: 1..10)
-- ------------------------------------------------------------

INSERT INTO attendance (schedule_id, student_id, status, note, created_at, updated_at)
VALUES (1, 12, 'Present', NULL, '2023-09-11 12:00:00', '2023-09-11 12:00:00'),
       (1, 14, 'Present', NULL, '2023-09-11 12:00:00', '2023-09-11 12:00:00'),
       (1, 17, 'Absent', 'Medical certificate', '2023-09-11 12:00:00', '2023-09-11 12:00:00'),
       (1, 23, 'Present', NULL, '2023-09-11 12:00:00', '2023-09-11 12:00:00'),
       (2, 12, 'Present', NULL, '2024-02-12 12:00:00', '2024-02-12 12:00:00'),
       (3, 13, 'Present', NULL, '2023-09-12 17:00:00', '2023-09-12 17:00:00'),
       (3, 19, 'Late', 'Arrived 20 min late', '2023-09-12 17:00:00', '2023-09-12 17:00:00'),
       (3, 26, 'Present', NULL, '2023-09-12 17:00:00', '2023-09-12 17:00:00'),
       (5, 15, 'Present', NULL, '2023-09-13 12:00:00', '2023-09-13 12:00:00'),
       (5, 21, 'Absent', 'Unexcused', '2023-09-13 12:00:00', '2023-09-13 12:00:00'),
       (6, 16, 'Present', NULL, '2023-09-14 12:00:00', '2023-09-14 12:00:00'),
       (6, 22, 'Present', NULL, '2023-09-14 12:00:00', '2023-09-14 12:00:00'),
       (7, 18, 'Present', NULL, '2023-09-15 17:00:00', '2023-09-15 17:00:00'),
       (7, 27, 'Present', NULL, '2023-09-15 17:00:00', '2023-09-15 17:00:00'),
       (8, 20, 'Present', NULL, '2023-09-18 12:00:00', '2023-09-18 12:00:00'),
       (8, 25, 'Late', 'Traffic issue', '2023-09-18 12:00:00', '2023-09-18 12:00:00'),
       (9, 24, 'Present', NULL, '2023-09-19 12:00:00', '2023-09-19 12:00:00'),
       (9, 31, 'Present', NULL, '2023-09-19 12:00:00', '2023-09-19 12:00:00'),
       (10, 29, 'Present', NULL, '2023-09-20 16:00:00', '2023-09-20 16:00:00'),
       (10, 17, 'Absent', 'Unexcused', '2023-09-20 16:00:00', '2023-09-20 16:00:00');

-- ------------------------------------------------------------
-- PAYMENTS
-- ------------------------------------------------------------

INSERT INTO payment (student_id, invoice_date, due_date, amount, status, payment_date, payment_method_id,
                     academic_year, semester, notes, created_at, updated_at)
VALUES (12, '2023-09-01', '2023-09-30', 8500, 1, '2023-09-15', 1, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2023-09-15 08:00:00'),
       (12, '2024-02-01', '2024-02-28', 8500, 1, '2024-02-10', 1, 2023, 2, 'Tuition S2', '2024-02-01 08:00:00',
        '2024-02-10 08:00:00'),
       (13, '2023-09-01', '2023-09-30', 12000, 1, '2023-09-20', 2, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2023-09-20 08:00:00'),
       (14, '2023-09-01', '2023-09-30', 8500, 1, '2023-09-12', 1, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2023-09-12 08:00:00'),
       (15, '2023-09-01', '2023-09-30', 18000, 1, '2023-09-25', 3, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2023-09-25 08:00:00'),
       (16, '2022-09-01', '2022-09-30', 9000, 1, '2022-09-18', 2, 2022, 1, 'Tuition S1', '2022-09-01 08:00:00',
        '2022-09-18 08:00:00'),
       (17, '2023-09-01', '2023-09-30', 8500, 2, NULL, 1, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2024-01-01 08:00:00'),
       (18, '2023-09-01', '2023-09-30', 5000, 1, '2023-09-10', 5, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2023-09-10 08:00:00'),
       (19, '2023-09-01', '2023-09-30', 12000, 1, '2023-09-22', 1, 2023, 1, 'Tuition S1', '2023-09-01 08:00:00',
        '2023-09-22 08:00:00'),
       (20, '2021-09-01', '2021-09-30', 6000, 1, '2021-09-14', 4, 2021, 1, 'Tuition S1', '2021-09-01 08:00:00',
        '2021-09-14 08:00:00'),
       (21, '2022-09-01', '2022-09-30', 18000, 1, '2022-09-08', 2, 2022, 1, 'Tuition S1', '2022-09-01 08:00:00',
        '2022-09-08 08:00:00'),
       (22, '2023-09-01', '2023-09-30', 9000, 0, NULL, 1, 2023, 1, 'Awaiting payment', '2023-09-01 08:00:00',
        '2024-01-01 08:00:00'),
       (23, '2022-09-01', '2022-09-30', 8500, 1, '2022-09-19', 1, 2022, 1, 'Tuition S1', '2022-09-01 08:00:00',
        '2022-09-19 08:00:00'),
       (24, '2022-09-01', '2022-09-30', 14000, 1, '2022-09-11', 3, 2022, 1, 'Tuition S1', '2022-09-01 08:00:00',
        '2022-09-11 08:00:00'),
       (25, '2021-09-01', '2021-09-30', 6000, 1, '2021-09-16', 2, 2021, 1, 'Tuition S1', '2021-09-01 08:00:00',
        '2021-09-16 08:00:00');

-- ============================================================
-- END OF SEED
-- ============================================================