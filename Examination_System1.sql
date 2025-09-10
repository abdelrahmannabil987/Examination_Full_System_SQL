use Examination_System


create partition function MyFUNC(int)
as range left 
for values (20000,40000,60000)

create partition scheme PSCHEMA
as partition MyFUNC
to (fg00,fg11,fg22,fg33)

create table stud
(
St_id int primary key identity ,
st_fname varchar(50),
st_lname varchar(50),
st_address varchar(20),
st_age int,
Dept_id int,
st_super int
)on PSCHEMA (St_id)

--insert values from student int student 
insert into stud 
select st_fname,St_Lname,St_Address,St_Age,Dept_Id,St_super from student
--connect relations
alter table stud add foreign key (Dept_id) references Department(Dept_id)
alter table stud add foreign key (st_super) references stud(st_id)

--drop all relations between student and other tables to drop it 
--and connect to stud table (which has PSCHEMA)

SELECT name, object_id
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('Stud_Course');

alter table Stud_Course 
drop constraint FK_Stud_Course_Student

alter table Stud_Course
add foreign key (St_id) references stud(st_id)


SELECT name, object_id
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('Student');


alter table Student 
drop constraint FK_Student_Student
go
alter table Student 
drop constraint FK_Student_Department

drop table Student

-----------------------------------------------------------

create or alter proc StudentInfo_ByDepartment @DeptID int
as 
select CONCAT(isnull(st_fname,' '),' ',isnull(st_lname,' ')) as [student name],
		d.Dept_Name
from stud s,Department d
where s.Dept_id=d.Dept_Id and d.Dept_id=@DeptID

execute StudentInfo_ByDepartment 10
-------------------------------------------------------------
create proc GetGrades_ByID @id int 
as
select st.st_fname,sc.Grade , c.Crs_Name
from stud st,Stud_Course sc , Course c
where st.St_id=sc.St_Id and st.St_id=@id and sc.Crs_Id=c.Crs_Id

execute GetGrades_ByID 10

--------------------------------------------------------------
create proc Courses_NumOfStudents_ByInsID @id int
as
select c.Crs_Name , count (sc.St_Id) as [number of students]
from Ins_Course ic , Stud_Course sc , Course c
where ic.Crs_Id=sc.Crs_Id and sc.Crs_Id = c.Crs_Id and ic.Ins_Id = @id
group by sc.Crs_Id , c.Crs_Name

exec Courses_NumOfStudents_ByInsID 3

-------------------------------------------------------------
create or alter procedure Topics_ByCrsID @id int 
as
select t.Top_Name 
from Course c , Topic t 
where c.Top_Id=t.Top_Id and c.Crs_Id=@id

exec Courses_NumOfStudents_ByInsID 2

--------------------------------------------------------------

