-----------------------------------------------------------------------------
--
--  Logical unit: FinanceLib
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  951017  MJ      Created
--  960123  ToRe    Defines for LU and PKG added.
--  960401  MIJO    Changed name on procedure Check_Am_Master to Check_Master.
--  980608  Kanchi  Modified check_module procedure
--  981112  Ruwan   Added the Is_Accrul_Master procedure since there are conflicts
--                  when Is_Master function is called by the Is_Master procedure
--                  (Overloading ?)
--  000912  HiMu    Added General_SYS.Init_Method
--  001019  SAABLK  Added the function Fin_LengthB
--  010530  Bmekse  Review of Distributed Installation. Removed old commented 
--                  code.
--  010912  Bmekse  Removed &MASTER_CODE and &ACCRUL_ID and replaced them with 
--                  values in Accrul_Attribute_Tab
--  020122  Upulp   IID 10114 Job Costing
--  031107  SHSALK  Added new function Get_Session_Id.
--  040316  Hecolk  IID FIPR300C1, Added FUNCTION Set_Params_For_Scheduled_Proc 
--  090810  LaPrlk  Bug 79846, Removed the precisions defined for NUMBER type variables.
--  100521  Kagalk  EAFH-2938, Removed code for distributed installations
--  121204  Maaylk  PEPA-183, Removed global variable
--  131113  Umdolk  PBFI-2035, Refactoring.
--  140625  Bmekse  PRFI-493 Changes for new interface

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE finlib_number_list IS TABLE OF NUMBER INDEX BY VARCHAR2(30);

TYPE bind_record IS RECORD (bind_name     VARCHAR2(100),
                            data_type     VARCHAR2(10),
                            bind_num      NUMBER,
                            bind_str      VARCHAR2(4000),
                            bind_date_    DATE);
TYPE bind_table IS TABLE OF bind_record INDEX BY BINARY_INTEGER;


-- Constants used by Aurena clients. 
-- Used when creating where statements that is sent to a pages that used pipelined functions that uses the sent
-- where statement, which is then parsed and using binds
--single_quote_        CONSTANT VARCHAR2(5) := ' '||chr(39)||' ';
single_quote_        CONSTANT VARCHAR2(5) := chr(39);
sql_eq_              CONSTANT VARCHAR2(5) := ' = ';
odata_eq_            CONSTANT VARCHAR2(5) := ' eq ';  -- equal
odata_ne_            CONSTANT VARCHAR2(5) := ' ne ';  -- not equal
odata_le_            CONSTANT VARCHAR2(5) := ' le ';  -- less than equal
odata_ge_            CONSTANT VARCHAR2(5) := ' ge ';  -- greater than equal
and_                 CONSTANT VARCHAR2(5) := ' and ';
or_                  CONSTANT VARCHAR2(5) := ' or ';
left_par_            CONSTANT VARCHAR2(5) := ' ( ';
right_par_           CONSTANT VARCHAR2(5) := ' ) ';
space_repl_char_     CONSTANT VARCHAR2(5) := chr(28);
space_char_          CONSTANT VARCHAR2(5) := ' ';
null_str_            CONSTANT VARCHAR2(6) := ' null ';

-- constant used when attribute is grouped but has no data, used in the join in drill down
temp_is_null_str_    CONSTANT VARCHAR2(20) := ' #IS NULL# '; 

-- constant used, set in drill down_summary row, when an attribute is part of group statement
temp_item_grouped_   CONSTANT VARCHAR2(20) := ' #ITEM_GROUPED# '; 
-- constant used, set in drill down_summary row, when an number attribute is part of group statement
temp_item_grouped_num_  CONSTANT NUMBER := -99.12345670000001; 

-------------------- PRIVATE DECLARATIONS -----------------------------------

selection_sep_             CONSTANT VARCHAR2(1) := ';';
-- Json separator is actually a comma ',' but considering that one a value can have a comma the separator is
-- set to '","' since different items in json strings starts and ends with '"' character
-- Json example string '["COMPANY=10^INVOICE_ID=55^","COMPANY=20^INVOICE_ID=66^"]'
json_record_sep_           CONSTANT VARCHAR2(3) := '","';
stringify_std_record_sep_  CONSTANT VARCHAR2(1) := Client_SYS.record_separator_;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
FUNCTION Get_Next_From_String___ (   
   ptr_           IN OUT NUMBER,
   sub_string_    IN OUT VARCHAR2,
   input_string_  IN     VARCHAR2,   
   string_sep_    IN     VARCHAR2,
   list_type_     IN     VARCHAR2 DEFAULT 'SIMPLE') RETURN BOOLEAN
IS
   field_sep_index_  NUMBER := 0;   
   from_             NUMBER;   
   return_value_     BOOLEAN := FALSE;         
   sep_length_       NUMBER := LENGTH(string_sep_);
   last_sep_         NUMBER;
   str_length_       NUMBER;   
   end_str_length_   NUMBER;         
BEGIN
   -- different lists has different number of start and end characters
   -- Json lists starts with '["' so therefore from_ needs to start a character 3 instead of 1 for simple list types and ends 
   -- with 2 characters '"]' so end_str_length is set to 2
   -- Stringify lists ends with a CHR(30) so end_str_length is set to 1
   CASE list_type_
   WHEN 'JSON' THEN
      from_ := NVL(ptr_, 3);      
      end_str_length_ := 2;
   WHEN 'STRINGIFY' THEN
      from_ := NVL(ptr_, 1);            
      end_str_length_ := 1;
   ELSE
      from_ := NVL(ptr_, 1);      
      end_str_length_ := 0;
   END CASE;      
   
   IF (from_ = 0) THEN
      RETURN FALSE;
   END IF;
   field_sep_index_ := INSTR(input_string_, string_sep_, from_);   
   IF (field_sep_index_ > 0) THEN      
      sub_string_ := SUBSTR(input_string_, from_, field_sep_index_ - from_);
      ptr_           := field_sep_index_ + sep_length_;      
      return_value_  := TRUE;
   ELSIF (field_sep_index_ = 0 AND from_ > 0) THEN
      -- This is for the last record      
      ptr_           := field_sep_index_;      
      str_length_    := LENGTH(input_string_);
      last_sep_      := INSTR(input_string_, string_sep_, -1);

      IF (from_ > str_length_) THEN
         RETURN FALSE;
      END IF;   
      sub_string_ := SUBSTR(input_string_, (last_sep_ + sep_length_), str_length_ - (last_sep_ + sep_length_ + end_str_length_) + 1);         

      return_value_  := TRUE;      
   END IF;
   RETURN return_value_;   
END Get_Next_From_String___;   

FUNCTION Get_Next_From_Sel_Attr___ (
   attr_       IN            VARCHAR2,
   ptr_        IN OUT NOCOPY NUMBER,
   sub_attr_   IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS   
BEGIN    
   IF (Get_Next_From_String___(ptr_, sub_attr_, attr_, selection_sep_)) THEN   
      Replace_Keyref_To_Attr_Sep___(sub_attr_);
      RETURN TRUE;
   ELSE
      sub_attr_ := NULL;
      RETURN FALSE;
   END IF;
END Get_Next_From_Sel_Attr___; 

-- Replace_Keyref_To_Attr_Sep___
--   method to replace keyref separators ('^' and '=') with attribute string separators (chr(30 and chr(31)))
PROCEDURE Replace_Keyref_To_Attr_Sep___ (
   input_string_     IN OUT VARCHAR2) 
IS   
BEGIN 
   input_string_ := Replace(input_string_, Client_SYS.text_separator_, Client_SYS.record_separator_);
   input_string_ := Replace(input_string_, '=', Client_SYS.field_separator_);         
END Replace_Keyref_To_Attr_Sep___;   


FUNCTION Unpack_Sel_To_Tbl_Attr___ (
   selection_        IN VARCHAR2) RETURN Utility_SYS.String_Table
IS    
   string_table_        Utility_SYS.String_Table := Unpack_String_To_Tbl___(selection_, selection_sep_);
BEGIN      
   FOR i_ IN 1..string_table_.COUNT LOOP
      Replace_Keyref_To_Attr_Sep___(string_table_(i_));
   END LOOP;
   RETURN string_table_;
END Unpack_Sel_To_Tbl_Attr___;


FUNCTION Unpack_String_To_Tbl___ (
   input_string_        IN VARCHAR2,
   string_separator_    IN VARCHAR2) RETURN Utility_SYS.String_Table
IS 
   string_table_        Utility_SYS.String_Table;
   cnt_                 NUMBER;
BEGIN   
   Utility_SYS.Tokenize(input_string_, string_separator_, string_table_, cnt_);
   RETURN string_table_;
END Unpack_String_To_Tbl___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Exist_Package_Procedure (
   rcode_        IN OUT VARCHAR2,
   package_name_ IN     VARCHAR2 ) IS

   CURSOR exist_package IS
      SELECT 'TRUE'
      FROM   all_objects
      WHERE  object_name = package_name_
      AND    object_type = 'PACKAGE';

BEGIN

   OPEN exist_package;
   FETCH exist_package INTO rcode_;
   IF ( exist_package%NOTFOUND ) THEN
      -- Package is not installed and granted to product role.
      rcode_ := 'FALSE';
   END IF;
   CLOSE exist_package;
END Exist_Package_Procedure;


@UncheckedAccess
PROCEDURE Check_Module (
   module_  OUT VARCHAR2 ) IS
BEGIN

   $IF Component_Genled_SYS.INSTALLED $THEN
      module_ := 'GENLED';
   $ELSE
      module_ := 'ACCRUL';
   $END
END Check_Module;


@UncheckedAccess
FUNCTION Fin_Length(
    len_str_   IN    VARCHAR2) RETURN NUMBER
IS
  n_       NUMBER;
BEGIN
  n_ := LENGTH(len_str_); 
  IF (n_ = 0) THEN
    RETURN NULL;
  ELSE
    RETURN n_;
  END IF;
END Fin_Length;



@UncheckedAccess
FUNCTION Is_Valid_Number(
    string_   IN    VARCHAR2) RETURN VARCHAR2
IS

   n_count_     NUMBER:=1;
BEGIN
   WHILE (n_count_ <= LENGTH(string_)) LOOP
      IF (SUBSTR(string_,n_count_,1) NOT IN ('1','2','3','4','5','6','7','8','9','0')) THEN
         RETURN 'FALSE';
      END IF;
      n_count_ := n_count_ +1;
   END LOOP;
   RETURN 'TRUE';
END Is_Valid_Number;



@UncheckedAccess
FUNCTION Get_Session_Id RETURN NUMBER
IS
   session_id_  NUMBER:=NULL;  
   errnum_      NUMBER:=NULL;
BEGIN
   BEGIN
     SELECT USERENV_SESSION_SEQ.CURRVAL INTO session_id_ FROM dual;
   EXCEPTION
      WHEN OTHERS THEN
        errnum_  := SQLCODE;
   END;
   IF (errnum_ = -8002) THEN
       SELECT USERENV_SESSION_SEQ.NEXTVAL INTO session_id_ FROM dual;
   END IF;
   RETURN session_id_;
END Get_Session_Id;



FUNCTION Set_Params_For_Scheduled_Proc (
  params_ IN VARCHAR2 ) RETURN VARCHAR2
IS
  sub_msg_ VARCHAR2(32000) := Message_SYS.Construct('');
  msg_     VARCHAR2(32000) := Message_SYS.Construct('');
  ptr_     NUMBER := NULL;
  name_    VARCHAR2(30);
  value_   VARCHAR2(2000);
BEGIN
	IF Message_SYS.Is_Message(params_) THEN
		-- params_ is a Message
		sub_msg_ := params_;    
	ELSE
		-- params_ is an Attribute String  
		WHILE (Client_SYS.Get_Next_From_Attr(params_, ptr_, name_, value_)) LOOP
			Message_SYS.Add_Attribute(sub_msg_, name_, value_);
		END LOOP;
	END IF;   
	Message_SYS.Add_Attribute(msg_, 'MANDATORY', sub_msg_);
	RETURN(msg_);
END Set_Params_For_Scheduled_Proc;



-- Convert_Key_Pair_Msg_To_Array
--   Function that takes a message with key value pairs (NAME and VALUE) into 
--   an associative array indexed by the values in NAME
--   NAME is a VARCHAR2 with maximum length of 30 and VALUE is a NUMBER.
--
--   name(i)   value(i)
--   --------------------
--   Planned   3
--   Realeased 3
--   Invoiced  2 etc...
--
@UncheckedAccess
FUNCTION Convert_Key_Pair_Msg_To_Array (
   msg_    IN VARCHAR2 ) RETURN finlib_number_list
IS
   name_                Message_SYS.Name_Table;
   value_               Message_SYS.Line_Table;   
   count_               NUMBER;
   finlib_number_list_  finlib_number_list;
BEGIN
   Message_SYS.Get_Attributes(msg_, count_, name_, value_);
   FOR i_ IN 1..count_ LOOP
      finlib_number_list_(name_(i_)) := value_(i_);      
   END LOOP;
   RETURN finlib_number_list_;
END Convert_Key_Pair_Msg_To_Array;



-- Get_Value_From_Array
--   Function that returns the value (a NUMBER) from the key-value pair list finlib_number_list
--   based on the index string (the name_ parameter)
--   If the index is not found NULL will be returned
@UncheckedAccess
FUNCTION Get_Value_From_Array (
   list_    IN finlib_number_list,
   name_    IN VARCHAR2 ) RETURN NUMBER
IS
BEGIN
   IF list_.EXISTS(name_) THEN
      RETURN list_(name_);      
   ELSE
      RETURN TO_NUMBER(NULL);       
   END IF;  
END Get_Value_From_Array;


-- Get_Next_From_Selection_Attr
--   Returns next value, converted to an attribute string, from a selection string of keyrefs (each keyref is separated by ';') 
--   Example input 'COMPANY=10^INVOICE_ID=55^;COMPANY=20^INVOICE_ID=66^' 
--   returns 'COMPANY<field_separator_>10<record_separator_>INVOICE_ID<field_separator_>55<record_separator_>' the first time 
--   when used in a loop using the function
--   ptr_ must be passed as NULL in the first call when used in a WHILE LOOP
--   attr_ is the returned attribute string extracted from the list of keyrefs
FUNCTION Get_Next_From_Selection_Attr (
   selection_     IN            VARCHAR2,
   ptr_           IN OUT NOCOPY NUMBER,
   attr_          IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS   
BEGIN
   RETURN Get_Next_From_Sel_Attr___(selection_, ptr_, attr_);
END Get_Next_From_Selection_Attr;

-- Get_Next_From_Selection_Keyref
--   Returns next value from a selection string of keyrefs (each keyref is separated by ';')
--   Example input 'COMPANY=10^INVOICE_ID=55^;COMPANY=20^INVOICE_ID=66^' returns 'COMPANY=10^INVOICE_ID=55^' the first time 
--   when used in a loop using the function   
--   ptr_ must be passed as NULL in the first call when used in a WHILE LOOP
--   keyref_ is the returned keyref extracted from the list
FUNCTION Get_Next_From_Selection_Keyref (
   selection_     IN            VARCHAR2,
   ptr_           IN OUT NOCOPY NUMBER,
   keyref_        IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS   
BEGIN
   RETURN Get_Next_From_String___(ptr_, keyref_, selection_, selection_sep_);      
END Get_Next_From_Selection_Keyref;   

-- Get_Next_From_Json_Keyref
--   Returns next value from a Json string of keyrefs (each keyref is separated by ',')
--   Example input '["COMPANY=10^INVOICE_ID=55^","COMPANY=20^INVOICE_ID=66^"]' returns 'COMPANY=10^INVOICE_ID=55^' the first time 
--   when used in a loop using the function  
--   ptr_ must be passed as NULL in the first call when used in a WHILE LOOP
--   keyref_ is the returned keyref extracted from the list
FUNCTION Get_Next_From_Json_Keyref (
   json_list_     IN            VARCHAR2,
   ptr_           IN OUT NOCOPY NUMBER,
   keyref_        IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS   
BEGIN   
   RETURN Get_Next_From_String___(ptr_, keyref_, json_list_, json_record_sep_, 'JSON');   
END Get_Next_From_Json_Keyref;   

-- Get_Next_From_Stringify_Keyref
--   Returns next value from a standard Stringify string of keyrefs (each keyref is separated by CHR(30), Client_SYS.record_separator_)
--   Example input 'COMPANY=10^INVOICE_ID=55^'||CHR(30)||'COMPANY=20^INVOICE_ID=66^' returns 'COMPANY=10^INVOICE_ID=55^' the first time 
--   when used in a loop using the function  
--   ptr_ must be passed as NULL in the first call when used in a WHILE LOOP
--   keyref_ is the returned keyref extracted from the list
FUNCTION Get_Next_From_Stringify_Keyref (
   stringify_list_   IN            VARCHAR2,
   ptr_              IN OUT NOCOPY NUMBER,
   keyref_           IN OUT NOCOPY VARCHAR2) RETURN BOOLEAN
IS   
BEGIN
   RETURN Get_Next_From_String___(ptr_, keyref_, stringify_list_, stringify_std_record_sep_, 'STRINGIFY');   
END Get_Next_From_Stringify_Keyref;   

-- Unpack_Selection_To_Tbl_Attr
--   Returns a Utility_SYS.String_Table with an attribute string in each record (e.g. 'COMPANY<field_separator_>X<record_separator_>VOUCHER_NO<field_separator_>39<record_separator_>')
FUNCTION Unpack_Selection_To_Tbl_Attr (
   selection_        IN VARCHAR2) RETURN Utility_SYS.String_Table
IS 
BEGIN   
   RETURN Unpack_Sel_To_Tbl_Attr___(selection_);
END Unpack_Selection_To_Tbl_Attr;

-- Unpack_Selection_To_Tbl_Keyref
--   Returns a Utility_SYS.String_Table with a keyref string in each record (e.g. 'COMPANY=X^VOUCHER_NO=39^')
FUNCTION Unpack_Selection_To_Tbl_Keyref (
   selection_        IN VARCHAR2) RETURN Utility_SYS.String_Table
IS 
BEGIN   
   RETURN Unpack_String_To_Tbl___(selection_, selection_sep_);
END Unpack_Selection_To_Tbl_Keyref;

-- Unpack_Json_To_Tbl_Keyref
--   Returns a Utility_SYS.String_Table with a keyref string in each record (e.g. 'COMPANY=10^INVOICE_ID=55^') from a Json list 
--   of keyrefs
--   Example input '["COMPANY=10^INVOICE_ID=55^","COMPANY=20^INVOICE_ID=66^"]' returns 'COMPANY=10^INVOICE_ID=55^' as the first  
--   record in the table 
--   The return table is indexed starting from 1.
FUNCTION Unpack_Json_To_Tbl_Keyref (
   json_list_        IN VARCHAR2) RETURN Utility_SYS.String_Table
IS 
   string_table_           Utility_SYS.String_Table;
   array_                  json_array_t;
BEGIN   
   array_ := json_array_t.parse(json_list_);     
   FOR indx IN 0..array_.get_size - 1 LOOP
      string_table_(indx + 1) := array_.get_String(indx);
   END LOOP;   
   RETURN string_table_;   
END Unpack_Json_To_Tbl_Keyref;

-- Unpack_Stringify_To_Tbl_Keyref
--   Returns a Utility_SYS.String_Table with a keyref string in each record (e.g. 'COMPANY=10^INVOICE_ID=55^') from a Stringify list 
--   of keyrefs (each keyref is separated by CHR(30) which is client_sys.record_separator)
--   Example input 'COMPANY=10^INVOICE_ID=55^'||CHR(30)||'COMPANY=20^INVOICE_ID=66^'||CHR(30) returns 'COMPANY=10^INVOICE_ID=55^' as the first  
--   record in the table 
FUNCTION Unpack_Stringify_To_Tbl_Keyref (
   stringify_list_        IN VARCHAR2) RETURN Utility_SYS.String_Table
IS 
BEGIN   
   RETURN Unpack_String_To_Tbl___(stringify_list_, stringify_std_record_sep_);
END Unpack_Stringify_To_Tbl_Keyref;


-- Add_Stringify_Keyref_To_Attr
--   Method that adds the value for key_ref attribute "name_" found in the key_ref_ string when group_field_ is true. 
--   This is a helper method for a number of analytic projection/pages in IFS Financials when performing drill down.
--   The key_ref_ is based on a string created by the client method Stringify. Older version of the Stringify method
--   added the string 'null', instead of NULL, for attributes, that did not have a value, that was passed to the Stringify method 
--   so therefore this method if backward compatible with that for the time being.
--   Note: When the value for the attribute name_ is NULL/'null' and group_field_ is true then the constant finance_lib_api.temp_is_null_str_ 
--   is added to the attribute string. This is a special construction for the drill down function for these projections/pages.
PROCEDURE Add_Stringify_Keyref_To_Attr (
   attr_          IN OUT VARCHAR2, 
   group_field_   IN BOOLEAN,
   name_          IN VARCHAR2,
   key_ref_       IN VARCHAR2)
IS
   value_         VARCHAR2(4000);   
BEGIN   
   IF (group_field_) THEN
      value_ := Client_SYS.Get_Key_Reference_Value(key_ref_, name_);
      IF (value_ IS NULL OR value_ = 'null') THEN
         Client_SYS.Add_To_Attr(name_, temp_is_null_str_, attr_);         
      ELSE         
         Client_SYS.Add_To_Attr(name_, value_, attr_);
      END IF;
   END IF; 
END Add_Stringify_Keyref_To_Attr;

   
PROCEDURE Is_View_Available (
   view_name_ IN VARCHAR2 )
IS
   view_ VARCHAR2(200);
   loc_  NUMBER;
BEGIN
   IF (view_name_ IS NOT NULL) THEN
      loc_ := INSTR(view_name_, '(');
      IF (loc_ > 0) THEN
         view_ := SUBSTR(view_name_, 1, loc_ - 1);
      ELSE
         view_ := view_name_;
      END IF;
      IF NOT Database_Sys.View_Active(view_) THEN
         Error_SYS.Record_General(lu_name_, 'VIEWNOTACTIVE: View :P1 is not available in an active module.', view_);
      END IF;
   END IF;
END Is_View_Available;

PROCEDURE Is_Method_Available (
   method_name_ IN VARCHAR2 )
IS
   package_ VARCHAR2(200);
   method_  VARCHAR2(200);
   loc_     NUMBER;
   loc2_    NUMBER;
BEGIN
   IF (method_name_ IS NOT NULL) THEN
      loc_  := INSTR(method_name_, '.');
      IF (loc_ > 0) THEN
         package_ := SUBSTR(method_name_, 1, loc_ - 1);  
         loc2_ := INSTR(method_name_, '(');
         IF (loc2_ > 0) THEN
            method_ := SUBSTR(method_name_, loc_ + 1, loc2_ - loc_ - 1);
         ELSE
            method_ := SUBSTR(method_name_, loc_ + 1);
         END IF;
      END IF;

      IF NOT Database_Sys.Method_Active(package_, method_) THEN
         Error_SYS.Record_General(lu_name_, 'METHODINACTIVE: The Method is not available in an active module. :P1, :P2', package_, method_);
      END IF;
   END IF;
END Is_Method_Available;

PROCEDURE Is_Package_Available (
   package_name_ IN VARCHAR2 )
IS
BEGIN
   IF (package_name_ IS NOT NULL) THEN
      IF NOT Dictionary_SYS.Package_Is_Active(package_name_) THEN
         Error_SYS.Record_General(lu_name_, 'PKGINACTIVE: The Package is not available in an active module. :P1', package_name_);
      END IF;
   END IF;
END Is_Package_Available;


FUNCTION Get_Next_Item_Picker_Value(
   item_list_ IN VARCHAR2,
   ptr_ IN OUT NUMBER,
   column_ IN VARCHAR2,
   value_ IN OUT VARCHAR2,
   reached_end_ IN OUT BOOLEAN) RETURN BOOLEAN
IS
   location_ NUMBER;
   sub_selection_ VARCHAR2(32000);
BEGIN
   IF reached_end_  THEN 
      RETURN FALSE;
   ELSE 
      location_ := INSTR(item_list_, ',', ptr_, 1);
      
      -- last item in list
      IF location_ <= 0 THEN 
         location_ := length(item_list_) - ptr_;
         sub_selection_ := SUBSTR(item_list_, ptr_, location_);
         reached_end_ := TRUE;
      ELSE
         sub_selection_ := SUBSTR(item_list_, ptr_, location_);
         ptr_:= location_ + 1;
      END IF;
      
      value_ := Client_SYS.Get_Key_Reference_Value(sub_selection_, column_);
      RETURN TRUE;
   END IF;
END Get_Next_Item_Picker_Value;

-- Get_Acc_Curr_Translated_Text
--   Function that returns the text "Accounting Currency" translated into the current session language
FUNCTION Get_Acc_Curr_Translated_Text RETURN VARCHAR2
IS
   translated_text_  VARCHAR2(100) := Language_SYS.Translate_Constant(lu_name_, 'ACCCURR: Accounting Currency');
BEGIN   
   RETURN translated_text_;
END Get_Acc_Curr_Translated_Text;   

-- Get_Par_Curr_Translated_Text
--   Function that returns the text "Parallel Currency" translated into the current session language
FUNCTION Get_Par_Curr_Translated_Text RETURN VARCHAR2
IS
   translated_text_  VARCHAR2(100) := Language_SYS.Translate_Constant(lu_name_, 'PARRCURR: Parallel Currency');
BEGIN   
   RETURN translated_text_;
END Get_Par_Curr_Translated_Text;

-- Is_Number
--   Function that returns true if the str_value can be converted to a number otherwise it returns false
FUNCTION Is_Number (
   str_value_     IN VARCHAR2) RETURN BOOLEAN
IS
   num_              NUMBER;
   invalid_number    EXCEPTION;
   PRAGMA EXCEPTION_INIT(invalid_number, -06502);     
BEGIN
   num_ := To_Number(str_value_);
   RETURN TRUE;
EXCEPTION 
   WHEN invalid_number THEN
      RETURN FALSE;
END Is_Number; 