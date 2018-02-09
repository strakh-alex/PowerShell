USE master

/* Certificate will be encrypted by master-key.
If master-key was not generated before, create it uncommenting next two strings: 
*/

/*
CREATE MASTER KEY
    ENCRYPTION BY PASSWORD = 'pa$$w0rd'
*/

/* Generate Certificate */
CREATE CERTIFICATE CERTNAME
    WITH SUBJECT = 'For MSSQL backup encryption'

/* Make a backup of this certificate */
BACKUP CERTIFICATE CERTNAME
    TO FILE = 'C:\Cert\CERTNAME.cer'
    WITH PRIVATE KEY
            (
            FILE = 'C:\Cert\CERTNAME.pvk',
            ENCRYPTION BY PASSWORD = 'pa$$w0rd'
            )