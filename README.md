# Sql Server Data Encryption @ Field Level

## Design Considerations

![Sql-Server-Encryption-Combinations](https://user-images.githubusercontent.com/6631390/110805630-45341300-824f-11eb-810b-0917a2326756.gif)

## Database Setup

### Create CustomerData database

### Create a database master key for column level SQL Server encryption

`USE CustomerData;`<br/>
`GO`<br/>
`CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'encryption@1'`;<br/>
`GO`<br/>

Use sys.symmetric_keys catalog view to verify the existence of this database master key in SQL Server encryption:

`SELECT name KeyName,symmetric_key_id KeyID,key_length KeyLength,algorithm_desc KeyAlgorithm` <br/>
`FROM sys.symmetric_keys;`

### Create a self-signed certificate for Column level SQL Server encryption

**`USE CustomerData;`**<br/>
`GO`<br/>
`CREATE CERTIFICATE Certificate_test WITH SUBJECT = 'Protect my data';`<br/>
`GO`<br/>

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

`CREATE SYMMETRIC KEY SymKey_test WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE Certificate_test;`

Check the existing keys using catalog view for column level SQL Server Encryption as checked earlier:

`SELECT name KeyName,symmetric_key_id KeyID,key_length KeyLength,algorithm_desc KeyAlgorithm`<br/>
`FROM sys.symmetric_keys;`

### Summary
So far, we have created the required encryption keys. It has the following setup that you can see in the image shown above as well:

* SQL Server installation creates a Service Master Key (SMK), and Windows operating system Data Protection API (DPAPI) protects this key
* This Service Master Key (SMK) protects the database master key (DMK)
* A database master key (DMK) protects the self-signed certificate
* This certificate protects the Symmetric key
