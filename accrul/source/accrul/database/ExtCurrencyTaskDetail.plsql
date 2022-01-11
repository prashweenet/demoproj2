-----------------------------------------------------------------------------
--
--  Logical unit: ExtCurrencyTaskDetail
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  010329  Uma    Created for Bug# 20944 - Merge Wizard modifications.
--  010612  ARMOLK Bug # 15677 Add call to General_SYS.Init_Method
--  010911  JeGu   Bug #24286 Added column inverted and new function Get_Inverted
--  020103  PPer   Added External File handling
--  020203  JeGu   Changed view EXT_CURRENCY_TASK_DETAIL. Added company authorization.
--                 New function Any_Auth_Exist
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   company_             EXT_CURRENCY_TASK_DETAIL_TAB.company%TYPE;
   currency_type_       EXT_CURRENCY_TASK_DETAIL_TAB.currency_type%TYPE;
   tmp_attr_   VARCHAR2(32000);
BEGIN
   tmp_attr_ := attr_;
   super(attr_);
   attr_ := tmp_attr_;
   company_ := Client_SYS.Get_Item_Value('COMPANY', attr_);
   currency_type_   := Currency_Type_API.Get_Default_Type(company_);
   Client_SYS.Add_To_Attr( 'CURRENCY_TYPE', currency_type_, attr_ );
END Prepare_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Task_Details (
   message_ OUT VARCHAR2,
   count_   OUT NUMBER,
   task_id_ IN VARCHAR2 )
IS
   CURSOR get_rec IS
      SELECT *
      FROM EXT_CURRENCY_TASK_DETAIL_TAB
      WHERE task_id = task_id_;
  sub_message_ VARCHAR2(2000);
BEGIN
   count_ := 0;
   Ext_Currency_Task_API.Exist(task_id_);
      message_ := Message_Sys.Construct('MAIN MESSAGE');
      FOR rec_ IN get_rec LOOP
         sub_message_ := Message_Sys.Construct('TASK DETAILS');
         Message_Sys.Add_Attribute(sub_message_, 'COMPANY', rec_.company);
         Message_Sys.Add_Attribute(sub_message_, 'CURRENCY_TYPE', rec_.currency_type);
         count_ := count_ + 1;
         Message_Sys.Add_Attribute(message_, TO_CHAR(count_), sub_message_);
      END LOOP;
END Get_Task_Details;


@UncheckedAccess
FUNCTION Any_Auth_Exist (
   task_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_CURRENCY_TASK_DETAIL
      WHERE task_id = task_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Any_Auth_Exist;



