CREATE TABLE Consolidator20_pruebas.dbo.CreditLimitRQ (
  Id int IDENTITY,
  CodeClientBackOffice int NULL,
  CodeClientOBT int NULL,
  Name varchar(200) NULL,
  ValidationLoc varchar(10) NULL,
  Value int NULL,
  Currency varchar(3) NULL,
  Product varchar(5) NULL,
  Description varchar(300) NULL,
  PaymentType varchar(10) NULL,
  UserEmail varchar(100) NULL,
  Status varchar(10) NULL,
  ValidationMessage varchar(300) NULL
)
GO