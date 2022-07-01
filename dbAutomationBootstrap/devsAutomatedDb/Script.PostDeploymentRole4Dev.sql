-- This file contains SQL statements that will be executed after the build script.
-- This file contains SQL statements that will be executed after the build script.
-- Write your own SQL object definition here, and it'll be included in your package.
--setup db owners
CREATE USER [edge-engineering-db-owners] FROM EXTERNAL PROVIDER;
ALTER ROLE db_owner ADD MEMBER [edge-engineering-db-owners];

--DeploymentUser
--Commented, this needs to be thoughtout before added
--Should only be required for the pipeline deployments
--Future should be to setup a specific user for each new db
-- CREATE USER [DeploymentUser] WITH PASSWORD='';
-- EXEC sys.sp_addrolemember @rolename = N'db_owner', @membername = N'DeploymentUser';

--setup readers
CREATE USER [edge-engineering] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [edge-engineering];

--dev only
ALTER ROLE db_owner ADD MEMBER [edge-engineering];

-- CREATE USER [edge-engineering-qa FROM EXTERNAL PROVIDER;
-- ALTER ROLE db_datareader ADD MEMBER [edge-engineering-qa];

CREATE USER [edge-engineering-data-science] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [edge-engineering-data-science];

CREATE USER [Data Solutions Group] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [Data Solutions Group];