-------------------------------------------------------------------------------
--
--  Filename      : Post_Accrul_RemoveObjectConnections.sql
--
--  Module        : ACCRUL
--
--  Purpose       :
--
--  Date          Sign    History
--  ------        ------  -------------------------------------------------------------
--  2017-05-08    THPELK  Created to remove object connections
---------------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveObjectConnections.sql','Timestamp_1');
PROMPT Post_Accrul_RemoveObjectConnections.sql

BEGIN
   Object_Connection_SYS.Disable_Logical_Unit('MultiCompanyVoucher');
   Object_Connection_SYS.Disable_Logical_Unit('MultiCompanyVoucherRow');

   COMMIT;
END;
/
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveObjectConnections.sql','Done');

