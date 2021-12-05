-- Create database

CREATE DATABASE InsuranceMSDB
go
Use InsuranceMSDB
go

-- Create tables

CREATE TABLE ProductsCatalog(
    ProductID int PRIMARY KEY IDENTITY (1,1),
    Type varchar(50) NOT NULL,
    Description varchar(200)

);

CREATE TABLE Coverage(
    CoverageID int PRIMARY KEY IDENTITY (10,1),
    Type varchar(50) NOT NULL,
    Description varchar(200),
    Region varchar(20) CHECK(Region in ('Romania', 'Europe', 'Worldwide'))
);


CREATE TABLE ProductCoverage(
    ProductID int not null ,
    CoverageID INT not null ,
    Type varchar(20) CHECK(TYPE IN ('Basic', 'Additional')),
    CONSTRAINT FKProduct FOREIGN KEY (ProductID) REFERENCES ProductsCatalog(ProductID)
                             ON DELETE CASCADE ,
    CONSTRAINT  FKCoverage FOREIGN KEY (CoverageID) REFERENCES Coverage(CoverageID)
                             ON DELETE CASCADE,
    CONSTRAINT ProductCoveragePK PRIMARY KEY (ProductID, CoverageID)
);


CREATE TABLE Occupations(
    OccupationID int PRIMARY KEY IDENTITY (100,1),
    Type varchar(50) NOT NULL ,
    Description varchar(50),
    LevelOfRisk varchar(20) CHECK(LevelOfRisk in ('Low', 'Medium', 'High'))
);



CREATE TABLE Insured(
    CNPInsured bigint PRIMARY KEY,
    OccupationID int NOT NULL,
    Name varchar(50) NOT NULL,
    Surname varchar(50) NOT NULL,
    Address varchar(100) NOT NULL,
    Email varchar(50) NOT NULL ,
    TelephoneNumber varchar(50) NOT NULL ,
    DateOfBirth date,
    CONSTRAINT FKOccupation FOREIGN KEY (OccupationID) REFERENCES   Occupations(OccupationID)
                             ON DELETE CASCADE
);


CREATE TABLE Contractors(
    CNPContractor bigint PRIMARY KEY,
    Name varchar(50) NOT NULL ,
    Surname varchar(50) NOT NULL,
    Address varchar(100) not null ,
    Email varchar(50) not null ,
    TelephoneNumber varchar(50) not null ,
    DateOfBirth date

);


CREATE TABLE Insurers(
    InsurerID int PRIMARY KEY IDENTITY (1000,1),
    Name varchar(50) NOT NULL ,
    Surname varchar(50),
    CompanyName varchar(50),
    Type varchar(20) check(Type in ('Employee', 'Broker')),
    Commission int,
    DateOfCollaborationStart date
);


CREATE TABLE Offers(
    OfferID int PRIMARY KEY IDENTITY (100,1),
    CNPContractor bigint NOT NULL,
    InsurerID int NOT NULL,
    Taxes int,
    DateOfEmission date NOT NULL ,
    DateOfSigning date ,
    CONSTRAINT FKInsurer FOREIGN KEY (InsurerID) REFERENCES Insurers(InsurerID)
                            ON DELETE CASCADE,
    CONSTRAINT FKContractor FOREIGN KEY (CNPContractor) REFERENCES Contractors (CNPContractor)
                            ON DELETE CASCADE


);

CREATE TABLE Policies(
    PolicyID int PRIMARY KEY IDENTITY (100,1),
    OfferID int NOT NULL,
    ProductID int NOT NULL,
    CNPInsured bigint NOT NULL,
    Price int NOT NULL ,
    TypeOfFee varchar(20),
    DateOfIssue date NOT NULL,
    DateOfStart date NOT NULL,
    DateOfEnd date NOT NULL,

CONSTRAINT FKProductPolicies FOREIGN KEY (ProductID) REFERENCES ProductsCatalog (ProductID)
                            ON DELETE CASCADE,
CONSTRAINT FKOffer FOREIGN KEY (OfferID) REFERENCES Offers (OfferID)
                            ON DELETE CASCADE,
CONSTRAINT FKInsured FOREIGN KEY (CNPInsured) REFERENCES Insured(CNPInsured)
                            ON DELETE cascade

);



CREATE TABLE Fees(
    FeeID int PRIMARY KEY IDENTITY (1,1),
    PolicyID int NOT NULL,
    AmountToPay int not null,
    MethodOfPayment varchar(20) check(MethodOfPayment in ('Cash', 'Card', 'Transaction')),
    DueDate date NOT NULL,
    DateOfPayment date,
    CONSTRAINT FKPolicy FOREIGN KEY (PolicyID) REFERENCES Policies (PolicyID)
                            ON DELETE CASCADE,

);

-- Insert data into the database

INSERT INTO Occupations ( Type, Description, LevelOfRisk)
Values ( 'Policeman', 'Carries a gun', 'Medium');

INSERT INTO Occupations (Type, Description, LevelOfRisk)
Values ( 'Accountant', '', 'Low');

INSERT INTO Occupations( Type, Description, LevelOfRisk)
Values ( 'Pilot', '', 'High');

INSERT INTO Occupations( Type, Description, LevelOfRisk)
Values ( 'Doctor', '', 'Low');

INSERT INTO Occupations( Type, Description, LevelOfRisk)
Values ( 'Attorney', '', 'Low');

--

INSERT INTO Insurers ( Name, Surname, CompanyName, Type, Commission, DateOfCollaborationStart)
Values ('Allan','Ford', 'ING','Employee', 10, '2020-01-10');

INSERT INTO Insurers ( Name, Surname,CompanyName, Type, Commission, DateOfCollaborationStart)
Values ('Alma','Mair', 'PFA','Broker', 20, '2021-08-17');

INSERT INTO Insurers ( Name, Surname,CompanyName, Type, Commission, DateOfCollaborationStart)
Values ('Deborah','Brown', 'Groupama','Employee', 15, '2021-07-27');

INSERT INTO Insurers ( Name, Surname,CompanyName, Type, Commission, DateOfCollaborationStart)
Values ('Darian','Davis', 'Euroins','Employee', 25, '2020-09-15');

INSERT INTO Insurers ( Name, Surname,CompanyName, Type, Commission, DateOfCollaborationStart)
Values ('Emily','Jones', 'PFA','Broker', 17, '2021-06-13');

--

INSERT INTO ProductsCatalog ( Type, Description)
VALUES ('Life','Life insurance for adults');

INSERT INTO ProductsCatalog ( Type, Description)
VALUES ('Health','Health insurance for adults');

INSERT INTO ProductsCatalog ( Type, Description)
VALUES ('Travel','Travel insurance for adults');

INSERT INTO ProductsCatalog ( Type, Description)
VALUES ('Health Student','Health insurance for students');

INSERT INTO ProductsCatalog ( Type, Description)
VALUES ( 'Travel Extreme','Premium Travel insurance for adults');

--

INSERT INTO Contractors (CNPContractor, Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6010114125908, 'Mike','Watt','Cluj-Napoca Dorobantilor Street no. 10', 'mike00@gmail.com', '0743835173', '1977-01-01');

INSERT INTO Contractors (CNPContractor,  Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6283494125924,  'Sarah','Mair','Cluj-Napoca Memorandumului Street no. 15', 'sarahm@gmail.com', '0786735374', '1991-05-24');

INSERT INTO Contractors (CNPContractor,  Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (1283494125924,  'Aida','Johnson','Cluj-Napoca Albac Street no. 18', 'aida_johnson@gmail.com', '0786772475', '1994-10-23');

INSERT INTO Contractors (CNPContractor,  Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (1983494125922,  'Charlotte','Evans','Cluj-Napoca Avram Iancu Street no. 15', 'charlotte_e@gmail.com', '0724735374', '1999-11-14');

INSERT INTO Contractors (CNPContractor,  Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6033494125929,  'Joshua','White','Cluj-Napoca Oltului Street no. 15', 'joshua_white@gmail.com', '0749735317', '2000-08-21');


--

INSERT INTO Insured (CNPInsured, OccupationID, Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6283494125924, 100,  'Sarah','Mair','Cluj-Napoca Memorandumului Street no. 15', 'sarahm@gmail.com', '0786735374', '1991-05-24');

INSERT INTO Insured (CNPInsured, OccupationID,Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6193494125224, 101,  'Jack','Shaw','Cluj-Napoca Kogalniceanu Street no. 17', 'jack@gmail.com', '0746737354', '1995-07-21');

INSERT INTO Insured (CNPInsured, OccupationID,Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (1983494125922, 103, 'Charlotte','Evans','Cluj-Napoca Avram Iancu Street no. 15', 'charlotte_e@gmail.com', '0724735374', '1999-11-14');

INSERT INTO Insured (CNPInsured, OccupationID,Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6033494125929, 102, 'Joshua','White','Cluj-Napoca Oltului Street no. 15', 'joshua_white@gmail.com', '0749735317', '2000-08-21');

INSERT INTO Insured (CNPInsured, OccupationID,Name, Surname, Address, Email, TelephoneNumber, DateOfBirth)
VALUES (6183655278894, 104, 'Thomas','Miller','Cluj-Napoca Dunarii Street no. 70', 'thomas_m@gmail.com', '0724783662', '1999-10-12');

--

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning)
values ( 6010114125908,1000, 50, '2021-10-07', '2021-10-08');

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning)
values ( 6033494125929,1000, 60, '2020-09-07', '2020-09-10');

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning)
values ( 1983494125922,1003, 40, '2021-08-11', '2020-08-11');

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning)
values ( 1283494125924,1004, 35, '2021-07-14', '2021-07-15');

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission)
values ( 1283494125924,1001, 45, '2021-09-20');

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission)
values ( 1283494125924,1000, 40, '2021-09-17');

INSERT INTO Offers ( CNPContractor, InsurerID, Taxes, DateOfEmission)
values ( 1283494125924,1003, 35, '2021-08-20');



INSERT INTO Coverage ( Type, Description, Region)
VALUES ( 'Seasonal sports', 'Practicing sports like skiing, water sports etc.', 'Romania');

INSERT INTO Coverage ( Type, Description, Region)
VALUES ( 'Hospitalization', 'Being hospitalized for urgent care', 'Worldwide');

INSERT INTO Coverage ( Type, Description, Region)
VALUES ( 'Theft', 'Having personal belongings being stolen', 'Europe');

INSERT INTO Coverage ( Type, Description, Region)
VALUES ( 'Extreme sports', 'Parachuting, Bungee jumping, Skydiving, etc', 'Europe');

INSERT INTO Coverage ( Type, Description, Region)
VALUES ( 'Surgeries', 'Having surgeries that are not urgent, but recommended by a doctor', 'Romania');

INSERT INTO Coverage (Type, Description, Region)
VALUES ('Covid-19','Performing full body checks after having Covid-19', 'Europe');

--

INSERT INTO ProductCoverage ( ProductID, CoverageID, Type)
VALUES ( 3, 10, 'Additional');

INSERT INTO ProductCoverage ( ProductID, CoverageID, Type)
VALUES ( 3, 12, 'Basic');

INSERT INTO ProductCoverage ( ProductID, CoverageID, Type)
VALUES ( 2, 11, 'Basic');

INSERT INTO ProductCoverage ( ProductID, CoverageID, Type)
VALUES ( 5, 13, 'Basic');

INSERT INTO ProductCoverage ( ProductID, CoverageID, Type)
VALUES ( 2, 14, 'Additional');

--

INSERT INTO Policies ( OfferID, ProductID, CNPInsured, Price, TypeOfFee, DateOfIssue, DateOfStart, DateOfEnd)
VALUES ( 100, 1, 6283494125924, 480,'Monthly', '2021-10-09', '2021-10-11', '2022-10-11');

INSERT INTO Policies ( OfferID, ProductID, CNPInsured, Price, TypeOfFee, DateOfIssue, DateOfStart, DateOfEnd)
VALUES ( 100, 2, 6193494125224, 150,'Unique', '2021-10-09', '2021-10-11', '2022-04-11');

INSERT INTO Policies ( OfferID, ProductID, CNPInsured, Price, TypeOfFee, DateOfIssue, DateOfStart, DateOfEnd)
VALUES ( 101, 3, 6033494125929, 600,'Monthly', '2020-09-10', '2020-09-11', '2021-09-11');

INSERT INTO Policies ( OfferID, ProductID, CNPInsured, Price, TypeOfFee, DateOfIssue, DateOfStart, DateOfEnd)
VALUES ( 102, 5, 1983494125922, 720,'Monthly', '2021-08-11', '2021-08-11', '2022-02-11');

INSERT INTO Policies ( OfferID, ProductID, CNPInsured, Price, TypeOfFee, DateOfIssue, DateOfStart, DateOfEnd)
VALUES ( 103, 4, 6183655278894, 360,'Monthly', '2021-07-15', '2021-07-16', '2022-07-16');

--

INSERT INTO Fees ( PolicyID, AmountToPay, MethodOfPayment, DueDate, DateOfPayment)
values ( 100, 40, 'Card', '2021-10-11', '2021-10-10');

INSERT INTO Fees (PolicyID, AmountToPay, MethodOfPayment, DueDate, DateOfPayment)
values ( 102, 50, 'Card', '2020-09-11', '2020-09-11');

INSERT INTO Fees ( PolicyID, AmountToPay,  DueDate)
values ( 102, 50, '2021-09-11');

INSERT INTO Fees ( PolicyID, AmountToPay,  MethodOfPayment, DueDate, DateOfPayment)
values ( 103, 60, 'Transaction', '2021-08-11', '2021-08-11');

INSERT INTO Fees ( PolicyID, AmountToPay,MethodOfPayment,  DueDate, DateOfPayment)
values ( 104, 30,'Card', '2021-07-16', '2021-07-15');






--------------------------------------------------- ASSIGNMENT 2 ---------------------------------------------------


-- Dropping the Fees table, creating 2 tables instead: Payments and Rates with a many to many relationship
-- ( table PaymentsFees solves the relationship )

DROP TABLE Fees;

CREATE TABLE Rates(
    RateID int PRIMARY KEY IDENTITY (100,1),
    PolicyID int NOT NULL,
    AmountToPay int not null,
    DueDate date NOT NULL,
    CONSTRAINT FKPolicy FOREIGN KEY (PolicyID) REFERENCES Policies (PolicyID)
                            ON DELETE CASCADE,
);

CREATE TABLE Payments(
    PaymentID int PRIMARY KEY IDENTITY (100,1),
    Bank varchar(50),
    MethodOfPayment varchar(50) CHECK(Payments.MethodOfPayment IN ('Cash','Transaction','Card')),
    Currency varchar(5) CHECK (Currency in ('RON', 'EUR','USD', 'BTC')) DEFAULT 'RON',
    CurrencyRate float NOT NULL DEFAULT 1,
    AmountPaid int NOT NULL,
    DateOfPayment date NOT NULL,
    Description varchar(200),

)

CREATE TABLE PaymentsRates(
    PaymentsRatesID int PRIMARY KEY IDENTITY (1,1),
    PaymentID int NOT NULL,
    RateID int NOT NULL,
    CONSTRAINT FKRate FOREIGN KEY (RateID) REFERENCES Rates(RateID)
                     ON DELETE CASCADE,
    CONSTRAINT FKPayment FOREIGN KEY (PaymentID) REFERENCES Payments(PaymentID)
                     ON DELETE CASCADE,

)

-- Altering table Policies
--

ALTER TABLE Policies
DROP COLUMN TypeOfFee;
go
--
ALTER TABLE Policies
ADD NumberOfRates int;
go

UPDATE Policies
SET NumberOfRates = 12
WHERE PolicyID = 100;

UPDATE Policies
SET NumberOfRates = 1
WHERE PolicyID = 101;

UPDATE Policies
SET NumberOfRates = 12
WHERE PolicyID = 102;

UPDATE Policies
SET NumberOfRates = 6
WHERE PolicyID = 103;

UPDATE Policies
SET NumberOfRates = 12
WHERE PolicyID = 104;

ALTER TABLE  Policies
ALTER COLUMN NumberOfRates int NOT NULL;


-- INSERTING INTO THE NEW TABLES

INSERT INTO Rates (PolicyID, AmountToPay, DueDate) VALUES (100, 40, '2021-10-11');
INSERT INTO Rates (PolicyID, AmountToPay, DueDate) VALUES (100, 40, '2021-11-11');
INSERT INTO Rates (PolicyID, AmountToPay, DueDate) VALUES (100, 40, '2021-12-11');
INSERT INTO Rates (PolicyID, AmountToPay, DueDate) VALUES (101, 150, '2021-10-11');
INSERT INTO Rates (PolicyID, AmountToPay, DueDate) VALUES (103, 120, '2021-08-11');


INSERT INTO Payments (Bank, MethodOfPayment, AmountPaid, DateOfPayment, Description)
values ('BT', 'Card', 80, '2021-10-11', 'Paid 2 Rates for months 10, 11');
INSERT INTO Payments (Bank, MethodOfPayment, AmountPaid, DateOfPayment, Description)
values ('BCR', 'Transaction',100, '2021-10-11', 'Paid part of rate for month 10');
INSERT INTO Payments (MethodOfPayment, AmountPaid, DateOfPayment, Description)
values ( 'Cash',50, '2021-10-11', 'Paid part of rate for month 10');
INSERT INTO Payments (Bank, MethodOfPayment, AmountPaid, DateOfPayment, Description)
values ('BT', 'Transaction',120, '2021-08-11', 'Paid rate for month 08');
INSERT INTO Payments (Bank, MethodOfPayment, AmountPaid, DateOfPayment, Description)
values ('BT', 'Card', 40, '2021-10-20', 'Paid rate for month 12');


INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (100, 100);
INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (100, 101);
INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (101, 103);
INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (102, 103);
INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (103, 104);
INSERT INTO PaymentsRates (PaymentID, RateID) VALUES (104, 102);


GO
CREATE VIEW ViewProducts AS
SELECT * FROM ProductsCatalog;
GO
CREATE VIEW ViewProductCoverageProducts AS
SELECT PC.Type, ProductCoverage.Type as CoverageType FROM ProductCoverage
    INNER JOIN ProductsCatalog PC on PC.ProductID = ProductCoverage.ProductID
go
CREATE VIEW ViewAvgPriceProductsPolicies AS
SELECT Type, AVG(Price) AS AveragePrice FROM(
SELECT ProductsCatalog.Type AS Type, Price FROM Policies
INNER JOIN ProductsCatalog ON Policies.ProductID = ProductsCatalog.ProductID) AS Table2
GROUP BY Type;
go
CREATE VIEW ViewOffers AS
SELECT * FROM Offers;