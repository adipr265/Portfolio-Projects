-- First let's take a look at the banking transaction data

SELECT *
FROM BANKING_DATA.BANKING
;

-- Everything appears to bankingbe accurate
-- However the CHQNO column has almost no values and there is a column Field9 with only dots
-- Lets clean this up and drop these two columns from the table

ALTER TABLE BANKING_DATA.BANKING
DROP COLUMN CHQNO, DROP COLUMN FIELD9
;

SELECT *
FROM BANKING_DATA.BANKING 
ORDER BY DATE DESC 
;

-- List of question
-- 1) how many customers does the bank have and which account number has done the most number of transactions
-- let's rename the columns as they seem to have spaces in between them
-- 2) most amount withdrawn and deposited in one single transaction and by whom
-- 3) we want to reward customers who have been with us a long time from the first year of 2015 and who are still doing transactions in the last six months of 2018 and early part of 2019
-- find out what is value date
-- 4) find out which is most prevelant in the transaction details column
-- 5) what is the latest balance amount of all the customers 

DESCRIBE BANKING_DATA.BANKING;

ALTER TABLE `banking_data`.`banking` 
CHANGE COLUMN `Account No` `account_no` VARCHAR(255)  ,
CHANGE COLUMN `Date` `date` DATETIME  ,
CHANGE COLUMN `Transaction Details` `transaction_details` VARCHAR(255)  ,
CHANGE COLUMN `Value Date` `value_date`  ,
CHANGE COLUMN `Withdrawal amt` `withdrawal_amt`  ,
CHANGE COLUMN `Deposit amt` `deposit_amt`  ,
CHANGE COLUMN `Balance amt` `balance_amt` ;

-- Answers

-- 1)
SELECT ACCOUNT_NO, COUNT(*) AS no_of_transactions
FROM BANKING_DATA.BANKING
GROUP BY ACCOUNT_NO
ORDER BY 2 DESC
;

SELECT COUNT(DISTINCT ACCOUNT_NO) AS no_of_customers
FROM BANKING_DATA.BANKING
;
-- the results of these queries indicate that the transactions have been done only by 10 account no's and that most of them have done multiple transactions over time
-- so we must be dealing with a private bank and a relatively new one catering to the needs of only few people

-- 2)
SELECT ACCOUNT_NO, DATE, TRANSACTION_DETAILS, MAX(WITHDRAWAL_AMT) AS maximum_withdrawal_amt
FROM BANKING_DATA.BANKING
GROUP BY ACCOUNT_NO
ORDER BY 4 DESC
;

SELECT ACCOUNT_NO, DATE, TRANSACTION_DETAILS, MAX(DEPOSIT_AMT) AS maximum_deposit_amt
FROM BANKING_DATA.BANKING
GROUP BY ACCOUNT_NO
ORDER BY 4 DESC
;

/* SELECT *
FROM BANKING_DATA.BANKING
WHERE ACCOUNT_NO LIKE '%409000362497%'
AND DEPOSIT_AMT IS NOT NULL
; */

-- 3)
SELECT DISTINCT ACCOUNT_NO
FROM BANKING_DATA.BANKING
WHERE (DATE BETWEEN '2015-01-01' AND '2015-12-31')
AND (DATE BETWEEN '2018-06-31' AND '2019-03-01')
;
-- We can see that 3 account no's have been active during this period and are hence dubbed as loyal customers and can be given a reward of some kind
-- These customers can also be asked suggestions what the bank is doing right and in what aspects the bank can improve

-- bonus question 
SELECT COUNT(*)
FROM BANKING_DATA.BANKING
;

SELECT COUNT(*)
FROM BANKING_DATA.BANKING
WHERE DATE = VALUE_DATE
;

SELECT *
FROM BANKING_DATA.BANKING
WHERE DATE != VALUE_DATE
;
-- from these three queries we can see that the value date and date are the same in most cases while in the few mismatching cases it is just a few days apart
-- hence we can ignore this and take both columns as the same data

-- 4)
DROP TEMPORARY TABLE IF EXISTS TEMP_T;
CREATE TEMPORARY TABLE TEMP_T AS
(
SELECT
 ACCOUNT_NO, SUBSTRING_INDEX(TRANSACTION_DETAILS, ' ', 2) AS WORDS
 FROM BANKING_DATA.BANKING
);
SELECT WORDS, COUNT(*) AS TRANSACTION_DETAIL_WORD_COUNT
FROM TEMP_T
WHERE WORDS IS NOT NULL
GROUP BY WORDS
ORDER BY 2 DESC
;
-- from this we can see that the transactions starting with FDRL/INTERNAL FUND and FDRL/NATIONAL ELECTRONIC have been the most used transaction detail

-- 5)
SELECT ACCOUNT_NO, MAX(DATE) AS DATE, BALANCE_AMT
FROM BANKING_DATA.BANKING
GROUP BY ACCOUNT_NO
ORDER BY 2 
;
-- We can see that alot of these accounts have a balance amount of minus which is not a good sign for the bank as they are loosing money
-- From previous queries on loyal customers we can also observe that these customers have an especially high minus value and hence maybe the reason they keep coming back as the bank is not collecting the money owed by them.
-- It is best for the bank to collect these negative balance amounts as soon as possible.