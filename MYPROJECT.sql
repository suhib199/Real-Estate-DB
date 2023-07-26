CREATE DATABASE EstateOffice;
USE EstateOffice;
GO
-----------------------------------------CREAT TABLES--------------------------------------
--1- RealEstate 
CREATE TABLE RealEstateTypes (
TypeNumber INT PRIMARY KEY,
TypeName VARCHAR(MAX) NOT NULL
);


-- 2-UserTypes 
CREATE TABLE UserTypes (
TypeNumber INT PRIMARY KEY,
TypeName VARCHAR(MAX) NOT NULL
);

-- 3-Users 
CREATE TABLE Users (
UserID INT PRIMARY KEY,
FirstName VARCHAR(MAX) NOT NULL,
LastName VARCHAR(MAX) NOT NULL,
Email VARCHAR(MAX) ,
PhoneNumber VARCHAR(10) NOT NULL UNIQUE CHECK (LEN(PhoneNumber)= 10 AND ISNUMERIC (PhoneNumber)=1)  ,--Jordanian phone number
Pass VARCHAR(MAX) NOT NULL ,
HomeAddress VARCHAR(MAX),
CONSTRAINT CheckPassword CHECK (LEN(Pass) >= 8 AND Pass LIKE '%[0-9]%'AND Pass LIKE '%[a-zA-Z]%')----- at least 8 characters and combination of letters and numbers
);
ALTER TABLE Users 
ADD CONSTRAINT EmailCheck CHECK (Email LIKE '%@%.%')

-- 4-RealEstates 
CREATE TABLE RealEstates (
EstateID INT PRIMARY KEY,
DateOfAddition DATE,
EstateNumber INT,
[Address] VARCHAR(MAX) NOT NULL,
PropertyDescription VARCHAR(MAX),
Price DECIMAL (18,2) NOT NULL,
Area DECIMAL (18,2) NOT NULL,
Bedrooms INT NOT NULL,
LivingRooms INT NOT NULL,
Kitchen INT NOT NULL,
Bathrooms INT NOT NULL,
HasElevator BIT NOT NULL,
);

-------------------Indexing to speed up the search process---------------------------------------
CREATE INDEX IX_Area_Price ON RealEstates (Area,Price);
-------------------------------------------------------------------------------------------------

--5-PurchaseOffers 
CREATE TABLE PurchaseOffers (
OfferID INT PRIMARY KEY,
EstateID INT,
UserID INT,
SubmissionDate DATE NOT NULL,
 IsApproved BIT NOT NULL,
ProposedPrice DECIMAL(18,2) NOT NULL,
CONSTRAINT PurchaseOffers_RealEstates_FK FOREIGN KEY (EstateID) REFERENCES RealEstates (EstateID),
CONSTRAINT PurchaseOffers_Users_FK FOREIGN KEY (UserID) REFERENCES Users (UserID)
);

--6-PropertyOwner 
CREATE TABLE PropertyOwner (
OwnerID INT PRIMARY KEY,
FirstName VARCHAR(MAX) NOT NULL,
LastName VARCHAR(MAX) NOT NULL,
Email VARCHAR(MAX) CHECK (Email LIKE '%@%.%'),----- Vaild email format (Can duplicate)
PhoneNumber VARCHAR(10) NOT NULL CHECK (LEN(PhoneNumber)= 10 AND ISNUMERIC (PhoneNumber)=1)
);


--7- MultipleOwner  (Estate can be owned by one or more user like this(many to many relationship)
CREATE TABLE MultipleOwner (
EstateID INT,
OwnerID INT,
PRIMARY KEY (EstateID,OwnerID),
FOREIGN KEY (EstateID) REFERENCES RealEstates (EstateID),
FOREIGN KEY (OwnerID) REFERENCES PropertyOwner (OwnerID)
);

-- 8-PropertyImages 
CREATE TABLE PropertyImages (
ImageID INT PRIMARY KEY,
EstateID INT,
ImageURL VARCHAR(MAX),
CONSTRAINT  PropertyImages_RealEstatesr_FK FOREIGN KEY (EstateID) REFERENCES RealEstates (EstateID)
);

-- 9-PropertyStatus 
CREATE TABLE PropertyStatus (
StatusID INT PRIMARY KEY,
StatusName VARCHAR(MAX)
);

-- 10-Negotiations 
CREATE TABLE Negotiations (
NegotiationID INT PRIMARY KEY,
OfferID INT,
NegotiationDate DATETIME,
NegotiationDetails VARCHAR(MAX),
CONSTRAINT  Negotiations_PurchaseOffers_FK FOREIGN KEY (OfferID) REFERENCES PurchaseOffers (OfferID)
);

--11-Contracts 
CREATE TABLE Contracts (
ContractID INT PRIMARY KEY,
EstateID INT,
BuyerID INT UNIQUE,
SellerID INT UNIQUE,
ContractDate DATE,
ContractTerms VARCHAR(MAX),
CONSTRAINT  Contracts_RealEstates_FK FOREIGN KEY (EstateID) REFERENCES RealEstates (EstateID),
CONSTRAINT  Contracts_Users_FK FOREIGN KEY (BuyerID) REFERENCES Users (UserID),
CONSTRAINT  Contracts_PurchaseOffers_FK FOREIGN KEY (SellerID) REFERENCES Users (UserID)
);

-- 12-Payments 
CREATE TABLE Payments (
PaymentID INT PRIMARY KEY,
ContractID INT NOT NULL,
PaymentDate DATETIME,
Price DECIMAL(18,2) NOT NULL,
CONSTRAINT  Payments_Contracts_FK  FOREIGN KEY (ContractID) REFERENCES Contracts (ContractID)
);

-- 13-Reviews 
CREATE TABLE Reviews (
ReviewID INT PRIMARY KEY,
EstateID INT NOT NULL,
UserID INT NOT NULL,
ReviewDate DATETIME,
Rating VARCHAR(5) NOT NULL,
ReviewComments VARCHAR(MAX),
CONSTRAINT  Reviews_RealEstates_FK FOREIGN KEY (EstateID) REFERENCES RealEstates (EstateID),
CONSTRAINT  Reviews_Users_FK FOREIGN KEY (UserID) REFERENCES Users (UserID),
CONSTRAINT Rating_From_5 CHECK (Rating BETWEEN 1 AND 5) --RATING FROM 5
);
SELECT*FROM USERS


---------------------------------------STORED PROCEDURE---------------------------------------------------
--	1-Insert     2-Update     3-Delete     4-Get Record By id     5-Search In Table 	 6-Get All Record
------------------------------------------For RealEstate Type table (1) ----------------------------------------	
--1- RealEstate 

-- 1-Insert
CREATE PROCEDURE InsertInToRealEstateType
@TypeNumber INT,
@TypeName VARCHAR(MAX)
AS
BEGIN
INSERT INTO RealEstateTypes (TypeNumber,TypeName)
VALUES (@TypeNumber,@TypeName)
END


-- 2-Update 
CREATE PROCEDURE UpdateRealEstateType
@TypeNumber INT,
@NewTypeName VARCHAR(MAX)
AS
BEGIN
UPDATE RealEstateTypes
SET TypeName = @NewTypeName
WHERE TypeNumber = @TypeNumber
END


-- 3-Delete 
CREATE PROCEDURE DeleteFromRealEstateType
@TypeNumber INT
AS
BEGIN
DELETE FROM RealEstateTypes
WHERE TypeNumber = @TypeNumber
END


--  4-Get depend on (TypeNumber)
CREATE PROCEDURE GetRealEstateTypeByID
@TypeNumber INT
AS
BEGIN
SELECT*FROM RealEstateTypes
WHERE TypeNumber = @TypeNumber
END



-- 5-Search by (TypeName)
CREATE PROCEDURE SearchRealEstateType
@SearchKey VARCHAR(MAX)
AS
BEGIN
SELECT*FROM RealEstateTypes
WHERE TypeName LIKE '%'+ @SearchKey +'%'
END


-- 6-Get all 
CREATE PROCEDURE GetAllRecordsRealEstateTypes
AS
BEGIN
SELECT*FROM RealEstateTypes
END



--To ensere that stored procedures for RealEstate table are working properly 
EXEC InsertInToRealEstateType 133,'Villas'
EXEC InsertInToRealEstateType 137,'Palaces' ---Insert
EXEC InsertInToRealEstateType 155,'Palaces'
EXEC InsertInToRealEstateType 158,'Buildings'
SELECT*FROM RealEstateTypes

EXEC UpdateRealEstateType 133,'Apartment' ---Update
SELECT*FROM RealEstateTypes

EXEC DeleteFromRealEstateType 133  ---Delete
SELECT*FROM RealEstateTypes

EXEC SearchRealEstateType 'Palaces'  ---Search
SELECT*FROM RealEstateTypes


-----------------------------------------For UserType table (2)-------------------------------------------	
--2-UserType

-- 1-Insert into UserTypes
CREATE PROCEDURE InsertInToUserType
@TypeNumber INT,@TypeName VARCHAR(MAX)
AS
BEGIN
INSERT INTO UserTypes (TypeNumber,TypeName)
VALUES (@TypeNumber, @TypeName)
END



-- 2-Update UserTypes
CREATE PROCEDURE UpdateUserType
@TypeNumber INT,@NewTypeName VARCHAR(MAX)
AS
BEGIN
UPDATE UserTypes
SET TypeName = @NewTypeName
WHERE TypeNumber = @TypeNumber
END


-- 3-Delete from UserTypes
CREATE PROCEDURE DeleteFromUserType
@TypeNumber INT
AS
BEGIN
DELETE FROM UserTypes
WHERE TypeNumber = @TypeNumber
END

-- 4-Get by (TypeNumber)
CREATE PROCEDURE GetByID
@TypeNumber INT
AS
BEGIN
SELECT *FROM UserTypes
WHERE TypeNumber = @TypeNumber
END

-- 5-Search by (TypeName)
CREATE PROCEDURE SearchUserType
@SearchKey VARCHAR(MAX)
AS
BEGIN
SELECT *FROM UserTypes
WHERE TypeName LIKE '%' + @SearchKey +'%'
END

--  6-Get all 
CREATE PROCEDURE GetAllUserTypes
AS
BEGIN 
SELECT *FROM UserTypes
END
-----------------------------------------For User table (3)-------------------------------------------
--3-User

-- 1-Insert into Users
CREATE PROCEDURE InsertInToUser
@UserID INT,
@FirstName VARCHAR(MAX),@LastName VARCHAR(MAX),@Email VARCHAR(MAX),@PhoneNumber VARCHAR(10),@Pass VARCHAR(MAX),@HomeAddress VARCHAR(MAX)
AS
BEGIN
INSERT INTO Users (UserID, FirstName, LastName, Email, PhoneNumber, Pass, HomeAddress)
VALUES (@UserID, @FirstName, @LastName, @Email, @PhoneNumber, @Pass, @HomeAddress)
END


-- 2-Update Users
CREATE PROCEDURE UpdateUser
@UserID INT,@NewFirstName VARCHAR(MAX), @NewLastName VARCHAR(MAX), @NewEmail VARCHAR(MAX), @NewPhoneNumber VARCHAR(10), @NewPass VARCHAR(30), @NewHomeAddress VARCHAR(MAX)
AS
BEGIN
UPDATE Users
SET FirstName = @NewFirstName,
LastName = @NewLastName, 
Email = @NewEmail, 
PhoneNumber = @NewPhoneNumber, 
Pass = @NewPass,
HomeAddress = @NewHomeAddress
WHERE UserID = @UserID
END


-- 3-Delete from Users
CREATE PROCEDURE DeleteFromUser
@UserID INT
AS
BEGIN
DELETE FROM Users
WHERE UserID = @UserID
END

-- 4-Get by (UserID)
CREATE PROCEDURE GetUserByID
@UserID INT
AS
BEGIN
SELECT *FROM Users
WHERE UserID = @UserID
END

-- 5-Search by (FirstName or LastName)
CREATE PROCEDURE SearchUser
@SearchKeyword VARCHAR(MAX)
AS
BEGIN
SELECT *FROM Users
WHERE FirstName LIKE '%'+ @SearchKeyword +'%' OR LastName LIKE '%'+ @SearchKeyword +'%'
END

-- 6-Get all Users
CREATE PROCEDURE GetAllUsers
AS
BEGIN
SELECT *FROM Users
END
-----------------------------------------For RealEstates table (4)-------------------------------------------
--4-RealEstates

-- 1-Insert into RealEstates
CREATE PROCEDURE InserInTotRealEstate
@EstateID INT, @DateOfAddition DATE, @EstateNumber INT, @Address VARCHAR(MAX), @PropertyDescription VARCHAR(MAX), 
@Price DECIMAL(18,2), @Area DECIMAL(18,2), @Bedrooms INT, @LivingRooms INT, @Kitchen INT, @Bathrooms INT, @HasElevator BIT
AS 
BEGIN
INSERT INTO RealEstates (EstateID, DateOfAddition, EstateNumber, [Address], PropertyDescription, Price, Area, Bedrooms, LivingRooms, Kitchen, Bathrooms, HasElevator)
VALUES (@EstateID, @DateOfAddition, @EstateNumber, @Address, @PropertyDescription, @Price, @Area, @Bedrooms, @LivingRooms, @Kitchen, @Bathrooms, @HasElevator)
END


-- 2-Update RealEstates
CREATE PROCEDURE UpdateRealEstate
@EstateID INT,@NewDateOfAddition DATE, @NewEstateNumber INT, @NewAddress VARCHAR(MAX), @NewPropertyDescription VARCHAR(MAX),
@NewPrice DECIMAL(18,2), @NewArea DECIMAL(18,2), @NewBedrooms INT, @NewLivingRooms INT, @NewKitchen INT, @NewBathrooms INT, @NewHasElevator BIT
AS
BEGIN
UPDATE RealEstates
SET DateOfAddition = @NewDateOfAddition,
EstateNumber = @NewEstateNumber,
[Address] = @NewAddress,
PropertyDescription = @NewPropertyDescription, 
Price = @NewPrice,
Area = @NewArea, 
Bedrooms = @NewBedrooms,
LivingRooms = @NewLivingRooms, 
Kitchen = @NewKitchen, 
Bathrooms = @NewBathrooms, 
HasElevator = @NewHasElevator
WHERE EstateID = @EstateID
END


-- 3-Delete from RealEstates
CREATE PROCEDURE DeleteFromRealEstate
@EstateID INT
AS
BEGIN
DELETE FROM RealEstates
WHERE EstateID = @EstateID
END


--  4-Get by (EstateID)
CREATE PROCEDURE GetRealEstateByID
@EstateID INT
AS
BEGIN
SELECT *FROM RealEstates
WHERE EstateID = @EstateID
END

-- 5-Search RealEstates by Address
CREATE PROCEDURE SearchRealEstate
@SearchKeyword VARCHAR(MAX)
AS
BEGIN
SELECT *FROM RealEstates
WHERE [Address] LIKE '%' + @SearchKeyword +'%'
END

-- 6-Get all 
CREATE PROCEDURE GetAllRealEstates
AS
BEGIN
SELECT *FROM RealEstates
END
-----------------------------------------For PurchaseOfferss table (5)-------------------------------------------
-- 5-PurchaseOfferss

-- 1-Insert into PurchaseOffers
CREATE PROCEDURE InsertInToPurchaseOffer
@OfferID INT, @EstateID INT, @UserID INT, @SubmissionDate DATE, @IsApproved BIT , @ProposedPrice DECIMAL(18,2)
AS
BEGIN
INSERT INTO PurchaseOffers (OfferID, EstateID, UserID, SubmissionDate, IsApproved, ProposedPrice)
VALUES (@OfferID, @EstateID, @UserID, @SubmissionDate, @IsApproved, @ProposedPrice)
END


-- 2-Update PurchaseOffers
CREATE PROCEDURE UpdatePurchaseOffer
@OfferID INT, @NewEstateID INT, @NewUserID INT, @NewSubmissionDate DATE, @NewIsApproved BIT, @NewProposedPrice DECIMAL(18,2)
AS
BEGIN
UPDATE PurchaseOffers
SET EstateID = @NewEstateID, 
UserID = @NewUserID, 
SubmissionDate = @NewSubmissionDate, 
IsApproved = @NewIsApproved, 
ProposedPrice = @NewProposedPrice
WHERE OfferID = @OfferID
END


-- 3-Delete from PurchaseOffers
CREATE PROCEDURE DeleteFromPurchaseOffer
@OfferID INT
AS
BEGIN
DELETE FROM PurchaseOffers
WHERE OfferID = @OfferID
END

-- 4-Get PurchaseOffers by OfferID
CREATE PROCEDURE GetPurchaseOfferByID
@OfferID INT
AS
BEGIN
SELECT *FROM PurchaseOffers
WHERE OfferID = @OfferID
END

-- 5-Get all PurchaseOffers
CREATE PROCEDURE GetAllPurchaseOffers
AS
BEGIN
SELECT *FROM PurchaseOffers
END
-----------------------------------------For PropertyOwner table (6)-------------------------------------------
-- 6-PropertyOwner

-- 1-Insert into PropertyOwner
CREATE PROCEDURE InsertIntoPropertyOwner
@OwnerID INT, @FirstName VARCHAR(MAX), @LastName VARCHAR(MAX), @Email VARCHAR(MAX), @PhoneNumber VARCHAR(10)
AS
BEGIN
INSERT INTO PropertyOwner (OwnerID, FirstName, LastName, Email, PhoneNumber)
VALUES (@OwnerID, @FirstName, @LastName, @Email, @PhoneNumber)
END


-- 2-Update PropertyOwner
CREATE PROCEDURE UpdatePropertyOwner
@OwnerID INT,@NewFirstName VARCHAR(MAX), @NewLastName VARCHAR(MAX), @NewEmail VARCHAR(MAX), @NewPhoneNumber VARCHAR(10)
AS
BEGIN
UPDATE PropertyOwner
SET FirstName = @NewFirstName,
LastName = @NewLastName,
Email = @NewEmail,
PhoneNumber = @NewPhoneNumber
WHERE OwnerID = @OwnerID
END


-- 3-Delete from PropertyOwner
CREATE PROCEDURE DeleteFromPropertyOwner
@OwnerID INT
AS
BEGIN
DELETE FROM PropertyOwner
WHERE OwnerID = @OwnerID
END


-- 4-Get by (OwnerID)
CREATE PROCEDURE GetPropertyOwnerByID
@OwnerID INT
AS
BEGIN
SELECT *FROM PropertyOwner
WHERE OwnerID = @OwnerID
END


-- 5-Search depending on (FirstName or LastName)
CREATE PROCEDURE SearchPropertyOwner
@SearchKeyword VARCHAR(MAX)
AS
BEGIN
SELECT *FROM PropertyOwner
WHERE FirstName LIKE '%'+ @SearchKeyword +'%' OR LastName LIKE '%'+ @SearchKeyword +'%'
END

-- 6-Get all PropertyOwner
CREATE PROCEDURE GetAllPropertyOwners
AS
BEGIN
SELECT *FROM PropertyOwner
END

------------------------------------------------Views---------------------------------------------------
-------------------------------a.User View: List all authors (First and Last Name) and their Address----------
CREATE VIEW UserView 
AS
SELECT FirstName, LastName, HomeAddress
FROM Users
-----------------------------b.Purchase Offer: List top 20 latest  Purchase Offer------------------ 
CREATE VIEW OfferView 
AS
SELECT TOP 20 *FROM PurchaseOffers
ORDER BY SubmissionDate DESC
----------------------------------- c.Estate View: List all Estate----------------------------------- 
CREATE VIEW AllEstateView 
AS
SELECT *FROM RealEstates
