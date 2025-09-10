# Examination System – SQL Server Project

## 📌 Overview

This project implements a **Database Examination System** in SQL Server.
It covers database design, constraints, stored procedures, reporting, and SQL Server Agent jobs for automated backups.

The system allows:

* Creating exams, questions, and choices.
* Students submitting answers.
* Auto-correcting exams and generating reports.
* Automated backups (full, differential, transaction log).

---

## ⚙️ Database Setup

### 1. Exam Table

```sql
create table Exam
(
    ExamID int primary key, 
    ExamName varchar(200)
)
```

### 2. Partitioning & Student Table

* Created partition function & scheme (`MyFUNC`, `PSCHEMA`).
* `stud` table is partitioned on `St_id`.
* Inserted data from the old `Student` table, updated relations.

```sql
create table stud
(
    St_id int primary key identity,
    st_fname varchar(50),
    st_lname varchar(50),
    st_address varchar(20),
    st_age int,
    Dept_id int foreign key references Department(Dept_id),
    st_super int foreign key references stud(st_id)
) on PSCHEMA (St_id)
```

---

##  Stored Procedures for Reports

### 1. Student Info by Department

```sql
exec StudentInfo_ByDepartment 10
```

### 2. Student Grades by ID

```sql
exec GetGrades_ByID 10
```

### 3. Number of Students per Instructor’s Courses

```sql
exec Courses_NumOfStudents_ByInsID 3
```

### 4. Topics by Course ID

```sql
exec Topics_ByCrsID 2
```

---

##  Exam Management

### Tables

* `Questions` (holds exam questions).
* `Choices` (multiple choices with IsCorrect flag).
* `StudentInExam` (tracks student answers, prevents duplicate answers via PK).

### Procedures

* **GetExamReport** → Show questions & choices by exam.
* **Submit\_one\_Answer** → Insert or update student’s answer.
* **Student\_All\_Answers** → Retrieve all student answers.
* **Correct\_Exam** → Compare student answers vs correct answers.
* **Get\_Student\_Score** → Return total questions, correct answers, and percentage.

---

##  CRUD Operations

* **Questions**:

  * `InsertQuestion`
  * `UpdateQuestion`
  * `DeleteQuestion`
  * `GetQuestions`

* **StudentInExam**:

  * `insert_student_in_exam`
  * `update_student_in_exam`
  * `delete_student_in_exam`

* **Exam**:

  * `Create_Exam`

---

##  Backup Strategy (SQL Server Agent Jobs)

1. **Monthly Full Backup** → Runs on day 1 of each month at 2 AM.
2. **Weekly Differential Backup** → Runs every Sunday at 2:30 AM.
3. **Daily Transaction Log Backup** → Runs every day at 3 AM.

Each job is created in `msdb` using `sp_add_job`, `sp_add_jobstep`, `sp_add_schedule`, etc.

---

##  Example Data Inserted

### Exam 1: *SQL Basics Exam*

* Questions about SQL basics (SELECT, UNIQUE, etc.).
* Students inserted answers → some correct, some wrong.

### Exam 2: *Database Normalization Exam*

* Questions about normalization (1NF, 2NF, 3NF).
* Choices inserted, answers submitted.

---

## Example Reports

* **Correct\_Exam 2,3**
  → Shows Qs, Student’s Answer, Correct Answer, and result.

* **Get\_Student\_Score 2,3**
  → Shows total questions, correct answers, and percentage.

---
Full Project covers:
* Database design & constraints.
* Partitioning.
* Stored procedures (CRUD + Reports).
* Rules, indexes.
* SQL Server Agent backup automation.

