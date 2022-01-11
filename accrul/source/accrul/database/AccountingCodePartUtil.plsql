-----------------------------------------------------------------------------
--
--  Logical unit: AccountingCodePartUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  07-06-2004 MAWELK  Created.
--  30-12-2011 AsHelk  SBI-305, Added methods Get_Functn_Mapped_Code_Parts,Get_All_Code_Part_Functns___,Get_Code_Prt_Vals_By_Func_Tab.
--  09-01-2012 AsHelk  SBI-256, Introduced micro cache. 
--   121204     Maaylk  PEPA-183, Removed global variables
--  08-07-2013 Nudilk  Bug 111132, Introduced Get_Code_Part_Text
--  07-02-2018 Dakplk  STRFI-12120, Merged LCS Bug 140132, Modified Get_Code_Part_Text.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

micro_cache_code_company_     Accounting_Code_Part_Tab.company%TYPE;
micro_cache_code_language_    VARCHAR2(5);
micro_cache_code_time_        NUMBER := 0;
TYPE code_cache_type IS RECORD (
   code_value  accounting_code_part_value_pub.code_part_value%TYPE,
   code_desc   accounting_code_part_value_pub.description%TYPE);
TYPE code_cache_tab IS TABLE OF code_cache_type INDEX BY VARCHAR2(10);
micro_cache_code_rec_ code_cache_tab;
TYPE AllCodePartFunctionsType    IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
micro_cache_value_            Accounting_Codestr_Api.FuncMappedCodePrtsType;
micro_cache_time_             NUMBER := 0;
micro_cache_company_          VARCHAR2(20);

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Invalidate_Cache___
IS
   null_value_  Accounting_Codestr_Api.FuncMappedCodePrtsType;
BEGIN
 micro_cache_company_          := NULL;
 micro_cache_value_            := null_value_;
END Invalidate_Cache___;


PROCEDURE Update_Cache___ (
   company_            IN VARCHAR2 )
IS
   time_       NUMBER;
   expired_    BOOLEAN;

   CURSOR get_code_parts IS
       SELECT code_part, code_part_function 
       FROM accounting_code_part_tab t
        WHERE t.company             = company_
          AND t.code_part_used      = 'Y'
          AND t.code_part_function != 'NOFUNC';
        
  CURSOR get_code_parts1 IS
      SELECT code_part
      FROM   accounting_code_part_tab
      WHERE  company           = company_
      AND    logical_code_part = 'Project';
      
  code_parts_by_func_tab_  Accounting_Codestr_API.FuncMappedCodePrtsType;
  code_part_               accounting_code_part_tab.code_part%TYPE;

BEGIN
   time_    := Database_SYS.Get_Time_Offset;
   expired_ := ((time_- micro_cache_time_) > 100);
   IF (NOT expired_) AND (micro_cache_company_ = company_) THEN
      NULL;
   ELSE
     $IF Component_Genled_SYS.INSTALLED $THEN
        FOR rec_ IN get_code_parts LOOP
            code_parts_by_func_tab_(rec_.code_part_function) := rec_.code_part;        
        END LOOP;
     $ELSE
        OPEN  get_code_parts1;
        FETCH get_code_parts1 INTO code_part_;
        CLOSE get_code_parts1;
        code_parts_by_func_tab_('PRACC') := code_part_;
     $END
     micro_cache_value_    := code_parts_by_func_tab_;  
     micro_cache_company_  := company_;
     micro_cache_time_     := time_;
   END IF;
END Update_Cache___;


PROCEDURE Initialize_Code_Cache___
IS
BEGIN
   FOR i_ IN 1..10 LOOP
      micro_cache_code_rec_('CODE'||CHR(64+i_)).code_value := NULL;
      micro_cache_code_rec_('CODE'||CHR(64+i_)).code_desc := NULL;
   END LOOP;
END Initialize_Code_Cache___;


FUNCTION Get_All_Code_Part_Functns___ RETURN AllCodePartFunctionsType
IS
  all_code_prt_functions_tab_   AllCodePartFunctionsType;
  code_part_functions_      VARCHAR2(2000);
  temp_code_part_func_      VARCHAR2(10);
  
  index_                    PLS_INTEGER := 0;
  location_                 PLS_INTEGER;
  delim_                    VARCHAR2(2) := Client_SYS.field_separator_;
BEGIN
   Accounting_Code_Part_Fu_API.Enumerate_Db(code_part_functions_); 
   LOOP
      location_  := INSTR(code_part_functions_,delim_);
      IF (location_ > 0) THEN
         temp_code_part_func_ := SUBSTR(code_part_functions_,1,location_-1);
         IF (temp_code_part_func_ != 'NOFUNC') THEN
           index_ := index_+1;
           all_code_prt_functions_tab_(index_) := temp_code_part_func_;
         END IF;
         code_part_functions_ := SUBSTR(code_part_functions_, location_+1);
      ELSE
         IF (code_part_functions_ != 'NOFUNC') THEN
           index_ := index_+1;
           all_code_prt_functions_tab_(index_) := code_part_functions_;
         END IF;
         EXIT;
      END IF; 
   END LOOP;
   RETURN  all_code_prt_functions_tab_;  
END Get_All_Code_Part_Functns___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Functn_Mapped_Code_Parts (
   company_  IN VARCHAR2 ) RETURN Accounting_Codestr_API.FuncMappedCodePrtsType
IS
  
BEGIN
   Update_Cache___(company_);
   RETURN micro_cache_value_;
END Get_Functn_Mapped_Code_Parts;



@UncheckedAccess
FUNCTION Get_Code_Prt_Vals_By_Func_Tab RETURN Accounting_Codestr_API.CodePrtValsByFunctionType
IS
  code_part_vals_by_function_  Accounting_Codestr_API.CodePrtValsByFunctionType;
  all_code_part_functns_tab_   AllCodePartFunctionsType; 
BEGIN
   all_code_part_functns_tab_ := Get_All_Code_Part_Functns___;
   IF (all_code_part_functns_tab_.COUNT > 0) THEN
      FOR index_ IN all_code_part_functns_tab_.FIRST..all_code_part_functns_tab_.LAST LOOP
          code_part_vals_by_function_(all_code_part_functns_tab_(index_)):=NULL;
      END LOOP;
   END IF;
   RETURN code_part_vals_by_function_;
END Get_Code_Prt_Vals_By_Func_Tab;



-- Get_Used_Codepart_By_Function
--   Returns the code part, which is used in the given company, for a given code part function e.g. PRACC in a company
@UncheckedAccess
FUNCTION Get_Used_Codepart_By_Function(
   company_          IN VARCHAR2,
   code_part_func_   IN VARCHAR2) RETURN VARCHAR2
IS
   function_mapped_code_prts_   Accounting_Codestr_API.FuncMappedCodePrtsType := Get_Functn_Mapped_Code_Parts(company_);
BEGIN
   IF (NOT function_mapped_code_prts_.EXISTS(code_part_func_)) THEN
      RETURN NULL;
   END IF;
   RETURN function_mapped_code_prts_(code_part_func_);
END Get_Used_Codepart_By_Function;



@UncheckedAccess
FUNCTION Get_Code_Part_Text (
   company_         IN VARCHAR2,
   text_type_       IN VARCHAR2,
   text_type_value_ IN VARCHAR2,
   lang_code_       IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   text_               VARCHAR2(2000);
   use_lang_code_      VARCHAR2(5);
   time_               NUMBER;
   expired_            BOOLEAN := FALSE;

BEGIN
   time_    := Database_SYS.Get_Time_Offset;
   expired_ := ((time_ - micro_cache_code_time_) > 100);

   -- Initialize code part cache if empty
   IF (NOT micro_cache_code_rec_.EXISTS('CODEA')) THEN
      -- set expired to trigger the Initialize_Code_Cache___ call
      expired_ := TRUE;
   END IF;
   
   IF (User_Finance_API.Is_User_Authorized(company_)) THEN
      IF (lang_code_ IS NULL) THEN
         use_lang_code_ := Language_SYS.Get_Language;
      ELSE
         use_lang_code_ := lang_code_;
      END IF;
      IF (micro_cache_code_language_ = use_lang_code_) THEN
         NULL;
      ELSE
         micro_cache_code_language_ := use_lang_code_;
         -- set expired to true to enforce a clear of the cache and retreive new code part text
         expired_ := TRUE;
      END IF;
      IF expired_ THEN
         -- Just set the new cache time when the cache has expired and not when just a code part has changed
         -- otherwise the cache time will be set more often than (practically) needed.
         -- When expired all the code parts cached data is reset.
         Initialize_Code_Cache___;
         micro_cache_code_time_ := time_;
      END IF;
      -- If text_type_ is not CODEA-CODEJ then return null
      IF (NOT micro_cache_code_rec_.EXISTS(text_type_)) THEN
         RETURN NULL;
      END IF;

      IF (NOT expired_ AND micro_cache_code_company_ = company_) THEN
         IF (micro_cache_code_rec_(text_type_).code_value = text_type_value_) THEN
            text_ := micro_cache_code_rec_(text_type_).code_desc;
         ELSE
            IF (text_type_ = 'CODEA') THEN
               text_ := ACCOUNT_API.Get_Description(company_, text_type_value_);
            ELSIF (text_type_ = 'CODEB') THEN
               text_ := Code_B_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEC') THEN
               text_ := Code_C_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODED') THEN
               text_ := Code_D_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEE') THEN
               text_ := Code_E_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEF') THEN
               text_ := Code_F_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEG') THEN
               text_ := Code_G_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEH') THEN
               text_ := Code_H_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEI') THEN
               text_ := Code_I_API.Get_Description(company_, text_type_value_, use_lang_code_);
            ELSIF (text_type_ = 'CODEJ') THEN
               text_ := Code_J_API.Get_Description(company_, text_type_value_, use_lang_code_);
            END IF;

            micro_cache_code_rec_(text_type_).code_value := text_type_value_;
            micro_cache_code_rec_(text_type_).code_desc := text_;
         END IF;
      ELSE
         IF (text_type_ = 'CODEA') THEN
            text_ := ACCOUNT_API.Get_Description(company_, text_type_value_);
         ELSIF (text_type_ = 'CODEB') THEN
            text_ := Code_B_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEC') THEN
            text_ := Code_C_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODED') THEN
            text_ := Code_D_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEE') THEN
            text_ := Code_E_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEF') THEN
            text_ := Code_F_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEG') THEN
            text_ := Code_G_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEH') THEN
            text_ := Code_H_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEI') THEN
            text_ := Code_I_API.Get_Description(company_, text_type_value_, use_lang_code_);
         ELSIF (text_type_ = 'CODEJ') THEN
            text_ := Code_J_API.Get_Description(company_, text_type_value_, use_lang_code_);
         END IF;

         micro_cache_code_rec_(text_type_).code_value := text_type_value_;
         micro_cache_code_rec_(text_type_).code_desc := text_;
         micro_cache_code_company_ := company_;
      END IF;
      RETURN text_;
   ELSE
      RETURN NULL;
   END IF;
END Get_Code_Part_Text;




