📘 README – HRMS SQL Query Concepts
🧠 Covered SQL Techniques
Scalar Subqueries

Used to compute single values like AVG(salary) or MAX(salary) and compare or display them.

Appears in SELECT or WHERE clauses, returning one scalar value (e.g., comparing salary to company average) 

Correlated Subqueries

Subqueries referencing outer query columns (e.g., computing average per location or department).


EXISTS

Checks for the presence of rows in a subquery, acting as a boolean test (true/false).

Efficient for existence-check logic without returning data 

Derived Tables (FROM Clause Subqueries)

Inner queries aliased and used as temporary tables in the FROM clause.

Helps structure complex logic or pre-aggregate data 


IN Clause with Subqueries

Used to match against a list of values returned by an inner query.

You said:
select * from leave_request where location = (select * from leave_request where status="Approve");

error de raha hai solution


ChatGPT said:
Aapko jo error aa raha hai, wo isliye ho raha hai kyunki aap:

sql
Copy
Edit
select * from leave_request
where location = (
    select * from leave_request
    where status = "Approve"
);
mein subquery me select * ka use kar rahe hain — jo multiple columns return karta hai. Lekin = operator sirf ek hi value (scalar) accept karta hai. Isliye DBMS complain karta hai.

🔧 Do common solutions yeh problem solve karti hain:
1. IN operator ka use karke (multiple values ke liye)
Agar aap sirf location ke liye match karna chahte ho jahan status "Approve" hai, to aisa karein:

sql
Copy
Edit
SELECT *
FROM leave_request
WHERE location IN (
  SELECT location
  FROM leave_request
  WHERE status = 'Approve'
);
Yeh sahi hai: subquery sirf ek column (location) return karegi — phir IN us list ke against match karega.

2. =` operator ke sath ek single value chahiye ho to
Agar sirf latest ya koi specific location chahiye, to subquery me LIMIT ya koi aggregation lagana jaroori hai. Example:

sql
Copy
Edit
SELECT *
FROM leave_request
WHERE location = (
  SELECT TOP 1 location
  FROM leave_request
  WHERE status = 'Approve'
  ORDER BY request_date DESC
);
SQL Server me TOP 1

MySQL me LIMIT 1 use karein

Ya agar sab se oldest chahiye:

sql
Copy
Edit
... WHERE location = (
  SELECT location
  FROM leave_request
  WHERE status = 'Approve'
  ORDER BY request_date ASC
  LIMIT 1
);
✅ Summary:
= — tabhi use karo jab subquery se exactly 1 value return ho.

IN (...) — tab use karo jab multiple values match karna ho.

Agar using =, to ensure karo subquery me ORDER BY + LIMIT/TOP 1, ya koi aggregation ho jisse ek hi row return ho.

Agar aapka DBMS, query aur requirement bataenge, to main exact syntax bhi bata sakta hoon. Kaunsa DB engine (MySQL, SQL Server, Postgres, etc.) use kar rahe hain?









Sources
You said:
isme = operator ka use karke subquery karoo


ChatGPT said:
Agar aap = operator ke saath exactly ek value chahte ho jo subquery se aaye, to subquery ko scalar banana zaroori hai. Iska matlab hai subquery se sirf ek hi row return ho — LIMIT 1, TOP 1, ya koi aggregation jaisa MAX() ya MIN().

Yaha kuch common SQL dialects ke examples hain:

✅ MySQL / MariaDB
sql
Copy
Edit
SELECT *
FROM leave_request
WHERE location = (
  SELECT location
  FROM leave_request
  WHERE status = 'Approve'
  ORDER BY request_date DESC
  LIMIT 1
);
ORDER BY ... DESC se sabse latest approve hua location milta hai.

LIMIT 1 ensure karta hai ki subquery sirf ek value return kare. 
cockroachlabs.com
+14
datacamp.com
+14
docs.snowflake.com
+14

✅ SQL Server (T-SQL)
sql
Copy
Edit
SELECT *
FROM leave_request
WHERE location = (
  SELECT TOP 1 location
  FROM leave_request
  WHERE status = 'Approve'
  ORDER BY request_date DESC
);
Yahan TOP 1 use hua hai LIMIT ke jagah.

✅ PostgreSQL / Oracle
sql
Copy
Edit
SELECT *
FROM leave_request
WHERE location = (
  SELECT location
  FROM leave_request
  WHERE status = 'Approve'
  ORDER BY request_date DESC
  FETCH FIRST 1 ROW ONLY
);
🧐 Agar aap sab approved locations chahte ho (multiple), to IN use karo:
sql
Copy
Edit
SELECT *
FROM leave_request
WHERE location IN (
  SELECT location
  FROM leave_request
  WHERE status = 'Approve'
);
🔍 TL;DR:
= tab use karo jab subquery se exactly 1 row aaye.

Uske liye use karo LIMIT 1, TOP 1, ya FETCH FIRST 1 ROW ONLY dialect ke hisaab se.

Agar multiple values chahiyein, to IN (...) use karo.

✨ Aap kaunsa database engine (MySQL / SQL Server / PostgreSQL, etc.) use kar rahe ho? Isse main exact syntax aur tweaks bata sakta hoon.










Sources
You said:
from use karke subquery likho


ChatGPT said:
Aap FROM clause mein subquery (derived table) ka use karke bhi kaam kar sakte hain, jisse aap query ko structured aur clear bana sakte hain. Yeh ek powerful approach hota hai jab aapko intermediate result ko reuse karna ho.

🛠️ Example: leave_request table mein subquery within FROM
Suppose aapko un locations ko select karna hai jahan last "Approve" status wala leave request hua hai, aur phir ussi location ke saare leave requests dekhne hain. Aap yeh query aise likh sakte hain:

sql
Copy
Edit
SELECT lr.*
FROM leave_request AS lr
JOIN (
  SELECT location, MAX(request_date) AS last_approved_date
  FROM leave_request
  WHERE status = 'Approve'
  GROUP BY location
) AS sub
  ON lr.location = sub.location
-- aur agar sirf last approved record chahiye ho to:
-- AND lr.request_date = sub.last_approved_date
;
Is query ka breakdown:
Subquery (sub):

Har ek location ke liye sabse badi (latest) request_date find karta hai jiska status = 'Approve' hai.

Isme GROUP BY location ke saath MAX(request_date) use kiya gaya hai 
ibm.com
+3
dba.stackexchange.com
+3
medium.com
+3
ibm.com
+1
databaserookies.wordpress.com
+1
.

Outer query:

leave_request table ko sub se join kiya gaya hai on location.

Isse aap un sab leave_requests ki details le sakte hain un locations ke jaha recent approved leave hua hai.

Optional filter:

Agar aap sirf latest approved record chahiye ho, to ON clause mein lr.request_date = sub.last_approved_date bhi add kar sakte hain.

🎯 Ek simple aur direct FROM-based scalar query:
Agar sirf ek location chahiye jiska sabse latest approved record mila hai, to subquery ko FROM ke through alias ke saath scalar bana kar aise kar sakte hain:

sql
Copy
Edit
SELECT lr.*
FROM leave_request AS lr
JOIN (
  SELECT location
  FROM leave_request
  WHERE status = 'Approve'
  ORDER BY request_date DESC
  LIMIT 1
) AS subloc
  ON lr.location = subloc.location
;
Yahan subquery se sirf ek value return hogi: wo location jisme status “Approve” ka sabse recent request hai.

FROM subquery ke baad alias subloc zaroori hai .

📝 Summary / TL;DR
Concept	Usecase	Syntax Feature
Scalar value using =	Agar aap chahte hain ek hi location/use-case ho to use FROM-subquery ke saath JOIN	ORDER BY … LIMIT 1
Multiple results / per-location logic	Agar multiple locations me per-location stats chahiye to GROUP BY + JOIN	GROUP BY location, MAX(request_date)
Alias ka use	Har subquery ko AS alias ke saath dena zaroori hota hai jo temporary table ko reference kar sake 
docs.actian.com
+1
databaserookies.wordpress.com
+1
mode.com
) AS sub

Aap apne use case ke hisaab se in approaches mein se choose kar sakte hain—chahe aapko sirf ek location ki details chahiye ho ya saari locations ke latest approved requests chahiye ho. Agar aap bata dein kaunsa database (MySQL, PostgreSQL, etc.) aap use kar rahe hain, to main exact syntax adjust bhi karke de sakta hoon!












Sources
You said:
use employees table


ChatGPT said:
Yahan aap employees table ka example dekh sakte hain jisme hum FROM clause mein subquery use karke ek specific location wala employee select karte hain—simply us location ke saare employees dikhane ke liye jahan sabse recent join hua hai.

🛠 1. Ek employee table ka schema (example ke liye)
Column	Description
employee_id	Employee ka unique ID
name	Employee ka naam
location	Unka location
status	e.g. 'Active', 'Leave', etc.
hire_date	Join hone ki date

🎯 Goal:
Sabse recent join hone wale 'Active' employee ke location mein kaun kaun employees hai, un sab ko list karo.

✅ Step 1: Subquery – sabse recent hire_date find karo jisme status = 'Active'
sql
Copy
Edit
SELECT location, MAX(hire_date) AS last_hire_date
FROM employees
WHERE status = 'Active'
✅ Step 2: Is subquery ko FROM se aliased table mein convert karo
sql
Copy
Edit
FROM (
  SELECT location, MAX(hire_date) AS last_hire_date
  FROM employees
  WHERE status = 'Active'
) AS sub
✅ Step 3: Outer query mein employees table ko join karo sub ke saath
sql
Copy
Edit
SELECT e.*
FROM employees AS e
JOIN (
  SELECT location, MAX(hire_date) AS last_hire_date
  FROM employees
  WHERE status = 'Active'
) AS sub
  ON e.location = sub.location
WHERE e.hire_date = sub.last_hire_date
  AND e.status = 'Active';
Explanation:

sub mein har location ke liye sabse latest Active joining date aati hai.

Outer JOIN se employees table se woh employee rows milti hain jin ki hire_date is maximum date ke barabar hai, same location aur status match hone par.

🛠 2. Agar sirf ek scalar location chahiye ho (jahan sabse recent join hua hai):
sql
Copy
Edit
SELECT e.*
FROM employees AS e
JOIN (
  SELECT location
  FROM employees
  WHERE status = 'Active'
  ORDER BY hire_date DESC
  LIMIT 1
) AS subloc
  ON e.location = subloc.location
WHERE e.status = 'Active';
LIMIT 1 ensure karta hai ki subquery se sirf ek location nikle (jisme sabse recent join hua hai).

JOIN ke through aap us location ke sabhi current (status = 'Active') employees fetch kar lete hain.

✅ Summary:
Derived table (FROM (… ) AS alias) use karke aap complex intermediate results calculate kar sakte hain.

Scalar result ke liye LIMIT 1 (MySQL/Postgres) ya TOP 1 (SQL Server).

Agar multiple locations ko handle karna hai (per-location aggregation), to use karo GROUP BY location + aggregation + join.

Agar aap specific DB engine (MySQL/PostgreSQL/SQL Server) use kar rahe hain, to dialect-specific syntax (e.g. TOP, LIMIT, FETCH FIRST) adjust karke batayein—main tailor kar doonga.

Agar main schema mein kuch aur tweak karu ya aap test data share karo, to main uske according bhi query bana sakta hoon!









Sources
You said:
select manager_id,location from(select location from manager) where location='delhi';

correct this it gives error


ChatGPT said:
Aapka original query is tarah se hai:

sql
Copy
Edit
SELECT manager_id, location
FROM (
  SELECT location
  FROM manager
) 
WHERE location = 'delhi';
Isme kuch issues hain:

Outer query FROM subquery me manager_id column available nahi hai — kyunki subquery sirf location return kar rahi hai.

Subquery ko alias dena zaroori hai (derived table ke liye).

Agar aap manager_id bhi use karna chahte hain, to woh subquery ya join me include karna hoga.

✅ Sahi syntax
A. Agar sirf location = 'delhi' wale managers chahiye hain:
sql
Copy
Edit
SELECT manager_id, location
FROM manager
WHERE location = 'delhi';
Yeh direct query hai, specific subquery ki zaroorat nahi — simple aur efficient.

B. Agar aap subquery (derived table) use karna chahte hain:
sql
Copy
Edit
SELECT m.manager_id, sub.location
FROM manager AS m
JOIN (
  SELECT DISTINCT location
  FROM manager
) AS sub
  ON m.location = sub.location
WHERE sub.location = 'delhi';
Inner subquery sirf distinct locations nikalegi.

Outer query se m.manager_id, sub.location match karke delhi wale records laayega.

Subquery ko alias sub diya gaya — ye required hai (per SQL rules) 
kamleshsingad.com
+4
reddit.com
+4
sqlshack.com
+4
reddit.com
+15
geeksforgeeks.org
+15
stackoverflow.com
+15
simmanchith.com
.

C. Simplest WITH subquery (CTE) approach:
sql
Copy
Edit
WITH locs AS (
  SELECT DISTINCT location
  FROM manager
)
SELECT m.manager_id, m.location
FROM manager m
JOIN locs
  ON m.location = locs.location
WHERE locs.location = 'delhi';
Yeh bhi derived result create karta hai pehle, then outer query filter karta hai.

⚠️ TL;DR
Agar sirf location = 'delhi' ki need hai, to simple WHERE query best:

sql
Copy
Edit
SELECT manager_id, location
FROM manager
WHERE location = 'delhi';
Agar aapko subquery se derived table banana hai:

Subquery mein woh sab columns hon jo outer query me chahiyein (e.g., location, manager_id).

Or alias zaroor use karein.

Example:

sql
Copy
Edit
SELECT sub.manager_id, sub.location
FROM (
  SELECT manager_id, location
  FROM manager
) AS sub
WHERE sub.location = 'delhi';
Yeh last query aapke subquery request aur manager_id fetch karne ki need, dono ko satisfy karti hai.

Agar aap dialect (MySQL/PostgreSQL/SQL Server) bata dein, to main exact syntax tweak karke de sakta hoon!












Sources
You said:
# Human Resource management system database

### Task 6 ###
use hrms;

#query within query
select manager_name,salary,(select avg(salary) from manager) as average_salary from manager;

select first_name, salary from employees where salary > (select avg(salary) from employees);

select max(salary) from employees where salary <> (select max(salary) from employees); 

select location from leave_request where emp_id = (select * from leave_request where location="mumbai");

select manager_id, manager_name,salary from manager where salary = (select max(salary) from manager);

select emp.first_name,emp.salary,(select avg(salary) from employees) AS avg_company_salary from employees emp;

select emp.first_name,emp.salary,(select avg(salary) from employees) AS avg_company_salary from employees emp;

select mgr.manager_name,mgr.salary,(select avg(salary) from manager where location = mgr.location) as avg_company_salary from manager mgr;

select manager_name,salary,(select avg(salary) from manager) as average_salary from manager where salary < (select avg(salary) from manager);

select location from department where dept_id = (select dept_name from department where dept_name="rose" or dept_name="gold");

#exists

select manager_name from manager where exists (select location from manager where location="mumbai");

select * from leave_request where exists (select * from leave_request where location="mumbai");


#From

select mgr.manager_id,mgr.location from(select  manager_id, location from manager) as mgr where mgr.location='delhi';

select lr.emp_id,lr.dept_id,lr.location,lr.status from(select emp_id,dept_id,location,status from leave_request) as lr where status="Approve";

#IN

select dept_id, dept_name,location from department where dept_name in (select dept_name from department where location in ('delhi','mumbai'));

select manager_name,location from manager where manager_id in (select manager_id from manager where location = 'Mumbai');

write what you do and concept readme file


ChatGPT said:
ज़रूर! नीचे एक README.md का ड्राफ्ट दिया गया है जो बताएगा कि प्रत्येक SQL query में हमने क्या-क्या concept इस्तेमाल किया है और उनका उद्देश्य क्या है।

📘 README.md
markdown
Copy
Edit
# HRMS Database — SQL Queries Guide

इस document में HRMS (Human Resource Management System) database के विभिन्न queries और उनमें उपयोग किए गए SQL concepts को explain किया गया है।

---

## 🏷️ Task 6 — Queries Overview

### 1. Query within a query (Subquery in SELECT or WHERE)

```sql
select manager_name, salary,
       (select avg(salary) from manager) as average_salary
from manager;
Concept: Scalar subquery in SELECT.

Purpose: हर manager के साथ कुल managers का average salary दिखाया गया है।

sql
Copy
Edit
select first_name, salary
from employees
where salary > (select avg(salary) from employees);
Concept: Scalar subquery in WHERE.

Purpose: उन employees को दिखाता है जिनकी salary कंपनी के average से ज़्यादा है।

sql
Copy
Edit
select max(salary)
from employees
where salary <> (select max(salary) from employees);
Concept: Subquery comparison to find second-highest salary.

Purpose: Employees की highest salary के तुरंत नीचे का salary ढूँढना।

sql
Copy
Edit
select location
from leave_request
where emp_id = (select emp_id from leave_request where location='mumbai');
Concept: Scalar subquery returning emp_id.

Note: Ensure subquery returns only one row, अन्यथा use LIMIT/TOP or aggregation।

sql
Copy
Edit
select manager_id, manager_name, salary
from manager
where salary = (select max(salary) from manager);
Concept: Subquery to get maximum salary among managers.

Purpose: सबसे ज़्यादा salary पाने वाले manager को देखना।

sql
Copy
Edit
select emp.first_name, emp.salary,
       (select avg(salary) from employees) as avg_company_salary
from employees emp;
Duplicate concept with alias usage

Purpose: हर employee के साथ average salary show करना।

sql
Copy
Edit
select mgr.manager_name, mgr.salary,
       (select avg(salary) from manager where location = mgr.location) as avg_company_salary
from manager mgr;
Concept: Correlated subquery.

Purpose: हर manager के लिए उसी location के average manager salary दिखाना।

sql
Copy
Edit
select manager_name, salary,
       (select avg(salary) from manager) as average_salary
from manager
where salary < (select avg(salary) from manager);
Combination: Scalar subqueries in both SELECT and WHERE.

Purpose: वो managers जिनकी salary average से कम है उन्हें दिखाना।

sql
Copy
Edit
select location
from department
where dept_id = (select dept_id from department where dept_name in ('rose','gold'));
Concept: Scalar subquery in WHERE.

Purpose: उन departments की location fetch करना जिनका name 'rose' या 'gold' है।

2. EXISTS Subqueries
sql
Copy
Edit
select manager_name
from manager
where exists (select 1 from manager where location='mumbai');
Concept: EXISTS checks if inner query returns any row.

Purpose: Manager list तभी आएगा जब at least एक manager Mumbai में हो।

sql
Copy
Edit
select *
from leave_request
where exists (select 1 from leave_request where location='mumbai');
Concept: Similar to above.

Purpose: सभी leave_request rows वापस आएंगी यदि कोई भी leave_request Mumbai से हो।

3. Derived Tables (Subquery in FROM)
sql
Copy
Edit
select mgr.manager_id, mgr.location
from (
  select manager_id, location from manager
) as mgr
where mgr.location = 'delhi';
Concept: Subquery in FROM with alias.

Purpose: Delhi के managers को derived table से filter करना।

sql
Copy
Edit
select lr.emp_id, lr.dept_id, lr.location, lr.status
from (
  select emp_id, dept_id, location, status from leave_request
) as lr
where lr.status = 'Approve';
Concept: FROM subquery acting as temp table.

Purpose: Approved leave_requests को derived table से निकालना।

4. IN Clause with Subquery
sql
Copy
Edit
select dept_id, dept_name, location
from department
where dept_name in (
    select dept_name from department
    where location in ('delhi','mumbai')
);
Concept: IN with subquery returning list.

Purpose: उन departments को चुनना जो Delhi या Mumbai में located हैं।

sql
Copy
Edit
select manager_name, location
from manager
where manager_id in (
    select manager_id from manager
    where location = 'Mumbai'
);
Concept: Simple IN query.

Purpose: Mumbai में स्थित managers की details fetch करना।

✅ Summary of SQL Concepts
Concept	Description
Scalar Subquery	Returns exactly one value; used in SELECT, WHERE, HAVING
Correlated Subquery	References outer query alias; executes per row
EXISTS	Checks existence of rows in inner query; efficient boolean check
Derived Table	Subquery in FROM with alias; acts as temporary relation
IN	Checks if value exists in list returned by subquery
Aggregate + Filtering	MAX(), AVG() in subquery; used to filter or compute metrics

ℹ️ Best Practices
Subqueries in WHERE should return one row for = comparisons; else use IN.

Use LIMIT 1, TOP 1, or FETCH FIRST if necessary to enforce single result.

Use correlated subquery if per-row contextual computation is needed.

EXISTS is often more efficient than IN for large datasets where inner query may return many rows.

Derived tables help structure complex queries and improve readability.

✍️ ये document आप अपने HRMS DB में queries को समझने, शेयर करने या maintain करने में मदद करेगा। अगर किसी dialect-specific tweak (MySQL/PostgreSQL/SQL Server आदि) चाहिए तो बताइए, मैं adjust कर दूँगा!

yaml
Copy
Edit

---

यदि आप इसे GitHub README या internal documentation में paste करें तो queries और उनके explanations वहाँ structured तरीके से दिखेंगे। किसी और concept या optimization की जरूरत है तो ज़रूर बताइए!







You said:
code nahi chahiye sirf text kya kya kia aisa


ChatGPT said:
आपने HRMS database में ये महत्वपूर्ण SQL concepts इस्तेमाल किए हैं — बिना code दिखाए, केवल textual रूप में समझाया गया है:

📌 Subquery in SELECT और WHERE (Scalar & Correlated Subqueries)
Scalar Subquery:

एक single value return करती है, जैसे:

(select avg(salary) from manager) — पूरे मास्टर की average salary निकालकर SELECT या WHERE में use की।

(select max(salary) from manager) — maximum salary fetch करके comparison में use किया गया।

= operator के साथ तब use होती है जब subquery से बस एक ही value जुड़ती हो।

Correlated Subquery:

यह outer query के हर row के context में dynamically run होती है।
उदाहरण: (select avg(salary) from manager where location = mgr.location) — हर manager की अपनी location के average salary compute किया गया, outer row mgr.location के अनुसार 
reddit.com
+8
sqltutorial.org
+8
datacamp.com
+8
reddit.com
+4
red-gate.com
+4
w3resource.com
+4
youtube.com
+8
reddit.com
+8
youtube.com
+8
।

✅ EXISTS Subquery
EXISTS (select * …) boolean check है—agar inner query में कोई row return होती है, तो true हो जाता है।

Example: select * from leave_request where exists (select * from leave_request where location='mumbai') — पूरी table return होती है सिर्फ इसलिए कि वीडियो में at least एक row “Mumbai” से exists 
stackoverflow.com
+5
geeksforgeeks.org
+5
stackoverflow.com
+5
।

🧩 Derived Table (FROM में Subquery)
Subquery को alias देकर derived table की तरह use किया गया—जैसे:
from (select …) as mgr — फिर outer query उस से join/filter करती है।

यह technique complex queries को modular और readable बनाती है 
geeksforgeeks.org
+7
red-gate.com
+7
teamtreehouse.com
+7
geeksforgeeks.org
+1
datacamp.com
+1
।

🌀 IN Clause with Subquery
Subquery एक list of values return करती है, जैसे:

where dept_name in (select dept_name …) — multiple matching values allow करने के लिए।

Useful when you want to match against a set of possible values rather than a single one 
youtube.com
+10
dev.mysql.com
+10
sqltutorial.org
+10
teamtreehouse.com
+1
stackoverflow.com
+1
।

📚 Summary of Concepts
Concept	विवरण
Scalar Subquery	Single value return; = में use
Correlated Subquery	Outer row-dependent; per-row execution
EXISTS	Boolean existence check
Derived Table	Subquery in FROM, with alias
IN	List comparison using subquery

ये textual explanation user की needs और सीखे गए कामों के अनुरूप है, बिना actual query code repeat किये—बस concepts और reasoning पर focus रखा गया है।












Sources
You said:
task6.sql
File
give me readme file for this 


ChatGPT said:
Here’s a concise README outlining what you did and which SQL concepts you covered—tailored for sharing or documentation:

📘 README – HRMS SQL Query Concepts
🧠 Covered SQL Techniques
Scalar Subqueries

Used to compute single values like AVG(salary) or MAX(salary) and compare or display them.

Appears in SELECT or WHERE clauses, returning one scalar value (e.g., comparing salary to company average) 
bertwagner.com
+12
datacamp.com
+12
docs.snowflake.com
+12
.

Correlated Subqueries

Subqueries referencing outer query columns (e.g., computing average per location or department).

Executed once per row in the outer query — ideal for per-row calculations 
en.wikipedia.org
+3
en.wikipedia.org
+3
duckdb.org
+3
medium.com
+9
docs.snowflake.com
+9
en.wikipedia.org
+9
.

EXISTS

Checks for the presence of rows in a subquery, acting as a boolean test (true/false).

Efficient for existence-check logic without returning data 
docs.snowflake.com
.

Derived Tables (FROM Clause Subqueries)

Inner queries aliased and used as temporary tables in the FROM clause.

Helps structure complex logic or pre-aggregate data 
struchkov.dev
+15
stackoverflow.com
+15
dataforgelabs.com
+15
datacamp.com
.

IN Clause with Subqueries

Used to match against a list of values returned by an inner query.

Great alternative to multiple OR conditions 
medium.com
+1
docs.snowflake.com
+1
mode.com
+2
docs.snowflake.com
+2
geeksforgeeks.org
+2
devart.com
.

📌 Why You Chose These Techniques
Scalar subqueries simplify showing or comparing single aggregated values.

Correlated subqueries allow context-aware computations (e.g., average salary per branch).

EXISTS streamlines existence checks across related tables.

Derived tables modularize multi-step queries into readable segments.

IN clause simplifies multi-value filtering in a readable and efficient manner.
