use InsuranceMSDB
go

CREATE OR ALTER PROCEDURE insertIntoProductsCatalog(@count int) -- procedure that inserts data into ProductsCatalog table
    AS
    BEGIN -- construct data to be inserted in the table
        declare @randomType varchar(50)
        set @randomType = 'Type'
        declare @randomDescription varchar(50)
        set @randomDescription = 'Description'
        while @count > 0 -- inserting @count rows to the table
            begin
            INSERT INTO ProductsCatalog (Type, Description) VALUES -- inserting the row
            (CONCAT(@randomType, CONVERT(varchar(5), @count)),CONCAT(@randomDescription, CONVERT(varchar(5), @count)));
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
GO

CREATE OR ALTER PROCEDURE insertIntoOffers(@count int) -- procedure that inserts data into Offers Table
AS
    BEGIN
        declare @randomCNPContractor bigint
        declare @randomInsurerId int
        declare @randomTaxes int
        declare @randomDateOfEmission date
        declare @randomDateOfSigning date
        while @count > 0 -- inserting @count rows into the table
        BEGIN
            set @randomCNPContractor = (SELECT TOP 1 CNPContractor FROM Contractors
                                ORDER BY NEWID()) -- selecting a random value for CNPContractor from table Contractors (FK in Offers)
            set @randomInsurerId = (SELECT TOP 1 InsurerID FROM Insurers
                            ORDER BY NEWID())  -- selecting a random value for InsurerID from table Insurers (FK in Offers)
            set @randomTaxes = (SELECT  FLOOR(RAND() * 70)) -- generating a random integer for taxes
            set @randomDateOfEmission = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01') -- generating random datetime values
            set @randomDateOfSigning = DATEADD(day , FLOOR(RAND() * 7000), '2000-01-01')
            INSERT INTO Offers (CNPContractor, InsurerID, Taxes, DateOfEmission, DateOfSigning) -- inserting the data
            VALUES (@randomCNPContractor, @randomInsurerId, @randomTaxes, @randomDateOfEmission, @randomDateOfSigning);
            set @count = @count - 1
            end
    end
GO


CREATE OR ALTER PROCEDURE insertIntoProductCoverage(@count int) -- procedure for inserting data into ProductsCoverage table
AS
    BEGIN
        declare @randomProductID int
        declare @randomCoverageID int
        declare @randomNumber int
        declare @randomType varchar(20)
        while @count > 0 -- inserting @count rows into the table
            begin
                set @randomProductId = (SELECT TOP 1 ProductID FROM ProductsCatalog
                                        ORDER BY NEWID()) -- selecting a random ProductID from ProductsCatalog table (FK in ProductsCoverage)
                set @randomCoverageID = (SELECT TOP 1 CoverageId FROM Coverage
                                        ORDER BY NEWID()) -- selecting a random CoverageId from Coverage table (FK in ProductsCoverage)
                -- checking if the pair (ProductID, CoverageId) does not already exists (it is a PK in ProductsCoverage)
                while EXISTS(SELECT * from ProductCoverage WHERE ProductID = @randomProductID AND CoverageID = @randomCoverageID)
                    begin -- generating values until they are not already found in the table
                        set @randomProductId = (SELECT TOP 1 ProductID FROM ProductsCatalog
                                        ORDER BY NEWID())
                        set @randomCoverageID = (SELECT TOP 1 CoverageId FROM Coverage
                                        ORDER BY NEWID())
                    end
                -- generating random value for Type
                set @randomNumber = @count % 2
                if @randomNumber = 0
                    begin
                        set @randomType = 'Basic'
                    end
                if @randomNumber = 1
                    begin
                         set @randomType = 'Additional'
                    end
                INSERT INTO ProductCoverage (ProductID, CoverageID, Type) -- inserting the data
                VALUES (@randomProductID, @randomCoverageID, @randomType);
                set @count = @count - 1
            end
    end
GO
-- test name, table name string with separator , view with separator , pos, no of rows
CREATE OR ALTER PROCEDURE runTest(@testName varchar(50), @tables varchar(200), @views varchar(200), @Rows int) -- procedure for running the tests
AS
    BEGIN
        declare @testStart datetime
        declare @testEnd datetime
        declare @testID int
        declare @tableName varchar(50)
        declare @noOfRows int
        declare @viewName varchar(50)
        declare @startTime datetime
        declare @endTime datetime
        declare @commandSelect varchar(50)
        declare @insertProcedureName varchar(50)
        declare @TestRunId int
        declare @tableId int
        declare @viewId int
        declare @deleteCommand varchar(50)
        declare @table varchar(50)
        declare @view varchar(50)
        declare @insertCommand varchar(200)
        declare @position int
        set @insertCommand = 'insert into Tests (Name) values(' + quotename(@testName,'''') + ');' -- inserting the new test into Tests table

        exec (@insertCommand)
        set @testID = (select TOP 1 TestID from Tests where Name = @testName ORDER BY TestID DESC)

        declare givenTablesCursor cursor for select value from STRING_SPLIT(@tables, ' ') -- going through the received tables
        open givenTablesCursor
        fetch givenTablesCursor into @table
        set @position = 1 -- generating the positions in the given order
        while @@FETCH_STATUS = 0
            BEGIN
                IF (EXISTS (SELECT *
                 FROM INFORMATION_SCHEMA.TABLES
                 WHERE TABLE_SCHEMA = 'dbo' -- checking if the table exists in the dbo schema
                 AND  TABLE_NAME = @table))
                BEGIN
                    IF NOT EXISTS(SELECT TableID FROM Tables WHERE Name = @table)
                begin

                    set @insertCommand = 'insert into Tables (Name) values(' + quotename(@table,'''') + ');' -- inserting the table into Tables if it is not already there
                    exec (@insertCommand)
                end
                set @tableId = (SELECT TableID from Tables where Name = @table)
                set @insertCommand = 'insert into TestTables(TestID, TableID, NoOfRows, Position) VALUES( ' + CONVERT(varchar(5), @testID) +','+ CONVERT(varchar(5), @tableId) +','+ CONVERT(varchar(5), @Rows) + ','+ CONVERT(varchar(5), @position) + ');'
                exec (@insertCommand) -- inserting into TestTables the connection between the test and the table
                set @position = @position + 1
                END
                ELSE
                    BEGIN
                    print 'Table ' + @table  + ' does not exist!'
                    END
                fetch givenTablesCursor into @table
            end
        CLOSE givenTablesCursor
        deallocate givenTablesCursor
        declare givenViewsCursor cursor for select value from STRING_SPLIT(@views, ' ') -- going through the received views
        open givenViewsCursor
        fetch givenViewsCursor into @view
        while @@FETCH_STATUS = 0
            BEGIN
                IF EXISTS(select * FROM sys.views where name = @view) -- check if view exists in the db
                BEGIN
                IF NOT EXISTS(SELECT ViewId FROM Views WHERE Name = @view)
                begin
                    set @insertCommand = 'insert into Views (Name) values(' + quotename(@view,'''') + ');' -- inserting the view into Views if it is not already there
                    exec (@insertCommand)
                end
                set @viewId = (select ViewID from Views where Name = @view)
                set @insertCommand = 'INSERT INTO TestViews (TestID, ViewID) VALUES('+ CONVERT(varchar(5), @testID) +','+ CONVERT(varchar(5), @viewId) +');'
                exec (@insertCommand) -- inserting the connection between the test and the view into TestViews
                END
                ELSE
                    begin
                    PRINT 'View ' + @view + ' does not exist!'
                    end
                fetch givenViewsCursor into @view
            end
        CLOSE givenViewsCursor
        deallocate givenViewsCursor

        set @testStart = SYSDATETIME() -- getting the time when the test started
        INSERT INTO TestRuns (Description, StartAt, EndAt) VALUES ('', null, null); -- inserting a TestRun with no values to retrieve its ID

        set @TestRunId = (SELECT TOP 1 TestRunID from TestRuns order by TestRunID desc) -- getting the ID of the current TestRun

            declare tableTestCursor cursor for SELECT Tables.TableID, Name from Tables
                INNER JOIN TestTables TT on Tables.TableID = TT.TableID
            WHERE TestID = @testID
            ORDER BY Position; -- cursor for the tables involved in this test for deletion ordered by position

            open tableTestCursor
            fetch tableTestCursor into @tableId, @tableName

            while @@FETCH_STATUS = 0 -- performing operations on all tables
                BEGIN
                    set @deleteCommand = 'delete from ' + @tableName + ';'
                    exec (@deleteCommand) -- deleting all data from table
                    fetch tableTestCursor into @tableId, @tableName
                end
            close tableTestCursor
            deallocate tableTestCursor

            declare tableTestCursor cursor for SELECT Tables.TableID, Name, NoOfRows from Tables
                INNER JOIN TestTables TT on Tables.TableID = TT.TableID
            WHERE TestID = @testID
            ORDER BY Position DESC; -- cursor for tables involved in insert in reverse order by position

            open tableTestCursor
            fetch tableTestCursor into @tableId, @tableName, @noOfRows
            while @@FETCH_STATUS = 0 -- looping through in all tables
                BEGIN
                    PRINT 'Running test on ' + @tableName
                    set @insertProcedureName = 'insertInto' + @tableName
                    set @startTime = SYSDATETIME() --  time before insertion starts
                    exec @insertProcedureName @noOfRows
                    set @endTime = SYSDATETIME() --  time after insertion ends
                    INSERT INTO TestRunTables (TestRunID, TableID, StartAt, EndAt) -- inserting performance values into TestRunTables
                    VALUES (@TestRunId, @tableId, @startTime, @endTime);
                    fetch tableTestCursor into @tableId, @tableName, @noOfRows
                end
            close tableTestCursor
            deallocate tableTestCursor

            declare viewCursor cursor for SELECT Views.ViewID, Name from Views
            INNER JOIN TestViews TV on Views.ViewID = TV.ViewID
            WHERE TestID = @testID; -- cursor for views involved in this test

            open viewCursor
            fetch viewCursor into @viewId, @viewName

            while @@FETCH_STATUS = 0 -- loop through the views
                begin
                    set @commandSelect = 'select * from ' + @viewName
                    set @startTime = SYSDATETIME() -- time before evaluation
                    exec (@commandSelect)
                    set @endTime = SYSDATETIME() -- time after evaluation
                    INSERT INTO TestRunViews (TestRunID, ViewID, StartAt, EndAt) -- inserting performance data into TestRunViews
                    VALUES (@TestRunId, @viewId, @startTime, @endTime);
                    fetch viewCursor into @viewId,@viewName
                end
            close viewCursor
            deallocate viewCursor


        set @testEnd = SYSDATETIME() -- getting the time when the test ended

        Update TestRuns -- updating the test Run with the performance values
        SET Description = 'Running Test' + @testName,
            StartAt = @testStart,
            EndAt = @testEnd
        WHERE TestRunID = @TestRunId;
    end
go


runTest 'TestProductsCatalog', 'ProductsCatalog', 'ViewProducts', 10;
runTest 'TestOffers', 'Offers', 'ViewOffers', 10;
runTest 'TestPolicies', 'Policies', 'ViewAvgPriceProductsPolicies', 10;
runTest 'TestProductCoverage', 'ProductCoverage', 'ViewProductCoverageProducts', 10;
runTest 'TestGeneral', 'Policies ProductCoverage Offers ProductsCatalog', 'ViewProducts ViewOffers ViewProductCoverageProducts ViewAvgPriceProductsPolicies', 10;
runTest 'TestWrong', 'Table1', 'View1', 20;





-- go
-- runTest 'TestProductCoverage';
-- go
-- runTest 'TestPolicies';
-- go
-- runTest 'TestOffers';
-- go
-- runTest 'GeneralTest';
-- go
-- runTest 'GeneralTestHard';


-- CREATE VIEW ViewInsurersCountOfOffers AS
-- SELECT Table2.InsurerID, Name, Surname, CountOffers FROM(
-- SELECT InsurerID, COUNT(OfferID) as CountOffers from Offers O
-- GROUP BY InsurerID
-- HAVING COUNT(O.InsurerID) > (
--     (SELECT COUNT(OfferID) from Offers O2) / (SELECT COUNT(InsurerID) from Insurers I2)
--     )) AS Table2
-- INNER JOIN Insurers ON Table2.InsurerID = Insurers.InsurerID;

-- CREATE OR ALTER PROCEDURE insertIntoOccupations(@count int) -- procedure that inserts @count rows into table Occu
-- AS
--     BEGIN
--         declare @randomType varchar(50)
--         set @randomType = 'Type'
--         declare @randomDescription varchar(50)
--         set @randomDescription = 'Description'
--         declare @randomNumber int
--         declare @randomLevelOfRisk varchar(20)
--         while @count > 0
--             begin
--                 set @randomNumber = @count % 3
--                 if @randomNumber = 0
--                     begin
--                     set @randomLevelOfRisk = 'Low'
--                     end
--                 if @randomNumber = 1
--                     begin
--                     set @randomLevelOfRisk = 'Medium'
--                     end
--                 if @randomNumber = 2
--                     begin
--                     set @randomLevelOfRisk = 'High'
--                     end
--             INSERT INTO Occupations (Type, Description, LevelOfRisk) VALUES
--             (CONCAT(@randomType, CONVERT(varchar(5), @count)),CONCAT(@randomDescription, CONVERT(varchar(5), @count)),@randomLevelOfRisk);
--             set @count = @count - 1
--                 end
--     END
--
-- go

-- DROP table TestViews;
-- DROP table TestTables;
-- DROP table TestRunTables;
-- DROP table TestRunViews;
-- DROP table TestRuns;
-- DROP table Tables;
-- DROP table Views;


--
-- INSERT INTO Tables (Name) VALUES ('ProductsCatalog'), -- table ProductsCatalog - one PK, no FK
--                                  ('Offers'), -- table Offers 1 PK, 2 FK
--                                  ('ProductCoverage'), -- table ProductCoverage 2 PK
--                                  ('Policies'); -- table Policies - one PK, 3 FK
--
-- INSERT INTO Tests (Name) VALUES ('TestProductsCatalog'),
--                                 ('TestOffers'),
--                                 ('TestProductCoverage'),
--                                 ('TestPolicies'),
--                                 ('GeneralTest'),
--                                 ('GeneralTestHard');
--
--
-- INSERT INTO TestTables (TestID, TableID, NoOfRows, Position) VALUES (1,1,50,1),
--                                                                     (2,2,50,1),
--                                                                     (3,3,50,1),
--                                                                     (4,4,50,1),
--                                                                     (5,1,50,4),
--                                                                     (5,2,50,3),
--                                                                     (5,3,50,2),
--                                                                     (5,4,50,1),
--                                                                     (6,1,100,4),
--                                                                     (6,2,100,3),
--                                                                     (6,3,100,2),
--                                                                     (6,4,100,1);
--
--
-- INSERT INTO Views (Name) VALUES ('ViewProducts'), -- view ViewProducts on 1 table
--                                 ('ViewOffers'), -- view ViewOffers on one table
--                                 ('ViewProductCoverageProducts'), -- view ViewProductCoverageProducts on 2 tables
--                                 ('ViewAvgPriceProductsPolicies'); -- ViewAvgPriceProductsPolicies group by on 2 tables
--
-- INSERT INTO TestViews (TestID, ViewID) VALUES (1,1),
--                                               (2,2),
--                                               (3,3),
--                                               (4,4),
--                                               (5,1),
--                                               (5,2),
--                                               (5,3),
--                                               (5,4),
--                                               (6,1),
--                                               (6,2),
--                                               (6,3),
--                                               (6,4);
-- GO
