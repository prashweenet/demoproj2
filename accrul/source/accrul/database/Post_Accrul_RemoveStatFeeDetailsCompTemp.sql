--
--  File    : Post_Accrul_RemoveStatFeeDetailCompTemp.sql
--
--  Module  : ACCRUL
--
--  Usage   : Remove StatutoryFeeDetail Lu in Comp templates
--
--  Date      Sign       History
--  --------  -------    ---------------------------------------------------------------------------------------
--  161130    Hiralk     Created.
----------------------------------------------------------------------------------------------------------------

SET SERVEROUT ON
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveStatFeeDetailsCompTemp.sql','Timestamp_1');
PROMPT Starting Post_Accrul_RemoveStatFeeDetailCompTemp.sql

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveStatFeeDetailsCompTemp.sql','Timestamp_2');
PROMPT Remove StatutoryFeeDetail lu from company templates

DECLARE

BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Remove_Cre_Comp_Lu('ACCRUL', 'StatutoryFeeDetail');
   COMMIT;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_RemoveStatFeeDetailsCompTemp.sql','Done');
PROMPT Finished with Post_Accrul_RemoveStatFeeDetailsCompTemp.sql
