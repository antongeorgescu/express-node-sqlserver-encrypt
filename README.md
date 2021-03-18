# Sql Server Data Encryption Methods

## Design Considerations

SQL Server provides the following mechanisms for encryption:

* Transact-SQL functions
* Asymmetric keys
* **`Symmetric keys`**
* **`Certificates`**
* Transparent Data Encryption (TDE)

This project covers the 3rd and 4th mechanisms in the list above

SQL Server encrypts data with a hierarchical encryption and key management infrastructure. Each layer encrypts the layer below it by using a combination of certificates, asymmetric keys, and symmetric keys. Asymmetric keys and symmetric keys can be stored outside of SQL Server in an Extensible Key Management (EKM) module.

The following illustration shows that each layer of the encryption hierarchy encrypts the layer beneath it, and displays the most common encryption configurations. The access to the start of the hierarchy is usually protected by a password.

![Sql-Server-Encryption-Combinations](https://user-images.githubusercontent.com/6631390/110805630-45341300-824f-11eb-810b-0917a2326756.gif)

## Database Encryption Configurations

### Create CustomerData database
For the purpose of this project we are going to create a test database, which we will call StudentLoans. There is one creation sql script in the project, under **database** folder calles **createStudentLoansDb.sql** <br/>
Run this script in a database where you have **db_owner** privileges

### Create a database master key for column level SQL Server encryption

**`USE StudentLoans;`**<br/>
**`GO`**<br/>
**`CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'encryption@1'`;**<br/>
**`GO`**<br/>

Use sys.symmetric_keys catalog view to verify the existence of this database master key in SQL Server encryption:

`SELECT name KeyName,symmetric_key_id KeyID,key_length KeyLength,algorithm_desc KeyAlgorithm` <br/>
`FROM sys.symmetric_keys;`

### Create a self-signed certificate for Column level SQL Server encryption

**`USE StudentLoans;`**<br/>
**`GO`**<br/>
**`CREATE CERTIFICATE Certificate_test WITH SUBJECT = 'Protect my data';`**<br/>
**`GO`**<br/>

Verify the certificate using the catalog view sys.certificates:

`SELECT name CertName,certificate_id CertID,pvt_key_encryption_type_desc EncryptType,issuer_name Issuer`<br/>
`FROM sys.certificates;`

In the output, we can note the following fields:

* **Encrypt Type**: In this column, we get a value ENCRYPTED_BY_MASTER_KEY, and it shows that SQL Server uses the database master key created in the previous step and protects this certificate
* **CertName**: It is the certificate name that we defined in the CREATE CERTIFICATE statement
* **Issuer**: We do not have a certificate authority certificate; therefore, it shows the subject value we defined in the CREATE CERTIFICATE statement<br/>
Optionally, we can use **ENCRYPTION BY PASSWORD** and **EXPIRY_DATE** parameters in the CREATE CERTIFICATE;

### Configure a symmetric key for column level SQL Server encryption

The symmetric key uses a single key for encryption and decryption as well. <br/>
In the image shared above, we can see the symmetric key on top of the data. <br/>
It is recommended to use the symmetric key for data encryption since we get excellent performance in it. <br/>
For column encryption, we use a multi-level approach, and it gives the benefit of the performance of the symmetric key and security of the asymmetric key.

**`CREATE SYMMETRIC KEY SymKey_test WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE Certificate_test;`**

Check the existing keys using catalog view for column level SQL Server Encryption as checked earlier:

`SELECT name KeyName,symmetric_key_id KeyID,key_length KeyLength,algorithm_desc KeyAlgorithm`<br/>
`FROM sys.symmetric_keys;`

### Setup Summary
So far, we have created the required encryption keys. It has the following setup that you can see in the image shown above as well:

* SQL Server installation creates a Service Master Key (SMK), and Windows operating system Data Protection API (DPAPI) protects this key
* This Service Master Key (SMK) protects the database master key (DMK)
* A database master key (DMK) protects the self-signed certificate
* This certificate protects the Symmetric key

## Database Encryption Operations

### Apply Encryption to Columns
SQL Server encrypted column datatype should be VARBINARY.

**`ALTER TABLE StudentLoans.dbo.CustomerInfo`** <br/>
**`ADD sin_encrypt varbinary(MAX)`**

Encrypt the data in this newly added column.

**`OPEN SYMMETRIC KEY SymKey_test DECRYPTION BY CERTIFICATE Certificate_test;`**

The following update uses EncryptByKey function and uses the symmetric function for encrypting the [sin] column and updates the values in the newly created [sin_encrypt] column:

**`UPDATE CustomerData.dbo.CustomerInfo`**<br/>
**`SET sin_encrypt = EncryptByKey (Key_GUID('SymKey_test'), sin)`**<br/>
**`FROM CustomerData.dbo.CustomerInfo;`** <br/>
**`GO`**

Close the symmetric key using the CLOSE SYMMETRIC KEY statement. If we do not close the key, it remains open until the session is terminated

**`CLOSE SYMMETRIC KEY SymKey_test;`**

### Read values of encrypted columns

Can be done by running the following set of 2 statements:

**`OPEN SYMMETRIC KEY SymKey_test DECRYPTION BY CERTIFICATE Certificate_test;`** <br/>
**`GO`** <br/>
**`SELECT borrower_id, full_name,sin_encrypt AS 'Encrypted data',`** <br/>
**`CONVERT(varchar, DecryptByKey(sin_encrypt)) AS 'Decrypted SIN#' `** <br/>
**`FROM StudentLoans.dbo.CustomerInfo;`**
**`GO`**

### Permissions required for decrypting data

A user with the read permission cannot decrypt data using the symmetric key. For the current project, we will create two users (that correspond to 2 permissions actually) and provide both **db_datareader** permissions on **StudentLoans** database:

**`USE [master]`** <br/>
**`GO`** <br/>
**`CREATE LOGIN [RestrictedAccess] WITH PASSWORD=N'reporter@1', DEFAULT_DATABASE=[StudentLoans], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF`** <br/>
**`GO`** <br/>
**`CREATE LOGIN [FullAccess] WITH PASSWORD=N'contributorr@1', DEFAULT_DATABASE=[StudentLoans], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF`** <br/>
**`GO`** <br/>
**`USE [StudentLoans]`** <br/>
**`GO`** <br/>
**`CREATE USER [RestrictedAccess] FOR LOGIN [RestrictedAccess]`** <br/>
**`GO`** <br/>
**`CREATE USER [FullAccess] FOR LOGIN [FullAccess]`** <br/>
**`GO`** <br/>
**`USE [StudentLoans]`** <br/>
**`GO`** <br/>
**`ALTER ROLE [db_datareader] ADD MEMBER [RestrictedAccess]`** <br/>
**`GO`** <br/>
**`ALTER ROLE [db_datareader] ADD MEMBER [FullAccess]`** <br/>
**`GO`** <br/>

Then provide "encrypted view" privileges to [FullAccess] permission
**`GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymKey_test TO FullAccess; `** <br/>
**`GO`** <br/>
**`GRANT VIEW DEFINITION ON Certificate::[Certificate_test] TO FullAccess;`** <br/>
**`GO`** <br/>
**`GRANT CONTROL ON Certificate::[Certificate_test] TO FullAccess;`** <br/>

### Test permissions granted
Run the above data query for the two users (permissions) created: **RestrictedAccess** and **FullAccess**

## Express with NodeJs and PUG Templates
This implementation mocks an authenticated user getting access to encrypted data

### Use Google Workspace Directory
This model is a combo og Google Workspace Directory and custom _security objects_. We are using an OAuth2 authentication based on a Google Workspace Directory structure, as in the following picture

![Google Workspace Directory](https://user-images.githubusercontent.com/6631390/111457541-b1e75b80-86ee-11eb-88b7-e47b615fd5e5.png)

:information_source: Note: for the purpose of the current Github implementation, we replaced the above authentication with a free user authentication combined with a local structure of objects that reflect the real Google Workspace Directory structure

### Use Azure Active Directory
The following security model is based on a combo of Azure AD and custom _security objects_. The native authentication is using Open ID Connect built on top of OAuth2 protocol.

The following two diagras show the conceptual security model and a concrete exemplification:

![Azure AD Centric Security Model](https://user-images.githubusercontent.com/6631390/111457258-57e69600-86ee-11eb-9101-2e133814c54e.png)

<br/>

![Azure AD Centric Security Model - Example](https://user-images.githubusercontent.com/6631390/111457323-6c2a9300-86ee-11eb-9714-7c7baaea4cc6.PNG)

## Student-Loans Database Schema
The following ERD shows the schema for the sample database used in this project.

![StudentLoans-Database-Schema](https://user-images.githubusercontent.com/6631390/111547092-08848200-874f-11eb-9cd7-1bd23af381ff.PNG)

## Secure Data Call to Sql Server Database
The following diagram illustrates the 3 layers of security that a Sql Server data call is supposed to go through:

1. access control through "connection string" and least privileged logins
2. transparent database encryption (TDE) applied to the whole Sql Server database for both data-in-transit and data-at-rest
3. column level encryption with symmetric/assymmetric keys stored in "database key vault"

![Secure data call to Sql Server](https://user-images.githubusercontent.com/6631390/111546996-e4c13c00-874e-11eb-9011-f9343a3fdbaa.PNG)

## Credits
* [SQLShack: An overview of the column level SQL Server encryption](https://www.sqlshack.com/an-overview-of-the-column-level-sql-server-encryption/)
* [Google Workspace - Directory API - Manage Entities](https://developers.google.com/admin-sdk/directory/v1/guides/manage-groups)
* [Google Workspace - Directory API - REST Resources](https://developers.google.com/admin-sdk/directory/reference/rest/v1/customers/update)
* [Google Workspace - Directory](https://developers.google.com/admin-sdk/directory)
