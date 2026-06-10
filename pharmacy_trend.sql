/* select * from projects.`pharmacy`; 
SELECT * FROM projects.pharmacy LIMIT 10;
SELECT COUNT(*) FROM projects.pharmacy;
SHOW CREATE TABLE projects.pharmacy;
SHOW WARNINGS;
SELECT * 
FROM information_schema.columns
WHERE table_schema='projects'
AND table_name='pharmacy';*/

/*create table sample(
name varchar(5),
age int);

insert into sample
values
( 'kal',20),
('vani',19);

select *from projects.sample;
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

CREATE TABLE pharmacy (
    DATE DATE,
    YEAR INT,
    MONTH INT,
    TOTAL_PHARMACIES INT,
    TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS INT,
    TOTAL_DISTANCE_SELLING_PHARMACIES INT,
    TOTAL_HUNDRED_HOUR_PHARMACIES INT,
    SMALL INT,
    MEDIUM INT,
    LARGE INT,

    TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_OPENED INT,
    TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_CLOSED INT,
    PHARMACIES_EXCLUDING_DISTANCE_SELLERS_NET_CHANGE INT,

    SMALL_PHARMACIES_OPENED INT,
    SMALL_PHARMACIES_CLOSED INT,
    SMALL_PHARMACIES_NET_CHANGE INT,

    MEDIUM_PHARMACIES_OPENED INT,
    MEDIUM_PHARMACIES_CLOSED INT,
    MEDIUM_PHARMACIES_NET_CHANGE INT,

    LARGE_PHARMACIES_OPENED INT,
    LARGE_PHARMACIES_CLOSED INT,
    LARGE_PHARMACIES_NET_CHANGE INT,

    DISTANCE_SELLERS_OPENED INT,
    DISTANCE_SELLERS_CLOSED INT,
    DISTANCE_SELLERS_NET_CHANGE INT
);
LOAD DATA LOCAL INFILE 'C:/Users/k8890/OneDrive/Documents/Desktop/Data Analytics/Project/Pharmacy/pharmacy.csv'
INTO TABLE projects.pharmacy
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
*/

select *from projects.`pharmacy` where YEAR = 2025;

/* to prevent from updates on all rows
set sql_safe_updates=0;

these are needed when date in in other format like varchar or text
update `pharmacy`
set `DATE `=str_to_date(`DATE`,'%y,%m,%d');

alter table `pharmacy`
modify column `DATE` DATE;
*/

-- 1.What is the trend in pharmacy openings and closures over time?--
select `year`,`month`,
sum(SMALL_PHARMACIES_OPENED+MEDIUM_PHARMACIES_OPENED+LARGE_PHARMACIES_OPENED) as total_opened,
sum(SMALL_PHARMACIES_CLOSED+MEDIUM_PHARMACIES_CLOSED+LARGE_PHARMACIES_CLOSED) as total_closed
from `pharmacy` group by `year`,`month` order by `year`,`month`;

select `year`,
sum(SMALL_PHARMACIES_OPENED+MEDIUM_PHARMACIES_OPENED+LARGE_PHARMACIES_OPENED) as total_opened,
sum(SMALL_PHARMACIES_CLOSED+MEDIUM_PHARMACIES_CLOSED+LARGE_PHARMACIES_CLOSED) as total_closed,
sum(SMALL_PHARMACIES_NET_CHANGE+MEDIUM_PHARMACIES_NET_CHANGE+LARGE_PHARMACIES_NET_CHANGE) as total_netchange
from `pharmacy` group by `year` order by `year`;

-- 2.Are closures disproportionately affecting certain pharmacy sizes?--
select 'SMALL' as pharmacy_size,sum(SMALL_PHARMACIES_CLOSED) as total_closed from `pharmacy`
union all
select 'MEDIUM',sum(MEDIUM_PHARMACIES_CLOSED) from `pharmacy` union all
select 'LARGE',sum(LARGE_PHARMACIES_CLOSED) from `pharmacy`;

-- 3.What are the implications for healthcare access?--

-- trend in total pharmacies--
select `year`,max(TOTAL_PHARMACIES) as total_pharmacies from `pharmacy`
group by `year` order by `year`;
-- net change--
select `year`,sum(SMALL_PHARMACIES_NET_CHANGE+MEDIUM_PHARMACIES_NET_CHANGE+LARGE_PHARMACIES_NET_CHANGE)
as net_change from `pharmacy` group by `year` order by `year`;

-- 4.Are distance sellers replacing physical pharmacies?--
-- distance sellers--
select `year`,sum(DISTANCE_SELLERS_OPENED) as dist_open,sum(DISTANCE_SELLERS_CLOSED) as dist_closed,sum(DISTANCE_SELLERS_NET_CHANGE) as dist_netchange
from `pharmacy` group by `year` order by `year`;
-- net change --
select `year`,sum(SMALL_PHARMACIES_NET_CHANGE+MEDIUM_PHARMACIES_NET_CHANGE+LARGE_PHARMACIES_NET_CHANGE) as net_change
from `pharmacy` group by `year` order by `year`;

-- Is the pharmacy industry growing or shrinking? --
-- with year--
select year,sum(TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_OPENED+DISTANCE_SELLERS_OPENED) as opened,
       sum(TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_CLOSED+DISTANCE_SELLERS_CLOSED) as closed 
from `pharmacy` group by year;

-- without year--
select sum(TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_OPENED+DISTANCE_SELLERS_OPENED) as opened,
       sum(TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_CLOSED+DISTANCE_SELLERS_CLOSED) as closed 
from `pharmacy`;

-- survival rate--
select year,round(100*(sum(TOTAL_PHARMACIES)-sum(TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_CLOSED+DISTANCE_SELLERS_CLOSED))/
sum(TOTAL_PHARMACIES),2) as survival_rate from `pharmacy` group by year order by year;

-- Identify the worst year for the industry.--
select year,sum(TOTAL_PHARMACIES_EXCLUDING_DISTANCE_SELLERS_CLOSED+DISTANCE_SELLERS_CLOSED) as closed
from `pharmacy` group by year order by closed desc limit 1;