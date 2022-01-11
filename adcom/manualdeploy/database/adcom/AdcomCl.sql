--------------------------------------------------------------------------------
--
--  File:         AdcomCl.sql
--
--  Component:    ADCOM
--
--  Purpose:      Remove copied default data tables and other temporary tables
--                used to upgrade ADCOM.
-- 
--  Localization: Not needed.
--
--  Notes:        
--
--  Date    Sign     History
--  ------  ----     --------------------------------------------------------------
--  120521  dhaslk   Removing obsolete files and tables  
--------------------------------------------------------------------------------

PROMPT NOTE! This script drops tables and columns no longer used in core
PROMPT and must be edited before usage.                                         
ACCEPT Press_any_key                                                            
EXIT; -- Remove me before usage

SET SERVEROUTPUT ON

PROMPT Dropping obsolete tables from previous releases.
BEGIN
   Database_Sys.Remove_Table( 'AV_HIST_USG_SNAPSHOT_REC_2113' );
   Database_Sys.Remove_Table( 'AV_HIST_USG_SNAPSHOT_DATA_2113' );
END;
/

PROMPT -------------------------------------------------------------
PROMPT Drop of obsolete table in ADCOM done!
PROMPT ---------------------------------------------------
        

                     
