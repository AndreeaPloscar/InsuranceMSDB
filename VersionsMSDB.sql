use InsuranceMSDB;

go
-- procedures for actions performed on dataabse
-- a. modify the type of a column

CREATE PROCEDURE modifyTypeToFloat    -- procedure that modifies type of column Price from Policies to a float
AS
    BEGIN TRY
        ALTER TABLE Policies
        ALTER COLUMN Price float not null    -- changing the type to float with a not null constraint
        print 'Modified type of Price in Policies to float' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not modify type of column Price from Policies' -- if something went wrong, this is printed
    end catch

go

CREATE PROCEDURE modifyTypeToInt -- procedure that modifies type of column Price from Policies to a float
AS
    BEGIN TRY
        ALTER TABLE Policies 
        ALTER COLUMN Price int not null  -- changing the type to int with a not null constraint
        print 'Modified type of Price in Policies to float' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not modify type of column Price from Policies' -- if something went wrong, this is printed
    end catch

go
-- b. add / remove a column

CREATE PROCEDURE addEmailToInsurers -- procedure that adds a column Email varchar(50) to table Insurers
AS
    BEGIN try
        ALTER TABLE Insurers
        ADD Email varchar(50) -- adding the column
        print 'Added column Email to Insurers' -- printed if change was successfull
    end try
    BEGIN CATCH
        PRINT 'Could not add column Email to Insurers' -- if something went wrong, this is printed
    end catch

go

CREATE PROCEDURE dropEmailFromInsurers -- procedure that removes column Email from table Insurers
AS
    BEGIN TRY
        ALTER TABLE Insurers
        DROP COLUMN Email; -- removing rhe column
        print 'Dropped column Email from Insurers' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not remove column Email from Insurers' -- if something went wrong, this is printed
    end catch
go
-- c. add / remove a DEFAULT constraint

CREATE PROCEDURE addDefaultOnDescriptionInCoverage -- procedure that adds default constraint on column Description from table Coverage
AS
    BEGIN TRY
        ALTER TABLE Coverage
        add constraint defaultEmptyDescription default '' for Description -- adding the constraint with name defaultEmptyDescription
        print 'Added default constraint on Description in Coverage' -- printed if change was successfull
    END TRY
    BEGIN CATCH
        print 'Could not add default empty constraint on Description in table Coverage' -- if something went wrong, this is printed
    end catch
go

CREATE PROCEDURE removeDefaultOnDescriptionInCoverage -- procedure that removes default constraint on column Description from table Coverage
AS
    BEGIN TRY
        ALTER TABLE Coverage
        drop constraint defaultEmptyDescription -- removing the constraint with name defaultEmptyDescription
        print 'Removed Default constraint from Description in Coverage' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not drop default empty constraint from Coverage' -- if something went wrong, this is printed
    end catch
go
-- d. add / remove a primary key

CREATE PROCEDURE addPrimaryKeyPremiumPartners -- procedure that adds a primary key constraint to column PremiumPartnerID from new table PremiumPartners
    AS
    BEGIN TRY
        CREATE TABLE PremiumPartners( -- table PremiumPartners is created without a primary key constraint
            PremiumPartnerID int not null ,
            TopPartnerFromCompanyID int not null ,
            CompanyName varchar(50),
            DateOfCollaborationStart date not null
        )
        ALTER TABLE PremiumPartners
        ADD CONSTRAINT Pk_PremiumPartnerID PRIMARY KEY (PremiumPartnerID) -- adding the primary key constraint
        print 'Added primary key to Premium Partners' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not add primary key' -- if something went wrong, this is printed
    end catch

go

CREATE PROCEDURE removePrimaryKeyPremiumPartners -- procedure that removes primary key constraint from column PremiumPartnerID from table PremiumPartners
AS
BEGIN TRY
    ALTER TABLE PremiumPartners
    DROP CONSTRAINT Pk_PremiumPartnerID; -- removing the constraint
    DROP TABLE PremiumPartners; -- dropping the table to do the reverse operation of the above procedure
    print 'Dropped primary key from PremiumPartners' -- printed if change was successfull
end TRY
BEGIN CATCH
        PRINT 'Could not remove primary key constraint' -- if something went wrong, this is printed
end catch

go
-- e. add / remove a candidate key

CREATE PROCEDURE addCandidateKeyPremiumPartners -- procedure that adds a candidate key constraint to table PremiumPartners on column CompanyName
    AS
    BEGIN TRY
    ALTER TABLE PremiumPartners
    ADD CONSTRAINT uniqueCompanyName unique (CompanyName); -- adding the constraint with name uniqueCompanyName
    print 'Added candidate key to Premium Partners' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not add candidate key CompanyName in PremiumPartners' -- if something went wrong, this is printed
    end catch

go

CREATE PROCEDURE removeCandidateKeyPremiumPartners -- procedure that removes a candidate key constraint from table PremiumPartners on column CompanyName
    AS
    BEGIN TRY
    ALTER TABLE PremiumPartners
    DROP CONSTRAINT uniqueCompanyName; -- removing the constraint uniqueCompanyName
    print 'Dropped candidate key from Premium Partners' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not remove candidate key constraint' -- if something went wrong, this is printed
    end catch

go
-- f. add / remove a foreign key

CREATE PROCEDURE addForeignKeyPremiumPartners -- procedure that adds a foreign key constraint to table PremiumPartners on column TopPartnerFromCompanyID
    AS
    BEGIN TRY
    ALTER TABLE PremiumPartners
    add constraint fk_PartnersInsurers foreign key(TopPartnerFromCompanyID) references Insurers(InsurerID); -- adding the constraint named fk_PartnersInsurers
        print 'Added foreign key to Premium Partners' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not add foreign key constraint' -- if something went wrong, this is printed
    end catch

go

CREATE PROCEDURE removeForeignKeyPremiumPartners -- procedure that removes a foreign key constraint from table PremiumPartners, column TopPartnerFromCompanyID
    AS
    BEGIN TRY
    ALTER TABLE PremiumPartners
    drop constraint fk_PartnersInsurers; -- removing constraint fk_PartnersInsurers
    print 'Removed foreign key from Premium Partners' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not remove foreign key constraint' -- if something went wrong, this is printed
    end catch

    go
-- g. create / drop a table

CREATE PROCEDURE createTypesOfPartnersTable -- procedure that creates table TypesOfPartners
AS
    BEGIN TRY
        CREATE TABLE TypesOfPartners( -- creating the table
            TypeID int PRIMARY KEY,
            Name varchar(50),
        )
        print 'Created new table TypesOfPartners' -- printed if change was successfull
    end try
    BEGIN CATCH
        PRINT 'Could not create table' -- if something went wrong, this is printed
    end catch

go

CREATE PROCEDURE dropTypesOfPartnersTable -- procedure that drops table TypesOfPartners
AS
    BEGIN TRY
        DROP TABLE TypesOfPartners; -- dropping table
        print 'Dropped table TypesOfPartners' -- printed if change was successfull
    end TRY
    BEGIN CATCH
        PRINT 'Could not drop table' -- if something went wrong, this is printed
    end catch

go
-- Versioning the database


-- table that holds one line with one column, an integer representing the current version of the database
CREATE TABLE Version( 
    CurrentVersion int
)
-- table that holds lines representing each version with its specific operation and reverse operation
CREATE TABLE OperationsReverseOperations(
    Version int PRIMARY KEY,
    Operation varchar(100),
    ReverseOperation varchar(100)
)
-- populating the table with versions, adding 7 versions to it
INSERT INTO OperationsReverseOperations (Version, Operation, ReverseOperation) VALUES
(1,'modifyTypeToFloat', 'modifyTypeToInt'),
(2,'addEmailToInsurers', 'dropEmailFromInsurers'),
(3,'addDefaultOnDescriptionInCoverage', 'removeDefaultOnDescriptionInCoverage'),
(4,'addPrimaryKeyPremiumPartners', 'removePrimaryKeyPremiumPartners'),
(5,'addCandidateKeyPremiumPartners', 'removeCandidateKeyPremiumPartners'),
(6,'addForeignKeyPremiumPartners', 'removeForeignKeyPremiumPartners'),
(7,'createTypesOfPartnersTable', 'dropTypesOfPartnersTable')

INSERT INTO Version (CurrentVersion) VALUES (0) -- the current version is 0 in the beginning

go

CREATE PROCEDURE nextVersion(@currentVersion int, @newVersion int) -- procedure that goes from currentVersion to newVersion when newVersion is greater
AS
    BEGIN
        	declare @operation varchar(50) -- the operation to be performed
            declare CursorOperationsReverse cursor for -- cursor for getting all operations to be performed sorted ascending by version number
                select Operation
                from OperationsReverseOperations
                where OperationsReverseOperations.Version > @currentVersion and Version <= @newVersion
                order by Version
            
            open CursorOperationsReverse
            fetch CursorOperationsReverse into @operation -- getting the first operation from the cursor

            while @@FETCH_STATUS = 0 -- loop to go through all operations from the cursos
            begin
                exec @operation -- executing the operation
                fetch CursorOperationsReverse into @operation -- getting the next operation from the cursor 
            end

            close CursorOperationsReverse -- closing the cursor
            deallocate CursorOperationsReverse 

            UPDATE Version 
            set Version.CurrentVersion = @newVersion -- updating the current version from the Version table to the new version
    end

go

CREATE PROCEDURE previousVersion(@currentVersion int, @newVersion int) -- procedure that goes from currentVersion to newVersion when newVersion is smaller
AS
    BEGIN
        declare @reverseOperation varchar(50) -- the reverse operation to be performed
            declare CursorOperationsReverse cursor for -- cursor for getting all reverse operations to be performed sorted descending by version number
                select ReverseOperation
                from OperationsReverseOperations
                where OperationsReverseOperations.Version <= @currentVersion and Version > @newVersion
                order by Version desc

            open CursorOperationsReverse
            fetch CursorOperationsReverse into @reverseOperation -- getting the first reverse operation from the cursor
            while @@FETCH_STATUS = 0 -- loop to go through all operations from the cursos
            begin
                exec @reverseOperation -- executing the operation
                fetch CursorOperationsReverse into @reverseOperation -- getting the next operation from the cursor 
            end
            close CursorOperationsReverse -- closing the cursor
            deallocate CursorOperationsReverse

            update Version
            set Version.CurrentVersion = @newVersion -- updating the current version from the Version table to the new version
    end

go

CREATE PROCEDURE changeVersion(@newVersion int) -- main procedure that changes the current version of the database to newVersion
AS
    BEGIN
        if @newVersion < 0 or @newVersion > 7 -- checking if the requested version is valid
            begin
                print 'Version is not supported' -- printing a message and returning if it was not valid
                return
            end
        declare @currentVersion int
        set @currentVersion = (select CurrentVersion from Version) -- getting the current version from table Version

        if @currentVersion < @newVersion -- checking if the current version is older than the requested one
            begin
                exec nextVersion @currentVersion, @newVersion -- executing procedure nextVersion in this case
                return
            end
        if @currentVersion > @newVersion -- otherwise, if the current version is newer than the requested one
            begin
                exec previousVersion @currentVersion, @newVersion -- going back to newVersion with procedure previousVersion
                return
            end
        print 'Same version' -- otherwise, the versions are equal, so there is no need to execute anything, prints a message

    end
go

--
-- changeVersion 0;
-- go
-- changeVersion 3;
-- go
-- changeVersion 7;
-- go
-- changeVersion 2;
-- go
-- changeVersion 0;
-- go
-- changeVersion 1;