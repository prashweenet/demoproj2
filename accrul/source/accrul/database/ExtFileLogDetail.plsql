-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileLogDetail
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  111112  MEALLK  PBFI-2010, Refactoring code
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Delete_File_Log (
   load_file_id_         IN     NUMBER )
IS
BEGIN
   DELETE
   FROM   Ext_File_Log_Detail_Tab
   WHERE  load_file_id = load_file_id_;
END Delete_File_Log;



