-- Database: keepcoding
DROP DATABASE IF EXISTS keepcoding;
CREATE DATABASE keepcoding;

-------------------- TABLE SPECIFICATION --------------------------

-- Table: student
CREATE TABLE IF NOT EXISTS student (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: bootcamp
CREATE TABLE IF NOT EXISTS bootcamp (
    bootcamp_id SERIAL PRIMARY KEY,
    title VARCHAR(80) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    duration_months INT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    description TEXT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: instructor
CREATE TABLE IF NOT EXISTS instructor (
    instructor_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    NIF VARCHAR(20) NOT NULL,
    qualification VARCHAR(100),
    hire_date DATE NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: course
CREATE TABLE IF NOT EXISTS course (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(80) UNIQUE NOT NULL,
    instructor_id INT,
    total_duration_hours INT NOT NULL,
    description TEXT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instructor_id) REFERENCES instructor (instructor_id)
);

-- Table: student_enrollment_data
CREATE TABLE IF NOT EXISTS student_enrollment_data (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    bootcamp_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ENROLLED',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES student (student_id),
    FOREIGN KEY (bootcamp_id) REFERENCES bootcamp (bootcamp_id)
);

-- Table: bootcamp_course
CREATE TABLE IF NOT EXISTS bootcamp_course (
    bootcamp_class_id SERIAL PRIMARY KEY,
    bootcamp_id INT NOT NULL,
    course_id INT NOT NULL,
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bootcamp_id) REFERENCES bootcamp (bootcamp_id),
    FOREIGN KEY (course_id) REFERENCES course (course_id)
);

-------------------- TRIGGERS --------------------------

-- Trigger to update 'last_updated' every time change is made
DROP FUNCTION IF EXISTS update_last_updated_column();
CREATE OR REPLACE FUNCTION update_last_updated_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.last_updated = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for student table
DROP TRIGGER IF EXISTS student_last_updated ON student;
CREATE TRIGGER student_last_updated
BEFORE UPDATE ON student
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column();

-- Trigger for bootcamp table
DROP TRIGGER IF EXISTS bootcamp_last_updated ON bootcamp;
CREATE TRIGGER bootcamp_last_updated
BEFORE UPDATE ON bootcamp
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column();

-- Trigger for instructor table
DROP TRIGGER IF EXISTS instructor_last_updated ON instructor;
CREATE TRIGGER instructor_last_updated
BEFORE UPDATE ON instructor
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column();

-- Trigger for course table
DROP TRIGGER IF EXISTS course_last_updated ON course;
CREATE TRIGGER course_last_updated
BEFORE UPDATE ON course
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column();

-- Trigger for student_enrollment_data table
DROP TRIGGER IF EXISTS student_enrollment_last_updated ON student_enrollment_data;
CREATE TRIGGER student_enrollment_last_updated
BEFORE UPDATE ON student_enrollment_data
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column();

-- Trigger for bootcamp_course table
DROP TRIGGER IF EXISTS bootcamp_course_last_updated ON bootcamp_course;
CREATE TRIGGER bootcamp_course_last_updated
BEFORE UPDATE ON bootcamp_course
FOR EACH ROW
EXECUTE FUNCTION update_last_updated_column();

-------------------- INSERT DUMMY VALUES --------------------------

INSERT INTO student (name, surname, email, phone)
VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '+1-555-0100'),
('Bob', 'Smith', 'bob.smith@example.com', '+1-555-0101'),
('Charlie', 'Brown', 'charlie.brown@example.com', '+1-555-0102'),
('Diana', 'Prince', 'diana.prince@example.com', '+1-555-0103'),
('Ethan', 'Hunt', 'ethan.hunt@example.com', '+1-555-0104');

INSERT INTO bootcamp (title, start_date, end_date, duration_months, price, description)
VALUES
('Full Stack Web Development', '2024-01-15', '2024-06-15', 5, 5000.00, 'Comprehensive program covering front-end and back-end technologies.'),
('Data Science Immersive', '2024-02-01', '2024-07-31', 6, 6000.00, 'Intensive training in data analysis, machine learning, and big data tools.'),
('Cybersecurity Bootcamp', '2024-03-10', '2024-08-10', 5, 5500.00, 'Learn the fundamentals of cybersecurity and ethical hacking.'),
('Mobile App Development', '2024-04-05', '2024-09-05', 4, 5200.00, 'Develop native and cross-platform mobile applications.'),
('Cloud Computing Essentials', '2024-05-20', '2024-10-20', 5, 5300.00, 'Master cloud services, deployment, and management.');

INSERT INTO instructor (name, surname, email, phone, NIF, qualification, hire_date)
VALUES
('Laura', 'Miller', 'laura.miller@example.com', '+1-555-0200', 'NIF123456A', 'Senior Software Engineer with 10 years of experience.', '2022-08-01'),
('James', 'Wilson', 'james.wilson@example.com', '+1-555-0201', 'NIF234567B', 'Data Scientist specializing in machine learning.', '2023-01-15'),
('Sophia', 'Davis', 'sophia.davis@example.com', '+1-555-0202', 'NIF345678C', 'Cybersecurity Expert and Certified Ethical Hacker.', '2021-11-30'),
('Michael', 'Garcia', 'michael.garcia@example.com', '+1-555-0203', 'NIF456789D', 'Mobile App Developer with expertise in Flutter and React Native.', '2023-05-10'),
('Emma', 'Martinez', 'emma.martinez@example.com', '+1-555-0204', 'NIF567890E', 'Cloud Solutions Architect with AWS and Azure certifications.', '2022-03-25');

INSERT INTO course (title, instructor_id, total_duration_hours, description)
VALUES
('Introduction to HTML & CSS', 1, 20, 'Basics of web development using HTML and CSS.'),
('Advanced JavaScript', 1, 30, 'Deep dive into JavaScript and modern frameworks.'),
('Machine Learning Algorithms', 2, 24, 'Comprehensive study of machine learning techniques.'),
('Network Security', 3, 24, 'Fundamentals of securing networks and data.'),
('iOS App Development', 4, 30, 'Building native iOS applications using Swift.');

INSERT INTO student_enrollment_data (student_id, bootcamp_id, enrollment_date, status)
VALUES
(1, 1, '2024-01-10', 'ENROLLED'),
(2, 1, '2024-02-05', 'ENROLLED'),
(3, 3, '2024-03-08', 'ENROLLED'),
(4, 4, '2024-04-01', 'ENROLLED'),
(5, 2, '2024-05-15', 'ENROLLED');

INSERT INTO bootcamp_course (bootcamp_id, course_id, is_mandatory)
VALUES
(1, 1, TRUE),
(1, 2, TRUE),
(2, 3, TRUE),
(2, 1, TRUE),
(2, 5, FALSE),
(3, 3, TRUE),
(3, 5, TRUE),
(4, 4, TRUE),
(4, 1, TRUE),
(5, 4, TRUE),
(5, 5, TRUE);

-------------------- SAMPLE QUERIES --------------------------

-- 1. Count of students enrolled in each bootcamp
SELECT 
    bootcamp.bootcamp_id,
    bootcamp.title AS bootcamp_title,
    COUNT(student_enrollment_data.enrollment_id) AS total_enrolled_students
FROM 
    bootcamp 
LEFT JOIN 
    student_enrollment_data ON bootcamp.bootcamp_id = student_enrollment_data.bootcamp_id
GROUP BY 
    1, 2
ORDER BY 
    1;
    
-- 2. Display bootcamps with their associated courses  
SELECT 
    bootcamp.bootcamp_id,
    bootcamp.title AS bootcamp_title,
    course.course_id,
    course.title AS course_title,
    bootcamp_course.is_mandatory
FROM 
    bootcamp
JOIN 
    bootcamp_course ON bootcamp.bootcamp_id = bootcamp_course.bootcamp_id
JOIN 
    course ON bootcamp_course.course_id = course.course_id
ORDER BY 
    1, 3;

