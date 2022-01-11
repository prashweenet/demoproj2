-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodestrCoUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  100914  Jaralk Bug 92858 Created new package Added two methods Insert_Code_Parts and Delete_Code_Parts  
--          to update the ACCOUNTING_CODESTR_COMPL_TAB to reflect the changes done in ACCOUNTING_CODE_PART tab
--  110803  Kanslk  FIDEAGLE-1257, added 'Compare_Code_Strings_Info()','Compare_Code_Part()','Is_Codestring_Value()','Apply_Defined_Codestr()' and 'Codepart_Info()'.
--  120829  JuKoDE  EDEL-1532, Added General_SYS.Init_Method in Apply_Defined_Codestr(), Compare_Code_Strings_Info(
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Insert_Code_Parts (
   company_            IN VARCHAR2,
   codefill_code_part_ IN VARCHAR2 )
IS

   CURSOR get_code_info IS
      SELECT   t.code_part_value, t.code_part
      FROM     ACCOUNTING_CODESTR_COMPL_TAB t 
      WHERE    t.company = company_
      GROUP BY t.code_part_value, t.code_part;
   newrec_     ACCOUNTING_CODESTR_COMPL_TAB%ROWTYPE;
   
BEGIN
   FOR rec_ IN get_code_info LOOP
      newrec_.company            := company_;
      newrec_.code_part          := rec_.code_part;
      newrec_.code_part_value    := rec_.code_part_value;
      newrec_.codefill_code_part := codefill_code_part_;
      newrec_.codefill_value     := NULL;
      newrec_.rowversion         := SYSDATE;
      ACCOUNTING_CODESTR_COMPL_API.Insert_Code_Parts(newrec_);
   END LOOP;
END Insert_Code_Parts;


PROCEDURE Delete_Code_Parts (
   company_            IN VARCHAR2,
   codefill_code_part_ IN VARCHAR2 )
IS
   CURSOR get_code_value IS
      SELECT   t.code_part_value, t.code_part
      FROM     ACCOUNTING_CODESTR_COMPL_TAB t
      WHERE    t.company = company_
      GROUP BY t.code_part_value, t.code_part;
BEGIN

   FOR rec_ IN get_code_value LOOP
      ACCOUNTING_CODESTR_COMPL_API.Delete_Code_Parts(company_, rec_.code_part,rec_.code_part_value,codefill_code_part_);
   END LOOP; 
END Delete_Code_Parts;


PROCEDURE Compare_Code_Strings_Info (
   code_part_             OUT     VARCHAR2,
   code_part_value2_      OUT     VARCHAR2,
   code_part_value1_      OUT     VARCHAR2,
   mis_match_             IN  OUT VARCHAR2,
   code_string_to_diff_   IN      Accounting_Codestr_API.CodestrRec,
   define_code_string_    IN      VARCHAR2)
IS
BEGIN
   IF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_a,
                           CLIENT_SYS.Get_Item_Value('ACCOUNT',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'A';
      code_part_value2_ := code_string_to_diff_.code_a;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('ACCOUNT',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_b,
                           CLIENT_SYS.Get_Item_Value('CODE_B',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'B';
      code_part_value2_ := code_string_to_diff_.code_b;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_B',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_c,
                           CLIENT_SYS.Get_Item_Value('CODE_C',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'C';
      code_part_value2_ := code_string_to_diff_.code_c;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_C',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_d,
                           CLIENT_SYS.Get_Item_Value('CODE_D',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'D';
      code_part_value2_ := code_string_to_diff_.code_d;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_D',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_e,
                           CLIENT_SYS.Get_Item_Value('CODE_E',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'E';
      code_part_value2_ := code_string_to_diff_.code_e;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_E',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_f,
                           CLIENT_SYS.Get_Item_Value('CODE_F',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'F';
      code_part_value2_ := code_string_to_diff_.code_f;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_F',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_g,
                           CLIENT_SYS.Get_Item_Value('CODE_G',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'G';
      code_part_value2_ := code_string_to_diff_.code_g;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_G',define_code_string_); 
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_h,
                           CLIENT_SYS.Get_Item_Value('CODE_H',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'H';
      code_part_value2_ := code_string_to_diff_.code_h;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_H',define_code_string_); 
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_i,
                           CLIENT_SYS.Get_Item_Value('CODE_I',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'I';
      code_part_value2_ := code_string_to_diff_.code_i;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_I',define_code_string_); 
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.code_j,
                           CLIENT_SYS.Get_Item_Value('CODE_J',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'J';
      code_part_value2_ := code_string_to_diff_.code_j;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('CODE_J',define_code_string_);
   ELSIF mis_match_= 'FALSE' AND Compare_Code_Part(code_string_to_diff_.process_code,
                           CLIENT_SYS.Get_Item_Value('PROCESS_CODE',define_code_string_)) ='FALSE' THEN
      mis_match_ := 'TRUE';
      code_part_ := 'PROCESS_CODE';
      code_part_value2_ := code_string_to_diff_.process_code;
      code_part_value1_ := CLIENT_SYS.Get_Item_Value('PROCESS_CODE',define_code_string_);
   END IF;
END Compare_Code_Strings_Info;


@UncheckedAccess
FUNCTION Compare_Code_Part (
   value_to_diff_   IN VARCHAR2,
   define_value_    IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF define_value_ IS NULL AND value_to_diff_ IS NOT NULL THEN
      RETURN 'TRUE';
   ELSIF define_value_ IS NOT NULL AND value_to_diff_ IS NULL THEN
      RETURN 'TRUE';
   ELSIF define_value_ <> value_to_diff_ THEN
      RETURN 'FALSE';
   ELSE
      RETURN 'TRUE';
   END IF;
END Compare_Code_Part;



@UncheckedAccess
FUNCTION Is_Codestring_Value(
   code_part_        IN VARCHAR2,
   found_value_      IN VARCHAR2,
   code_string_rec_  IN Accounting_Codestr_API.CodestrRec ) RETURN VARCHAR2
IS
BEGIN
   IF code_part_ ='A' THEN
      IF found_value_ = code_string_rec_.code_a THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'B' THEN
      IF found_value_ = code_string_rec_.code_b THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'C' THEN
      IF found_value_ = code_string_rec_.code_c THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'D' THEN
      IF found_value_ = code_string_rec_.code_d THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'E' THEN
      IF found_value_ = code_string_rec_.code_e THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'F' THEN
      IF found_value_ = code_string_rec_.code_f THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'G' THEN
      IF found_value_ = code_string_rec_.code_g THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'H' THEN
      IF found_value_ = code_string_rec_.code_h THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'I' THEN
      IF found_value_ = code_string_rec_.code_i THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'J' THEN
      IF found_value_ = code_string_rec_.code_j THEN
         RETURN 'TRUE';
      END IF;
   ELSIF code_part_ = 'PROCESS_CODE' THEN
      IF found_value_ = code_string_rec_.process_code THEN
         RETURN 'TRUE';
      END IF;
   END IF;
   RETURN 'FALSE';
END Is_Codestring_Value;



PROCEDURE Apply_Defined_Codestr (
   merged_code_string_     IN OUT Accounting_Codestr_API.CodestrRec,
   define_code_string_     IN     VARCHAR2)
IS
BEGIN
   IF INSTR(define_code_string_,'ACCOUNT')>0 THEN
      merged_code_string_.code_a := CLIENT_SYS.Get_Item_Value('ACCOUNT',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_B')>0 THEN
      merged_code_string_.code_b := CLIENT_SYS.Get_Item_Value('CODE_B',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_C')>0 THEN
      merged_code_string_.code_c := CLIENT_SYS.Get_Item_Value('CODE_C',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_D')>0 THEN
      merged_code_string_.code_d := CLIENT_SYS.Get_Item_Value('CODE_D',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_E')>0 THEN
      merged_code_string_.code_e := CLIENT_SYS.Get_Item_Value('CODE_E',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_F')>0 THEN
      merged_code_string_.code_f := CLIENT_SYS.Get_Item_Value('CODE_F',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_G')>0 THEN
      merged_code_string_.code_g := CLIENT_SYS.Get_Item_Value('CODE_G',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_H')>0 THEN
      merged_code_string_.code_h := CLIENT_SYS.Get_Item_Value('CODE_H',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_I')>0 THEN
      merged_code_string_.code_i := CLIENT_SYS.Get_Item_Value('CODE_I',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'CODE_J')>0 THEN
      merged_code_string_.code_j := CLIENT_SYS.Get_Item_Value('CODE_J',define_code_string_);
   END IF;
   IF INSTR(define_code_string_,'PROCESS_CODE')>0 THEN
      merged_code_string_.process_code := CLIENT_SYS.Get_Item_Value('PROCESS_CODE',define_code_string_);
   END IF;
END Apply_Defined_Codestr;


PROCEDURE Codepart_Info (
   code_part_       OUT VARCHAR2,
   code_part_value_ OUT VARCHAR2,
   codestr_rec_     IN  Accounting_Codestr_API.CodestrRec,
   position_        IN  NUMBER )
IS
BEGIN
   IF position_ = 1 THEN
      IF codestr_rec_.code_a IS NOT NULL THEN
         code_part_       := 'A'; 
         code_part_value_ := codestr_rec_.code_a;
      END IF;
   ELSIF position_ = 2 THEN
      IF codestr_rec_.code_b IS NOT NULL THEN
         code_part_       := 'B'; 
         code_part_value_ := codestr_rec_.code_b;
      END IF;
   ELSIF position_ = 3 THEN
      IF codestr_rec_.code_c IS NOT NULL THEN
         code_part_       := 'C'; 
         code_part_value_ := codestr_rec_.code_c;
      END IF;
   ELSIF position_ = 4 THEN
      IF codestr_rec_.code_d IS NOT NULL THEN
         code_part_       := 'D'; 
         code_part_value_ := codestr_rec_.code_d;
      END IF;
   ELSIF position_ = 5 THEN
      IF codestr_rec_.code_e IS NOT NULL THEN
         code_part_       := 'E'; 
         code_part_value_ := codestr_rec_.code_e;
      END IF;
   ELSIF position_ = 6 THEN
      IF codestr_rec_.code_f IS NOT NULL THEN
         code_part_       := 'F'; 
         code_part_value_ := codestr_rec_.code_f;
      END IF;
   ELSIF position_ = 7 THEN
      IF codestr_rec_.code_g IS NOT NULL THEN
         code_part_       := 'G'; 
         code_part_value_ := codestr_rec_.code_g;
      END IF;
   ELSIF position_ = 8 THEN
      IF codestr_rec_.code_h IS NOT NULL THEN
         code_part_       := 'H'; 
         code_part_value_ := codestr_rec_.code_h;
      END IF;
   ELSIF position_ = 9 THEN
      IF codestr_rec_.code_i IS NOT NULL THEN
         code_part_       := 'I'; 
         code_part_value_ := codestr_rec_.code_i;
      END IF;
   ELSIF position_ = 10 THEN
      IF codestr_rec_.code_j IS NOT NULL THEN
         code_part_       := 'J'; 
         code_part_value_ := codestr_rec_.code_j;
      END IF;
   END IF;
END Codepart_Info;



