CREATE TYPE grades_level AS ENUM ('U', '3', '4', '5');

-- 1. Departments(_name_, abbreviation)
--   abbreviation Unique
CREATE TABLE Departments(
	name TEXT, 
	abbreviation TEXT NOT NULL,
	PRIMARY KEY (name), 
	UNIQUE (abbreviation)
);

-- 2. Programs(_name_, abbreviation)
CREATE TABLE Programs(
	name TEXT, 
	abbreviation TEXT NOT NULL,
	PRIMARY KEY (name)
);

-- 3. ProgramDepartments(_dname_, _pname_)
--   dname → Departments.name
--   pname → Programs.name
CREATE TABLE ProgramDepartments(
	dname TEXT,
	pname TEXT, 
	PRIMARY KEY (dname, pname),
	FOREIGN KEY (dname) REFERENCES Departments,
	FOREIGN KEY (pname) REFERENCES Programs
);

-- 4. Students(_idnr_, name, login, program)
CREATE TABLE Students(
	idnr CHAR(10), 
	name TEXT NOT NULL,
	login TEXT NOT NULL,
	program TEXT NOT NULL, 
	PRIMARY KEY (idnr),
	FOREIGN KEY (program) REFERENCES Programs,
	UNIQUE (login),
	UNIQUE (idnr, program)
);

-- 5. Branches(_name_, _program_)
-- 	 program → Programs.name
CREATE TABLE Branches(
	name TEXT,
	program TEXT,
	PRIMARY KEY (name ,program),
	FOREIGN KEY (program) REFERENCES Programs
);

-- 6. Courses(_code_, name, credits, department)
CREATE TABLE Courses(
	code CHAR(6), 
	name TEXT NOT NULL,
	credits NUMERIC NOT NULL,
	CHECK (credits >= 0), -- The credits of a course should be positive
	department TEXT NOT NULL,
	PRIMARY KEY (code),
	FOREIGN KEY (department) REFERENCES Departments
);

-- 7. Prerequisite(_course_, _requiredcourse_)
--   course → Course.code
--   requiredcourse → Course.code
CREATE TABLE Prerequisite(
	course CHAR(6), 
	requiredcouurse CHAR(6),
	PRIMARY KEY (course, requiredcouurse),
	FOREIGN KEY (course) REFERENCES Courses, 
	FOREIGN KEY (requiredcouurse) REFERENCES Courses
);

-- 8. LimitedCourses(_code_, capacity) 
-- 		code → Courses.code
CREATE TABLE LimitedCourses(
	code CHAR(6), 
	capacity INTEGER NOT NULL,
	CHECK (capacity >= 0), -- The capacity of a course should be positive
	PRIMARY KEY (code),
	FOREIGN KEY (code) REFERENCES Courses
);


-- 9. StudentBranches(_student_, branch, program)
-- 		student → Students.idnr 
-- 		(branch, program) → Branches.(name, program)
CREATE TABLE StudentBranches(
	student TEXT, 
	branch TEXT NOT NULL, 
	program TEXT NOT NULL, 
	PRIMARY KEY (student),
	-- UNIQUE (student, branch),
	FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

-- 10. Classifications(_name_)
CREATE TABLE Classifications(
	name TEXT, 
	PRIMARY KEY (name)
);

-- 11. Classified(_course_, _classification_)
-- 		course → courses.code 
-- 		classification → Classifications.name
CREATE TABLE Classified(
	course CHAR(6), 
	classification TEXT, 
	PRIMARY KEY (course, classification),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (classification) REFERENCES Classifications
);

-- 12. MandatoryProgram(_course_, _program_)
-- 		course → Courses.code
CREATE TABLE MandatoryProgram(
	course CHAR(6), 
	program TEXT, 
	PRIMARY KEY (course, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (program) REFERENCES Programs
);

-- 13. MandatoryBranch(_course_, _branch_, _program_)
-- 		course → Courses.code 
-- 		(branch, program) → Branches.(name, program)
CREATE TABLE MandatoryBranch(
	course CHAR(6), 
	branch TEXT, 
	program TEXT,
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

-- 14. RecommendedBranch(_course_, _branch_, _program_)
-- 		course → Courses.code 
-- 		(branch, program) → Branches.(name, program)
CREATE TABLE RecommendedBranch(
	course CHAR(6), 
	branch TEXT, 
	program TEXT,
	PRIMARY KEY (course, branch, program),
	FOREIGN KEY (course) REFERENCES Courses,
	FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

-- 15. Registered(_student_, _course_)
-- 		student → Students.idnr 
-- 		course → Courses.code
CREATE TABLE Registered(
	student TEXT, 
	course CHAR(6),
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Courses
);

-- 16. Taken(_student_, _course_, grade)
-- 		student → Students.idnr 
-- 		course → Courses.code
CREATE TABLE Taken(
	student TEXT, 
	course CHAR(6),
	grade grades_level NOT NULL,
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Courses
);

-- position is either a SERIAL, a TIMESTAMP or the actual position 
-- 17. WaitingList(_student_, _course_, position) 
-- 		student → Students.idnr 
-- 		course → Limitedcourses.code
-- 		(course, position) Unique
CREATE TABLE WaitingList(
	student TEXT, 
	course CHAR(6),
	position SERIAL,
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students,
	FOREIGN KEY (course) REFERENCES Limitedcourses,
	UNIQUE (course, position)
);


-----------------------------------------------------------------------------------------

-- INSERTS

INSERT INTO Departments VALUES ('Dept1','D1');

INSERT INTO Programs VALUES ('Prog1','P1');
INSERT INTO Programs VALUES ('Prog2','P2');

INSERT INTO ProgramDepartments VALUES ('Dept1', 'Prog1');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Students VALUES ('7777777777','Nx','ls7','Prog2');
INSERT INTO Students VALUES ('8888888888','N8','ls8','Prog2');
INSERT INTO Students VALUES ('9999999999','N9','ls9','Prog2');
INSERT INTO Students VALUES ('1111111110','N10','ls10','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dept1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dept1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dept1');
INSERT INTO Courses VALUES ('CCC444','C4',40,'Dept1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dept1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
INSERT INTO LimitedCourses VALUES ('CCC444',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');

INSERT INTO Prerequisite VALUES ('CCC111','CCC222');
INSERT INTO Prerequisite VALUES ('CCC333','CCC444');
INSERT INTO Prerequisite VALUES ('CCC444','CCC555');

INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC555', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');


INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');
INSERT INTO Taken VALUES('4444444444','CCC555','5');

INSERT INTO Taken VALUES('5555555555','CCC333','5');
INSERT INTO Taken VALUES('5555555555','CCC444','5');
INSERT INTO Taken VALUES('5555555555','CCC555','5');

INSERT INTO Taken VALUES('1111111111','CCC555','U');
INSERT INTO Taken VALUES('2222222222','CCC555','5');
INSERT INTO Taken VALUES('3333333333','CCC555','5');
INSERT INTO Taken VALUES('6666666666','CCC555','5');
INSERT INTO Taken VALUES('7777777777','CCC555','5');
INSERT INTO Taken VALUES('8888888888','CCC555','5');
INSERT INTO Taken VALUES('9999999999','CCC555','5');
INSERT INTO Taken VALUES('1111111110','CCC555','5');
------------------------------------------------------------------------------------------

-- VIEWS

-- THIS file is used to create all required views
/* View: BasicInformation(idnr, name, login, program, branch)
For all students, their national identification number, name, login, 
their program and the branch (if any). 
The branch column is the only column in any of the views that is allowed to contain NULL. */
CREATE VIEW BasicInformation AS(
	SELECT idnr, name, login, Students.program, branch
	FROM Students FULL OUTER JOIN StudentBranches
	ON (idnr = student)
);

/* View: FinishedCourses(student, course, grade, credits) 
For all students, all finished courses, along with their codes, grades (grade 'U', '3', '4' or '5') 
and number of credits. 
The type of the grade should be a character type, e.g. CHAR(1). */
CREATE VIEW FinishedCourses AS(
	SELECT student, course, grade, credits
	FROM Taken LEFT OUTER JOIN Courses
	ON (course = code)
);

/* View: PassedCourses(student, course, credits) 
For all students, all passed courses, i.e. courses finished with a grade other than 'U', 
and the number of credits for those courses. This view is intended as a helper view towards 
later views (and for task 4), 
and will not be directly used by your application. */
CREATE VIEW PassedCourses AS(
	SELECT student, course, credits
	FROM FinishedCourses
	WHERE grade != 'U'
);

/* View: Registrations(student, course, status) 
All registered and waiting students for all courses, along with their waiting status 
('registered' or 'waiting'). */
CREATE VIEW Registrations AS(
	SELECT student, course, status
	FROM (SELECT student, course, 'registered' AS status FROM Registered
		UNION
		SELECT student, course, 'waiting' AS status FROM WaitingList) AS U
);

/* View: UnreadMandatory(student, course) 
For all students, the mandatory courses (branch and program) they have not yet passed. 
This view is intended as a helper view towards the PathToGraduation view, 
and will not be directly used by your application.*/
CREATE VIEW UnreadMandatory AS(
	WITH AllMandatoryCourses AS(
		SELECT student, course
		FROM (SELECT idnr AS student, course
			FROM BasicInformation FULL OUTER JOIN MandatoryProgram
			USING (program)) AS MPC 
			FULL OUTER JOIN
			(SELECT idnr AS student, course
			FROM BasicInformation FULL OUTER JOIN MandatoryBranch
			USING (program, branch)) AS MBC
			USING (student, course)
		), 
	AllPassedCourse AS(
		SELECT student, course
		FROM PassedCourses
		)
	SELECT student, course 
	FROM ((SELECT student, course FROM AllMandatoryCourses WHERE course IS NOT NULL)
		EXCEPT
		(SELECT student, course FROM AllPassedCourse)) AS UR
);

/* View: PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, 
seminarCourses, qualified) 
For all students, their path to graduation, i.e. a view with columns for 
	- student: the student's national identification number.
	- totalCredits: the number of credits they have taken.
	- mandatoryLeft: the number of courses that are mandatory for a branch or a program 
	they have yet to read.
	- mathCredits: the number of credits they have taken in courses that are classified as math courses.
	- researchCredits: the number of credits they have taken in courses that are classified 
	as research courses.
	- seminarCourses: the number of seminar courses they have read.
	- qualified: whether or not they qualify for graduation. The SQL type of this field 
	should be BOOLEAN (i.e. TRUE or FALSE).*/
CREATE VIEW PathToGraduation AS(
	WITH 
	-- one column of all students' ID
	StuID AS(
		SELECT idnr AS student FROM Students
	), 
	-- course list with corresponding credits 
	course_and_credit AS(
		SELECT code AS course, credits 
		FROM Courses
	), 
	-- add each course's credit into PassesCourses
	PassedCoursesWithCredits AS(
		SELECT * 
		FROM (SELECT student, course FROM PassedCourses) AS PC 
		NATURAL JOIN course_and_credit
	), 
	-- For the first column in the last view
	_totalCredits AS(
		SELECT student, SUM(credits) AS totalcredits
		FROM PassedCoursesWithCredits
		GROUP BY student
	), 
	-- For the second column in the last view
	_mandatoryleft AS(
		SELECT student, COUNT(course) AS mandatoryleft
		FROM UnreadMandatory
		GROUP BY student
	), 
	-- All math courses
	_mathCourses AS(
		SELECT course 
		FROM (SELECT * FROM Classified WHERE classification = 'math') AS mathcourses
	),
	-- All research courses
	_researchCourses AS(
		SELECT course 
		FROM (SELECT * FROM Classified WHERE classification = 'research') AS researchCourses
	),
	-- All seminar courses
	_seminarCourses AS(
		SELECT course 
		FROM (SELECT * FROM Classified WHERE classification = 'seminar') AS seminarCourses
	),
	-- Sum of all math credits for students who have read and passed math courses
	_mathCredits AS(
		SELECT student, SUM(credits) AS mathcredits 
		FROM (SELECT * FROM PassedCourses NATURAL JOIN _mathCourses) AS passedMathCourses
		GROUP BY student
	), 
	-- Sum of all research credits for students who have read and passed research courses
	_researchCredits AS(
		SELECT student, SUM(credits) AS researchcredits 
		FROM (SELECT * FROM PassedCourses NATURAL JOIN _researchCourses) AS passedResearchCourses
		GROUP BY student
	), 
	-- Number of all seminar courses for students who have read and passed seminar courses
	_seminarCoursesNum AS(
		SELECT student, COUNT(credits) AS seminarcourses 
		FROM (SELECT * FROM PassedCourses NATURAL JOIN _seminarCourses) AS passedSeminarCourses
		GROUP BY student
	), 
	
	-- This part is used to judge the qualfication to graduate
	_qualfiedStudents AS(
		WITH 
		-- Student have passed all mandatory courses
		AllPassedStudents AS(
			SELECT student
			FROM ((SELECT student FROM StuID) 
				EXCEPT (SELECT student FROM _mandatoryleft)) AS AllPassedStudents
		),
		-- Students who fullfill math courses' requirement
		MathQualfiedStudents AS(
			SELECT student
			FROM _mathCredits
			WHERE mathcredits >= 20
		),
		-- Students who fullfill research courses' requirement
		ResearchQualfiedStudents AS(
			SELECT student
			FROM _researchCredits
			WHERE researchcredits >= 10
		),
		-- Students who fullfill seminar courses' requirement
		SeminarQualfiedStudents AS(
			SELECT student
			FROM _seminarCoursesNum
			WHERE seminarcourses >= 1
		), 
		
		-- The following module is to decide tte qualification of students regarding recommended courses
		RecommendQualifiedStudents AS(
		WITH 
		-- All passed courses which is also belongs to recommend course of all branches
		AllpassedRecommended AS(
			SELECT * 
			FROM PassedCourses JOIN RecommendedBranch 
			USING (course)
		), 
		-- Only the matched (which is extactly included in this student's program and his branch's 
		-- recommend course list)
		MatchedRecommended AS(
			SELECT *
			FROM StudentBranches JOIN AllpassedRecommended
			USING (student, branch, program)
		), 
		-- SUM UP each student's earned credits from taking efficient recommended course. 
		RecommandedCredits AS(
			SELECT student, SUM(credits) AS recommandedcredits 
			FROM MatchedRecommended
			GROUP BY student
		)
		SELECT student
		FROM RecommandedCredits
		WHERE (recommandedcredits >= 10)
		)
		
		-- Students who fullfill all requirements to graduate
		SELECT student, TRUE AS qualified
		FROM (SELECT student FROM
			 (SELECT student FROM
			 (SELECT student FROM
			 ((SELECT student FROM AllPassedStudents) INTERSECT (SELECT student 
			 	FROM MathQualfiedStudents)) AS step1
			 INTERSECT (SELECT student FROM ResearchQualfiedStudents)) AS step2
			 INTERSECT (SELECT student FROM SeminarQualfiedStudents)) AS step3
			 INTERSECT (SELECT student FROM RecommendQualifiedStudents)) AS step4
	)
	SELECT 	student, 
			COALESCE(totalcredits, 0) AS totalcredits, 
			COALESCE(mandatoryleft, 0) AS mandatoryleft, 
			COALESCE(mathcredits, 0) AS mathcredits, 
			COALESCE(researchcredits, 0) AS researchcredits, 
			COALESCE(seminarcourses, 0) AS seminarcourses, 
			COALESCE(qualified, FALSE) AS qualified 
	FROM 	((((((StuID NATURAL FULL OUTER JOIN _totalCredits) AS firstCol 
			NATURAL FULL OUTER JOIN _mandatoryleft) AS secondCol
			NATURAL FULL OUTER JOIN _mathCredits) AS thirdCol
			NATURAL FULL OUTER JOIN _researchCredits) AS forthCol
			NATURAL FULL OUTER JOIN _seminarCoursesNum) AS fifthCol
			NATURAL FULL OUTER JOIN _qualfiedStudents) AS sixthCol
);


CREATE VIEW CourseQueuePositions AS(
	SELECT course, student, position AS place
	FROM WaitingList
);


------------------------------------------------------------------------------------------

-- Triggers

CREATE FUNCTION registration_function() RETURNS TRIGGER AS $$
	DECLARE 
		cnt INTEGER;
		cap INTEGER;
		pos INTEGER;
		numofprereq INTEGER;
	BEGIN
		IF (EXISTS (SELECT student, course FROM PassedCourses WHERE course=NEW.course AND student=NEW.student)) THEN
			RAISE EXCEPTION 'Student % has already passed the course %', NEW.student, NEW.course;
		
		ELSIF (EXISTS (SELECT student, course FROM Registered WHERE course=NEW.course AND student=NEW.student)) THEN
			RAISE EXCEPTION 'Student % has already registered the course %', NEW.student, NEW.course;
		
		ELSIF (EXISTS (SELECT student, course FROM Waitinglist WHERE course=NEW.course AND student=NEW.student)) THEN
			SELECT position INTO pos FROM Waitinglist WHERE course=NEW.course AND student=NEW.student;
			RAISE EXCEPTION 'Student % are already in the course % waiting list position %', 
						NEW.student, NEW.course, pos;
		
		ELSIF (EXISTS (SELECT requiredcouurse FROM Prerequisite WHERE course=NEW.course 
						EXCEPT SELECT course FROM PassedCourses WHERE student=NEW.student)) THEN
			RAISE EXCEPTION 'Student % does not fullfill the course % requirement', NEW.student, NEW.course;
		
		ELSIF (EXISTS (SELECT * FROM LimitedCourses WHERE code=NEW.course)) THEN
			SELECT COUNT(*) INTO cnt FROM Registered WHERE course=NEW.course;
			SELECT capacity INTO cap FROM LimitedCourses WHERE code=NEW.course;
			
			IF (cnt >= cap) THEN
				IF (EXISTS(SELECT * FROM WaitingList WHERE course=NEW.course)) THEN
					SELECT COUNT(*) INTO pos FROM WaitingList WHERE course=NEW.course;
					INSERT INTO WaitingList VALUES (NEW.student, NEW.course, pos+1);
				ELSE
					INSERT INTO WaitingList VALUES (NEW.student, NEW.course, 1);
				END IF;
				
			ELSE
				INSERT INTO Registered VALUES (NEW.student, NEW.course);
			END IF;
		
		ELSE
			INSERT INTO Registered VALUES (NEW.student, NEW.course);
		END IF;

		RETURN NEW;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER registration 
	INSTEAD OF INSERT ON Registrations
	FOR EACH ROW 
	EXECUTE PROCEDURE registration_function();



CREATE FUNCTION unregistration_function() RETURNS TRIGGER AS $$
	DECLARE
		pos INTEGER;
		cnt INTEGER;
		cap INTEGER;
		stu TEXT;
	BEGIN
		IF NOT (EXISTS (SELECT * FROM Registrations WHERE student=OLD.student AND course=OLD.course))
			AND NOT (EXISTS (SELECT * FROM Registered WHERE student=OLD.student AND course=OLD.course)) THEN
			RAISE EXCEPTION 'Student % has not registered course %', NEW.student, NEW.course;
		
		ELSIF (EXISTS (SELECT * FROM WaitingList WHERE student=OLD.student AND course=OLD.course)) THEN
			SELECT position INTO pos FROM WaitingList WHERE student=OLD.student AND course=OLD.course;
			DELETE FROM WaitingList WHERE student=OLD.student AND course=OLD.course;
			UPDATE WaitingList SET position=position-1 WHERE position>=pos AND course=OLD.course;
		
		ELSIF (EXISTS (SELECT * FROM Registered WHERE student=OLD.student AND course=OLD.course)) THEN
			DELETE FROM Registered WHERE student=OLD.student AND course=OLD.course;
			
			
			IF (EXISTS (SELECT * FROM LimitedCourses WHERE code=OLD.course)) THEN
				SELECT COUNT(*) INTO cnt FROM Registered WHERE course=OLD.course;
				SELECT capacity INTO cap FROM LimitedCourses WHERE code=OLD.course;
				IF (cnt<cap) AND EXISTS (SELECT * FROM Waitinglist WHERE course=OLD.course) THEN
					SELECT student INTO stu FROM WaitingList WHERE position=1 AND course=OLD.course;
					DELETE FROM WaitingList WHERE position=1 AND course=OLD.course;
					INSERT INTO Registered VALUES (stu, OLD.course);
					UPDATE WaitingList SET position=position-1 WHERE course=OLD.course;
				END IF;
			END IF;
		END IF;
	RETURN OLD;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unregistration 
	INSTEAD OF DELETE ON Registrations
	FOR EACH ROW 
	EXECUTE PROCEDURE unregistration_function();

------------------------------------------------------------------------------------------
-- For Testing web 

INSERT INTO Registrations VALUES ('6666666666', 'CCC444');
INSERT INTO Registrations VALUES ('7777777777', 'CCC444');
INSERT INTO Registrations VALUES ('8888888888', 'CCC444');
INSERT INTO Registered VALUES ('9999999999', 'CCC444');


SELECT student, course, status FROM Registrations;

