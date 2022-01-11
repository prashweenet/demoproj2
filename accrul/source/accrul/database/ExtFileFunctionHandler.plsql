-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileFunctionHandler
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  051104  Jeguse  Created
--  060524  Jeguse  Bug 58274, Corrected
--  070123  Gadalk  LCS Merge 60420
--  070430  JARALK  LCS Merge 64537.
--  070620  PARALK  LCS Merge 65954 corrected. Called proper method for upper and lower case.
--  080115  Jeguse  Bug 70590, Corrected
--  080818  Jeguse  Bug 76423, Corrected
--  080925  Jeguse  Bug 77126, Corrected
--  100322  Jeguse  EAFH-2475 
--  120126  NiFelk  SFI-1264, Merged LCS 99807.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  130807  AjPelk  Bug 105388, Corrected.
--  130819  Clstlk  Bug 111221, Corrected functions without RETURN statement in all code paths
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

fc_value_error                  EXCEPTION;
fc_numeric_error                EXCEPTION;
fc_date_error                   EXCEPTION;
fc_colref_error                 EXCEPTION;
fc_destcolref_error             EXCEPTION;
fc_detref_error                 EXCEPTION;
fc_parref_error                 EXCEPTION;
fc_illegaldate_error            EXCEPTION;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Find_Destination_Column___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   column_id_    IN Ext_File_Type_Rec_Column_Tab.column_id%TYPE )RETURN VARCHAR2
IS
   destination_column_ Ext_File_Type_Rec_Column_Tab.destination_column%TYPE;
BEGIN
   FOR i_ IN 1.. templ_det_rec_.max_ft LOOP
      IF (column_id_ = templ_det_rec_.ft_list(i_).column_id AND
          templ_det_rec_.act_record_type = templ_det_rec_.ft_list(i_).record_type_id) THEN
         destination_column_ := templ_det_rec_.ft_list(i_).destination_column;
         EXIT;
      END IF;
   END LOOP;
   RETURN destination_column_;     
END Find_Destination_Column___;


FUNCTION Find_Destination_Column___( 
   templ_det_rec_   IN OUT External_File_Utility_API.ft_m_det_rec,
   column_id_      IN Ext_File_Type_Rec_Column_Tab.column_id%TYPE,
   record_type_id_ IN Ext_File_Type_Rec_Column_Tab.column_id%TYPE )RETURN VARCHAR2
IS
   destination_column_ Ext_File_Type_Rec_Column_Tab.destination_column%TYPE;
BEGIN
   FOR i_ IN 1.. templ_det_rec_.max_ft LOOP
      IF (column_id_ = templ_det_rec_.ft_list(i_).column_id AND
          record_type_id_ = templ_det_rec_.ft_list(i_).record_type_id) THEN
         destination_column_ := templ_det_rec_.ft_list(i_).destination_column;
         EXIT;
      END IF;
   END LOOP;
   RETURN destination_column_;     
END Find_Destination_Column___;


FUNCTION Get_Function_Arg___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec,
   i_arg_        IN PLS_INTEGER ) RETURN VARCHAR2
IS
   crec_            External_File_Utility_API.Command_Rec;
   result_          VARCHAR2(4000);
   stmt_            VARCHAR2(2000);
BEGIN
   IF ( Ext_File_Argument_Handler_API.Arg_Ref_Ok__( command_rec_, i_arg_ )) THEN
      IF (Ext_File_Argument_Handler_API.Arg_Is_Function__( command_rec_, i_arg_ )) THEN
         crec_   := Ext_File_Argument_Handler_API.Build_Rec_For_Arg__(command_rec_, i_arg_);
         result_ := (Execute_Function_Step___(templ_det_rec_, crec_));
         IF (result_ != CHR(39)) THEN
            IF (SUBSTR(command_rec_.Main_Function,1,10) NOT IN ('DETAIL_REF','COLUMN_REF') AND 
                SUBSTR(command_rec_.Main_Function,1,11) NOT IN ('CONCATENATE')) THEN
               result_ := REPLACE(result_,CHR(39));
            END IF;
         END IF;
         result_ := REPLACE(REPLACE(result_,CHR(10),' '),CHR(13),' ');
      ELSE
         -- get_user_str__ should handle true_string
         result_ := ( Ext_File_Argument_Handler_API.Get_Use_Str__(command_rec_, i_arg_));
         result_ := REPLACE(result_,CHR(39));
         IF (result_ = 'NULL') THEN
            RETURN NULL;
         END IF;
         result_ := REPLACE(REPLACE(result_,CHR(10),' '),CHR(13),' ');
         IF (SUBSTR(result_,1,4) = 'CHR(') THEN
            BEGIN
               stmt_ := 'BEGIN :result_ := ' || result_ || '; ' ||
                        'END;' ;
               @ApproveDynamicStatement(2008-01-15,jeguse)
               EXECUTE IMMEDIATE stmt_ USING OUT result_;
            EXCEPTION
               WHEN OTHERS THEN 
                  Trace_SYS.Message('***** Exception asci_attr_');
            END;
         END IF;
      END IF;
   ELSE
      RETURN NULL;
   END IF;
   RETURN result_;
END Get_Function_Arg___;


FUNCTION Get_Function_Arg_Num___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec,
   i_arg_        IN PLS_INTEGER ) RETURN NUMBER
IS
   n_               NUMBER;
BEGIN
   n_ := TO_NUMBER(Get_Function_Arg___( templ_det_rec_, command_rec_, i_arg_ ));
   RETURN n_;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END Get_Function_Arg_Num___;


FUNCTION Cf_Set_Default_Value___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec )RETURN VARCHAR2
IS
   file_value_      VARCHAR2(4000);
   file_valued_     DATE;
   file_valuen_     NUMBER;
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(4000);
BEGIN
   IF (templ_det_rec_.act_data_type = '3') THEN
      file_valued_ := Ext_File_Column_Util_API.Return_D_Value (templ_det_rec_.act_dest_column, templ_det_rec_.transrec);
      arg1_     := Get_Function_Arg___(templ_det_rec_, command_rec_, 1);
      arg2_     := Get_Function_Arg___(templ_det_rec_, command_rec_, 2);
      IF (file_valued_ IS NULL OR arg2_ = 'TRUE') THEN
         BEGIN
            file_valued_ := TO_DATE(arg1_,templ_det_rec_.act_date_format);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE fc_date_error;
         END;
      END IF;
      result_ := TO_CHAR(file_valued_,templ_det_rec_.act_date_format);
   --
   ELSIF (templ_det_rec_.act_data_type = '2') THEN
      file_valuen_ := Ext_File_Column_Util_API.Return_N_Value (templ_det_rec_.act_dest_column, templ_det_rec_.transrec);
      arg1_ := Get_Function_Arg___(templ_det_rec_, command_rec_, 1);
      arg2_ := Get_Function_Arg___(templ_det_rec_, command_rec_, 2);
      IF (file_valuen_ IS NULL OR arg2_ = 'TRUE') THEN
         BEGIN
            file_valuen_ := TO_NUMBER(arg1_);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE fc_numeric_error;
         END;
      END IF;
      result_ := TO_CHAR(file_valuen_);
   --
   ELSE
      file_value_ := Ext_File_Column_Util_API.Return_C_Value (templ_det_rec_.act_dest_column, templ_det_rec_.transrec);
      arg1_ := Get_Function_Arg___(templ_det_rec_, command_rec_, 1);
      arg2_ := Get_Function_Arg___(templ_det_rec_, command_rec_, 2);
      IF (file_value_ IS NULL OR arg2_ = 'TRUE') THEN
         result_ := arg1_;
      ELSE
         result_ := file_value_;
      END IF;
   END IF;
   --
   RETURN result_;
END Cf_Set_Default_Value___;


FUNCTION Cf_Line_Ref___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec) RETURN VARCHAR2
IS
   result_          VARCHAR2(4000);
BEGIN
   result_ :=  templ_det_rec_.transrec.file_line;
   RETURN result_;
END Cf_Line_Ref___;


FUNCTION Cf_Detail_Ref___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   act_index_       NUMBER         := templ_det_rec_.act_index;
   cf_from_         NUMBER         := templ_det_rec_.ft_list(act_index_).funct_detail_from;
   cf_to_           NUMBER         := templ_det_rec_.ft_list(act_index_).funct_detail_to;
   arg1_            NUMBER;
   result_          VARCHAR2(2000);
   found_           BOOLEAN        := FALSE;
BEGIN
   arg1_ := Get_Function_Arg_Num___(templ_det_rec_, command_rec_, 1);
   IF (arg1_ IS NULL) THEN
      result_ := NULL;
   ELSE
      FOR i IN cf_from_ .. cf_to_ LOOP
         IF (templ_det_rec_.cf_list(i).function_no = arg1_) THEN
            result_ := templ_det_rec_.cf_list(i).step_result;
            found_ := TRUE;
            EXIT;
         END IF;
      END LOOP;
      IF (NOT found_) THEN
         RAISE fc_detref_error;
      END IF;
   END IF;
   RETURN result_;
END Cf_Detail_Ref___;


FUNCTION Cf_Column_Ref___( 
   templ_det_rec_    IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_      IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_               VARCHAR2(2000);
   destination_column_ Ext_File_Type_Rec_Column_Tab.destination_column%TYPE;
   result_             VARCHAR2(2000);
   resultd_            DATE;
   arg2_               VARCHAR2(2000);
   transrec_           Ext_File_Trans_Tab%ROWTYPE;
   CURSOR gettransrec IS
      SELECT *
      FROM  ext_file_trans_tab
      WHERE load_file_id   = templ_det_rec_.transrec.load_file_id
      AND   row_no         < templ_det_rec_.transrec.row_no
      AND   record_type_id = arg2_
      ORDER BY row_no DESC;
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NULL) THEN
      IF (arg1_ IS NULL) THEN
         destination_column_ := templ_det_rec_.act_dest_column;
      ELSE
         destination_column_ := Find_Destination_Column___ (templ_det_rec_, arg1_);
      END IF;
      IF (destination_column_ IS NULL) THEN
         RAISE fc_colref_error;
      END IF;
      IF (SUBSTR(destination_column_,1,1) = 'D') THEN
         resultd_ := Ext_File_Column_Util_API.Return_D_Value (destination_column_, templ_det_rec_.transrec);
         result_ := TO_CHAR(resultd_,templ_det_rec_.act_date_format);
      ELSE
         result_ := Ext_File_Column_Util_API.Return_C_Value (destination_column_, templ_det_rec_.transrec);
      END IF;
   ELSE
      OPEN  gettransrec;
      FETCH gettransrec INTO transrec_;
      CLOSE gettransrec;
      destination_column_ := Find_Destination_Column___ (templ_det_rec_, arg1_, arg2_);
      IF (destination_column_ IS NULL) THEN
         RAISE fc_colref_error;
      END IF;
      IF (SUBSTR(destination_column_,1,1) = 'D') THEN
         resultd_ := Ext_File_Column_Util_API.Return_D_Value (destination_column_, transrec_);
         result_ := TO_CHAR(resultd_,templ_det_rec_.act_date_format);
      ELSE
         result_ := Ext_File_Column_Util_API.Return_C_Value (destination_column_, transrec_);
      END IF;
   END IF;
   RETURN result_;
END Cf_Column_Ref___;


FUNCTION Cf_Destcol_Ref___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(2000);
   result_          VARCHAR2(2000);
   resultd_         DATE;
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   IF (arg1_ IS NULL) THEN
      RAISE fc_destcolref_error;
   END IF;
   IF (SUBSTR(arg1_,1,1) = 'D') THEN
      resultd_ := Ext_File_Column_Util_API.Return_D_Value (arg1_, templ_det_rec_.transrec);
      result_ := TO_CHAR(resultd_,templ_det_rec_.act_date_format);
   ELSE
      result_ := Ext_File_Column_Util_API.Return_C_Value (arg1_, templ_det_rec_.transrec);
   END IF;
   RETURN result_;
END Cf_Destcol_Ref___;


FUNCTION Cf_Parameter_Ref___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(2000);
   result_          VARCHAR2(2000);
   tmp_             VARCHAR2(2000) := NULL;
   dummy_           VARCHAR2(10)   := '<DUMMY>';
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   tmp_    := Message_SYS.Find_Attribute (templ_det_rec_.parameter_string, arg1_, dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      result_ := tmp_;
   ELSE
      RAISE fc_parref_error;
   END IF;
   RETURN result_;
END Cf_Parameter_Ref___;


FUNCTION Cf_Parameter_Put___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(2000);
   arg2_            VARCHAR2(2000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   Ext_File_Message_API.Check_And_Replace_Attribute_ (templ_det_rec_.parameter_string,
                                                      arg1_,  -- Name
                                                      arg2_,  -- Value
                                                      'TRUE');
   result_ := arg2_;
   RETURN result_;
END Cf_Parameter_Put___;


FUNCTION Cf_Find_String___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            NUMBER := NULL;
   arg4_            NUMBER := NULL;
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_ := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
   arg4_ := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 4);
   arg2_ := REPLACE (arg2_,CHR(39));
   IF (arg2_ IS NULL) THEN
      arg2_ := ' ';
   END IF;
   IF (arg4_ IS NOT NULL) THEN
      result_ := ( INSTR(arg1_, arg2_, arg3_, arg4_ ));
   ELSIF (arg3_ IS NOT NULL) THEN
      result_ := ( INSTR(arg1_, arg2_, arg3_));
   ELSE
      result_ := ( INSTR(arg1_, arg2_ ));
   END IF;
   RETURN result_;
END Cf_Find_String___;


FUNCTION Cf_Sub_String___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            NUMBER := NULL;
   arg3_            NUMBER := NULL;
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
   arg3_ := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
   IF (arg3_ IS NOT NULL) THEN
      result_ := ( SUBSTR(arg1_, arg2_, arg3_));
   ELSE
      result_ := ( SUBSTR(arg1_, arg2_ ));
   END IF;
   RETURN result_;
END Cf_Sub_String___;


FUNCTION Cf_Left_Trim___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NOT NULL) THEN
      result_ := LTRIM(arg1_, arg2_ );
   ELSE
      result_ := LTRIM(arg1_);
   END IF;
   RETURN result_;
END Cf_Left_Trim___;


FUNCTION Cf_Right_Trim___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NOT NULL) THEN
      result_ := RTRIM(arg1_, arg2_ );
   ELSE
      result_ := RTRIM(arg1_);
   END IF;
   RETURN result_;
END Cf_Right_Trim___;


FUNCTION Cf_Left_Pad___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            NUMBER := NULL;
   arg3_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
   arg3_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   IF (arg3_ IS NULL) THEN
      result_ := LPAD(arg1_, arg2_ );
   ELSE
      result_ := LPAD(arg1_, arg2_, arg3_ );
   END IF;
   RETURN result_;
END Cf_Left_Pad___;


FUNCTION Cf_Right_Pad___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg3_            NUMBER := NULL;
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
   arg3_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   IF (arg3_ IS NULL) THEN
      result_ := RPAD(arg1_, arg2_ );
   ELSE
      result_ := RPAD(arg1_, arg2_, arg3_ );
   END IF;
   RETURN result_;
END Cf_Right_Pad___;


FUNCTION Cf_Length___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_ := LENGTH(arg1_);
   RETURN result_;
END Cf_Length___;


FUNCTION Cf_To_Upper_Case___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_ := UPPER(arg1_);
   RETURN result_;
END Cf_To_Upper_Case___;


FUNCTION Cf_To_Lower_Case___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_ := LOWER(arg1_);
   RETURN result_;
END Cf_To_Lower_Case___;


FUNCTION Cf_To_Char___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NULL) THEN
      result_ := TO_CHAR(arg1_);
   ELSE
      result_ := TO_CHAR(arg1_,arg2_);
   END IF;
   RETURN result_;
END Cf_To_Char___;


FUNCTION Cf_To_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NULL) THEN
      result_ := TO_NUMBER(arg1_);
   ELSE
      result_ := TO_NUMBER(arg1_,arg2_);
   END IF;
   RETURN result_;
END Cf_To_Number___;


FUNCTION Cf_Concatenate___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            VARCHAR2(4000);
   arg4_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   arg4_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 4); 
   result_ := arg1_ || arg2_;
   IF (arg3_ IS NOT NULL) THEN
      result_ := result_ || arg3_;
      IF (arg4_ IS NOT NULL) THEN
         result_ := result_ || arg4_;
      END IF;
   END IF;
   RETURN result_;
END Cf_Concatenate___;


FUNCTION Cf_Replace___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   result_ := REPLACE(arg1_,arg2_,arg3_);
   RETURN result_;
END Cf_Replace___;


FUNCTION Cf_Translate___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   result_ := TRANSLATE(arg1_,arg2_,arg3_);
   RETURN result_;
END Cf_Translate___;


FUNCTION Cf_Add___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1n_           NUMBER;
   arg2n_           NUMBER;
   arg3n_           NUMBER;
   result_          VARCHAR2(2000);
BEGIN
   arg1n_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 1);
   arg2n_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
   arg3n_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
   IF (arg3n_ IS NOT NULL) THEN
      result_  := TO_CHAR(NVL(arg1n_,arg3n_) + NVL(arg2n_,arg3n_));
   ELSE
      result_  := TO_CHAR(arg1n_ + arg2n_);
   END IF;
   RETURN result_;
EXCEPTION
   WHEN fc_illegaldate_error THEN
      RAISE;
   WHEN OTHERS THEN
      RAISE fc_numeric_error;
END Cf_Add___;


FUNCTION Cf_Subtract___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1n_           NUMBER;
   arg2n_           NUMBER;
   arg3n_           NUMBER;
   result_          VARCHAR2(2000);
BEGIN
   arg1n_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 1);
   arg2n_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
   arg3n_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
   IF (arg3n_ IS NOT NULL) THEN
      result_  := TO_CHAR(NVL(arg1n_,arg3n_) - NVL(arg2n_,arg3n_));
   ELSE
      result_  := TO_CHAR(arg1n_ - arg2n_);
   END IF;
   RETURN result_;
EXCEPTION
   WHEN fc_illegaldate_error THEN
      RAISE;
   WHEN OTHERS THEN
      RAISE fc_numeric_error;
END Cf_Subtract___;


FUNCTION Cf_Multiply___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            NUMBER;
   arg2_            NUMBER;
   arg3n_           NUMBER;
   result_          VARCHAR2(2000);
BEGIN
   IF (templ_det_rec_.act_data_type != '3') THEN
      arg1_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 1);
      arg2_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
      arg3n_  := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
      IF (arg3n_ IS NOT NULL) THEN
         result_ := TO_CHAR(NVL(arg1_,arg3n_) * NVL(arg2_,arg3n_));
      ELSE
         result_ := TO_CHAR(arg1_ * arg2_);
      END IF;
   ELSE
      RAISE fc_illegaldate_error;
   END IF;
   RETURN result_;
EXCEPTION
   WHEN fc_illegaldate_error THEN
      RAISE;
   WHEN OTHERS THEN
      RAISE fc_numeric_error;
END Cf_Multiply___;


FUNCTION Cf_Divide___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            NUMBER;
   arg2_            NUMBER;
   arg3n_           NUMBER;
   result_          VARCHAR2(2000);
BEGIN
   IF (templ_det_rec_.act_data_type != '3') THEN
      arg1_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 1);
      arg2_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 2);
      arg3n_  := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
      IF (arg3n_ IS NOT NULL) THEN
         result_ := TO_CHAR(NVL(arg1_,arg3n_) / NVL(arg2_,arg3n_));
      ELSE
         result_ := TO_CHAR(arg1_ / arg2_);
      END IF;
   ELSE
      RAISE fc_illegaldate_error;
   END IF;
   RETURN result_;
EXCEPTION
   WHEN fc_illegaldate_error THEN
      RAISE;
   WHEN OTHERS THEN
      RAISE fc_numeric_error;
END Cf_Divide___;


FUNCTION Cf_Change_Sign___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
  command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            NUMBER;
   result_          VARCHAR2(2000);
BEGIN
   IF (templ_det_rec_.act_data_type = '2') THEN
      arg1_   := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 1);
      result_ := TO_CHAR(arg1_ * -1);
   END IF;
   RETURN result_;
END Cf_Change_Sign___;


FUNCTION Cf_Is_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg1n_           NUMBER;
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg1n_  := TO_NUMBER(arg1_);
   result_ := '1';
   RETURN result_;
   EXCEPTION
      WHEN OTHERS THEN
         result_ := '0';            
         RETURN result_;
END Cf_Is_Number___;


FUNCTION Cf_If_Else___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            VARCHAR2(4000);
   arg4_            VARCHAR2(4000);
   arg5_            VARCHAR2(4000);
   arg6_            VARCHAR2(4000);
   arg7_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   arg4_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 4);
   arg5_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 5);
   arg6_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 6);
   arg7_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 7);
   IF (arg1_ = arg2_) THEN
      result_ := arg3_;
      IF (arg5_ = 'EXIT_TRUE') THEN
         templ_det_rec_.col_func_exit := 'TRUE';
      END IF;
   ELSE
      IF (arg5_ IS NULL OR arg5_ = 'EXIT_TRUE') THEN
         result_ := arg4_;
      ELSE
         IF (arg1_ = arg4_) THEN
            result_ := arg5_;
            IF (NVL(arg7_,' ') = 'EXIT_TRUE') THEN
               templ_det_rec_.col_func_exit := 'TRUE';
            END IF;
         ELSE
            result_ := arg6_;
         END IF;
      END IF;
   END IF;
   RETURN result_;
END Cf_If_Else___;


FUNCTION Cf_If_Else_Condition___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            VARCHAR2(4000);
   arg4_            VARCHAR2(4000);
   arg5_            VARCHAR2(4000);
   arg6_            VARCHAR2(4000);
   condition_       VARCHAR2(10);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 3);
   arg4_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 4);
   arg5_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 5);
   arg6_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 6);
   --Trace_SYS.Message ('arg1_ : '||arg1_||' arg2_ : '||arg2_||' arg3_ : '||arg3_||' arg4_ : '||arg4_||' arg5_ : '||arg5_);
   condition_ := arg2_;
   IF (condition_ = '<') THEN
      IF (arg1_ < arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = '<=') THEN
      IF (arg1_ <= arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = '=') THEN
      IF (arg1_ = arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = '!=') THEN
      IF (arg1_ != arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = '>') THEN
      IF (arg1_ > arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = '>=') THEN
      IF (arg1_ >= arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = 'LIKE') THEN
      IF (arg1_ LIKE arg3_) THEN
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;
         RETURN arg4_;
      END IF;
   ELSIF (condition_ = 'NOTLIKE') THEN
      IF (arg1_ NOT LIKE arg3_) THEN 
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF;  
      END IF; 
   ELSIF (condition_ = 'IS' AND arg3_ = 'NULL') THEN 
      IF (arg1_ IS NULL) THEN 
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF; 
         RETURN arg4_; 
      END IF; 
   ELSIF (condition_ = 'ISNOT' AND arg3_ = 'NULL') THEN 
      IF (arg1_ IS NULL) THEN 
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF; 
         RETURN arg4_;  
      END IF;
   ELSIF (condition_ = 'ISNOT' AND arg3_ IS NULL) THEN
      IF (arg1_ IS NULL) THEN 
         IF (NVL(arg6_,' ') = 'EXIT_TRUE') THEN
            templ_det_rec_.col_func_exit := 'TRUE';
         END IF; 
         RETURN arg4_;  
      END IF; 
   END IF;
   RETURN arg5_;
END Cf_If_Else_Condition___;


FUNCTION Cf_If_Empty___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg1_ IS NULL) THEN
      result_ := arg2_;
   ELSE
      result_ := arg1_;
   END IF;
   RETURN result_;
END Cf_If_Empty___;


FUNCTION Cf_Is_Empty___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   IF (arg1_ IS NULL) THEN
      result_ := 'TRUE';
   ELSE
      result_ := 'FALSE';
   END IF;
   RETURN result_;
END Cf_Is_Empty___;


FUNCTION Cf_Find_One_Of___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   arg3_            NUMBER;
   compare_to_      VARCHAR2(2000);
   compare_         VARCHAR2(2000);
   instra_          NUMBER;
   instr_           NUMBER         := 0;
   result_          VARCHAR2(2000);
BEGIN
   arg1_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   arg3_ := Get_Function_Arg_Num___(templ_det_rec_,command_rec_, 3);
   compare_to_    := arg2_;
   IF (SUBSTR(compare_to_,LENGTH(compare_to_),1) != ';') THEN
      compare_to_ := compare_to_ || ';';
   END IF;
   LOOP
      instra_     := INSTR(compare_to_,';');
      IF (NVL(instra_,0) = 0) THEN
         EXIT;
      END IF;
      compare_    := SUBSTR(compare_to_,1,instra_-1);
      compare_to_ := SUBSTR(compare_to_,instra_+1);
      instr_      := INSTR(arg1_,compare_);
      IF (arg3_ IS NOT NULL AND instr_ > arg3_) THEN
         instr_   := 0;
      END IF;
      IF (instr_ > 0) THEN
         result_  := compare_;
         EXIT;
      END IF;
   END LOOP;
   RETURN result_;
END Cf_Find_One_Of___;


FUNCTION Cf_Last_Day_In_Month___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   format1_         VARCHAR2(20);
   format2_         VARCHAR2(20);
   result_          VARCHAR2(100);
BEGIN
   arg1_    := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_    := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   format1_ := arg2_;
   format2_ := arg2_;
   IF (format1_ = 'MM') THEN
      format2_ := 'DD';
   END IF;
   result_  := TO_CHAR(LAST_DAY(TO_DATE(arg1_, format1_)), format2_);
   RETURN result_;
END Cf_Last_Day_In_Month___;


FUNCTION Cf_Current_Base_Currency___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_ := Currency_Code_API.Get_Currency_Code (arg1_);
   RETURN result_;
END Cf_Current_Base_Currency___;


FUNCTION Cf_Current_User___ RETURN VARCHAR2
IS
   result_          VARCHAR2(2000);
BEGIN
   result_ := Fnd_Session_API.Get_Fnd_User;
   RETURN result_;
END Cf_Current_User___;


FUNCTION Cf_Current_Company___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec) RETURN VARCHAR2
IS
   result_          VARCHAR2(2000);
BEGIN
   result_ := templ_det_rec_.company;
   RETURN result_;
END Cf_Current_Company___;


FUNCTION Cf_Def_Pay_Doc_Serie___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);

   $IF Component_Payled_SYS.INSTALLED $THEN
      Payment_Doc_Series_API.Get_Def_Series (arg1_, arg2_, result_);
      RETURN result_;
   $ELSE
      RETURN NULL;
   $END
END Cf_Def_Pay_Doc_Serie___;


FUNCTION Cf_Current_Load_File_Id___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec) RETURN VARCHAR2
IS
   result_          VARCHAR2(2000);
BEGIN
   result_ := templ_det_rec_.load_file_id;
   RETURN result_;
END Cf_Current_Load_File_Id___;


FUNCTION Cf_Current_Date_Time___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec) RETURN VARCHAR2
IS
   result_          VARCHAR2(2000);
   resultd_         DATE;
BEGIN
   resultd_ := SYSDATE;
   result_  := TO_CHAR(resultd_,templ_det_rec_.act_date_format);
   RETURN result_;
END Cf_Current_Date_Time___;


FUNCTION Cf_Round_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NULL) THEN
      result_ := ROUND(arg1_);
   ELSE
      result_ := ROUND(arg1_,arg2_);
   END IF;
   RETURN result_;
END Cf_Round_Number___;


FUNCTION Cf_Trunc_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   IF (arg2_ IS NULL) THEN
      result_ := TRUNC(arg1_);
   ELSE
      result_ := TRUNC(arg1_,arg2_);
   END IF;
   RETURN result_;
END Cf_Trunc_Number___;


FUNCTION Cf_Current_Date___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
   resultd_         DATE;
BEGIN
   resultd_ := TRUNC(SYSDATE);
   arg1_    := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   IF (arg1_ IS NOT NULL) THEN
      resultd_ := resultd_ + arg1_;
   END IF;
   result_  := TO_CHAR(resultd_,templ_det_rec_.act_date_format);
   RETURN result_;
END Cf_Current_Date___;


FUNCTION Cf_Sign_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_ := SIGN(arg1_);
   RETURN result_;
END Cf_Sign_Number___;


FUNCTION Cf_Abs_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_ := ABS(arg1_);
   RETURN result_;
END Cf_Abs_Number___;


FUNCTION Cf_Add_Line_Feed_First___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   file_value_      VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   file_value_ := Ext_File_Column_Util_API.Return_C_Value (templ_det_rec_.act_dest_column,templ_det_rec_.transrec);
   arg1_       := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_     := REPLACE(REPLACE(arg1_,CHR(10)),CHR(13));
   result_     := CHR(13) || CHR(10) || result_;
   RETURN result_;
END Cf_Add_Line_Feed_First___;


FUNCTION Cf_Add_Line_Feed_Last___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   arg1_            VARCHAR2(4000);
   file_value_      VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   file_value_ := Ext_File_Column_Util_API.Return_C_Value (templ_det_rec_.act_dest_column,templ_det_rec_.transrec);
   arg1_       := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   result_     := REPLACE(REPLACE(arg1_,CHR(10)),CHR(13));
   result_     := result_ || CHR(13) || CHR(10);
   RETURN result_;
END Cf_Add_Line_Feed_Last___;


FUNCTION Cf_Row_Number___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec) RETURN VARCHAR2
IS
   result_          VARCHAR2(2000);
BEGIN
   result_ := templ_det_rec_.transrec.row_no;
   RETURN result_;
END Cf_Row_Number___;


FUNCTION Cf_Remove_Not_Num___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   c_               VARCHAR2(1);
   ok_value_        VARCHAR2(1);
   arg1_            VARCHAR2(4000);
   arg2_            VARCHAR2(4000);
   result_          VARCHAR2(2000);
BEGIN
   arg1_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   arg2_   := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   Trace_SYS.Message('***** arg1_ : '||arg1_||' arg2_ : '||arg2_);
   FOR i_ IN 1..LENGTH(arg1_) LOOP
      ok_value_ := NULL;
      c_ := SUBSTR(arg1_,i_,1);
      Trace_SYS.Message('***** c_ : '||c_);
      IF (c_ < '0' OR c_ > '9') THEN
         IF (arg2_ IS NOT NULL) THEN
            IF (arg2_ LIKE '%'||c_||'%') THEN
               ok_value_ := c_;
            END IF;
         END IF;
      ELSE
         ok_value_ := c_;
      END IF;
      IF (ok_value_ IS NOT NULL) THEN
         IF (result_ IS NULL) THEN
            result_ := ok_value_;
         ELSE
            result_ := result_||ok_value_;
         END IF;
         Trace_SYS.Message('***** result_ : '||result_);
      END IF;
   END LOOP;
   RETURN result_;
END Cf_Remove_Not_Num___;


FUNCTION Cf_X_Attribute___( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   source_text_     VARCHAR2(4000);
   result_          VARCHAR2(4000);
   tag_id_          VARCHAR2(4000);
   tag_start_       VARCHAR2(4000);
   tag_end_         VARCHAR2(4000);
   value_end_       VARCHAR2(4000);
   tag_instr_       NUMBER;
BEGIN
   source_text_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   tag_id_      := Get_Function_Arg___(templ_det_rec_,command_rec_, 2);
   tag_start_   := NVL(Get_Function_Arg___(templ_det_rec_,command_rec_, 3),'<');
   tag_end_     := NVL(Get_Function_Arg___(templ_det_rec_,command_rec_, 4),'>');
   value_end_   := NVL(Get_Function_Arg___(templ_det_rec_,command_rec_, 5),'</');
   IF (tag_start_ IS NOT NULL) THEN
      tag_instr_ := INSTR(source_text_,tag_start_||tag_id_);
   ELSE
      tag_instr_ := INSTR(source_text_,tag_id_);
   END IF;
   IF (tag_instr_ > 0) THEN
      result_ := SUBSTR(source_text_,tag_instr_);
      tag_instr_ := INSTR(result_,tag_end_);
      IF (tag_instr_ > 0) THEN
         result_ := SUBSTR(result_,tag_instr_+1);
         tag_instr_ := INSTR(result_,value_end_);
         IF (tag_instr_ > 0) THEN
            result_ := SUBSTR(result_,1,tag_instr_-1);
         END IF;
      END IF;
   END IF;
   RETURN result_;
END Cf_X_Attribute___;


FUNCTION Execute_Function_Step___(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
   result_          VARCHAR2(4000);
BEGIN
   IF (command_rec_.Empty) THEN
      RETURN NULL;
   ELSE
      CASE command_rec_.Main_Function
         WHEN  'SET_DEFAULT_VALUE'     THEN result_ := Cf_Set_Default_Value___     (templ_det_rec_, command_rec_);
         WHEN  'LINE_REF'              THEN result_ := Cf_Line_Ref___              (templ_det_rec_);
         WHEN  'DETAIL_REF'            THEN result_ := Cf_Detail_Ref___            (templ_det_rec_, command_rec_);
         WHEN  'COLUMN_REF'            THEN result_ := Cf_Column_Ref___            (templ_det_rec_, command_rec_);
         WHEN  'DESTCOL_REF'           THEN result_ := Cf_Destcol_Ref___           (templ_det_rec_, command_rec_);
         WHEN  'PARAMETER_REF'         THEN result_ := Cf_Parameter_Ref___         (templ_det_rec_, command_rec_);
         WHEN  'PARAMETER_PUT'         THEN result_ := Cf_Parameter_Put___         (templ_det_rec_, command_rec_);
         WHEN  'SUB_STRING'            THEN result_ := Cf_Sub_String___            (templ_det_rec_, command_rec_);
         WHEN  'LEFT_TRIM'             THEN result_ := Cf_Left_Trim___             (templ_det_rec_, command_rec_);
         WHEN  'RIGHT_TRIM'            THEN result_ := Cf_Right_Trim___            (templ_det_rec_, command_rec_);
         WHEN  'LEFT_PAD'              THEN result_ := Cf_Left_Pad___              (templ_det_rec_, command_rec_);
         WHEN  'RIGHT_PAD'             THEN result_ := Cf_Right_Pad___             (templ_det_rec_, command_rec_);
         WHEN  'LENGTH'                THEN result_ := Cf_Length___                (templ_det_rec_, command_rec_);
         WHEN  'FIND_STRING'           THEN result_ := Cf_Find_String___           (templ_det_rec_, command_rec_);
         WHEN  'TO_UPPERCASE'          THEN result_ := Cf_To_Upper_Case___         (templ_det_rec_, command_rec_);
         WHEN  'TO_LOWERCASE'          THEN result_ := Cf_To_Lower_Case___         (templ_det_rec_, command_rec_);
         WHEN  'TO_CHAR'               THEN result_ := Cf_To_Char___               (templ_det_rec_, command_rec_);
         WHEN  'TO_NUMBER'             THEN result_ := Cf_To_Number___             (templ_det_rec_, command_rec_);
         WHEN  'CONCATENATE'           THEN result_ := Cf_Concatenate___           (templ_det_rec_, command_rec_);
         WHEN  'REPLACE'               THEN result_ := Cf_Replace___               (templ_det_rec_, command_rec_);
         WHEN  'TRANSLATE'             THEN result_ := Cf_Translate___             (templ_det_rec_, command_rec_);
         WHEN  'ADD'                   THEN result_ := Cf_Add___                   (templ_det_rec_, command_rec_);
         WHEN  'SUBTRACT'              THEN result_ := Cf_Subtract___              (templ_det_rec_, command_rec_);
         WHEN  'MULTIPLY'              THEN result_ := Cf_Multiply___              (templ_det_rec_, command_rec_);
         WHEN  'DIVIDE'                THEN result_ := Cf_Divide___                (templ_det_rec_, command_rec_);
         WHEN  'CHANGE_SIGN'           THEN result_ := Cf_Change_Sign___           (templ_det_rec_, command_rec_);
         WHEN  'IS_NUMBER'             THEN result_ := Cf_Is_Number___             (templ_det_rec_, command_rec_);
         WHEN  'IF_ELSE'               THEN result_ := Cf_If_Else___               (templ_det_rec_, command_rec_);
         WHEN  'IF_ELSE_CONDITION'     THEN result_ := Cf_If_Else_Condition___     (templ_det_rec_, command_rec_);
         WHEN  'IF_EMPTY'              THEN result_ := Cf_If_Empty___              (templ_det_rec_, command_rec_);
         WHEN  'IS_EMPTY'              THEN result_ := Cf_Is_Empty___              (templ_det_rec_, command_rec_);
         WHEN  'FIND_ONE_OF'           THEN result_ := Cf_Find_One_Of___           (templ_det_rec_, command_rec_);
         WHEN  'LAST_DAY_IN_MONTH'     THEN result_ := Cf_Last_Day_In_Month___     (templ_det_rec_, command_rec_);
         WHEN  'CURRENT_BASE_CURRENCY' THEN result_ := Cf_Current_Base_Currency___ (templ_det_rec_, command_rec_);
         WHEN  'CURRENT_USER'          THEN result_ := Cf_Current_User___;
         WHEN  'CURRENT_COMPANY'       THEN result_ := Cf_Current_Company___       (templ_det_rec_);
         WHEN  'CURRENT_LOAD_FILE_ID'  THEN result_ := Cf_Current_Load_File_Id___  (templ_det_rec_);
         WHEN  'CURRENT_DATE_TIME'     THEN result_ := Cf_Current_Date_Time___     (templ_det_rec_);
         WHEN  'ROUND_NUMBER'          THEN result_ := Cf_Round_Number___          (templ_det_rec_, command_rec_);
         WHEN  'TRUNC_NUMBER'          THEN result_ := Cf_Trunc_Number___          (templ_det_rec_, command_rec_);
         WHEN  'CURRENT_DATE'          THEN result_ := Cf_Current_Date___          (templ_det_rec_, command_rec_);
         WHEN  'SIGN_NUMBER'           THEN result_ := Cf_Sign_Number___           (templ_det_rec_, command_rec_);
         WHEN  'ABS_NUMBER'            THEN result_ := Cf_Abs_Number___            (templ_det_rec_, command_rec_);
         WHEN  'ADD_LINE_FEED_FIRST'   THEN result_ := Cf_Add_Line_Feed_First___   (templ_det_rec_, command_rec_);
         WHEN  'ADD_LINE_FEED_LAST'    THEN result_ := Cf_Add_Line_Feed_Last___    (templ_det_rec_, command_rec_);
         WHEN  'ROW_NUMBER'            THEN result_ := Cf_Row_Number___            (templ_det_rec_);
         WHEN  'REMOVE_NOT_NUM'        THEN result_ := Cf_Remove_Not_Num___        (templ_det_rec_, command_rec_);
         WHEN  'FIND_X_ATTR'           THEN result_ := Cf_X_Attribute___           (templ_det_rec_, command_rec_);
         WHEN  'DEF_PAY_DOC_SERIE'     THEN result_ := Cf_Def_Pay_Doc_Serie___     (templ_det_rec_, command_rec_);
         ELSE                               result_ := NULL;
      END CASE;
   END IF;
   --Trace_SYS.Message ('Execute_Function_Step___ Command_Rec.Main_Function : '||Command_Rec.Main_Function||' result_ : '||result_);
   RETURN result_;
EXCEPTION
   WHEN fc_value_error THEN
      Error_SYS.Appl_General( lu_name_, 'VALUEERROR: Value error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_numeric_error THEN
      Error_SYS.Appl_General( lu_name_, 'NUMERICERROR: Numeric error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_date_error THEN
      Error_SYS.Appl_General( lu_name_, 'DATEERROR: Date error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_colref_error THEN
      Error_SYS.Appl_General( lu_name_, 'COLREFERROR: Column reference error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_destcolref_error THEN
      Error_SYS.Appl_General( lu_name_, 'DCOLREFERROR: Destination Column reference error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_detref_error THEN
      Error_SYS.Appl_General( lu_name_, 'DETREFERROR: Detail reference error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_parref_error THEN
      Error_SYS.Appl_General( lu_name_, 'PARREFERROR: Parameter reference error on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN fc_illegaldate_error THEN
      Error_SYS.Appl_General( lu_name_, 'ILLDATEERROR: Illegal function for date column on (column no :P1 function no :P2 )',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
   WHEN OTHERS THEN
      IF    (templ_det_rec_.act_data_type = '3') THEN
         Error_SYS.Appl_General( lu_name_, 'DATEERROR2: Date error on column no :P1 function no :P2 ',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
      ELSIF (templ_det_rec_.act_data_type = '2') THEN
         Error_SYS.Appl_General( lu_name_, 'NUMERICERROR2: Numeric error on column no :P1 function no :P2 ',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
      ELSE
         Error_SYS.Appl_General( lu_name_, 'VALUEERROR2: Value error on column no :P1 function no :P2 ',templ_det_rec_.act_column_id,templ_det_rec_.act_function );
      END IF;
END Execute_Function_Step___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Trace_Column_Function( 
   templ_det_rec_ IN External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) 
IS
BEGIN
   IF (command_rec_.empty) THEN 
      Trace_SYS.Put_Line('Nothing found');
   ELSE
      Trace_SYS.Put_Line ('Main Function = '||command_rec_.main_function);
      Trace_SYS.Put_Line ('N_Args        = ' ||command_rec_.n_args);  
      FOR c in 1..command_rec_.n_args LOOP
         Trace_SYS.Put_Line ('arg '|| to_char(c));
         Trace_SYS.Put_Line ('argument_str  = '||command_rec_.main_argument_list(c).argument_string);
         Trace_SYS.Put_Line ('use_str       = '||command_rec_.main_argument_list(c).use_string);
         Trace_SYS.Put_Line ('argument_type = '||command_rec_.main_argument_list(c).argument_type);         
         IF (command_rec_.main_argument_list(c).argument_type = 'FUNCTION') THEN
            Trace_SYS.Put_Line ('s_arg_string = '||command_rec_.main_argument_list(c).single_argument.argument_string);  
            Trace_SYS.Put_Line( 's_arg_type   = '||command_rec_.main_argument_list(c).single_argument.argument_type);  
         END IF;
      END LOOP;
   END IF;
END Trace_Column_Function;


FUNCTION Execute_Function_Step( 
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN External_File_Utility_API.Command_Rec ) RETURN VARCHAR2
IS
BEGIN
   RETURN Execute_Function_Step___( templ_det_rec_, command_rec_ );
END Execute_Function_Step;


FUNCTION Execute_Column_Functions(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN OUT External_File_Utility_API.Command_Rec,
   ft_           IN     NUMBER ) RETURN VARCHAR2
IS
   step_result_         VARCHAR2(4000);
   cf_from_             NUMBER         := templ_det_rec_.ft_list(ft_).funct_detail_from;
BEGIN
   IF (templ_det_rec_.cf_list(cf_from_).main_function != 'LOOP_MERGE') THEN
      step_result_ := Execute_Column_Func_Normal (templ_det_rec_, command_rec_, ft_);
   ELSE
      step_result_ := Execute_Column_Func_Merge (templ_det_rec_, command_rec_, ft_);
   END IF;
   RETURN step_result_;
END Execute_Column_Functions;


FUNCTION Execute_Column_Func_Normal(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN OUT External_File_Utility_API.Command_Rec,
   ft_           IN     NUMBER ) RETURN VARCHAR2
IS
   step_result_         VARCHAR2(4000);
   cf_from_             NUMBER         := templ_det_rec_.ft_list(ft_).funct_detail_from;
   cf_to_               NUMBER         := templ_det_rec_.ft_list(ft_).funct_detail_to;
BEGIN
   FOR i IN cf_from_ .. cf_to_ LOOP
      IF (templ_det_rec_.cf_list(1).main_function != 'LOOP_MERGE') THEN
         templ_det_rec_.col_func_exit      := 'FALSE';
         templ_det_rec_.act_function       := templ_det_rec_.cf_list(i).function_no;
         Ext_File_Argument_Handler_API.Validate_Fkn_Synthax (templ_det_rec_.cf_list(i).main_function,
                                                             templ_det_rec_.cf_list(i).function_argument,
                                                             templ_det_rec_);
         Ext_File_Argument_Handler_API.Unpack_Arguments (command_rec_,
                                                         templ_det_rec_.cf_list(i).main_function,
                                                         templ_det_rec_.cf_list(i).function_argument,
                                                         templ_det_rec_);
         --Ext_File_Function_Handler_API.Trace_Column_Function (Templ_Det_Rec,
         --                                                     Command_Rec);
         step_result_ := Ext_File_Function_Handler_API.Execute_Function_Step( templ_det_rec_,
                                                                              command_rec_ );
         templ_det_rec_.cf_list(i).step_result := step_result_;
         Trace_SYS.Message ('***** Act_index : '||templ_det_rec_.act_index||' Executing function '||command_rec_.Main_Function||' step_result : '||templ_det_rec_.cf_list(i).step_result);
         IF (templ_det_rec_.col_func_exit = 'TRUE') THEN
            EXIT;
         END IF;
      END IF;
   END LOOP;
   RETURN step_result_;
END Execute_Column_Func_Normal;


FUNCTION Execute_Column_Func_Merge(
   templ_det_rec_ IN OUT External_File_Utility_API.ft_m_det_rec,
   command_rec_   IN OUT External_File_Utility_API.Command_Rec,
   ft_           IN     NUMBER ) RETURN VARCHAR2
IS
   org_line_            VARCHAR2(4000);
   packed_line_         VARCHAR2(4000);
   file_line_           VARCHAR2(4000);
   merge_result_        VARCHAR2(4000);
   step_result_         VARCHAR2(4000);
   merge_separator_     VARCHAR2(20);
   instr_               NUMBER;
   cf_from_             NUMBER         := templ_det_rec_.ft_list(ft_).funct_detail_from;
   value_tab_            External_File_Utility_API.ValueTabType;
   count_               NUMBER         := 0;
   max_v_               NUMBER;
BEGIN
   org_line_    :=  templ_det_rec_.transrec.file_line;
   Ext_File_Argument_Handler_API.Unpack_Arguments (command_rec_,
                                                   templ_det_rec_.cf_list(cf_from_).main_function,
                                                   templ_det_rec_.cf_list(cf_from_).function_argument,
                                                   templ_det_rec_ );
   merge_separator_ := Get_Function_Arg___(templ_det_rec_,command_rec_, 1);
   packed_line_     := org_line_;
   instr_           := INSTR(packed_line_,CHR(10));
   LOOP
      IF (instr_ > 0) THEN
         file_line_     := SUBSTR(packed_line_,1,instr_-1);
         packed_line_   := SUBSTR(packed_line_,instr_ + 1);
      ELSE
         file_line_     := packed_line_;
         packed_line_   := NULL;
      END IF;
      count_            := count_ + 1;
      value_tab_(count_) := file_line_;
      instr_ := INSTR(packed_line_,CHR(10));
      IF (packed_line_ IS NULL) THEN
         EXIT;
      END IF;
   END LOOP;
   max_v_ := value_tab_.COUNT;
   FOR i_ IN 1 .. max_v_ LOOP
      file_line_        := value_tab_(i_);
      templ_det_rec_.transrec.file_line := file_line_;
      step_result_ := Execute_Column_Func_Normal (templ_det_rec_, command_rec_, ft_);
      IF (step_result_ IS NOT NULL) THEN
         IF (merge_result_ IS NULL) THEN
            merge_result_ := step_result_;
         ELSE
            merge_result_ := merge_result_ || merge_separator_ || step_result_;
         END IF;
      END IF;
   END LOOP;
   templ_det_rec_.transrec.file_line := org_line_;
   RETURN merge_result_;
END Execute_Column_Func_Merge;



