
use InsuranceMSDB
go
--=======================================================================================================================================


-- INSERT THAT VIOLATES REFERENTIAL INTEGRITY CONSTRAINTS

-- INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (105, 100);

-- UPDATES

-- LIKE
-- Update all occupations that are related to doctors to a High level of risk.

UPDATE Occupations
SET LevelOfRisk = 'High'
WHERE Type LIKE '%Doctor%';

-- >=
-- Delay all due dates of rates with price higher or equal to 150 RON by a month.

UPDATE Rates
SET DueDate = DATEADD(month, 1, DueDate)
WHERE AmountToPay >= 150;

-- IN
-- Update Coverages related to Hospitalization and Surgeries to be supported Worldwide.

UPDATE Coverage
SET Region = 'Worldwide'
WHERE Type IN ('Hospitalization', 'Surgeries');

-- BETWEEN
-- Increase the commission of Insurers who started their collaboration with us in 2020 by 5 %.

UPDATE Insurers
SET Commission = Commission + 5
WHERE DateOfCollaborationStart BETWEEN '2020-01-01' AND '2020-12-31';


-- DELETES

-- AND
-- Delete the Insurer named Deborah Brown who is working for Groupama.

DELETE FROM Insurers
WHERE Name = 'Deborah' AND Surname = 'Brown' AND CompanyName = 'Groupama';

-- NULL
-- Delete the offers between Contractor with CNP 1283494125924 and Insurer with id 1001 that where emitted but not signed.

DELETE FROM Offers
WHERE CNPContractor = 1283494125924 AND InsurerID = 1001 AND DateOfEmission IS NOT NULL AND DateOfSigning IS NULL;


-------- a --------

-- 2 queries with the union operation; use UNION [ALL] and OR

-- UNION
-- Show all distinct addresses of our adult clients (Contractors and Insured) who can be reached by phone or email

SELECT DISTINCT Address FROM(
SELECT TelephoneNumber, Name, Surname, Address
FROM Contractors
WHERE DATEDIFF(hour,DateOfBirth,GETDATE())/8766.0 >= 18 AND (TelephoneNumber IS NOT NULL OR Email IS NOT NULL)
UNION
SELECT TelephoneNumber, Name, Surname, Address
FROM Insured
WHERE DATEDIFF(hour,DateOfBirth,GETDATE())/8766.0 >= 18 AND (TelephoneNumber IS NOT NULL OR Email IS NOT NULL)) as Table2;

-- OR
-- Show the full names of insurers being employees for Euroins or ING
--


SELECT Name, Surname FROM Insurers WHERE (CompanyName = 'Euroins' OR CompanyName = 'ING') AND Type='Employee';


-- <-> UNION
-- Show the full names of insurers working for Euroins or ING ordered by Name, Surname

SELECT Name, Surname
FROM Insurers
WHERE CompanyName = 'Euroins' AND Type='Employee'
UNION
SELECT Name, Surname
FROM Insurers
WHERE CompanyName = 'ING' AND Type='Employee'
ORDER BY Name, Surname;



-------- b --------

-- 2 queries with the intersection operation; use INTERSECT and IN

-- INTERSECT
-- Show the full names of the contractors who are also insured.

SELECT CNPContractor, Name, Surname
FROM Contractors
INTERSECT
SELECT CNPInsured, Name, Surname
FROM Insured;

-- IN
-- get full names and emails of insured clients who have at least a policy on a travel product

SELECT Name, Surname, Email
FROM Insured
WHERE Insured.CNPInsured IN(SELECT CNPInsured FROM Policies WHERE ProductID
                            IN(SELECT ProductID FROM ProductsCatalog WHERE Type LIKE '%Travel%'));


-------- c --------

-- 2 queries with the difference operation; use EXCEPT and NOT IN;

-- Except
-- Show the full names of insurers who do not have emitted offers yet and simulate their commission decreased by 10%.

SELECT Name, Surname, Insurers.Commission as PreviousCommission, Commission - (10 * Insurers.Commission / 100) as NewComission FROM Insurers
WHERE InsurerID IN(
SELECT InsurerID FROM Insurers
EXCEPT
SELECT Offers.InsurerID FROM Offers);

-- NOT IN

-- Select the policies IDs and prices of policies that do not have rates emitted or have unpaid rates

SELECT PolicyID, Policies.Price FROM Policies
WHERE PolicyID NOT IN (
    SELECT PolicyID FROM Rates
    )
UNION
SELECT PolicyID, Policies.Price  FROM Policies
WHERE PolicyID IN(
    SELECT PolicyID FROM Rates WHERE RateID NOT IN(
        SELECT RateID FROM PaymentsRates
        )
    );

-------- d --------

-- 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator);
-- one query will join at least 3 tables, while another one will join at least two many-to-many relationships;

-- RIGHT JOIN at least 3 tables

-- Display all contractors and their total price from all their policies, the names of their insurers, along with the contractors who do not have offers emitted

SELECT Offers.OfferID, PolicyID, (Offers.Taxes + Policies.Price) * (100 + Insurers.Commission) / 100 AS TOTAL, Insurers.Name, Insurers.Surname, Contractors.Surname, Contractors.Name
FROM Policies
RIGHT JOIN Offers ON Offers.OfferID = Policies.OfferID
RIGHT JOIN Insurers on Offers.InsurerID = Insurers.InsurerID
RIGHT JOIN Contractors on Contractors.CNPContractor = Offers.CNPContractor
ORDER BY TOTAL desc;

-- LEFT JOIN

-- Display all insurers full name, email and offer IDs associated to them ( without excluding the ones that have no offers )

SELECT Name, Surname, CompanyName, O.OfferID
FROM Insurers
LEFT JOIN Offers O ON Insurers.InsurerID = O.InsurerID;


-- INNER JOIN 2 MANY TO MANY RELATIONSHIPS

-- Joined tables: Insured, Policies, Products <-> Coverage, Rates <-> Payments

-- Show a report of all paid products and coverages for all insured clients who have policies

SELECT Insured.Name, Insured.Surname, Policies.PolicyID, PC.Type, C.Type, R2.AmountToPay, P2.AmountPaid, P2.MethodOfPayment from Policies
INNER JOIN Insured ON Policies.CNPInsured = Insured.CNPInsured
INNER JOIN ProductsCatalog PC ON Policies.ProductID = PC.ProductID
INNER JOIN ProductCoverage P ON PC.ProductID = P.ProductID
INNER JOIN Coverage C ON P.CoverageID = C.CoverageID
INNER JOIN Rates R2 ON Policies.PolicyID = R2.PolicyID
INNER JOIN PaymentsRates PR ON R2.RateID = PR.RateID
INNER JOIN Payments P2 ON PR.PaymentID = P2.PaymentID;


-- FULL JOIN

-- get all products and coverages from our catalog

SELECT ProductsCatalog.Type, ProductsCatalog.Description, C.Type, C.Description from ProductsCatalog
FULL JOIN ProductCoverage PC on ProductsCatalog.ProductID = PC.ProductID
FULL JOIN Coverage C on C.CoverageID = PC.CoverageID;


-------- e --------

-- 2 queries with the IN operator and a subquery in the WHERE clause; in at least one case,
-- the subquery should include a subquery in its own WHERE clause;

-- WHERE () IN

-- All contractors who have emitted 1 or 2 offers

SELECT Name, Surname FROM Contractors
WHERE (SELECT COUNT(OfferID) FROM Offers WHERE Offers.CNPContractor = Contractors.CNPContractor ) IN (1, 2)

-- All insurers who emitted 1 or 2 offers that have at least one policy on their name

SELECT Name, Surname FROM Insurers
WHERE (SELECT COUNT(OfferID) FROM Offers WHERE Offers.InsurerID = Insurers.InsurerID AND (
    SELECT COUNT(PolicyID) FROM Policies WHERE Policies.OfferID = Offers.OfferID
    ) >= 1) IN (1, 2)

-- WHERE IN()

-- Show the products that are used in policies emitted for signed offers.

SELECT Type from ProductsCatalog
WHERE ProductID IN(
    SELECT ProductID FROM Policies WHERE OfferID IN(
        SELECT OfferID from Offers WHERE DateOfSigning IS NOT NULL
        )
    );

-- Show the full names, emails and phone numbers of the insured clients who have policies emitted working in high or
-- medium risk occupations and don't have a description of the occupation.

SELECT Name, Surname, TelephoneNumber, Email FROM Insured
WHERE CNPInsured IN(
    SELECT CNPInsured FROM Policies WHERE OccupationID IN (
    SELECT OccupationID FROM Occupations WHERE (LevelOfRisk = 'High' OR LevelOfRisk = 'Medium') AND Description = ''
    ));


-------- f --------

-- 2 queries with the EXISTS operator and a subquery in the WHERE clause

-- Show full names of insured clients who have paid rates

SELECT Name, Surname FROM Insured WHERE CNPInsured IN(
SELECT CNPInsured FROM Policies
WHERE PolicyID IN(
    SELECT DISTINCT PolicyID FROM Rates WHERE EXISTS(
        SELECT * FROM PaymentsRates WHERE Rates.RateID = PaymentsRates.RateID)
    ));


-- Show the full name of the insurers who have emitted offers having taxes >= 50

SELECT Name, Surname
FROM Insurers
WHERE EXISTS(SELECT * FROM Offers
where Taxes >= 50 AND Offers.InsurerID = Insurers.InsurerID);


-------- g --------

-- 2 queries with a subquery in the FROM clause;

-- The average policy price for every product type

SELECT Type, AVG(Price) AS AveragePrice FROM(
SELECT ProductsCatalog.Type AS Type, Price FROM Policies
INNER JOIN ProductsCatalog ON Policies.ProductID = ProductsCatalog.ProductID) AS Table2
GROUP BY Type;

-- The total amount paid for each policy that has rates emitted and payments made and the method of payment

SELECT PolicyID, SUM(AmountPaid) as TOTAL FROM(
    SELECT DISTINCT Policies.PolicyID as PolicyID, AmountPaid, MethodOfPayment from Policies
    INNER JOIN Rates R2 on Policies.PolicyID = R2.PolicyID
    INNER JOIN PaymentsRates PR on R2.RateID = PR.RateID
    INNER JOIN Payments P on PR.PaymentID = P.PaymentID
                                              ) AS Table2
GROUP BY PolicyID;

-------- h --------

--  4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause;
--  2 of the latter will also have a subquery in the HAVING clause;
--  use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;

-- The total amount paid through each bank

SELECT Bank, SUM(AmountPaid) FROM Payments
WHERE MethodOfPayment IN ('Card', 'Transaction')
GROUP BY Bank;

-- The full names and the number of offers emitted by each insurer, only the ones who have more than 1,
-- ordered descending by the number of offers
-- having


Select Name, Surname, OffersCount FROM(
SELECT COUNT(OfferID) AS OffersCount, InsurerID AS I
FROM Offers
GROUP BY InsurerID
HAVING COUNT(OfferID) > 0 ) AS Table2
INNER JOIN Insurers ON I = Insurers.InsurerID
ORDER BY OffersCount DESC;

-- subquery in having

-- Companies that have the average commission greater than the average commission of all insurers who collaborate with us

SELECT CompanyName, AVG(Commission) AS AVG1 FROM Insurers I
GROUP BY CompanyName
HAVING AVG(I.Commission) > (SELECT AVG(I2.Commission) FROM Insurers I2);


-- Display all insurers who have emitted more offers than the average of all offers emitted by all insurers


SELECT Table2.InsurerID, Name, Surname, CountOffers FROM(
SELECT InsurerID, COUNT(OfferID) as CountOffers from Offers O
GROUP BY InsurerID
HAVING COUNT(O.InsurerID) > (
    (SELECT COUNT(OfferID) from Offers O2) / (SELECT COUNT(InsurerID) from Insurers I2)
    )) AS Table2
INNER JOIN Insurers ON Table2.InsurerID = Insurers.InsurerID;


-------- i --------

-- 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator);
-- rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.

-- ANY

-- Display the names of the insured people who have policies that can be paid in multiple
-- rates and the price of the policies with a 5% discount.

SELECT Name, Surname, Price as OldPrice, Price - (5 * Price)/100 as NewPrice FROM Insured
INNER JOIN Policies P on Insured.CNPInsured = P.CNPInsured
WHERE Insured.CNPInsured = ANY(
    SELECT CNPInsured FROM Policies
    WHERE Policies.NumberOfRates > 1
    );

-- IN

SELECT Name, Surname, Price as OldPrice, Price - (5 * Price)/100 as NewPrice FROM Insured
INNER JOIN Policies P on Insured.CNPInsured = P.CNPInsured
WHERE Insured.CNPInsured IN (
    SELECT CNPInsured FROM Policies
    WHERE Policies.NumberOfRates > 1
    );

-- ANY

-- ALL insured clients who have due dates for rates between '2021-08-11' and '2021-10-11'

SELECT Name, Surname, TelephoneNumber from Insured WHERE CNPInsured = ANY(
SELECT CNPInsured FROM Policies WHERE PolicyID = ANY(
    SELECT PolicyID FROM Rates WHERE DueDate BETWEEN '2021-08-11' AND '2021-10-11'
    ))

-- IN

SELECT Name, Surname, TelephoneNumber FROM Insured WHERE CNPInsured IN(
SELECT CNPInsured FROM Policies WHERE PolicyID IN(
    SELECT PolicyID FROM Rates WHERE DueDate BETWEEN '2021-08-11' AND '2021-10-11'
    ))

-- ALL
-- Select policies that have lower prices than the Travel policies, sorted by price, top 3

SELECT TOP 3 PolicyID, Price FROM Policies WHERE Price < ALL(
    SELECT Price FROM Policies WHERE ProductID IN(
        SELECT ProductID FROM ProductsCatalog WHERE Type LIKE '%Travel%'
        )
    ) ORDER BY Price;

-- MIN

SELECT TOP 3 PolicyID, Price FROM Policies WHERE Price <
    (SELECT MIN(Price) FROM Policies WHERE ProductID IN(
        SELECT ProductID FROM ProductsCatalog WHERE Type LIKE '%Travel%'
        ))
    ORDER BY Price;

-- ALL

-- All Insurers that have the commission percentage larger than all insurers from ING

SELECT TOP 3 Name, Surname, Insurers.CompanyName, Commission FROM Insurers WHERE Commission > ALL(
    SELECT Commission FROM Insurers WHERE CompanyName = 'ING'
    )
ORDER BY Commission DESC;

-- MAX

SELECT TOP 3 Name, Surname, Insurers.CompanyName, Commission FROM Insurers WHERE Commission > (
    SELECT MAX(Commission) FROM Insurers WHERE CompanyName = 'ING'
    )ORDER BY Commission DESC;

