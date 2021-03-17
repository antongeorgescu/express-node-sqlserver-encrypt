USE [master]
GO

/****** Object:  Database [StudentLoans]    Script Date: 3/11/2021 1:35:20 PM ******/
DROP DATABASE [StudentLoans]
GO

/****** Object:  Database [StudentLoans]    Script Date: 3/11/2021 1:35:20 PM ******/
CREATE DATABASE [StudentLoans]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CustomerData', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\CustomerData.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'CustomerData_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\CustomerData_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [StudentLoans].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [StudentLoans] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [StudentLoans] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [StudentLoans] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [StudentLoans] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [StudentLoans] SET ARITHABORT OFF 
GO

ALTER DATABASE [StudentLoans] SET AUTO_CLOSE ON 
GO

ALTER DATABASE [StudentLoans] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [StudentLoans] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [StudentLoans] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [StudentLoans] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [StudentLoans] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [StudentLoans] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [StudentLoans] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [StudentLoans] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [StudentLoans] SET  ENABLE_BROKER 
GO

ALTER DATABASE [StudentLoans] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [StudentLoans] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [StudentLoans] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [StudentLoans] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [StudentLoans] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [StudentLoans] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [StudentLoans] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [StudentLoans] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [StudentLoans] SET  MULTI_USER 
GO

ALTER DATABASE [StudentLoans] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [StudentLoans] SET DB_CHAINING OFF 
GO

ALTER DATABASE [StudentLoans] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [StudentLoans] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [StudentLoans] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [StudentLoans] SET QUERY_STORE = OFF
GO

ALTER DATABASE [StudentLoans] SET  READ_WRITE 
GO

USE [StudentLoans]
GO
/****** Object:  User [FullAccess]    Script Date: 3/17/2021 5:50:00 PM ******/
CREATE USER [FullAccess] FOR LOGIN [FullAccess] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [RestrictedAccess]    Script Date: 3/17/2021 5:50:00 PM ******/
CREATE USER [RestrictedAccess] FOR LOGIN [RestrictedAccess] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [FullAccess]
GO
ALTER ROLE [db_datareader] ADD MEMBER [RestrictedAccess]
GO

/****** Object:  Table [dbo].[CustomerInfo]    Script Date: 3/11/2021 1:40:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomerInfo]') AND type in (N'U'))
DROP TABLE [dbo].[CustomerInfo]
GO

/****** Object:  Table [dbo].[CustomerInfo]    Script Date: 3/17/2021 5:50:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInfo](
	[borrower_id] [int] NOT NULL,
	[full_name] [varchar](50) NOT NULL,
	[sin] [varchar](9) NOT NULL,
	[sin_encrypt] [varbinary](max) NULL,
 CONSTRAINT [PK__Customer__049E3A89EBDE5335] PRIMARY KEY CLUSTERED 
(
	[borrower_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

INSERT INTO dbo.CustomerInfo (borrower_id,full_name, sin)  VALUES ( 1,'Johnny Cecotto','514321234')
GO
INSERT INTO dbo.CustomerInfo (borrower_id,full_name, sin)  VALUES ( 2,'Toni Alvianda','513231452')
GO
INSERT INTO dbo.CustomerInfo (borrower_id,full_name, sin)  VALUES ( 3,'Costel Fistic','515234178')
GO
INSERT INTO dbo.CustomerInfo (borrower_id,full_name, sin)  VALUES ( 4,'Daniel Barbalat','514786543')
GO
INSERT INTO dbo.CustomerInfo (borrower_id,full_name, sin)  VALUES ( 5,'Joe Kourich','513999567')
GO

/****** Object:  Table [dbo].[Organization]    Script Date: 3/17/2021 5:47:10 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Organization]') AND type in (N'U'))
DROP TABLE [dbo].[Organization]
GO

/****** Object:  Table [dbo].[Organization]    Script Date: 3/17/2021 5:50:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organization](
	[org_id] [tinyint] NOT NULL,
	[name] [varchar](50) NULL,
	[description] [varchar](200) NULL,
 CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED 
(
	[org_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [StudentLoans].[dbo].[Organization] (org_id,name,description) VALUES (1,'UGuelph','University of Guelph, Guelph, ON')
INSERT INTO [StudentLoans].[dbo].[Organization] (org_id,name,description) VALUES (2,'UWaterloo','University of Waterloo, Waterloo, ON')
INSERT INTO [StudentLoans].[dbo].[Organization] (org_id,name,description) VALUES (3,'CSheridan','Sheridan College, Oakville, ON')
INSERT INTO [StudentLoans].[dbo].[Organization] (org_id,name,description) VALUES (4,'NSLSC','National Student Loans Service Centre')
GO

/****** Object:  Table [dbo].[Tenant]    Script Date: 3/11/2021 1:40:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tenant]') AND type in (N'U'))
DROP TABLE [dbo].[Tenant]
GO

/****** Object:  Table [dbo].[Tenant]    Script Date: 3/17/2021 5:50:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tenant](
	[tenant_id] [tinyint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[description] [varchar](250) NULL,
 CONSTRAINT [PK_Tenant] PRIMARY KEY CLUSTERED 
(
	[tenant_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [StudentLoans].[dbo].[Tenant] (tenant_id,name,description) VALUES (1,'FedUniFT','Federal university full-time loans')
INSERT INTO [StudentLoans].[dbo].[Tenant] (tenant_id,name,description) VALUES (2,'ProvColPT','Provincial college part-time loans')
GO

/****** Object:  Table [dbo].[Loan]    Script Date: 3/11/2021 1:40:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Loan]') AND type in (N'U'))
DROP TABLE [dbo].[Loan]
GO

/****** Object:  Table [dbo].[Loan]    Script Date: 3/17/2021 5:50:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loan](
	[loan_id] [smallint] NOT NULL,
	[tenant_id] [tinyint] NOT NULL,
	[org_id] [tinyint] NOT NULL,
	[amount] [money] NOT NULL,
	[due_date] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_Loan] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (1,1,1,13566.00,'Sep 23 2021 12:00AM')
INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (2,2,3,7455.00,'Mar 15 2022 12:00AM')
INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (3,2,2,12234.00,'May 21 2023 12:00AM')
INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (4,1,1,8677.00,'Jun 21 2023 12:00AM')
INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (5,2,3,3245.00,'Nov 13 2021 12:00AM')
INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (6,1,2,21345.00,'Oct 16 2023 12:00AM')
INSERT INTO [StudentLoans].[dbo].[Loan] (loan_id,tenant_id,org_id,amount,due_date) VALUES (7,2,3,5433.00,'Sep  3 2023 12:00AM')
GO

/****** Object:  Table [dbo].[CustomerLoan]    Script Date: 3/11/2021 1:40:41 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomerLoan]') AND type in (N'U'))
DROP TABLE [dbo].[CustomerLoan]
GO

/****** Object:  Table [dbo].[CustomerLoan]    Script Date: 3/17/2021 5:50:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerLoan](
	[borrower_id] [int] NOT NULL,
	[loan_id] [smallint] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CustomerLoan]  WITH CHECK ADD  CONSTRAINT [FK_CustomerLoan_CustomerInfo] FOREIGN KEY([borrower_id])
REFERENCES [dbo].[CustomerInfo] ([borrower_id])
GO
ALTER TABLE [dbo].[CustomerLoan] CHECK CONSTRAINT [FK_CustomerLoan_CustomerInfo]
GO
ALTER TABLE [dbo].[CustomerLoan]  WITH CHECK ADD  CONSTRAINT [FK_CustomerLoan_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[CustomerLoan] CHECK CONSTRAINT [FK_CustomerLoan_Loan]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_Organization] FOREIGN KEY([org_id])
REFERENCES [dbo].[Organization] ([org_id])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_Organization]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_Tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[Tenant] ([tenant_id])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_Tenant]
GO
ALTER TABLE [dbo].[Tenant]  WITH CHECK ADD  CONSTRAINT [FK_Tenant_Tenant] FOREIGN KEY([tenant_id])
REFERENCES [dbo].[Tenant] ([tenant_id])
GO
ALTER TABLE [dbo].[Tenant] CHECK CONSTRAINT [FK_Tenant_Tenant]
GO

INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (1,1)
INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (1,2)
INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (2,3)
INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (3,4)
INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (4,5)
INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (5,6)
INSERT INTO [StudentLoans].[dbo].[CustomerLoan] (borrower_id,loan_id) VALUES (5,7)
GO
