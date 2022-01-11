-----------------------------------------------------------------------------
--
--  Post_Accrul_RefreshCostStructCache.sql
--
--  Purpose:  This script will refresh project cost structure cach tables.
--
--
--  Date    Sign    History
--  ------  ----    ---------------------------------------------------------
--  140814  Jeguse  Created.
--  160520  kgamlk  Moved to Accrul
-----------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RefreshCostStructCache.sql','Timestamp_1');
PROMPT Start Post_Accrul_RefreshCostStructCache.sql

DECLARE
   CURSOR get_rec IS
      SELECT *
      FROM   cost_structure_tab;
BEGIN
   FOR rec_ IN get_rec LOOP
     Cost_Structure_Util_API.Refresh_Structure_Cache (rec_.company, rec_.cost_structure_id);
   END LOOP;
END;
/
COMMIT;


PROMPT Finish Post_Accrul_RefreshCostStructCache.sql
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RefreshCostStructCache.sql','Done');
