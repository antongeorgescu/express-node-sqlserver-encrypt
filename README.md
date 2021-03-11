# Sql Server Data Encryption @ Field Level

## Design Considerations

![Sql-Server-Encryption-Combinations](https://user-images.githubusercontent.com/6631390/110805630-45341300-824f-11eb-810b-0917a2326756.gif)

## Database Encryption Configurations

### Create CustomerData database
For the purpose of this project we are going to create a test database, which we will call StudentLoans. There are one sql scripts in the project, under **database** folder calles **createStudentLoansDb.sql**
Run the script in a database where you have **db_owner** privileges

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
**`SET BankACCNumber_encrypt = EncryptByKey (Key_GUID('SymKey_test'), BankACCNumber)`**<br/>
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

A user with the read permission cannot decrypt data using the symmetric key. For the current project, we will create two users (that correspond to 2 roles actually) and provide both **db_datareader** permissions on **StudentLoans** database:

**`USE [master]`** <br/>
**`GO`** <br/>
**`CREATE LOGIN [csr] WITH PASSWORD=N'reporter@1', DEFAULT_DATABASE=[StudentLoans], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF`** <br/>
**`GO`** <br/>
**`CREATE LOGIN [manager] WITH PASSWORD=N'contributorr@1', DEFAULT_DATABASE=[StudentLoans], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF`** <br/>
**`GO`** <br/>
**`USE [StudentLoans]`** <br/>
**`GO`** <br/>
**`CREATE USER [csr] FOR LOGIN [csr]`** <br/>
**`GO`** <br/>
**`CREATE USER [manager] FOR LOGIN [manager]`** <br/>
**`GO`** <br/>
**`USE [StudentLoans]`** <br/>
**`GO`** <br/>
**`ALTER ROLE [db_datareader] ADD MEMBER [csr]`** <br/>
**`GO`** <br/>
**`ALTER ROLE [db_datareader] ADD MEMBER [manager]`** <br/>
**`GO`** <br/>

Then provide "encrypted view" privileges to [manager] role
**`GRANT VIEW DEFINITION ON SYMMETRIC KEY::SymKey_test TO manager; `** <br/>
**`GO`** <br/>
**`GRANT VIEW DEFINITION ON Certificate::[Certificate_test] TO manager;`** <br/>
**`GO`** <br/>
**`GRANT CONTROL ON Certificate::[Certificate_test] TO manager;`** <br/>

### Test permissions granted
Run the above data query for the two users (roles) created: **csr** and **manager**
