-----------------------------------------------------------------------------
--
--  Logical unit: CounterPartOne
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

FUNCTION Is_Rep_Entity_Connected___(
   company_          IN VARCHAR2,
   reporting_entity_ IN VARCHAR2) RETURN BOOLEAN
IS 
   temp_ NUMBER;
   
   CURSOR get_rep_entity IS
      SELECT 1 
      FROM  ACCOUNTING_CODE_PART_VALUE_TAB 
      WHERE company          = company_
      AND   reporting_entity = reporting_entity_;
BEGIN 
   OPEN get_rep_entity;
   FETCH get_rep_entity INTO temp_;
   IF (get_rep_entity%FOUND) THEN 
      CLOSE get_rep_entity;
      RETURN TRUE;
   ELSE 
      CLOSE get_rep_entity;
      RETURN FALSE;
   END IF;
END Is_Rep_Entity_Connected___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   valid_until_      Accrul_Attribute_Tab.attribute_value%TYPE;
BEGIN
   super(attr_);
   valid_until_    := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_VALID_TO');   
   Client_SYS.Add_To_Attr('CODE_PART','K', attr_ );
   Client_SYS.Add_To_Attr('VALID_FROM', TRUNC(SYSDATE), attr_);
   Client_SYS.Add_To_Attr('VALID_UNTIL',TRUNC(to_date(valid_until_, 'YYYYMMDD')), attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN accounting_code_part_value_tab%ROWTYPE )
IS
BEGIN
   super(remrec_);
   
   $IF Component_Grocon_SYS.INSTALLED $THEN
   -- checks whether the counterpart one is used in code part value mapping (header level or detail level)
   IF ((Rep_Codepart_Val_Map_API.Is_Mc_Codepart_Value_Used(remrec_.company, 
                                                           'K', 
                                                           remrec_.code_part_value)= TRUE) 
        OR 
       (Rep_Codepart_Val_Det_Map_API.Is_Mc_Codepart_Value_Used(remrec_.company, 
                                                               'K', 
                                                               remrec_.code_part_value)= TRUE)) THEN
      Error_SYS.Appl_General(lu_name_, 'COUNTERPARTONEUSED: Counterpart one :P1 cannot be deleted as it is used in code part value mapping.', remrec_.code_part_value);
   END IF;     
   $END
    
END Check_Delete___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     accounting_code_part_value_tab%ROWTYPE,
   newrec_ IN OUT accounting_code_part_value_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF ((INSTR( newrec_.code_part_value,'&') > 0) OR (INSTR( newrec_.code_part_value,'^') > 0) OR (INSTR( newrec_.code_part_value,'''') > 0)) THEN
      Error_SYS.Record_General('CodeK', 'INVCHARACTORS: You have entered an invalid character in this field');
   END IF;
   newrec_.rowtype := 'Code' || newrec_.code_part;
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
   Accounting_Code_Part_Value_API.Validate_Common_Additional(newrec_);
   IF (indrec_.reporting_entity) AND 
      (Is_Rep_Entity_Connected___(newrec_.company, newrec_.reporting_entity)) THEN
      Error_SYS.Appl_General(lu_name_, 'REPENTCONNECTED: The selected reporting entity :P1 is already connected to another countrerpart in master company :P2 .', newrec_.reporting_entity, newrec_.company);      
   END IF;
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
FUNCTION Get_Cp_From_Reporting_Entity (
   company_          IN VARCHAR2,
   reporting_entity_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ ACCOUNTING_CODE_PART_VALUE_TAB.reporting_entity%TYPE;
   CURSOR get_attr IS
      SELECT code_part_value
      FROM   ACCOUNTING_CODE_PART_VALUE_TAB
      WHERE  company = company_
       AND   reporting_entity = reporting_entity_
       AND   code_part = 'K';
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Cp_From_Reporting_Entity;


@UncheckedAccess
FUNCTION Check_Exist (
   company_             IN VARCHAR2,
   counter_part_one_id_ IN VARCHAR2 ) RETURN BOOLEAN
IS  
BEGIN
   RETURN Check_Exist___(company_,
                         counter_part_one_id_);
END Check_Exist;


