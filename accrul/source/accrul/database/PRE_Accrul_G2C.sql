-----------------------------------------------------------------------------
--  Module : ACCRUL
--
--  File   : PRE_Accrul_G2C.sql
--
--  Function:  This file is intended to Execute at the begining of the upgrade, if upgrading from versions 9.1.0-GET
--             Handles obsolete functionalities and ensures error free execution of core UPG files
--
--  IFS Developer Studio Template Version 2.6
--
--  Date     Sign    History
--  ------   ------  --------------------------------------------------
--  191004   Ashelk  Created Sample. Content will be added later
--  191003   Nijilk  Created.
--  200729   Jadulk  FISPRING20-6727, Renamed supplier_tax_info_tab.
--  210222   Basblk  Added update statement for TAX_CODE_TEXTS_TAB to set null values in EXC_FROM_SPESOMETRO_DEC column to false.
--  ------   ------  --------------------------------------------------
-----------------------------------------------------------------------------

SET SERVEROUTPUT ON
DEFINE MODULE = 'ACCRUL'

------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------
-- SECTION 1: HANDLING OF FUNCTIONALITIES MOVED INTO CORE/FUNCTIONALITIES OBSOLETE IN EXT LAYER

--    Sub Section: Make nullable/rename table columns, drop table columns from temporary tables moved to core

--    Sub Section: Rename tables moved to core
--       Pre Upgrade sections: tax_code_struct_tab
--       Pre Upgrade sections: tax_code_struct_det_tab
--       Pre Upgrade sections: tax_code_struct_det_ref_tab
--       Pre Upgrade sections: supplier_tax_info_tab
--    Sub Section: Drop packages/views moved to core
--       Pre Upgrade sections: tax_code_struct_tab
--       Pre Upgrade sections: tax_code_struct_det_tab
--       Pre Upgrade sections: tax_code_struct_det_ref_tab
--
--    Sub Section: Remove company creation basic data moved to core

-- SECTION 2: ENSURING ERROR-FREE EXECUTION OF CORE UPG FILES
--    Sub Section: Provide Oracle Default values to columns added to core tables
--        Pre Upgrade sections: currency_type_basic_data_tab
--        Pre Upgrade sections: tax_code_texts_tab

---------------------------------------------------------------------------------------------
-- SECTION 1 : HANDLING OF FUNCTIONALITIES MOVED INTO CORE/FUNCTIONALITIES OBSOLETE IN EXT LAYER
---------------------------------------------------------------------------------------------

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_1');
PROMPT Starting PRE_Accrul_G2C.sql

---------------------------------------------------------------------------------------------
--------------------- Make nullable/rename table columns moved to core-----------------------
---------------------------------------------------------------------------------------------

-- ***** tax_code_struct_tab Start *****
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_2');
PROMPT rename table tax_code_struct_tab
DECLARE
   new_table_name_   VARCHAR2(30):= 'TAX_CODE_STRUCT_910';
   old_table_name_   VARCHAR2(30):= 'TAX_CODE_STRUCT_TAB';
BEGIN
   IF NOT(Database_SYS.Table_Exist(new_table_name_))AND Database_SYS.Table_Exist(old_table_name_) THEN
      Database_SYS.Rename_Table(old_table_name_, new_table_name_, FALSE, TRUE, TRUE, TRUE);
   END IF;
END;
/
-- ***** tax_code_struct_tab End *****

-- ***** tax_code_struct_det_tab Start *****
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_3');
PROMPT rename table tax_code_struct_det_tab
DECLARE
   new_table_name_   VARCHAR2(30):= 'TAX_CODE_STRUCT_DET_910';
   old_table_name_   VARCHAR2(30):= 'TAX_CODE_STRUCT_DET_TAB';
BEGIN
   IF NOT(Database_SYS.Table_Exist(new_table_name_))AND Database_SYS.Table_Exist(old_table_name_) THEN
      Database_SYS.Rename_Table(old_table_name_, new_table_name_, FALSE, TRUE, TRUE, TRUE);
   END IF;
END;
/
-- ***** tax_code_struct_det_tab End *****

-- ***** tax_code_struct_det_ref_tab Start *****
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_4');
PROMPT rename table tax_code_struct_det_ref_tab
DECLARE
   new_table_name_   VARCHAR2(30):= 'TAX_CODE_STRUCT_DET_REF_910';
   old_table_name_   VARCHAR2(30):= 'TAX_CODE_STRUCT_DET_REF_TAB';
BEGIN
   IF NOT(Database_SYS.Table_Exist(new_table_name_))AND Database_SYS.Table_Exist(old_table_name_) THEN
      Database_SYS.Rename_Table(old_table_name_, new_table_name_, FALSE, TRUE, TRUE, TRUE);
   END IF;
END;
-- ***** tax_code_struct_det_ref_tab End *****

-- ***** supplier_tax_info_tab Start *****
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_5');
PROMPT Rename table supplier_tax_info_tab to supplier_tax_info_br_tab
DECLARE
   new_table_name_   VARCHAR2(30) := 'SUPPLIER_TAX_INFO_BR_TAB';
   old_table_name_   VARCHAR2(30) := 'SUPPLIER_TAX_INFO_TAB';
BEGIN
   IF (Database_SYS.Table_Exist(old_table_name_) AND NOT (Database_SYS.Table_Exist(new_table_name_))) THEN
      Database_SYS.Rename_Table(old_table_name_, new_table_name_, TRUE);
   END IF;
END;
/
-- ***** supplier_tax_info_tab End *****

---------------------------------------------------------------------------------------------
--------------------- Drop packages/views moved to core -------------------------------------
---------------------------------------------------------------------------------------------


exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_6');
PROMPT Removing  packages moved to core
BEGIN
   Database_SYS.Remove_Package('TAX_CODE_STRUCT_API', TRUE);
   Database_SYS.Remove_Package('TAX_CODE_STRUCT_DET_API', TRUE);
   Database_SYS.Remove_Package('TAX_CODE_STRUCT_DET_REF_API', TRUE);
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_7');
PROMPT Removing  views moved to core
BEGIN
   Database_SYS.Remove_View('TAX_CODE_STRUCT', TRUE);
   Database_SYS.Remove_View('TAX_CODE_STRUCT_CUST_LOV', TRUE);
   Database_SYS.Remove_View('TAX_CODE_STRUCT_DET', TRUE);
   Database_SYS.Remove_View('TAX_CODE_STRUCT_DET_REF', TRUE);
END;
/


---------------------------------------------------------------------------------------------
--------------------- Remove company creation basic data moved to core ----------------------
---------------------------------------------------------------------------------------------

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_8');
PROMPT removing  create company component detail
DECLARE
   module_ VARCHAR2(10) :='ACCRUL';
BEGIN
   Crecomp_Component_API.Remove_Component_Detail(module_,'TaxCodeStruct');
   Crecomp_Component_API.Remove_Component_Detail(module_,'TaxCodeStructDet');
   Crecomp_Component_API.Remove_Component_Detail(module_,'TaxCodeStructDetRef');
END;

-- End:Handling of Functionalities moved into core/Functionalities obsolete in Ext layer---

-- END SECTION 1: Handling of Functionalities moved into core/Functionalities obsolete in Ext layer---


---------------------------------------------------------------------------------------------
-- SECTION 2: ENSURING ERROR-FREE EXECUTION OF CORE UPG FILES -------------------------------
---------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------
--------------------- Add Oracle Defaults to NOT NULL Columns added to Core Tables ----------
---------------------------------------------------------------------------------------------

-- ***** currency_type_basic_data_tab Start *****
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_9');
PROMPT setting default value for use_tax_withh_rates to currency_type_basic_data_tab.
DECLARE
   columns_      Database_SYS.ColumnTabType;
   table_name_   VARCHAR2(30) := 'CURRENCY_TYPE_BASIC_DATA_TAB';
BEGIN
   Database_SYS.Reset_Column_Table(columns_);
   Database_SYS.Set_Table_Column(columns_, 'USE_TAX_WITHH_RATES', default_value_ => '''FALSE''');
   Database_SYS.Alter_Table( table_name_, columns_);
END;
/
-- ***** currency_type_basic_data_tab End *****

-----------------------------------------------------------------------------------------

-- ***** tax_code_texts_tab Start *****

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_10');
PROMPT renaming column annual_list_exemption to exc_from_spesometro_dec
DECLARE
   new_column_name_   VARCHAR2(30);
   old_column_name_   VARCHAR2(30);
   table_name_        VARCHAR2(30) := 'TAX_CODE_TEXTS_TAB';
   columns_           Database_SYS.ColumnTabType;
BEGIN
   new_column_name_ := 'EXC_FROM_SPESOMETRO_DEC';
   old_column_name_ := 'EXCLUDE_FROM_ANNUAL_LIST';
   IF NOT (Database_SYS.Column_Exist(table_name_, new_column_name_)) AND Database_SYS.Column_Exist(table_name_, old_column_name_) THEN
     Database_SYS.Rename_Column(table_name_, new_column_name_, old_column_name_, TRUE);
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_11');
PROMPT updating exc_from_spesometro_dec to false for null values
BEGIN
   IF (Database_SYS.Column_Exist('TAX_CODE_TEXTS_TAB','EXC_FROM_SPESOMETRO_DEC')) THEN
      UPDATE TAX_CODE_TEXTS_TAB
      SET    EXC_FROM_SPESOMETRO_DEC = 'FALSE'
      WHERE  EXC_FROM_SPESOMETRO_DEC IS NULL;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Timestamp_12');
PROMPT setting default value for exclude_from_annual_list to tax_code_texts_tab
DECLARE
   columns_      Database_SYS.ColumnTabType;
   table_name_   VARCHAR2(30) := 'TAX_CODE_TEXTS_TAB';
BEGIN
   Database_SYS.Reset_Column_Table(columns_);
   Database_SYS.Set_Table_Column(columns_, 'EXC_FROM_SPESOMETRO_DEC',  default_value_ => '''FALSE''');
   Database_SYS.Alter_Table( table_name_, columns_);
END;
/

-- ***** tax_code_texts_tab End *****

-----------------------------------------------------------------------------------------

-- END SECTION 2: ENSURING ERROR-FREE EXECUTION OF CORE UPG FILES -----------------------



UNDEFINE MODULE

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C.sql','Done');
PROMPT Finished with PRE_Accrul_G2C.sql
