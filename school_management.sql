CREATE DATABASE school_managements;
USE school_managements;

CREATE TABLE teachers (
    id INT AUTO_INCREMENT,
    NAME VARCHAR(100),
    SUBJECT VARCHAR(50),
    PRIMARY KEY(id)
);

INSERT INTO teachers (NAME, SUBJECT) VALUES ('Pak Anton', 'Matematika');
INSERT INTO teachers (NAME, SUBJECT) VALUES ('Bu Dina', 'Bahasa Indonesia');
INSERT INTO teachers (NAME, SUBJECT) VALUES ('Pak Eko', 'Biologi');
INSERT INTO teachers (NAME, SUBJECT) VALUES ('Pak Fajar', 'Fisika');
INSERT INTO teachers (NAME, SUBJECT) VALUES ('Bu Gita', 'Kimia');

CREATE TABLE classes (
    id INT AUTO_INCREMENT,
    NAME VARCHAR(50),
    teacher_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 10A', 1);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 11B', 2);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 12C', 3);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 10B', 1);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 11A', 2);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 12A', 3);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 10C', 4);
INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 11C', 5);

CREATE TABLE students (
    id INT AUTO_INCREMENT,
    NAME VARCHAR(100),
    age INT,
    class_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

INSERT INTO students (NAME, age, class_id) VALUES ('Budi', 16, 1);
INSERT INTO students (NAME, age, class_id) VALUES ('Ani', 17, 2);
INSERT INTO students (NAME, age, class_id) VALUES ('Candra', 18, 3);
INSERT INTO students (NAME, age, class_id) VALUES ('Dewi', 16, 4);
INSERT INTO students (NAME, age, class_id) VALUES ('Eko', 17, 5);
INSERT INTO students (NAME, age, class_id) VALUES ('Farah', 18, 1);
INSERT INTO students (NAME, age, class_id) VALUES ('Gilang', 16, 2);
INSERT INTO students (NAME, age, class_id) VALUES ('Hadi', 17, 3);


#Soal 1
SELECT 
    students.name AS student_name, 
    classes.name AS class_name, 
    teachers.name AS teacher_name
FROM 
    students
JOIN 
    classes ON students.class_id = classes.id
JOIN 
    teachers ON classes.teacher_id = teachers.id;

	
#Soal 2
SELECT classes.name AS class_name
FROM classes
JOIN teachers ON classes.teacher_id = teachers.id
WHERE teachers.name = 'Pak Anton';

#Versi procedur nya
DELIMITER //

CREATE PROCEDURE sp_classes_taught_by_teacher(
    IN teacher_name VARCHAR(100)
)
BEGIN
    SELECT classes.name AS class_name
    FROM classes
    JOIN teachers ON classes.teacher_id = teachers.id
    WHERE teachers.name = teacher_name;
END //

DELIMITER ;

CALL sp_classes_taught_by_teacher('Pak Anton');


#Soal 3
CREATE VIEW student_class_teacher AS
SELECT 
    students.name AS student_name, 
    classes.name AS class_name, 
    teachers.name AS teacher_name
FROM 
    students
JOIN 
    classes ON students.class_id = classes.id
JOIN 
    teachers ON classes.teacher_id = teachers.id;
    
#Versi per tabel
CREATE VIEW student_view AS
SELECT id, NAME AS student_name, age, class_id
FROM students;

CREATE VIEW class_view AS
SELECT id, NAME AS class_name, teacher_id
FROM classes;

CREATE VIEW teacher_view AS
SELECT id, NAME AS teacher_name
FROM teachers;

   
#Soal 4
DELIMITER //

CREATE PROCEDURE GetStudentClassTeacher()
BEGIN
    SELECT 
        students.name AS student_name, 
        classes.name AS class_name, 
        teachers.name AS teacher_name
    FROM 
        students
    JOIN 
        classes ON students.class_id = classes.id
    JOIN 
        teachers ON classes.teacher_id = teachers.id;
END //

DELIMITER ;

CALL GetStudentClassTeacher();

#Versi per tabel
DELIMITER //

CREATE PROCEDURE sp_students()
BEGIN
    SELECT *
    FROM students;
END //

DELIMITER ;

CALL sp_students();


DELIMITER //

CREATE PROCEDURE sp_classes()
BEGIN
    SELECT *
    FROM classes;
END //

DELIMITER ;

CALL sp_classes();


DELIMITER //

CREATE PROCEDURE sp_teachers()
BEGIN
    SELECT *
    FROM teachers;
END //

DELIMITER ;

CALL sp_teachers();


#Soal 5
DELIMITER //

CREATE TRIGGER before_student_insert
BEFORE INSERT ON students
FOR EACH ROW
BEGIN
    DECLARE student_exists INT;
    
    SELECT COUNT(*) INTO student_exists
    FROM students
    WHERE NAME = NEW.name AND age = NEW.age AND class_id = NEW.class_id;

    IF student_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Data siswa yang sama sudah ada.';
    END IF;
END //

DELIMITER ;

INSERT INTO students (NAME, age, class_id) VALUES ('Budi', 16, 1);


DELIMITER //

CREATE TRIGGER before_class_insert
BEFORE INSERT ON classes
FOR EACH ROW
BEGIN
    DECLARE class_exists INT;
    
    SELECT COUNT(*)
    INTO class_exists
    FROM classes
    WHERE NAME = NEW.name AND teacher_id = NEW.teacher_id;

    IF class_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Data kelas yang diajar oleh guru yang sama sudah ada.';
    END IF;
END //

DELIMITER ;

INSERT INTO classes (NAME, teacher_id) VALUES ('Kelas 10A', 1);


DELIMITER //

CREATE TRIGGER before_teacher_insert
BEFORE INSERT ON teachers
FOR EACH ROW
BEGIN
    DECLARE teacher_exists INT;
    
    SELECT COUNT(*)
    INTO teacher_exists
    FROM teachers
    WHERE NAME = NEW.name;

    IF teacher_exists > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Data guru dengan nama yang sama sudah ada.';
    END IF;
END //

DELIMITER ;

INSERT INTO teachers (NAME) VALUES ('Pak Anton');
