-----------------------------------------------------------------------------
--
--  Logical unit: AvLogbookType
--  Component:    ADCOM
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  200727  TAJALK  LMM2020R1-481 Created, added methods for Mxi Sync
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE Get_Id_Version_By_Mx_Uniq_Key (
   objid_      OUT VARCHAR2,
   objversion_ OUT VARCHAR2,
   mx_unique_key_ IN VARCHAR2 ) 
IS  
   
   CURSOR get_key IS
   SELECT   rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')       
      FROM  av_logbook_type_tab
      WHERE logbook_type_code = mx_unique_key_;
BEGIN
   OPEN  get_key;
   FETCH get_key INTO objid_, objversion_;
   CLOSE get_key;
   
END Get_Id_Version_By_Mx_Uniq_Key;

PROCEDURE Pre_Sync_Action(
   attr_  IN OUT VARCHAR2)
IS
   local_attr_                VARCHAR2(4000);
   logbook_type_code_         av_logbook_type_tab.logbook_type_code%TYPE;
BEGIN
   local_attr_        := attr_;
   logbook_type_code_ := Client_SYS.Get_Item_Value('LOGBOOK_TYPE_CODE', local_attr_); 
   
   IF Check_Exist___(logbook_type_code_) THEN
      local_attr_:= Client_SYS.Remove_Attr('LOGBOOK_TYPE_CODE',  local_attr_);
   END IF;
   
   attr_ := local_attr_;
END Pre_Sync_Action;


