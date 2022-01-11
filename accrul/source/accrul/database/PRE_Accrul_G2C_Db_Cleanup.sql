-------------------------------------------------------------------------------------------------
--  Module  : ACCRUL
--
--  Purpose : This file is intended to execute at the begining of the upgrade, if upgrading from a GET version
--            Cleans up the DB Objects exclusive to GET versions
--
--  File    : PRE_Accrul_G2C_Db_Cleanup.sql
--
--  IFS Developer Studio Template Version 2.6
--
--  Date    Sign    History
--  ------  ------  -----------------------------------------------------------------------------
--  210217  cecobr  FISPRING20-9195, Commit PRE Scripts and Drop Scripts for Obsolete components
-------------------------------------------------------------------------------------------------

SET SERVEROUTPUT ON
PROMPT Starting PRE_Accrul_G2C_Db_Cleanup.sql

-------------------------------------------------------------------------------------------------
-- Removing Packages
-------------------------------------------------------------------------------------------------
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C_Db_Cleanup.sql','Timestamp_1');
PROMPT Removing Packages
BEGIN
   Database_SYS.Remove_Package('CS_FILL_MODE_CODE_API', TRUE);
   Database_SYS.Remove_Package('EXT_FEE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('FEC_EXCLUDE_VOUCHER_TYPE_API', TRUE);
   Database_SYS.Remove_Package('FEC_GENERAL_PARAMETER_API', TRUE);
   Database_SYS.Remove_Package('FR_REPORTING_UTIL_API', TRUE);
   Database_SYS.Remove_Package('GST_TAX_HANDLING_UTIL_API', TRUE);
   Database_SYS.Remove_Package('HSN_SAC_CODES_API', TRUE);
   Database_SYS.Remove_Package('HSN_SAC_GROUPS_API', TRUE);
   Database_SYS.Remove_Package('HSN_SAC_TAX_STRUCTURES_API', TRUE);
   Database_SYS.Remove_Package('HSN_SAC_TYPES_API', TRUE);
   Database_SYS.Remove_Package('INVOICE_TYPES_PER_TAX_BOOK_API', TRUE);
   Database_SYS.Remove_Package('INV_SERIES_PER_TAX_BOOK_API', TRUE);
   Database_SYS.Remove_Package('JPK_ACCOUNTING_BOOKS_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_ACCOUNTING_JOURNAL_API', TRUE);
   Database_SYS.Remove_Package('JPK_ACCOUNT_BALANCES_API', TRUE);
   Database_SYS.Remove_Package('JPK_BANK_ACCOUNTS_API', TRUE);
   Database_SYS.Remove_Package('JPK_BANK_STATEMENT_API', TRUE);
   Database_SYS.Remove_Package('JPK_BANK_STATEMENT_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_DATE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('JPK_ENTITY_API', TRUE);
   Database_SYS.Remove_Package('JPK_FILE_API', TRUE);
   Database_SYS.Remove_Package('JPK_FILE_LOG_API', TRUE);
   Database_SYS.Remove_Package('JPK_FILE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('JPK_GENERAL_PARAMETERS_API', TRUE);
   Database_SYS.Remove_Package('JPK_GOODS_ISSUED_API', TRUE);
   Database_SYS.Remove_Package('JPK_GOODS_RECEIVED_API', TRUE);
   Database_SYS.Remove_Package('JPK_HEADER_API', TRUE);
   Database_SYS.Remove_Package('JPK_INTERNAL_ISSUE_API', TRUE);
   Database_SYS.Remove_Package('JPK_INTERNAL_TRANSFER_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVENTORY_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVENT_CONFIGURATION_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVENT_DIRECTION_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVENT_DOC_TYPE_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVENT_REPORT_TYPES_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_CONFIGURATION_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_LINE_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_LINE_TAX_RATES_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_PARTY_TYPE_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('JPK_INVOICE_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_JOURNAL_ENTRY_API', TRUE);
   Database_SYS.Remove_Package('JPK_ORDER_API', TRUE);
   Database_SYS.Remove_Package('JPK_ORDER_LINE_API', TRUE);
   Database_SYS.Remove_Package('JPK_PURCHASE_RECORDS_API', TRUE);
   Database_SYS.Remove_Package('JPK_REPORTING_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_SALES_RECORDS_API', TRUE);
   Database_SYS.Remove_Package('JPK_TURNOVER_BALANCE_API', TRUE);
   Database_SYS.Remove_Package('JPK_V7M_DECLARATION_API', TRUE);
   Database_SYS.Remove_Package('JPK_V7M_LINE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('JPK_V7M_PURCHASE_RECORDS_API', TRUE);
   Database_SYS.Remove_Package('JPK_V7M_SALES_RECORDS_API', TRUE);
   Database_SYS.Remove_Package('JPK_V7M_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_VAT_UTIL_API', TRUE);
   Database_SYS.Remove_Package('JPK_WAREHOUSE_API', TRUE);
   Database_SYS.Remove_Package('NATURE_OF_OPERATION_API', TRUE);
   Database_SYS.Remove_Package('PT_CUSTOMER_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_FILE_API', TRUE);
   Database_SYS.Remove_Package('PT_GEN_LED_ACCOUNT_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_GEN_LED_ENTRY_SUMMARY_API', TRUE);
   Database_SYS.Remove_Package('PT_GEN_LED_JOURNAL_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_GEN_LED_TRANS_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_GEN_LED_TRANS_LINE_API', TRUE);
   Database_SYS.Remove_Package('PT_HEADER_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_INVOICE_DOCUMENT_TOTALS_API', TRUE);
   Database_SYS.Remove_Package('PT_INVOICE_HEADER_API', TRUE);
   Database_SYS.Remove_Package('PT_INVOICE_LINE_API', TRUE);
   Database_SYS.Remove_Package('PT_INVOICE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('PT_INVOICE_TYPE_CONFIG_API', TRUE);
   Database_SYS.Remove_Package('PT_INV_HEADERS_SUMMARY_API', TRUE);
   Database_SYS.Remove_Package('PT_INV_LINE_TAX_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_MOVEMENT_TYPE_API', TRUE);
   Database_SYS.Remove_Package('PT_MOVEMENT_TYPE_CONFIG_API', TRUE);
   Database_SYS.Remove_Package('PT_MOV_OF_GOODS_HEADER_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_DOC_TOTALS_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_HEADER_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_LINE_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_LINE_TAX_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_SUMMARY_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_TYPE_API', TRUE);
   Database_SYS.Remove_Package('PT_PAYMENT_TYPE_CONFIG_API', TRUE);
   Database_SYS.Remove_Package('PT_PRODUCT_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_PRODUCT_SERIAL_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_PRODUCT_SERVICE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('PT_REPORTING_UTIL_API', TRUE);
   Database_SYS.Remove_Package('PT_STOCK_MOVEMENT_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_STOCK_MOVEMENT_LINE_API', TRUE);
   Database_SYS.Remove_Package('PT_STOCK_MOV_DOC_TOTALS_API', TRUE);
   Database_SYS.Remove_Package('PT_STOCK_MOV_LINE_TAX_API', TRUE);
   Database_SYS.Remove_Package('PT_STOCK_PROD_SERIAL_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_SUPPLIER_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_TAXONOMY_CODE_API', TRUE);
   Database_SYS.Remove_Package('PT_TAXONOMY_CONFIG_API', TRUE);
   Database_SYS.Remove_Package('PT_TAX_TABLE_INFO_API', TRUE);
   Database_SYS.Remove_Package('PT_TRANSACTION_TYPE_API', TRUE);
   Database_SYS.Remove_Package('PT_TRANSACTION_TYPE_CONFIG_API', TRUE);
   Database_SYS.Remove_Package('SAFT_FILE_TYPE_API', TRUE);
   Database_SYS.Remove_Package('SAFT_PT_GENERAL_PARAMETER_API', TRUE);
   Database_SYS.Remove_Package('SII_OPERATION_TYPE_API', TRUE);
   Database_SYS.Remove_Package('SII_TAX_LIABILITY_CLASS_API', TRUE);
   Database_SYS.Remove_Package('TAX_BOOK_BASE_API', TRUE);
   Database_SYS.Remove_Package('TAX_BOOK_BASE_VALUES_API', TRUE);
   Database_SYS.Remove_Package('TAX_CHARACTER_API', TRUE);
   Database_SYS.Remove_Package('TAX_PER_STATUS_API', TRUE);
   Database_SYS.Remove_Package('TAX_REPORTING_REGION_API', TRUE);
END;
/

-------------------------------------------------------------------------------------------------
-- Removing Views
-------------------------------------------------------------------------------------------------
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C_Db_Cleanup.sql','Timestamp_2');
PROMPT Removing Views
BEGIN
   Database_SYS.Remove_View('DIM_HSN_SAC_CODES_DM', TRUE);
   Database_SYS.Remove_View('DIM_HSN_SAC_CODES_OL', TRUE);
   Database_SYS.Remove_View('EXT_FILE_TRANS_DETAIL2', TRUE);
   Database_SYS.Remove_View('FEC_EXCLUDE_VOUCHER_TYPE', TRUE);
   Database_SYS.Remove_View('FEC_GENERAL_PARAMETER', TRUE);
   Database_SYS.Remove_View('HSN_SAC_CODES', TRUE);
   Database_SYS.Remove_View('HSN_SAC_GROUPS', TRUE);
   Database_SYS.Remove_View('HSN_SAC_TAX_STRUCTURES', TRUE);
   Database_SYS.Remove_View('INVOICE_TYPES_PER_TAX_BOOK', TRUE);
   Database_SYS.Remove_View('INV_SERIES_PER_TAX_BOOK', TRUE);
   Database_SYS.Remove_View('JPK_ACCOUNTING_JOURNAL', TRUE);
   Database_SYS.Remove_View('JPK_ACCOUNTING_JOURNAL_CTRL', TRUE);
   Database_SYS.Remove_View('JPK_ACCOUNT_BALANCES', TRUE);
   Database_SYS.Remove_View('JPK_BANK_ACCOUNTS', TRUE);
   Database_SYS.Remove_View('JPK_BANK_STATEMENT', TRUE);
   Database_SYS.Remove_View('JPK_BANK_STATEMENT_CONTROL', TRUE);
   Database_SYS.Remove_View('JPK_ENTITY', TRUE);
   Database_SYS.Remove_View('JPK_FILE', TRUE);
   Database_SYS.Remove_View('JPK_FILE_LOG', TRUE);
   Database_SYS.Remove_View('JPK_GENERAL_PARAMETERS', TRUE);
   Database_SYS.Remove_View('JPK_GOODS_ISSUED', TRUE);
   Database_SYS.Remove_View('JPK_GOODS_ISSUED_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_GOODS_RECEIVED', TRUE);
   Database_SYS.Remove_View('JPK_GOODS_RECEIVED_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_HEADER', TRUE);
   Database_SYS.Remove_View('JPK_INTERNAL_ISSUE', TRUE);
   Database_SYS.Remove_View('JPK_INTERNAL_ISSUE_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_INTERNAL_TRANSFER', TRUE);
   Database_SYS.Remove_View('JPK_INTERNAL_TRANSFER_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_INVENT_CONFIGURATION', TRUE);
   Database_SYS.Remove_View('JPK_INVENT_REPORT_TYPES', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE_CONFIGURATION', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE_LINE', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE_LINE_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE_SERIES_LOV', TRUE);
   Database_SYS.Remove_View('JPK_INVOICE_TYPE', TRUE);
   Database_SYS.Remove_View('JPK_JOURNAL_ENTRY', TRUE);
   Database_SYS.Remove_View('JPK_JOURNAL_ENTRY_CTRL', TRUE);
   Database_SYS.Remove_View('JPK_ORDER', TRUE);
   Database_SYS.Remove_View('JPK_ORDER_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_ORDER_LINE', TRUE);
   Database_SYS.Remove_View('JPK_ORDER_LINE_DETAILS', TRUE);
   Database_SYS.Remove_View('JPK_PURCHASE_CONTROL', TRUE);
   Database_SYS.Remove_View('JPK_PURCHASE_RECORDS', TRUE);
   Database_SYS.Remove_View('JPK_SALES_CONTROL', TRUE);
   Database_SYS.Remove_View('JPK_SALES_RECORDS', TRUE);
   Database_SYS.Remove_View('JPK_TURNOVER_BALANCE', TRUE);
   Database_SYS.Remove_View('JPK_V7M_DECLARATION', TRUE);
   Database_SYS.Remove_View('JPK_V7M_DECLARATION_XML', TRUE);
   Database_SYS.Remove_View('JPK_V7M_PURCHASE_CONTROL', TRUE);
   Database_SYS.Remove_View('JPK_V7M_PURCHASE_RECORDS', TRUE);
   Database_SYS.Remove_View('JPK_V7M_PURCHASE_RECORDS_XML', TRUE);
   Database_SYS.Remove_View('JPK_V7M_SALES_CONTROL', TRUE);
   Database_SYS.Remove_View('JPK_V7M_SALES_RECORDS', TRUE);
   Database_SYS.Remove_View('JPK_V7M_SALES_RECORDS_XML', TRUE);
   Database_SYS.Remove_View('JPK_VAT_3_ENTITY', TRUE);
   Database_SYS.Remove_View('JPK_VAT_3_HEADER', TRUE);
   Database_SYS.Remove_View('JPK_WAREHOUSE', TRUE);
   Database_SYS.Remove_View('PROPOSAL_LOV', TRUE);
   Database_SYS.Remove_View('PT_CUSTOMER_INFO', TRUE);
   Database_SYS.Remove_View('PT_FILE', TRUE);
   Database_SYS.Remove_View('PT_GEN_LED_ACCOUNT_INFO', TRUE);
   Database_SYS.Remove_View('PT_GEN_LED_ACCOUNT_INFO_SEC', TRUE);
   Database_SYS.Remove_View('PT_GEN_LED_ENTRY_SUMMARY', TRUE);
   Database_SYS.Remove_View('PT_GEN_LED_JOURNAL_INFO', TRUE);
   Database_SYS.Remove_View('PT_GEN_LED_TRANS_INFO', TRUE);
   Database_SYS.Remove_View('PT_GEN_LED_TRANS_LINE', TRUE);
   Database_SYS.Remove_View('PT_HEADER_INFO', TRUE);
   Database_SYS.Remove_View('PT_INVOICE_DOCUMENT_TOTALS', TRUE);
   Database_SYS.Remove_View('PT_INVOICE_HEADER', TRUE);
   Database_SYS.Remove_View('PT_INVOICE_LINE', TRUE);
   Database_SYS.Remove_View('PT_INVOICE_TYPE', TRUE);
   Database_SYS.Remove_View('PT_INVOICE_TYPE_CONFIG', TRUE);
   Database_SYS.Remove_View('PT_INV_HEADERS_SUMMARY', TRUE);
   Database_SYS.Remove_View('PT_INV_LINE_TAX_INFO', TRUE);
   Database_SYS.Remove_View('PT_MOVEMENT_OF_GOODS_HEADER', TRUE);
   Database_SYS.Remove_View('PT_MOVEMENT_TYPE', TRUE);
   Database_SYS.Remove_View('PT_MOVEMENT_TYPE_CONFIG', TRUE);
   Database_SYS.Remove_View('PT_MOV_OF_GOODS_DOCS_TOTALS', TRUE);
   Database_SYS.Remove_View('PT_MOV_OF_GOODS_HEADER', TRUE);
   Database_SYS.Remove_View('PT_MOV_OF_GOODS_INFO', TRUE);
   Database_SYS.Remove_View('PT_MOV_OF_GOODS_LINE_INFO', TRUE);
   Database_SYS.Remove_View('PT_MOV_OF_GOODS_LINE_TAX_INFO', TRUE);
   Database_SYS.Remove_View('PT_MOV_OF_GOODS_PROD_INFO', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_DOC_TOTALS', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_HEADER', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_LINE', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_LINE_TAX', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_SUMMARY', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_TYPE', TRUE);
   Database_SYS.Remove_View('PT_PAYMENT_TYPE_CONFIG', TRUE);
   Database_SYS.Remove_View('PT_PRODUCT_INFO', TRUE);
   Database_SYS.Remove_View('PT_PRODUCT_SERIAL_INFO', TRUE);
   Database_SYS.Remove_View('PT_STOCK_MOVEMENT_INFO', TRUE);
   Database_SYS.Remove_View('PT_STOCK_MOVEMENT_LINE', TRUE);
   Database_SYS.Remove_View('PT_STOCK_MOV_DOC_TOTALS', TRUE);
   Database_SYS.Remove_View('PT_STOCK_MOV_LINE_TAX', TRUE);
   Database_SYS.Remove_View('PT_STOCK_PROD_SERIAL_INFO', TRUE);
   Database_SYS.Remove_View('PT_SUPPLIER_INFO', TRUE);
   Database_SYS.Remove_View('PT_TAXONOMY_CODE', TRUE);
   Database_SYS.Remove_View('PT_TAXONOMY_CONFIG', TRUE);
   Database_SYS.Remove_View('PT_TAX_TABLE_INFO', TRUE);
   Database_SYS.Remove_View('PT_TRANSACTION_TYPE', TRUE);
   Database_SYS.Remove_View('PT_TRANSACTION_TYPE_CONFIG', TRUE);
   Database_SYS.Remove_View('PT_WORKING_DOCS_DOCS_TOTALS', TRUE);
   Database_SYS.Remove_View('PT_WORKING_DOCS_LINE_TAX_INFO', TRUE);
   Database_SYS.Remove_View('PT_WORKING_DOCUMENTS_HEADER', TRUE);
   Database_SYS.Remove_View('PT_WORKING_DOCUMENTS_INFO', TRUE);
   Database_SYS.Remove_View('PT_WORKING_DOCUMENTS_LINE_INFO', TRUE);
   Database_SYS.Remove_View('PT_WORKING_DOCUMENTS_PROD_INFO', TRUE);
   Database_SYS.Remove_View('SAFT_PT_GENERAL_PARAMETER', TRUE);
   Database_SYS.Remove_View('STATUTORY_FEE_TAX', TRUE);
   Database_SYS.Remove_View('TAX_CODE_TAX_CALC_STRUCTURE_IN', TRUE);
   Database_SYS.Remove_View('VOUCHERS_INVOICE_LOV', TRUE);
END;
/


exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','PRE_Accrul_G2C_Db_Cleanup.sql','Done');
PROMPT Finished with PRE_Accrul_G2C_Db_Cleanup.sql
