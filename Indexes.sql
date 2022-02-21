use InsuranceMSDB
go

delete from Offers; -- Ta
delete from ProductsCatalog; -- Tb
delete from Policies; -- Tc

-- Alter Table Offers
-- ADD Code int UNIQUE;
--
-- go
--
-- Alter Table ProductsCatalog
-- Add YearOfRelease int,
-- go


CREATE OR ALTER PROCEDURE insertIntoOffers(@count int) -- procedure that inserts data into Offers Table
AS
    BEGIN
        declare @randomCNPContractor bigint
        declare @randomInsurerId int
        declare @randomTaxes int
        declare @randomDateOfEmission date
        declare @randomDateOfSigning date
        declare @randomCode int

        while @count > 0 -- inserting @count rows into the table
        BEGIN
            set @randomCNPContractor = (SELECT TOP 1 CNPContractor FROM Contractors
                                ORDER BY NEWID()) -- selecting a random value for CNPContractor from table Contractors (FK in Offers)
            set @randomInsurerId = (SELECT TOP 1 InsurerID FROM Insurers
                            ORDER BY NEWID())  -- selecting a random value for InsurerID from table Insurers (FK in Offers)
            set @randomTaxes = (SELECT  FLOOR(RAND() * 70)) -- generating a random integer for taxes
            set @randomCode = 1
            if (EXISTS(SELECT Code from Offers))
                begin
                    set @randomCode = (SELECT TOP 1 Code from Offers ORDER BY Code DESC) + 1
                end
            set @randomDateOfEmission = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01') -- generating random datetime values
            set @randomDateOfSigning = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01')
            INSERT INTO Offers (CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning, Code) -- inserting the data
            VALUES (@randomCNPContractor, @randomInsurerId, @randomTaxes, @randomDateOfEmission, @randomDateOfSigning, @randomCode);
            set @count = @count - 1
            end
    end

go


CREATE OR ALTER PROCEDURE insertIntoProductsCatalog(@count int) -- procedure that inserts data into ProductsCatalog table
    AS
    BEGIN -- construct data to be inserted in the table
        declare @randomType varchar(50)
        set @randomType = 'Type'
        declare @randomDescription varchar(200)
        declare @randomYear int
        set @randomDescription = 'Description'
        while @count > 0 -- inserting @count rows to the table
            begin
            set @randomYear = 2010 + FLOOR(RAND() * 11)

            INSERT INTO ProductsCatalog (Type, Description, YearOfRelease) VALUES -- inserting the row
            (CONCAT(@randomType, CONVERT(varchar(5), @count)),CONCAT(@randomDescription, CONVERT(varchar(5), @count)), @randomYear);
            set @count = @count - 1
            end
    END
GO

CREATE OR ALTER PROCEDURE insertIntoPolicies(@count int) -- procedure that inserts data into Policies table
AS
     BEGIN
        declare @randomOfferId int
        declare @randomProductId int
        declare @randomCNPInsured bigint
        declare @randomPrice int
        declare @randomDateOfIssue date
        declare @randomDateOfStart date
        declare @randomDateOfEnd date
        declare @randomNoOfRates int
        while @count > 0 -- inserting @count rows into the table
        BEGIN
            set @randomOfferId = (SELECT TOP 1 OfferId FROM Offers
                                ORDER BY NEWID()) -- selecting a random OfferId from Offers table (it is a FK)
            set @randomProductId = (SELECT TOP 1 ProductId FROM ProductsCatalog
                            ORDER BY NEWID())  -- selecting a random ProductId from ProductsCatalog table (it is a FK)
            set @randomCNPInsured = (SELECT TOP 1 CNPInsured FROM Insured
                                ORDER BY NEWID()) -- selecting a random CNPInsured from Insured table (it is a FK)
            set @randomPrice = (SELECT FLOOR(RAND() * 500)) -- generating a random integer for price
            set @randomDateOfIssue = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01') -- generating random datetime values
            set @randomDateOfStart = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01')
            set @randomDateOfEnd = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01')
            set @randomNoOfRates = (SELECT FLOOR(RAND() * 3) * 6) -- generating a random amount of rates (0/6/12)
            INSERT INTO Policies (OfferID, ProductID, CNPInsured, Price, DateOfIssue, DateOfStart, DateOfEnd, NumberOfRates) -- inserting the data
            VALUES (@randomOfferId, @randomProductId, @randomCNPInsured, @randomPrice, @randomDateOfIssue, @randomDateOfStart, @randomDateOfEnd, @randomNoOfRates);
            set @count = @count - 1
            end
    end
go

insertIntoOffers 500
go
insertintoProductsCatalog 500
go
insertIntoPolicies 500

--Ta

-- clustered index scan;

SET STATISTICS IO ON
select OfferID from Offers; -- 0.0038

-- clustered index seek;

SET STATISTICS IO ON
select OfferID from Offers where OfferID = 3600; -- 0.0032

-- non clustered index scan;

SET STATISTICS IO ON
select Code from Offers; -- 0.0038

-- non clustered index seek;

SET STATISTICS IO ON
select InsurerID, Code from Offers where Code = 400; -- 0.0033

-- key lookup (nested loops non clustered index seek and clustered index seek)

SET STATISTICS IO ON
select * from Offers where Taxes = 32; --clustered index scan 0.0053
select * from Offers where OfferID = 3445; --clustered index seek 0.0032
select Code from Offers WHERE Code = 500;-- non clustered index seek 0.0032

select * from Offers where Code = 500; -- key lookup 0.0065 (inefficient because of nested loop)

CREATE UNIQUE INDEX Unique_Offers on Offers(Code) INCLUDE (CNPContractor, InsurerID, Taxes, DateOfSigning, DateOfEmission);

select * from Offers where Code = 500; --  0.0032 unique non clustered index seek (key lookup solved)

DROP INDEX Offers.Unique_Offers;

--Tb

--scan

drop index IX_ProductsCatalog_Year on ProductsCatalog;
GO
select * from ProductsCatalog where YearOfRelease = 2020; -- 0.0053

--seek

CREATE NONCLUSTERED INDEX IX_ProductsCatalog_Year ON ProductsCatalog(YearOfRelease)
INCLUDE (Type, Description);

GO
select * from ProductsCatalog where YearOfRelease = 2020; -- 0.0038

-- c

-- using clustered and non clustered indexes

CREATE OR ALTER VIEW ViewProductsOffers AS
Select PC.ProductID, Type, Description, YearOfRelease, O.OfferID, CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning, Code, P.Price from
(select * from ProductsCatalog where YearOfRelease = 2019 ) AS PC
INNER JOIN (SELECT * FROM Policies where PolicyID > 200) as P on PC.ProductID = P.ProductID
inner join (SELECT * FROM Offers where Code = 299) AS O on O.OfferID = P.OfferID

select * from ViewProductsOffers; -- 0.0146

-- not using any indexes

CREATE OR ALTER VIEW ViewProductsOffers2 AS
Select O.OfferID, ProductsCatalog.ProductID, PolicyID,YearOfRelease from ProductsCatalog
INNER JOIN Policies P on ProductsCatalog.ProductID = P.ProductID
INNER JOIN Offers O on O.OfferID = P.OfferID

select * from ViewProductsOffers2; -- 0.0659
