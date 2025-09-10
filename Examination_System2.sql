--Report that takes exam number and returns the 
--Questions in it and choices [freeform report] 
--step 1 : Build Exam Table
create table Exam
(
ExamID int primary key , 
ExamName varchar(200)
)
go
--step 2 : Build Questions Table
create or alter table Questions
(
QuestionID int primary key  ,
ExamID int foreign key references Exam(ExamID) ,
QuestionText nvarchar(700)
)
go 
--step 3 : Build Choices Table
create table Choices
(
ChoiceID int primary key,
QuestionID int foreign key references Questions(QuestionID),
choiceText nvarchar(700),
IsCorrect bit
)
--step 3 : Exam Generator
create proc GetExamReport @Exam_ID int
as 
begin
select Q.QuestionID,Q.QuestionText,C.ChoiceID,C.choiceText,C.IsCorrect
from Questions Q inner join Choices C
on Q.QuestionID=C.QuestionID
where Q.ExamID=@Exam_ID
order by Q.QuestionID,C.ChoiceID
End 

--Report that takes exam number and the student 
--ID then returns the Questions in this exam with 
--the student answers
--step 1 
create table StudentInExam
(
StudentID int foreign key references stud(St_id),
ExamID int foreign key references Exam(ExamID),
QuestionID int foreign key references Questions(QuestionID),
ChoiceID int foreign key references Choices(ChoiceID),
CONSTRAINT PK_OneChoice PRIMARY KEY (StudentID, ExamID, QuestionID)
-- This Constraint to not enter more than one Choice
)
--step 2 : Submit_OR_Update_one_Answer
go 
create or alter Proc Submit_one_Answer @Exam_id int ,@StudentID int , @QuestionID int ,@ChoiceID int 
as 
if exists (
select * 
from StudentInExam
where ExamID=@Exam_id and StudentID=@StudentID and QuestionID=@QuestionID
)
begin
update StudentInExam
set ChoiceID=@ChoiceID
where QuestionID=@QuestionID and StudentID=@StudentID and ExamID=@Exam_id
end
else
begin
insert into StudentInExam
values (@StudentID, @Exam_id, @QuestionID, @ChoiceID);
end
go
--step 3 
create or alter Proc Student_All_Answers @Exam_id int ,@StudentID int
as 
begin 
select QuestionID , ChoiceID 
from StudentInExam
where StudentID=@StudentID and  ExamID=@Exam_id
order by QuestionID
end

-----------------------------------------------------------
--create Proc to Correct the Exam
create proc Correct_Exam @ExamID int , @Stud_ID int 
as 
begin 
select Q.QuestionText,C.choiceText as Student_Ans , Cs.choiceText as Correct_Ans,
case 
when STE.ChoiceID = Cs.ChoiceID then 'Correct'
else 'Wrong'
end as result 
from StudentInExam STE 
inner join Questions Q on STE.QuestionID=Q.QuestionID
inner join Choices C on C.ChoiceID = STE.ChoiceID 
inner join Choices Cs on Cs.QuestionID=Q.QuestionID and Cs.IsCorrect = 1
where STE.ExamID=@ExamID and STE.StudentID=@Stud_ID
order by Q.QuestionID
end 
---------------------------------------------------------------

-- Get Student Score
Create proc Get_Student_Score
    @ExamID int,
    @StudentID int 
as
begin
    select 
        Count(*) AS TotalQuestions,
        sum(case when SIE.ChoiceID = C2.ChoiceID then 1 else 0 end) as CorrectAnswers,
        sum(case when SIE.ChoiceID = C2.ChoiceID then 1 else 0 end) * 100.0 / count(*) as Percentage
    FROM StudentInExam SIE
    inner join Questions Q on SIE.QuestionID = Q.QuestionID
    inner join Choices C2 on Q.QuestionID = C2.QuestionID and C2.IsCorrect = 1
    where SIE.StudentID = @StudentID and SIE.ExamID = @ExamID
end
go


--------------------------------------------------------------
-- Select
Create Proc GetQuestions
as 
begin
    Select * from Questions;
end
go

-- Insert
Create or alter Proc InsertQuestion
    @QID int,
    @ExamID int,
    @QuestionText nvarchar(500)
as 
begin
    Insert into Questions (QuestionID, ExamID, QuestionText)
    Values (@QID,@ExamID, @QuestionText);
end
go

-- Update
Create Proc UpdateQuestion
    @QuestionID int,
    @QuestionText nvarchar(500)
as
begin
    update Questions
    set QuestionText = @QuestionText
    where QuestionID = @QuestionID;
end
go

-- Delete
Create Proc DeleteQuestion
    @QuestionID int
as
begin
    Delete from Questions Where QuestionID = @QuestionID;
end
go

-- insert
create or alter proc insert_student_in_exam
    @studentId int,
    @examId int,
    @questionId int,
    @choiceId int
as
begin
    insert into StudentInExam (StudentID, ExamID, QuestionID, ChoiceID)
    values (@studentId, @examId, @questionId, @choiceId)
end;
go
--create Exam
create proc Create_Exam @examID int , @examName varchar(200)
as 
begin 
insert into Exam
values(@examID,@examName)
end
--Update 
create or alter proc update_student_in_exam
    @studentId int,
    @examId int,
    @questionId int,
    @choiceId int
as
begin
    update StudentInExam
    set ChoiceID = @choiceId
    where StudentID = @studentId 
      and ExamID = @examId 
      and QuestionID = @questionId
end;
go

-- Delete 
create or alter proc delete_student_in_exam
    @studentId int,
    @examId int,
    @questionId int
as
begin
    delete from StudentInExam
    where StudentID = @studentId 
      and ExamID = @examId 
      and QuestionID = @questionId
end;
go

-----------------------------------------------------
-------Data-------------------
insert into Exam (ExamID, ExamName)
values (1, 'SQL Basics Exam');

insert into Questions (QuestionID, ExamID, QuestionText)
values 
(101, 1, 'What does SQL stand for?'),
(102, 1, 'Which SQL keyword is used to fetch data?'),
(103, 1, 'Which constraint ensures uniqueness of values in a column?');




-- Question 101
insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values 
(1001, 101, 'Structured Query Language', 1),
(1002, 101, 'Strong Question Line', 0),
(1003, 101, 'Simple Quick Logic', 0);

-- Question 102
insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values 
(1004, 102, 'SELECT', 1),
(1005, 102, 'FETCH', 0),
(1006, 102, 'PULL', 0);

-- Question 103
insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values 
(1007, 103, 'UNIQUE', 1),
(1008, 103, 'NOT NULL', 0),
(1009, 103, 'CHECK', 0);



execute insert_student_in_exam 1, 1, 101, 1001
execute insert_student_in_exam 1, 1, 102, 1005
execute insert_student_in_exam 1, 1, 103, 1007


execute insert_student_in_exam 3, 1, 101, 1002
execute insert_student_in_exam 3, 1, 102, 1004
execute insert_student_in_exam 3, 1, 103, 1008


exec Create_Exam 
    @ExamID = 2, 
    @ExamName = 'Database Normalization Exam'
 
exec InsertQuestion @QID = 201, @ExamID = 2, @QuestionText = 'What is the main goal of normalization?';
exec InsertQuestion @QID = 202, @ExamID = 2, @QuestionText = 'Which normal form removes partial dependency?';
exec InsertQuestion @QID = 203, @ExamID = 2, @QuestionText = 'Which normal form deals with transitive dependency?';

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2001, 201, 'Reduce redundancy and improve data integrity', 1);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2002, 201, 'Increase query complexity', 0);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2003, 201, 'Reduce database size only', 0);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2004, 202, '1NF', 0);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2005, 202, '2NF', 1);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2006, 202, '3NF', 0);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2007, 203, '1NF', 0);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2008, 203, '2NF', 0);

insert into Choices (ChoiceID, QuestionID, ChoiceText, IsCorrect)
values (2009, 203, '3NF', 1);

execute insert_student_in_exam 1, 2, 201, 2001
execute insert_student_in_exam 1, 2, 202, 2005
execute insert_student_in_exam 1, 2, 203, 2009


execute insert_student_in_exam 3, 2, 201, 2002
execute insert_student_in_exam 3, 2, 202, 2005
execute insert_student_in_exam 3, 2, 203, 2009

execute Correct_Exam 2,3
execute Get_Student_Score 2,3

