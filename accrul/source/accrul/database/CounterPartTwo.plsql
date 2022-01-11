-----------------------------------------------------------------------------
--
--  Logical unit: CounterPartTwo
--  Component:    GROCON
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
PROCEDURE Check_Common___ (
   oldrec_ IN     accounting_code_part_value_tab%ROWTYPE,
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF ((INSTR( newrec_.code_part_value,'&') > 0) OR (INSTR( newrec_.code_part_value,'^') > 0) OR (INSTR( newrec_.code_part_value,'''') > 0)) THEN
      Error_SYS.Record_General('CodeL', 'INVCHARACTORS: You have entered an invalid character in this field');
   END IF;
   newrec_.rowtype := 'Code' || newrec_.code_part;
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
   Accounting_Code_Part_Value_API.Validate_Common_Additional(newrec_);
END Check_Common___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(newrec_, indrec_, attr_);
   --Add post-processing code here
   Accounting_Code_Part_Value_API.Validate_Insert_Additional(newrec_);
END Check_Insert___;

@Override

@Override
PROCEDURE Insert___ (
   objid_         OUT VARCHAR2,
   objversion_    OUT VARCHAR2,
   newrec_     IN OUT accounting_code_part_value_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
    code_part_   VARCHAR2(1); 
BEGIN
   --Add pre-processing code here
   super(objid_, objversion_, newrec_, attr_);
   --Add post-processing code here
   $IF Component_Grocon_SYS.INSTALLED $THEN    
      code_part_ := Company_Grocon_Info_API.Get_Code_Part(newrec_.company);
      IF ((code_part_ IS NOT NULL) AND 
          (NOT(Accounting_Code_Part_Value_API.Exist_Code_Part_Value2(newrec_.company, code_part_,newrec_.code_part_value)))) THEN
            Client_SYS.Add_To_Attr('COMPANY',  newrec_.company, attr_);      
            Client_SYS.Add_To_Attr('CODE_PART_VALUE',  newrec_.code_part_value, attr_);
            Client_SYS.Add_To_Attr('CODE_PART', code_part_, attr_);
            Client_SYS.Add_To_Attr('DESCRIPTION',  newrec_.description, attr_);
            Client_SYS.Add_To_Attr('VALID_FROM', newrec_.valid_from, attr_);
            Client_SYS.Add_To_Attr('VALID_UNTIL', newrec_.valid_until, attr_);
            Accounting_Code_Part_Value_API.New_Code_Part_Value(attr_); 
      END IF;
   $END
END Insert___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   valid_until_      Accrul_Attribute_Tab.attribute_value%TYPE;
BEGIN
   super(attr_);
   valid_until_    := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');   
   Client_SYS.Add_To_Attr('CODE_PART','L', attr_ );
   Client_SYS.Add_To_Attr('VALID_FROM', TRUNC(SYSDATE), attr_);
   Client_SYS.Add_To_Attr('VALID_UNTIL',TRUNC(to_date(valid_until_, 'YYYYMMDD')), attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN ACCOUNTING_CODE_PART_VALUE_TAB%ROWTYPE )
IS
BEGIN
   super(remrec_);
   
   $IF Component_Grocon_SYS.INSTALLED $THEN
   -- checks whether the counterpart two is used in code part value mapping (header level or detail level)
   IF ((Rep_Codepart_Val_Map_API.Is_Mc_Codepart_Value_Used(remrec_.company, 
                                                           'L', 
                                                           remrec_.code_part_value)= TRUE) 
       OR 
       (Rep_Codepart_Val_Det_Map_API.Is_Mc_Codepart_Value_Used(remrec_.company, 
                                                               'L', 
                                                               remrec_.code_part_value)= TRUE)) THEN
      Error_SYS.Appl_General(lu_name_, 'COUNTERPARTTWOUSED: Counterpart two :P1 cannot be deleted as it is used in code part value mapping.', remrec_.code_part_value);
   END IF;
   $END
   
END Check_Delete___;

@Override
PROCEDURE Unpack___ (
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(newrec_, indrec_, attr_);
   
   IF NOT (indrec_.code_part_value) THEN
      IF (Client_SYS.Item_Exist('CODE_PART_VALUE', attr_)) THEN
         newrec_.code_part_value := Client_SYS.Get_Item_Value('CODE_PART_VALUE', attr_);
         indrec_.code_part_value := TRUE;
      END IF;
   END IF;
END Unpack___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Exist (
   master_company_      IN VARCHAR2,
   counter_part_two_id_ IN VARCHAR2 ) RETURN BOOLEAN
IS  
BEGIN
   RETURN Check_Exist___(master_company_,
                         counter_part_two_id_);
END Check_Exist;


