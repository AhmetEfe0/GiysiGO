-- Yalnız Test-CatalogData.ps1 tarafından oluşturulan ve adı doğrulanan test veritabanını temizler.
IF DB_ID(N'$(DatabaseName)') IS NOT NULL
BEGIN
    ALTER DATABASE [$(DatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END;
