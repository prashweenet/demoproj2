-----------------------------------------------------------------------------
--
--  Logical unit: CodeS
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  151230  PRatlk  FINGP-22,Moved additional code parts to ACCRUL.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN      
   super(attr_);
   Accounting_Code_Part_Value_API.Add_Default_Values_Additional(attr_, 'S');
END Prepare_Insert___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     Accounting_code_part_value_tab%ROWTYPE,
   newrec_ IN OUT Accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF ((INSTR( newrec_.code_part_value,'&') > 0) OR (INSTR( newrec_.code_part_value,'^') > 0) OR (INSTR( newrec_.code_part_value,'''') > 0)) THEN
      Error_SYS.Record_General('CodeS', 'INVCHARACTORS: You have entered an invalid character in this field');
   END IF;
   newrec_.rowtype := 'Code' || newrec_.code_part;
   super(oldrec_, newrec_, indrec_, attr_);
   Accounting_Code_Part_Value_API.Validate_Common_Additional(newrec_);
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS   
BEGIN
   super(newrec_, indrec_, attr_);   
   Accounting_Code_Part_Value_API.Validate_Insert_Additional(newrec_);    
END Check_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
PROCEDURE New_Code_Part_Value (
   attr_      IN VARCHAR2 )
IS
   info_         VARCHAR2(2000);
   objid_        ROWID;
   objversion_   VARCHAR2(2000);
   new_attr_     VARCHAR2(4000);
BEGIN
   new_attr_ := attr_;
   New__(info_, objid_, objversion_, new_attr_, 'DO');
END New_Code_Part_Value;



