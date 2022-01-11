--------------------------------------------------------------------------
--  File:      Post_Accrul_HandleLuModifications.sql
--
--  Module:    ACCRUL
--
--  Purpose:   Hanlde object connections and other Lu modifications after changing keys.
--
--  Date    Sign   History
--  ------  -----  -------------------------------------------------------
--  180216  Umdolk Created.
--------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_HandleLuModifications.sql','Timestamp_1');
PROMPT Starting Post_Accrul_HandleLuModifications.sql

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_HandleLuModifications.sql','Timestamp_2');
PROMPT Handle Lu Modifications for user_group_period_tab
BEGIN
   Database_SYS.Handle_Lu_Modification('ACCRUL', 'UserGroupPeriod', in_regenerate_key_ref_=>TRUE);
   COMMIT;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_HandleLuModifications.sql','Timestamp_3');
PROMPT Handle Lu Modifications for multi_company_voucher_tab
BEGIN
   Database_SYS.Handle_Lu_Modification('ACCRUL', 'MultiCompanyVoucher', 'Voucher');
   COMMIT;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_HandleLuModifications.sql','Timestamp_4');
PROMPT Handle Lu Modifications for multi_company_voucher_row_tab
BEGIN
   Database_SYS.Handle_Lu_Modification('ACCRUL', 'MultiCompanyVoucherRow', 'VoucherRow', in_regenerate_key_ref_=>TRUE, key_ref_map_ =>'ROW_NO=MULTI_COMPANY_ROW_NO');
   COMMIT;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_HandleLuModifications.sql','Done');
PROMPT Finished with Post_Accrul_HandleLuModifications.SQL
