-----------------------------------------------------------------------------
--
--  Logical unit: AccrulInstallation
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  170125  ShFrlk  STRBI-1260, Grant permission for IAL views.
--  170103  ShFrlk  STRBI-1261, Create view ACCOUNTING_ATTRIBUTE_CON_BIA in IAL schema.
--  160808  Hecolk  Created
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Insert_Posting_Control_Type___
IS      
BEGIN
   IF (Database_SYS.Component_Active('INVENT')) THEN
      IF (Module_API.Is_Included_In_Delivery('ACCRUL') OR Module_API.Is_Included_In_Delivery('INVENT')) THEN
         Posting_Ctrl_API.Insert_Control_Type('AC22', module_, 'Project Connection', 'SYSTEM_DEFINED', 'PROJECT_CONNECTION_INFO', 'INVENT_POSTING_CTRL_API');
      END IF;
   END IF;
END Insert_Posting_Control_Type___;

PROCEDURE Post_Installation_Object___
IS 
BEGIN
   Create_View_In_Ifsinfo___('ACCOUNTING_ATTRIBUTE_CON_BIA');
END Post_Installation_Object___;


PROCEDURE Create_View_In_Ifsinfo___(
   bi_view_name_ IN VARCHAR2)
IS
   log_text_      XLR_IMPORT_LOG_TAB.message%TYPE; 
BEGIN      
   IF (Database_SYS.View_Exist(bi_view_name_)) THEN      
      Bi_Utility_API.Create_Bi_View_Ifsinfo(bi_view_name_, module_);
   
      log_text_ := Language_SYS.Translate_Constant(lu_name_, 'VIEWCREIFSINFO: View ":P1" created in <IFSINFO> schema',NULL, bi_view_name_);
      Xlr_Log_Util_API.Log_Text(log_text_, 'INFO:VIEWCREIFSINFO');
   END IF;   
END Create_View_In_Ifsinfo___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Post_Installation_Data
IS   
BEGIN
   -- Create all posting control entries for dynamic modules.
   Insert_Posting_Control_Type___();  
END Post_Installation_Data;

PROCEDURE Post_Installation_Object
IS
BEGIN
   Post_Installation_Object___;   
END Post_Installation_Object;

-------------------- LU  NEW METHODS -------------------------------------
