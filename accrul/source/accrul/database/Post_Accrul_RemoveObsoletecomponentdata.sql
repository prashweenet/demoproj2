-----------------------------------------------------------------------------
--  Module : ACCRUL
--
--  File   : Post_Accrul_RemoveObsoletecomponentdata.sql
--
--  IFS Developer Studio Template Version 2.6
--
--  Date     Sign    History
--  ------   ------  --------------------------------------------------
--  200924   tkavlk  FISPRING20-6702, Removed Function Group 'C'(Consolidation)
--  ------   ------  --------------------------------------------------
-----------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveObsoletecomponentdata.sql','Timestamp_1');
PROMPT Post_Accrul_RemoveObsoletecomponentdata.sql

DECLARE
BEGIN
   DELETE FROM FUNCTION_GROUP_TAB f
      WHERE f.function_group = 'C';
   Basic_Data_Translation_API.Remove_Basic_Data_Translation('ACCRUL','FunctionGroup','C');
   COMMIT;
END;
/
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveObsoletecomponentdata.sql','Done');




