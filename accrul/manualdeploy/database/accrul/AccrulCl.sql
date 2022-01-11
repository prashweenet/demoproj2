--------------------------------------------------------------------------------
--
--  File:         AccrulCl.sql
--
--  Component:    ACCRUL
--
--  Purpose:      Remove copied default data tables and other temporary tables
--                used to upgrade Accounting Rules.
-- 
--  Localization: Not needed.
--
--  Notes:        
--
--  Date    Sign     History
--  ------  ----     --------------------------------------------------------------
--  030228  MGUTSE   Created.
--  030702  Pperse   Removing renamed Ext_Files tables  
--  040909  Nalslk   Removing renamed tables from 8.10.0 version
--  050726  THPELK   Remove the Remove Package for CURR_TYPE_DEF_API
--  051014  reanpl   FIAD376 Actual Costing, remove valid_until column from POSTING_CTRL_DETAIL_TAB and POSTING_CTRL_COMB_DETAIL_TAB
--  060608  iswalk   FIPL614A, remove combined_control_type from POSTING_CTRL_TAB and POSTING_CTRL_DETAIL_TAB.  
--  060619  iswalk   FIPL614A, remove allowed_default from POSTING_CTRL_CONTROL_TYPE_TAB.
--  070622  shsalk   B145889, Dropped unwanted triggers coming from MEE.
--  091007  AsHelk   Bug 86122, Added escape mechanism.
--  100317  Samwlk   EAFH-2552, Remove posting_ctrl_def_900.
--  210524  Kagalk   EAFH-2939, Removed column accrul_id from Transferred_Voucher_Tab, Voucher_Tab
--  130805  DipeLK   CAHOOK-1168, Removed column MAX_NUMBER_OF_CHAR_TEMP from ACCOUNTING_CODE_PART_TAB
--  141204  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from ACCOUNT_TYPE_TAB.
--  141205  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from POSTING_CTRL_ALLOWED_COMB_TAB.
--  141205  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from POSTING_CTRL_COMB_DETAIL_TAB.
--  141205  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from STATUTORY_FEE_TAB.
--  141208  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from TRANSFERRED_VOUCHER_TAB.
--  141208  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from USER_FINANCE_TAB.
--  141217  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from VOUCHER_TYPE_TAB.
--  141217  DipeLK   PRFI-3818,Dropping obsolete COLUMNS from VOUCHER_TYPE_USER_GROUP_TAB
--  150727  PKurlk   KES-1126, Removed column TAX_RECOVERABLE from STATUTORY_FEE_TAB.
--  151009  PRatlk   STRFI-26, Removed columns from ACCOUNTING_CODE_PART_VALUE_TAB.
--  160411  Paralk   FINHR-1446 , Removed columns from COMPANY_FINANCE_TAB.
--  160420  Shdilk   STRFI-1537, Removed column OBSOLETE from PROJECT_COST_ELEMENT_TAB.
--  160425  Paralk   FINHR-1446 , Removed columns from COMPANY_FINANCE_TAB.
--  161202  Hiralk   FINHR-4733, Removed obsolete table STATUTORY_FEE_DETAIL_1000.
--  170403  Thaslk STRFI-5562 Drop obsolete tables 
--  180410  Ajpelk   Bug 141243, Removing EXT_PARAM_VOUCHER_TYPES moved to the cdb file.
--  181004  Nudilk   Bug 144548, Moved removal of triggers to 181004_144548_ACCRUL.cdb
--  200701  Jadulk  FISPRING20-6694 , Removed column CONSOLIDATED from ACOCUNTING_PERIOD_TAB.
--  200922  Jadulk  FISPRING20-6695, Removed code part related obsolete component logic for CONACC.
--  201112	Tkavlk  FISPRING20-8158, Removed company finance related obsolete columns.
--  201120  Jadulk  FISPRING20-8268, Changed IFS Cloud version to 21R1.
--  201202  Jadulk  FISPRING20-8299, Renamed obsolete columns to 21R1.
--  201208  Jadulk  FISPRING20-8527, Rollbacked renaming obsolete columns for MV referenced columns.
--------------------------------------------------------------------------------

PROMPT NOTE! This script drops tables and columns no longer used in core
PROMPT and must be edited before usage.                                         
ACCEPT Press_any_key                                                            
EXIT; -- Remove me before usage

SET SERVEROUTPUT ON

PROMPT Dropping obsolete tables from previous releases.
BEGIN
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_DEF_TAB_TMP' );
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_DEF_TAB_850' );
   Database_Sys.Remove_Table( 'CURRENCY_CODE_TAB_SAVE' );
   Database_Sys.Remove_Table( 'CURRENCY_CODE_TAB_850' );
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_TAB_TMP' );
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_TAB_850' );
   Database_Sys.Remove_Table( 'PAYMENT_TERM_TAB_SAVE' );
   Database_Sys.Remove_Table( 'PAYMENT_TERM_TAB_852' );
END;
/

PROMPT Dropping obsolete tables from 8.7.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'CURRENCY_CODE_DEF_870' );
   Database_Sys.Remove_Table( 'CURRENCY_RATE_DEF_870' );
   Database_Sys.Remove_Table( 'CURRENCY_TYPE_DEF_870' );
   Database_Sys.Remove_Table( 'TEXT_FIELD_TRANSLATION_DEF_870' );
   Database_Sys.Remove_Table( 'ACCOUNTING_CODE_PART_DEF_870' );
   Database_Sys.Remove_Table( 'TRANSLATION_TYPE_870' );
   Database_Sys.Remove_Table( 'ACCOUNT_GROUP_DEF_870' );
   Database_Sys.Remove_Table( 'ACCNT_CODE_PART_VALUE_DEF_870' );
   Database_Sys.Remove_Table( 'ACCOUNT_CODESTR_COMB_DEF_870' );
   Database_Sys.Remove_Table( 'ACCOUNTING_PERIOD_DEF_870' );
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_DEF_870' );
   Database_Sys.Remove_Table( 'FUNCTION_GROUP_870' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DEF_870' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DETAIL_DEF_870' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DETAIL_DEF_870' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_USER_GRP_DEF_870' );
   Database_Sys.Remove_Table( 'VOUCHER_NO_SERIAL_DEF_870' );
   Database_Sys.Remove_Table( 'USER_GROUP_FINANCE_DEF_870' );
   Database_Sys.Remove_Table( 'USER_FINANCE_DEF_870' );
   Database_Sys.Remove_Table( 'USER_GROUP_MEMBER_FIN_DEF_870' );
   Database_Sys.Remove_Table( 'USER_GROUP_PERIOD_DEF_870' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_POSTING_TYPE_870' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_ALLOWED_COMB_870' );
   Database_Sys.Remove_Table( 'ACC_POSTING_CTRL_DEF_870' );
   Database_Sys.Remove_Table( 'ACC_POST_CTRL_DETAIL_DEF_870' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_CONTROL_TYPE_870' );
   Database_Sys.Remove_Table( 'CREATE_ACCRUL_COMPANY_870' );
   Database_Sys.Remove_Table( 'PAYMENT_TERM_DEF_870' );
   Database_Sys.Remove_Table( 'STATUTORY_FEE_DEF_870' );
   Database_Sys.Remove_Table( 'ACCRUL_ATTRIBUTE_870' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_DEF_870' );
END;
/   

PROMPT Dropping obsolete tables from 8.7.0.A releases.
BEGIN
   Database_Sys.Remove_Table( 'CURRENCY_CODE_DEF870A' );
   Database_Sys.Remove_Table( 'CURRENCY_RATE_DEF870A' );
   Database_Sys.Remove_Table( 'CURRENCY_TYPE_DEF870A' );
   Database_Sys.Remove_Table( 'TEXT_FIELD_TRANSLATION_DEF870A' );
   Database_Sys.Remove_Table( 'ACCOUNTING_CODE_PART_DEF870A' );
   Database_Sys.Remove_Table( 'TRANSLATION_TYPE870A' );
   Database_Sys.Remove_Table( 'ACCOUNT_GROUP_DEF870A' );
   Database_Sys.Remove_Table( 'ACCNT_CODE_PART_VALUE_DEF870A' );
   Database_Sys.Remove_Table( 'ACCOUNT_CODESTR_COMB_DEF870A' );
   Database_Sys.Remove_Table( 'ACCOUNTING_PERIOD_DEF870A' );
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_DEF870A' );
   Database_Sys.Remove_Table( 'FUNCTION_GROUP870A' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DEF870A' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DETAIL_DEF870A' );
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_USER_GRP_DEF870A' );
   Database_Sys.Remove_Table( 'VOUCHER_NO_SERIAL_DEF870A' );
   Database_Sys.Remove_Table( 'USER_GROUP_FINANCE_DEF870A' );
   Database_Sys.Remove_Table( 'USER_FINANCE_DEF870A' );
   Database_Sys.Remove_Table( 'USER_GROUP_MEMBER_FIN_DEF870A' );
   Database_Sys.Remove_Table( 'USER_GROUP_PERIOD_DEF870A' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_POSTING_TYPE870A' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_ALLOWED_COMB870A' );
   Database_Sys.Remove_Table( 'ACC_POSTING_CTRL_DEF870A' );
   Database_Sys.Remove_Table( 'ACC_POST_CTRL_DETAIL_DEF870A' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_CONTROL_TYPE870A' );
   Database_Sys.Remove_Table( 'CREATE_ACCRUL_COMPANY870A' );
   Database_Sys.Remove_Table( 'PAYMENT_TERM_DEF870A' );
   Database_Sys.Remove_Table( 'STATUTORY_FEE_DEF870A' );
   Database_Sys.Remove_Table( 'ACCRUL_ATTRIBUTE870A' );
   Database_Sys.Remove_Table( 'POSTING_CTRL_DEF_870A' );
END;
/

PROMPT Dropping obsolete tables from 8.7.1 releases.
BEGIN
   Database_Sys.Remove_Table( 'CURRENCY_CODE_DEF_871' );
   Database_Sys.Remove_Table( 'TEXT_FIELD_TRANSLATION_DEF_871' );
   Database_Sys.Remove_Table( 'ACCOUNTING_CODE_PART_DEF_871' );
   Database_Sys.Remove_Table( 'ACCOUNT_GROUP_DEF_871' );
   Database_Sys.Remove_Table( 'ACCNT_CODE_PART_VALUE_DEF_871' );
   Database_Sys.Remove_Table( 'ACCOUNT_CODESTR_COMB_DEF_871' );
   Database_Sys.Remove_Table( 'ACCOUNT_CODESTR_COMB_DEF_871' );
   Database_Sys.Remove_Table( 'ACCOUNTING_PERIOD_DEF_871' );
   Database_Sys.Remove_Table( 'ACCOUNT_TYPE_DEF_871');
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DEF_871');
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_DETAIL_DEF_871');
   Database_Sys.Remove_Table( 'VOUCHER_TYPE_USER_GRP_DEF_871');
   Database_Sys.Remove_Table( 'VOUCHER_NO_SERIAL_DEF_871');
   Database_Sys.Remove_Table( 'USER_GROUP_FINANCE_DEF_871');
   Database_Sys.Remove_Table( 'USER_GROUP_PERIOD_DEF_871');
   Database_Sys.Remove_Table( 'USER_GROUP_MEMBER_FIN_DEF_871');
   Database_Sys.Remove_Table( 'USER_FINANCE_DEF_871');
   Database_Sys.Remove_Table( 'ACC_POSTING_CTRL_DEF_871');
   Database_Sys.Remove_Table( 'ACC_POST_CTRL_DETAIL_DEF_871');
   Database_Sys.Remove_Table( 'CREATE_ACCRUL_COMPANY_871');
   Database_Sys.Remove_Table( 'PAYMENT_TERM_DEF_871');
   Database_Sys.Remove_Table( 'STATUTORY_FEE_DEF_871');
   Database_Sys.Remove_Table( 'CURRENCY_RATE_DEF_871');
   Database_Sys.Remove_Table( 'CURRENCY_TYPE_DEF_871');
   Database_Sys.Remove_Table( 'TRANSLATION_TYPE_871');
   Database_Sys.Remove_Table( 'FUNCTION_GROUP_871');
   Database_Sys.Remove_Table( 'POSTING_CTRL_POSTING_TYPE_871');
   Database_Sys.Remove_Table( 'POSTING_CTRL_ALLOWED_COMB_871');
   Database_Sys.Remove_Table( 'POSTING_CTRL_CONTROL_TYPE_871');
   Database_Sys.Remove_Table( 'ACCRUL_ATTRIBUTE_871');
   Database_Sys.Remove_Table( 'POSTING_CTRL_DEF_871');
   Database_Sys.Remove_Table( 'EXT_CURRENCY_BATCH_871');
   Database_SYS.Remove_Table( 'COMPANY_FINANCE_LOG_871');
END;
/
   
PROMPT Dropping obsolete tables from 8.8.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'USER_GROUP_FINANCE_DEF_880');
   Database_Sys.Remove_Table( 'USER_GROUP_PERIOD_DEF_880');
   Database_Sys.Remove_Table( 'USER_GROUP_MEMBER_FIN_DEF_880');
   Database_Sys.Remove_Table( 'USER_FINANCE_DEF_880');
   Database_Sys.Remove_Table( 'EXT_CURRENCY_880');
   Database_Sys.Remove_Table( 'TEXT_FIELD_TRANSLATION_880');   
   Database_Sys.Remove_Table( 'ACCRUL_TMP_V880');
END;
/

PROMPT Dropping obsolete tables from 8.9.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'POSTING_CTRL_DETAIL_890');
   Database_Sys.Remove_Table( 'POSTING_CTRL_COMB_DETAIL_890');
   Database_Sys.Remove_Table( 'EXT_FILE_TYPE_890');
   Database_Sys.Remove_Table( 'EXT_FILE_TYPE_GROUP_890');
   Database_Sys.Remove_Table( 'EXT_FILE_COLUMN_890');
   Database_Sys.Remove_Table( 'EXT_FILE_890');
   Database_Sys.Remove_Table( 'EXT_FILE_CONTROL_890');
   Database_Sys.Remove_Table( 'EXT_FILE_DETAIL_890');
   Database_Sys.Remove_Table( 'EXT_FILE_LOAD_890');
   Database_Sys.Remove_Table( 'EXT_PARAMETERS_890');
   Database_Sys.Remove_Table( 'EXT_CURRENCY_TASK_DETAIL_890');
   Database_Sys.Remove_Table( 'EXT_CURRENCY_TASK_890');
   Database_Sys.Remove_Table( 'POSTING_CTRL_TEMP_TAB');
   Database_Sys.Remove_Table( 'EURO_CORRECTION_ACCRUL_890');
   Database_Sys.Remove_Table( 'ACCRUL_TMP_V890');
END;
/

PROMPT Dropping obsolete tables from 8.10.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'CURRENCY_TYPE_8100' );
END;
/

PROMPT Dropping obsolete tables from 8.10.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'CURRENCY_TYPE_8100' );
END;
/

PROMPT Dropping obsolete tables from 9.0.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'Posting_Ctrl_Def_900', TRUE );
END;
/

PROMPT Dropping obsolete tables from 10.0.0 releases.
BEGIN
   Database_Sys.Remove_Table( 'STATUTORY_FEE_DETAIL_1000', TRUE );
   Database_Sys.Remove_Table( 'TAX_ITEM_TAB_TMP_1000', TRUE );
   Database_Sys.Remove_Table( 'TAX_ITEM_TEMPLATE_TAB_TMP_1000', TRUE );
   Database_Sys.Remove_Table( 'MULTI_COMPANY_VOUCHER_1000', TRUE );
   Database_Sys.Remove_Table( 'MULTI_COMPANY_VOUCHER_ROW_1000', TRUE );
   
END;
/

PROMPT Dropping obsolete COLUMNS
DECLARE
   table_name_    VARCHAR2(30) := 'ACCOUNTING_CODESTR_COMB_TAB';
   column_        Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('Keystring');
   Database_SYS.Alter_Table_Column ( table_name_, 'D', column_, TRUE);
END;
/

DECLARE
   table_name_    VARCHAR2(30) := 'PAYMENT_TERM_TAB';
   column_        Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('Days_Cnt', 'NUMBER(20,0)' );
   Database_SYS.Alter_Table_Column ( table_name_, 'D', column_, TRUE );
   column_ := Database_SYS.Set_Column_Values('No_Free_Deliv_Month', 'NUMBER(20)' );
   Database_SYS.Alter_Table_Column ( table_name_, 'D', column_, TRUE );
   column_ := Database_SYS.Set_Column_Values('End_Of_Month', 'VARCHAR2(5)' );
   Database_SYS.Alter_Table_Column ( table_name_, 'D', column_, TRUE );
   column_ := Database_SYS.Set_Column_Values('Specific_Due_Day', 'NUMBER(20)' );
   Database_SYS.Alter_Table_Column ( table_name_, 'D', column_, TRUE );
END;
/

PROMPT DROP column valid_until FROM POSTING_CTRL_DETAIL_TAB
DECLARE
   table_name_      VARCHAR2(30) := 'POSTING_CTRL_DETAIL_TAB';
   column_          Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('VALID_UNTIL');
   Database_SYS.Alter_Table_Column ( table_name_, 'D', column_, TRUE);
END;
/

DECLARE
   column_          Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('VALID_UNTIL');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_COMB_DETAIL_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('STRING_EVALUATE');
   Database_SYS.Alter_Table_Column ( 'EXT_FILE_TEMPLATE_CONTROL_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('DEFAULT_VALUE');
   Database_SYS.Alter_Table_Column ( 'EXT_FILE_TEMPLATE_DETAIL_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('STRING_EVALUATE');
   Database_SYS.Alter_Table_Column ( 'EXT_FILE_TEMPLATE_DETAIL_TAB', 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMNS from 8.11.0 releases.
DECLARE
   column_        Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('combined_control_type');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('spec_combined_control_type');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_DETAIL_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('allowed_default');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_CONTROL_TYPE_TAB', 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMNS from 9.0.0 releases.
DECLARE
   column_          Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('ACCRUL_ID');
   Database_SYS.Alter_Table_Column ( 'TRANSFERRED_VOUCHER_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('ACCRUL_ID');
   Database_SYS.Alter_Table_Column ( 'VOUCHER_TAB', 'D', column_, TRUE);
END;
/

PROMPT Dropping Temporary COLUMN from ACCOUNTING_CODE_PART_TAB
DECLARE
   table_name_ VARCHAR2(30) := 'ACCOUNTING_CODE_PART_TAB';
   column_     Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('MAX_NUMBER_OF_CHAR_TEMP');
   Database_SYS.Alter_Table_Column ( table_name_ , 'D', column_ , TRUE );
END;
/

PROMPT Dropping obsolete COLUMNS from 9.1.0 releases.
DECLARE
   column_          Database_SYS.ColRec;
BEGIN
   column_ := Database_SYS.Set_Column_Values('NCF_INV_STAT_FEE');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_CODE_PART_VALUE_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('NCF_OVERRIDE_FEE');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_CODE_PART_VALUE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('ACCOUNT_TYPE_DESCRIPTION');
   Database_SYS.Alter_Table_Column ( 'ACCOUNT_TYPE_TAB', 'D', column_, TRUE);  
   column_ := Database_SYS.Set_Column_Values('POSTING_COMBINATION_ID');
   Database_SYS.Alter_Table_Column ( 'EXT_TRANSACTIONS_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CCT_COMPANY');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_ALLOWED_COMB_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('CONTROL_TYPE1_DESCRIPTION');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_COMB_DETAIL_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CONTROL_TYPE2_DESCRIPTION');
   Database_SYS.Alter_Table_Column ( 'POSTING_CTRL_COMB_DETAIL_TAB', 'D', column_, TRUE);  
   column_ := Database_SYS.Set_Column_Values('NCF_INV_TAX_RATE');
   Database_SYS.Alter_Table_Column ( 'STATUTORY_FEE_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('TRIANGULATION_TRADE');
   Database_SYS.Alter_Table_Column ( 'STATUTORY_FEE_TAB', 'D', column_, TRUE);  
   column_ := Database_SYS.Set_Column_Values('ROWTYPE');
   Database_SYS.Alter_Table_Column ( 'TRANSFERRED_VOUCHER_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('DESCRIPTION');
   Database_SYS.Alter_Table_Column ( 'USER_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('VOUCHER_GROUP');
   Database_SYS.Alter_Table_Column ( 'VOUCHER_TYPE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('VOUCHER_GROUP');
   Database_SYS.Alter_Table_Column ( 'VOUCHER_TYPE_USER_GROUP_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('TAX_RECOVERABLE');
   Database_SYS.Alter_Table_Column ( 'STATUTORY_FEE_TAB', 'D', column_, TRUE);  
END;
/

PROMPT Dropping COLUMNS from ACCOUNTING_CODE_PART_VALUE_TAB
DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'ACCOUNTING_CODE_PART_VALUE_TAB';
BEGIN
   column_ := Database_SYS.Set_Column_Values('PROJECT_TYPE');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PROJECT_GROUP');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('READY_DATE');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CONTRIB_MARGIN');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PROJECT_LEADER');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('POSTING_COMBINATION_ID');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('EXTERNALLY_CREATED');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CLOSE_AT_FINAL_INVO');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('FINALLY_INVOICED');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('FINALLY_INVO_ACC_PERIOD');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PROJECT_ORIGIN');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('REVENUE_RECOG_METHOD');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('POC_METHOD');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PROJECT_PROGRESS_METHOD');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PROJECT_REOPENED');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CAPITALIZATION_POST_METHOD');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('SPECIFIC_CAP_PRINCIPLES');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('REVISION_ACCOUNTING');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);

END;
/

PROMPT Dropping obsolete COLUMNS from 10.0.0 releases.
DECLARE
   column_          Database_SYS.ColRec;
BEGIN 
   column_ := Database_SYS.Set_Column_Values('MULTIPLE_TAX');
   Database_SYS.Alter_Table_Column ('STATUTORY_FEE_TAB', 'D', column_, TRUE);  
   column_ := Database_SYS.Set_Column_Values('FEE_TYPE_TEMP');
   Database_SYS.Alter_Table_Column ('STATUTORY_FEE_TAB', 'D', column_, TRUE);     
   column_ := Database_SYS.Set_Column_Values('LEVEL_IN_PERCENT');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('LEVEL_IN_ACC_CURRENCY');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('TAX_ROUNDING_METHOD');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('OBSOLETE');
   Database_SYS.Alter_Table_Column ('PROJECT_COST_ELEMENT_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CITY_TAX_CODE');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('STATE_TAX_CODE');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('COUNTY_TAX_CODE');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('DISTRICT_TAX_CODE');
   Database_SYS.Alter_Table_Column ('COMPANY_FINANCE_TAB', 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('PERIOD_STATUS_INT');
   Database_SYS.Alter_Table_Column ( 'USER_GROUP_PERIOD_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('OPENING_BALANCES');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_YEAR_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CLOSING_BALANCES');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_YEAR_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('YEAR_STATUS');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_YEAR_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PERIOD_STATUS_INT');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_PERIOD_TAB', 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('PERIOD_STATUS');
   Database_SYS.Alter_Table_Column ( 'ACCOUNTING_PERIOD_TAB', 'D', column_, TRUE);

   

END;
/

PROMPT Dropping obsolete COLUMN in tax_book table from 21.1.0 releases.
DECLARE
   column_          Database_SYS.ColRec;
   table_name_	    VARCHAR2(20);
BEGIN 
   column_ 		:= Database_SYS.Set_Column_Values('TAX_CODE_2110');
   table_name_ 	:= 'TAX_BOOK_TAB';
   
   IF Database_SYS.Column_Exist(table_name_, 'TAX_CODE_2110') THEN	   
	   Database_SYS.Alter_Table_Column (table_name_, 'D', column_, TRUE);
   END IF;
END;
/

PROMPT Dropping obsolete COLUMN in accounting_year table from 21.1.0 releases.
DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'ACCOUNTING_YEAR_TAB';
BEGIN
   -- Column renaming with versioning has been removed as this column has been used by some Materialized Views in a previous upg. 
   column_ := Database_SYS.Set_Column_Values('OPEN_BAL_CONSOLIDATED');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMN in accounting_period table from 21.1.0 releases.

DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'ACCOUNTING_PERIOD_TAB';
BEGIN
   -- Column renaming with versioning has been removed as this column has been used by some Materialized Views in a previous upg.  
   column_ := Database_SYS.Set_Column_Values('CONSOLIDATED');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMNS in accounting_code_part table from 21.1.0 releases.
DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'ACCOUNTING_CODE_PART_TAB';
BEGIN
   column_ := Database_SYS.Set_Column_Values('PARENT_CODE_PART_2110');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMNS in accounting_code_part_value table from 21.1.0 releases.
DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'ACCOUNTING_CODE_PART_VALUE_TAB';
BEGIN 
   column_ := Database_SYS.Set_Column_Values('CONS_ACCNT_2110');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CONS_CODE_PART_VALUE_2110');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMNS in account_group table from 21.1.0 releases.
DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'ACCOUNT_GROUP_TAB';
BEGIN 
   column_ := Database_SYS.Set_Column_Values('DEFAULT_CONS_ACCNT_2110');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
END;
/

PROMPT Dropping obsolete COLUMNS in company_finance table from 21.1.0 releases.
DECLARE
   column_     Database_SYS.ColRec;
   table_name_ VARCHAR2(30) := 'COMPANY_FINANCE_TAB';
BEGIN
   -- Column renaming with versioning has been removed as these columns has been used by some Materialized Views in a previous upg.  
   column_ := Database_SYS.Set_Column_Values('CONS_COMPANY');
   Database_SYS.Alter_Table_Column(table_name_, 'D', column_, TRUE);
   column_ := Database_SYS.Set_Column_Values('CONSOLIDATION_FILE');
   Database_SYS.Alter_Table_Column (table_name_, 'D', column_, TRUE); 
   column_ := Database_SYS.Set_Column_Values('CONS_CODE_PART_VALUE');
   Database_SYS.Alter_Table_Column (table_name_, 'D', column_, TRUE);      

END;
/

PROMPT -------------------------------------------------------------
PROMPT Drop of obsolete table in ACCRUL done!
PROMPT ---------------------------------------------------
        

                     
