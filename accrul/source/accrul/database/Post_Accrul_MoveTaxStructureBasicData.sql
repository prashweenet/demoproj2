-----------------------------------------------------------------------------
--  Module : ACCRUL
--
--  File   : Post_Accrul_MoveTaxStructureBasicData.sql
--
--  IFS Developer Studio Template Version 2.6
--
--  Date     Sign    History
--  ------   ------  --------------------------------------------------
--  180526   chgulk  Created. gelr:Added to support Global Extension Functionalities
--  ------   ------  --------------------------------------------------
-----------------------------------------------------------------------------

SET SERVEROUTPUT ON
DEFINE MODULE = 'ACCRUL'

------------------------------------------------------------------------------------------


exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxStructureBasicData.sql','Timestamp_1');
PROMPT Starting Post_Accrul_MoveTaxStructureBasicData.sql

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxStructureBasicData.sql','Timestamp_2');
PROMPT Moving Data from TAX_CODE_STRUCT_910 to TAX_CALC_STRUCTURE_TAB

DECLARE
   stmt_     VARCHAR2(32767);
BEGIN
   IF Database_SYS.Table_Exist('TAX_CODE_STRUCT_910') THEN
        stmt_ := 'INSERT INTO tax_calc_structure_tab (company, tax_calc_structure_id, description, rowstate, rowversion, rowkey)'||
                 '      (SELECT st.company, st.tax_code_struct_id, st.description, ''Active'', SYSDATE, sys_guid()'||
                 '       FROM   tax_code_struct_910 st '||
                 '       WHERE NOT EXISTS (SELECT 1 FROM tax_calc_structure_tab t '||
                 '                         WHERE  t.company               = st.company '||
                 '                         AND    t.tax_calc_structure_id = st.tax_code_struct_id)) ';
        EXECUTE IMMEDIATE stmt_;
        COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxStructureBasicData.sql','Timestamp_3');
PROMPT Moving Data from TAX_CODE_STRUCT_DET_910 to TAX_STRUCTURE_ITEM_TAB

DECLARE
   stmt_     VARCHAR2(32767);
BEGIN
   IF Database_SYS.Table_Exist('TAX_CODE_STRUCT_DET_910') THEN
        stmt_ := 'INSERT INTO tax_structure_item_tab (company, tax_calc_structure_id, item_id, calculation_order,'||
                 '                                    tax_code, incl_price_in_tax_base, incl_manual_amnt_in_tax, rowversion, rowkey)'||
                 '      (SELECT st.company, st.tax_code_struct_id, st.tax_code_struct_item_id, st.calculation_order, st.fee_code,'||
                 '	           st.incl_net_amount_base, st.manual_base, SYSDATE, sys_guid()'||
                 '       FROM   tax_code_struct_det_910 st '||
                 '       WHERE NOT EXISTS (SELECT 1 FROM tax_structure_item_tab t '||
                 '                         WHERE  t.company               = st.company '||
                 '                         AND    t.tax_calc_structure_id = st.tax_code_struct_id'||
                 '                         AND    t.item_id               = st.tax_code_struct_item_id)) ';
        EXECUTE IMMEDIATE stmt_;
        COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxStructureBasicData.sql','Timestamp_4');
PROMPT Moving Data from TAX_CODE_STRUCT_DET_REF_910 to TAX_STRUCTURE_ITEM_REF_TAB

DECLARE
   stmt_     VARCHAR2(32767);
BEGIN
   IF Database_SYS.Table_Exist('TAX_CODE_STRUCT_DET_REF_910') THEN
        stmt_ := 'INSERT INTO tax_structure_item_ref_tab (company, tax_calc_structure_id, item_id, item_id_ref, rowversion, rowkey)'||
                 '      (SELECT st.company, st.tax_code_struct_id, st.tax_code_struct_item_id, st.tax_code_struct_item_id_ref, SYSDATE, sys_guid()'||
                 '       FROM   tax_code_struct_det_ref_910 st '||
                 '       WHERE NOT EXISTS (SELECT 1 FROM tax_structure_item_ref_tab t '||
                 '                         WHERE  t.company               = st.company '||
                 '                         AND    t.tax_calc_structure_id = st.tax_code_struct_id'||
                 '                         AND    t.item_id               = st.tax_code_struct_item_id'||
                 '                         AND    t.item_id_ref           = st.tax_code_struct_item_id_ref)) ';
        EXECUTE IMMEDIATE stmt_;
        COMMIT;
   END IF;
END;
/


UNDEFINE MODULE

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxStructureBasicData.sql','Done');
PROMPT Finished with Post_Accrul_MoveTaxStructureBasicData.sql
