-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileArgumentHandler
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  051104  Jeguse  Created
--  051220  Maaylk  Removed General_SYS.Init_Method of Is_Valid_Number
--  070123  GaDalk  LCS Merge 6042
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Unpack_Arguments___( 
   command_line_rec_ OUT External_File_Utility_API.Command_Rec,
   main_function_    IN  VARCHAR2,
   command_line_     IN  VARCHAR2,
   templ_det_rec_    IN  External_File_Utility_API.ft_m_det_rec )
IS
   cmd_                  External_File_Utility_API.Command_Rec;
BEGIN
   IF (Is_Valid_Function___(main_function_, templ_det_rec_)) THEN
      cmd_.Main_function := main_function_;
      cmd_.Empty         := FALSE;
      IF (command_line_ IS NOT NULL) THEN 
         cmd_.N_Args := -1;
      ELSE
         cmd_.N_Args := 0;
      END IF;
   ELSE
      cmd_ := Set_Empty___;
   END IF;
   IF (command_line_ IS NOT NULL) THEN 
      Find_Main_Arg___( cmd_, command_line_, templ_det_rec_ );
      Find_Single_Arg___( cmd_, templ_det_rec_ );
   END IF;
   command_line_rec_ := cmd_;
END Unpack_Arguments___;


FUNCTION Get_Arg_Sep_Pos___( 
   source_str_ IN VARCHAR2,
   sep_chr_    IN VARCHAR2) RETURN PLS_INTEGER
IS
   string_chr_    VARCHAR2(1) := CHR(39);
   source_length_ PLS_INTEGER;
   ip_            PLS_INTEGER := 0;
   check_         BOOLEAN     := TRUE;
BEGIN
   source_length_ := LENGTH(source_str_);
   FOR i_ in 1..source_length_ LOOP
      IF (check_ AND SUBSTR(source_str_,i_ , 1) = sep_chr_) THEN
         ip_ := i_;
         EXIT;
      END IF;
      IF (SUBSTR(source_str_,i_ , 1) = string_chr_) THEN
         IF (check_) THEN
            check_ := FALSE;
         ELSE
            check_ := TRUE;
         END IF;
      END IF;
   END LOOP;
   RETURN ip_;
END Get_Arg_Sep_Pos___;


PROCEDURE Find_Main_Arg___( 
   command_line_rec_ IN OUT External_File_Utility_API.Command_Rec,
   command_line_     IN     VARCHAR2,
   templ_det_rec_    IN     External_File_Utility_API.ft_m_det_rec ) 
IS
   w_str_                   VARCHAR2(2000);
   ipos_                    PLS_INTEGER;
   arg_str_                 VARCHAR2(2000);
   i1_                      PLS_INTEGER;
BEGIN
   IF ( command_line_rec_.Empty = TRUE OR
        command_line_rec_.N_Args = 0 ) THEN
      NULL;
   ELSE
      command_line_rec_.N_Args := 0;
      w_str_ := LTRIM(REPLACE(command_line_,CHR(34),CHR(39)));
      i1_    := 0;
      ipos_  := Get_Arg_Sep_Pos___( w_str_, ',');
      WHILE (ipos_> 0) LOOP
         arg_str_  := LTRIM(SUBSTR(w_str_, 1, ipos_ - 1));
         arg_str_  := RTRIM(arg_str_, ' ');
         Assign_Main_Arg___( command_line_rec_, arg_str_, templ_det_rec_ );
         i1_       := ipos_ + 1;
         w_str_    := LTRIM(SUBSTR(w_str_, i1_));
         ipos_  := Get_Arg_Sep_Pos___( w_str_, ',');
      END LOOP;
      IF (w_str_ IS NOT NULL) THEN
         arg_str_ := LTRIM(w_str_);
         Assign_Main_Arg___( command_line_rec_, arg_str_, templ_det_rec_ );
      END IF;
   END IF;
END Find_Main_Arg___;


PROCEDURE Find_Single_Arg___( 
   command_line_rec_ IN OUT External_File_Utility_API.Command_Rec,
   templ_det_rec_    IN     External_File_Utility_API.ft_m_det_rec ) 
IS
   w_str_                   VARCHAR2(2000);
   use_str_                 VARCHAR2(2000);
   arg_type_                VARCHAR2(100);
BEGIN
   IF ( NOT command_line_rec_.Empty ) THEN
      FOR i_ IN 1..command_line_rec_.N_Args  LOOP
         IF ( command_line_rec_.Main_Argument_List(i_).Argument_Type = 'FUNCTION' ) THEN
            w_str_ := command_line_rec_.Main_Argument_List(i_).Argument_String;
            w_str_ := REPLACE(w_str_, command_line_rec_.Main_Argument_List(i_).Use_String,'');
            w_str_ := LTRIM(RTRIM(w_str_,' '),' ');
            IF (SUBSTR(w_str_,1,1)='(') THEN
               w_str_ := SUBSTR(w_str_,2);
               IF (SUBSTR(w_str_,LENGTH(w_str_),1)=')') THEN
                  w_str_ := SUBSTR(w_str_,1,LENGTH(w_str_)-1); 
               END IF;
            END IF;
            Get_Type_Of_Arg___(use_str_, arg_type_, w_str_, templ_det_rec_ );
            command_line_rec_.Main_Argument_List(i_).Single_Argument.Argument_String := use_str_;
            command_line_rec_.Main_Argument_List(i_).Single_Argument.Argument_Type   := arg_type_;
         END IF;
      END LOOP;
   END IF;
END Find_Single_Arg___;


PROCEDURE Assign_Main_Arg___(
   command_line_rec_ IN OUT External_File_Utility_API.Command_Rec,
   arg_str_          IN     VARCHAR2,
   templ_det_rec_    IN     External_File_Utility_API.ft_m_det_rec )
IS
   use_str_                 VARCHAR2(2000);
   arg_type_                VARCHAR2(50);
   n_                       PLS_INTEGER;
BEGIN
   n_                       := NVL(command_line_rec_.N_Args,0) + 1;
   command_line_rec_.N_Args := n_;
   command_line_rec_.Main_Argument_List(n_).Argument_String := arg_str_;
   Get_Type_Of_Arg___(use_str_, arg_type_, arg_str_, templ_det_rec_ );
   command_line_rec_.Main_Argument_List(n_).Use_String    := use_str_;
   command_line_rec_.Main_Argument_List(n_).Argument_Type := arg_type_;
END Assign_Main_Arg___;


FUNCTION Get_Min_Num_Of_Args___( 
   function_name_ IN VARCHAR2,
   templ_det_rec_  IN External_File_Utility_API.ft_m_det_rec ) RETURN NUMBER 
IS
   min_num_of_args_  NUMBER;
BEGIN
   min_num_of_args_ := templ_det_rec_.func_list(function_name_).min_num_of_args;
   RETURN min_num_of_args_;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END Get_Min_Num_Of_Args___;


FUNCTION Is_Valid_Function___( 
   function_name_ IN VARCHAR2,
   templ_det_rec_ IN External_File_Utility_API.ft_m_det_rec ) RETURN BOOLEAN 
IS
   min_num_of_args_  NUMBER;
BEGIN
   --RETURN Ext_File_Function_API.Check_Exist (function_name_);
   min_num_of_args_ := templ_det_rec_.func_list(function_name_).min_num_of_args;
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END Is_Valid_Function___;


PROCEDURE Find_Function___( 
   str_      IN  VARCHAR2,
   spos_     IN  PLS_INTEGER,
   found_    OUT BOOLEAN,
   name_     OUT VARCHAR2,
   lp_found_ OUT BOOLEAN) 
IS
   f_            BOOLEAN         := FALSE;                              
   fname_        VARCHAR2(100)   := NULL;
   work_str_     VARCHAR2(2000)  := LTRIM(SUBSTR(str_, spos_));
   pos_lp_       PLS_INTEGER;
BEGIN
   IF (work_str_ IS NOT NULL ) THEN
      pos_lp_ := INSTR(work_str_, '(');
      IF (pos_lp_ > 0 ) THEN
         fname_ := SUBSTR(work_str_, 1, pos_lp_ - 1 );
         f_     := TRUE;
      ELSE
         -- here we have found something, it might be a function without argument 
         -- or another type of argument
         fname_ := work_str_;
         f_     := TRUE;
      END IF;
    END IF;
    found_    := f_; 
    name_     := fname_;
    lp_found_ := (pos_lp_ > 0);
END Find_Function___;


FUNCTION Set_Empty___ RETURN External_File_Utility_API.Command_Rec
IS
   c_    External_File_Utility_API.Command_Rec;
BEGIN
   c_.empty := TRUE;
   RETURN c_;
END Set_Empty___;


PROCEDURE Get_Type_Of_Arg___(
   use_str_       OUT VARCHAR2,
   arg_type_      OUT VARCHAR2, 
   arg_str_       IN  VARCHAR2,
   templ_det_rec_ IN  External_File_Utility_API.ft_m_det_rec)
IS
   found_        BOOLEAN;
   name_         VARCHAR2(100);
   lp_found_     BOOLEAN;
   s_true_       VARCHAR2(2000);
   s_num_        NUMBER;
BEGIN
   IF (arg_str_ IS NULL) THEN
      use_str_   := NULL;
      arg_type_  := 'NULL_STRING';
   ELSE
      -- is this a function?
      Find_Function___( arg_str_, 1, found_, name_, lp_found_ );
      IF  (found_) THEN
         -- a valid function?
         -- VALIDATE That this is a valid SOURCE-FUNCTION
         IF (Is_Valid_Function___(name_, templ_det_rec_)) THEN
            use_str_    := name_;
            arg_type_   := 'FUNCTION';
         ELSE
            -- something else, true string, number string or other string
            s_true_ := Get_True_String___(arg_str_);
            s_num_  := Get_Num_String___(arg_str_);
            IF (s_true_ IS NOT NULL) THEN
               use_str_  := s_true_;
               arg_type_ := 'TRUE_STRING';
            ELSIF (s_num_ IS NOT NULL) THEN
               use_str_  := s_num_;
               arg_type_ := 'NUM_STRING';
            ELSE
               use_str_  := LTRIM(RTRIM(arg_str_));
               arg_type_ := 'STRING';
            END IF;
         END IF;
      ELSE
         Error_SYS.Appl_General(lu_name_, 'ERRDECODETYPE: Cannot decode type in string :P1', arg_str_) ;
      END IF;
   END IF;
END Get_Type_Of_Arg___;


PROCEDURE Validate_Fkn_Synthax___(
   w_str_         IN VARCHAR2,
   function_name_ IN VARCHAR2,
   templ_det_rec_ IN External_File_Utility_API.ft_m_det_rec)
IS
   n_lp_             PLS_INTEGER := 0;
   n_rp_             PLS_INTEGER := 0;
   n_39_             PLS_INTEGER := 0;
   par1s_            PLS_INTEGER := 1;
   par1e_            PLS_INTEGER := 0;
   func1_            VARCHAR2(100);
   par2s_            PLS_INTEGER := 0;
   par2e_            PLS_INTEGER := 0;
   func2_            VARCHAR2(100);
   min_num_of_args_  NUMBER;
   num_of_args_      NUMBER      := 0;
BEGIN
   --Trace_SYS.Message ('##### Validate_Fkn_Synthax___ Function_Name_ : '||Function_Name_||' w_str_ : '||w_str_);
   --min_num_of_args_ := Ext_File_Function_API.Get_Min_Num_Of_Args (function_name_);
   IF (templ_det_rec_.load_file_id = 0) THEN
      min_num_of_args_ := Ext_File_Function_API.Get_Min_Num_Of_Args (function_name_);
   ELSE
      min_num_of_args_ := Get_Min_Num_Of_Args___ (function_name_, templ_det_rec_);
   END IF;
   IF (w_str_ IS NOT NULL) THEN 
      num_of_args_ := num_of_args_ + 1;
      FOR i_ IN 1..LENGTH(w_str_) LOOP
         IF (   SUBSTR(w_str_,i_,1) = ',') THEN
            num_of_args_ := num_of_args_ + 1;
         END IF;
         IF (   SUBSTR(w_str_,i_,1) = '(') THEN
            n_lp_ := n_lp_ + 1;
         ELSIF( SUBSTR(w_str_,i_,1) = ')') THEN
            n_rp_ := n_rp_ + 1;
         ELSIF( SUBSTR(w_str_,i_,1) = CHR(39)) THEN
            n_39_ := n_39_ + 1;
         END IF;
      END LOOP;
      IF (n_lp_ <> n_rp_) THEN
         Error_SYS.Appl_General(lu_name_, 
                                'INVFKNSYNTX: Invalid paranthesis synthax for function :P1',
                                 function_name_ );
      END IF;
      IF (MOD(n_39_,2) <> 0 ) THEN
         Error_SYS.Appl_General(lu_name_, 
                                'INVFKNSYNTX2: Invalid string argument synthax for function :P1',
                                 function_name_ );
      END IF;
      -- Check for nested functions
      FOR i_ IN 1..LENGTH(w_str_) LOOP
         IF (SUBSTR(w_str_,i_,1) = '(' AND par1e_ = 0) THEN
            par1e_ := i_;
            par2s_ := i_ + 1;
            func1_ := LTRIM(RTRIM(SUBSTR(w_str_,par1s_,par1e_-par1s_)));
         ELSE
            IF (SUBSTR(w_str_,i_,1) IN (',',')')) THEN
               par1s_ := i_ + 1;
               par1e_ := 0;
               par2s_ := 0;
               func1_ := NULL;
            END IF;
            IF (SUBSTR(w_str_,i_,1) = '(' AND par1e_ > 0) THEN
               par2e_ := i_;
               func2_ := LTRIM(RTRIM(SUBSTR(w_str_,par2s_,par2e_-par2s_)));
               Error_SYS.Appl_General(lu_name_, 
                                      'INVFKNSYNTX3: Invalid nested function synthax for function :P1 (:P2 (:P3))',
                                       function_name_,
                                       func1_,
                                       func2_ );
            END IF;
         END IF;
      END LOOP;
   END IF;
   IF (num_of_args_ < min_num_of_args_) THEN
      Error_SYS.Appl_General(lu_name_, 
                             'NOTENARGS: Number of arguments have to be at least :P1',
                              min_num_of_args_ );
   END IF;
END Validate_Fkn_Synthax___;


FUNCTION Get_True_String___(
   source_str_ IN VARCHAR2) RETURN VARCHAR2
IS
   s_             VARCHAR2(2000);
BEGIN
   s_ := LTRIM(RTRIM(source_str_));
   IF (SUBSTR(s_,1,1) = CHR(39)) THEN
      IF (SUBSTR(s_,LENGTH(s_),1)= CHR(39) ) THEN
         RETURN s_;
      END IF;
   END IF;
   RETURN NULL;
END Get_True_String___;


FUNCTION Get_Num_String___(
   source_str_ IN VARCHAR2) RETURN VARCHAR2
IS
   s_             VARCHAR2(2000);
BEGIN
   s_ := LTRIM(RTRIM(source_str_));
   IF (NOT Is_Valid_Number___(s_)) THEN
      s_ := REPLACE(s_, '.', ',');
      IF ( NOT Is_Valid_Number___(s_))THEN
         s_ := REPLACE(s_, ',', '.');
         IF ( NOT Is_Valid_Number___(s_)) THEN
            RETURN NULL;
         END IF;
      END IF;
   END IF;
   RETURN s_;
END Get_Num_String___;


FUNCTION Is_Valid_Number___(
   source_string_ IN VARCHAR2) RETURN BOOLEAN
IS
   n_                NUMBER;
BEGIN
   n_ := TO_NUMBER(source_string_);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END Is_Valid_Number___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

FUNCTION Arg_Is_Function__( 
   command_rec_ IN External_File_Utility_API.Command_Rec,
   i_arg_       IN PLS_INTEGER )  RETURN BOOLEAN
IS
BEGIN
   IF NOT( Arg_Ref_Ok__(command_rec_, i_arg_ )) THEN
      RETURN FALSE;
   ELSE
      IF ( command_rec_.Main_Argument_List(i_arg_).Argument_Type = 'FUNCTION') THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END IF;
END Arg_Is_Function__;


FUNCTION Get_Use_Str__(
   command_rec_ IN External_File_Utility_API.Command_Rec,
   i_arg_       IN PLS_INTEGER )  RETURN VARCHAR2
IS
BEGIN
   IF NOT( Arg_Ref_Ok__(command_rec_, i_arg_ )) THEN
      RETURN NULL;
   END IF;
   RETURN(command_rec_.Main_Argument_List(i_arg_).Use_String);
END Get_Use_Str__;


FUNCTION Arg_Ref_Ok__(
   command_rec_ IN External_File_Utility_API.Command_Rec,
   i_arg_       IN PLS_INTEGER )  RETURN BOOLEAN
IS
BEGIN
   IF (command_rec_.Empty OR command_rec_.N_Args < i_arg_) THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
END Arg_Ref_Ok__;


FUNCTION Build_Rec_For_Arg__(
   command_rec_ IN External_File_Utility_API.Command_Rec,
   i_arg_       IN PLS_INTEGER ) RETURN External_File_Utility_API.Command_Rec
IS
   arg_rec_        External_File_Utility_API.Command_Rec;
BEGIN
   IF NOT( Arg_Ref_Ok__(command_rec_, i_arg_ )) THEN
      RETURN(Set_Empty___);
   ELSE
      arg_rec_.main_function := command_rec_.Main_Argument_List(i_arg_).Use_String;
      arg_rec_.main_argument_list(1).argument_string := 
               command_rec_.Main_Argument_List(i_arg_).single_argument.argument_string;
      arg_rec_.main_argument_list(1).use_string :=
               arg_rec_.main_argument_list(1).argument_string;
      arg_rec_.main_argument_list(1).argument_type := 
               command_rec_.Main_Argument_List(i_arg_).single_argument.argument_type;
      arg_rec_.empty := FALSE;
      IF (command_rec_.Main_Argument_List(i_arg_).single_argument.argument_type='NULL_STRING') THEN
         arg_rec_.n_args  := 0;
      ELSE
         arg_rec_.n_args  := 1;
      END IF;
   END IF;
   RETURN(arg_rec_);
END Build_Rec_For_Arg__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Unpack_Arguments( 
   command_line_rec_ OUT External_File_Utility_API.Command_Rec,
   main_function_    IN  VARCHAR2,
   command_line_     IN  VARCHAR2,
   templ_det_rec_    IN  External_File_Utility_API.ft_m_det_rec ) 
IS
   cmd_rec_              External_File_Utility_API.Command_Rec;
BEGIN
   IF (main_function_ IS NULL) THEN
      cmd_rec_ := Set_Empty___;
   ELSE
      Unpack_Arguments___( cmd_rec_, 
                           main_function_, 
                           command_line_,
                           templ_det_rec_ );
   END IF;
   command_line_rec_ := cmd_rec_;
END Unpack_Arguments;


PROCEDURE Validate_Fkn_Synthax(
   main_function_     IN VARCHAR2,
   function_argument_ IN VARCHAR2,
   templ_det_rec_     IN External_File_Utility_API.ft_m_det_rec)
IS
BEGIN
   Validate_Fkn_Synthax___(function_argument_,
                           main_function_,
                           templ_det_rec_);
END Validate_Fkn_Synthax;


@UncheckedAccess
FUNCTION Is_Valid_Number(
   source_string_ IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
   RETURN Is_Valid_Number___( source_string_);
END Is_Valid_Number;




