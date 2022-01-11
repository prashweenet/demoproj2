-------------------------------------------------------------------------------
--
--  Filename      : Post_Accrul_RenameObsoleteTables.sql
--
--  Module        : ACCRUL
--
--  Purpose       : This script will Rename multi company related tables( since the GENLED uses these table data for update need to handle through a post script.)
--
--
--  Date    Sign    History
--  ------  ------  -------------------------------------------------------------
--  161221  THPELK  Created
--
---------------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RenameObsoleteTables.sql','Timestamp_1');
PROMPT Post_Accrul_RenameObsoleteTables.SQL

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RenameObsoleteTables.sql','Timestamp_2');
PROMPT RENAME multi company TABLES

DECLARE
BEGIN
   IF (Database_SYS.Table_Exist('MULTI_COMPANY_VOUCHER_TAB'))  THEN
      Database_SYS.Rename_Table('MULTI_COMPANY_VOUCHER_TAB','MULTI_COMPANY_VOUCHER_1000', TRUE);
   END IF;
   IF (Database_SYS.Table_Exist('MULTI_COMPANY_VOUCHER_ROW_TAB'))  THEN
      Database_SYS.Rename_Table('MULTI_COMPANY_VOUCHER_ROW_TAB','MULTI_COMPANY_VOUCHER_ROW_1000', TRUE);
   END IF;
END;
/
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RenameObsoleteTables.sql','Done');


