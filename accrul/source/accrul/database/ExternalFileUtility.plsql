-----------------------------------------------------------------------------
--
--  Logical unit: ExternalFileUtility
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  020327  thsrlk  Corrected Double byte problem
--  020617  JeGu    Bug 31051 Corrected
--  021011  PPerse  Merged External Files
--  030805  prdilk  SP4 Merge.
--  031020  Brwelk  Init_Method Corrections
--  031231  ArJalk  FIPR300A1 Enhanced Batch Scheduling functionality.
--  040324  Gepelk  2004 SP1 Merge
--  040521  anpelk  Batch Scheduling  
--  040726  anpelk  FIPR338B Modified methods Create_Output_Message and Load_Client_File_
--  040805  Jeguse  IID FIJP335. Added Method Translate_Value_Sign_Conv
--                  The parts regarding this file for bug 44702 are merged.
--  040826  Jeguse  Merged bug 46650
--  050322  Samwlk  Bug 49874, Merged.
--  050714  Hecolk  LCS Merge 50272, Modified in Unpack_Separated_File, Tab_To_Table, Unpack_Ext_Line and Load_Client_File_
--  060126  Samwlk  LCS Bug 54682, Merged.
--  060316  TsYolk  Few lines are commented. These codes are not needed at present.
--  060615  Jeguse  Merged ExternalFileUtility2
--  061016  Kagalk  LCS Merge 57354, Modified in Unp_Separated_File___  
--  061201  Kagalk  LCS Merge 59780, Modified Create_External_Input to consider null values. 
--  061201  Kagalk  LCS Merge 61940, Modified Create_External_Input.
--  061208  Kagalk  LCS Merge 60487 
--  061212  Kagalk  LCS Merge 61676, Dispaly error msgs for date format errors.
--  061213  Kagalk  LCS Merge 61761
--  070123  GaDalk  LCS Merge 60420
--  070320  NiFelk  LCS Merge 62475.
--  070711  Hawalk  Merged Bug 66081, Corrected in Start_Input_Batch().
--  071018  Maselk  Bug 67348, Corrected the budget import error for code parts with ampersand sign.
--  071106  Nugalk  Bug 67693, Corrected.
--  071207  Maaylk  Bug 67699, Changed Create_External_Input() and the cursor detail_ in Copy_File_Type_From_View()
--  080124  Nugalk  Bug 69321, Corrected. PROCEDURE Tab_To_Table___(),
--  080124          Let Oracle handle to_date and then tried other methods.
--  080121  NiFelk  Bug 70517, Corrected. Added new parameter to method Create_Rec_Det_From_View.
--  080319  Jeguse  Bug 72555, Corrected in Tab_To_Table___
--  080324  Nugalk  Bug 72369, Corrected. Added a method call when date_nls_calendar format is not null, 
--  080324          to change the date to the correct format (e.g. Japanese date format)
--  080323  Jeguse  Bug 75259, Corrected in Get_Template_Data
--  080922  Jeguse  Bug 77126, Added method Create_Xml_File and taken care of new anonymous columns.
--                  Removed hidden XML code
--  081006  AjPelk  Bug 75568, Corrected
--  081212  Jeguse  Bug 78760  Modified method Merge_Skipped_File_Lines
--  090108  Jeguse  Bug 78481, Corrected in Get_Dyn_Id_Version and Tab_To_Table___
--  090109  Jeguse  Bug 77122, Corrected
--  090116  Jeguse  Bug 79498, Increased length of file_name
--  090127  Jeguse  Bug 79995, Corrected
--  090213  Jeguse  Bug 80586, Corrected
--  090226  Jeguse  Bug 77823, Corrected in Unp_Separated_File___
--  090320  Jeguse  Bug 81450, Corrected
--  090525  AsHelk  Bug 80221, Adding Transaction Statement Approved Annotation.
--  090717  ErFelk  Bug 83174, Replaced constant EXTFILUTI with EXTFILES in Execute_Batch_Process and
--  090717          Replaced constant EXTCREEXTFILE with EXTFILES in Start_Batch_Process.
--  090928  Nsillk  Issue Id EAFH-23 Removed the COMMIT statements
--  091106  Jeguse  Bug 86411, Added methods for creating insert file instructions
--  100203  Jeguse  Bug 88772 Corrected
--  100322  Jeguse  EAFH-2475 
--  101011  AjPelk  Bug 92374 Corrected , added a method only , Error_Text_Only 
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  110712  Sacalk  FIDEAGLE-316, Merged LCS Bug 94878 Corrected , added File_Path_Info, Error_Text_Only  
--  110719  Sacalk  FIDEAGLE-311, Merged Lcs Bug 94718 Corrected.
--  120216  AsHelk  SFI-2391, Changed Transaction_SYS method installed checks to Dictionary_SYS.
--  120503  Nudilk  EASTRTM-10831, Merged 102333. 
--  120709  Raablk  Bug 102620, Modified PROCEDURE Execute_Batch_Process2().
--  130129  Kagalk  Bug 107616, Modified field length 
--  130206  SALIDE  EDEL-1995, Added C100..C199.
--  130304  AjPelk  Bug 107649, Merged , added a new field remove_end_separator.
--  130320  AjPelk  Bug 109048, Corrected , Changed the limit in order to support multi-byte character
--  130430  AjPelk  Bug 109759, Corrected , Modified the code in method Get_Input_Package() in order to support '_UIV" views as well.
--                  Because other product groups such as 'Maintenance' uses '_UIV' views instead of their BASE views.
--  130730  Maaylk  Bug 111024, Called Security_Sys.Is_Method_Available() to check if user has access
--  130819  JUKODE  FISPTWO-430, Modified 'FOR i_ IN 0 .. 99 LOOP' to 'FOR i_ IN 0 .. 199 LOOP' due to adding additional column C100..C199 in Create_External_Output()
--  130816  Clstlk  Bug 111218, Fixed General_SYS.Init_Method issue.
--  130816  Waudlk  Bug 111891, Added method Get_Data_Rec which is used in ReceiveXmlPaymentFile bizapi.
--  130902  THPELK  Bug 112154, Corrected QA script cleanup - Financials  Type Cursor usage in procedure / function.
--  131029  PRATLK  PBFI-1329,Changed argument parameter to use encode in EXT_FILE_TEMPLATE_API.Get_File_Format method.
--  131112  Charlk  PBFI-2009,Get the Db value from Ext_File_Load_API.Get_File_Direction to support to the new app9 format.
--  131114  Charlk  PBFI-2045,Change method In_Ext_File_Template_Dir_API.Get_Character_Set to  Get_Character_Set_Db
--  131115  Lamalk  PBFI-2002, Refactored code according to new template standards
--  131123  MEALLK  PBFI-2017, Modified Start_Api_To_Call.
--  140212  Umdolk  PBFI-5065, Removed parsing of user source and instead used the base view. 
--  140709  Kagalk  PRFI-1051, Bug 117573, Enable to use views with 200 text columns when creating file types,templates from view definitions.
--  140829  Raablk  PBFI-803, Merged bug 117470 .Modified PROCEDURE Merge_Skipped_File_Lines. 
--  141115  AjPelk  PRFI-3385, Merged bug 119506. Not a direct merge.
--  141213  Ajpelk  PRFI-3930, Insert the client value inside Modify_File_Name to get the correct value for file_name_
--  150820  Waudlk  Bug 123663, Deprecated the Get_Data_Rec method.
--  151216  Nudilk  STRFI-804, Merged Bug 126210.
--  151221  Waudlk  STRFI-45, Removed the Get_Data_Rec.
--  170126  Kumglk  STRFI-4116, Merged Bug 132701.
--  170227  Chwtlk  STRFI-3529, Merged LCS Bug 131403.
--  170227  Savmlk  STRFI-5087, LCS Bug 134423 merged.
--  180622  Nudilk  Bug 142634, Corrected Col_To_Line___.
--  190304  Nudilk  Bug 147211, Corrected in Create_External_Input.
--  190413  Chwtlk  Bug 147863, Modified Start_Output_Batch.
--  190625  Chwtlk  Bug 148925, Modified in Create_External_Input.
--  191024  Nudilk  Bug 150675, Create_External_Input.
--  191125  kusplk  GESPRING20-1589, temperory solution to replace send tax report bizapi.
--  200403  Chwtlk  Bug 153186, Modified Create_Xml_File. Enhanced performance when creating the xml file.
--  200706  CKumlk  Bug 154570, Added method Check_View_Col_Diff.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE ExtFileRec IS RECORD
   (File_Template_Id          VARCHAR2(30), 
    File_Type                 VARCHAR2(30), 
    Description               VARCHAR2(200),
    Separated                 VARCHAR2(5),        
    Field_Separator           VARCHAR2(10),
    Decimal_Symbol            VARCHAR2(1),
    Denominator               NUMBER,
    Date_Format               VARCHAR2(50),
    Log_Skipped_Lines         VARCHAR2(5),
    Log_Invalid_Lines         VARCHAR2(5),
    Allow_Record_Set_Repeat   VARCHAR2(5),
    Allow_One_Record_Set_Only VARCHAR2(5),
    Active_Defininition       VARCHAR2(5),
    Valid_Definition          VARCHAR2(5),
    Abort_Immediatly          VARCHAR2(5),
    Number_Out_Fill_Value     VARCHAR2(1),
    Overwrite_File            VARCHAR2(5),
    Ext_File_Name_Option      VARCHAR2(1),
    Skip_Initial_Blanks       VARCHAR2(5),
    Skip_All_Blanks           VARCHAR2(5),
    Create_Header             VARCHAR2(5),
    Text_Qualifier            VARCHAR2(10),
    Date_Nls_Calendar         VARCHAR2(50),
    File_Format               VARCHAR2(10),
    api_to_call_unp_before    VARCHAR2(200),
    api_to_call_unp_after     VARCHAR2(200),
     remove_end_separator   VARCHAR2(5));
TYPE ExtFileDetailRec IS RECORD
   (File_Template_Id       VARCHAR2(30), 
    Record_Type_Id         VARCHAR2(20),        
    Column_Id              VARCHAR2(30),
    Data_Type              VARCHAR2(10),        
    Column_No              NUMBER,
    Start_Position         NUMBER,
    End_Position           NUMBER,
    Length_Position        NUMBER,
    Decimal_Symbol         VARCHAR2(1),
    Denominator            NUMBER,
    Date_Format            VARCHAR2(50));
TYPE ExtFileControlRec IS RECORD
   (File_Id                VARCHAR2(30),   
    Row_No                 VARCHAR2(10),
    Group_No               NUMBER,
    Condition              VARCHAR2(10),        
    Column_No              NUMBER,
    Start_Position         NUMBER,
    End_Position           NUMBER,
    Length_Position        NUMBER,
    Suppress_blank         VARCHAR2(5),
    String_Evaluate        VARCHAR2(30),
    Control_String         VARCHAR2(100),
    Record_Type_Id         VARCHAR2(20));        
TYPE ExtCurrencyRec IS RECORD
   (currency_code      VARCHAR2(3),
    currency_rate      NUMBER,
    valid_from         DATE );
TYPE ColumnTabType           IS TABLE OF VARCHAR2(35)  INDEX BY BINARY_INTEGER;
TYPE NumberTabType           IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE DateTabType             IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
TYPE CharSmallTabType        IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
TYPE CharBigTabType          IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
TYPE ValueTabType            IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE Single_Argument_Rec IS RECORD( Argument_String  VARCHAR2(200),
                                    Argument_Type    VARCHAR2(30));
TYPE Argument_Rec        IS RECORD( Argument_String  VARCHAR2(200),
                                    Use_String       VARCHAR2(200),
                                    Argument_Type    VARCHAR2(30),
                                    Single_Argument  Single_Argument_Rec );
TYPE Argument_List       IS TABLE OF Argument_Rec INDEX BY BINARY_INTEGER;
TYPE Command_Rec         IS RECORD( Main_Function       VARCHAR2(200),
                                    Main_Argument_List  Argument_List,
                                    Empty               BOOLEAN,
                                    N_Args              PLS_INTEGER );
TYPE cf_s_det_rec IS RECORD
   ( 
   row_no             Ext_File_Templ_Det_Func_Tab.row_no%TYPE,
   function_no        Ext_File_Templ_Det_Func_Tab.function_no%TYPE,
   main_function      Ext_File_Templ_Det_Func_Tab.main_function%TYPE,
   function_argument Ext_File_Templ_Det_Func_Tab.function_argument%TYPE,
   step_result        VARCHAR2(2000)
   );
TYPE cf_det_list      IS TABLE OF cf_s_det_rec INDEX BY BINARY_INTEGER;
TYPE cf_m_det_rec     IS RECORD(
    cf_list           cf_det_list,
    max_cf            PLS_INTEGER);
TYPE ef_func_rec IS RECORD
   ( 
   description     Ext_File_Function_Tab.description%TYPE,
   valid_argument  Ext_File_Function_Tab.valid_argument%TYPE,
   min_num_of_args Ext_File_Function_Tab.min_num_of_args%TYPE,
   max_num_of_args Ext_File_Function_Tab.max_num_of_args%TYPE
   );
TYPE ef_func_list      IS TABLE OF ef_func_rec INDEX BY VARCHAR2(50);
TYPE ft_s_det_rec IS RECORD
   ( 
   row_no             Ext_File_Template_Detail_Tab.row_no%TYPE,
   record_type_id     Ext_File_Template_Detail_Tab.record_type_id%TYPE,
   column_id          Ext_File_Template_Detail_Tab.column_id%TYPE,
   data_type          Ext_File_Type_Rec_Column_Tab.data_type%TYPE,
   column_no          Ext_File_Template_Detail_Tab.column_no%TYPE,
   start_position     Ext_File_Template_Detail_Tab.start_position%TYPE,
   length_position    Ext_File_Template_Detail_Tab.end_position%TYPE,
   decimal_symbol     Ext_File_Template_Tab.decimal_symbol%TYPE,
   denominator        Ext_File_Template_Tab.denominator%TYPE,
   detail_denominator VARCHAR2(1),
   date_format        Ext_File_Template_Tab.date_format%TYPE,
   destination_column Ext_File_Type_Rec_Column_Tab.destination_column%TYPE,
   description        VARCHAR2(100),
   control_column     Ext_File_Template_Detail_Tab.control_column%TYPE,
   max_length         Ext_File_Template_Detail_Tab.max_length%TYPE,
   function_detail    NUMBER,
   funct_detail_from  NUMBER,
   funct_detail_to    NUMBER
   );
TYPE ft_det_list      IS TABLE OF ft_s_det_rec INDEX BY BINARY_INTEGER;
TYPE gr_s_det_rec IS RECORD
   ( 
   record_type_id      Ext_File_Type_Rec_Tab.record_type_id%TYPE,
   parent_record_type  Ext_File_Type_Rec_Tab.parent_record_type%TYPE,
   record_set_id       Ext_File_Type_Rec_Tab.record_set_id%TYPE,
   first_in_record_set Ext_File_Type_Rec_Tab.first_in_record_set%TYPE,
   last_in_record_set  Ext_File_Type_Rec_Tab.last_in_record_set%TYPE,
   mandatory_record    Ext_File_Type_Rec_Tab.mandatory_record%TYPE,
   record_set_count    NUMBER
   );
TYPE gr_det_list      IS TABLE OF gr_s_det_rec INDEX BY BINARY_INTEGER;
TYPE cn_s_det_rec IS RECORD
   ( 
   record_type_id      Ext_File_Template_Control_Tab.record_type_id%TYPE,
   row_no              Ext_File_Template_Control_Tab.row_no%TYPE,
   group_no            Ext_File_Template_Control_Tab.group_no%TYPE,
   condition           Ext_File_Template_Control_Tab.condition%TYPE,
   column_no           Ext_File_Template_Control_Tab.column_no%TYPE,
   start_position      Ext_File_Template_Control_Tab.start_position%TYPE,
   length_position     Ext_File_Template_Control_Tab.end_position%TYPE,
   control_string      Ext_File_Template_Control_Tab.control_string%TYPE,
   destination_column  Ext_File_Template_Control_Tab.destination_column%TYPE,
   no_of_lines         Ext_File_Template_Control_Tab.no_of_lines%TYPE
   );
TYPE cn_det_list      IS TABLE OF cn_s_det_rec INDEX BY BINARY_INTEGER;
TYPE ft_m_det_rec     IS RECORD
   ( 
   ft_list           ft_det_list,                           -- File Template Detail Records
   max_ft            PLS_INTEGER,                           -- Max File Template Details
   cf_list           cf_det_list,                           -- Column Function Records
   max_cf            PLS_INTEGER,                           -- Max Column Functions
   gr_any_first      VARCHAR2(5),                           -- Any record type marked with first
   gr_any_last       VARCHAR2(5),                           -- Any record type marked with last
   cn_list           cn_det_list,                           -- File Template Control Records
   max_cn            PLS_INTEGER,                           -- Max File Template Controls
   gr_list           gr_det_list,                           -- File Template Group Records
   max_gr            PLS_INTEGER,                           -- Max File Template Groups
   func_list         ef_func_list,                          -- Valid File Functions
   transrec          Ext_File_Trans_Tab%ROWTYPE,            -- Transaction Record
   load_file_id      NUMBER,                                -- Load File Id
   file_direction    Ext_File_Template_Dir_Tab.file_direction%TYPE, -- File direction (1=in,2=Out)
   ext_file_rec      External_File_Utility_API.ExtFileRec,  -- File Type / Template Information
   parameter_string  VARCHAR2(2000),                        -- Parameter String
   act_row_no        NUMBER,
   act_record_type   Ext_File_Type_Rec_Column_Tab.record_type_id%TYPE,
   act_column_id     Ext_File_Type_Rec_Column_Tab.column_id%TYPE,
   act_dest_column   Ext_File_Type_Rec_Column_Tab.destination_column%TYPE,
   act_data_type     Ext_File_Type_Rec_Column_Tab.data_type%TYPE,
   act_date_format   Ext_File_Template_Detail_Tab.date_format%TYPE,
   act_index         NUMBER ,
   act_function      NUMBER ,
   company           Ext_File_Load_Tab.company%TYPE,
   col_func_exit     VARCHAR2(5)
   );
   
TYPE col_values_rec IS RECORD (
   line_columns   VARCHAR2(32000),
   stmt           VARCHAR2(32000));

TYPE col_list IS TABLE OF col_values_rec INDEX BY VARCHAR2(100);

TYPE LineTabType IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------

unp_date_format_error   EXCEPTION;
to_long_out_line        EXCEPTION;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Clear_Value_Tab___ (
   value_tab_ IN OUT ValueTabType,
   max_i_     IN     NUMBER )
IS
BEGIN
   FOR i_ IN 1 .. max_i_ LOOP
      value_tab_(i_) := NULL;
   END LOOP;
END Clear_Value_Tab___;


PROCEDURE Unp_Separated_File___ (
   err_msg_          IN OUT VARCHAR2,
   row_state_        IN OUT VARCHAR2,
   value_tab_        IN OUT ValueTabType,
   buffer_           IN     VARCHAR2,
   ext_file_rec_     IN     ExtFileRec )
IS
   bufferx_              VARCHAR2(4001);
   count_                NUMBER;
   pos_                  NUMBER;
   value_                VARCHAR2(4000);
   length_separator_     NUMBER;
   column_length_        NUMBER;
   first_txq_            NUMBER;
   second_txq_           NUMBER;
BEGIN
   Trace_SYS.Message ('Start Unp_Separated_File___');
   length_separator_ := LENGTH(ext_file_rec_.field_separator);
   pos_              := 1;
   count_            := 0;
   bufferx_          := buffer_;
   bufferx_          := bufferx_||ext_file_rec_.field_separator;
   LOOP
      IF (ext_file_rec_.text_qualifier IS NOT NULL) THEN
         IF (SUBSTR(bufferx_, 1,1) != ext_file_rec_.text_qualifier) THEN
            pos_           := INSTR(bufferx_, ext_file_rec_.field_separator);
         ELSE
            first_txq_     := INSTR(bufferx_, ext_file_rec_.text_qualifier);
            IF (NVL(first_txq_,0) = 0) THEN
               pos_        := INSTR(bufferx_, ext_file_rec_.field_separator);
            ELSE
               second_txq_ := INSTR(bufferx_, ext_file_rec_.text_qualifier,2);
               IF (NVL(second_txq_,0) = 0) THEN
                  pos_     := INSTR(bufferx_, ext_file_rec_.field_separator);
               ELSE
                  pos_     := INSTR(bufferx_, ext_file_rec_.field_separator,second_txq_);
               END IF;
            END IF;
         END IF;
      ELSE
         pos_              := INSTR(bufferx_, ext_file_rec_.field_separator);
      END IF;
      IF (NVL(pos_,0) = 0) THEN
         EXIT;
      END IF;
      count_            := count_ + 1;
      IF (NVL(pos_,0) > 1) THEN
         column_length_    := pos_ - 1;
         value_            := RTRIM(SUBSTR(bufferx_, 1, column_length_));
      ELSE
         column_length_    := 0;
         value_            := NULL;
      END IF;

      Trace_SYS.Message ('count_ : '||count_||' column_length_ : '||column_length_||' pos_ : '||pos_||' value_ : '||value_); 
      IF (ext_file_rec_.text_qualifier IS NOT NULL) THEN
         value_ := REPLACE(value_,ext_file_rec_.text_qualifier);
      END IF;
      value_tab_(count_) := value_;
      bufferx_          := SUBSTR(bufferx_,pos_+ length_separator_);
   END LOOP;
   -- Removed test on 'ExtCustInv','ExtSuppInv' (is handled by max_length on template details
EXCEPTION
   WHEN OTHERS THEN
      Trace_SYS.Message('Unp_Separated_File___ sqlerrm : '||sqlerrm);
      err_msg_   := SUBSTR('Unp Sep ' || sqlerrm,1,2000);
      row_state_ := '4';
END Unp_Separated_File___;


PROCEDURE Unp_Merge_Extra_Lines___ (
   err_msg_             IN OUT VARCHAR2,
   row_state_           IN OUT VARCHAR2,
   unp_value_tab_       IN OUT ValueTabType,
   buffer_              IN OUT VARCHAR2,
   no_of_x_lines_       IN OUT NUMBER,
   no_of_skipped_lines_ IN OUT NUMBER,
   ext_file_rec_        IN     ExtFileRec,
   load_file_id_        IN     NUMBER,
   row_no_              IN     NUMBER )
IS
   max_v_                      NUMBER;
   CURSOR GetFileTransXRow (row_no_ IN NUMBER) IS
      SELECT row_no, 
             file_line
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       > row_no_;
BEGIN
   Trace_SYS.Message ('Start Unp_Merge_Extra_Lines___');
   no_of_skipped_lines_ := no_of_x_lines_;
   FOR recx_ IN GetFileTransXRow (row_no_) LOOP
      IF (no_of_x_lines_ = 0) THEN
         EXIT;
      END IF;
      buffer_ := buffer_ || recx_.file_line;
      no_of_x_lines_ := no_of_x_lines_ - 1;
      err_msg_   := Language_SYS.Translate_Constant (lu_name_, 'EXTUSED: Information merged to line :P1',NULL,row_no_);
      Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                           recx_.row_no,
                                           '6',
                                           err_msg_);
      err_msg_   := NULL;
   END LOOP;
   IF (ext_file_rec_.file_format = 'SEP') THEN
      max_v_ := unp_value_tab_.COUNT;
      IF (max_v_ > 0) THEN
         Clear_Value_Tab___ ( unp_value_tab_, max_v_ );  
      END IF;
      Unp_Separated_File___ ( err_msg_,
                              row_state_,
                              unp_value_tab_,
                              buffer_,
                              ext_file_rec_ );
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      Trace_SYS.Message('Unp_Merge_Extra_Lines___ sqlerrm : '||sqlerrm);
      err_msg_   := SUBSTR('Merge ' || sqlerrm,1,2000);
      row_state_ := '4';
END Unp_Merge_Extra_Lines___;


PROCEDURE Unp_Load_Value_Tab___ (
   err_msg_        IN OUT VARCHAR2,
   row_state_      IN OUT VARCHAR2,
   templ_det_rec_  IN OUT ft_m_det_rec,
   value_tab_      IN OUT ValueTabType,
   unp_value_tab_  IN     ValueTabType,
   buffer_         IN     VARCHAR2,
   record_type_id_ IN     VARCHAR2)
IS
   max_v_                      NUMBER;
BEGIN
   max_v_ := unp_value_tab_.COUNT;  
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      value_tab_ (i_) := NULL;
      IF (NVL(templ_det_rec_.ft_list(i_).record_type_id,'1') = NVL(record_type_id_,'1')) THEN
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
            IF (templ_det_rec_.ft_list(i_).column_no <= max_v_) THEN
               value_tab_ (i_) := unp_value_tab_ (templ_det_rec_.ft_list(i_).column_no);
            END IF;
         ELSE
            value_tab_ (i_) := RTRIM(SUBSTR(buffer_,templ_det_rec_.ft_list(i_).Start_Position,
                                                   templ_det_rec_.ft_list(i_).Length_Position));
         END IF;
         value_tab_ (i_)    := REPLACE(value_tab_ (i_),CHR(39),' ');
         IF (templ_det_rec_.ext_file_rec.Skip_Initial_Blanks = 'TRUE') THEN
            value_tab_ (i_) := LTRIM(value_tab_ (i_));
         END IF;
         IF (templ_det_rec_.ext_file_rec.Skip_All_Blanks = 'TRUE') THEN
            value_tab_ (i_) := REPLACE(value_tab_ (i_),' ');
         END IF;
      ELSE
         value_tab_ (i_) := NULL;
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      Trace_SYS.Message('Unp_Load_Value_Tab___ sqlerrm : '||sqlerrm);
      err_msg_   := SUBSTR('Values ' || sqlerrm,1,2000);
      row_state_ := '4';
END Unp_Load_Value_Tab___;


PROCEDURE Unp_Control_Id_Test___ (
   control_id_abort_    IN OUT VARCHAR2,
   err_msg_             IN OUT VARCHAR2,
   row_state_           IN OUT VARCHAR2,
   templ_det_rec_       IN OUT ft_m_det_rec,
   value_tab_           IN OUT ValueTabType,
   control_id_          IN OUT VARCHAR2,
   record_type_id_      IN     VARCHAR2 )
IS
BEGIN                  
   Client_SYS.Clear_Attr (control_id_);
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      IF (templ_det_rec_.ft_list(i_).record_type_id = record_type_id_ AND
          NVL(templ_det_rec_.ft_list(i_).control_column,'FALSE') = 'TRUE') THEN
         Client_SYS.Add_To_Attr (templ_det_rec_.ft_list(i_).column_id, value_tab_ (i_), control_id_ );
      END IF;
   END LOOP;
   IF (control_id_ IS NOT NULL) THEN
      IF (Ext_File_Identity_API.Check_Exist_Control_Identity ( control_id_ ) ) THEN
         err_msg_   := Language_SYS.Translate_Constant (lu_name_, 'EXTCNTID: Control Identity already exist');
         row_state_ := '4';
         Ext_File_Load_API.Update_State (templ_det_rec_.load_file_id, '5');
         control_id_abort_ := 'TRUE';
      END IF;
   END IF;
END Unp_Control_Id_Test___;


PROCEDURE Unp_Max_Length_Test___ (
   err_msg_             IN OUT VARCHAR2,
   row_state_           IN OUT VARCHAR2,
   templ_det_rec_       IN OUT ft_m_det_rec,
   value_tab_           IN OUT ValueTabType )
IS
BEGIN                  
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      IF (NVL(templ_det_rec_.ft_list(i_).max_length,0) != 0) THEN
         IF (LENGTH(value_tab_ (i_)) > templ_det_rec_.ft_list(i_).max_length) THEN
            err_msg_   := Language_SYS.Translate_Constant (lu_name_, 'EXTMAXL: Max Length :P1 exceeded for column :P2',
                                                           NULL,
                                                           templ_det_rec_.ft_list(i_).max_length,
                                                           templ_det_rec_.ft_list(i_).description);
            row_state_ := '4';
         END IF;
      END IF;
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      Trace_SYS.Message('Unp_Max_Length_Test___ sqlerrm : '||sqlerrm);
      err_msg_   := SUBSTR('Max ' || sqlerrm,1,2000);
      row_state_ := '4';
END Unp_Max_Length_Test___;


PROCEDURE Unp_Column_Function___ (
   err_msg_             IN OUT VARCHAR2,
   row_state_           IN OUT VARCHAR2,
   templ_det_rec_       IN OUT ft_m_det_rec,
   command_rec_         IN OUT Command_Rec )
IS
   result_                     VARCHAR2(4000);
   resultd_                    DATE;
   resultn_                    NUMBER;
   instr_                      NUMBER;
   format_len_                 NUMBER;
   value_len_                  NUMBER;
BEGIN 
   FOR ft_ IN 1 .. templ_det_rec_.max_ft LOOP
      Trace_SYS.Message ('templ_det_rec_.transrec.record_type_id     : '||templ_det_rec_.transrec.record_type_id);
      Trace_SYS.Message ('templ_det_rec_.ft_list(ft_).record_type_id : '||templ_det_rec_.ft_list(ft_).record_type_id);
      IF (templ_det_rec_.transrec.record_type_id = templ_det_rec_.ft_list(ft_).record_type_id AND
          templ_det_rec_.ft_list(ft_).function_detail > 0) THEN
         templ_det_rec_.act_row_no      := templ_det_rec_.ft_list(ft_).row_no;
         templ_det_rec_.act_dest_column := templ_det_rec_.ft_list(ft_).destination_column;
         templ_det_rec_.act_column_id   := templ_det_rec_.ft_list(ft_).column_id;
         templ_det_rec_.act_data_type   := templ_det_rec_.ft_list(ft_).data_type;
         templ_det_rec_.act_date_format := templ_det_rec_.ft_list(ft_).date_format;
         templ_det_rec_.act_record_type := templ_det_rec_.ft_list(ft_).record_type_id;
         templ_det_rec_.act_index       := ft_;
         Trace_SYS.Message ('act_index : '||templ_det_rec_.act_index||' act_column_id : '||templ_det_rec_.act_column_id);
         result_ := Ext_File_Function_Handler_API.Execute_Column_Functions(templ_det_rec_,
                                                                           command_rec_,
                                                                           ft_);
         Trace_SYS.Message ('***** act_column_id   : '||templ_det_rec_.act_column_id||' result_ : '||result_||' dest_column : '||templ_det_rec_.act_dest_column);
         IF (templ_det_rec_.act_data_type = '3') THEN
            BEGIN
               resultd_ := TO_DATE(result_,templ_det_rec_.act_date_format);
            EXCEPTION WHEN OTHERS THEN
               format_len_      :=  INSTR(templ_det_rec_.act_date_format,SUBSTR(TRANSLATE(result_,'0123456789','N'),2,1),1,1);
               value_len_       :=  INSTR(result_,SUBSTR(TRANSLATE(result_,'0123456789','N'),2,1),1,1);
               
               IF (format_len_ IS NULL AND value_len_ IS NULL ) THEN
                  format_len_   :=  INSTR(templ_det_rec_.act_date_format,SUBSTR(TRANSLATE(result_,'0123456789','N'),1,1),1,1);
                  value_len_    :=  INSTR(result_,SUBSTR(TRANSLATE(result_,'0123456789','N'),1,1),1,1);
               END IF;
               
               IF (format_len_   !=  value_len_) THEN
                  Error_SYS.record_general(lu_name_, 'INVDATEFORMAT:  Invalid Date Format :P1, should be in the format :P2',result_,templ_det_rec_.act_date_format);
               ELSE
                  -- Converted date from Client_SYS.date_format_ to Templ_Det_Rec.act_date_format 
                  resultd_ := TO_DATE(result_,Client_SYS.date_format_);
                  result_  := TO_CHAR(resultd_,templ_det_rec_.act_date_format);
                  resultd_ := TO_DATE(result_,templ_det_rec_.act_date_format);
               END IF;
            END;
            Ext_File_Column_Util_API.Put_D_Value ( templ_det_rec_.act_dest_column,
                                                   resultd_,
                                                   templ_det_rec_.transrec);
         ELSIF (templ_det_rec_.act_data_type = '2') THEN
            BEGIN
               resultn_ := TO_NUMBER(result_);
            EXCEPTION
               WHEN OTHERS THEN
                  IF    (INSTR(result_,',') > 0) THEN
                     result_ := REPLACE(result_,',','.');
                  ELSIF (INSTR(result_,',') > 0) THEN
                     result_ := REPLACE(result_,'.',',');
                  END IF;
                  resultn_ := TO_NUMBER(result_);
            END;
            Ext_File_Column_Util_API.Put_N_Value ( templ_det_rec_.act_dest_column,
                                                   resultn_,
                                                   templ_det_rec_.transrec);
         ELSE
             Ext_File_Column_Util_API.Put_C_Value ( templ_det_rec_.act_dest_column,
                                                    result_,
                                                    templ_det_rec_.transrec);
             result_ := SUBSTR(result_,1,2000);
         END IF;
      END IF;
   END LOOP;
   -- Ext_File_Trans_API.Modify (Templ_Det_Rec.transrec);
EXCEPTION
   WHEN OTHERS THEN
      Trace_SYS.Message('Unp_Column_Function___ sqlerrm : '||sqlerrm);
      err_msg_   := SUBSTR('Func ' || sqlerrm,1,2000);
      instr_     := INSTR(err_msg_,':');
      IF (instr_ > 0) THEN
         err_msg_ := SUBSTR(err_msg_,instr_+2);
      END IF;
      row_state_ := '4';
END Unp_Column_Function___;


PROCEDURE Check_Record_Type_Mandatory___ (
   mandatory_abort_       IN OUT VARCHAR2,
   templ_det_rec_         IN OUT ft_m_det_rec,
   record_set_id_         IN     VARCHAR2,
   record_set_no_         IN     NUMBER )
IS
   err_msg_                      VARCHAR2(2000);
BEGIN
   Trace_SYS.Message('Start Check_Record_Type_Mandatory___');
   mandatory_abort_ := 'FALSE';
   FOR i_ IN 1 .. templ_det_rec_.max_gr LOOP
      IF (templ_det_rec_.gr_list(i_).record_set_id = record_set_id_) THEN
         IF (templ_det_rec_.gr_list(i_).mandatory_record = 'TRUE' AND
             templ_det_rec_.gr_list(i_).record_set_count = 0) THEN
            err_msg_ := Language_SYS.Translate_Constant (lu_name_, 'EXTMANDREC: Missing mandatory record type');
            Ext_File_Trans_API.Update_Record_Set_State ( templ_det_rec_.load_file_id,
                                                         record_set_no_,
                                                         '4',
                                                         err_msg_ );
            Ext_File_Load_API.Update_State (templ_det_rec_.load_file_id, '5');
            mandatory_abort_ := 'TRUE';
            EXIT;
         END IF;
      END IF;
   END LOOP;
END Check_Record_Type_Mandatory___;


PROCEDURE Clear_Record_Set_Count_Tab___ (
   templ_det_rec_          IN OUT ft_m_det_rec )
IS
BEGIN
   Trace_SYS.Message('Start Clear_Record_Set_Count_Tab___');
   FOR i_ IN 1 .. templ_det_rec_.max_gr LOOP
      templ_det_rec_.gr_list(i_).Record_Set_Count := 0;
   END LOOP;
END Clear_Record_Set_Count_Tab___;


PROCEDURE Unp_Control_Record_Types___ (
   mandatory_abort_           IN OUT VARCHAR2,
   templ_det_rec_             IN OUT ft_m_det_rec,
   record_type_id_            IN     VARCHAR2,
   record_set_no_             IN OUT NUMBER,
   prev_record_type_id_       IN OUT VARCHAR2,
   g_curr_record_type_order_  IN OUT NUMBER,
   g_prev_record_type_order_  IN OUT NUMBER,
   g_curr_record_set_id_      IN OUT VARCHAR2,
   g_prev_record_set_id_      IN OUT VARCHAR2,
   g_curr_parent_record_type_ IN OUT VARCHAR2,
   err_record_set_id_         IN OUT VARCHAR2)
IS
BEGIN
   g_curr_record_type_order_ := 0;
   FOR i_ IN 1 .. templ_det_rec_.max_gr LOOP
      IF (templ_det_rec_.gr_list(i_).record_type_id = record_type_id_) THEN
         g_curr_record_type_order_  := i_;
         g_curr_record_set_id_      := templ_det_rec_.gr_list(i_).record_set_id;
         g_curr_parent_record_type_ := templ_det_rec_.gr_list(i_).parent_record_type;
         EXIT;
      END IF;
   END LOOP;
   IF (record_type_id_ IS NOT NULL) THEN
      IF (NVL(prev_record_type_id_,' ') = ' ') THEN
         -- First record in the file
         g_prev_record_type_order_  := g_curr_record_type_order_;
         prev_record_type_id_       := record_type_id_;
         g_prev_record_set_id_      := g_curr_record_set_id_;
         record_set_no_             := 1;
         templ_det_rec_.gr_list(g_curr_record_type_order_).record_set_count := templ_det_rec_.gr_list(g_curr_record_type_order_).record_set_count + 1;
      ELSE
         IF (g_prev_record_set_id_ != g_curr_record_set_id_) THEN
            -- Here we have a new record set id
            -- First we have to check if previous record set was missing any mandatory records
            Check_Record_Type_Mandatory___ (mandatory_abort_,
                                            templ_det_rec_,
                                            g_prev_record_set_id_,
                                            record_set_no_);
            IF (mandatory_abort_ != 'TRUE') THEN
               g_prev_record_type_order_ := g_curr_record_type_order_;
               prev_record_type_id_      := record_type_id_;
               g_prev_record_set_id_     := g_curr_record_set_id_;
               record_set_no_            := record_set_no_ + 1;
               Clear_Record_Set_Count_Tab___ ( templ_det_rec_ );
               templ_det_rec_.gr_list(g_curr_record_type_order_).record_set_count := templ_det_rec_.gr_list(g_curr_record_type_order_).record_set_count + 1;
            END IF;
         ELSE
            IF (NVL(g_curr_parent_record_type_,' ') = ' ' ) THEN
            -- Here we have a new record set with same record set id
            -- First we have to check if previous record set was missing any mandatory records
               Check_Record_Type_Mandatory___ (mandatory_abort_,
                                               templ_det_rec_,
                                               g_prev_record_set_id_,
                                               record_set_no_);
               IF (mandatory_abort_ != 'TRUE') THEN
                  g_prev_record_type_order_ := g_curr_record_type_order_;
                  prev_record_type_id_      := record_type_id_;
                  g_prev_record_set_id_     := g_curr_record_set_id_;
                  record_set_no_            := record_set_no_ + 1;
                  IF (templ_det_rec_.ext_file_rec.allow_record_set_repeat = 'FALSE') THEN
                     -- It is not alowed to have more than one record set with same record set id
                     err_record_set_id_     := g_curr_record_set_id_;
                  END IF;
                  Clear_Record_Set_Count_Tab___ ( templ_det_rec_ );
               END IF;
            END IF;
            templ_det_rec_.gr_list(g_curr_record_type_order_).Record_Set_Count := templ_det_rec_.gr_list(g_curr_record_type_order_).record_set_count + 1;
         END IF;
      END IF;
   END IF;
END Unp_Control_Record_Types___;


PROCEDURE Control_In_Ext_File___ (
   err_msg_                IN OUT VARCHAR2,
   use_line_               IN OUT VARCHAR2,
   skipped_line_           IN OUT VARCHAR2,
   invalid_line_           IN OUT VARCHAR2,
   record_type_id_         IN OUT VARCHAR2,
   no_of_lines_            IN OUT NUMBER,
   buffer_                 IN OUT VARCHAR2,
   templ_det_rec_          IN OUT ft_m_det_rec,
   unp_value_tab_          IN     ValueTabType )
IS
   max_u_                         NUMBER;
   control_test_                  VARCHAR2(200);
   control_testx_                 VARCHAR2(200);
   file_test_                     VARCHAR2(200);
   file_testx_                    VARCHAR2(200);
   use_control_                   VARCHAR2(5) := 'FALSE';
   do_control_                    VARCHAR2(5) := 'FALSE';
BEGIN
   Trace_SYS.Message('Start Control_In_Ext_File___');
   max_u_        := unp_value_tab_.COUNT;
   control_test_ := NULL;
   file_test_    := NULL;
   skipped_line_ := 'FALSE';
   invalid_line_ := 'FALSE';
   FOR i_ IN 1 .. templ_det_rec_.max_cn LOOP
      use_control_ := 'FALSE';
      IF (NVL(templ_det_rec_.cn_list(i_).destination_column,' ') = ' ') THEN
         use_control_ := 'TRUE';
      END IF;
      IF (use_control_ = 'TRUE') THEN
         file_testx_       := ' ';
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
            IF (NVL(templ_det_rec_.cn_list(i_).column_no,0) > 0 AND
                NVL(templ_det_rec_.cn_list(i_).column_no,0) <= max_u_) THEN
               file_testx_ := unp_value_tab_ (templ_det_rec_.cn_list(i_).column_no);
            ELSIF (NVL(templ_det_rec_.cn_list(i_).start_position,0) > 0 AND
                   NVL(templ_det_rec_.cn_list(i_).length_position,0) > 0) THEN
               file_testx_ := SUBSTR(buffer_,templ_det_rec_.cn_list(i_).start_position,
                                             templ_det_rec_.cn_list(i_).length_position);
            END IF;
         ELSE
            IF (NVL(templ_det_rec_.cn_list(i_).start_position,0) > 0 AND
                NVL(templ_det_rec_.cn_list(i_).length_position,0) > 0) THEN
               file_testx_ := SUBSTR(buffer_,templ_det_rec_.cn_list(i_).start_position,
                                             templ_det_rec_.cn_list(i_).length_position);
            END IF;
         END IF;
         IF (file_test_ IS NULL) THEN
            file_test_ := file_testx_;
         ELSE
            file_test_ := file_test_ || file_testx_;
         END IF;
         control_testx_ := templ_det_rec_.cn_list(i_).control_string;
         --
         IF (control_testx_ = '<NUM>') THEN
            IF (Ext_File_Message_API.Is_Column_Numeric (file_testx_)) THEN
               control_testx_ := file_testx_;
            END IF;
         END IF;
         IF (control_testx_ = '<NOTNUM>') THEN
            IF (NOT Ext_File_Message_API.Is_Column_Numeric (file_testx_)) THEN
               control_testx_ := file_testx_;
            END IF;
         END IF;
         IF (control_testx_ = '<NOTNULL>') THEN
            IF (LTRIM(RTRIM(file_testx_)) IS NOT NULL) THEN
               control_testx_ := file_testx_;
            END IF;
         END IF;
         IF (control_testx_ = '<NULL>') THEN
            IF (LTRIM(RTRIM(file_testx_)) IS NULL) THEN
               control_testx_ := file_testx_;
            END IF;
         END IF;
         --
         IF (control_test_ IS NULL) THEN
            control_test_ := control_testx_;
         ELSE
            control_test_ := control_test_ || control_testx_;
         END IF;
      END IF;
      IF (i_ = templ_det_rec_.max_cn) THEN
         do_control_ := 'TRUE';
      ELSIF (templ_det_rec_.cn_list(i_).group_no != templ_det_rec_.cn_list(i_+1).group_no) THEN
         do_control_ := 'TRUE';
      ELSE
         do_control_ := 'FALSE';
      END IF;
      IF (do_control_ = 'TRUE') THEN
         IF (templ_det_rec_.cn_list(i_).condition = '1') THEN  -- Skip Test
            IF (control_test_ = file_test_) THEN
               err_msg_             := Language_SYS.Translate_Constant (lu_name_, 'EXTCNTSKP: Skipped Caused By Control Rule');
               use_line_            := 'FALSE';
               skipped_line_        := 'TRUE';
               record_type_id_      := NULL;
               EXIT;
            ELSE
               err_msg_             := NULL;
               use_line_            := 'TRUE';
               skipped_line_        := 'FALSE';
               record_type_id_      := templ_det_rec_.cn_list(i_).record_type_id;
               no_of_lines_         := templ_det_rec_.cn_list(i_).no_of_lines;
            END IF;
         ELSIF (templ_det_rec_.cn_list(i_).condition = '2') THEN  -- Satisfy Test
            IF (control_test_ = file_test_) THEN
               err_msg_             := NULL;
               use_line_            := 'TRUE';
               skipped_line_        := 'FALSE';
               record_type_id_      := templ_det_rec_.cn_list(i_).record_type_id;
               no_of_lines_         := templ_det_rec_.cn_list(i_).no_of_lines;
               EXIT;
            ELSE
               err_msg_             := Language_SYS.Translate_Constant (lu_name_, 'EXTCNTSAT: Control Rule Not Satisfied');
               use_line_            := 'FALSE';
               skipped_line_        := 'TRUE';
               record_type_id_      := NULL;
            END IF;
         ELSE
            use_line_       := 'FALSE';
            record_type_id_ := NULL;
         END IF;
         IF (use_line_ = 'TRUE' AND
             templ_det_rec_.cn_list(i_).condition = '2') THEN
            EXIT;
         END IF;
         control_test_ := NULL;
         file_test_    := NULL;
      END IF;
      IF (i_ = templ_det_rec_.max_cn) THEN
         EXIT;
      END IF;
   END LOOP;
END Control_In_Ext_File___;


PROCEDURE Control_Out_Ext_File___ (
   err_msg_                IN OUT VARCHAR2,
   use_line_               IN OUT VARCHAR2,
   skipped_line_           IN OUT VARCHAR2,
   invalid_line_           IN OUT VARCHAR2,
   record_type_id_         IN OUT VARCHAR2,
   templ_det_rec_          IN OUT ft_m_det_rec )
IS
   control_test_             VARCHAR2(200);
   file_test_                VARCHAR2(200);
   file_testx_               VARCHAR2(200);
   use_control_              VARCHAR2(5) := 'FALSE';
   do_control_               VARCHAR2(5) := 'FALSE';
BEGIN
   Trace_SYS.Message('Start Control_Out_Ext_File___');
   control_test_ := NULL;
   file_test_    := NULL;
   skipped_line_ := 'FALSE';
   invalid_line_ := 'FALSE';
   FOR i_ IN 1 .. templ_det_rec_.max_cn LOOP
      use_control_ := 'FALSE';
      IF (NVL(templ_det_rec_.cn_list(i_).destination_column,' ') != ' ') THEN
         use_control_ := 'TRUE';
      END IF;
      IF (use_control_ = 'TRUE') THEN
         file_testx_       := ' ';
         IF (NVL(templ_det_rec_.cn_list(i_).destination_column,' ') != ' ') THEN
            file_testx_ := Ext_File_Column_Util_API.Return_C_Value ( templ_det_rec_.cn_list(i_).destination_column,
                                                                     templ_det_rec_.transrec );
         END IF;
         IF (file_test_ IS NULL) THEN
            file_test_ := file_testx_;
         ELSE
            file_test_ := file_test_ || file_testx_;
         END IF;
         IF (control_test_ IS NULL) THEN
            control_test_ := templ_det_rec_.cn_list(i_).control_string;
         ELSE
            control_test_ := control_test_ || templ_det_rec_.cn_list(i_).control_string;
         END IF;
         IF (i_ = templ_det_rec_.max_cn) THEN
            do_control_ := 'TRUE';
         ELSIF (templ_det_rec_.cn_list(i_).group_no != templ_det_rec_.cn_list(i_+1).group_no) THEN
            do_control_ := 'TRUE';
         ELSE
            do_control_ := 'FALSE';
         END IF;
         IF (do_control_ = 'TRUE') THEN
            IF (templ_det_rec_.cn_list(i_).condition = '1') THEN  -- Skip Test
               IF (control_test_ = file_test_) THEN
                  err_msg_             := Language_SYS.Translate_Constant (lu_name_, 'EXTCNTSKP: Skipped Caused By Control Rule');
                  use_line_            := 'FALSE';
                  skipped_line_        := 'TRUE';
                  record_type_id_      := NULL;
                  EXIT;
               ELSE
                  err_msg_             := NULL;
                  use_line_            := 'TRUE';
                  skipped_line_        := 'FALSE';
                  record_type_id_      := templ_det_rec_.cn_list(i_).record_type_id;
               END IF;
            ELSIF (templ_det_rec_.cn_list(i_).condition = '2') THEN  -- Satisfy Test
               IF (control_test_ = file_test_) THEN
                  err_msg_             := NULL;
                  use_line_            := 'TRUE';
                  skipped_line_        := 'FALSE';
                  record_type_id_      := templ_det_rec_.cn_list(i_).record_type_id;
                  EXIT;
               ELSE
                  err_msg_             := Language_SYS.Translate_Constant (lu_name_, 'EXTCNTSAT: Control Rule Not Satisfied');
                  use_line_            := 'FALSE';
                  skipped_line_        := 'TRUE';
                  record_type_id_      := NULL;
               END IF;
            ELSE
               use_line_       := 'FALSE';
            END IF;
            IF (use_line_ = 'TRUE') THEN
               EXIT;
            END IF;
            control_test_ := NULL;
            file_test_    := NULL;
         END IF;
         IF (i_ = templ_det_rec_.max_cn) THEN
            EXIT;
         END IF;
      END IF;
   END LOOP;
END Control_Out_Ext_File___;


PROCEDURE Tab_To_Table___ (
   err_msg_             IN OUT VARCHAR2,
   row_state_           IN OUT VARCHAR2,
   templ_det_rec_       IN OUT ft_m_det_rec,
   value_tab_           IN ValueTabType )
IS
   value_                    VARCHAR2(4000);
   max_v_                    NUMBER         := 0;  
   col_upd_                  NUMBER         := 0;
   index_                    NUMBER;
   year_                     NUMBER;
   format_len_               NUMBER;
   value_len_                NUMBER;
   number_value_             NUMBER;
   date_value_               DATE;
   date_format_error_        EXCEPTION;
   invalid_year_             EXCEPTION;
BEGIN
   Trace_SYS.Message ('Start Tab_To_Table___ max_ft_ : '||templ_det_rec_.max_ft||' max_v_ : '||max_v_);
   max_v_  := value_tab_.COUNT;
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      index_ := i_;
      IF (i_ > max_v_) THEN
         EXIT;
      END IF;
      value_ := value_tab_(i_);
      Trace_SYS.Message ('i_ : '||i_||' value_tab_(i_) : '||value_tab_(i_));
      IF (templ_det_rec_.ft_list(i_).data_type IN ('2','3')) THEN
         IF (value_ = '-') THEN
            value_ := NULL;
         END IF;
      END IF;
      --
      IF (value_ IS NOT NULL) THEN
         IF (templ_det_rec_.ft_list(i_).destination_column IS NOT NULL) THEN
            col_upd_ := col_upd_ + 1;
         END IF;
         --
         -- Date Format
         IF (templ_det_rec_.ft_list(i_).data_type = '3') THEN
            IF (templ_det_rec_.ft_list(i_).date_format IS NULL) THEN
               RAISE unp_date_format_error;
            END IF;
            IF (templ_det_rec_.ext_file_rec.date_nls_calendar IS NOT NULL) THEN
				   date_value_ := Ext_File_Column_Util_API.Str_To_Date(value_,
                                                                   templ_det_rec_.ft_list(i_).date_format,
                                                                   templ_det_rec_.ext_file_rec.date_nls_calendar);
            ELSE
               BEGIN
                  date_value_ := TO_DATE(value_,
                                         templ_det_rec_.ft_list(i_).date_format);
               EXCEPTION WHEN OTHERS THEN
                  format_len_      :=  INSTR(templ_det_rec_.ft_list(i_).date_format,SUBSTR(TRANSLATE(value_,'0123456789','N'),2,1),1,1);
                  value_len_       :=  INSTR(value_,SUBSTR(TRANSLATE(value_,'0123456789','N'),2,1),1,1);
                        
                  IF (format_len_ IS NULL AND value_len_ IS NULL ) THEN
                     format_len_   :=  INSTR(templ_det_rec_.ft_list(i_).date_format,SUBSTR(TRANSLATE(value_,'0123456789','N'),1,1),1,1);
                     value_len_    :=  INSTR(value_,SUBSTR(TRANSLATE(value_,'0123456789','N'),1,1),1,1);
                  END IF;
      
                  IF (format_len_ != value_len_) THEN
                     IF (NVL(INSTR(value_, ':'),0) > 0 OR INSTR(templ_det_rec_.ft_list(i_).date_format, ':') >0) THEN
                        RAISE date_format_error_;
                     ELSE
                        Error_SYS.record_general(lu_name_, 'INVDATEFORMAT: Invalid Date Format :P1, should be in the format :P2',value_,templ_det_rec_.ft_list(i_).date_format);
                     END IF;
                     
                  ELSE
                     date_value_ := TO_DATE(value_,
                                            templ_det_rec_.ft_list(i_).date_format);
                  END IF;
               END;
            END IF;
            
            year_ := TO_NUMBER(TO_CHAR(date_value_,'YYYY'));
            IF (year_ < 1900) THEN               
               IF NVL(INSTR(value_, ':'),0) > 0 THEN
                  RAISE invalid_year_;
               ELSE 
                  Error_SYS.record_general(lu_name_, 'INVDATEFORMATYEAR: Date :P1 is not allowed; validate year :P2', value_, year_);
               END IF;
            END IF;
            
            Ext_File_Column_Util_API.Put_D_Value ( templ_det_rec_.ft_list(i_).destination_column,
                                                   date_value_,
                                                   templ_det_rec_.transrec);
         --
         -- Number Format
         ELSIF (templ_det_rec_.ft_list(i_).data_type = '2') THEN
            IF (templ_det_rec_.ft_list(i_).decimal_symbol IS NOT NULL) THEN
               number_value_ := Ext_File_Column_Util_API.Str_To_Number ( value_, 
                                                                         templ_det_rec_.ft_list(i_).decimal_symbol );
            ELSIF (templ_det_rec_.ft_list(i_).denominator IS NOT NULL) THEN
               number_value_ := Ext_File_Column_Util_API.Str_To_Number2 ( value_, 
                                                                          templ_det_rec_.ft_list(i_).denominator );
            ELSE
               number_value_ := value_;
            END IF;
            Ext_File_Column_Util_API.Put_N_Value ( templ_det_rec_.ft_list(i_).destination_column,
                                                   number_value_,
                                                   templ_det_rec_.transrec);
         --
         -- String Format
         ELSE
             Ext_File_Column_Util_API.Put_C_Value ( templ_det_rec_.ft_list(i_).destination_column,
                                                    value_,
                                                    templ_det_rec_.transrec);
         END IF;
         --
      END IF;
   END LOOP;

   col_upd_ := col_upd_ + 1;
EXCEPTION
   WHEN unp_date_format_error THEN
      err_msg_   := Language_SYS.Translate_Constant(lu_name_,'DATEFORMERR: No Date Format Specified on Column or File Template');
      row_state_ := '4';
   WHEN date_format_error_ THEN
      err_msg_ := Language_SYS.Translate_Constant(lu_name_, 'INVDATEFORMATPART1: Invalid Date Format ');
      err_msg_ := err_msg_ || value_;
      err_msg_ := err_msg_ || Language_SYS.Translate_Constant(lu_name_, 'INVDATEFORMATPART2: , should be in the format ');
      err_msg_ := err_msg_ || templ_det_rec_.ft_list(index_).date_format;
      row_state_ := '4';
   WHEN invalid_year_ THEN
      err_msg_ := Language_SYS.Translate_Constant(lu_name_, 'INVDATEFORMATYEAR1: Date ');
      err_msg_ := err_msg_ || value_ || ' ';
      err_msg_ := err_msg_ || Language_SYS.Translate_Constant(lu_name_, 'INVDATEFORMATYEAR2: is not allowed; validate year '|| year_);
      row_state_ := '4';
   WHEN OTHERS THEN
      Trace_SYS.Message('Tab_To_Table___ sqlerrm : '||sqlerrm);
      --err_msg_   := SUBSTR('Tab ' || sqlerrm,1,2000);
      err_msg_   := SUBSTR(SUBSTR(sqlerrm,INSTR(sqlerrm,':',-1)+1),1,2000);
      row_state_ := '4';
END Tab_To_Table___;


PROCEDURE Col_To_Line___ (
   templ_det_rec_          IN OUT ft_m_det_rec,
   record_type_id_        IN     VARCHAR2,
   first_line_            IN OUT VARCHAR2 )
IS
   oi_                       NUMBER         := 0;
   row_no_                   NUMBER;
   error_msg_                VARCHAR2(2000);
   file_line_                VARCHAR2(32000);
   char_value_               VARCHAR2(4000);
   number_value_             NUMBER;
   date_value_               DATE;
   first_                    VARCHAR2(5)  := 'TRUE';
   separator_id_             VARCHAR2(20);
BEGIN
   Trace_SYS.Message('Start Col_To_Line___');
   --
   separator_id_                         := Ext_File_Template_API.Get_Separator_Id (templ_det_rec_.ext_file_rec.file_template_id);
   templ_det_rec_.transrec.use_line       := 'TRUE';
   templ_det_rec_.transrec.record_type_id := record_type_id_;
   templ_det_rec_.transrec.error_text     := NULL;
   templ_det_rec_.transrec.row_state      := '7';
   templ_det_rec_.transrec.file_line      := NULL;
   --
   IF (templ_det_rec_.transrec.row_no = ROUND(templ_det_rec_.transrec.row_no)) THEN
      --
      IF (first_line_ = 'TRUE' AND
          NVL(templ_det_rec_.ext_file_rec.create_header,'FALSE') = 'TRUE') THEN
         file_line_ := NULL;
         oi_        := 0;
         FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
            IF (NVL(templ_det_rec_.ft_list(i_).record_type_id,'1') = 
                NVL(templ_det_rec_.transrec.record_type_id,'1')) THEN
               char_value_ := templ_det_rec_.ft_list(i_).description;
               IF (templ_det_rec_.ext_file_rec.text_qualifier IS NOT NULL) THEN
                  char_value_ := templ_det_rec_.ext_file_rec.text_qualifier || 
                                 char_value_ || 
                                 templ_det_rec_.ext_file_rec.text_qualifier;
               END IF;
               IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
                  IF (templ_det_rec_.ft_list(i_).column_no IS NOT NULL) THEN
                  IF (templ_det_rec_.ft_list(i_).column_no > oi_) THEN
                     LOOP
                        oi_ := oi_ + 1;
                        IF (oi_ >= templ_det_rec_.ft_list(i_).column_no) THEN
                           EXIT;
                        END IF;
                        char_value_ := templ_det_rec_.ext_file_rec.field_separator || 
                                       char_value_;
                     END LOOP;
                  END IF;
                  oi_ := templ_det_rec_.ft_list(i_).column_no;
                  IF (file_line_ IS NULL) THEN
                     file_line_ := char_value_ || templ_det_rec_.ext_file_rec.field_separator;
                  ELSE
                     file_line_ := file_line_ || char_value_ || templ_det_rec_.ext_file_rec.Field_Separator;
                  END IF;
                  END IF;
               ELSE
                  IF (templ_det_rec_.ft_list(i_).length_position IS NOT NULL) THEN
                     IF (LENGTH(char_value_) > templ_det_rec_.ft_list(i_).length_position) THEN
                        char_value_ := SUBSTR(char_value_,
                                              1,
                                              templ_det_rec_.ft_list(i_).length_position);
                     ELSE
                        IF (templ_det_rec_.ft_list(i_).data_type = '2') THEN
                           char_value_ := LPAD(char_value_,
                                               templ_det_rec_.ft_list(i_).length_position,
                                               NVL(templ_det_rec_.ext_file_rec.number_out_fill_value,' '));
                        ELSE
                           char_value_ := RPAD(char_value_,
                                               templ_det_rec_.ft_list(i_).length_position,' ');
                        END IF;
                     END IF;
                     IF (file_line_ IS NOT NULL) THEN
                        IF (LENGTH(file_line_) > (templ_det_rec_.ft_list(i_).start_position-1)) THEN
                           file_line_ := SUBSTR(file_line_,
                                                1,
                                                (templ_det_rec_.ft_list(i_).start_position-1));
                        ELSE
                           file_line_ := RPAD(file_line_,
                                              (templ_det_rec_.ft_list(i_).start_position-1),' ');
                        END IF;
                     END IF;
                     IF (file_line_ IS NULL) THEN
                        IF (templ_det_rec_.ft_list(i_).start_position > 1) THEN
                           file_line_ := RPAD(' ',
                                              (templ_det_rec_.ft_list(i_).start_position-1),' ') || char_value_;
                        ELSE
                           file_line_ := char_value_;
                        END IF;
                     ELSE
                        file_line_ := file_line_ || char_value_;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
         
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP' AND NVL(templ_det_rec_.ext_file_rec.remove_end_separator,'FALSE') = 'TRUE') THEN
            IF (substr(file_line_ , -1* NVL(LENGTH(templ_det_rec_.ext_file_rec.Field_Separator),1)) = templ_det_rec_.ext_file_rec.Field_Separator ) THEN
               file_line_ := SUBSTR(file_line_,1,LENGTH(file_line_) - LENGTH(templ_det_rec_.ext_file_rec.Field_Separator));
            END IF;
         END IF;
         
         row_no_ := templ_det_rec_.transrec.row_no - 0.5;
         IF (Ext_File_Trans_API.Check_Exist_File_Trans ( templ_det_rec_.transrec.load_file_id, row_no_ )) THEN
            Ext_File_Trans_API.Update_File_Line ( templ_det_rec_.transrec.load_file_id,
                                                  row_no_,
                                                  file_line_ );
         ELSE
            Ext_File_Trans_API.Insert_File_Trans ( templ_det_rec_.transrec.load_file_id,
                                                   row_no_,
                                                   file_line_,
                                                   '7',
                                                   templ_det_rec_.transrec.record_type_id );
         END IF;
      END IF;
      --
      first_line_ := 'FALSE';
      file_line_  := NULL;
      oi_         := 0;
      FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
         IF (NVL(templ_det_rec_.ft_list(i_).record_type_id,'1') = 
             NVL(templ_det_rec_.transrec.record_type_id,'1')) THEN
            IF (first_ = 'TRUE') THEN
               first_ := 'FALSE';
            END IF;
            IF (templ_det_rec_.ft_list(i_).destination_column IS NOT NULL) THEN
               IF (templ_det_rec_.ft_list(i_).data_type = '3') THEN
                  date_value_ := Ext_File_Column_Util_API.Return_D_Value ( templ_det_rec_.ft_list(i_).destination_column,
                                                                           templ_det_rec_.transrec );
                  char_value_ := Ext_File_Column_Util_API.Date_To_Str ( date_value_,
                                                                        templ_det_rec_.ft_list(i_).date_format );
               -- Number Format
               ELSIF (templ_det_rec_.ft_list(i_).data_type = '2') THEN
                  number_value_ := Ext_File_Column_Util_API.Return_N_Value ( templ_det_rec_.ft_list(i_).destination_column,
                                                                             templ_det_rec_.transrec );
                  IF (templ_det_rec_.ft_list(i_).decimal_symbol IS NOT NULL) THEN
                     char_value_ := Ext_File_Column_Util_API.Number_To_Str ( number_value_,
                                                                             templ_det_rec_.ft_list(i_).decimal_symbol );
                  ELSIF (templ_det_rec_.ft_list(i_).denominator IS NOT NULL) THEN
                     char_value_ := Ext_File_Column_Util_API.Number_To_Str2 ( number_value_,
                                                                              templ_det_rec_.ft_list(i_).denominator );
                  ELSE
                     char_value_ := TO_CHAR(number_value_);
                  END IF;
               -- String Format
               ELSE
                  char_value_ := Ext_File_Column_Util_API.Return_C_Value ( templ_det_rec_.ft_list(i_).destination_column,
                                                                           templ_det_rec_.transrec );
               END IF;
            END IF;
            --
            IF (templ_det_rec_.ext_file_rec.text_qualifier IS NOT NULL) THEN
               char_value_ := templ_det_rec_.ext_file_rec.text_qualifier || 
                              char_value_ || 
                  templ_det_rec_.ext_file_rec.text_qualifier;
            END IF;
            --
            IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
               IF (templ_det_rec_.ft_list(i_).column_no IS NOT NULL) THEN
               IF (templ_det_rec_.ft_list(i_).column_no > oi_) THEN
                  LOOP
                     oi_ := oi_ + 1;
                     IF (oi_ >= templ_det_rec_.ft_list(i_).column_no) THEN
                        EXIT;
                     END IF;
                     char_value_ := templ_det_rec_.ext_file_rec.Field_Separator || char_value_;
                  END LOOP;
               END IF;
               oi_ := templ_det_rec_.ft_list(i_).column_no;
               file_line_ := file_line_ || 
                             char_value_ || 
                             templ_det_rec_.ext_file_rec.Field_Separator;
               END IF;
            ELSE
               IF (templ_det_rec_.ft_list(i_).length_position IS NOT NULL) THEN
                  IF (LENGTH(char_value_) > templ_det_rec_.ft_list(i_).length_position) THEN
                     char_value_ := SUBSTR(char_value_,
                                           1,
                                           templ_det_rec_.ft_list(i_).length_position);
                  ELSE
                     IF (templ_det_rec_.ft_list(i_).Data_Type = '2') THEN
                        char_value_ := LPAD(char_value_,
                                            templ_det_rec_.ft_list(i_).length_position,
                                            NVL(templ_det_rec_.ext_file_rec.number_out_fill_value,' '));
                     ELSE
                        char_value_ := RPAD(NVL(char_value_,' '),
                                            templ_det_rec_.ft_list(i_).length_position,
                                            ' ');
                     END IF;
                  END IF;
                  IF (file_line_ IS NOT NULL) THEN
                     IF (LENGTH(file_line_) > (templ_det_rec_.ft_list(i_).start_position-1)) THEN
                        file_line_ := SUBSTR(file_line_,
                                             1,
                                             (templ_det_rec_.ft_list(i_).start_position-1));
                     ELSE
                        file_line_ := RPAD(file_line_,
                                           (templ_det_rec_.ft_list(i_).start_position-1),
                                           ' ');
                     END IF;
                  END IF;
                  IF (file_line_ IS NULL) THEN
                     IF (templ_det_rec_.ft_list(i_).start_position > 1) THEN
                        file_line_ := RPAD(' ',
                                           (templ_det_rec_.ft_list(i_).start_position-1),' ') || char_value_;
                     ELSE
                        file_line_ := char_value_;
                     END IF;
                  ELSE
                     file_line_ := file_line_ || char_value_;
                  END IF;
               END IF;
            END IF;
         END IF;
         --
      END LOOP;
      IF (separator_id_ = 'LF') THEN
         file_line_ := SUBSTR(file_line_,1,LENGTH(file_line_)-2);
      ELSIF (templ_det_rec_.ext_file_rec.file_format = 'SEP' AND NVL(templ_det_rec_.ext_file_rec.remove_end_separator,'FALSE') = 'TRUE') THEN
         file_line_ := SUBSTR(file_line_,1,LENGTH(file_line_) - LENGTH(templ_det_rec_.ext_file_rec.Field_Separator));
      END IF;
      IF (LENGTH(file_line_) > 4000) THEN
         RAISE to_long_out_line;
      END IF;
      templ_det_rec_.transrec.file_line := file_line_;
      templ_det_rec_.transrec.file_line      := file_line_;
      Ext_File_Trans_API.Modify (templ_det_rec_.transrec);
      --
   END IF;
EXCEPTION
   WHEN to_long_out_line THEN
      error_msg_ := Language_SYS.Translate_Constant (lu_name_, 'EXTTOLOUT: The line will be larger than 4000 char');
      first_line_ := 'FALSE';
      Ext_File_Trans_API.Update_Row_State (templ_det_rec_.transrec.load_file_id,
                                           templ_det_rec_.transrec.row_no,
                                           '4',
                                           error_msg_);
   WHEN OTHERS THEN
      error_msg_ := Language_SYS.Translate_Constant (lu_name_, 'EXTGENUNP: General Unpacking Error');
      first_line_ := 'FALSE';
      Ext_File_Trans_API.Update_Row_State (templ_det_rec_.transrec.load_file_id,
                                           templ_det_rec_.transrec.row_no,
                                           '4',
                                           error_msg_);
END Col_To_Line___;


PROCEDURE Create_Type_Params___ (
   table_name_      IN VARCHAR2,
   column_name_     IN VARCHAR2,
   file_type_       IN VARCHAR2,
   param_no_        IN NUMBER,
   data_type_       IN VARCHAR2,
   description_     IN VARCHAR2,
   lov_view_        IN VARCHAR2 ) 
IS
   paramrec_           Ext_File_Type_Param_Tab%ROWTYPE;
BEGIN
   paramrec_.file_type         := file_type_;
   paramrec_.param_no          := param_no_;
   paramrec_.param_id          := column_name_;
   IF (description_ IS NULL) THEN
      paramrec_.description    := Get_View_Column_Description ( table_name_, column_name_ );
   ELSE
      paramrec_.description    := description_;
   END IF;
   paramrec_.lov_view          := lov_view_;
   paramrec_.enumerate_method  := NULL;
   paramrec_.validate_method   := NULL;
   paramrec_.browsable_field   := 'FALSE';
   paramrec_.help_text         := NULL;
   paramrec_.data_type         := data_type_;
   paramrec_.rowversion        := SYSDATE;
   Ext_File_Type_Param_API.Insert_Record ( paramrec_ );
END Create_Type_Params___;


PROCEDURE Create_Per_Set_Params___ (
   file_type_         IN VARCHAR2,
   value_             IN VARCHAR2,
   param_no_          IN NUMBER,
   set_id_            IN VARCHAR2,
   mandatory_param_   IN VARCHAR2,
   show_at_load_      IN VARCHAR2,
   inputable_at_load_ IN VARCHAR2 )
IS
   parampsrec_         Ext_Type_Param_Per_Set_Tab%ROWTYPE;
BEGIN
   parampsrec_.file_type         := file_type_;
   parampsrec_.param_no          := param_no_;
   parampsrec_.set_id            := set_id_;
   parampsrec_.default_value     := value_;
   parampsrec_.mandatory_param   := mandatory_param_;
   parampsrec_.show_at_load      := show_at_load_;
   parampsrec_.inputable_at_load := inputable_at_load_;
   parampsrec_.rowversion        := SYSDATE;
   Ext_Type_Param_Per_Set_API.Insert_Record ( parampsrec_ );
END Create_Per_Set_Params___;


PROCEDURE Find_Batch_Par_Key___ (
   parameter_string_ IN  VARCHAR2,
   par_key_          OUT VARCHAR2 )
IS
   length_par_           NUMBER;
   i_                    NUMBER := 0;
BEGIN
   length_par_ := LENGTH(parameter_string_);
   LOOP
      i_ := i_ + 1;
      IF (i_ > length_par_) THEN
         EXIT;
      END IF;
      IF (SUBSTR(parameter_string_,i_,1) IN ('0','1','2','3','4','5','6','7','8','9')) THEN
         IF (par_key_ IS NULL) THEN
            par_key_ := SUBSTR(parameter_string_,i_,1);
         ELSE
            par_key_ := par_key_ || SUBSTR(parameter_string_,i_,1);
         END IF;
      END IF;
   END LOOP;
END Find_Batch_Par_Key___;


PROCEDURE Desc_Col_To_Line___ (
   file_line1_            OUT    VARCHAR2,
   file_line2_            OUT    VARCHAR2,
   templ_det_rec_         IN OUT ft_m_det_rec,
   d_desc_value_tab_      IN OUT CharSmallTabType,
   record_type_id_        IN     VARCHAR2)
IS
   v_                        NUMBER         := 64;
   file_line_                VARCHAR2(4000);
   char_value_               VARCHAR2(200);
   number_value_             NUMBER;
   date_value_               DATE;
   first_                    VARCHAR2(5)  := 'TRUE';   
BEGIN  
	Trace_SYS.Message('Start Desc_Col_To_Line___');
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      IF (NVL(templ_det_rec_.ft_list(i_).Record_Type_Id,'1') = NVL(record_type_id_,'1')) THEN
         char_value_ := templ_det_rec_.ft_list(i_).description;
         IF (templ_det_rec_.ext_file_rec.text_qualifier IS NOT NULL) THEN
            char_value_ := templ_det_rec_.ext_file_rec.text_qualifier || 
                           char_value_ || 
                           templ_det_rec_.ext_file_rec.text_qualifier;
         END IF;
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
            IF (file_line_ IS NULL) THEN
               file_line_ := char_value_ || 
                             templ_det_rec_.ext_file_rec.field_separator;
            ELSE
               file_line_ := file_line_ || 
                             char_value_ || 
                             templ_det_rec_.ext_file_rec.field_separator;
            END IF;
         ELSE
            IF (LENGTH(char_value_) > templ_det_rec_.ft_list(i_).length_position) THEN
               char_value_ := SUBSTR(char_value_,
                                     1,
                                     templ_det_rec_.ft_list(i_).length_position);
            ELSE
               IF (templ_det_rec_.ft_list(i_).data_type = '2') THEN
                  char_value_ := LPAD(char_value_,
                                      templ_det_rec_.ft_list(i_).length_position,
                                      NVL(templ_det_rec_.ext_file_rec.number_out_fill_value,' '));
               ELSE
                  char_value_ := RPAD(char_value_,
                                      templ_det_rec_.ft_list(i_).length_position,
                                      ' ');
               END IF;
            END IF;
            IF (file_line_ IS NOT NULL) THEN
               IF (NVL(LENGTH(file_line_),0) > 
                   (templ_det_rec_.ft_list(i_).start_position-1)) THEN
                  file_line_ := SUBSTR(file_line_,
                                       1,
                                       (templ_det_rec_.ft_list(i_).start_position-1));
               ELSE
                  file_line_ := RPAD(file_line_,
                                     (templ_det_rec_.ft_list(i_).start_position-1),
                                     ' ');
               END IF;
            END IF;
            IF (file_line_ IS NULL) THEN
               IF (templ_det_rec_.ft_list(i_).start_position > 1) THEN
                  file_line_ := RPAD(' ',
                                     (templ_det_rec_.ft_list(i_).start_position-1),
                                     ' ');
               ELSE
                  file_line_ := char_value_;
               END IF;
            ELSE
               file_line_ := file_line_ || char_value_;
            END IF;
         END IF;
      END IF;
   END LOOP;
   --
   file_line1_ := file_line_;
   file_line_  := NULL;
   --i_          := 0;
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      IF (NVL(templ_det_rec_.ft_list(i_).record_type_id,'1') = 
          NVL(record_type_id_,'1')) THEN
         IF (first_ = 'TRUE') THEN
            first_ := 'FALSE';
         END IF;
         IF (templ_det_rec_.ft_list(i_).data_type = '3') THEN
            date_value_ := SYSDATE;
            char_value_ := Ext_File_Column_Util_API.Date_To_Str ( date_value_,
                                                                  templ_det_rec_.ft_list(i_).date_format );
            d_desc_value_tab_ (i_) := NULL;
         -- Number Format
         ELSIF (templ_det_rec_.ft_list(i_).data_type = '2') THEN
            number_value_ := 1;
            IF (templ_det_rec_.ft_list(i_).decimal_symbol IS NOT NULL) THEN
               char_value_ := Ext_File_Column_Util_API.Number_To_Str ( number_value_,
                                                                       templ_det_rec_.ft_list(i_).decimal_symbol );
            ELSIF (templ_det_rec_.ft_list(i_).denominator IS NOT NULL) THEN
               char_value_ := Ext_File_Column_Util_API.Number_To_Str2 ( number_value_,
                                                                        templ_det_rec_.ft_list(i_).denominator );
            ELSE
               char_value_ := TO_CHAR(number_value_);
            END IF;
            d_desc_value_tab_ (i_) := NULL;
         -- String Format
         ELSE
            v_          := v_ + 1;
            IF (v_ > 90) THEN
               v_       := 97;
            END IF;
            --char_value_ := 'X';
            char_value_           := CHR(v_);
            d_desc_value_tab_ (i_) := char_value_;
            char_value_           := REPLACE(char_value_,CHR(39),' ');
         END IF;
         --
         IF (templ_det_rec_.ext_file_rec.text_qualifier IS NOT NULL) THEN
            char_value_ := templ_det_rec_.ext_file_rec.text_qualifier || 
                           char_value_ || 
                           templ_det_rec_.ext_file_rec.text_qualifier;
         END IF;
         --
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
            Desc_Control_Separated_File___ (char_value_,
                                            templ_det_rec_.ft_list(i_).column_no,
                                            record_type_id_,
                                            templ_det_rec_);
            file_line_ := file_line_ || 
                          char_value_ || 
                          templ_det_rec_.ext_file_rec.Field_Separator;
         ELSE
            IF (LENGTH(char_value_) > templ_det_rec_.ft_list(i_).length_position) THEN
               char_value_ := SUBSTR(char_value_,
                                     1,
                                     templ_det_rec_.ft_list(i_).length_position);
            ELSE
               IF (templ_det_rec_.ft_list(i_).data_type = '2') THEN
                  char_value_ := LPAD(char_value_,
                                      templ_det_rec_.ft_list(i_).length_position,
                                      NVL(templ_det_rec_.ext_file_rec.number_out_fill_value,' '));
               ELSIF (templ_det_rec_.ft_list(i_).data_type = '1') THEN
                  char_value_ := RPAD(NVL(char_value_,' '),
                                      templ_det_rec_.ft_list(i_).length_position,
                                      d_desc_value_tab_ (i_));
               ELSE
                  char_value_ := RPAD(NVL(char_value_,' '),
                                      templ_det_rec_.ft_list(i_).length_position,
                                      ' ');
               END IF;
            END IF;
            IF (file_line_ IS NOT NULL) THEN
               IF (NVL(LENGTH(file_line_),0) > (templ_det_rec_.ft_list(i_).start_position-1)) THEN
                  file_line_ := SUBSTR(file_line_,
                                       1,
                                       (templ_det_rec_.ft_list(i_).start_position-1));
               ELSE
                  file_line_ := RPAD(file_line_,
                                     (templ_det_rec_.ft_list(i_).start_position-1),
                                     ' ');
               END IF;
            END IF;
            IF (file_line_ IS NULL) THEN
               IF (templ_det_rec_.ft_list(i_).start_position > 1) THEN
                  file_line_ := RPAD(' ',
                                     (templ_det_rec_.ft_list(i_).start_position-1),' ') || char_value_;
               ELSE
                  file_line_ := char_value_;
               END IF;
            ELSE
               file_line_ := file_line_ || char_value_;
            END IF;
         END IF;
      END IF;
      --
   END LOOP;
   file_line2_ := file_line_;
END Desc_Col_To_Line___;


PROCEDURE Desc_Record_Type___ (
   row_no_                IN OUT NUMBER,
   record_type_id_        IN     VARCHAR2,
   templ_det_rec_         IN OUT ft_m_det_rec)
IS
   file_line_                    VARCHAR2(4000);
   first_                        BOOLEAN        := TRUE;
   CURSOR get_col_funcs IS
      SELECT d.column_id                      column_id,
             Ext_File_Type_Rec_Column_API.Get_Description(d.file_type,d.record_type_id,d.column_id) 
                                              description,
             f.function_no                    function_no, 
             f.main_function                  main_function, 
             f.function_argument              function_argument 
      FROM   ext_file_templ_det_func_tab  f,
             ext_file_template_detail_tab d
      WHERE  d.file_template_id = templ_det_rec_.ext_file_rec.file_template_id
      AND    d.record_type_id   = record_type_id_
      AND    f.file_template_id = d.file_template_id
      AND    f.row_no           = d.row_no
      ORDER BY f.row_no,f.function_no;
BEGIN
	Trace_SYS.Message('Start Desc_Record_Type___');
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := 'Template Columns :';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := RPAD('Column Id',32,' ')||RPAD('Column Desc',32,' ')||'Type        ';
   IF    (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
      file_line_ := file_line_ || 'Column No';
   ELSIF (templ_det_rec_.ext_file_rec.file_format = 'FIX') THEN
      file_line_ := file_line_ || 'Start Pos  Length    Example';
   END IF;
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   FOR i_ IN 1 .. templ_det_rec_.max_ft LOOP
      IF (templ_det_rec_.ft_list(i_).record_type_id = record_type_id_) THEN
         file_line_ := RPAD(SUBSTR(templ_det_rec_.ft_list(i_).column_id,1,30),32,' ')||
                       RPAD(SUBSTR(templ_det_rec_.ft_list(i_).description,1,30),32,' ')||
                       RPAD(Exty_Data_Type_API.Decode(templ_det_rec_.ft_list(i_).data_type),12,' ');
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
            file_line_ := file_line_ || 
                          RPAD(TO_CHAR(templ_det_rec_.ft_list(i_).column_no),11,' ');
         ELSIF (templ_det_rec_.ext_file_rec.file_format = 'FIX') THEN
            file_line_ := file_line_ || 
                          RPAD(TO_CHAR(templ_det_rec_.ft_list(i_).start_position),11,' ') || 
                          RPAD(TO_CHAR(templ_det_rec_.ft_list(i_).length_position),11,' ');
         END IF;
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      END IF;
   END LOOP;
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   FOR rec_ IN get_col_funcs LOOP
      IF (first_) THEN
         first_     := FALSE;
         file_line_ := 'Column Functions :';
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
         file_line_ := RPAD('Column Id',32,' ')     ||
                       RPAD('Func No',10,' ')       ||
                       RPAD('Main Function',32,' ') ||
                       'Function Argument';
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
         file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      END IF;
      file_line_ := RPAD(rec_.column_id,32,' ')     ||
                    RPAD(rec_.function_no,10,' ')   ||
                    RPAD(rec_.main_function,32,' ') ||
                    rec_.function_argument;
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   END LOOP;
   IF NOT (first_) THEN
      file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   END IF;
END Desc_Record_Type___;


PROCEDURE Desc_Control_Fixed_File___ (
   file_line_              IN OUT VARCHAR2,
   record_type_id_         IN     VARCHAR2,
   templ_det_rec_          IN OUT ft_m_det_rec )
IS
   end_position_                  NUMBER;
   char_value_                    VARCHAR2(100);
   file_line_org_                 VARCHAR2(4000);
BEGIN
	Trace_SYS.Message('Start Desc_Control_Fixed_File___');
   file_line_org_ := file_line_;
   FOR i_ IN 1 .. templ_det_rec_.max_cn LOOP
      IF (templ_det_rec_.cn_list(i_).record_type_id = record_type_id_) THEN
         IF (templ_det_rec_.cn_list(i_).condition = '2') THEN
            end_position_   := templ_det_rec_.cn_list(i_).start_position + templ_det_rec_.cn_list(i_).length_position;
            char_value_     := templ_det_rec_.cn_list(i_).control_string;
            file_line_      := SUBSTR(file_line_org_,1,templ_det_rec_.cn_list(i_).start_position-1) ||
                               RPAD(char_value_,templ_det_rec_.cn_list(i_).length_position,' ') ||
                               SUBSTR(file_line_org_,end_position_);
            file_line_org_   := file_line_;
         END IF;
      END IF;
   END LOOP;
END Desc_Control_Fixed_File___;


PROCEDURE Desc_Control_Separated_File___ (
   char_value_             IN OUT VARCHAR2,
   column_no_              IN     VARCHAR2,
   record_type_id_         IN     VARCHAR2,
   templ_det_rec_          IN OUT ft_m_det_rec )
IS
BEGIN
	Trace_SYS.Message('Start Desc_Control_Separated_File___');
   FOR i_ IN 1 .. templ_det_rec_.max_cn LOOP
      IF (templ_det_rec_.cn_list(i_).record_type_id = record_type_id_) THEN
         IF (templ_det_rec_.cn_list(i_).column_no = column_no_ AND 
             templ_det_rec_.cn_list(i_).condition = '2') THEN
            char_value_ := templ_det_rec_.cn_list(i_).control_string;
            EXIT;
         END IF;
      END IF;
   END LOOP;
END Desc_Control_Separated_File___;


PROCEDURE Insert_File_Trans___ (
   load_file_id_         IN     NUMBER,
   row_no_               IN OUT NUMBER,
   file_line_            IN     VARCHAR2,
   row_state_            IN     VARCHAR2 DEFAULT '1',
   record_type_id_       IN     VARCHAR2 DEFAULT NULL )
IS
BEGIN
   row_no_ := row_no_ + 1;
   Ext_File_Trans_API.Insert_File_Trans ( load_file_id_, 
                                          row_no_, 
                                          file_line_,
                                          row_state_,
                                          record_type_id_ );
END Insert_File_Trans___;


PROCEDURE Clear_Empty_Attr___ (
   attr_ IN OUT VARCHAR2 )
IS
   new_attr_    VARCHAR2(32000);
   ptr_   NUMBER;
   name_  VARCHAR2(30);
   value_ VARCHAR2(2000);
BEGIN
   Client_SYS.Clear_Attr(new_attr_);
   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(attr_, ptr_, name_, value_)) LOOP
      IF (value_ IS NOT NULL) THEN
         Client_SYS.Add_To_Attr( name_, value_, new_attr_ );
      END IF;
   END LOOP;
   attr_ := new_attr_;
END Clear_Empty_Attr___;

PROCEDURE Check_Insert_Col_Pkg___ (
   input_package_    IN VARCHAR2,
   view_name_        IN VARCHAR2,
   base_view_        IN VARCHAR2,
   d_column_id_tab_  IN OUT CharSmallTabType, 
   where_list_       IN OUT VARCHAR2)
IS
   column_id_tab_         External_File_Utility_API.CharSmallTabType;
   i_                     NUMBER := 0;
   max_i_                 NUMBER := 0;      
   c_                     NUMBER := 0;
   max_c_                 NUMBER := 0;
   custom_base_view_      VARCHAR2(5);
   
   CURSOR get_colname IS
         SELECT column_name, type_flag, NVL(table_column_name,column_name) table_column_name 
         FROM   Dictionary_Sys_View_Column_Act
         WHERE  view_name = base_view_;
   
BEGIN
   IF (NOT Dictionary_SYS.Method_Is_Active (input_package_, 'New__')) THEN
      Error_SYS.Appl_General( lu_name_, 'NONEWMETHOD: There is no valid new method in package :P1',input_package_ );
   END IF;
   
   IF (base_view_ LIKE '%_CLV') THEN
      custom_base_view_ := 'TRUE';
   ELSE
      custom_base_view_ := 'FALSE';
   END IF;
   
   -- get the columns from base view.
   FOR rec_ IN get_colname LOOP            
      i_ := i_ + 1;
      -- IF part is only for Custom Lus
       --ELSE part is for everything else other than Custom Lus
      -- In custom lus there is no way to update a particular record for a given OBJKEY .
      -- Therefore no need to take its key column OBJKEY into column list
      IF (rec_.column_name = 'OBJKEY' AND custom_base_view_ = 'TRUE') THEN
          column_id_tab_ (i_) := 'XXXXX'; 
      ELSE
         column_id_tab_ (i_) := rec_.column_name; 
         -- construct the where statement with keys.
         -- this where list will be used when fetching the objid and objversion.
         IF (rec_.type_flag IN ('P', 'K')) THEN         
            IF (where_list_ IS NOT NULL) THEN
               where_list_ := where_list_ || ' AND ';
            END IF;            
            where_list_ := where_list_ || rec_.table_column_name || ' = ' || rec_.column_name || '_';      
         END IF;
      END IF;
   END LOOP; 
   
   -- Note: Custom LU's only support New__ for the time being. Modify__ is not supported yet.
   --       So the sql statement should not return a record. for that reason where clause is modifed so that it will always be FALSE.
   IF custom_base_view_ = 'TRUE' AND where_list_ IS NULL THEN
      where_list_ := '''TRUE'''|| ' = ' || '''FALSE''';
   END IF;
   
   max_i_ := column_id_tab_.COUNT;
   i_     := 0;
   max_c_ := d_column_id_tab_.COUNT;
   LOOP
      c_ := c_ + 1;
      IF (c_ > max_c_) THEN
         EXIT;
      END IF;
      i_ := 0;
      LOOP
         i_ := i_ + 1;
         IF (i_ > max_i_) THEN
            d_column_id_tab_ (c_) := 'XXXXX';
            EXIT;
         END IF;
         IF (column_id_tab_ (i_) = d_column_id_tab_ (c_)) THEN
            EXIT;
         END IF;
      END LOOP;
   END LOOP;
   
   IF (Check_If_Code_Part_View___ ( view_name_ ) = 'TRUE') THEN
      Error_SYS.Appl_General( lu_name_, 'COPAFUNC: View :P1 is not valid for input because there is a connected function',view_name_ );
   END IF;
END Check_Insert_Col_Pkg___;

FUNCTION Check_If_Code_Part_View___ (
   view_name_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   tmp_            VARCHAR2(32000);
   instr_          NUMBER;
   code_part_      VARCHAR2(1);
   dummy_          NUMBER;
   company_        VARCHAR2(20);
   CURSOR Get_Attr IS
      SELECT text
      FROM   user_views
      WHERE  view_name  = view_name_;
   CURSOR Get_Used_Func IS
      SELECT 1
      FROM   accounting_code_part_tab
      WHERE  company              = company_
      AND    code_part            = code_part_
      AND    code_part_function   != 'NOFUNC';
BEGIN
   User_Finance_API.Get_Default_Company ( company_ );
   OPEN  Get_Attr;
   FETCH Get_Attr INTO tmp_;
   IF (Get_Attr%NOTFOUND) THEN
      CLOSE Get_Attr;
      RETURN 'FALSE';
   END IF;
   CLOSE Get_Attr;
   IF (UPPER(tmp_) LIKE '%ACCOUNTING_CODE_PART_VALUE_TAB%') THEN
      IF (UPPER(tmp_) LIKE '%CODE_PART =%') THEN
         instr_ := INSTR(UPPER(tmp_),'CODE_PART =');
         IF (NVL(instr_,0) = 0) THEN
            RETURN 'FALSE';
         END IF;
         tmp_   := SUBSTR(tmp_,instr_);
         instr_ := INSTR(UPPER(tmp_),CHR(39));
         IF (NVL(instr_,0) = 0) THEN
            RETURN 'FALSE';
         END IF;
         code_part_ := SUBSTR(tmp_,instr_+1,1);
         OPEN  Get_Used_Func;
         FETCH Get_Used_Func INTO dummy_;
         IF (Get_Used_Func%FOUND) THEN
            CLOSE Get_Used_Func;
            RETURN 'TRUE';
         END IF;
         CLOSE Get_Used_Func;
      END IF;
   END IF;
   RETURN 'FALSE';
END Check_If_Code_Part_View___;

FUNCTION Get_Dyn_Id_Version___ (
   logical_unit_  IN VARCHAR2,
   where_list_    IN VARCHAR2) RETURN VARCHAR2
IS
   stmt_            VARCHAR2(32000);
   objid_name_      VARCHAR2(100);
   objversion_name_ VARCHAR2(100);
   table_name_      VARCHAR2(30);   
BEGIN
   -- gets objid and objversion styles from the view.
   objid_name_ := Dictionary_SYS.Get_Lu_Table_Column_Impl(logical_unit_, 'OBJID');
   objversion_name_ := Dictionary_SYS.Get_Lu_Table_Column_Impl(logical_unit_, 'OBJVERSION');
   
   table_name_ := Dictionary_SYS.Get_Base_Table_Name(logical_unit_);      
   stmt_ := 'SELECT ' || objid_name_ || ',' || objversion_name_ || ' FROM ' || table_name_ ;
   IF  (where_list_ IS NOT NULL) THEN
      stmt_ := stmt_ ||' WHERE ' || where_list_;
   END IF;               
   RETURN stmt_;
END Get_Dyn_Id_Version___;

FUNCTION Check_View_Col_Exist___ (
   view_name_   IN VARCHAR2,
   column_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   user_tab_columns
      WHERE  table_name  = view_name_
      AND    column_name = column_name_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_View_Col_Exist___; 

PROCEDURE Get_Column_Id___ (
   c_i_                    IN OUT NUMBER,
   column_id_              IN OUT VARCHAR2,
   destination_column_     IN OUT VARCHAR2,
   date_format_            IN OUT VARCHAR2,
   column_id_tab_          IN     CharSmallTabType,
   destination_column_tab_ IN     CharSmallTabType,
   date_format_tab_        IN     CharSmallTabType )
IS
   i_                        NUMBER := 0;
   max_i_                    NUMBER;
BEGIN
   max_i_        := column_id_tab_.COUNT;
   c_i_          := 0;
   LOOP
      i_     := i_ + 1;
      IF (i_ > max_i_) THEN
         EXIT;
      END IF;
      IF (destination_column_tab_ (i_) = destination_column_) THEN
         column_id_   := column_id_tab_ (i_);
         date_format_ := date_format_tab_ (i_);
         c_i_       := i_;
         EXIT;
      END IF;
   END LOOP;
END Get_Column_Id___;

FUNCTION Check_View_Col_Valid___ (
   view_name_     IN VARCHAR2,
   column_name_   IN VARCHAR2,
   insert_update_ IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Dictionary_Sys_View_Column_Act
      WHERE  view_name   = view_name_
      AND    column_name = column_name_
      AND    ((insert_update_ = 'U' AND update_flag <> insert_update_) OR (insert_update_ = 'I' AND insert_flag <> insert_update_)); 
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'FALSE';
   END IF;
   CLOSE exist_control;
   RETURN 'TRUE';
END Check_View_Col_Valid___;

FUNCTION Get_String___(
   string_    IN VARCHAR2,
   position_  IN NUMBER,
   separator_ IN VARCHAR2) RETURN VARCHAR2 
IS
   start_pos_        NUMBER;
   end_pos_          NUMBER;
   seperator_length_ NUMBER := LENGTH(separator_);
   start_length_     NUMBER := 0;
   end_length_       NUMBER := 0;
BEGIN
   IF position_ = 1 THEN
      start_pos_ := 0;
      end_length_ := 1;
   ELSE
      start_pos_ := INSTR(string_, separator_, 1, position_ - 1);
      start_length_ := seperator_length_;
      end_length_ := seperator_length_;
   END IF;

   end_pos_ := INSTR(string_, separator_, 1, position_);
   RETURN SUBSTR(string_, start_pos_ + start_length_, end_pos_ - start_pos_  - end_length_);
END Get_String___;

FUNCTION Select_Stmt_Builder___(
   file_type_        IN     VARCHAR2,
   file_template_    IN     VARCHAR2,
   separator_        IN     VARCHAR2,
   date_format_      IN     VARCHAR2 DEFAULT NULL) RETURN col_list
IS
   stmt_             VARCHAR2(32000):= 'SELECT ';
   line_columns_     VARCHAR2(32000):= '';   
   temp_             VARCHAR2(20) := NULL;   
   col_list_               col_list;
  
   CURSOR get_columns IS
      SELECT 
         CASE
            WHEN column_value LIKE 'D%' THEN
               CASE
                  WHEN date_format IS NOT NULL THEN
                     'TO_CHAR(' || column_value || ', ''' || date_format || ''')'
                  WHEN date_format IS NULL AND date_format_ IS NOT NULL THEN 
                     'TO_CHAR(' || column_value || ', ''' || date_format_ || ''')'
                  ELSE
                     column_value
               END
            WHEN column_value LIKE 'C%' AND max_length IS NOT NULL THEN
               'SUBSTR(' || column_value || ', 0, ' || max_length || ')'
            ELSE
               column_value
         END 
         column_value,
         column_id,
         record_type_id
      FROM (SELECT t2.destination_column column_value,
                   t1.column_id        column_id,
                   t1.date_format      date_format,
                   t1.max_length       max_length,
                   t1.record_type_id   record_type_id
            FROM   ext_file_template_detail_tab t1, ext_file_type_rec_column_tab t2
            WHERE  t1.file_template_id = file_template_
            AND    t1.file_type        = file_type_
            AND    t1.file_type = t2.file_type
            AND    t1.record_type_id = t2.record_type_id
            AND    t1.column_id = t2.column_id
            AND    NVL(t1.hide_column, 'FALSE') = 'FALSE')
      ORDER BY record_type_id;
BEGIN      
   FOR rec_ IN get_columns LOOP  
      IF (temp_ IS NULL OR NOT(temp_ = rec_.record_type_id)) THEN
         IF (temp_ IS NOT NULL AND NOT(temp_ = rec_.record_type_id)) THEN
            col_list_(temp_).line_columns := line_columns_;
            col_list_(temp_).stmt         := substr(stmt_, 0, length(stmt_) - 2);
         END IF;
         temp_:= rec_.record_type_id;
         stmt_ := 'SELECT ';
         line_columns_ := '';
      END IF;       
      line_columns_ := line_columns_ || REPLACE(rec_.column_id, ' ', '_') || separator_;
      stmt_ := stmt_ || rec_.column_value || '||' || '''' || separator_ || '''' || '||';        
   END LOOP; 
   col_list_(temp_).line_columns := line_columns_;
   col_list_(temp_).stmt         := substr(stmt_, 0, length(stmt_) - 2);
   RETURN col_list_;
END Select_Stmt_Builder___;

-- This method is to validate External File Line
FUNCTION Validate_File_Line___(
   input_line_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_input_line_    VARCHAR2(32000);
   temp_special_chars_ VARCHAR2(2000);
   temp_replace_chars_ VARCHAR2(2000);
BEGIN
   temp_input_line_ := input_line_;
   IF temp_input_line_ IS NULL THEN
      Error_SYS.Appl_General(lu_name_, 'NOLINE: No File Lines Found');
   END IF;
   IF LENGTH(temp_input_line_) > 4000 THEN
      Error_SYS.Appl_General(lu_name_, 'LINETOOLONG: Maximum length allowed for a File Line is 4000 characters.');
   END IF;
   Get_Special_Characters___(temp_special_chars_, temp_replace_chars_);
   temp_input_line_ := Remove_Special_Characters___(temp_input_line_, temp_special_chars_, temp_replace_chars_);   
   RETURN temp_input_line_;
END Validate_File_Line___;

-- This method is to construct Special Characters that are used by Framwork
PROCEDURE Get_Special_Characters___ (
   special_chars_  OUT VARCHAR2,
   replace_chars_  OUT VARCHAR2)
IS   
BEGIN
   FOR i_ IN 0..15 LOOP
      special_chars_ := special_chars_||chr(13+i_)||';';
      replace_chars_ := replace_chars_||''||';';
   END LOOP;   
END Get_Special_Characters___;

FUNCTION Get_Line_Values___(
   load_file_id_     IN     NUMBER,
   row_no_           IN     NUMBER,
   pre_stmt_         IN     VARCHAR2) RETURN VARCHAR2
IS
   stmt_          VARCHAR2(32000):= 'SELECT ';
   line_values_   VARCHAR2(32000);
   
   TYPE ExtCurTyp  IS REF CURSOR;
   rec1_    ExtCurTyp;
BEGIN  
   stmt_ := pre_stmt_ || '  
                      FROM ext_file_trans 
                      WHERE load_file_id =  :load_id
                      AND row_no = :row_no';

   @ApproveDynamicStatement(2017-10-02,chwtlk)
   OPEN rec1_ FOR stmt_ USING load_file_id_, row_no_;
   FETCH rec1_ INTO line_values_;
   CLOSE rec1_;   
   RETURN line_values_;
END Get_Line_Values___;

FUNCTION Remove_Special_Characters___(
   string_               IN VARCHAR2,
   special_character_    IN VARCHAR2,
   replace_with_         IN VARCHAR2) RETURN VARCHAR2 
IS
   special_character_tmp_     VARCHAR2(2000);
   replace_with_tmp_          VARCHAR2(2000);
   new_line_                  VARCHAR2(32000);
BEGIN
   new_line_ := string_;
   FOR count_ IN 1..REGEXP_COUNT (special_character_, ';') LOOP
      special_character_tmp_   := Get_String___(special_character_, count_, ';');
      replace_with_tmp_        := Get_String___(replace_with_, count_, ';');     
      new_line_    := REPLACE(new_line_, special_character_tmp_ , replace_with_tmp_);
   END LOOP;
   RETURN new_line_;
END Remove_Special_Characters___;

FUNCTION Get_Head_Structure_Arr___ (
   load_file_id_     IN NUMBER) RETURN Ext_File_Trans_Head_Structure_Arr
IS
   rec_           Ext_File_Trans_Head_Structure_Rec;
   list_array_    Ext_File_Trans_Head_Structure_Arr := Ext_File_Trans_Head_Structure_Arr();   
   
   CURSOR get_list IS
      SELECT row_no
      FROM ext_file_trans_head
      WHERE load_file_id = load_file_id_;   
BEGIN 
   FOR cur_ IN get_list LOOP
      rec_ := Get_Ext_File_Trans_Head_Structure_Rec___(load_file_id_, cur_.row_no);      
      list_array_.extend;
      list_array_(list_array_.last) := rec_;      
   END LOOP;  
   RETURN list_array_;
END Get_Head_Structure_Arr___;

@Override
FUNCTION Ext_File_Trans_Head_Structure_Arr_To_Dom___ (
   arr_ IN Ext_File_Trans_Head_Structure_Arr) RETURN Dbms_Xmldom.DomDocument
IS
   temp_dom_      Dbms_Xmldom.DomDocument;   
   node_list_     Dbms_xmldom.DOMNodeList;
   l_node_        Dbms_xmldom.DOMNode;  
   l_node_name_   VARCHAR2(2000);
BEGIN   
   temp_dom_ := super(arr_);
   
   -- Find the tope node to be able to set xml-attributes
   node_list_ := Dbms_Xmldom.Getelementsbytagname(temp_dom_, 'ExtFileTransHeadStructureArray');
   
   FOR i_ IN 0..dbms_xmldom.Getlength(node_list_)-1 LOOP
      l_node_ := dbms_xmldom.item(node_list_, i_);      
      l_node_name_ := dbms_xmldom.Getnodename(l_node_);
      IF (l_node_name_ = 'ExtFileTransHeadStructureArray') THEN
         Dbms_Xmldom.setAttribute(Dbms_Xmldom.makeElement(l_node_), 'xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
         -- the following attribute is needed for the existing transformer to be able to transform from IFS XML
         Dbms_Xmldom.setAttribute(Dbms_Xmldom.makeElement(l_node_), 'xmlns','urn:ifsworld-com:schemas:tax_xml_handler_send_tax_xml_file_request');      
      END IF;
   END LOOP;     
   
   RETURN temp_dom_;
END Ext_File_Trans_Head_Structure_Arr_To_Dom___;

-- This Function accept a CLOB and return an array of file lines.
-- Since Oracle Column allow only 4000,buffer_ is also limited to 4000. 
FUNCTION Read_Line_By_Line(
   lob_loc_ CLOB) RETURN LineTabType
IS
   amount_         NUMBER;
   offset_         NUMBER := 1;
   buffer_         VARCHAR2(32000);
   clob_length_    NUMBER := DBMS_Lob.getlength(lob_loc_);
   file_lines_     LineTabType;
   i_              NUMBER := 1;
BEGIN
   WHILE offset_ < clob_length_ LOOP
      amount_ := DBMS_Lob.instr(lob_loc_, CHR(10), offset_) - offset_;
      IF amount_ > 0 THEN
         DBMS_Lob.read(lob_loc_, amount_, offset_, buffer_);
         offset_ := offset_ + amount_ + 1;
      ELSE
         amount_ := (clob_length_-offset_)+1;
         DBMS_Lob.read(lob_loc_, amount_, offset_, buffer_);
         offset_ := clob_length_;
      END IF;
      buffer_ := Validate_File_Line___(buffer_);
      file_lines_(i_) := buffer_;
      i_:=i_+1;
   END LOOP;
   RETURN file_lines_;
END Read_Line_By_Line;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
FUNCTION Blob_To_Clob__ (
   lob_loc_ IN BLOB) RETURN CLOB
IS
   temp_clob_ CLOB;
   varchar_ VARCHAR2(32000);
   start_ PLS_INTEGER := 1;
   buffer_ PLS_INTEGER := 32000;
BEGIN
   DBMS_LOB.CREATETEMPORARY(temp_clob_, TRUE);

   FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(lob_loc_) / buffer_)
   LOOP
      varchar_ := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(lob_loc_, buffer_, start_));
      DBMS_LOB.WRITEAPPEND(temp_clob_, LENGTH(varchar_), varchar_);
      start_ := start_ + buffer_;
   END LOOP;
   RETURN temp_clob_;
END Blob_To_Clob__;

PROCEDURE Add_Xml_Data__(
   objid_            OUT VARCHAR2,
   load_file_id_  IN     NUMBER,
   clob_file_     IN     CLOB)
IS
BEGIN
   INSERT 
      INTO EXT_FILE_XML_FILE_TAB(
         load_file_id,
         clob_file)
      VALUES(
         load_file_id_,
         clob_file_)
   RETURNING ROWID INTO objid_;
END Add_Xml_Data__;
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Load_Server_File_ (
   load_file_id_     IN OUT NUMBER,
   file_template_id_ IN     VARCHAR2,
   file_type_        IN     VARCHAR2,
   file_name_        IN OUT VARCHAR2,
   company_          IN     VARCHAR2 )
IS
BEGIN
   Ext_File_Server_Util_API.Load_Server_File_ ( load_file_id_,
                                                file_template_id_,
                                                file_type_,
                                                file_name_,
                                                company_ );
END Load_Server_File_;


PROCEDURE Load_Client_File_ (
   action_           IN     VARCHAR2,
   load_file_id_     IN OUT NUMBER,
   file_template_id_ IN     VARCHAR2,
   file_type_        IN     VARCHAR2,
   message_          IN     VARCHAR2,
   company_          IN     VARCHAR2,
   file_name_        IN     VARCHAR2 )
IS
   count_                   INTEGER;
   names_                   Message_SYS.name_Table;
   values_                  Message_SYS.line_Table;
   scount_                  INTEGER;
   snames_                  Message_SYS.name_Table;
   svalues_                 Message_SYS.line_Table;
   file_line_               VARCHAR2(4000);
   row_no_                  NUMBER;
   system_bound_            VARCHAR2(5);
BEGIN
   IF (action_ = 'NEW' OR NVL(load_file_id_,0) = 0) THEN
      load_file_id_ := Get_Next_Seq;
   END IF;
   row_no_       := NVL(Ext_File_Trans_API.Get_Max_Row_No ( load_file_id_ ),1);
   system_bound_ := Ext_File_Type_API.Get_System_Bound(file_type_);
   Message_SYS.Get_Attributes ( message_, count_, names_, values_ );
   IF system_bound_ = 'TRUE' THEN
      FOR i_ IN 1..count_ LOOP
         Message_SYS.Get_Attributes ( values_(i_), scount_, snames_, svalues_ );
         file_line_                    := Database_Sys.Unistr(svalues_(1));
         IF (( file_line_ IS NULL ) AND (svalues_(1) IS NOT NULL)) THEN
            svalues_(1) := replace(svalues_(1),'\','\005C');
            file_line_     := Database_Sys.Unistr( svalues_(1));
            IF (file_line_ IS NULL) THEN
               Error_SYS.Record_General( lu_name_, 'NOTUNICODECOMPL: Error in loading file :P1',load_file_id_);
            END IF;
         END IF;
         IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_id_ ) ) THEN
            Ext_File_Load_API.Insert_File_Load ( load_file_id_,
                                                 file_template_id_,
                                                 '1',
                                                 file_type_,
                                                 company_,
                                                 file_name_ );
         END IF;
         Ext_File_Trans_API.Insert_File_Trans ( load_file_id_,
                                                row_no_,
                                                file_line_ );
         row_no_ := row_no_ + 1;
      END LOOP;
   ELSE
      FOR i_ IN 1..count_ LOOP
         Message_SYS.Get_Attributes ( values_(i_), scount_, snames_, svalues_ );
         file_line_                    := svalues_(1);
         IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_id_ ) ) THEN
            Ext_File_Load_API.Insert_File_Load ( load_file_id_,
                                                 file_template_id_,
                                                 '1',
                                                 file_type_,
                                                 company_,
                                                 file_name_ );
         END IF;
         Ext_File_Trans_API.Insert_File_Trans ( load_file_id_,
                                                row_no_,
                                                file_line_ );
         row_no_ := row_no_ + 1;
      END LOOP;
   END IF;
   Ext_File_Load_API.Update_State (load_file_id_,
                                   '2',
                                   file_name_);

END Load_Client_File_;

PROCEDURE Load_Aurena_Client_File_ (
   action_           IN     VARCHAR2,
   load_file_id_     IN OUT NUMBER,
   file_template_id_ IN     VARCHAR2,
   file_type_        IN     VARCHAR2,
   message_          IN     BLOB,
   company_          IN     VARCHAR2,
   file_name_        IN     VARCHAR2 )
IS
   file_line_               VARCHAR2(4000);
   row_no_                  NUMBER;
   system_bound_            VARCHAR2(5);
   
   clob_values_             CLOB;
   lines_array_             LineTabType;
BEGIN
   IF (action_ = 'NEW' OR NVL(load_file_id_,0) = 0) THEN
      load_file_id_ := Get_Next_Seq;
   END IF;
   row_no_       := NVL(Ext_File_Trans_API.Get_Max_Row_No ( load_file_id_ ),1);
   system_bound_ := Ext_File_Type_API.Get_System_Bound(file_type_);
   clob_values_ := Blob_To_Clob__(message_);
   lines_array_ := External_File_Utility_API.Read_Line_By_Line(clob_values_);

   IF system_bound_ = 'TRUE' THEN
      FOR i_ IN 1..lines_array_.COUNT() LOOP
         file_line_                    := Database_Sys.Unistr(lines_array_(i_));
         IF (( file_line_ IS NULL ) AND (lines_array_(i_) IS NOT NULL)) THEN
            lines_array_(i_) := replace(lines_array_(i_),'\','\005C');
            file_line_     := Database_Sys.Unistr( lines_array_(i_));
            IF (file_line_ IS NULL) THEN
               Error_SYS.Record_General( lu_name_, 'NOTUNICODECOMPL: Error in loading file :P1',load_file_id_);
            END IF;
         END IF;
         
         IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_id_ ) ) THEN
            Ext_File_Load_API.Insert_File_Load ( load_file_id_,
                                                 file_template_id_,
                                                 '1',
                                                 file_type_,
                                                 company_,
                                                 file_name_ );
         END IF;
         --Error_SYS.Appl_General(lu_name_, file_line_);
         Ext_File_Trans_API.Insert_File_Trans ( load_file_id_,
                                                row_no_,
                                                file_line_ );
         row_no_ := row_no_ + 1;
         
      END LOOP;
   ELSE
      FOR i_ IN 1..lines_array_.COUNT() LOOP
         file_line_                    := lines_array_(i_);
         file_line_                    := REPLACE(file_line_,CHR(15711167));
         IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_id_ ) ) THEN
            Ext_File_Load_API.Insert_File_Load ( load_file_id_,
                                                 file_template_id_,
                                                 '1',
                                                 file_type_,
                                                 company_,
                                                 file_name_ );
         END IF;
         Ext_File_Trans_API.Insert_File_Trans ( load_file_id_,
                                                row_no_,
                                                file_line_ );
         row_no_ := row_no_ + 1;
      END LOOP;
   END IF;
   Ext_File_Load_API.Update_State (load_file_id_,
                                   '2',
                                   file_name_);

END Load_Aurena_Client_File_;

PROCEDURE Clear_Temp_Data_
IS
BEGIN
   DELETE
   FROM EXT_FILE_XML_FILE_TAB;
END Clear_Temp_Data_;
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Unpack_Separated_File (
   err_msg_       IN OUT VARCHAR2,
   row_state_     IN OUT VARCHAR2,
   value_tab_     IN OUT ValueTabType,
   buffer_        IN     VARCHAR2,
   ext_file_rec_  IN     ExtFileRec )
IS
BEGIN
   Unp_Separated_File___ (err_msg_,
                          row_state_,
                          value_tab_,
                          buffer_,
                          ext_file_rec_);
END Unpack_Separated_File;


PROCEDURE Control_In_Ext_File (
   err_msg_                IN OUT VARCHAR2,
   use_line_               IN OUT VARCHAR2,
   skipped_line_           IN OUT VARCHAR2,
   invalid_line_           IN OUT VARCHAR2,
   record_type_id_         IN OUT VARCHAR2,
   no_of_lines_            IN OUT NUMBER,
   buffer_                 IN OUT VARCHAR2,
   templ_det_rec_          IN OUT ft_m_det_rec,
   unp_value_tab_          IN     ValueTabType )
IS
BEGIN
   Control_In_Ext_File___ (err_msg_,
                           use_line_,
                           skipped_line_,
                           invalid_line_,
                           record_type_id_,
                           no_of_lines_,
                           buffer_,
                           templ_det_rec_,
                           unp_value_tab_);
END Control_In_Ext_File;


FUNCTION Get_Next_Seq RETURN NUMBER
IS
   seq_no_ NUMBER;
   CURSOR nextseq IS
      SELECT Ext_File_Sequence.NEXTVAL
      FROM dual;
BEGIN
   OPEN  nextseq;
   FETCH nextseq INTO seq_no_;
   CLOSE nextseq;
   RETURN ( seq_no_ );
END Get_Next_Seq;


PROCEDURE Clear_Value_Tab (
   value_tab_ IN OUT ValueTabType,
   max_i_     IN     NUMBER )
IS
BEGIN
   Clear_Value_Tab___ (value_tab_, max_i_);
END Clear_Value_Tab;


PROCEDURE Create_External_Input (
   info_              IN OUT VARCHAR2,
   load_file_id_      IN     NUMBER,
   file_type_         IN     VARCHAR2,
   file_template_id_  IN     VARCHAR2,
   record_type_id_    IN     VARCHAR2,
   view_name_         IN     VARCHAR2,
   input_package_     IN     VARCHAR2,
   file_typey_        IN     VARCHAR2,    
   file_template_idy_ IN     VARCHAR2 )   
IS
   chk_stmnt_                VARCHAR2(32000);
   chk_stmntx_               VARCHAR2(32000);
   new_stmnt_                VARCHAR2(32000);
   mod_stmnt_                VARCHAR2(32000);
   objid_                    VARCHAR2(2000);
   objversion_               VARCHAR2(2000);
   prep_attr_                VARCHAR2(32000);
   new_attr_                 VARCHAR2(32000);
   mod_attr_                 VARCHAR2(32000);
   action_                   VARCHAR2(10) := 'DO';
   d_destination_column_tab_ External_File_Utility_API.CharSmallTabType;
   d_column_id_tab_          External_File_Utility_API.CharSmallTabType;
   d_insertable_tab_         External_File_Utility_API.CharSmallTabType;
   d_updatable_tab_          External_File_Utility_API.CharSmallTabType;
   d_date_format_tab_        External_File_Utility_API.CharSmallTabType;
   date_format_              VARCHAR2(50);
   c_i_                      NUMBER;
   d_                        NUMBER  := 0;
   destination_column_       VARCHAR2(4);
   key_column_               NUMBER;
   error_msg_                VARCHAR2(2000);
   row_state_                VARCHAR2(1);
   cvalue_                   VARCHAR2(2000);
   nvalue_                   NUMBER;
   dvalue_                   DATE;
   chkvalue_                 VARCHAR2(2000);
   column_id_                VARCHAR2(30);
   rec_exists_               NUMBER;
   logical_unit_             VARCHAR2(30);
   enumeration_lu_           VARCHAR2(30);
   enumeration_pkg_          VARCHAR2(30);
   base_view_                VARCHAR2(30);
   where_list_               VARCHAR2(32000);
   encode_stmnt_             VARCHAR2(2000);
   add_db_val_insert_        BOOLEAN := FALSE;
   add_db_val_update_        BOOLEAN := FALSE;
   client_col_id_            VARCHAR2(30);
   ext_file_rec_             Ext_File_Type_API.Public_Rec;
   CURSOR CheckExtFileTrans IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id   = load_file_id_
      AND    record_type_id = record_type_id_
      AND    row_state      = '2';
   CURSOR GetExtFileTrans IS
      SELECT *
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id   = load_file_id_
      AND    record_type_id = record_type_id_
      AND    row_state      = '2'
      ORDER BY row_no;
   CURSOR GetColumns IS
      SELECT d.column_id                    column_id,
             c.destination_column           destination_column,
             NVL(d.date_format,t.date_format) date_format
      FROM   ext_file_template_detail_tab d,
             ext_file_type_rec_column_tab c,
             ext_file_template_tab t
      WHERE  d.file_template_id = file_template_id_
      AND    d.file_type        = file_type_
      AND    d.column_id       != 'LINE_TYPE'
      AND    d.record_type_id   = record_type_id_
      AND    c.file_type        = d.file_type
      AND    c.record_type_id   = d.record_type_id
      AND    c.column_id        = d.column_id
      AND    t.file_template_id = d.file_template_id;
BEGIN
   logical_unit_ := Dictionary_SYS.Get_Logical_Unit(view_name_,'VIEW');
   base_view_    := Dictionary_SYS.Get_Base_View(logical_unit_);   
   ext_file_rec_ := Ext_File_Type_API.Get(file_type_);
   
   IF ((ext_file_rec_.system_defined = 'FALSE') OR (ext_file_rec_.input_projection_action IS NULL)) THEN
      Error_SYS.Appl_General(lu_name_, 'FILETYPENOTAVAILABLE: File type :P1 is not available for the user.', file_type_);
   ELSIF (NOT Security_SYS.Is_Proj_Action_Available('ExternalFileAssistantHandling', ext_file_rec_.input_projection_action)) THEN
      Error_SYS.Appl_General(lu_name_, 'NOPROJACTAVAILABLE: Projection action :P1 is not available for the user.', ext_file_rec_.input_projection_action);
   END IF;
   
   OPEN  CheckExtFileTrans;
   FETCH CheckExtFileTrans INTO rec_exists_;
   IF (CheckExtFileTrans%NOTFOUND) THEN
      rec_exists_ := 0;
   END IF;
   CLOSE CheckExtFileTrans;
   --
   IF (rec_exists_ = 1) THEN
      FOR rec_ IN GetColumns LOOP
         d_ := d_ + 1;
         d_destination_column_tab_ (d_) := rec_.destination_column;
         d_column_id_tab_ (d_)          := rec_.column_id;
         d_date_format_tab_ (d_)        := rec_.date_format;
         d_insertable_tab_ (d_) := Check_View_Col_Valid___ (view_name_,
                                                           rec_.column_id,
                                                           'I');
         d_updatable_tab_ (d_)  := Check_View_Col_Valid___ (view_name_,
                                                           rec_.column_id,
                                                           'U');
      END LOOP;
      
      Check_Insert_Col_Pkg___ ( input_package_,
                                view_name_,
                                base_view_,
                                d_column_id_tab_,
                                where_list_);      
      new_stmnt_   := 'BEGIN '||input_package_||'.New__ ( '||
                         ':info_, :objid_, :objversion_, :new_attr_, :action_ );'||
                      'END;';
      mod_stmnt_   := 'BEGIN '||input_package_||'.Modify__ ( '||
                         ':info_, :objid_, :objversion_, :mod_attr_, :action_ );'||
                      'END;';
      chk_stmnt_   := Get_Dyn_Id_Version___ (logical_unit_, where_list_);
      
      IF (base_view_ IN ('ACCOUNT' , 'CODE_B' , 'CODE_C' , 'CODE_D' , 'CODE_E' , 'CODE_F' , 'CODE_G' , 'CODE_H' , 'CODE_I' , 'CODE_J')) THEN
         chk_stmnt_   := chk_stmnt_ || ' AND CODE_PART = CODE_PART_ ';
      END IF;
      
      Assert_SYS.Assert_Is_Package_Method(input_package_,'New__');
      Assert_SYS.Assert_Is_Package_Method(input_package_,'Modify__');
      FOR trans_rec_ IN GetExtFileTrans LOOP
         error_msg_ := NULL;
         Client_SYS.Clear_Attr (new_attr_);
         Client_SYS.Clear_Attr (mod_attr_);
         Client_SYS.Clear_Attr(prep_attr_);
         chk_stmntx_ := chk_stmnt_||' ';
         FOR i_ IN 0 .. 199 LOOP
            destination_column_ := 'C'||TO_CHAR(i_);
            cvalue_ := Ext_File_Column_Util_API.Return_C_Value ( destination_column_, trans_rec_ );
            cvalue_ := REPLACE(cvalue_,'"',CHR(39));
            column_id_ := NULL;
            Get_Column_Id___ ( c_i_, 
                              column_id_,
                              destination_column_,
                              date_format_,
                              d_column_id_tab_,
                              d_destination_column_tab_,
                              d_date_format_tab_ );
            IF (column_id_ = 'FILE_TYPE' AND file_typey_ IS NOT NULL) THEN
               cvalue_ := file_typey_;
            END IF;
            IF (column_id_ = 'FILE_TEMPLATE_ID' AND file_template_idy_ IS NOT NULL) THEN
               cvalue_ := file_template_idy_;
            END IF;
            IF (NVL(column_id_,'XXXXX') != 'XXXXX') THEN
               IF (Check_View_Col_Exist___ ( view_name_, column_id_) = 'TRUE' ) THEN
                  key_column_ := INSTR(chk_stmntx_,' '||column_id_||'_ ');
                  IF (NVL(key_column_,0) > 0) THEN
                     chkvalue_ := cvalue_;
                     enumeration_lu_ := Dictionary_SYS.Get_Enumeration_Lu(base_view_,column_id_);
                     IF ( enumeration_lu_ IS NOT NULL) THEN
                        enumeration_pkg_ := Dictionary_SYS.Get_Base_Package(enumeration_lu_);
                        encode_stmnt_ := ' SELECT ' || enumeration_pkg_ || '.Encode(''' || chkvalue_ || ''') FROM DUAL ';                        
                        @ApproveDynamicStatement(2014-02-13,umdolk)
                        EXECUTE IMMEDIATE encode_stmnt_ INTO chkvalue_;
                     END IF;                     
                     chk_stmntx_ := REPLACE(chk_stmntx_,' '||column_id_||'_ ',' '||CHR(39)||chkvalue_||CHR(39)||' ');
                  END IF;
                  add_db_val_insert_ := FALSE;
                  add_db_val_update_ := FALSE;
                  IF (SUBSTR(column_id_,-3,3) = '_DB') THEN
                     client_col_id_ := substr(column_id_,0,instr(column_id_,'_DB') - 1);
                     enumeration_lu_ := Dictionary_SYS.Get_Enumeration_Lu(base_view_, client_col_id_);
                     add_db_val_insert_ := enumeration_lu_ IS NOT NULL 
                                           AND cvalue_ IS NOT NULL 
                                           AND Check_View_Col_Valid___(base_view_, client_col_id_, 'I') = 'TRUE';
                     add_db_val_update_ := enumeration_lu_ IS NOT NULL 
                                           AND cvalue_ IS NOT NULL 
                                           AND Check_View_Col_Valid___(base_view_, client_col_id_, 'U') = 'TRUE';
                  END IF;
                  
                  IF (d_insertable_tab_ (c_i_) = 'TRUE' OR add_db_val_insert_) THEN
                     Client_SYS.Add_To_Attr ( column_id_, cvalue_, new_attr_);
                  END IF;
                  IF (key_column_ = 0) THEN
                     IF (d_updatable_tab_ (c_i_) = 'TRUE' OR add_db_val_update_) THEN
                        Client_SYS.Add_To_Attr ( column_id_, cvalue_, mod_attr_);
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
         FOR i_ IN 0 .. 99 LOOP
            destination_column_ := 'N'||TO_CHAR(i_);
            nvalue_ := Ext_File_Column_Util_API.Return_N_Value ( destination_column_, trans_rec_ );
            column_id_ := NULL;
            Get_Column_Id___ ( c_i_, 
                              column_id_,
                              destination_column_,
                              date_format_,
                              d_column_id_tab_,
                              d_destination_column_tab_,
                              d_date_format_tab_ );
            IF (NVL(column_id_,'XXXXX') != 'XXXXX') THEN
               IF (Check_View_Col_Exist___ ( view_name_, column_id_) = 'TRUE' ) THEN
                  key_column_ := INSTR(chk_stmntx_,' '||column_id_||'_ ');
                  chk_stmntx_ := REPLACE(chk_stmntx_,' '||column_id_||'_ ',' '||NVL(nvalue_,0)||' '); 
                  IF (d_insertable_tab_ (c_i_) = 'TRUE') THEN
                     Client_SYS.Add_To_Attr ( column_id_, nvalue_, new_attr_);
                  END IF;
                  IF (key_column_ = 0) THEN
                     IF (d_updatable_tab_ (c_i_) = 'TRUE') THEN
                        Client_SYS.Add_To_Attr ( column_id_, nvalue_, mod_attr_);
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
         FOR i_ IN 1 .. 20 LOOP
            destination_column_ := 'D'||TO_CHAR(i_);
            dvalue_ := Ext_File_Column_Util_API.Return_D_Value ( destination_column_, trans_rec_ );
            column_id_ := NULL;
            Get_Column_Id___ ( c_i_, 
                            column_id_,
                            destination_column_,
                            date_format_,
                            d_column_id_tab_,
                            d_destination_column_tab_,
                            d_date_format_tab_ );
            IF (NVL(column_id_,'XXXXX') != 'XXXXX') THEN
               IF (Check_View_Col_Exist___ ( view_name_, column_id_) = 'TRUE' ) THEN
                  key_column_ := INSTR(chk_stmntx_,' '||column_id_||'_ ');
                  chk_stmntx_ := REPLACE(chk_stmntx_,' '||column_id_||'_ ',' TO_DATE('||CHR(39)||TO_CHAR(dvalue_,date_format_)||CHR(39)||','||CHR(39)||date_format_||CHR(39)||') ');
                  IF (d_insertable_tab_ (c_i_) = 'TRUE') THEN
                     Client_SYS.Add_To_Attr ( column_id_, dvalue_, new_attr_);
                  END IF;
                  IF (key_column_ = 0) THEN
                     IF (d_updatable_tab_ (c_i_) = 'TRUE') THEN
                        Client_SYS.Add_To_Attr ( column_id_, dvalue_, mod_attr_);
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
         BEGIN
            @ApproveDynamicStatement(2006-01-27,jeguse)
            EXECUTE IMMEDIATE chk_stmntx_ INTO objid_, objversion_;
         EXCEPTION
            WHEN OTHERS THEN
               --NOTE: Exception may occure because NO_DATA_FOUND or there is some columns for which values are
               --automatically generated (eg: by a sequence). In such case a new record is always inserted.
               objid_      := NULL;
               objversion_ := NULL;
         END;
         IF (error_msg_ IS NOT NULL) THEN
            NULL;
         ELSIF (objid_ IS NULL) THEN
            BEGIN
               Finance_Lib_API.Is_Method_Available(input_package_||'.New__');               
               action_ := 'PREPARE';
               prep_attr_  := new_attr_;
               BEGIN
                  @ApproveDynamicStatement(2005-12-05,ovjose)
                  EXECUTE IMMEDIATE new_stmnt_ USING
                     OUT info_, OUT objid_, OUT objversion_, IN OUT prep_attr_, IN action_;
               EXCEPTION
                  WHEN OTHERS THEN
                     error_msg_ := SQLERRM;
                     row_state_ := '5';
               END;
               new_attr_ := prep_attr_ || new_attr_;
               Clear_Empty_Attr___ (new_attr_);
               action_ := 'DO';
               @ApproveDynamicStatement(2005-12-05,ovjose)
               EXECUTE IMMEDIATE new_stmnt_ USING
                  OUT info_, OUT objid_, OUT objversion_, IN OUT new_attr_, IN action_;
               row_state_ := '3';
            EXCEPTION
               WHEN OTHERS THEN
                  error_msg_ := SQLERRM;
                  row_state_ := '5';
            END;
         ELSE
            BEGIN
               Finance_Lib_API.Is_Method_Available(input_package_||'.Modify__');
               @ApproveDynamicStatement(2005-12-05,ovjose)
               EXECUTE IMMEDIATE mod_stmnt_ USING
                  OUT info_, IN objid_, IN OUT objversion_, IN OUT mod_attr_, IN action_;
               row_state_ := '3';
            EXCEPTION
               WHEN OTHERS THEN
                  error_msg_ := SQLERRM;
                  row_state_ := '5';
            END;
         END IF;
         Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                              trans_rec_.row_no,
                                              row_state_,
                                              error_msg_);
      END LOOP;
   END IF;
END Create_External_Input;


PROCEDURE Create_External_Input (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER  )
IS
   parameter_string_        VARCHAR2(2000);
   file_typey_              VARCHAR2(30);
   file_template_idy_       VARCHAR2(30);
   tmp_                     VARCHAR2(2000)  := NULL;
   dummy_                   VARCHAR2(10)    := '<DUMMY>';
   file_type_               VARCHAR2(30);
   file_template_id_        VARCHAR2(30);
   company_                 VARCHAR2(20);
   ext_file_rec_            External_File_Utility_API.ExtFileRec;
   view_name_               VARCHAR2(30);
   gview_name_              VARCHAR2(30);
   input_package_           VARCHAR2(30);
   ginput_package_          VARCHAR2(30);
   instr_                   NUMBER;
   msg_                     VARCHAR2(32000);
   translate_               VARCHAR2(32000);
   ext_file_type_rec_       Ext_File_Type_API.Public_Rec;
   
   CURSOR Getload_info IS
      SELECT parameter_string,      
             file_type,
             file_template_id,
             company
      FROM   Ext_File_Load_Tab
      WHERE load_file_id = load_file_id_;
   CURSOR GetRecTypes IS
      SELECT DISTINCT
             G.record_type_id,
             G.first_in_record_set,
             G.last_in_record_set,
             G.view_name,
             G.input_package
      FROM   Ext_File_Template_Detail_Tab D,
             Ext_File_Type_Rec_Tab G
      WHERE  D.file_template_id = file_template_id_
      AND    G.file_type        = D.file_type
      AND    G.record_type_id   = D.record_type_id
      ORDER BY DECODE(G.first_in_record_set,'TRUE',0,
                  DECODE(G.last_in_record_set,'TRUE',3,2)),
               G.record_type_id;
BEGIN
   OPEN  Getload_info;
   FETCH Getload_info INTO parameter_string_,
                          file_type_,
                          file_template_id_,
                          company_;
   CLOSE Getload_info;
   ext_file_type_rec_   := Ext_File_Type_API.Get( file_type_ );
   view_name_     := ext_file_type_rec_.view_name;
   input_package_ := ext_file_type_rec_.input_package;
   IF (file_type_ = 'ExtFileExpImp') THEN
      tmp_ := Message_SYS.Find_Attribute (parameter_string_,
                                          'FILE_TYPEY',
                                          dummy_);
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         file_typey_ := tmp_;
      END IF;
      tmp_ := Message_SYS.Find_Attribute (parameter_string_,
                                          'FILE_TEMPLATE_IDY',
                                          dummy_);
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         file_template_idy_ := tmp_;
      END IF;
   END IF;

   instr_       := NVL(INSTR(input_package_,'.'),0);
   IF (instr_ > 0) THEN
      input_package_ := SUBSTR(input_package_,1,instr_-1);
   END IF;
   Ext_File_Template_API.Get_Ext_File_Head ( ext_file_rec_,
                                             file_template_id_,
                                             '1');
   FOR rec_ IN GetRecTypes LOOP
      IF (rec_.view_name IS NOT NULL) THEN
         gview_name_ := rec_.view_name;
      ELSE
         gview_name_ := view_name_;
      END IF;
      IF (rec_.input_package IS NOT NULL) THEN
         ginput_package_ := rec_.input_package;
      ELSE
         ginput_package_ := input_package_;
      END IF;
      IF (ginput_package_ IS NULL) THEN
         Error_SYS.Appl_General( lu_name_, 'NOINPKG: There is no Input Package specified for File Type :P1 and Record Type :P2',file_type_, rec_.record_type_id );
      END IF;
      Create_External_Input ( info_,
                              load_file_id_,
                              file_type_,
                              file_template_id_,
                              rec_.record_type_id,
                              gview_name_,
                              ginput_package_,
                              file_typey_,             
                              file_template_idy_ );    
   END LOOP;
   Ext_File_Load_API.Update_State (load_file_id_, '4');
   msg_ := 'NOERRINPUT: Load File ID :P1 is loaded without errors';
   Client_SYS.Clear_Info;
   translate_  := Language_SYS.Translate_Constant(lu_name_,'NOERRINPUT: Load File ID :P1 is loaded without errors');
   Client_SYS.Add_Info(lu_name_, msg_, load_file_id_);
   info_ := Client_SYS.Get_All_Info;
END Create_External_Input;


PROCEDURE Create_External_Output (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER  )
IS
   file_type_               VARCHAR2(30);
   file_template_id_        VARCHAR2(30);
   company_                 VARCHAR2(20);
   parameter_string_        VARCHAR2(2000);
   date_format_             Ext_File_Template_Tab.date_format%TYPE;
   row_no_                  NUMBER        := 0;
   view_name_               VARCHAR2(30);
   gview_name_              VARCHAR2(30);
   file_typex_              VARCHAR2(30)    := '%';
   file_template_idx_       VARCHAR2(30)    := '%';
   export_file_type_        VARCHAR2(5)     := 'FALSE';
   export_file_template_id_ VARCHAR2(5)     := 'FALSE';
   exist_file_type_         VARCHAR2(5)     := 'FALSE';
   exist_file_template_id_  VARCHAR2(5)     := 'FALSE';
   tmp_                     VARCHAR2(2000)  := NULL;
   dummy_                   VARCHAR2(10)    := '<DUMMY>';
   parameter_attr_          VARCHAR2(2000);
   client_server_           VARCHAR2(1)     := 'C';
   create_output_ok_        VARCHAR2(5);
   file_name_               VARCHAR2(2000);
   --
   CURSOR Getload_info IS
      SELECT parameter_string,
             file_type,
             file_template_id,
             company,
             file_name_
      FROM   Ext_File_Load_Tab
      WHERE load_file_id = load_file_id_;
   CURSOR GetRecTypes IS
      SELECT DISTINCT
             G.record_type_id,
             G.first_in_record_set,
             G.last_in_record_set,
             G.view_name,
             G.parent_record_type
      FROM   Ext_File_Template_Detail_Tab D,
             Ext_File_Type_Rec_Tab G
      WHERE  D.file_template_id = file_template_id_
      AND    G.file_type        = D.file_type
      AND    G.record_type_id   = D.record_type_id
      AND    G.parent_record_type IS NULL
      ORDER BY DECODE(G.first_in_record_set,'TRUE',0,
                  DECODE(G.last_in_record_set,'TRUE',3,2)),
               G.record_type_id,
               G.parent_record_type;
BEGIN
   OPEN  Getload_info;
   FETCH Getload_info INTO parameter_string_,
                          file_type_,
                          file_template_id_,
                          company_,
                          file_name_;
   CLOSE Getload_info;
   view_name_   := Ext_File_Type_API.Get_View_Name ( file_type_ );
   date_format_ := Ext_File_Template_API.Get_Date_Format ( file_template_id_ );
   row_no_      := Ext_File_Trans_API.Get_Max_Row_No ( load_file_id_ ) - 1;
   parameter_attr_ := parameter_string_;
   IF (file_type_ = 'ExtFileExpImp') THEN
      tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                          'FILE_TYPEX',
                                          dummy_);
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         file_typex_ := tmp_;
      END IF;
      tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                          'FILE_TEMPLATE_IDX',
                                          dummy_);
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         file_template_idx_ := tmp_;
      END IF;
      tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                          'EXPORT_FILE_TYPE',
                                          dummy_);
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         export_file_type_ := tmp_;
      END IF;
      tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                          'EXPORT_FILE_TEMPLATE',
                                          dummy_);
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         export_file_template_id_ := tmp_;
      END IF;
      Message_SYS.Remove_Attribute ( parameter_string_, 'EXPORT_FILE_TYPE' );
      Message_SYS.Remove_Attribute ( parameter_string_, 'EXPORT_FILE_TEMPLATE' );
      Message_SYS.Remove_Attribute ( parameter_string_, 'FILE_DIRECTION_DB' );
   END IF;
   --
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'CLIENT_SERVER',
                                       dummy_);
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      client_server_ := tmp_;
   END IF;
   --
   FOR rec_ IN GetRecTypes LOOP
      Trace_SYS.Message ('***** Create_External_Output rec_.record_type_id : '||rec_.record_type_id);
      IF (rec_.view_name IS NOT NULL) THEN
         gview_name_ := rec_.view_name;
      ELSE
         gview_name_ := view_name_;
      END IF;
      parameter_attr_   := parameter_string_;
      create_output_ok_ := 'TRUE';
      IF (file_type_ = 'ExtFileExpImp') THEN
         exist_file_type_ := Ext_File_Type_rec_column_API.Check_Exist_Str ( file_type_,
                                                                        rec_.record_type_id,
                                                                        'FILE_TYPE' );
         exist_file_template_id_ := Ext_File_Type_rec_column_API.Check_Exist_Str ( file_type_,
                                                                               rec_.record_type_id,
                                                                               'FILE_TEMPLATE_ID' );
         IF (exist_file_type_ = 'FALSE') THEN
            Message_SYS.Remove_Attribute ( parameter_attr_, 'FILE_TYPEX' );
         END IF;
         IF (exist_file_template_id_ = 'FALSE') THEN
            Message_SYS.Remove_Attribute ( parameter_attr_, 'FILE_TEMPLATE_IDX' );
         END IF;
         -- File Type should not be exported
         IF (export_file_type_ = 'FALSE' AND exist_file_template_id_ = 'FALSE') THEN
            create_output_ok_ := 'FALSE';
         END IF;
         -- File Template should not be exported
         IF (export_file_template_id_ = 'FALSE' AND exist_file_template_id_ = 'TRUE') THEN
            create_output_ok_ := 'FALSE';
         END IF;
      END IF;
      IF (create_output_ok_ = 'TRUE') THEN
         Create_External_Output ( info_,
                                  load_file_id_,
                                  file_type_,
                                  file_template_id_,
                                  company_,
                                  parameter_attr_,
                                  date_format_,
                                  row_no_,
                                  rec_.record_type_id,
                                  gview_name_ );
      END IF;
   END LOOP;
   --
END Create_External_Output;


PROCEDURE Create_External_Output (
   info_                IN OUT VARCHAR2,
   load_file_id_        IN     NUMBER,
   file_type_           IN     VARCHAR2,
   file_template_id_    IN     VARCHAR2,
   company_             IN     VARCHAR2,
   parameter_string_    IN     VARCHAR2,
   date_format_         IN     VARCHAR2,
   row_no_              IN OUT NUMBER,
   record_type_id_      IN     VARCHAR2,
   view_name_           IN     VARCHAR2,
   where_in_            IN     VARCHAR2 DEFAULT NULL )
IS
   TYPE RecordType IS REF CURSOR;
   rec_                       RecordType;
   trec_                      Ext_File_Trans_Tab%ROWTYPE;
   tmp_                       VARCHAR2(2000) := NULL;
   dummy_                     VARCHAR2(10)   := '<DUMMY>';
   stmnt_                     VARCHAR2(32000);
   from_string_               VARCHAR2(32000);
   where_                     VARCHAR2(2000);
   order_                     VARCHAR2(2000);
   set_id_                    VARCHAR2(20)   := NULL;
   c_data_type_               VARCHAR2(10);
   c_data_length_             NUMBER;        
   c_column_id_               VARCHAR2(200); 
   is_parent_record_type_     VARCHAR2(5);
   ext_file_rec_              External_File_Utility_API.ExtFileRec;
   --
   CURSOR GetColumns IS
      SELECT d.column_id                    column_id,
             d.date_format                  date_format,
             c.destination_column           destination_column
      FROM   ext_file_template_detail_tab d,
             ext_file_template_tab        t,
             ext_file_type_rec_column_tab c
      WHERE  d.file_template_id = file_template_id_
      AND    d.record_type_id   = record_type_id_
      AND    t.file_template_id = d.file_template_id
      AND    c.file_type        = t.file_type
      AND    c.record_type_id   = d.record_type_id
      AND    c.column_id        = d.column_id
      ORDER BY d.row_no;
   CURSOR GetColProp (view_name_   IN VARCHAR2,
                      column_name_ IN VARCHAR2) IS
      SELECT data_type,
             data_length
      FROM   user_tab_columns
      WHERE  table_name  = view_name_
      AND    column_name = column_name_;
BEGIN
   --Trace_SYS.Message ('***** Create_External_Output record_type_id_ : '||record_type_id_);
   Ext_File_Template_API.Get_Ext_File_Head ( ext_file_rec_,
                                             file_template_id_,
                                             '2');
   where_ := NULL;
   tmp_ := Message_SYS.Find_Attribute (parameter_string_,
                                       'SET_ID',
                                       dummy_);
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      set_id_ := tmp_;
   END IF;
   IF (Ext_File_Template_Detail_API.Check_Multi_Record_Type (file_template_id_) = 'FALSE') THEN
      is_parent_record_type_ := 'FALSE';
   ELSE
      is_parent_record_type_ := Ext_File_Type_Rec_API.Check_If_Parent (file_type_, record_type_id_);
   END IF;
   IF (where_in_ IS NOT NULL) THEN
      where_ := where_in_;
   ELSE
      IF (set_id_ IS NOT NULL) THEN
         Ext_File_Message_API.Create_Out_Where ( where_,
                                                 parameter_string_,
                                                 file_type_,
                                                 date_format_,
                                                 view_name_,
                                                 set_id_ );
      END IF;
   END IF;
   --Trace_SYS.Message ('***** where_ : '||where_);
   order_ := NULL;
   tmp_ := Message_SYS.Find_Attribute (parameter_string_,
                                       'ORDER_BY',
                                       dummy_);
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      order_ := 'ORDER BY ' || tmp_;
   END IF;
   from_string_ := '*,C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,' ||
                   'C21,C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,C32,C33,C34,C35,C36,C37,C38,C39,C40,' ||
                   'C41,C42,C43,C44,C45,C46,C47,C48,C49,C50,C51,C52,C53,C54,C55,C56,C57,C58,C59,C60,' ||
                   'C61,C62,C63,C64,C65,C66,C67,C68,C69,C70,C71,C72,C73,C74,C75,C76,C77,C78,C79,C80,' ||
                   'C81,C82,C83,C84,C85,C86,C87,C88,C89,C90,C91,C92,C93,C94,C95,C96,C97,C98,C99,' ||
                   'C100,C101,C102,C103,C104,C105,C106,C107,C108,C109,C110,C111,C112,C113,C114,C115,C116,C117,C118,C119,C120,' ||
                   'C121,C122,C123,C124,C125,C126,C127,C128,C129,C130,C131,C132,C133,C134,C135,C136,C137,C138,C139,C140,' ||
                   'C141,C142,C143,C144,C145,C146,C147,C148,C149,C150,C151,C152,C153,C154,C155,C156,C157,C158,C159,C160,' ||
                   'C161,C162,C163,C164,C165,C166,C167,C168,C169,C170,C171,C172,C173,C174,C175,C176,C177,C178,C179,C180,' ||
                   'C181,C182,C183,C184,C185,C186,C187,C188,C189,C190,C191,C192,C193,C194,C195,C196,C197,C198,C199,' ||
                   'N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,N10,N11,N12,N13,N14,N15,N16,N17,N18,N19,N20,' ||
                   'N21,N22,N23,N24,N25,N26,N27,N28,N29,N30,N31,N32,N33,N34,N35,N36,N37,N38,N39,N40,' ||
                   'N41,N42,N43,N44,N45,N46,N47,N48,N49,N50,N51,N52,N53,N54,N55,N56,N57,N58,N59,N60,' ||
                   'N61,N62,N63,N64,N65,N66,N67,N68,N69,N70,N71,N72,N73,N74,N75,N76,N77,N78,N79,N80,' ||
                   'N81,N82,N83,N84,N85,N86,N87,N88,N89,N90,N91,N92,N93,N94,N95,N96,N97,N98,N99,' ||
                   'D1,D2,D3,D4,D5,D6,D7,D8,D9,D10,D11,D12,D13,D14,D15,D16,D17,D18,D19,D20,*';
   stmnt_ := 'SELECT ';
   --
   FOR col_rec_ IN GetColumns LOOP
       IF (Check_View_Col_Exist___ ( view_name_, col_rec_.column_id) = 'TRUE' ) THEN
         c_column_id_ := col_rec_.column_id;
         OPEN  GetColProp ( view_name_, c_column_id_ );
         FETCH GetColProp INTO c_data_type_, c_data_length_;
         IF (GetColProp%FOUND) THEN
            IF (c_data_type_ IN ('CHAR','VARCHAR2') AND c_data_length_ > 2000) THEN
               c_column_id_ := 'SUBSTR('||c_column_id_||',1,2000)';
            END IF;
         END IF;
         CLOSE GetColProp;
         from_string_ := REPLACE(from_string_, ',' || col_rec_.destination_column || ',' ,',#' || c_column_id_ || ',');
      ELSE
         from_string_ := REPLACE(from_string_, ',' || col_rec_.destination_column || ',' ,',NULL,');
      END IF;
   END LOOP;
   --
   FOR i_ IN 0 .. 199 LOOP
      from_string_ := REPLACE(from_string_,',C'|| TO_CHAR(i_)|| ',' , ','||CHR(39)||CHR(39)||',');
      from_string_ := REPLACE(from_string_,',N'|| TO_CHAR(i_)|| ',' , ','||CHR(39)||CHR(39)||',');
      from_string_ := REPLACE(from_string_,',D'|| TO_CHAR(i_)|| ',' , ','||CHR(39)||CHR(39)||',');
   END LOOP;
   --
   from_string_ := REPLACE(from_string_,'#');
   from_string_ := REPLACE(from_string_,'*,');
   from_string_ := REPLACE(from_string_,',*');
   stmnt_ := stmnt_ || from_string_ || ' FROM ' || view_name_ || ' a ' || where_ || ' ' || order_;
   --   
   @ApproveDynamicStatement(2006-01-27,jeguse)
   OPEN rec_ FOR stmnt_;
   LOOP
      FETCH rec_ INTO trec_.C0, trec_.C1, trec_.C2, trec_.C3, trec_.C4, trec_.C5, trec_.C6, trec_.C7, trec_.C8, trec_.C9, trec_.C10,
                      trec_.C11,trec_.C12,trec_.C13,trec_.C14,trec_.C15,trec_.C16,trec_.C17,trec_.C18,trec_.C19,trec_.C20,
                      trec_.C21,trec_.C22,trec_.C23,trec_.C24,trec_.C25,trec_.C26,trec_.C27,trec_.C28,trec_.C29,trec_.C30,
                      trec_.C31,trec_.C32,trec_.C33,trec_.C34,trec_.C35,trec_.C36,trec_.C37,trec_.C38,trec_.C39,trec_.C40,
                      trec_.C41,trec_.C42,trec_.C43,trec_.C44,trec_.C45,trec_.C46,trec_.C47,trec_.C48,trec_.C49,trec_.C50,
                      trec_.C51,trec_.C52,trec_.C53,trec_.C54,trec_.C55,trec_.C56,trec_.C57,trec_.C58,trec_.C59,trec_.C60,
                      trec_.C61,trec_.C62,trec_.C63,trec_.C64,trec_.C65,trec_.C66,trec_.C67,trec_.C68,trec_.C69,trec_.C70,
                      trec_.C71,trec_.C72,trec_.C73,trec_.C74,trec_.C75,trec_.C76,trec_.C77,trec_.C78,trec_.C79,trec_.C80,
                      trec_.C81,trec_.C82,trec_.C83,trec_.C84,trec_.C85,trec_.C86,trec_.C87,trec_.C88,trec_.C89,trec_.C90,
                      trec_.C91,trec_.C92,trec_.C93,trec_.C94,trec_.C95,trec_.C96,trec_.C97,trec_.C98,trec_.C99,trec_.C100,
                      trec_.C101, trec_.C102, trec_.C103, trec_.C104, trec_.C105, trec_.C106, trec_.C107, trec_.C108, trec_.C109, trec_.C110,
                      trec_.C111,trec_.C112,trec_.C113,trec_.C114,trec_.C115,trec_.C116,trec_.C117,trec_.C118,trec_.C119,trec_.C120,
                      trec_.C121,trec_.C122,trec_.C123,trec_.C124,trec_.C125,trec_.C126,trec_.C127,trec_.C128,trec_.C129,trec_.C130,
                      trec_.C131,trec_.C132,trec_.C133,trec_.C134,trec_.C135,trec_.C136,trec_.C137,trec_.C138,trec_.C139,trec_.C140,
                      trec_.C141,trec_.C142,trec_.C143,trec_.C144,trec_.C145,trec_.C146,trec_.C147,trec_.C148,trec_.C149,trec_.C150,
                      trec_.C151,trec_.C152,trec_.C153,trec_.C154,trec_.C155,trec_.C156,trec_.C157,trec_.C158,trec_.C159,trec_.C160,
                      trec_.C161,trec_.C162,trec_.C163,trec_.C164,trec_.C165,trec_.C166,trec_.C167,trec_.C168,trec_.C169,trec_.C170,
                      trec_.C171,trec_.C172,trec_.C173,trec_.C174,trec_.C175,trec_.C176,trec_.C177,trec_.C178,trec_.C179,trec_.C180,
                      trec_.C181,trec_.C182,trec_.C183,trec_.C184,trec_.C185,trec_.C186,trec_.C187,trec_.C188,trec_.C189,trec_.C190,
                      trec_.C191,trec_.C192,trec_.C193,trec_.C194,trec_.C195,trec_.C196,trec_.C197,trec_.C198,trec_.C199,
                      trec_.N0, trec_.N1, trec_.N2, trec_.N3, trec_.N4, trec_.N5, trec_.N6, trec_.N7, trec_.N8, trec_.N9, trec_.N10,
                      trec_.N11,trec_.N12,trec_.N13,trec_.N14,trec_.N15,trec_.N16,trec_.N17,trec_.N18,trec_.N19,trec_.N20,
                      trec_.N21,trec_.N22,trec_.N23,trec_.N24,trec_.N25,trec_.N26,trec_.N27,trec_.N28,trec_.N29,trec_.N30,
                      trec_.N31,trec_.N32,trec_.N33,trec_.N34,trec_.N35,trec_.N36,trec_.N37,trec_.N38,trec_.N39,trec_.N40,
                      trec_.N41,trec_.N42,trec_.N43,trec_.N44,trec_.N45,trec_.N46,trec_.N47,trec_.N48,trec_.N49,trec_.N50,
                      trec_.N51,trec_.N52,trec_.N53,trec_.N54,trec_.N55,trec_.N56,trec_.N57,trec_.N58,trec_.N59,trec_.N60,
                      trec_.N61,trec_.N62,trec_.N63,trec_.N64,trec_.N65,trec_.N66,trec_.N67,trec_.N68,trec_.N69,trec_.N70,
                      trec_.N71,trec_.N72,trec_.N73,trec_.N74,trec_.N75,trec_.N76,trec_.N77,trec_.N78,trec_.N79,trec_.N80,
                      trec_.N81,trec_.N82,trec_.N83,trec_.N84,trec_.N85,trec_.N86,trec_.N87,trec_.N88,trec_.N89,trec_.N90,
                      trec_.N91,trec_.N92,trec_.N93,trec_.N94,trec_.N95,trec_.N96,trec_.N97,trec_.N98,trec_.N99,
                      trec_.D1, trec_.D2, trec_.D3, trec_.D4, trec_.D5, trec_.D6, trec_.D7, trec_.D8, trec_.D9, trec_.D10,
                      trec_.D11,trec_.D12,trec_.D13,trec_.D14,trec_.D15,trec_.D16,trec_.D17,trec_.D18,trec_.D19,trec_.D20;
      EXIT WHEN rec_%NOTFOUND;
      row_no_ := row_no_ + 1;
      trec_.load_file_id   := load_file_id_;
      trec_.row_no         := row_no_;
      trec_.record_type_id := record_type_id_;
      trec_.row_state      := '1';
      trec_.Rowversion     := SYSDATE;
      Trace_SYS.Message ('***** Create_External_Output trec_.record_type_id : '||trec_.record_type_id);
      Ext_File_Trans_API.Insert_Record ( trec_ );
      IF (is_parent_record_type_ = 'TRUE') THEN
         Create_External_Output_Det ( info_,
                                      load_file_id_,
                                      file_type_,
                                      file_template_id_,
                                      company_,
                                      parameter_string_,
                                      date_format_,
                                      row_no_,
                                      record_type_id_,
                                      trec_ );
      END IF;
   END LOOP;
   CLOSE rec_;
   --
   Ext_File_Load_API.Update_State (load_file_id_, '2');
END Create_External_Output;


PROCEDURE Start_Api_To_Call (
   info_         IN OUT VARCHAR2,
   load_file_id_ IN     NUMBER )
IS
   api_to_call_         VARCHAR2(200);
   package_method_      VARCHAR2(200); 
   point_               NUMBER;
   package_name_        VARCHAR2(30);
   method_name_         VARCHAR2(30);
   stmnt_               VARCHAR2(2000);
   load_state_          VARCHAR2(200);
   err_msg_             VARCHAR2(2000);
   row_state1_          VARCHAR2(5);
   row_state2_          VARCHAR2(5);
   row_state3_          VARCHAR2(5);
   row_state4_          VARCHAR2(5);
   row_state5_          VARCHAR2(5);
   translate_           VARCHAR2(2000);
   ext_file_load_rec_   Ext_File_Load_API.Public_Rec;
BEGIN
   Client_SYS.Clear_Info;
   ext_file_load_rec_ := Ext_File_Load_API.Get( load_file_id_ );

   IF (ext_file_load_rec_.file_direction = '1') THEN
      IF (ext_file_load_rec_.state != '3' ) THEN
         load_state_ := Ext_File_State_API.Decode(ext_file_load_rec_.state);
         Error_SYS.Record_General( lu_name_, 'EXTLOADNOTUNP: Load File ID :P1 has wrong state :P2', load_file_id_, load_state_ );
      END IF;
      IF (Ext_File_Trans_API.Check_Exist_Row_State ( load_file_id_, '4')) THEN
         load_state_ := Ext_File_Row_State_API.Decode ('4');
         Error_SYS.Record_General( lu_name_, 'EXTLOADERREX: Load File ID :P1 contains rows with state :P2', load_file_id_, load_state_ );
      END IF;
   END IF;
   api_to_call_      := Ext_File_Template_Dir_API.Get_Api_To_Call ( ext_file_load_rec_.file_template_id, File_Direction_API.Decode(ext_file_load_rec_.file_direction ));
   package_method_   := api_to_call_;
   point_            := INSTR(package_method_,'.');
   IF (point_ = 0 OR api_to_call_ IS NULL) THEN
      Error_SYS.Appl_General( lu_name_, 'ATCERROR: Illegal Api To Call' );
   ELSE
      package_name_ := LTRIM(RTRIM(SUBSTR(package_method_,1,point_-1)));
      method_name_  := LTRIM(RTRIM(SUBSTR(package_method_,point_+1)));
   END IF;
   IF (NOT Dictionary_SYS.Method_Is_Active ( package_name_,
                                             method_name_ )) THEN
      Error_SYS.Appl_General( lu_name_, 'NOMETHOD: Method :P1 not found in package :P2',method_name_,package_name_ );
   ELSE
      Assert_SYS.Assert_Is_Package_Method(package_method_);
      stmnt_ := 'BEGIN ' || package_method_ || ' (:info_, :load_file_id_); END;';
      @ApproveDynamicStatement(2005-12-05,ovjose)
      EXECUTE IMMEDIATE stmnt_ USING IN OUT info_, 
                                     IN     load_file_id_;
   END IF;
   IF (ext_file_load_rec_.file_direction = '1') THEN
      load_state_ := Ext_File_Load_API.Get_State_Db ( load_file_id_ );
      row_state1_ := Ext_File_Trans_API.Check_Exist_Row_State2 ( load_file_id_, '1');
      row_state2_ := Ext_File_Trans_API.Check_Exist_Row_State2 ( load_file_id_, '2');
      row_state3_ := Ext_File_Trans_API.Check_Exist_Row_State2 ( load_file_id_, '3');
      row_state4_ := Ext_File_Trans_API.Check_Exist_Row_State2 ( load_file_id_, '4');
      row_state5_ := Ext_File_Trans_API.Check_Exist_Row_State2 ( load_file_id_, '5');
      IF ((row_state3_ = 'TRUE' AND row_state1_ = 'TRUE') OR
          (row_state3_ = 'TRUE' AND row_state2_ = 'TRUE') OR
          (row_state3_ = 'TRUE' AND row_state4_ = 'TRUE') OR
          (row_state3_ = 'TRUE' AND row_state5_ = 'TRUE')) THEN
         load_state_ := '10';
      ELSIF (row_state5_ = 'TRUE' ) THEN
         load_state_ := '9';
      END IF;
      IF (load_state_ IN ('9','10')) THEN
         Ext_File_Load_API.Update_State (load_file_id_, load_state_);
      END IF;
      err_msg_    := NULL;
      IF (load_state_ = '3') THEN
         err_msg_ := 'NOTTRANSF: Load File ID :P1 is not transferred.';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'NOTTRANSF: Load File ID :P1 is not transferred.');
      ELSIF (load_state_ = '4') THEN
         err_msg_ := 'TRANSFNOERR: Load File ID :P1 is transferred without errors.';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'TRANSFNOERR: Load File ID :P1 is transferred without errors.');
      ELSIF (load_state_ = '5') THEN
         err_msg_ := 'TRANSFABORT: Load File ID :P1 transfer is aborted.';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'TRANSFABORT: Load File ID :P1 transfer is aborted.');
      ELSIF (load_state_ = '9') THEN
         err_msg_ := 'TRANSFERERR: Load File ID :P1 is transferred with errors.';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'TRANSFERERR: Load File ID :P1 is transferred with errors.');
      ELSIF (load_state_ = '10') THEN
         err_msg_ := 'PARTLYTRANSF: Load File ID :P1 is partly transferred.';
         translate_  := Language_SYS.Translate_Constant(lu_name_,'PARTLYTRANSF: Load File ID :P1 is partly transferred.');
      END IF;
      IF (err_msg_ IS NOT NULL) THEN
         Client_SYS.Add_Info(lu_name_, err_msg_, load_file_id_);
         info_ := Client_SYS.Get_All_Info || info_;
      END IF;
   END IF;
END Start_Api_To_Call;


PROCEDURE Copy_File_Type_From_Type (
   file_type_       IN VARCHAR2,
   type_desc_       IN VARCHAR2,
   from_file_type_  IN VARCHAR2 )
IS
   typrec_             Ext_File_Type_Tab%ROWTYPE;
   colrec_             Ext_File_Type_Rec_Column_Tab%ROWTYPE;
   grprec_             Ext_File_Type_Rec_Tab%ROWTYPE;
   paramrec_           Ext_File_Type_Param_Tab%ROWTYPE;
   paramsrec_          Ext_Type_Param_Set_Tab%ROWTYPE;
   parampsrec_         Ext_Type_Param_Per_Set_Tab%ROWTYPE;
   CURSOR GetType IS
      SELECT *
      FROM   Ext_File_Type_Tab T
      WHERE  T.file_type = from_file_type_;
   CURSOR GetGroups IS
      SELECT *
      FROM   Ext_File_Type_Rec_Tab G
      WHERE  G.file_type = from_file_type_;
   CURSOR GetDetails IS
      SELECT *
      FROM   Ext_File_Type_Rec_Column_Tab D
      WHERE  D.file_type = from_file_type_;
   CURSOR GetParams IS
      SELECT *
      FROM   Ext_File_Type_Param_Tab
      WHERE  file_type = from_file_type_;
   CURSOR GetParamSets IS
      SELECT *
      FROM   Ext_Type_Param_Set_Tab
      WHERE  file_type = from_file_type_;
   CURSOR GetParamPerSet IS
      SELECT *
      FROM   Ext_Type_Param_Per_Set_Tab
      WHERE  file_type = from_file_type_;
BEGIN
   IF NOT (Ext_File_Type_API.Exists( from_file_type_ )) THEN
      Error_SYS.Appl_General(lu_name_, 'FILETYPEEXIST: External file type :P1 does not exist.', from_file_type_);
   END IF;
   Ext_File_Type_API.Already_Exist ( file_type_ );
   OPEN  GetType;
   FETCH GetType INTO typrec_;
   CLOSE GetType;
   typrec_.file_type      := file_type_;
   typrec_.description    := type_desc_;
   typrec_.system_defined := 'FALSE';
   typrec_.rowversion     := SYSDATE;
   -- clear projection actions used for security checks.
   typrec_.input_projection_action := NULL;
   typrec_.output_projection_action := NULL;
   Ext_File_Type_API.Insert_Record ( typrec_ );
   FOR rec_ IN GetGroups LOOP
      grprec_.file_type           := file_type_;
      grprec_.record_type_id      := rec_.record_type_id;
      grprec_.record_set_id       := rec_.record_set_id;
      grprec_.first_in_record_set := rec_.first_in_record_set;
      grprec_.last_in_record_set  := rec_.last_in_record_set;
      grprec_.mandatory_record    := rec_.mandatory_record;
      grprec_.description         := NVL(RTRIM(RPAD(Basic_Data_Translation_API.Get_Basic_Data_Translation('ACCRUL', 'ExtFileTypeRec', rec_.file_type || '^' || rec_.record_type_id ),100)),rec_.description);
      grprec_.parent_record_type  := rec_.parent_record_type;
      grprec_.rowversion          := SYSDATE;
      Ext_File_Type_Rec_API.Insert_Record ( grprec_ );
   END LOOP;
   FOR rec_ IN GetDetails LOOP
      colrec_.file_type          := file_type_;
      colrec_.record_type_id     := rec_.record_type_id;
      colrec_.column_id          := rec_.column_id;
      colrec_.mandatory          := rec_.mandatory;
      colrec_.destination_column := rec_.destination_column;
      colrec_.data_type          := rec_.data_type;
      colrec_.description        := NVL(RTRIM(RPAD(Basic_Data_Translation_API.Get_Basic_Data_Translation('ACCRUL', 'ExtFileTypeRecColumn', rec_.file_type || '^' || rec_.record_type_id || '^' || rec_.column_id ),100)),rec_.description);
      colrec_.rowversion         := SYSDATE;
      Ext_File_Type_Rec_Column_API.Insert_Record ( colrec_ );
   END LOOP;
   FOR rec_ IN GetParams LOOP
      paramrec_.file_type         := file_type_;
      paramrec_.param_no          := rec_.param_no;
      paramrec_.param_id          := rec_.param_id;
      paramrec_.description       := NVL(RTRIM(RPAD(Basic_Data_Translation_API.Get_Basic_Data_Translation('ACCRUL', 'ExtFileTypeParam', rec_.file_type || '^' || rec_.param_no ),100)),rec_.description);
      paramrec_.lov_view          := rec_.lov_view;
      paramrec_.enumerate_method  := rec_.enumerate_method;
      paramrec_.validate_method   := rec_.validate_method;
      paramrec_.browsable_field   := rec_.browsable_field;
      paramrec_.help_text         := NVL(RTRIM(RPAD(Basic_Data_Translation_API.Get_Basic_Data_Translation('ACCRUL', 'ExtFileTypeParam', rec_.file_type || '^' || rec_.param_no || '^' || 'HELP'),200)),rec_.help_text);
      paramrec_.data_type         := rec_.data_type;
      paramrec_.rowversion        := SYSDATE;
      Ext_File_Type_Param_API.Insert_Record ( paramrec_ );
   END LOOP;
   FOR rec_ IN GetParamSets LOOP
      paramsrec_.file_type        := file_type_;
      paramsrec_.set_id           := rec_.set_id;
      paramsrec_.description      := rec_.description;
      paramsrec_.set_id_default   := rec_.set_id_default;
      paramsrec_.rowversion       := SYSDATE;
      Ext_Type_Param_Set_API.Insert_Record ( paramsrec_ );
   END LOOP;
   FOR rec_ IN GetParamPerSet LOOP
      parampsrec_.file_type         := file_type_;
      parampsrec_.param_no          := rec_.param_no;
      parampsrec_.set_id            := rec_.set_id;
      parampsrec_.default_value     := rec_.default_value;
      parampsrec_.mandatory_param   := rec_.mandatory_param;
      parampsrec_.show_at_load      := rec_.show_at_load;
      parampsrec_.inputable_at_load := rec_.inputable_at_load;
      parampsrec_.rowversion        := SYSDATE;
      Ext_Type_Param_Per_Set_API.Insert_Record ( parampsrec_ );
   END LOOP;
END Copy_File_Type_From_Type;


FUNCTION Check_If_View2 (
   view_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_If_View ( view_name_ ) ) THEN
      RETURN 'TRUE';
   END IF;
   RETURN 'FALSE';
END Check_If_View2;


PROCEDURE Pack_Out_Ext_Line (
   file_type_              IN VARCHAR2,
   file_template_id_       IN VARCHAR2,
   load_file_id_           IN NUMBER,
   company_                IN VARCHAR2 DEFAULT NULL )
IS
   templ_det_rec_              External_File_Utility_API.ft_m_det_rec;
   command_rec_                External_File_Utility_API.Command_Rec;
   --
   value_tab_                  External_File_Utility_API.ValueTabType;
   record_set_no_             NUMBER := 0;
   record_type_id_            VARCHAR2(20);
   use_line_                  VARCHAR2(5);
   skipped_line_              VARCHAR2(5);
   invalid_line_              VARCHAR2(5);
   err_msg_                   VARCHAR2(2000);
   first_line_                VARCHAR2(5)    := 'TRUE';
   no_action                  EXCEPTION;
   row_state_                 VARCHAR2(1);
   --
   CURSOR GetFileTrans IS
      SELECT *
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       > 0.5
      ORDER BY row_no;
   transrec_                  Ext_File_Trans_Tab%ROWTYPE;
--
BEGIN
   -- Get File Template Data 
   templ_det_rec_.load_file_id                  := load_file_id_;
   templ_det_rec_.file_direction                := '2';
   Get_Template_Data (templ_det_rec_);
   --
   Clear_Value_Tab___ ( value_tab_, templ_det_rec_.max_ft );
   --
   IF (templ_det_rec_.max_ft > 0) THEN
      --
      IF (err_msg_ IS NOT NULL) THEN
         Ext_File_Trans_API.Update_Row_State ( load_file_id_,
                                               '8',
                                               err_msg_ );
         Ext_File_Load_API.Update_State (load_file_id_, '5');
         RAISE no_action;
      END IF;
      --
      OPEN GetFileTrans;
      LOOP
         FETCH GetFileTrans INTO transrec_;
         EXIT WHEN GetFileTrans%NOTFOUND;
         err_msg_ := NULL;
         record_type_id_ := transrec_.record_type_id;
         IF (templ_det_rec_.max_gr <= 1 OR templ_det_rec_.max_cn = 0) THEN
            -- There is only one record_type_id defined in file template definition or no controls
            record_set_no_           := record_set_no_ + 1;
            transrec_.record_set_no  := record_set_no_;
            IF (transrec_.record_type_id IS NULL) THEN
               record_type_id_          := templ_det_rec_.gr_list(1).record_type_id;
               transrec_.record_type_id := record_type_id_;
            END IF;
         END IF;
         templ_det_rec_.transrec := transrec_;
         use_line_              := 'TRUE';
         -- New Column function handling start
         IF (templ_det_rec_.max_cf > 0) THEN
            Trace_SYS.Message ('Before Unp_Column_Function___');
            Unp_Column_Function___ (err_msg_,
                                    row_state_,
                                    templ_det_rec_,
                                    command_rec_);
         END IF;
         -- New Column function handling end
         IF (templ_det_rec_.max_cn > 0) THEN
            record_type_id_ := transrec_.record_type_id;
            Trace_SYS.Message ('Before Control_Out_Ext_File___');
            Control_Out_Ext_File___ (err_msg_,
                                     use_line_,
                                     skipped_line_,
                                     invalid_line_,
                                     record_type_id_,
                                     templ_det_rec_);
            templ_det_rec_.transrec.record_type_id := record_type_id_;
         END IF;
         IF (err_msg_ IS NOT NULL) THEN
            Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                                 transrec_.row_no,
                                                 '8',
                                                 err_msg_);
         --IF (use_line_ = 'TRUE') THEN
         ELSIF (use_line_ = 'TRUE') THEN
            Trace_SYS.Message ('Before Col_To_Line___');
            Col_To_Line___ (templ_det_rec_,
                            record_type_id_,
                            first_line_);
         ELSE
            IF (skipped_line_ = 'TRUE') THEN
               Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                                    transrec_.row_no,
                                                    '9',
                                                    err_msg_);
            END IF;
         END IF;
      END LOOP;
      CLOSE GetFileTrans;
      --
   END IF;
   Ext_File_Load_API.Update_State (load_file_id_, '6');
EXCEPTION
   WHEN no_action THEN
      NULL;
   WHEN VALUE_ERROR THEN
      IF (GetFileTrans%ISOPEN) THEN
         CLOSE GetFileTrans;
      END IF;
      Error_SYS.Record_General(lu_name_, 'PACKVERR: Value Error detected');
END Pack_Out_Ext_Line;


PROCEDURE Unpack_Ext_Line ( 
   file_type_            IN     VARCHAR2,
   file_template_id_     IN     VARCHAR2,
   load_file_id_         IN     NUMBER,
   company_              IN     VARCHAR2 DEFAULT NULL )
IS
   unp_value_tab_             External_File_Utility_API.ValueTabType;
   value_tab_                 External_File_Utility_API.ValueTabType;
   templ_det_rec_             External_File_Utility_API.ft_m_det_rec;
   command_rec_               External_File_Utility_API.Command_Rec;
   g_curr_record_type_order_  NUMBER;
   g_prev_record_type_order_  NUMBER;
   g_curr_record_set_id_      VARCHAR2(20);
   g_prev_record_set_id_      VARCHAR2(20);
   g_curr_parent_record_type_ VARCHAR2(20);
   --
   use_line_                  VARCHAR2(5);
   skipped_line_              VARCHAR2(5);
   invalid_line_              VARCHAR2(5);
   record_type_id_            VARCHAR2(20);
   no_of_lines_               NUMBER;
   no_of_x_lines_             NUMBER;
   no_of_skipped_lines_       NUMBER    := 0;
   skipp_merge_               VARCHAR2(5);
   prev_record_type_id_       VARCHAR2(20);
   buffer_                    VARCHAR2(4000); 
   max_v_                     NUMBER := 0;  
   record_set_no_             NUMBER := 0;
   err_record_set_id_         VARCHAR2(20);
   row_state_                 VARCHAR2(2);
   mandatory_abort_           VARCHAR2(5);
   err_msg_                   VARCHAR2(2000);
   info_                      VARCHAR2(2000);
   old_parameter_string_      VARCHAR2(2000);
   --
   control_id_                VARCHAR2(200);
   control_id_abort_          VARCHAR2(5)   := 'FALSE';
   invalid_abort_             VARCHAR2(5)   := 'FALSE';
   no_action                  EXCEPTION;
   --
   CURSOR File_Trans IS
      SELECT *
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      ORDER BY row_no;
   --
BEGIN
   Client_SYS.Clear_Info;
   IF (NOT Ext_File_Trans_API.Check_Exist_File_Trans ( load_file_id_ ) ) THEN
      Error_SYS.Appl_General( lu_name_, 'NOTRANS: No transactions are loaded, unpack is not allowed' );
   ELSE
      IF ( Ext_File_Template_Detail_API.Check_Detail_Exist ( file_template_id_ ) = 'FALSE') THEN
         -- No File Template Details Exist, Set state to 'Unpacked'
         err_msg_ := Language_SYS.Translate_Constant (lu_name_, 'EXTNODET: No template details');
         Ext_File_Trans_API.Update_Row_State ( load_file_id_, '2', err_msg_ );
         Ext_File_Load_API.Update_State (load_file_id_, '3');
      ELSE
         IF ( Ext_File_Load_API.Get_State_Db ( load_file_id_ ) > '2') THEN
            Ext_File_Trans_API.Update_Columns_Null ( load_file_id_ );
         END IF;
         -- Get File Template Data 
         templ_det_rec_.load_file_id                  := load_file_id_;
         templ_det_rec_.file_direction                := '1';
         Get_Template_Data (templ_det_rec_);
         --
         IF (err_msg_ IS NOT NULL) THEN
            Ext_File_Trans_API.Update_Row_State ( load_file_id_, '4', err_msg_ );
            Ext_File_Load_API.Update_State (load_file_id_, '5');
            RAISE no_action;
         END IF;
         --
         Clear_Value_Tab ( value_tab_, templ_det_rec_.max_ft );
         --
         -- Execute "Api before Unpack" if specified
         IF (templ_det_rec_.ext_file_rec.api_to_call_unp_before IS NOT NULL) THEN
            Start_Api_Unp_Extra (info_,
                                 load_file_id_,
                                 'BEFORE',
                                 templ_det_rec_.ext_file_rec.api_to_call_unp_before,
                                 templ_det_rec_.ext_file_rec.api_to_call_unp_after);
         END IF;
         --
         FOR rec_ IN File_Trans LOOP
            templ_det_rec_.transrec := rec_;
            skipp_merge_           := 'FALSE';
            use_line_              := 'TRUE';
            err_msg_               := NULL;
            record_type_id_        := NULL;
            IF (no_of_skipped_lines_ > 0) THEN
               use_line_            := 'FALSE';
               no_of_skipped_lines_ := no_of_skipped_lines_ - 1;
               skipp_merge_         := 'TRUE';
            END IF;
            buffer_         := REPLACE(rec_.file_line,CHR(13));
            Trace_SYS.Message ('buffer_ : '||buffer_);
            -- Check if line is empty
            IF (buffer_ IS NULL) THEN
               err_msg_      := Language_SYS.Translate_Constant (lu_name_, 'EXTBUFEMP: File Line Is Empty');
               use_line_     := 'FALSE';
               skipped_line_ := 'TRUE';
            END IF;
            IF (use_line_ = 'TRUE') THEN
               -- Unpack a separated file
               IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
                  max_v_ := unp_value_tab_.COUNT;
                  IF (max_v_ > 0) THEN
                     Clear_Value_Tab ( unp_value_tab_, max_v_ );  
                  END IF;
                  Unp_Separated_File___ ( err_msg_,
                                          row_state_,
                                          unp_value_tab_,
                                          buffer_,
                                          templ_det_rec_.ext_file_rec);
                  IF (err_msg_ IS NOT NULL) THEN
                     use_line_     := 'FALSE';
                     invalid_line_ := 'TRUE';
                  END IF;
               END IF;
            END IF;
   
         -- Control if file-line should be used
         -- Return Use_line 'TRUE'=Use the line / 'FALSE'=Don't use the line
         -- Return Record_Type_Id to use testing what detail-parameters should be used
            IF (use_line_ = 'TRUE') THEN
               no_of_x_lines_ := 0;
               -- If Templ_Det_Rec.max_cn = 0, then there is no controls specified for the file
               IF (templ_det_rec_.max_cn > 0) THEN
                  --IF (Test_Input_Control ( c_Destination_Column_Tab ) = 'TRUE') THEN
                  Control_In_Ext_File___ (err_msg_,
                                          use_line_,
                                          skipped_line_,
                                          invalid_line_,
                                          record_type_id_ ,
                                          no_of_lines_,
                                          buffer_,
                                          templ_det_rec_,
                                          unp_value_tab_);
                  no_of_x_lines_ := NVL(no_of_lines_,1) - 1;
               END IF;
            END IF;

            IF (use_line_ = 'FALSE' AND 
                templ_det_rec_.ext_file_rec.abort_immediatly = 'TRUE') THEN              
               invalid_abort_ := 'TRUE';               
            END IF;

            IF (use_line_ = 'TRUE') THEN
               --
               -- parameter no_of_x_lines_ is set on file template control
               IF (no_of_x_lines_ > 0) THEN
                  Unp_Merge_Extra_Lines___ (err_msg_,
                                            row_state_,
                                            unp_value_tab_,
                                            buffer_,
                                            no_of_x_lines_,
                                            no_of_skipped_lines_,
                                            templ_det_rec_.ext_file_rec,
                                            load_file_id_,
                                            rec_.row_no);
               END IF;
               --
               IF (templ_det_rec_.max_gr > 1) THEN
                  -- There is more than one record_type_id defined in file definition
                  -- Check current record_type_id order
                  Unp_Control_Record_Types___ (mandatory_abort_,
                                               templ_det_rec_,
                                               record_type_id_,
                                               record_set_no_,
                                               prev_record_type_id_,
                                               g_curr_record_type_order_,
                                               g_prev_record_type_order_,
                                               g_curr_record_set_id_,
                                               g_prev_record_set_id_,
                                               g_curr_parent_record_type_,
                                               err_record_set_id_);
                  IF (mandatory_abort_ = 'TRUE') THEN
                     EXIT;
                  END IF;
               ELSE
                  -- There is only one record_type_id defined in file definition
                  record_set_no_       := record_set_no_ + 1;
                  record_type_id_      := templ_det_rec_.gr_list(1).record_type_id;
                  prev_record_type_id_ := record_type_id_;
               END IF;
               --
               -- Load value tab from columns or fixed positions
               IF (err_msg_ IS NULL) THEN
                  Unp_Load_Value_Tab___ (err_msg_,
                                         row_state_,
                                         templ_det_rec_,
                                         value_tab_,
                                         unp_value_tab_,
                                         buffer_,
                                         record_type_id_);
               END IF;
               --
               -- Control Identity Tests (Move to after column functions ???
               IF (err_msg_ IS NULL AND rec_.row_state != '3') THEN
                  Unp_Control_Id_Test___ (control_id_abort_,
                                          err_msg_,
                                          row_state_,
                                          templ_det_rec_,
                                          value_tab_,
                                          control_id_,
                                          record_type_id_);
               END IF;
               --
               -- Max Length Tests (Move to after column functions ???)
               IF (err_msg_ IS NULL AND rec_.row_state != '3') THEN
                  Unp_Max_Length_Test___ (err_msg_,
                                          row_state_,
                                          templ_det_rec_,
                                          value_tab_);
               END IF;
               --
               IF (err_msg_ IS NULL AND rec_.row_state != '3') THEN
                  IF (NVL(err_record_set_id_,' ') = g_curr_record_set_id_) THEN
                     err_msg_   := Language_SYS.Translate_Constant (lu_name_, 'EXTDUPREC: Duplicate Record Set Not Alowed');
                     row_state_ := '4';
                  ELSE
                     err_msg_   := NULL;
                     row_state_ := '2';
                  END IF;
               END IF;
               --
               -- Update table from unpacked file line
               IF (err_msg_ IS NULL AND rec_.row_state != '3') THEN
                  templ_det_rec_.transrec.use_line       := 'TRUE';
                  templ_det_rec_.transrec.record_type_id := record_type_id_;
                  templ_det_rec_.transrec.record_set_no  := record_set_no_;
                  templ_det_rec_.transrec.control_id     := control_id_;
                  templ_det_rec_.transrec.error_text     := err_msg_;
                  templ_det_rec_.transrec.row_state      := row_state_;
                  Tab_To_Table___ ( err_msg_,
                                    row_state_,
                                    templ_det_rec_,
                                    value_tab_ );
               END IF;
               -- Values from file is now updated to destination columns
               --
               -- New Column function handling start
               IF (err_msg_ IS NULL AND rec_.row_state != '3') THEN
                  IF (templ_det_rec_.max_cf > 0) THEN
                     Unp_Column_Function___ (err_msg_,
                                             row_state_,
                                             templ_det_rec_,
                                             command_rec_);
                  END IF;
               END IF;
               -- New Column function handling end
               --
               -- If any error has occured then update row_state and error message
               IF (err_msg_ IS NOT NULL AND rec_.row_state != '3') THEN
                  Ext_File_Trans_API.Update_Row_State (templ_det_rec_.transrec.load_file_id,
                                                       templ_det_rec_.transrec.row_no,
                                                       row_state_,
                                                       err_msg_);
                  -- Exit if abort immediatly is set
                  IF (templ_det_rec_.ext_file_rec.abort_immediatly = 'TRUE') THEN
                     invalid_abort_ := 'TRUE';
                     EXIT;
                  END IF;
               ELSE
                  Ext_File_Trans_API.Modify (templ_det_rec_.transrec);
               END IF;
               --
            ELSE
               IF (skipped_line_ = 'TRUE') THEN
                  IF (templ_det_rec_.ext_file_rec.log_skipped_lines = 'TRUE') THEN
                     IF (skipp_merge_ = 'FALSE') THEN
                        Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                                             rec_.row_no,
                                                             '6',
                                                             err_msg_);
                     END IF;
                  ELSE
                     Ext_File_Trans_API.Delete_File_Trans (load_file_id_, rec_.row_no);
                  END IF;
               END IF;
               IF (invalid_line_ = 'TRUE') THEN
                  IF (templ_det_rec_.ext_file_rec.log_invalid_lines = 'TRUE') THEN
                     Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                                          rec_.row_no,
                                                          '4',
                                                          err_msg_);
                     IF (templ_det_rec_.ext_file_rec.abort_immediatly = 'TRUE') THEN
                        invalid_abort_ := 'TRUE';
                     END IF;
                  ELSE
                     Ext_File_Trans_API.Delete_File_Trans (load_file_id_, rec_.row_no);
                  END IF;
               END IF;
            END IF;
            Clear_Value_Tab ( value_tab_, templ_det_rec_.max_ft );  
            g_prev_record_type_order_ := g_curr_record_type_order_;
            IF (record_type_id_ IS NOT NULL) THEN
               prev_record_type_id_   := record_type_id_;
            END IF;
            g_prev_record_set_id_     := g_curr_record_set_id_;
         END LOOP;
         
         -- Execute "Api after Unpack" if specified
         IF (invalid_abort_ = 'FALSE') THEN
            IF (templ_det_rec_.ext_file_rec.api_to_call_unp_after IS NOT NULL) THEN
               Start_Api_Unp_Extra (info_,
                                    load_file_id_,
                                    'AFTER',
                                    templ_det_rec_.ext_file_rec.api_to_call_unp_before,
                                    templ_det_rec_.ext_file_rec.api_to_call_unp_after);
            END IF;
         END IF;
         --
         IF (invalid_abort_ = 'FALSE' AND
             control_id_abort_ = 'FALSE') THEN
            -- First we have to check if previous record set was missing any mandatory records
            Check_Record_Type_Mandatory___ (mandatory_abort_,
                                            templ_det_rec_,
                                            g_prev_record_set_id_,
                                            record_set_no_);
            IF (mandatory_abort_ = 'FALSE' OR control_id_abort_ = 'FALSE') THEN
               Ext_File_Load_API.Update_State (load_file_id_, '3');
            END IF;
         ELSE
            Ext_File_Load_API.Update_State (load_file_id_, '5');
         END IF;
         old_parameter_string_ := Ext_File_Load_API.Get_Parameter_String (load_file_id_);
         IF (old_parameter_string_ != templ_det_rec_.parameter_string) THEN
            Ext_File_Load_API.Update_Parameter_String (load_file_id_, templ_det_rec_.parameter_string);
         END IF;
      END IF;
   END IF;
EXCEPTION
   WHEN no_action THEN
      NULL;
   WHEN VALUE_ERROR THEN
      Error_SYS.Record_General(lu_name_, 'INVDCOL: Invalid Number of Columns or  Invalid Decimal Sign in Load File');
END Unpack_Ext_Line;


PROCEDURE Store_File_Identities ( 
   load_file_id_ IN NUMBER )
IS
   ext_file_identity_rec_ Ext_File_Identity_Tab%ROWTYPE;
   CURSOR get_ext_file_trans IS
      SELECT control_id
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_state    = 2
      AND    control_id   IS NOT NULL
      ORDER BY row_no;
BEGIN
   IF (Ext_File_Trans_API.Check_Exist_Control_Id (load_file_id_)) THEN
      FOR trans_rec_ IN get_ext_file_trans LOOP
         ext_file_identity_rec_.load_file_id := load_file_id_;
         ext_file_identity_rec_.identity     := trans_rec_.control_id;
         Ext_File_Identity_API.Insert_Identity ( ext_file_identity_rec_ );
      END LOOP;
   END IF;
END Store_File_Identities;


PROCEDURE Copy_Def_From_File_Def (
   file_template_id_      IN VARCHAR2,
   template_desc_         IN VARCHAR2,
   from_file_template_id_ IN VARCHAR2 )
IS
   filrec_                   Ext_File_Template_Tab%ROWTYPE;
   info_                     VARCHAR2(2000);     
   CURSOR GetTempl IS
      SELECT *
      FROM   Ext_File_Template_Tab T
      WHERE  T.file_template_id = from_file_template_id_;
BEGIN
   IF NOT (Ext_File_Template_API.Exists( from_file_template_id_ )) THEN
      Error_SYS.Appl_General(lu_name_, 'FILETEMPLATEEXIST: External file template :P1 does not exist.', from_file_template_id_);
   END IF;
   Ext_File_Template_API.Already_Exist ( file_template_id_ );
   OPEN  GetTempl;
   FETCH GetTempl INTO filrec_;
   CLOSE GetTempl;
   filrec_.file_template_id := file_template_id_;
   filrec_.system_defined   := 'FALSE';
   filrec_.description      := template_desc_;
   filrec_.rowversion       := SYSDATE;
   Ext_File_Template_API.Insert_Record ( filrec_ );
   Ext_File_Template_Detail_API.Copy_File_Defintion ( file_template_id_, from_file_template_id_ );
   Ext_File_Templ_Det_Func_API.Copy_File_Function ( file_template_id_, from_file_template_id_ );
   IF (In_Ext_File_Template_Dir_API.Check_Rec_Exist ( file_template_id_ ) = 'FALSE') THEN
      In_Ext_File_Template_Dir_API.Copy_File_Defintion ( file_template_id_, from_file_template_id_ );
   END IF;
   IF (Out_Ext_File_Template_Dir_API.Check_Rec_Exist ( file_template_id_ ) = 'FALSE') THEN
      Out_Ext_File_Template_Dir_API.Copy_File_Defintion ( file_template_id_,
                                                          from_file_template_id_ );
   END IF;
   Ext_File_Template_Control_API.Copy_File_Control ( file_template_id_, from_file_template_id_ );
   Ext_File_Template_API.Update_Valid_Definition ( info_,                 -- 41113
                                                   file_template_id_,
                                                   'FALSE' );
END Copy_Def_From_File_Def;


PROCEDURE Copy_Def_From_File_Type (
   file_template_id_      IN VARCHAR2,
   template_desc_         IN VARCHAR2,
   file_type_             IN VARCHAR2,
   only_mandatory_        IN VARCHAR2 )
IS
   info_                      VARCHAR2(2000);    
   filrec_                    Ext_File_Template_Tab%ROWTYPE;
   detrec_                    Ext_File_Template_Detail_Tab%ROWTYPE;
   separator_id_              Ext_File_Template_Tab.separator_id%TYPE;
   decimal_symbol_            Ext_File_Template_Tab.decimal_symbol%TYPE;
   date_format_               Ext_File_Template_Tab.date_format%TYPE;
   row_no_                    NUMBER := 0;
   column_no_                 NUMBER := 0;
   record_type_id_            VARCHAR2(30) := NULL;
   CURSOR detail_ IS
      SELECT *
      FROM   Ext_File_Type_Rec_Column_Tab D
      WHERE  D.file_type = file_type_
      AND    DECODE(NVL(only_mandatory_,'FALSE'),'TRUE','TRUE',D.mandatory) = D.mandatory
      ORDER BY record_type_id,
               DECODE(column_id,'LINE_TYPE',0,'FILE_TYPE',1,'FILE_TEMPLATE_ID',2,3),
               destination_column;
BEGIN
   IF NOT (Ext_File_Type_API.Exists( file_type_ )) THEN
      Error_SYS.Appl_General(lu_name_, 'FILETYPEEXIST: External file type :P1 does not exist.', file_type_);
   END IF;
   Ext_File_Template_API.Already_Exist ( file_template_id_ );
   separator_id_               := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_SEPARATOR_ID');
   decimal_symbol_             := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DECIMAL_SYMBOL');
   date_format_                := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DATE_FORMAT');
   filrec_.file_template_id    := file_template_id_;
   filrec_.system_defined      := 'FALSE';
   filrec_.description         := template_desc_;
   filrec_.active_definition   := 'FALSE';
   filrec_.valid_definition    := 'TRUE';
   filrec_.separated           := 'TRUE';
   filrec_.file_format         := 'SEP';
   filrec_.separator_id        := NVL(separator_id_,'1');
   filrec_.decimal_symbol      := NVL(decimal_symbol_,'.');
   filrec_.date_format         := NVL(date_format_,'YYYY-MM-DD');
   filrec_.file_type           := file_type_;
   filrec_.rowversion          := SYSDATE;
   Ext_File_Template_API.Insert_Record ( filrec_ );
   FOR rec_ IN detail_ LOOP
      detrec_.file_template_id := file_template_id_;
      row_no_                  := row_no_ + 1;
      detrec_.row_no           := row_no_;
      detrec_.record_type_id   := rec_.record_type_id;
      detrec_.column_id        := rec_.column_id;
      IF (record_type_id_ IS NULL) THEN
         record_type_id_       := rec_.record_type_id;
         column_no_            := 0;
      END IF;
      IF (record_type_id_ != rec_.record_type_id) THEN
         record_type_id_       := rec_.record_type_id;
         column_no_            := 0;
      END IF;
      column_no_               := column_no_ + 1;
      detrec_.column_no        := column_no_;
      detrec_.file_type        := file_type_;
      detrec_.control_column   := 'FALSE';
      detrec_.hide_column      := 'FALSE';
      detrec_.column_sort      := NULL;
      detrec_.rowversion       := SYSDATE;
      Ext_File_Template_Detail_API.Insert_Record ( detrec_ );
   END LOOP;
   Ext_File_Template_API.Update_Valid_Definition ( info_,                 
                                                   file_template_id_,
                                                   'FALSE' );
END Copy_Def_From_File_Type;


FUNCTION Check_If_View (
   view_name_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   user_views
      WHERE  view_name = view_name_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_If_View;

FUNCTION Check_View_Col_Exist (
   view_name_   IN VARCHAR2,
   column_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS   
BEGIN
   RETURN Check_View_Col_Exist___(view_name_, column_name_);
END Check_View_Col_Exist;      

FUNCTION Get_Input_Package (
   view_name_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   input_package_ VARCHAR2(30);
   view_type_     VARCHAR2(1);
   view_name2_    Dictionary_Sys_View_Active.view_name%TYPE;

   CURSOR get_api IS
      SELECT d2.package_name
      FROM   Dictionary_Sys_View_Active d1,
             Dictionary_Sys_Package_Active d2
      WHERE  d1.lu_name   = d2.lu_name
      AND    d1.view_type = view_type_
      AND    d1.view_name = UPPER(view_name_)
      ORDER BY DECODE(d2.package_name,UPPER(view_name2_)||'_API',0,1);

BEGIN
   IF (UPPER(SUBSTR(view_name_,-4)) = '_UIV') THEN
      view_type_  := 'A';
      view_name2_ := SUBSTR(view_name_,1,LENGTH(view_name_)-4);
   ELSE
      view_type_  := 'B';
      view_name2_ := view_name_;
   END IF;
   OPEN  get_api;
   FETCH get_api INTO input_package_;
   IF (get_api%NOTFOUND) THEN
      input_package_ := NULL;
   END IF;
   CLOSE get_api;
   RETURN input_package_;
END Get_Input_Package;


FUNCTION Get_View_Column_Description (
   table_name_  IN VARCHAR2,
   column_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_        VARCHAR2(30);
   CURSOR GetDesc IS
      SELECT NVL(Dictionary_SYS.Comment_Value_('PROMPT',m.comments),INITCAP(c.column_name)) description
      FROM   user_tab_columns  c,
             user_col_comments m,
             user_views        w
      WHERE  c.table_name  = table_name_
      AND    c.column_name = column_name_
      AND    m.table_name  = c.table_name
      AND    m.column_name = c.column_name
      AND    w.view_name   = c.table_name;
BEGIN
   OPEN GetDesc;
   FETCH GetDesc INTO dummy_;
   IF (GetDesc%NOTFOUND) THEN
      dummy_ := NULL;
   END IF;
   CLOSE GetDesc;
   RETURN dummy_;
END Get_View_Column_Description;


PROCEDURE Create_Rec_Det_From_View (
   file_type_       IN VARCHAR2,
   view_name_       IN VARCHAR2,
   input_package_   IN VARCHAR2,
   record_type_id_  IN VARCHAR2,
   component_       IN VARCHAR2 DEFAULT NULL )
IS
   colrec_             Ext_File_Type_Rec_Column_Tab%ROWTYPE;
   c_                  NUMBER := 0;
   n_                  NUMBER := 0;
   d_                  NUMBER := 0;
   i_                  NUMBER := 0;
   col_ok_             VARCHAR2(5);
   destination_column_ VARCHAR2(3);
   detrec_             Ext_File_Template_Detail_Tab%ROWTYPE;
   cnt_file_template_  NUMBER;
   file_template_id_   VARCHAR2(30);
   CURSOR detail_ IS
      SELECT c.column_id,
             c.column_name,
             DECODE(SUBSTR(c.data_type,1,1),'N','2','D','3','1') data_type,
             SUBSTR(c.data_type,1,1)                             destination_type,
             NVL(Dictionary_SYS.Comment_Value_('PROMPT',m.comments),INITCAP(c.column_name)) 
                                                                 description,
             Dictionary_SYS.Comment_Value_('FLAGS',m.comments)   flags,
             DECODE(SUBSTR(Dictionary_SYS.Comment_Value_('FLAGS',m.comments),2,1),'M','TRUE','FALSE') 
                                                                 mandatory_column,
             DECODE(SUBSTR(Dictionary_SYS.Comment_Value_('FLAGS',m.comments),1,1),'P','TRUE','K','TRUE','FALSE') 
                                                                 key_column
      FROM   user_tab_columns  c,
             user_col_comments m,
             user_views        w
      WHERE  c.table_name  = view_name_
      AND    c.column_name NOT IN ('OBJID','OBJVERSION')
      AND    m.table_name  = c.table_name
      AND    m.column_name = c.column_name
      AND    w.view_name   = c.table_name
      ORDER BY column_id;
BEGIN

   IF (component_ IS NOT NULL) THEN
      MODULE_API.Check_Active(component_);
   END IF;

   cnt_file_template_   := Ext_File_Template_API.Count_Usable_File_Template (file_type_);
   IF (cnt_file_template_ = 1) THEN
      file_template_id_ := Ext_File_Template_API.Get_File_Template_Id (file_type_);
   END IF;
   
   IF (Check_If_View ( view_name_ ) ) THEN
      IF (Ext_File_Type_Rec_Column_API.Check_Column_Exist ( file_type_, record_type_id_ ) = 'FALSE') THEN
         FOR rec_ IN detail_ LOOP
            i_ := i_ + 1;
            col_ok_ := 'TRUE';
            IF    (rec_.data_type = '2') THEN
               n_ := n_ + 1;
               IF (n_ > 100) THEN
                  col_ok_ := 'FALSE';
               ELSIF (n_ = 100) THEN
                  destination_column_ := 'N0';
               ELSE
                  destination_column_ := 'N' || TO_CHAR(n_);
               END IF;
            ELSIF (rec_.data_type = '3') THEN
               d_ := d_ + 1;
               destination_column_ := 'D' || TO_CHAR(d_);
               IF (d_ > 20) THEN
                  col_ok_ := 'FALSE';
               END IF;
            ELSE
               c_ := c_ + 1;
               Trace_SYS.Message ('rec_.column_name : '||rec_.column_name||' c_ : '||c_);
               IF (c_ > 200) THEN
                  col_ok_ := 'FALSE';
               ELSIF (c_ = 200) THEN
                  destination_column_ := 'C0';
               ELSE
                  destination_column_ := 'C' || TO_CHAR(c_);
               END IF;
            END IF;
            IF (col_ok_ = 'TRUE') THEN
               -- File Type Column
               colrec_.file_type          := file_type_;
               colrec_.record_type_id     := record_type_id_;
               colrec_.column_id          := rec_.column_name;
               colrec_.mandatory          := rec_.mandatory_column;
               colrec_.destination_column := destination_column_;
               colrec_.data_type          := rec_.data_type;
               colrec_.description        := rec_.description;
               colrec_.rowversion         := SYSDATE;
               Ext_File_Type_Rec_Column_API.Insert_Record ( colrec_ );
               IF (cnt_file_template_ = 1) THEN
                  -- File Template Detail
                  detrec_.file_template_id   := file_template_id_;
                  detrec_.row_no             := Ext_File_Template_Detail_API.Get_Next_Row_No (file_template_id_);
                  detrec_.file_type          := file_type_;
                  detrec_.record_type_id     := record_type_id_;
                  detrec_.column_id          := rec_.column_name;
                  detrec_.column_no          := i_;
                  detrec_.control_column     := 'FALSE';
                  detrec_.hide_column        := 'FALSE';
                  detrec_.column_sort        :=  NULL;
                  detrec_.rowversion         := SYSDATE;
                  Ext_File_Template_Detail_API.Insert_Record ( detrec_ );
               END IF;
            END IF;
         END LOOP;
         Ext_File_Type_Rec_API.Update_View_Name ( file_type_,
                                                  record_type_id_,
                                                  view_name_,
                                                  input_package_ );
      ELSE
         Error_SYS.Appl_General( lu_name_, 'ALRCOLUMNS: There are already columns defined' );
      END IF;
   ELSE
      Error_SYS.Appl_General( lu_name_, 'NOTAVIEW: Incorrect view name' );
   END IF;
END Create_Rec_Det_From_View;


PROCEDURE Copy_File_Type_From_View (
   view_name_        IN VARCHAR2,
   input_package_    IN VARCHAR2,
   component_        IN VARCHAR2,
   file_type_        IN VARCHAR2,
   type_desc_        IN VARCHAR2,
   file_template_id_ IN VARCHAR2,
   template_desc_    IN VARCHAR2,
   input_template_   IN VARCHAR2,
   output_template_  IN VARCHAR2 )
IS
   info_                VARCHAR2(2000);    
   typrec_              Ext_File_Type_Tab%ROWTYPE;
   colrec_              Ext_File_Type_Rec_Column_Tab%ROWTYPE;
   grprec_              Ext_File_Type_Rec_Tab%ROWTYPE;
   filrec_              Ext_File_Template_Tab%ROWTYPE;
   idirrec_             Ext_File_Template_Dir_Tab%ROWTYPE;
   odirrec_             Ext_File_Template_Dir_Tab%ROWTYPE;
   detrec_              Ext_File_Template_Detail_Tab%ROWTYPE;
   paramsrec_           Ext_Type_Param_Set_Tab%ROWTYPE;
   separator_id_        Ext_File_Template_Tab.separator_id%TYPE;
   decimal_symbol_      Ext_File_Template_Tab.decimal_symbol%TYPE;
   date_format_         Ext_File_Template_Tab.date_format%TYPE;
   file_extension_      VARCHAR2(20);
   load_file_type_list_ Ext_File_Template_Dir_Tab.load_file_type_list%TYPE;
   remove_days_in_      Ext_File_Template_Dir_Tab.remove_days%TYPE;
   remove_days_out_     Ext_File_Template_Dir_Tab.remove_days%TYPE;
   input_path_          Ext_File_Template_Dir_Tab.file_path%TYPE;
   output_path_         Ext_File_Template_Dir_Tab.file_path%TYPE;
   backup_file_path_    Ext_File_Template_Dir_Tab.backup_file_path%TYPE;
   input_templatex_     VARCHAR2(5);
   output_templatex_    VARCHAR2(5);
   c_                   NUMBER := 0;
   n_                   NUMBER := 0;
   d_                   NUMBER := 0;
   i_                   NUMBER := 0;
   col_ok_              VARCHAR2(5);
   destination_column_  VARCHAR2(4);
   row_no_              NUMBER           := 0;
   param_no_            NUMBER           := 0;
   create_template_     VARCHAR2(5)      := 'FALSE';
   value_               VARCHAR2(200);
   CURSOR detail_ IS
      SELECT c.column_id,
             c.column_name,
             DECODE(SUBSTR(c.data_type,1,1),'N','2','D','3','1')                                                 data_type,
             SUBSTR(c.data_type,1,1)                                                                             destination_type,
             NVL(Dictionary_SYS.Comment_Value_('PROMPT',m.comments),INITCAP(c.column_name))                      description,
             Ext_File_Message_API.Comment_To_Reference(Dictionary_SYS.Comment_Value_('REF',m.comments))          reference,
             Dictionary_SYS.Comment_Value_('FLAGS',m.comments)                                                   flags,
             DECODE(SUBSTR(Dictionary_SYS.Comment_Value_('FLAGS',m.comments),2,1),'M','TRUE','FALSE')            mandatory_column,
             DECODE(SUBSTR(Dictionary_SYS.Comment_Value_('FLAGS',m.comments),1,1),'P','TRUE','K','TRUE','FALSE') key_column
      FROM   user_tab_columns c,
             user_col_comments m,
             user_views w
      WHERE  c.table_name  = view_name_
      AND    c.column_name NOT IN ('OBJID','OBJVERSION')
      AND    m.table_name  = c.table_name
      AND    m.column_name = c.column_name
      AND    w.view_name   = c.table_name
      ORDER BY column_id;
BEGIN
   Ext_File_Type_API.Already_Exist ( file_type_ );
   IF (file_template_id_ IS NOT NULL) THEN
      Ext_File_Template_API.Already_Exist ( file_template_id_ );
      create_template_ := 'TRUE';
   END IF;
   input_templatex_    := input_template_;
   output_templatex_   := output_template_;
   IF (input_package_ IS NULL) THEN
      input_templatex_ := '0';
   ELSE
      IF (NOT Dictionary_SYS.Package_Is_Active ( input_package_ )) THEN
         Error_SYS.Appl_General( lu_name_, 'NOVALINPKG: Specified Input Package is not valid' );
      END IF;
   END IF;
   IF (Check_If_View ( view_name_ ) ) THEN
      typrec_.file_type          := file_type_;
      typrec_.description        := type_desc_;
      typrec_.component          := component_;
      typrec_.view_name          := view_name_;
      typrec_.input_package      := input_package_;
      typrec_.api_to_call_input  := 'External_File_Utility_API.Create_External_Input';
      typrec_.api_to_call_output := 'External_File_Utility_API.Create_External_Output';
      typrec_.system_defined     := 'FALSE';
      typrec_.rowversion         := SYSDATE;
      Ext_File_Type_API.Insert_Record ( typrec_ );
      FOR rec_ IN detail_ LOOP
         i_ := i_ + 1;
         col_ok_ := 'TRUE';
         IF    (rec_.data_type = '2') THEN
            n_ := n_ + 1;
            IF (n_ > 100) THEN
               col_ok_ := 'FALSE';
            ELSIF (n_ = 100) THEN
               destination_column_ := 'N0';
            ELSE
               destination_column_ := 'N' || TO_CHAR(n_);
            END IF;
         ELSIF (rec_.data_type = '3') THEN
            d_ := d_ + 1;
            destination_column_ := 'D' || TO_CHAR(d_);
            IF (d_ > 20) THEN
               col_ok_ := 'FALSE';
            END IF;
         ELSE
            c_ := c_ + 1;
            IF (c_ > 200) THEN
               col_ok_ := 'FALSE';
            ELSIF (c_ = 200) THEN
               destination_column_ := 'C0';
            ELSE
               destination_column_ := 'C' || TO_CHAR(c_);
            END IF;
         END IF;
         IF (col_ok_ = 'TRUE') THEN
            -- File Type Column
            colrec_.file_type          := file_type_;
            colrec_.record_type_id     := '1';
            colrec_.column_id          := rec_.column_name;
            colrec_.mandatory          := rec_.mandatory_column;
            colrec_.destination_column := destination_column_;
            colrec_.data_type          := rec_.data_type;
            colrec_.description        := rec_.description;
            colrec_.rowversion         := SYSDATE;
            Ext_File_Type_Rec_Column_API.Insert_Record ( colrec_ );
            IF (create_template_ = 'TRUE') THEN
               -- File Template Detail
               detrec_.file_template_id   := file_template_id_;
               row_no_                    := row_no_ + 1;
               detrec_.row_no             := row_no_;
               detrec_.file_type          := file_type_;
               detrec_.record_type_id     := '1';
               detrec_.column_id          := rec_.column_name;
               detrec_.column_no          := i_;
               detrec_.control_column     := 'FALSE';
               detrec_.hide_column        := 'FALSE';
               detrec_.column_sort        :=  NULL;
               detrec_.rowversion         := SYSDATE;
               Ext_File_Template_Detail_API.Insert_Record ( detrec_ );
            END IF;
            IF (rec_.key_column = 'TRUE') THEN
               param_no_ := param_no_ + 1;
               -- Parameter record
               Create_Type_Params___ ( NULL, 
                                       rec_.column_name, 
                                       file_type_, 
                                       param_no_, 
                                       rec_.data_type, 
                                       rec_.description, 
                                       rec_.reference );       
               value_                      := NULL;
               IF (rec_.column_name = 'COMPANY') THEN       
                  value_                   := '<COMPANY>';
               END IF;
               IF (output_templatex_ = '1') THEN
                  -- Parameter per set output
                  Create_Per_Set_Params___ ( file_type_, value_, param_no_, '2', 'FALSE', 'TRUE', 'TRUE' );
               END IF;
            END IF;
         END IF;
      END LOOP;
      IF (output_templatex_ = '1') THEN
         -- Parameter Set for Output
         paramsrec_.file_type              := file_type_;
         paramsrec_.set_id                 := '2';
         paramsrec_.description            := type_desc_ || ' Output';
         paramsrec_.set_id_default         := 'TRUE';
         paramsrec_.rowversion             := SYSDATE;
         Ext_Type_Param_Set_API.Insert_Record ( paramsrec_ );
      END IF;
      IF (input_templatex_ = '1') THEN
         -- Parameter Set for Output
         paramsrec_.file_type              := file_type_;
         paramsrec_.set_id                 := '1';
         paramsrec_.description            := type_desc_ || ' Input';
         paramsrec_.set_id_default         := 'FALSE';
         paramsrec_.rowversion             := SYSDATE;
         Ext_Type_Param_Set_API.Insert_Record ( paramsrec_ );
      END IF;
      --
      -- Parameter record for file_direction_db
      param_no_ := param_no_ + 1;
      Create_Type_Params___ ( 'EXT_FILE_LOAD', 'FILE_DIRECTION_DB', file_type_, param_no_, '1', NULL, NULL ); 
      IF (output_templatex_ = '1') THEN
         -- Parameter for file_direction_db per set output
         Create_Per_Set_Params___ ( file_type_, '2', param_no_, '2', 'FALSE', 'FALSE', 'FALSE');
      END IF;
      IF (input_templatex_ = '1') THEN
         -- Parameter for file_direction_db per set input
         Create_Per_Set_Params___ ( file_type_, '1', param_no_, '1', 'FALSE', 'FALSE', 'FALSE');
      END IF;
      -- Parameter record for order_by
      param_no_ := param_no_ + 1;
      Create_Type_Params___ ( NULL, 'ORDER_BY', file_type_, param_no_, '1', 'Order By', NULL ); 
      IF (output_templatex_ = '1') THEN
         -- Parameter for order_by per set output
         Create_Per_Set_Params___ ( file_type_, NULL, param_no_, '2', 'FALSE', 'TRUE', 'TRUE');
      END IF;
      --
      -- Record type
      grprec_.file_type                 := file_type_;
      grprec_.record_type_id            := '1';
      grprec_.record_set_id             := '1';
      grprec_.first_in_record_set       := 'TRUE';
      grprec_.last_in_record_set        := 'TRUE';
      grprec_.mandatory_record          := 'FALSE';
      grprec_.description               := file_type_;
      grprec_.view_name                 := view_name_;
      grprec_.input_package             := input_package_;
      grprec_.rowversion                := SYSDATE;
      Ext_File_Type_Rec_API.Insert_Record ( grprec_ );
      IF (create_template_ = 'TRUE') THEN
         -- File Template
         separator_id_                  := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_SEPARATOR_ID');
         decimal_symbol_                := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DECIMAL_SYMBOL');
         date_format_                   := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_DATE_FORMAT');
         file_extension_                := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_FILE_EXT');
         load_file_type_list_           := Accrul_Attribute_API.Get_Attribute_Value('DEFAULT_X_FILE_TYPE_LIST');
         remove_days_in_                := Accrul_Attribute_API.Get_Attribute_Value('EXT_REMOVE_DAYS_IN');
         remove_days_out_               := Accrul_Attribute_API.Get_Attribute_Value('EXT_REMOVE_DAYS_OUT');
         input_path_                    := Accrul_Attribute_API.Get_Attribute_Value('CLIENT_INPUT_PATH');
         backup_file_path_              := Accrul_Attribute_API.Get_Attribute_Value('CLIENT_BACKUP_PATH');
         output_path_                   := Accrul_Attribute_API.Get_Attribute_Value('CLIENT_INPUT_PATH');
         filrec_.file_template_id       := file_template_id_;
         filrec_.system_defined         := 'FALSE';
         filrec_.description            := template_desc_;
         filrec_.active_definition      := 'TRUE';
         filrec_.valid_definition       := 'TRUE';
         filrec_.separated              := 'TRUE';
         filrec_.file_format            := 'SEP';
         filrec_.separator_id           := NVL(separator_id_,'1');
         filrec_.decimal_symbol         := NVL(decimal_symbol_,'.');
         filrec_.date_format            := NVL(date_format_,'YYYY-MM-DD');
         filrec_.file_type              := file_type_;
         filrec_.rowversion             := SYSDATE;
         Ext_File_Template_API.Insert_Record ( filrec_ );
         IF (input_templatex_ = '1') THEN
            -- File Template Input
            idirrec_.file_template_id          := file_template_id_;
            idirrec_.file_direction            := '1';
            idirrec_.api_to_call               := 'External_File_Utility_API.Create_External_Input';
            idirrec_.log_skipped_lines         := 'TRUE';
            idirrec_.log_invalid_lines         := 'TRUE';
            idirrec_.abort_immediatly          := 'FALSE';
            idirrec_.allow_record_set_repeat   := 'TRUE';
            idirrec_.allow_one_record_set_only := 'FALSE';
            idirrec_.skip_all_blanks           := 'FALSE';
            idirrec_.skip_initial_blanks       := 'FALSE';
            idirrec_.load_file_type_list       := NVL(load_file_type_list_,'All Types^*');
            idirrec_.file_path                 := input_path_;
            idirrec_.backup_file_path          := backup_file_path_;
            idirrec_.file_name                 := file_template_id_ || '.' ||NVL(file_extension_,'csv');
            idirrec_.remove_days               := remove_days_in_;
            idirrec_.rowversion                := SYSDATE;
            In_Ext_File_Template_Dir_API.Insert_Record ( idirrec_ );
         END IF;
         IF (output_templatex_ = '1') THEN
            -- File Template Output
            odirrec_.file_template_id          := file_template_id_;
            odirrec_.file_direction            := '2';
            odirrec_.api_to_call               := 'External_File_Utility_API.Create_External_Output';
            odirrec_.create_header             := 'TRUE';
            odirrec_.overwrite_file            := 'TRUE';
            odirrec_.create_header             := 'TRUE';
            odirrec_.name_option               := '1';
            odirrec_.file_path                 := output_path_;
            odirrec_.file_name                 := file_template_id_ || '.' ||NVL(file_extension_,'csv');
            odirrec_.remove_days               := remove_days_out_;
            odirrec_.rowversion                := SYSDATE;
            Out_Ext_File_Template_Dir_API.Insert_Record ( odirrec_ );
         END IF;
      END IF;
      Ext_File_Template_API.Update_Valid_Definition ( info_,                 
                                                      file_template_id_,
                                                      'FALSE' );
   ELSE
      Error_SYS.Appl_General( lu_name_, 'NOTAVIEW: Incorrect view name' );
   END IF;
END Copy_File_Type_From_View;


PROCEDURE Start_Online_Process (
   info_         IN OUT VARCHAR2,
   load_file_id_ IN     NUMBER,
   api_to_call_  IN     VARCHAR2 )
IS
BEGIN
   Start_Api_To_Call ( info_, load_file_id_ );
END Start_Online_Process;


PROCEDURE Start_Input_Online (
   info_         IN OUT VARCHAR2,
   load_file_id_ IN     NUMBER )
IS
   load_state_          VARCHAR2(200);
   ext_file_load_rec_   Ext_File_Load_API.Public_Rec;
BEGIN
   Client_SYS.Clear_Info;
   ext_file_load_rec_ := Ext_File_Load_API.Get( load_file_id_ );
   IF (ext_file_load_rec_.state != '2' ) THEN
      load_state_    := Ext_File_State_API.Decode ( ext_file_load_rec_.state );
      Error_SYS.Record_General( lu_name_, 'EXTFNOLOAD: Load File ID :P1 is not loaded correctly, state is :P2', load_file_id_, load_state_ );
   END IF;
   Unpack_Ext_Line ( ext_file_load_rec_.file_type,
                     ext_file_load_rec_.file_template_id,
                     load_file_id_,
                     ext_file_load_rec_.company );
   ext_file_load_rec_ := Ext_File_Load_API.Get( load_file_id_ );
   IF (ext_file_load_rec_.state != '3' ) THEN
      load_state_    := Ext_File_State_API.Decode ( ext_file_load_rec_.state );
      Error_SYS.Record_General( lu_name_, 'EXTFNOTUNP: Load File ID :P1 is not unpacked correctly, state is :P2', load_file_id_, load_state_ );
   END IF;
END Start_Input_Online;


PROCEDURE Start_Input_Batch (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER,
   file_type_        IN     VARCHAR2,
   file_template_id_ IN     VARCHAR2,
   file_name_        IN     VARCHAR2,
   company_          IN     VARCHAR2 )
IS
   file_namex_            VARCHAR2(2000);
   load_state_            VARCHAR2(200);
   in_file_character_set_ VARCHAR2(64) := In_Ext_File_Template_Dir_API.Get_Character_Set_Db(file_template_id_, '1');
   default_character_set_ VARCHAR2(64) := Nvl(Database_SYS.Get_File_Encoding, Database_SYS.Get_Database_Charset);
   backup_file_path_      VARCHAR2(2000);
   load_file_idx_         NUMBER;
   ext_file_load_rec_     Ext_File_Load_API.Public_Rec;
BEGIN
   file_namex_    := file_name_;
   load_file_idx_ := load_file_id_;
   IF (load_file_idx_ IS NULL) THEN
      load_file_idx_ := Get_Next_Seq;
      IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_idx_ ) ) THEN
         Ext_File_Load_API.Insert_File_Load ( load_file_idx_,
                                              file_template_id_,
                                              '1',
                                              file_type_,
                                              company_,
                                              file_namex_ );
      END IF;
   END IF;
   -- Note: Needs to copy the original file into backup and process the backup file instead of original, if backup path
   -- Note: is available. 
   Ext_File_Server_Util_API.Copy_Server_File_ ( backup_file_path_,
                                                load_file_idx_,
                                                file_namex_,
                                                default_character_set_ );
   -- Note: Setting filename to backup file if available, for processing it instead of original. Copy would remove the 
   -- Note: original file after copying it to backup.
   IF (backup_file_path_ IS NOT NULL) THEN
      file_namex_    := backup_file_path_;
   END IF; 
   Ext_File_Server_Util_API.Load_Server_File_ ( load_file_idx_,
                                                file_template_id_,
                                                file_type_,
                                                file_namex_,
                                                company_ );
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
   ext_file_load_rec_   := Ext_File_Load_API.Get( load_file_idx_ );
   IF (ext_file_load_rec_.state != '2' ) THEN
      load_state_    := Ext_File_State_API.Decode( ext_file_load_rec_.state );
      Error_SYS.Record_General( lu_name_, 'EXTFNOLOAD: Load File ID :P1 is not loaded correctly, state is :P2', load_file_idx_, load_state_ );
   END IF;
   Unpack_Ext_Line ( file_type_,
                     file_template_id_,
                     load_file_idx_,
                     company_ );
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
   ext_file_load_rec_   := Ext_File_Load_API.Get( load_file_idx_ );
   IF (ext_file_load_rec_.state != '3' ) THEN
      load_state_    := Ext_File_State_API.Decode( ext_file_load_rec_.state );
      Error_SYS.Record_General( lu_name_, 'EXTFNOTUNP: Load File ID :P1 is not unpacked correctly, state is :P2', load_file_idx_, load_state_ );
   END IF;
   Store_File_Identities ( load_file_id_ );
   Start_Api_To_Call ( info_, load_file_idx_ );
   ext_file_load_rec_   := Ext_File_Load_API.Get( load_file_idx_ );
   load_state_ := ext_file_load_rec_.state;
   IF (load_state_ NOT IN ('9','10')) THEN
      Ext_File_Load_API.Update_State (load_file_idx_, '4');
   END IF;
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
   IF (load_state_ = 9) THEN
      Error_SYS.Record_General( lu_name_, 'TRANSFERERR: Load File ID :P1 is transferred with errors.', load_file_idx_);
   ELSIF (load_state_ = 10) THEN
      Error_SYS.Record_General( lu_name_, 'PARTLYTRANSF: Load File ID :P1 is partly transferred.', load_file_idx_);
   END IF;
   --Set the character set for the file according to file template in and out character set settings
   IF in_file_character_set_ IS NOT NULL THEN
      default_character_set_ := in_file_character_set_;
   END IF;
END Start_Input_Batch;


PROCEDURE Start_Output_Online (
   info_         IN OUT VARCHAR2,
   load_file_id_ IN     NUMBER )
IS
   file_is_xml_type_    VARCHAR2(5);
   ext_file_load_rec_   Ext_File_Load_API.Public_Rec;
BEGIN
   Start_Api_To_Call ( info_ , load_file_id_ );
   ext_file_load_rec_ := Ext_File_Load_API.Get( load_file_id_ );
   Pack_Out_Ext_Line ( ext_file_load_rec_.file_type,
                       ext_file_load_rec_.file_template_id,
                       load_file_id_,
                       ext_file_load_rec_.company );
   Create_Xml_File (load_file_id_, file_is_xml_type_);
END Start_Output_Online;


PROCEDURE Start_Output_Batch (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER,
   file_type_        IN     VARCHAR2,
   file_template_id_ IN     VARCHAR2,
   file_name_        IN     VARCHAR2,
   company_          IN     VARCHAR2 )
IS
   load_file_idx_           NUMBER;
   file_namex_              VARCHAR2(2000);
   file_is_xml_type_        VARCHAR2(5);
   clob_out_                CLOB; 
   path_                    VARCHAR2(2000);
   server_path_separator_   VARCHAR2(1) := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');
   out_ext_file_template_dir_rec_   Out_Ext_File_Template_Dir_API.Public_Rec;
BEGIN
   file_namex_    := file_name_;
   load_file_idx_ := load_file_id_;
   IF (load_file_idx_ IS NULL) THEN
      load_file_idx_ := Get_Next_Seq;
      IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_idx_ ) ) THEN
         Ext_File_Load_API.Insert_File_Load ( load_file_idx_,
                                              file_template_id_,
                                              '2',
                                              file_type_,
                                              company_,
                                              file_name_ );
      END IF;
   END IF;
   Start_Api_To_Call ( info_ , load_file_idx_ );
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
   Pack_Out_Ext_Line ( file_type_,
                       file_template_id_,
                       load_file_idx_,
                       company_ );
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
   Modify_File_Name ( load_file_idx_, file_namex_ );
   Create_Xml_File (load_file_idx_, file_is_xml_type_);
   out_ext_file_template_dir_rec_ := Out_Ext_File_Template_Dir_API.Get(file_template_id_, File_Direction_API.DB_OUTPUT_FILE);
   IF (out_ext_file_template_dir_rec_.create_xml_file = 'TRUE' AND file_is_xml_type_ != 'TRUE') THEN
      Create_Xml_File(clob_out_, load_file_id_);
      path_ := out_ext_file_template_dir_rec_.file_path_server|| server_path_separator_ || out_ext_file_template_dir_rec_.file_name;
      Write_Xml_File(clob_out_, path_);
   ELSE
      IF (file_is_xml_type_ != 'TRUE') THEN
         Ext_File_Server_Util_API.Write_Server_File_ (load_file_idx_,
                                                      file_namex_,
                                                      out_ext_file_template_dir_rec_.character_set);
         Ext_File_Load_API.Update_State (load_file_idx_, '7');
      END IF;
   END IF;
   @ApproveTransactionStatement(2009-05-25,ashelk)
   COMMIT;
END Start_Output_Batch;


PROCEDURE Get_Datatype (
   destination_column_ IN     VARCHAR2,
   data_type_          IN OUT VARCHAR2 )
IS
   type_        VARCHAR2(2);
BEGIN
   IF (data_type_ IS NULL) THEN
      type_ := SUBSTR(destination_column_,1,1);
      IF (type_ = 'C') THEN
         data_type_ := Exty_Data_Type_API.Decode ( '1' );
      ELSIF (type_ = 'N') THEN
         data_type_ := Exty_Data_Type_API.Decode ( '2' );
      ELSE
         data_type_ := Exty_Data_Type_API.Decode ( '3' );
      END IF;
   END IF;
END Get_Datatype;


PROCEDURE Create_Output_Message (
   message_         OUT VARCHAR2,
   last_line_       OUT VARCHAR2,
   count_           OUT NUMBER,
   row_no_       IN OUT NUMBER,
   load_file_id_ IN     NUMBER )
IS
   sub_message_         VARCHAR2(4000);
   dummy_               VARCHAR2(1);
   file_type_           EXT_FILE_LOAD_TAB.file_type%TYPE;
   system_bound_        VARCHAR2(5);
   CURSOR file_trans IS
      SELECT row_no,
             file_line
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       > row_no_
      AND    row_state    IN ('2','7')
      ORDER BY row_no;
   CURSOR exist_control IS
      SELECT '1'
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       > row_no_;
BEGIN
   IF (row_no_ IS NULL) THEN
      row_no_ := 0;
   END IF;
   file_type_ := Ext_File_Load_API.Get_File_Type( load_file_id_);
   system_bound_ := Ext_File_Type_API.Get_System_Bound(file_type_);
   count_     := 0;
   message_   := Message_Sys.Construct('MAIN MESSAGE');
   IF (system_bound_ = 'TRUE') THEN
      FOR rec_ IN file_trans LOOP
         sub_message_ := Message_Sys.Construct('OUTPUT_FILE');
         Message_Sys.Add_Attribute(sub_message_, 'ROW_NO', rec_.row_no);
         Message_Sys.Add_Attribute(sub_message_, 'FILE_LINE', rec_.file_line);          
         count_  := count_ + 1;
         row_no_ := rec_.row_no;
         Message_Sys.Add_Attribute(message_, TO_CHAR(count_), sub_message_);
         IF (LENGTH(message_) > 8000) THEN
            EXIT;
         END IF;
      END LOOP;
   ELSE
      FOR rec_ IN file_trans LOOP
         sub_message_ := Message_Sys.Construct('OUTPUT_FILE');
         Message_Sys.Add_Attribute(sub_message_, 'ROW_NO', rec_.row_no);
         Message_Sys.Add_Attribute(sub_message_, 'FILE_LINE', rec_.file_line);
         count_  := count_ + 1;
         row_no_ := rec_.row_no;
         Message_Sys.Add_Attribute(message_, TO_CHAR(count_), sub_message_);
         IF (LENGTH(message_) > 8000) THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      last_line_ := 'FALSE';
   ELSE
      last_line_ := 'TRUE';
   END IF;
   CLOSE exist_control;
END Create_Output_Message;


PROCEDURE Check_Valid_Definition (
   valid_definition_ IN OUT VARCHAR2,
   error_type_       IN OUT VARCHAR2,
   file_type_        IN     VARCHAR2,
   file_template_id_ IN     VARCHAR2 )
IS
   record_type_count_ NUMBER;
   record_set_id_     VARCHAR2(20);
   --separated_         VARCHAR2(5);
   file_format_       VARCHAR2(10);
   dummy_             NUMBER;
   CURSOR get_direction IS
      SELECT 1
      FROM   Ext_File_Template_Dir_Tab
      WHERE  file_template_id = file_template_id_;
   CURSOR count_det_groups IS
      SELECT COUNT(DISTINCT record_type_id)
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_ ;
   CURSOR get_details IS
      SELECT DISTINCT record_type_id
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_ ;
   CURSOR get_rec_sets IS
      SELECT DISTINCT G.record_set_id
      FROM   Ext_File_Type_Rec_Tab G,
             Ext_File_Template_Detail_Tab D
      WHERE  G.file_type        = file_type_
      AND    D.record_type_id   = G.record_type_id
      AND    D.file_template_id = file_template_id_;
   CURSOR get_rec_groups IS
      SELECT record_type_id
      FROM   Ext_File_Type_Rec_Tab
      WHERE  file_type        = file_type_
      AND    record_set_id    = record_set_id_
      AND    mandatory_record = 'TRUE';
   CURSOR get_det_sep IS
      SELECT 1
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_
      AND    start_position IS NOT NULL;
   CURSOR get_det_notsep IS
      SELECT 1
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_
      AND    column_no IS NOT NULL;
BEGIN
   valid_definition_ := 'TRUE';
   -- There must exists any detail
   IF (Ext_File_Template_Detail_API.Check_Detail_Exist ( file_template_id_ ) = 'FALSE' ) THEN
      valid_definition_ := 'FALSE';
      error_type_       := 'NoDetails';
   END IF;
   -- There must exist an input or output definition
   IF (valid_definition_ = 'TRUE') THEN
      OPEN  get_direction;
      FETCH get_direction INTO dummy_;
      IF (get_direction%NOTFOUND) THEN
         valid_definition_ := 'FALSE';
         error_type_       := 'NoDirection';
      END IF;
      CLOSE get_direction;
   END IF;
   IF (valid_definition_ = 'TRUE') THEN
      OPEN  count_det_groups;
      FETCH count_det_groups INTO record_type_count_;
      CLOSE count_det_groups;
      -- If more than one record_type is used there must be any control on these
      IF (record_type_count_ > 1) THEN
         FOR reca_ IN get_details LOOP
            IF (In_Ext_File_Template_Dir_API.Check_Rec_Exist ( file_template_id_ ) = 'TRUE') THEN
               IF (Ext_File_Template_Control_API.Check_Any_Control ( file_template_id_,
                                                                     '1',
                                                                     reca_.record_type_id ) = 'FALSE') THEN
                  valid_definition_ := 'FALSE';
                  error_type_       := 'NoControlsMult';
                  EXIT;
               END IF;
            END IF;
         END LOOP;
      END IF;
   END IF;
   IF (valid_definition_ = 'TRUE') THEN
      FOR recb_ IN get_rec_sets LOOP
         record_set_id_ := recb_.record_set_id;
         FOR recc_ IN get_rec_groups LOOP
            IF (Ext_File_Template_Detail_API.Check_Detail_Exist ( file_template_id_, recc_.record_type_id ) = 'FALSE' ) THEN
               valid_definition_ := 'FALSE';
               error_type_       := 'MissMandRectype';
               EXIT;
            END IF;
         END LOOP;
         IF (valid_definition_ = 'FALSE') THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;
   IF (valid_definition_ = 'TRUE') THEN
      file_format_ := Ext_File_Template_API.Get_File_Format_Db (file_template_id_);
      IF (file_format_ = 'SEP') THEN
         OPEN  get_det_sep;
         FETCH get_det_sep INTO dummy_;
         IF (get_det_sep%FOUND) THEN
            valid_definition_ := 'FALSE';
            error_type_       := 'SepError1';
         END IF;
         CLOSE get_det_sep;
      ELSE
         OPEN  get_det_notsep;
         FETCH get_det_notsep INTO dummy_;
         IF (get_det_notsep%FOUND) THEN
            valid_definition_ := 'FALSE';
            error_type_       := 'SepError2';
         END IF;
         CLOSE get_det_notsep;
      END IF;
   END IF;
END Check_Valid_Definition;


PROCEDURE Modify_File_Name (
   load_file_id_ IN     NUMBER,
   file_name_    IN OUT VARCHAR2 )
IS
   file_name_org_       VARCHAR2(2000);
   file_template_id_    VARCHAR2(30);
   date_format_         Ext_File_Template_Tab.date_format%TYPE;
   name_option_         VARCHAR2(1);
   file_path_begin_     VARCHAR2(2000);
   file_path_end_       VARCHAR2(100);
BEGIN
   file_name_org_        := file_name_;
   file_template_id_     := Ext_File_Load_API.Get_File_Template_Id ( load_file_id_ );
   name_option_          := Out_Ext_File_Template_Dir_API.Get_Name_Option_Db ( file_template_id_, File_Direction_API.Decode('2') );
   IF (NVL(name_option_,'1') IN ('3','4')) THEN
      date_format_       := Accrul_Attribute_API.Get_Attribute_Value('NAME_OPTION_DATE_FORMAT');
      IF (date_format_ IS NULL) THEN
         date_format_    := 'YYYY-MM-DD';
      END IF;
   END IF;
   IF (NVL(name_option_,'1') = '2') THEN
      File_Path_Info ( file_path_begin_ , file_path_end_ , file_name_org_ );
      file_path_end_ := REPLACE(file_path_end_,'.',TO_CHAR(load_file_id_)||'.');
      file_name_     := file_path_begin_ || file_path_end_;
   ELSIF (NVL(name_option_,'1') = '3') THEN
      File_Path_Info ( file_path_begin_ , file_path_end_ , file_name_org_ );
      file_path_end_ := REPLACE(file_path_end_,'.',TO_CHAR(SYSDATE,date_format_)||'.');
      file_name_ := file_path_begin_ || file_path_end_;
   ELSIF (NVL(name_option_,'1') = '4') THEN 
      File_Path_Info ( file_path_begin_ , file_path_end_ , file_name_org_ );
      file_path_end_ := REPLACE(file_path_end_,'.',TO_CHAR(load_file_id_)||TO_CHAR(SYSDATE,date_format_)||'.');
      file_name_ := file_path_begin_ || file_path_end_;
   END IF;
   IF (file_name_org_ != file_name_) THEN
      Ext_File_Load_API.Update_File_Name ( load_file_id_, file_name_ );
   END IF;
END Modify_File_Name;


PROCEDURE Create_External_Output_Det (
   info_                IN OUT VARCHAR2,
   load_file_id_        IN     NUMBER,
   file_type_           IN     VARCHAR2,
   file_template_id_    IN     VARCHAR2,
   company_             IN     VARCHAR2,
   parameter_string_    IN     VARCHAR2,
   date_format_         IN     VARCHAR2,
   row_no_              IN OUT NUMBER,
   parent_record_type_  IN     VARCHAR2,
   trec_                IN     Ext_File_Trans_Tab%ROWTYPE )
IS
   record_type_id_             VARCHAR2(30);
   where_                      VARCHAR2(2000);
   value_                      VARCHAR2(200);
   nvalue_                     NUMBER;
   dvalue_                     DATE;
   --
   CURSOR GetRecTypes IS
      SELECT DISTINCT
             G.record_type_id,
             G.first_in_record_set,
             G.last_in_record_set,
             G.view_name,
             G.parent_record_type
      FROM   Ext_File_Template_Detail_Tab D,
             Ext_File_Type_Rec_Tab G
      WHERE  D.file_template_id = file_template_id_
      AND    G.file_type        = D.file_type
      AND    G.record_type_id   = D.record_type_id
      AND    G.parent_record_type = parent_record_type_
      ORDER BY DECODE(G.first_in_record_set,'TRUE',0,
                  DECODE(G.last_in_record_set,'TRUE',3,2)),
               G.record_type_id,
               G.parent_record_type;
   CURSOR GetKeys IS
      SELECT c.column_id                    column_id,
             c.destination_column           destination_column
      FROM   ext_file_template_tab        t,
             ext_file_type_rec_column_tab c,
             ext_file_type_rec_tab        r
      WHERE  t.file_template_id = file_template_id_
      AND    c.file_type        = t.file_type
      AND    c.record_type_id   = record_type_id_
      AND    r.file_type        = c.file_type
      AND    r.record_type_id   = c.record_type_id
      AND    External_File_Utility_API.Is_Col_Parent_Key (r.view_name,c.column_id) = 'TRUE';
BEGIN
   FOR rec_ IN GetRecTypes LOOP
      record_type_id_ := rec_.record_type_id;
      where_          := NULL;
      FOR keys_ IN GetKeys LOOP
         IF (SUBSTR(keys_.destination_column,1,1) = 'N') THEN
            nvalue_ := Ext_File_Column_Util_API.Return_N_Value(keys_.destination_column, trec_);
         ELSIF (SUBSTR(keys_.destination_column,1,1) = 'D') THEN 
            dvalue_ := Ext_File_Column_Util_API.Return_D_Value(keys_.destination_column, trec_);
         ELSE
            value_  := Ext_File_Column_Util_API.Return_C_Value(keys_.destination_column, trec_);
         END IF;
         IF (where_ IS NULL) THEN
            where_ := 'WHERE ';
         ELSE
            where_ := where_ || ' AND ';
         END IF;
         where_ := where_ || keys_.column_id || ' = ';
         IF (SUBSTR(keys_.destination_column,1,1) = 'N') THEN
            where_ := where_ ||  nvalue_ ;
         ELSIF (SUBSTR(keys_.destination_column,1,1) = 'D') THEN
            where_ := where_ || 'TO_DATE(' || CHR(39) || TO_CHAR(dvalue_,'yyyy-mm-dd-hh24:mi:ss') || CHR(39) || ',' || CHR(39) || 'yyyy-mm-dd-hh24:mi:ss' || CHR(39) || ')';
         ELSE
            where_ := where_ || CHR(39) || value_ || CHR(39);
         END IF;
      END LOOP;
      Create_External_Output ( info_,
                               load_file_id_,
                               file_type_,
                               file_template_id_,
                               company_,
                               parameter_string_,
                               date_format_,
                               row_no_,
                               rec_.record_type_id,
                               rec_.view_name,
                               where_ );
   END LOOP;
   --
END Create_External_Output_Det;


PROCEDURE Execute_Batch_Process2 (
   parameter_string_ IN VARCHAR2 )
IS
   par_key_             VARCHAR2(100);
   batch_parameter_     VARCHAR2(2000);
   info_                VARCHAR2(2000);
   company_             VARCHAR2(20);
   file_template_id_    VARCHAR2(30);
   file_direction_      VARCHAR2(30);
   file_type_           VARCHAR2(30);
   file_name_           VARCHAR2(2000);
   load_file_id_        NUMBER           := NULL;
BEGIN
   Find_Batch_Par_Key___ (parameter_string_, par_key_);
   batch_parameter_ := Ext_File_Batch_Param_API.Get_Param_String (TO_NUMBER(par_key_));
   IF (batch_parameter_ IS NULL) THEN
      Error_SYS.Appl_General( lu_name_, 'NOBATCHPAR: Batch Parameter not found');
   END IF;
   Message_SYS.Get_Attribute (batch_parameter_, 'COMPANY',          company_);
   Message_SYS.Get_Attribute (batch_parameter_, 'FILE_TYPE',        file_type_);
   Message_SYS.Get_Attribute (batch_parameter_, 'FILE_TEMPLATE_ID', file_template_id_);
   Message_SYS.Get_Attribute (batch_parameter_, 'FILE_DIRECTION_DB',file_direction_);
   Message_SYS.Get_Attribute (batch_parameter_, 'FILE_NAME',        file_name_);
   Message_SYS.Set_Attribute (batch_parameter_, 'LOAD_DATE',        TRUNC(SYSDATE));
   
   IF (LENGTH(file_direction_) > 1) THEN
      file_direction_ := File_Direction_API.Encode (file_direction_);
   END IF;
   IF (file_direction_ = '1') THEN
      Ext_File_Server_Util_API.Check_Server_File_ (info_, file_name_);
   ELSE
      info_ := NULL;
   END IF;
   IF (info_ IS NOT NULL) THEN
      Error_SYS.Record_General(lu_name_, info_);
   ELSE
      Ext_File_Load_API.Create_Load_Id_Param ( load_file_id_, batch_parameter_ );
      IF (file_direction_ = '1') THEN
         Start_Input_Batch ( info_,
                             load_file_id_,
                             file_type_,
                             file_template_id_,
                             file_name_,
                             company_ );
      ELSE
         Start_Output_Batch ( info_,
                              load_file_id_,
                              file_type_,
                              file_template_id_,
                              file_name_,
                              company_ );
      END IF;
   END IF;
END Execute_Batch_Process2;


PROCEDURE Execute_Batch_Process (
   parameter_string_ IN VARCHAR2 )
IS
   par_key_             VARCHAR2(100);
   batch_parameter_     VARCHAR2(2000);
   file_template_id_    VARCHAR2(30);
   print_desc_          VARCHAR2(50);
BEGIN
   Find_Batch_Par_Key___ (parameter_string_, par_key_);
   batch_parameter_ := Ext_File_Batch_Param_API.Get_Param_String (TO_NUMBER(par_key_));
   IF (batch_parameter_ IS NULL) THEN
      Error_SYS.Appl_General( lu_name_, 'NOBATCHPAR: Batch Parameter not found');
   END IF;
   Message_SYS.Get_Attribute (batch_parameter_, 'FILE_TEMPLATE_ID',   file_template_id_);
   print_desc_ := Language_SYS.Translate_Constant(lu_name_,'EXTFILES: External Files');
   Transaction_SYS.Deferred_Call('External_File_Utility_API.Execute_Batch_Process2', parameter_string_, print_desc_||' '||file_template_id_);
END Execute_Batch_Process;


PROCEDURE Start_Batch_Process (
   info_             IN OUT VARCHAR2,
   parameter_string_ IN     VARCHAR2,
   exec_plan_        IN     VARCHAR2 DEFAULT 'ASAP' )
IS
   err_msg_               VARCHAR2(2000);
   print_desc_            VARCHAR2(50);
   schedule_id_           NUMBER;
   next_execution_date_   DATE;
   start_date_            DATE := SYSDATE;
   seq_no_                NUMBER;
   file_template_id_      VARCHAR2(30);
BEGIN
   print_desc_ := Language_SYS.Translate_Constant(lu_name_,'EXTFILES: External Files');
   Message_SYS.Get_Attribute (parameter_string_, 'FILE_TEMPLATE_ID',   file_template_id_);
   Batch_SYS.New_Batch_Schedule(schedule_id_, 
                             next_execution_date_, 
                             start_date_, 
                             NULL, 
                             print_desc_||' '||file_template_id_, 
                             'External_File_Utility_API.Execute_Batch_Process2',
                             'TRUE',
                             exec_plan_);    
   Batch_SYS.New_Batch_Schedule_Param(seq_no_, schedule_id_, 'PARAMETER_STRING_',parameter_string_);                                               
   IF (schedule_id_ IS NOT NULL) THEN
      err_msg_ := 'EXTFILEBOK: Batch Schedule :P1 is created';
      Client_SYS.Add_Info(lu_name_, err_msg_, schedule_id_);
      info_ := Client_SYS.Get_All_Info;
   ELSE
      err_msg_ := 'EXTFILEBERR: Error when creating Batch Schedule';
      Client_SYS.Add_Info(lu_name_, err_msg_);
      info_ := Client_SYS.Get_All_Info;
   END IF;
END Start_Batch_Process;


PROCEDURE Get_File_Path (
   file_         OUT VARCHAR2,
   path_         OUT VARCHAR2,
   file_name_    IN  VARCHAR2 )
IS
   last_slash_       NUMBER;
   last_dot_         NUMBER;
BEGIN
   last_slash_   := NVL(INSTR(file_name_,'\',-1),0);
   last_dot_     := NVL(INSTR(file_name_,'.',-1),0);
   IF (last_slash_ = 0) THEN
      IF (last_dot_ = 0) THEN
         file_   := NULL;
         path_   := NULL;
      ELSE
         file_   := file_name_;
         path_   := NULL;
      END IF;
   ELSE
      IF (last_dot_ = 0) THEN
         file_   := NULL;
         path_   := file_name_;
      ELSE
         file_   := SUBSTR(file_name_,last_slash_+1);
         path_   := SUBSTR(file_name_,1,last_slash_-1);
      END IF;
   END IF;
END Get_File_Path;


PROCEDURE Merge_File_Lines (
   info_            IN OUT VARCHAR2,
   load_file_id_    IN     NUMBER,
   merge_condition_ IN     VARCHAR2,
   keep_line_feed_  IN     VARCHAR2 DEFAULT 'TRUE' )
IS 
   file_line_                 VARCHAR2(4000);
   row_no_                    NUMBER;
   objid_                     VARCHAR2(2000);
   next_row_no_               NUMBER;
   TYPE RecordType IS REF CURSOR;
   rec_                       RecordType;
   recx_                      RecordType;
   stmnt_                     VARCHAR2(32000);
   stmntnx_                   VARCHAR2(32000);
   --
   CURSOR File_Trans_Sub IS
      SELECT row_no,
             file_line, 
             rowid objid
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_state    = '1'
      AND    row_no       > row_no_
      AND    row_no       < next_row_no_
      ORDER BY row_no;
   --
BEGIN
   IF (merge_condition_ IS NOT NULL) THEN
      stmnt_ :=               ' SELECT row_no, file_line, rowid objid ';
      stmnt_ := stmnt_ ||     ' FROM   Ext_File_Trans_Tab ';
      stmnt_ := stmnt_ ||     ' WHERE  load_file_id = :load_file_id_ ';
      stmnt_ := stmnt_ ||     ' AND    row_state    = '||CHR(39)||'1'||CHR(39)||' ';
      stmnt_ := stmnt_ ||     ' AND '||merge_condition_||' ';
      stmnt_ := stmnt_ ||     ' ORDER BY row_no ';      
      --
      stmntnx_ :=             ' SELECT row_no ';
      stmntnx_ := stmntnx_ || ' FROM   Ext_File_Trans_Tab ';
      stmntnx_ := stmntnx_ || ' WHERE  load_file_id = :load_file_id_ ';
      stmntnx_ := stmntnx_ || ' AND    row_no       > :row_no_ ';
      stmntnx_ := stmntnx_ || ' AND    row_state    = '||CHR(39)||'1'||CHR(39)||' ';
      stmntnx_ := stmntnx_ || ' AND '||merge_condition_||' ';
      stmntnx_ := stmntnx_ || ' ORDER BY row_no ';      
      --
      @ApproveDynamicStatement(2006-01-03,pperse)
      OPEN rec_ FOR stmnt_ USING IN load_file_id_;
      LOOP
         FETCH rec_ INTO row_no_, 
                         file_line_, 
                         objid_;
         EXIT WHEN rec_%NOTFOUND;
         @ApproveDynamicStatement(2006-01-03,pperse)
         OPEN recx_ FOR stmntnx_ USING load_file_id_, row_no_;
         FETCH recx_ INTO next_row_no_; 
         IF (recx_%NOTFOUND) THEN
            next_row_no_ := row_no_;
         END IF;
         CLOSE recx_;
         IF ((next_row_no_ - row_no_) > 1)  THEN
            FOR sub_rec_ IN File_Trans_Sub LOOP
               IF (keep_line_feed_ = 'TRUE') THEN
                  file_line_  := file_line_ || CHR(13) || CHR(10) || sub_rec_.file_line;
               ELSE
                  file_line_  := file_line_ || sub_rec_.file_line;
               END IF;
               DELETE FROM Ext_File_Trans_Tab
               WHERE  ROWID = sub_rec_.objid;
            END LOOP;
            UPDATE Ext_File_Trans_Tab 
               SET file_line = file_line_
            WHERE  ROWID = objid_;
         END IF;
      END LOOP;
      CLOSE rec_;
   END IF;
END Merge_File_Lines;


PROCEDURE Merge_Skipped_File_Lines (
   info_            IN OUT VARCHAR2,
   load_file_id_    IN     NUMBER,
   keep_line_feed_  IN     VARCHAR2 DEFAULT 'TRUE' )
IS
   record_type_id_            VARCHAR2(30);
   no_of_lines_               NUMBER;
   no_of_x_lines_             NUMBER;
   file_line_                 VARCHAR2(4000);
   row_no_                    NUMBER;   
   row_state_                 VARCHAR2(1);
   err_msg_                   VARCHAR2(2000);
   use_line_                  VARCHAR2(5);
   skipped_line_              VARCHAR2(5);
   invalid_line_              VARCHAR2(5);
   unp_value_tab_             External_File_Utility_API.ValueTabType;
   max_v_                     NUMBER := 0;
   templ_det_rec_             External_File_Utility_API.ft_m_det_rec;   
   detail_file_line_          VARCHAR2(4000);
   limit_                     NUMBER := 1000;
   first_row_no_              NUMBER;
   first_row_                 BOOLEAN := TRUE;
   next_row_no_               NUMBER;
   exit_                      BOOLEAN := FALSE;
   
   CURSOR File_Trans IS
      SELECT row_no,
             file_line,
             rowid objid
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_state    = '1'
      ORDER BY row_no;

   CURSOR File_Trans_Sub IS
      SELECT row_no,
             file_line,
             row_state,
             rowid objid
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND row_no > row_no_ AND row_no < next_row_no_
      ORDER BY row_no;
   
   TYPE file_trans_rec IS TABLE OF File_Trans%ROWTYPE;
   file_trans_rec_   file_trans_rec;   
   
   TYPE sub_file_trans_rec IS TABLE OF File_Trans_Sub%ROWTYPE;
   sub_file_trans_rec_   sub_file_trans_rec;   
   cnt_   PLS_integer;   
BEGIN
   templ_det_rec_.load_file_id                  := load_file_id_;
   templ_det_rec_.file_direction                := '1';
   External_File_Utility_API.Get_Template_Data (templ_det_rec_);
   FOR rec_ IN File_Trans LOOP
      file_line_      := rec_.file_line;
      use_line_       := 'TRUE';
      IF (file_line_ IS NULL) THEN
         use_line_     := 'FALSE';
         skipped_line_ := 'TRUE';
      END IF;
      IF (use_line_ = 'TRUE') THEN
         IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
            max_v_ := unp_value_tab_.COUNT;
            IF (max_v_ > 0) THEN
               External_File_Utility_API.Clear_Value_Tab ( unp_value_tab_,
                                                           max_v_ );
            END IF;
            External_File_Utility_API.Unpack_Separated_File ( err_msg_,
                                                              row_state_,
                                                              unp_value_tab_,
                                                              file_line_,
                                                              templ_det_rec_.ext_file_rec );
            IF (err_msg_ IS NOT NULL) THEN
               use_line_     := 'FALSE';
               invalid_line_ := 'TRUE';
            END IF;
         END IF;
      END IF;
      IF (use_line_ = 'TRUE') THEN
         no_of_x_lines_ := 0;
         IF (templ_det_rec_.max_cn > 0) THEN
            External_File_Utility_API.Control_In_Ext_File (err_msg_,
                                                           use_line_,
                                                           skipped_line_,
                                                           invalid_line_,
                                                           record_type_id_,
                                                           no_of_lines_,
                                                           file_line_,
                                                           templ_det_rec_,
                                                           unp_value_tab_);
            no_of_x_lines_ := NVL(no_of_lines_,1) - 1;
         END IF;
      END IF;
      IF (use_line_ = 'FALSE') THEN
         Ext_File_Trans_API.Update_Row_State (load_file_id_,
                                              rec_.row_no,
                                              '6',
                                              err_msg_);
      END IF;
   END LOOP;
   
   OPEN File_Trans;
   LOOP
      FETCH File_Trans BULK COLLECT INTO file_trans_rec_ LIMIT limit_;
      cnt_ := file_trans_rec_.COUNT;
      FOR i_ IN 1..file_trans_rec_.COUNT LOOP
         row_no_ := file_trans_rec_(i_).row_no;         
         IF first_row_ THEN
            first_row_no_ := row_no_;
            first_row_ := FALSE;
         END IF;         

         IF (cnt_ > i_) THEN
            next_row_no_ := file_trans_rec_(i_+1).row_no;         
         ELSE            
            -- set some high number since we don't know the next row_no
            -- due to end of array (could have been solved in a different way)
            -- The exit statement on row_state = '1' should make sure to not merge to many lines
            dbms_output.put_line('row_no_: '|| row_no_);
            next_row_no_ := 999999999999999999;
         END IF;
            
         detail_file_line_  := file_trans_rec_(i_).file_line;
         
         OPEN File_Trans_Sub;
         LOOP
            FETCH File_Trans_Sub BULK COLLECT INTO sub_file_trans_rec_ LIMIT limit_;
            --CLOSE File_Trans_Sub;      
            exit_ := FALSE;
            FOR k_ IN 1..sub_file_trans_rec_.COUNT LOOP      
               -- to handle the case when the end of the array is reached and might be more rows to fetch
               -- then use the row_state to know when to exit the inner loop and continue
               IF (sub_file_trans_rec_(k_).row_state = '1') THEN
                  exit_ := TRUE;
                  EXIT;
               END IF;                  

               IF (length(file_trans_rec_(i_).file_line) + Length(sub_file_trans_rec_(k_).file_line) > 4000 ) THEN
                  -- will this be correct(?), if string to large then set the "master" row's file_line and skip any "sub" rows). Bug 117470 added this handling
                  file_trans_rec_(i_).file_line  := detail_file_line_;
                  exit_ := TRUE;
                  EXIT;
               ELSIF (keep_line_feed_ = 'TRUE') THEN
                  file_trans_rec_(i_).file_line := file_trans_rec_(i_).file_line || '#' || CHR(13) || CHR(10) || sub_file_trans_rec_(k_).file_line;
               ELSE
                  file_trans_rec_(i_).file_line := file_trans_rec_(i_).file_line || '#' || sub_file_trans_rec_(k_).file_line;
               END IF;              
            END LOOP;
            EXIT WHEN (File_Trans_Sub%NOTFOUND OR exit_);
         END LOOP;
         CLOSE File_Trans_Sub;      
      END LOOP;      
      
      FORALL indx IN 1..file_trans_rec_.COUNT
        UPDATE Ext_File_Trans_Tab emp
           SET emp.file_line = file_trans_rec_(indx).file_line
         WHERE emp.rowid = file_trans_rec_(indx).objid;    
      
      EXIT WHEN File_Trans%NOTFOUND;
   END LOOP;
   CLOSE File_Trans;      
   
   DELETE FROM Ext_File_Trans_Tab
   WHERE  load_file_id = load_file_id_
   AND    row_state    != '1'
   AND    row_no       > first_row_no_;
END Merge_Skipped_File_Lines;


PROCEDURE Start_Api_Unp_Extra (
   info_                   IN OUT VARCHAR2,
   load_file_id_           IN     NUMBER,
   before_after_           IN     VARCHAR2 DEFAULT 'BEFORE',
   api_to_call_unp_before_ IN     VARCHAR2 DEFAULT NULL,
   api_to_call_unp_after_  IN     VARCHAR2 DEFAULT NULL )
IS
   api_to_call_         VARCHAR2(2000);
   package_method_      VARCHAR2(2000); 
   point_               NUMBER;
   parx_                NUMBER;
   pary_                NUMBER;
   parz_                NUMBER;
   param_               VARCHAR2(2000);
   param1_              VARCHAR2(100);
   param2_              VARCHAR2(100);
   param3_              VARCHAR2(100);
   param1x_             VARCHAR2(5)     := 'FALSE';
   param2x_             VARCHAR2(5)     := 'FALSE';
   param3x_             VARCHAR2(5)     := 'FALSE';
   package_name_        VARCHAR2(30);
   method_name_         VARCHAR2(2000);
   stmnt_               VARCHAR2(32000);
   ext_file_load_rec_   Ext_File_Load_API.Public_Rec;
BEGIN
   Client_SYS.Clear_Info;
   ext_file_load_rec_ := Ext_File_Load_API.Get( load_file_id_ );
  
   IF (before_after_ = 'BEFORE') THEN
      IF (api_to_call_unp_before_ IS NOT NULL) THEN
         api_to_call_      := api_to_call_unp_before_;
      ELSE
         api_to_call_      := Ext_File_Template_Dir_API.Get_Api_To_Call_Unp_Before ( ext_file_load_rec_.file_template_id, ext_file_load_rec_.file_direction );
      END IF;
   ELSE
      IF (api_to_call_unp_after_ IS NOT NULL) THEN
         api_to_call_      := api_to_call_unp_after_;
      ELSE
         api_to_call_      := Ext_File_Template_Dir_API.Get_Api_To_Call_Unp_After ( ext_file_load_rec_.file_template_id, ext_file_load_rec_.file_direction );
      END IF;
   END IF;
   
   package_method_      := api_to_call_;
   point_               := INSTR(package_method_,'.');
   IF (point_ = 0 OR api_to_call_ IS NULL) THEN
      Error_SYS.Appl_General( lu_name_, 'ATCERROR: Illegal Api To Call' );
   ELSE
      package_name_     := SUBSTR(package_method_,1,point_-1);
      method_name_      := SUBSTR(package_method_,point_+1);
      parx_             := INSTR(method_name_,'(');
      IF (parx_ > 0) THEN
         param_         := SUBSTR(method_name_,parx_);
         method_name_   := SUBSTR(method_name_,1,parx_-1);
      END IF;
      package_method_   := package_name_ || '.' || method_name_;
   END IF;
   --
   -- Check for the first parameter
   IF (param_ IS NOT NULL) THEN
      parx_             := INSTR(param_,'<');
      IF (parx_ > 0) THEN
         pary_          := INSTR(param_,'>');
         IF (pary_ > 0) THEN
            parz_       := pary_ - parx_ - 1;
            param1_     := SUBSTR(param_,parx_ +1, parz_);
            param1x_    := 'TRUE';
            param_      := SUBSTR(param_,pary_+1);
         ELSE
            param_      := NULL;
         END IF;
      ELSE
         param_         := NULL;
      END IF;
   END IF;
   --
   -- Check for the second parameter
   IF (param_ IS NOT NULL) THEN
      parx_             := INSTR(param_,'<');
      IF (parx_ > 0) THEN
         pary_          := INSTR(param_,'>');
         IF (pary_ > 0) THEN
            parz_       := pary_ - parx_ - 1;
            param2_     := SUBSTR(param_,parx_ +1, parz_);
            param2x_    := 'TRUE';
            param_      := SUBSTR(param_,pary_+1);
         ELSE
            param_      := NULL;
         END IF;
      ELSE
         param_         := NULL;
      END IF;
   END IF;
   --
   -- Check for the third parameter
   IF (param_ IS NOT NULL) THEN
      parx_             := INSTR(param_,'<');
      IF (parx_ > 0) THEN
         pary_          := INSTR(param_,'>');
         IF (pary_ > 0) THEN
            parz_       := pary_ - parx_ - 1;
            param3_     := SUBSTR(param_,parx_ +1, parz_);
            param3x_    := 'TRUE';
            param_      := SUBSTR(param_,pary_+1);
         ELSE
            param_      := NULL;
         END IF;
      ELSE
         param_         := NULL;
      END IF;
   END IF;
   package_name_   := LTRIM(RTRIM(package_name_));
   method_name_    := LTRIM(RTRIM(method_name_));
   package_method_ := LTRIM(RTRIM(package_method_));
   IF (NOT Dictionary_SYS.Method_Is_Active ( package_name_, method_name_ )) THEN
      Error_SYS.Appl_General( lu_name_, 'NOMETHOD: Method :P1 not found in package :P2',method_name_,package_name_ );
   ELSE
      -- Start the method with 3 parameters 
      Assert_SYS.Assert_Is_Package_Method(package_method_);
      IF    (param3x_ = 'TRUE') THEN
         stmnt_ := 'BEGIN ' || package_method_ || ' (:info_, :load_file_id_, :param1_, :param2_, :param3_ ); END;';
         @ApproveDynamicStatement(2005-12-05,ovjose)
         EXECUTE IMMEDIATE stmnt_ USING IN OUT info_, 
                                        IN     load_file_id_,
                                        IN     param1_,
                                        IN     param2_,
                                        IN     param3_;
      -- Start the method with 2 parameters 
      ELSIF (param2x_ = 'TRUE') THEN
         stmnt_ := 'BEGIN ' || package_method_ || ' (:info_, :load_file_id_, :param1_, :param2_ ); END;';
         @ApproveDynamicStatement(2005-12-05,ovjose)
         EXECUTE IMMEDIATE stmnt_ USING IN OUT info_, 
                                        IN     load_file_id_,
                                        IN     param1_,
                                        IN     param2_;
      -- Start the method with 1 parameter 
      ELSIF (param1x_ = 'TRUE') THEN
         stmnt_ := 'BEGIN ' || package_method_ || ' (:info_, :load_file_id_, :param1_ ); END;';
         @ApproveDynamicStatement(2005-12-05,ovjose)
         EXECUTE IMMEDIATE stmnt_ USING IN OUT info_, 
                                        IN     load_file_id_,
                                        IN     param1_;
      -- Start the method with no parameter 
      ELSE
         stmnt_ := 'BEGIN ' || package_method_ || ' (:info_, :load_file_id_); END;';
         @ApproveDynamicStatement(2005-12-05,ovjose)
         EXECUTE IMMEDIATE stmnt_ USING IN OUT info_, 
                                        IN     load_file_id_;
      END IF;
   END IF;
END Start_Api_Unp_Extra;


FUNCTION Is_Col_Parent_Key (
   view_name_   IN VARCHAR2,
   column_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_          VARCHAR2(5);
   CURSOR exist_control IS
      SELECT DECODE(SUBSTR(Dictionary_SYS.Comment_Value_('FLAGS',m.comments),1,1),'P','TRUE','FALSE') key_column
      FROM   user_tab_columns  c,
             user_col_comments m
      WHERE  c.table_name  = view_name_
      AND    c.column_name = column_name_
      AND    m.table_name  = c.table_name
      AND    m.column_name = c.column_name;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      dummy_ := 'FALSE';
   END IF;
   CLOSE exist_control;
   RETURN dummy_;
END Is_Col_Parent_Key;


PROCEDURE Get_Template_Data ( 
   templ_det_rec_     IN OUT ft_m_det_rec)
IS
   ft_                      NUMBER := 0;
   cf_                      NUMBER := 0;
   cfi_                     NUMBER := 0;
   gr_                      NUMBER := 0;
   cn_                      NUMBER := 0;
   send_file_temp_id_       VARCHAR2(30);
   send_file_direction_     VARCHAR2(1);
   ext_file_load_rec_       Ext_File_Load_API.Public_Rec;
   
   CURSOR detail_ IS
      SELECT D.row_no,
             D.record_type_id,
             D.Column_Id,
             C.Data_Type,
             D.Column_No,
             D.Start_Position,
             D.End_Position,
             DECODE(C.Data_Type,'2',H.Decimal_Symbol,NULL)                 Decimal_Symbol,
             DECODE(C.Data_Type,'2',NVL(D.Denominator,H.Denominator),NULL) Denominator,
             NVL(D.Date_Format,H.Date_Format)                              Date_Format,
             C.Destination_Column                                          Destination_Column,
             DECODE(NVL(D.Denominator,0),0,'N','Y')                        Detail_Denominator,
             NVL(RTRIM(RPAD(
                 Basic_Data_Translation_API.Get_Basic_Data_Translation(
                   'ACCRUL', 
                   'ExtFileTypeRecColumn', 
                   C.file_type || '^' || C.record_type_id || '^' || C.column_id ),
                   100)),C.description)                                    Description,
             D.control_column                                              control_column,
             D.max_length                                                  max_length
      FROM   Ext_File_Template_Detail_Tab D,
             Ext_File_Type_Rec_Column_Tab C,
             Ext_File_Template_Tab        H
      WHERE  D.file_template_id = templ_det_rec_.ext_file_rec.file_template_id
      AND    H.file_template_id = D.file_template_id
      AND    C.column_id        = D.column_id
      AND    C.file_type        = H.file_type
      AND    C.record_type_id   = D.record_type_id
      ORDER BY D.record_type_id,
               DECODE(templ_det_rec_.file_direction,'2',0,NVL(D.Column_Sort,0)),
               NVL(D.Column_No,NVL(D.Start_Position,99999)),
               D.Column_No, D.Start_Position;
   CURSOR function_ ( file_template_id_ IN VARCHAR2,
                      row_no_           IN NUMBER) IS
      SELECT row_no,
             function_no,
             main_function,
             function_argument
      FROM   Ext_File_Templ_Det_Func_Tab
      WHERE  file_template_id = file_template_id_
      AND    row_no           = row_no_
      ORDER BY row_no,function_no;
   CURSOR groups_ IS
      SELECT G.record_type_id,
             G.parent_record_type,
             Ext_File_Type_Rec_API.Get_Parent_Record_Types (G.file_type, G.parent_record_type) parent_record_types,
             G.record_set_id,
             G.first_in_record_set,
             G.last_in_record_set,
             G.mandatory_record
      FROM   Ext_File_Type_Rec_Tab G
      WHERE  G.file_type      = templ_det_rec_.ext_file_rec.file_type
      AND EXISTS
         (SELECT 1
          FROM   Ext_File_Template_Detail_Tab D
          WHERE  D.file_template_id = templ_det_rec_.ext_file_rec.file_template_id
          AND    D.record_type_id   = G.record_type_id)
      ORDER BY G.record_set_id,
               DECODE(G.first_in_record_set,'TRUE',0,1),
               DECODE(G.last_in_record_set,'TRUE',1,0),
               Ext_File_Type_Rec_API.Get_Parent_Record_Types (G.file_type, G.parent_record_type),
               G.record_type_id;
   CURSOR controls_ IS
      SELECT Record_Type_Id,
             Row_No,
             Group_No,
             Condition,
             Column_No,
             Start_Position,
             End_Position,
             Control_String,
             Destination_Column,
             No_Of_Lines
      FROM   Ext_File_Template_Control_Tab
      WHERE  file_template_id = templ_det_rec_.ext_file_rec.file_template_id
      AND    file_direction   = templ_det_rec_.file_direction
      ORDER BY Group_No, Row_No;
   CURSOR functions_ IS
      SELECT function_id,
             description,
             valid_argument,
             min_num_of_args,
             max_num_of_args
      FROM   Ext_File_Function_Tab
      ORDER BY function_id;
BEGIN
   ext_file_load_rec_ := Ext_File_Load_API.Get(templ_det_rec_.load_file_id );
   IF (templ_det_rec_.ext_file_rec.file_template_id IS NULL) THEN
      templ_det_rec_.ext_file_rec.file_template_id := ext_file_load_rec_.file_template_id;
   END IF;
   templ_det_rec_.parameter_string             := ext_file_load_rec_.parameter_string;
   templ_det_rec_.company                      := ext_file_load_rec_.company;
   send_file_temp_id_                          := templ_det_rec_.ext_file_rec.file_template_id;
   send_file_direction_                        := templ_det_rec_.file_direction;
   Ext_File_Template_API.Get_Ext_File_Head ( templ_det_rec_.ext_file_rec,
                                             send_file_temp_id_,
                                             send_file_direction_);
   FOR rec_ IN detail_ LOOP
      ft_                                                := ft_ + 1;
      templ_det_rec_.ft_list(ft_).row_no                  := rec_.row_no;
      templ_det_rec_.ft_list(ft_).record_type_id          := rec_.record_type_id;
      templ_det_rec_.ft_list(ft_).column_id               := rec_.column_id;
      templ_det_rec_.ft_list(ft_).data_type               := rec_.data_type;
      templ_det_rec_.ft_list(ft_).column_no               := rec_.column_no;
      templ_det_rec_.ft_list(ft_).start_position          := rec_.start_position;
      IF (rec_.Start_Position IS NOT NULL) THEN
         templ_det_rec_.ft_list(ft_).length_position      := NVL(rec_.End_Position,rec_.Start_Position) - rec_.Start_Position + 1;
      ELSE
         templ_det_rec_.ft_list(ft_).length_position      := NULL;
      END IF;
      templ_det_rec_.ft_list(ft_).decimal_symbol          := rec_.decimal_symbol;
      IF (rec_.Detail_Denominator = 'Y') THEN
         templ_det_rec_.ft_list(ft_).decimal_symbol       := NULL;
      END IF;
      templ_det_rec_.ft_list(ft_).denominator             := rec_.denominator;
      templ_det_rec_.ft_list(ft_).date_format             := rec_.date_format;
      templ_det_rec_.ft_list(ft_).destination_column      := rec_.destination_column;
      templ_det_rec_.ft_list(ft_).control_column          := rec_.control_column;
      templ_det_rec_.ft_list(ft_).description             := rec_.description;
      templ_det_rec_.ft_list(ft_).max_length              := rec_.max_length;
      cfi_ := 0;
      FOR recf_ IN function_ (templ_det_rec_.ext_file_rec.file_template_id, rec_.row_no) LOOP
         IF (templ_det_rec_.file_direction = '2' AND 
             recf_.main_function = 'X_ATTRIBUTE') THEN
            NULL;
         ELSE
            cf_                                             := cf_ + 1;
            IF (cfi_ = 0) THEN
               templ_det_rec_.ft_list(ft_).funct_detail_from := cf_;
            END IF;
            templ_det_rec_.ft_list(ft_).funct_detail_to      := cf_;
            cfi_    := cfi_ + 1;
            templ_det_rec_.cf_list(cf_).row_no               := recf_.row_no;
            templ_det_rec_.cf_list(cf_).function_no          := recf_.function_no;
            templ_det_rec_.cf_list(cf_).main_function        := recf_.main_function;
            --Templ_Det_Rec.cf_list(cf_).function_argument    := REPLACE(recf_.function_argument,' ');
            templ_det_rec_.cf_list(cf_).function_argument    := recf_.function_argument;
         END IF;
      END LOOP;
      templ_det_rec_.ft_list(ft_).function_detail         := cfi_;
   END LOOP;
   templ_det_rec_.max_ft                                  := ft_;
   templ_det_rec_.max_cf                                  := cf_;
   --
   templ_det_rec_.gr_any_first := 'FALSE';
   templ_det_rec_.gr_any_last  := 'FALSE';
   FOR rec_ IN groups_ LOOP
      gr_     := gr_ + 1;
      templ_det_rec_.gr_list(gr_).record_type_id      := rec_.record_type_id;
      templ_det_rec_.gr_list(gr_).parent_record_type  := rec_.parent_record_type;
      templ_det_rec_.gr_list(gr_).record_set_id       := rec_.record_set_id;
      templ_det_rec_.gr_list(gr_).first_in_record_set := rec_.first_in_record_set;
      templ_det_rec_.gr_list(gr_).last_in_record_set  := rec_.last_in_record_set;
      templ_det_rec_.gr_list(gr_).mandatory_record    := rec_.mandatory_record;
      templ_det_rec_.gr_list(gr_).record_set_count    := 0;
      IF (rec_.first_in_record_set = 'TRUE') THEN
         templ_det_rec_.gr_any_first := 'TRUE';
      END IF;
      IF (rec_.last_in_record_set = 'TRUE') THEN
         templ_det_rec_.gr_any_last := 'TRUE';
      END IF;
   END LOOP;
   templ_det_rec_.max_gr                              := gr_;
   --
   FOR rec_ IN controls_ LOOP
      cn_     := cn_ + 1;
      templ_det_rec_.cn_list(cn_).record_type_id     := rec_.record_type_id;
      templ_det_rec_.cn_list(cn_).row_no             := rec_.row_no;
      templ_det_rec_.cn_list(cn_).group_no           := rec_.group_no;
      templ_det_rec_.cn_list(cn_).condition          := rec_.condition;
      templ_det_rec_.cn_list(cn_).column_no          := rec_.column_no;
      templ_det_rec_.cn_list(cn_).start_position     := rec_.start_position;
      IF (rec_.Start_Position IS NOT NULL) THEN
         templ_det_rec_.cn_list(cn_).length_position := NVL(rec_.end_position,rec_.start_position) - rec_.start_position + 1;
      ELSE
         templ_det_rec_.cn_list(cn_).length_position := NULL;
      END IF;
      templ_det_rec_.cn_list(cn_).control_string     := rec_.control_string;
      templ_det_rec_.cn_list(cn_).destination_column := rec_.destination_column;
      templ_det_rec_.cn_list(cn_).no_of_lines        := rec_.no_of_lines;
   END LOOP;
   templ_det_rec_.max_cn                             := cn_;
   --
   FOR rec_ IN functions_ LOOP
      templ_det_rec_.func_list(rec_.function_id).description     := rec_.description;
      templ_det_rec_.func_list(rec_.function_id).valid_argument  := rec_.valid_argument;
      templ_det_rec_.func_list(rec_.function_id).min_num_of_args := rec_.min_num_of_args;
      templ_det_rec_.func_list(rec_.function_id).max_num_of_args := rec_.max_num_of_args;
   END LOOP;
END Get_Template_Data;


PROCEDURE Create_Xml_File (
   load_file_id_     IN NUMBER,
   file_is_xml_type_ OUT VARCHAR2)
IS
   xml_layout_id_    VARCHAR2(30);
   bizapi_name_      VARCHAR2(30);
   message_id_       NUMBER;
   list_array_       Ext_File_Trans_Head_Structure_Arr := Ext_File_Trans_Head_Structure_Arr();
   clob_             CLOB;
   ifs_xml_clob_     CLOB; 
   doc_                 Plsqlap_Document_API.Document;
   ext_file_load_rec_   Ext_File_Load_API.Public_Rec;
BEGIN
   ext_file_load_rec_ := Ext_File_Load_API.Get(load_file_id_);
   xml_layout_id_     := NVL(ext_file_load_rec_.xml_layout_id,
                             Ext_File_Template_Dir_API.Get_Xml_Layout_Id (ext_file_load_rec_.file_template_id, '2'));
   file_is_xml_type_ := 'FALSE';
   
   IF (xml_layout_id_ IS NOT NULL) THEN
      file_is_xml_type_ := 'TRUE';
      bizapi_name_      := Ext_File_Xml_Layout_API.Get_Bizapi_Name(xml_layout_id_);
      
      IF (bizapi_name_ = 'SEND_TAX_XML_FILE') THEN            
         list_array_ := Get_Head_Structure_Arr___(load_file_id_);
         clob_ := Ext_File_Trans_Head_Structure_Arr_To_Xml___(list_array_);

         Plsqlap_Document_API.From_Xml(doc_, clob_, add_type_ => TRUE);
         Plsqlap_Document_API.To_Upper_Case(doc_);

         -- Rename to match names used in BizAPIs to be backward compatible
         Plsqlap_Document_API.Rename(doc_, 'EXT_FILE_TRANS_HEAD_STRUCTURE_ARRAY', 'EXT_FILE_TRANS_HEAD_LIST', FALSE, TRUE, FALSE);   
         Plsqlap_Document_API.Rename(doc_, 'EXT_FILE_TRANS_HEAD_STRUCTURE', 'EXT_FILE_TRANS_HEAD', FALSE, FALSE, TRUE);         

         Plsqlap_Document_API.To_Xml(ifs_xml_clob_, doc_, xml_attrs_ => TRUE, add_header_ => TRUE, elem_type_ => FALSE, use_crlf_ => TRUE);   

         Plsqlap_Server_API.Post_Outbound_Message(ifs_xml_clob_,
                                                  message_id_,                                              
                                                  sender_       => ext_file_load_rec_.company||'_'||TO_CHAR(sysdate,'yyyymmdd HH.mm.ss'),
                                                  receiver_     => xml_layout_id_,                                            
                                                  message_type_ => 'APPLICATION_MESSAGE',                                            
                                                  message_function_ => bizapi_name_);                                                             
      END IF;
      Ext_File_Load_API.Update_State (load_file_id_, '7');
   END IF;   
END Create_Xml_File;


@UncheckedAccess
FUNCTION Is_File_Xml_Type (
   load_file_id_ IN NUMBER ) RETURN VARCHAR2
IS
   file_template_id_  VARCHAR2(30);
   xml_layout_id_     VARCHAR2(30);
BEGIN
   file_template_id_:= Ext_File_Load_API.Get_File_Template_Id (load_file_id_);
   xml_layout_id_   := Ext_File_Template_Dir_API.Get_Xml_Layout_Id (file_template_id_, '2');
   IF (xml_layout_id_ IS NOT NULL) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Is_File_Xml_Type;



PROCEDURE Describe_Input_File (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER )
IS
   templ_det_rec_             External_File_Utility_API.ft_m_det_rec;
   ext_file_load_rec_         Ext_File_Load_API.Public_Rec;
   parameter_attr_            VARCHAR2(2000);
   d_desc_value_tab_          External_File_Utility_API.CharSmallTabType;
   record_type_id_            VARCHAR2(20);
   record_type_desc_          VARCHAR2(200);
   file_type_                 Ext_File_Template_Detail_Tab.File_Type%TYPE;
   file_template_id_          Ext_File_Template_Detail_Tab.File_Template_Id%TYPE;
   file_type_desc_            VARCHAR2(200);
   row_no_                    NUMBER          := 0;
   file_line_                 VARCHAR2(4000);
   file_line1_                VARCHAR2(4000);
   file_line2_                VARCHAR2(4000);
   CURSOR get_rec_types IS
      SELECT DISTINCT 
             d.record_type_id,
             r.record_set_id,
             r.first_in_record_set,
             r.last_in_record_set,
             Ext_File_Type_Rec_API.Get_Parent_Record_Types (r.file_type, r.parent_record_type)
      FROM   Ext_File_Template_Detail_Tab d,
             Ext_File_Type_Rec_Tab        r
      WHERE  d.file_template_id = file_template_id_
      AND    r.file_type        = d.file_type
      AND    r.record_type_id   = d.record_type_id
      ORDER BY r.record_set_id,
               DECODE(r.first_in_record_set,'TRUE',0,1),
               DECODE(r.last_in_record_set,'TRUE',1,0),
               Ext_File_Type_Rec_API.Get_Parent_Record_Types (r.file_type, r.parent_record_type),
               d.record_type_id;
BEGIN
   ext_file_load_rec_ := Ext_File_Load_API.Get (load_file_id_);
   parameter_attr_    := ext_file_load_rec_.parameter_string;
   Message_SYS.Get_Attribute (parameter_attr_, 'FILE_TEMPLATE_IDX', file_template_id_);
   --
   templ_det_rec_.load_file_id                  := load_file_id_;
   templ_det_rec_.file_direction                := '1';
   templ_det_rec_.ext_file_rec.file_template_id := file_template_id_;
   External_File_Utility_API.Get_Template_Data (templ_det_rec_);
   --
   file_type_desc_ := Ext_File_Type_API.Get_Description (templ_det_rec_.ext_file_rec.file_type);
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := 'Description of Input File Template';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := 'File Type     : ' || rpad(file_type_,22,' ') || file_type_desc_;
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := 'File Template : ' || rpad(file_template_id_,22,' ') || templ_det_rec_.ext_file_rec.description;
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   --
   FOR reca_ IN get_rec_types LOOP
      record_type_id_   := reca_.record_type_id;
      record_type_desc_ := Ext_File_Type_Rec_API.Get_Description ( file_type_, record_type_id_ );
      Desc_Col_To_Line___ (file_line1_,
                           file_line2_,
                           templ_det_rec_,
                           d_desc_value_tab_,
                           record_type_id_);
      file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      file_line_ := 'Record Type   : ' || rpad(record_type_id_,22,' ') || record_type_desc_;
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      file_line_ := ' ';
      Desc_Record_Type___ (row_no_,
                           record_type_id_,
                           templ_det_rec_);
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      IF (templ_det_rec_.ext_file_rec.file_format = 'SEP') THEN
         file_line_ := 'Description:';
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
         file_line_ := SUBSTR(file_line1_,1,2000);
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
         file_line_ := ' ';
         Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      END IF;
      file_line_ := 'Example:';
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      file_line_ := SUBSTR(file_line2_,1,2000);
      IF (templ_det_rec_.ext_file_rec.file_format != 'SEP') THEN
         Desc_Control_Fixed_File___ (file_line_,
                                     record_type_id_,
                                     templ_det_rec_);
      END IF;
      row_no_ := Ext_File_Trans_API.Get_Max_Row_No (load_file_id_);
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
      file_line_ := ' ';
      Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   END LOOP;
   file_line_ := ' ';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( templ_det_rec_.load_file_id, row_no_, file_line_ );
   Ext_File_Trans_API.Update_State_Load ( load_file_id_, '1', '2' );
   Ext_File_Load_API.Update_State (load_file_id_, '3',NULL);
END Describe_Input_File;


PROCEDURE File_Type_Row (
   file_type_                IN Ext_File_Type_Tab.file_type%TYPE, 
   description_              IN Ext_File_Type_Tab.description%TYPE, 
   component_                IN Ext_File_Type_Tab.component%TYPE, 
   system_defined_           IN Ext_File_Type_Tab.system_defined%TYPE, 
   system_bound_             IN Ext_File_Type_Tab.system_bound%TYPE, 
   view_name_                IN Ext_File_Type_Tab.view_name%TYPE, 
   form_name_                IN Ext_File_Type_Tab.form_name%TYPE, 
   target_default_method_    IN Ext_File_Type_Tab.target_default_method%TYPE,
   api_to_call_input_        IN Ext_File_Type_Tab.api_to_call_input%TYPE,
   api_to_call_output_       IN Ext_File_Type_Tab.api_to_call_output%TYPE,   
   input_projection_action_  IN Ext_File_Type_Tab.input_projection_action%TYPE DEFAULT NULL,
   output_projection_action_ IN Ext_File_Type_Tab.output_projection_action%TYPE DEFAULT NULL)
IS
   newrec_                Ext_File_Type_Tab%ROWTYPE;
BEGIN
   newrec_.file_type                := file_type_;
   newrec_.description              := description_;
   newrec_.component                := component_;
   newrec_.system_defined           := system_defined_;
   newrec_.system_bound             := system_bound_;
   newrec_.view_name                := view_name_;
   newrec_.form_name                := form_name_;
   newrec_.target_default_method    := target_default_method_;
   newrec_.api_to_call_input        := api_to_call_input_;
   newrec_.api_to_call_output       := api_to_call_output_;
   newrec_.input_projection_action  := input_projection_action_;
   newrec_.output_projection_action := output_projection_action_;
   newrec_.rowversion               := SYSDATE;
   Ext_File_Type_API.Insert_Lu_Data_Rec__(newrec_);
END File_Type_Row;


PROCEDURE File_Type_Rec_Row (
   file_type_             IN Ext_File_Type_Rec_Tab.file_type%TYPE, 
   record_type_id_        IN Ext_File_Type_Rec_Tab.record_type_id%TYPE, 
   description_           IN Ext_File_Type_Rec_Tab.description%TYPE, 
   record_set_id_         IN Ext_File_Type_Rec_Tab.record_set_id%TYPE, 
   first_in_record_set_   IN Ext_File_Type_Rec_Tab.first_in_record_set%TYPE, 
   last_in_record_set_    IN Ext_File_Type_Rec_Tab.last_in_record_set%TYPE, 
   mandatory_record_      IN Ext_File_Type_Rec_Tab.mandatory_record%TYPE,
   view_name_             IN Ext_File_Type_Rec_Tab.view_name%TYPE,
   input_package_         IN Ext_File_Type_Rec_Tab.input_package%TYPE, 
   parent_record_type_    IN Ext_File_Type_Rec_Tab.parent_record_type%TYPE)
IS
   newrec_                Ext_File_Type_Rec_Tab%ROWTYPE;
BEGIN
   newrec_.file_type             := file_type_;
   newrec_.record_type_id        := record_type_id_;
   newrec_.description           := description_;
   newrec_.record_set_id         := record_set_id_;
   newrec_.first_in_record_set   := first_in_record_set_;
   newrec_.last_in_record_set    := last_in_record_set_;
   newrec_.mandatory_record      := mandatory_record_;
   newrec_.parent_record_type    := parent_record_type_;
   newrec_.view_name             := view_name_;
   newrec_.input_package         := input_package_;
   newrec_.rowversion            := SYSDATE;
   Ext_File_Type_Rec_API.Insert_Lu_Data_Rec__(newrec_);
END File_Type_Rec_Row;


PROCEDURE File_Type_Rec_Column_Row (
   file_type_          IN Ext_File_Type_Rec_Column_Tab.file_type%TYPE, 
   record_type_id_     IN Ext_File_Type_Rec_Column_Tab.record_type_id%TYPE, 
   column_id_          IN Ext_File_Type_Rec_Column_Tab.column_id%TYPE, 
   description_        IN Ext_File_Type_Rec_Column_Tab.description%TYPE, 
   data_type_          IN Ext_File_Type_Rec_Column_Tab.data_type%TYPE, 
   mandatory_          IN Ext_File_Type_Rec_Column_Tab.mandatory%TYPE,
   destination_column_ IN Ext_File_Type_Rec_Column_Tab.destination_column%TYPE)
IS
   newrec_                Ext_File_Type_Rec_Column_Tab%ROWTYPE;
BEGIN

   newrec_.file_type           := file_type_;
   newrec_.record_type_id      := record_type_id_;
   newrec_.column_id           := column_id_;
   newrec_.description         := description_;
   newrec_.data_type           := data_type_;
   newrec_.mandatory           := mandatory_;
   newrec_.destination_column  := destination_column_;
   newrec_.rowversion          := SYSDATE;
   Ext_File_Type_Rec_Column_API.Insert_Lu_Data_Rec__(newrec_);
END File_Type_Rec_Column_Row;


PROCEDURE File_Type_Param_Row (
   file_type_          IN Ext_File_Type_Param_Tab.file_type%TYPE, 
   param_no_           IN Ext_File_Type_Param_Tab.param_no%TYPE, 
   param_id_           IN Ext_File_Type_Param_Tab.param_id%TYPE, 
   description_        IN Ext_File_Type_Param_Tab.description%TYPE, 
   lov_view_           IN Ext_File_Type_Param_Tab.lov_view%TYPE, 
   enumerate_method_   IN Ext_File_Type_Param_Tab.enumerate_method%TYPE, 
   validate_method_    IN Ext_File_Type_Param_Tab.validate_method%TYPE, 
   browsable_field_    IN Ext_File_Type_Param_Tab.browsable_field%TYPE, 
   help_text_          IN Ext_File_Type_Param_Tab.help_text%TYPE, 
   data_type_          IN Ext_File_Type_Param_Tab.data_type%TYPE)
IS
   newrec_      Ext_File_Type_Param_Tab%ROWTYPE;
BEGIN

   newrec_.file_type           := file_type_;
   newrec_.param_no            := param_no_;
   newrec_.param_id            := param_id_;
   newrec_.Description         := description_;
   newrec_.lov_view            := lov_view_;
   newrec_.enumerate_method    := enumerate_method_;
   newrec_.validate_method     := validate_method_;
   newrec_.browsable_field     := browsable_field_;
   newrec_.help_text           := help_text_;
   newrec_.data_type           := data_type_;
   newrec_.validate_method     := validate_method_;
   newrec_.rowversion          := SYSDATE;
   Ext_File_Type_Param_API.Insert_Lu_Data_Rec__(newrec_);
END File_Type_Param_Row;


PROCEDURE File_Type_Param_Set_Row (
   file_type_          IN Ext_Type_Param_Set_Tab.file_type%TYPE, 
   set_id_             IN Ext_Type_Param_Set_Tab.set_id%TYPE, 
   description_        IN Ext_Type_Param_Set_Tab.description%TYPE, 
   set_id_default_     IN Ext_Type_Param_Set_Tab.set_id_default%TYPE)
IS
   newrec_      Ext_Type_Param_Set_Tab%ROWTYPE;
BEGIN

   newrec_.file_type           := file_type_;
   newrec_.set_id              := set_id_;
   newrec_.description         := description_;
   newrec_.set_id_default      := set_id_default_;
   newrec_.rowversion          := SYSDATE;
   Ext_Type_Param_Set_API.Insert_Lu_Data_Rec__(newrec_);
END File_Type_Param_Set_Row;


PROCEDURE File_Type_Param_Per_Set_Row(
   file_type_          IN Ext_Type_Param_Per_Set_Tab.file_type%TYPE, 
   set_id_             IN Ext_Type_Param_Per_Set_Tab.set_id%TYPE, 
   param_no_           IN Ext_Type_Param_Per_Set_Tab.param_no%TYPE, 
   default_value_      IN Ext_Type_Param_Per_Set_Tab.default_value%TYPE, 
   mandatory_param_    IN Ext_Type_Param_Per_Set_Tab.mandatory_param%TYPE, 
   show_at_load_       IN Ext_Type_Param_Per_Set_Tab.show_at_load%TYPE, 
   inputable_at_load_  IN Ext_Type_Param_Per_Set_Tab.inputable_at_load%TYPE)
IS
BEGIN

INSERT
   INTO ext_type_param_per_set_tab (
      file_type,
      param_no,
      set_id,
      default_value,
      mandatory_param,
      show_at_load,
      inputable_at_load,
      rowversion)
   VALUES (
      file_type_,
      param_no_,
      set_id_,
      default_value_,
      mandatory_param_,
      show_at_load_,
      inputable_at_load_,
      SYSDATE);
END File_Type_Param_Per_Set_Row;


PROCEDURE File_Template_Row (
   file_type_             IN Ext_File_Template_Tab.file_type%TYPE, 
   file_template_id_      IN Ext_File_Template_Tab.file_template_id%TYPE, 
   description_           IN Ext_File_Template_Tab.description%TYPE, 
   separated_             IN Ext_File_Template_Tab.separated%TYPE, 
   file_format_           IN Ext_File_Template_Tab.file_format%TYPE,
   separator_id_          IN Ext_File_Template_Tab.separator_id%TYPE, 
   decimal_symbol_        IN Ext_File_Template_Tab.decimal_symbol%TYPE,
   denominator_           IN Ext_File_Template_Tab.denominator%TYPE, 
   date_format_           IN Ext_File_Template_Tab.date_format%TYPE, 
   system_defined_        IN Ext_File_Template_Tab.system_defined%TYPE, 
   active_definition_     IN Ext_File_Template_Tab.active_definition%TYPE, 
   valid_definition_      IN Ext_File_Template_Tab.valid_definition%TYPE, 
   date_nls_calendar_     IN Ext_File_Template_Tab.date_nls_calendar%TYPE,
   text_qualifier_        IN Ext_File_Template_Tab.text_qualifier%TYPE DEFAULT NULL)
IS
   newrec_                Ext_File_Template_Tab%ROWTYPE;
BEGIN

   newrec_.file_type             := file_type_;
   newrec_.file_template_id      := file_template_id_;
   newrec_.description           := description_;
   newrec_.system_defined        := system_defined_;
   newrec_.active_definition     := active_definition_;
   newrec_.valid_definition      := valid_definition_;
   newrec_.separated             := separated_;
   newrec_.file_format           := file_format_;
   newrec_.decimal_symbol        := decimal_symbol_;
   newrec_.date_format           := date_format_;
   newrec_.denominator           := denominator_;
   newrec_.date_nls_calendar     := date_nls_calendar_;
   newrec_.separator_id          := separator_id_;
   newrec_.text_qualifier        := text_qualifier_;
   newrec_.rowversion            := SYSDATE;
   Ext_File_Template_API.Insert_Lu_Data_Rec__(newrec_);
END File_Template_Row;


PROCEDURE File_Template_Dir_Row(
   file_template_id_          IN VARCHAR2, 
   file_direction_            IN VARCHAR2,
   log_skipped_lines_         IN VARCHAR2,
   log_invalid_lines_         IN VARCHAR2,
   skip_all_blanks_           IN VARCHAR2,
   skip_initial_blanks_       IN VARCHAR2,
   allow_record_set_repeat_   IN VARCHAR2,
   allow_one_record_set_only_ IN VARCHAR2,
   abort_immediatly_          IN VARCHAR2,
   load_file_type_list_       IN VARCHAR2,
   rowtype_                   IN VARCHAR2,
   api_to_call_               IN VARCHAR2,
   remove_days_               IN NUMBER,
   remove_complete_           IN VARCHAR2,
   overwrite_file_            IN VARCHAR2,
   create_header_             IN VARCHAR2,
   name_option_               IN VARCHAR2,
   file_name_                 IN VARCHAR2 DEFAULT NULL,
   character_set_             IN VARCHAR2 DEFAULT NULL,
   api_to_call_unp_before_    IN VARCHAR2 DEFAULT NULL,
   api_to_call_unp_after_     IN VARCHAR2 DEFAULT NULL,
   xml_layout_id_             IN VARCHAR2 DEFAULT NULL,
   number_out_fill_value_     IN VARCHAR2 DEFAULT NULL,
   remove_end_separator_      IN VARCHAR2 DEFAULT NULL)
IS
   dummy_                        NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Template_Dir_Tab
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_;
BEGIN

   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      BEGIN
         INSERT INTO Ext_File_Template_Dir_Tab 
            (file_template_id,
             file_direction,
             log_skipped_lines,
             log_invalid_lines,
             skip_all_blanks,
             skip_initial_blanks,
             allow_record_set_repeat,
             allow_one_record_set_only,
             abort_immediatly,
             load_file_type_list,
             rowtype,
             api_to_call,
             remove_days,
             remove_complete,
             overwrite_file,
             create_header,
             name_option,
             file_name,
             character_set,
             api_to_call_unp_before,
             api_to_call_unp_after,
             xml_layout_id,
             number_out_fill_value,
             remove_end_separator,
             Rowversion)
         VALUES
            (file_template_id_, 
             file_direction_,
             log_skipped_lines_,
             log_invalid_lines_,
             skip_all_blanks_,
             skip_initial_blanks_,
             allow_record_set_repeat_,
             allow_one_record_set_only_,
             abort_immediatly_,
             load_file_type_list_,
             rowtype_,
             api_to_call_,
             remove_days_,
             remove_complete_,
             overwrite_file_,
             create_header_,
             name_option_,
             file_name_,
             character_set_,
             REPLACE(api_to_call_unp_before_,'"',CHR(39)),
             REPLACE(api_to_call_unp_after_,'"',CHR(39)),
             xml_layout_id_,
             number_out_fill_value_,
             remove_end_separator_,
             SYSDATE);
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;      
      END;
   ELSE
      UPDATE Ext_File_Template_Dir_Tab SET
         log_skipped_lines          = log_skipped_lines_,
         log_invalid_lines          = log_invalid_lines_,
         skip_all_blanks            = skip_all_blanks_,
         skip_initial_blanks        = skip_initial_blanks_,
         allow_record_set_repeat    = allow_record_set_repeat_,
         allow_one_record_set_only  = allow_one_record_set_only_,
         abort_immediatly           = abort_immediatly_,
         rowtype                    = rowtype_,
         api_to_call                = api_to_call_,
         overwrite_file             = overwrite_file_,
         create_header              = create_header_,
         name_option                = name_option_,
         character_set              = character_set_,
         api_to_call_unp_before     = REPLACE(api_to_call_unp_before_,'"',CHR(39)),
         api_to_call_unp_after      = REPLACE(api_to_call_unp_after_,'"',CHR(39)),
         xml_layout_id              = xml_layout_id_,
         number_out_fill_value      = number_out_fill_value_,
         remove_end_separator       = remove_end_separator_
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_;
   END IF;
   CLOSE exist_control;
END File_Template_Dir_Row;


PROCEDURE File_Template_Det_Row (
   row_no_             IN OUT NUMBER,
   file_template_id_   IN VARCHAR2, 
   file_type_          IN VARCHAR2, 
   record_type_id_     IN VARCHAR2, 
   column_id_          IN VARCHAR2, 
   column_no_          IN NUMBER, 
   start_position_     IN NUMBER, 
   end_position_       IN NUMBER, 
   denominator_        IN NUMBER, 
   date_format_        IN VARCHAR2, 
   control_column_     IN VARCHAR2,
   hide_column_        IN VARCHAR2 DEFAULT 'FALSE',
   column_sort_        IN NUMBER   DEFAULT NULL,
   max_length_         IN NUMBER   DEFAULT NULL)
IS
   dummy_                 NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   ext_file_template_detail_tab
      WHERE  file_template_id = file_template_id_
      AND    record_type_id   = record_type_id_
      AND    column_id        = column_id_;
   CURSOR get_rowno IS
      SELECT NVL(MAX(row_no),0)
      FROM   ext_file_template_detail_tab
      WHERE  file_template_id = file_template_id_ ;
BEGIN

   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      BEGIN
         OPEN get_rowno;
         FETCH get_rowno INTO row_no_;
         IF (get_rowno%NOTFOUND) THEN
            row_no_ := 0;
         END IF;
         CLOSE get_rowno;
         row_no_ := row_no_ + 1;
         INSERT INTO Ext_File_Template_Detail_Tab 
            (file_template_id,
             row_no, 
             file_type, 
             record_type_id, 
             column_id, 
             column_no, 
             start_position, 
             end_position, 
             denominator, 
             date_format, 
             control_column,
             hide_column,
             column_sort,
             max_length,
             rowversion)
         VALUES
            (file_template_id_,
             row_no_,
             file_type_, 
             record_type_id_, 
             column_id_, 
             column_no_, 
             start_position_, 
             end_position_, 
             denominator_, 
             date_format_, 
             control_column_,
             hide_column_,
             column_sort_,
             max_length_,
             SYSDATE);
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;      
      END;
   END IF;
   CLOSE exist_control;
END File_Template_Det_Row;


PROCEDURE File_Template_Func_Row (
   row_no_            IN NUMBER,
   file_template_id_  IN VARCHAR2,
   function_no_       IN NUMBER,
   main_function_     IN VARCHAR2,
   function_argument_ IN VARCHAR2)
IS
BEGIN

   INSERT
      INTO ext_file_templ_det_func_tab (
         file_template_id,
         row_no,
         function_no,
         function_argument,
         main_function,
         rowversion)
      VALUES (
         file_template_id_,
         row_no_,
         function_no_,
         function_argument_,
         main_function_,
         SYSDATE);
   EXCEPTION
      WHEN dup_val_on_index THEN
         NULL;      
END File_Template_Func_Row;


PROCEDURE File_Template_Ctrl_Row(
   file_template_id_    IN VARCHAR2, 
   file_type_           IN VARCHAR2, 
   record_type_id_      IN VARCHAR2, 
   row_no_              IN NUMBER, 
   file_direction_      IN VARCHAR2,
   group_no_            IN NUMBER, 
   condition_           IN VARCHAR2, 
   column_no_           IN NUMBER, 
   start_position_      IN NUMBER, 
   end_position_        IN NUMBER, 
   control_string_      IN VARCHAR2,
   destination_column_  IN VARCHAR2,
   no_of_lines_         IN NUMBER   DEFAULT NULL )
IS
   dummy_                        NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Template_Control_Tab
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_
      AND    row_no           = row_no_;
BEGIN

   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      BEGIN
         INSERT INTO Ext_File_Template_Control_Tab 
            (file_template_id, 
             file_type, 
             record_type_id, 
             row_no,
             file_direction, 
             group_no, 
             condition, 
             column_no, 
             start_position, 
             end_position, 
             control_string,
             destination_column, 
             no_of_lines, 
             Rowversion)
         VALUES
            (file_template_id_, 
             file_type_, 
             record_type_id_, 
             row_no_,
             file_direction_, 
             group_no_, 
             condition_, 
             column_no_, 
             start_position_, 
             end_position_, 
             control_string_,
             destination_column_, 
             no_of_lines_, 
             SYSDATE);
      EXCEPTION
         WHEN dup_val_on_index THEN
            NULL;      
      END;
   ELSE
      UPDATE Ext_File_Template_Control_Tab SET
         record_type_id     = record_type_id_,
         file_type          = file_type_,
         group_no           = group_no_,
         condition          = condition_,
         column_no          = column_no_,
         start_position     = start_position_,
         end_position       = end_position_,
         control_string     = control_string_,
         destination_column = destination_column_,
         no_of_lines        = no_of_lines_
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = file_direction_
      AND    row_no           = row_no_;
   END IF;
   CLOSE exist_control;

END File_Template_Ctrl_Row;


PROCEDURE File_Type_Export (
   load_file_id_      IN     NUMBER,
   file_type_         IN     VARCHAR2,
   file_template_id_  IN     VARCHAR2,
   row_no_            IN OUT NUMBER)
IS
   ft_rec_                    Ext_File_Type_Tab%ROWTYPE;
   --
   file_line_                 VARCHAR2(4000);
   CURSOR get_file_type IS
      SELECT *
      FROM   Ext_File_Type_Tab
      WHERE  file_type = file_type_;
   CURSOR get_file_rec IS
      SELECT *
      FROM   Ext_File_Type_Rec_Tab
      WHERE  file_type = file_type_
      ORDER BY record_type_id;
   CURSOR get_file_col IS
      SELECT *
      FROM   Ext_File_Type_Rec_Column_Tab
      WHERE  file_type = file_type_
      ORDER BY record_type_id, column_id;
   CURSOR get_file_par IS
      SELECT *
      FROM   Ext_File_Type_Param_Tab
      WHERE  file_type = file_type_
      ORDER BY param_no;
   CURSOR get_file_set IS
      SELECT *
      FROM   Ext_Type_Param_Set_Tab
      WHERE  file_type = file_type_
      ORDER BY set_id;
   CURSOR get_file_per_set IS
      SELECT *
      FROM   Ext_Type_Param_Per_Set_Tab
      WHERE  file_type = file_type_
      ORDER BY set_id, param_no;
BEGIN
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'PROMPT Insert Instructions for file type';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   --
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'DECLARE ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   row_no_                NUMBER;';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'BEGIN ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   OPEN  get_file_type;
   FETCH get_file_type INTO ft_rec_;
   CLOSE get_file_type;
   file_line_ := '   DELETE FROM Ext_File_Type_Tab WHERE  file_type = '||CHR(39)||ft_rec_.file_type||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   External_File_Utility_API.File_Type_Row(';
   file_line_ := file_line_ || CHR(39) || ft_rec_.file_type             || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.description           || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.component             || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.system_defined        || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.system_bound          || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.view_name             || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.form_name             || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.target_default_method || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.api_to_call_input     || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.api_to_call_output    || CHR(39);
   file_line_ := file_line_ || ' );';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := '   DELETE FROM Ext_File_Type_Rec_Tab WHERE  file_type = '||CHR(39)||ft_rec_.file_type||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR rec_ IN get_file_rec LOOP
      file_line_ := '   External_File_Utility_API.File_Type_Rec_Row(';
      file_line_ := file_line_ || CHR(39) || rec_.file_type             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.record_type_id        || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.description           || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.record_set_id         || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.first_in_record_set   || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.last_in_record_set    || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.mandatory_record      || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.view_name || CHR(39)  || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.input_package         || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.parent_record_type    || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   END LOOP;
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := '   DELETE FROM Ext_File_Type_Rec_Column_Tab WHERE  file_type = '||CHR(39)||ft_rec_.file_type||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR rec_ IN get_file_col LOOP
      file_line_ := '   External_File_Utility_API.File_Type_Rec_Column_Row(';
      file_line_ := file_line_ || CHR(39) || rec_.file_type             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.record_type_id        || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.column_id             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.description           || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.data_type             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.mandatory             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.destination_column    || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   END LOOP;
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := '   DELETE FROM Ext_File_Type_Param_Tab WHERE  file_type = '||CHR(39)||ft_rec_.file_type||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR rec_ IN get_file_par LOOP
      file_line_ := '   External_File_Utility_API.File_Type_Param_Row(';
      file_line_ := file_line_ || CHR(39) || rec_.file_type             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.param_no              || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.param_id              || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.description           || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.lov_view              || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.enumerate_method      || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.validate_method       || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.browsable_field       || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.help_text             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.data_type             || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   END LOOP;
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := '   DELETE FROM Ext_Type_Param_Set_Tab WHERE  file_type = '||CHR(39)||ft_rec_.file_type||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR rec_ IN get_file_set LOOP
      file_line_ := '   External_File_Utility_API.File_Type_Param_Set_Row(';
      file_line_ := file_line_ || CHR(39) || rec_.file_type             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.set_id                || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.description           || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.set_id_default        || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   END LOOP;
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := '   DELETE FROM Ext_Type_Param_Per_Set_Tab WHERE  file_type = '||CHR(39)||ft_rec_.file_type||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR rec_ IN get_file_per_set LOOP
      file_line_ := '   External_File_Utility_API.File_Type_Param_Per_Set_Row(';
      file_line_ := file_line_ || CHR(39) || rec_.file_type             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.set_id                || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.param_no              || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.default_value         || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.mandatory_param       || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.show_at_load          || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || rec_.inputable_at_load     || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   END LOOP;
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'END;';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '/';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'COMMIT;';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   Ext_File_Trans_API.Update_State_Load ( load_file_id_, '1', '7' );
   Ext_File_Load_API.Update_State (load_file_id_, '3',NULL);
END File_Type_Export;


PROCEDURE File_Template_Export (
   load_file_id_      IN     NUMBER,
   file_type_         IN     VARCHAR2,
   file_template_id_  IN     VARCHAR2,
   row_no_            IN OUT NUMBER)
IS
   drow_no_                   NUMBER;
   ft_rec_                    ext_file_template_tab%ROWTYPE;
   ftr_rec_                   ext_file_template_dir_tab%ROWTYPE;
   --
   file_line_                 VARCHAR2(4000);
   CURSOR get_file_template IS
      SELECT *
      FROM   Ext_File_Template_Tab
      WHERE  file_template_id = file_template_id_;
   CURSOR get_file_template_dir IS
      SELECT *
      FROM   Ext_File_Template_Dir_Tab
      WHERE  file_template_id = file_template_id_;
   CURSOR get_file_template_det IS
      SELECT *
      FROM   Ext_File_Template_Detail_Tab
      WHERE  file_template_id = file_template_id_
      ORDER BY row_no;
   CURSOR get_file_template_func IS
      SELECT *
      FROM   Ext_File_Templ_Det_Func_Tab
      WHERE  file_template_id = file_template_id_
      AND    row_no           = drow_no_
      ORDER BY row_no, function_no;
   CURSOR get_file_template_ctrl IS
      SELECT *
      FROM   Ext_File_Template_Control_Tab
      WHERE  file_template_id = file_template_id_
      ORDER BY row_no;
BEGIN
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'PROMPT Insert Instructions for file template';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
    --
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'DECLARE ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   row_no_                NUMBER;';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'BEGIN ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   OPEN  get_file_template;
   FETCH get_file_template INTO ft_rec_;
   CLOSE get_file_template;
   file_line_ := '   DELETE FROM Ext_File_Template_Tab WHERE  file_template_id = '||CHR(39)||ft_rec_.file_template_id||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   External_File_Utility_API.File_Template_Row(';
   file_line_ := file_line_ || CHR(39) || ft_rec_.file_type           || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.file_template_id    || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.description         || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.separated           || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.file_format         || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.separator_id        || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.decimal_symbol      || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.denominator         || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.date_format         || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.system_defined      || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.active_definition   || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.valid_definition    || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.date_nls_calendar   || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ft_rec_.text_qualifier      || CHR(39);
   file_line_ := file_line_ || ' );';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   OPEN  get_file_template_dir;
   FETCH get_file_template_dir INTO ftr_rec_;
   CLOSE get_file_template_dir;
   file_line_ := '   DELETE FROM Ext_File_Template_Dir_Tab WHERE  file_template_id = '||CHR(39)||ft_rec_.file_template_id||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   External_File_Utility_API.File_Template_Dir_Row(';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.file_template_id           || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.file_direction             || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.log_skipped_lines          || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.log_invalid_lines          || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.skip_all_blanks            || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.skip_initial_blanks        || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.allow_record_set_repeat    || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.allow_one_record_set_only  || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.abort_immediatly           || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.load_file_type_list        || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.rowtype                    || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.api_to_call                || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.remove_days                || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.remove_complete            || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.overwrite_file             || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.create_header              || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.name_option                || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.file_name                  || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.character_set              || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.api_to_call_unp_before     || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.api_to_call_unp_after      || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.xml_layout_id              || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.number_out_fill_value      || CHR(39) || ', ';
   file_line_ := file_line_ || CHR(39) || ftr_rec_.remove_end_separator       || CHR(39);
   file_line_ := file_line_ || ' );';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   file_line_ := '   DELETE FROM Ext_File_Template_Detail_Tab WHERE  file_template_id = '||CHR(39)||ft_rec_.file_template_id||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   DELETE FROM Ext_File_Templ_Det_Func_Tab WHERE  file_template_id = '||CHR(39)||ft_rec_.file_template_id||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR recd_ IN get_file_template_det LOOP
      drow_no_ := recd_.row_no;
      file_line_ := '   External_File_Utility_API.File_Template_Det_Row(row_no_, ';
      file_line_ := file_line_ || CHR(39) || recd_.file_template_id || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.file_type        || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.record_type_id   || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.column_id        || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.column_no        || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.start_position   || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.end_position     || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.denominator      || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.date_format      || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.control_column   || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.hide_column      || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.column_sort      || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recd_.max_length       || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
      --
      FOR recf_ IN get_file_template_func LOOP
         file_line_ := '      External_File_Utility_API.File_Template_Func_Row(row_no_, ';
         file_line_ := file_line_ || CHR(39) || recf_.file_template_id  || CHR(39) || ', ';
         file_line_ := file_line_ || CHR(39) || recf_.function_no       || CHR(39) || ', ';
         file_line_ := file_line_ || CHR(39) || recf_.main_function     || CHR(39) || ', ';
         file_line_ := file_line_ || CHR(39) || REPLACE(recf_.function_argument,CHR(39),'"') || CHR(39);
         file_line_ := file_line_ || ' );';
         Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
      END LOOP;
   END LOOP;
   --
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '   DELETE FROM Ext_File_Template_Control_Tab WHERE  file_template_id = '||CHR(39)||ft_rec_.file_template_id||CHR(39)||';';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   FOR recx_ IN get_file_template_ctrl LOOP
      file_line_ := '   External_File_Utility_API.File_Template_Ctrl_Row(';
      file_line_ := file_line_ || CHR(39) || recx_.file_template_id   || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.file_type          || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.record_type_id     || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.row_no             || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.file_direction     || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.group_no           || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.condition          || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.column_no          || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.start_position     || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.end_position       || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.control_string     || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.destination_column || CHR(39) || ', ';
      file_line_ := file_line_ || CHR(39) || recx_.no_of_lines        || CHR(39);
      file_line_ := file_line_ || ' );';
      Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   END LOOP;
   --
   
   file_line_ := ' ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'END;';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '/';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := 'COMMIT;';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   Ext_File_Trans_API.Update_State_Load ( load_file_id_, '1', '7' );
   Ext_File_Load_API.Update_State (load_file_id_, '3',NULL);
END File_Template_Export;


PROCEDURE File_Type_Create_Export (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER )
IS
   ext_file_load_rec_         Ext_File_Load_API.Public_Rec;
   parameter_attr_            VARCHAR2(2000);
   file_type_                 VARCHAR2(30);
   file_template_id_          VARCHAR2(30);
   row_no_                    NUMBER          := 0;
   file_line_                 VARCHAR2(4000);
BEGIN
   ext_file_load_rec_ := Ext_File_Load_API.Get (load_file_id_);
   parameter_attr_    := ext_file_load_rec_.parameter_string;
   Message_SYS.Get_Attribute (parameter_attr_, 'FILE_TYPEX',        file_type_);
   Message_SYS.Get_Attribute (parameter_attr_, 'FILE_TEMPLATE_IDX', file_template_id_);
   --
   file_line_ := '-----------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--  Filename      : FileTypeTemplate'||file_type_||file_template_id_||'.ins';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--  Module        : ACCRUL';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--  Purpose       : Define basic data for File Type and / or File Template ';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '-----------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--  Date    Sign    History';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--  ----    ----    ----------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--  '||TO_CHAR(SYSDATE,'YYMMDD')||'  '||Fnd_Session_API.Get_Fnd_User||'  File created.';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--------------------------------------------------------------------------------------------------------------------------------------';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   file_line_ := '--';
   Insert_File_Trans___ ( load_file_id_, row_no_, file_line_ );
   --
   IF (file_type_ IS NOT NULL) THEN
      File_Type_Export (load_file_id_, file_type_, file_template_id_, row_no_);
   END IF;
   --
   IF (file_template_id_ IS NOT NULL) THEN
      File_Template_Export (load_file_id_, file_type_, file_template_id_, row_no_);
   END IF;
   --
END File_Type_Create_Export;


PROCEDURE Error_Text_Only (
   error_msg_ IN OUT VARCHAR2 )
IS
   start_position_ NUMBER;
   end_position_   NUMBER;
   text_           VARCHAR2(2000);
BEGIN
   text_           := error_msg_;
   start_position_ := INSTR(text_,':',1,2);
   end_position_   := LENGTH(text_);
   text_           := SUBSTR(text_, start_position_+ 1, end_position_);
   error_msg_      := text_;
END Error_Text_Only;


PROCEDURE File_Path_Info (
   file_path_begin_ OUT VARCHAR2,
   file_path_end_   OUT VARCHAR2,
   file_path_       IN  VARCHAR2 )
IS
BEGIN
   -- takes path upto the last dot
   file_path_begin_ := SUBSTR(file_path_,1,INSTR(file_path_,'.',-1)-1);
   -- takes the rest
   file_path_end_ := SUBSTR(file_path_,INSTR(file_path_,'.',-1),LENGTH(file_path_));
END File_Path_Info;

PROCEDURE Process_Xml_File(
   objid_         IN OUT   VARCHAR2,
   load_file_id_  IN       NUMBER)
IS
   create_xml_          VARCHAR2(5);
   file_template_id_    VARCHAR2(30);
   clob_out_            CLOB;
BEGIN
   file_template_id_:= Ext_File_Load_API.Get_File_Template_Id(load_file_id_);
   create_xml_ := Out_Ext_File_Template_Dir_API.Get_Create_Xml_File(file_template_id_, File_Direction_API.Decode('2'));
   IF (create_xml_ = 'TRUE') THEN
      Create_Xml_File(clob_out_, load_file_id_);
      Add_Xml_Data__(objid_, load_file_id_, clob_out_);
   ELSE
      objid_:= 'NULL';
   END IF;
END Process_Xml_File;

PROCEDURE Create_Xml_File(
   clob_out_         OUT   CLOB,   
   load_file_id_  IN       NUMBER)
IS
   error_exists_ VARCHAR2(5);
BEGIN
   Create_Xml_File(clob_out_, error_exists_, load_file_id_);
END Create_Xml_File;

PROCEDURE Create_Xml_File(
   clob_out_         OUT   CLOB,   
   error_exists_     OUT   VARCHAR2,
   load_file_id_  IN       NUMBER)
IS
   TYPE RecType IS RECORD (
      Record_Type_Id VARCHAR2(2000),
      Tag_Name       VARCHAR2(2000),
      IsOpened       BOOLEAN);

   TYPE RecType1 IS RECORD (
      Record_Type_Id VARCHAR2(2000),
      Description    VARCHAR2(2000));

   TYPE RecType2 IS RECORD (
      Record_Type_Id          VARCHAR2(2000),
      Parent_Record_Type_Id   VARCHAR2(2000));
     
   TYPE RecType3 IS RECORD (
      Record_Type_Id VARCHAR2(2000),
      row_no         NUMBER,
      row_state      VARCHAR2(200));

   TYPE tag_list IS TABLE OF RecType INDEX BY PLS_INTEGER;
   tag_list_               tag_list;

   TYPE tag_list1 IS TABLE OF RecType1 INDEX BY PLS_INTEGER;
   tag_list1_              tag_list1;

   TYPE tag_list3 IS TABLE OF RecType2 INDEX BY PLS_INTEGER;
   tag_list2_              tag_list3;
   
   TYPE tag_list4 IS TABLE OF RecType3 INDEX BY PLS_INTEGER;
   tag_list3_              tag_list4;
         
   TYPE ParentChild IS TABLE OF VARCHAR2(100)   INDEX BY VARCHAR2(100);        
   parent_child_           ParentChild;
	
   col_list_               col_list;
   tag_count_              NUMBER := 0;
   tag_close_count_        NUMBER := 0;
   count_                  NUMBER;
   row_no_                 NUMBER;
   rec_count_              NUMBER := 0;
   rec_limit_              NUMBER:= 2000;
   line_                   VARCHAR2(32000):= '';
   file_type_              VARCHAR2(32000);
   file_template_          VARCHAR2(32000);
   record_type_id_         VARCHAR2(32000);
   tag_                    VARCHAR2(32000);
   value_                  VARCHAR2(32000);
   column_names_           VARCHAR2(32000);
   new_line_               VARCHAR2(32000);
   main_tag_               VARCHAR2(32000);
   row_state_              VARCHAR2(32000);
   current_rec_id_         VARCHAR2(2000);
   previous_rec_id_        VARCHAR2(2000);  
   current_parent_         VARCHAR2(2000);  
   root_tag_               VARCHAR2(2000);
   now_                    VARCHAR2(2000);
   check_                  VARCHAR2(2000);   
   separator_              VARCHAR2(200) := 'DummySeparator';  
   line_values_            VARCHAR2(32000);
   special_character_      VARCHAR2(32000) := '&;' || CLIENT_SYS.field_separator_ || ';' || CLIENT_SYS.record_separator_ || ';<;>;';
   replace_with_           VARCHAR2(32000) := 'n;|;||;-;-;'  ;
   clob_value_             CLOB;  
   xsl_                    CLOB;
   xsl_b_                  BLOB;
   date_format_            VARCHAR2(50);
   temp_                   VARCHAR2(1);
   tag_list_index_         NUMBER;
   
   CURSOR get_template_name IS 
      SELECT REPLACE(REPLACE(description, ' ' , '_'), ',', '.'), NVL(date_format, 'YYYY-MM-DD')
      FROM   ext_file_template_tab 
      WHERE  file_type = file_type_
      AND    file_template_id = file_template_; 
   
   CURSOR get_style_sheet IS 
      SELECT xml_style_sheet
      FROM   ext_file_template_dir_tab 
      WHERE  file_template_id = file_template_
      AND    file_direction = '2'
      AND    rowtype LIKE '%OutExtFileTemplateDir';

   CURSOR load_info IS 
      SELECT file_type, file_template_id
      FROM   ext_file_load_tab
      WHERE  load_file_id = load_file_id_;

   CURSOR ext_trans IS
      SELECT record_type_id, row_no, row_state
      FROM   ext_file_trans_tab
      WHERE  load_file_id = load_file_id_
      AND    (NOT row_no = 0.5)
      ORDER BY row_no;
   
   CURSOR get_parent_tag IS
      SELECT record_type_id, REPLACE(REPLACE(description, ' ', '_'), ',', '.')
      FROM   ext_file_type_rec_tab
      WHERE  file_type = file_type_;
   
   CURSOR get_parent IS
      SELECT record_type_id, REPLACE(REPLACE(NVL(parent_record_type, 'MainTag'), ' ', '_'), ',', '.')
      FROM   ext_file_type_rec_tab
      WHERE  file_type = file_type_;
   
   CURSOR get_children(rec_id_ VARCHAR2) IS
      SELECT 1
      FROM   ext_file_type_rec_tab tr
      WHERE  file_type = file_type_
      AND    parent_record_type = rec_id_;              
BEGIN
   IF (load_file_id_ IS NOT NULL) THEN
      error_exists_ := 'FALSE';
      
      OPEN  load_info;
      FETCH load_info INTO file_type_, file_template_;
      CLOSE load_info;

      OPEN  get_template_name;
      FETCH get_template_name INTO root_tag_, date_format_;
      CLOSE get_template_name;
      
      OPEN  get_style_sheet;
      FETCH get_style_sheet INTO xsl_b_;
      CLOSE get_style_sheet;

      OPEN  get_parent_tag;
      FETCH get_parent_tag BULK COLLECT INTO tag_list1_;
      CLOSE get_parent_tag;

      OPEN  get_parent;
      FETCH get_parent BULK COLLECT INTO tag_list2_;
      CLOSE get_parent;

      FOR i_ IN 1..tag_list1_.COUNT LOOP       
         OPEN  get_children(tag_list1_(i_).record_type_id);
         FETCH get_children INTO temp_;

         IF get_children%FOUND THEN
           parent_child_(tag_list1_(i_).record_type_id)  := 'TRUE';
         ELSE
           parent_child_(tag_list1_(i_).record_type_id)  := 'FALSE';
         END IF;
         CLOSE get_children;
      END LOOP;          

      col_list_ := Select_Stmt_Builder___(file_type_ , file_template_ , separator_ , date_format_ );
      
      dbms_lob.createtemporary(clob_value_,true);
      dbms_lob.writeappend(clob_value_,length('<' || UPPER(root_tag_) || '>' || chr(10)), '<' || UPPER(root_tag_) || '>' || chr(10));     
      
      OPEN ext_trans;
      LOOP
         FETCH ext_trans BULK COLLECT INTO tag_list3_ LIMIT rec_limit_;
         IF tag_list3_.COUNT = 0 THEN
            EXIT;
         END IF;
         FOR q_ IN 1..tag_list3_.COUNT LOOP
            record_type_id_ := tag_list3_(q_).record_type_id;
            row_no_ := tag_list3_(q_).row_no;
            row_state_ := tag_list3_(q_).row_state;
            new_line_ := '';
            column_names_ := '';
            
            line_values_ := Get_Line_Values___(load_file_id_, row_no_, col_list_(record_type_id_).stmt);
            line_  := Remove_Special_Characters___(line_values_, special_character_, replace_with_);                        
            count_ := REGEXP_COUNT (line_, separator_);
            column_names_ := col_list_(record_type_id_).line_columns;
            
            FOR position_ IN 1..count_ LOOP          
               tag_   := Get_String___(column_names_, position_, separator_);
               value_ := Get_String___(line_, position_, separator_);
               IF (value_ IS NOT NULL) THEN
                  new_line_ := new_line_ || '<' || UPPER(tag_) || '>' || value_ || '</' || UPPER(tag_) || '>' || chr(10);  
               END IF;
            END LOOP;

            FOR i_ IN 1..tag_list1_.COUNT LOOP         
               IF (tag_list1_(i_).Record_Type_Id = record_type_id_) THEN
                  main_tag_ := tag_list1_(i_).Description;
                  EXIT;
               END IF;
            END LOOP;         

            new_line_ := '<' || UPPER(main_tag_ )|| '>' || new_line_; 
            rec_count_ := rec_count_ + 1;

            current_rec_id_ := record_type_id_;
            line_ := new_line_;

            FOR i_ IN 1..tag_list2_.COUNT LOOP         
               IF (tag_list2_(i_).Record_Type_Id = current_rec_id_) THEN
                  current_parent_ := tag_list2_(i_).Parent_Record_Type_Id;
                  EXIT;
               END IF;
            END LOOP;
            
            IF (NOT previous_rec_id_ = current_rec_id_) THEN
               IF (NOT previous_rec_id_ = current_parent_) THEN
                  tag_close_count_ := tag_count_ - 1;
                  now_ := current_rec_id_;
                  IF tag_close_count_ >= 0 THEN
                     tag_list_index_ := tag_list_.LAST;
                     WHILE tag_list_index_ IS NOT NULL OR tag_list_index_ < 1 LOOP
                        check_ := tag_list_(tag_list_index_).Record_Type_Id;
                        IF (check_ <> current_parent_) THEN
                           dbms_lob.writeappend(clob_value_,length('</' || UPPER(tag_list_(tag_list_index_).Tag_Name) || '>' || chr(10)),
                                                                   '</' || UPPER(tag_list_(tag_list_index_).Tag_Name) || '>' || chr(10));
                           tag_list_.delete(tag_list_index_);                           
                        ELSE
                           EXIT;
                        END IF;
                        tag_list_index_ := tag_list_.PRIOR(tag_list_index_);
                     END LOOP;
                  END IF;
               END IF;
            ELSE
               tag_close_count_ := tag_count_ - 1;
               IF (parent_child_(current_rec_id_) = 'TRUE') AND tag_close_count_ >= 0  THEN
                  dbms_lob.writeappend(clob_value_,length('</' || UPPER(main_tag_ )|| '>'|| chr(10)),'</' || UPPER(main_tag_ )|| '>'|| chr(10));
                  tag_list_index_ := tag_list_.LAST;
                  tag_list_.delete(tag_list_index_);
               END IF;  
            END IF;
            IF (parent_child_(current_rec_id_) = 'TRUE') THEN
               dbms_lob.writeappend(clob_value_,length(line_|| chr(10)), line_|| chr(10));
               tag_list_(tag_count_).Record_Type_Id := current_rec_id_;
               tag_list_(tag_count_).Tag_Name := SUBSTR(line_,  2, INSTR(line_, '>') - 2);
               tag_list_(tag_count_).IsOpened := TRUE;
               tag_count_ := tag_count_ + 1;
            ELSE
            dbms_lob.writeappend(clob_value_,length(line_ || '</' || SUBSTR(line_,  2, INSTR(line_, '>') - 2) || '>' ||chr(10)),
                                                       line_ || '</' || SUBSTR(line_,  2, INSTR(line_, '>') - 2) || '>' ||chr(10));
            END IF;   
            previous_rec_id_ := current_rec_id_;
         END LOOP;
      END LOOP;
      CLOSE ext_trans;
      tag_close_count_ := tag_count_ - 1;
      now_ := current_rec_id_;
      IF tag_close_count_ > 0 THEN
         tag_list_index_ := tag_list_.LAST;
         WHILE tag_list_index_ IS NOT NULL OR tag_list_index_ < 1 LOOP
            dbms_lob.writeappend(clob_value_,length('</' || UPPER(tag_list_(tag_list_index_).Tag_Name) || '>' || chr(10)),
                                                    '</' || UPPER(tag_list_(tag_list_index_).Tag_Name) || '>' || chr(10));
            tag_list_.delete(tag_list_index_);
            tag_list_index_ := tag_list_.PRIOR(tag_list_index_);
         END LOOP;
      END IF;
      dbms_lob.writeappend(clob_value_,length('</' || UPPER(root_tag_) || '>'), '</' || UPPER(root_tag_) || '>');
      IF (xsl_b_ IS NOT NULL) THEN
         xsl_ := Blob_To_Clob__(xsl_b_);
         SELECT XMLTRANSFORM(XMLTYPE.CREATEXML(clob_value_), XMLTYPE.CREATEXML(xsl_)).getclobval()
         INTO   clob_value_
         FROM   DUAL;
      END IF;

      clob_out_ := clob_value_;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      clob_out_ :=  '<error>' || sqlerrm || '</error>' || chr(10) || chr(10) || clob_value_;
      error_exists_ := 'TRUE';
END Create_Xml_File;

PROCEDURE Write_Xml_File(
   xml_              IN    CLOB,
   file_name_        IN    VARCHAR2,
   file_template_id_ IN    VARCHAR2 DEFAULT NULL)
IS
   TYPE RecType IS RECORD (
      File_Row NUMBER,
      File_Line VARCHAR2(32000));
      
   TYPE tag_list IS TABLE OF RecType INDEX BY PLS_INTEGER;
    tag_list_               tag_list;
    empty_tag_list_               tag_list;
    
   offset_                    NUMBER  := 1;     
   file_row_                  NUMBER  := 0;
   count_                     NUMBER  := 0;
   file_line_                 VARCHAR2(32000);
   length_                    NUMBER;
   current_length_            NUMBER  := 0;
   pos1_                      NUMBER;       
   file_handle_               Utl_File.File_Type;
   server_path_separator_     VARCHAR2(1);     
   last_slash_                NUMBER;        
   dir_                       VARCHAR2(100);
   file_                      VARCHAR2(100); 
   open_type_                 VARCHAR2(1) := 'W';
   file_template_char_set_    VARCHAR2(100) := Out_Ext_File_Template_Dir_API.Get_Character_Set_Db(file_template_id_, '2');
BEGIN
   server_path_separator_ := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');
   last_slash_ := INSTR(file_name_ ,server_path_separator_ ,-1);

   IF (last_slash_ = 0) THEN
      dir_    := NULL;
      file_   := file_name_;   
   ELSE
      dir_    := SUBSTR(file_name_,1,last_slash_);
      IF (SUBSTR(dir_,LENGTH(dir_),1) = server_path_separator_ ) THEN
         dir_ := SUBSTR(dir_,1,LENGTH(dir_)-1);
      END IF;
      file_   := SUBSTR(file_name_,last_slash_+1);   
   END IF;
   Ext_File_Server_Util_API.Open_External_File2 ( file_handle_,dir_,file_,open_type_ );
   IF file_template_char_set_ IS NOT NULL THEN
      Database_SYS.Set_File_Encoding(file_template_char_set_);
   END IF;
   
   length_ := dbms_lob.getlength(xml_);
   
   LOOP
      pos1_ := dbms_lob.instr(lob_loc => xml_, pattern => chr(10), offset => offset_, nth => 100);
      
      IF (pos1_ = 0) THEN
        pos1_:= length_ + 1;
      END IF;
      
      file_line_:= dbms_lob.substr( xml_, pos1_ - offset_, offset_ );
      
      IF current_length_ > length_ OR file_line_ IS NULL THEN
         FOR i_ IN tag_list_.FIRST..tag_list_.LAST LOOP         
            Ext_File_Server_Util_API.Put_Line_External_File (tag_list_(i_).File_Line, file_handle_);
         END LOOP;                
         tag_list_ := empty_tag_list_;
         EXIT;
      END IF;
      
      offset_ :=  pos1_ + 1;     
      file_row_ := file_row_ + 1;
      
      tag_list_(count_).File_Row := file_row_;
      tag_list_(count_).File_Line := file_line_;
      count_ := count_ + 1;

      current_length_ := current_length_ + length(file_line_);

      IF (MOD(file_row_, 2000) = 0) THEN
         FOR i_ IN tag_list_.FIRST..tag_list_.LAST LOOP         
            Ext_File_Server_Util_API.Put_Line_External_File (tag_list_(i_).File_Line, file_handle_);
         END LOOP;                
         tag_list_ := empty_tag_list_;
         count_ := 0;
      END IF;
   END LOOP;

   Ext_File_Server_Util_API.Close_External_File ( file_handle_ );
   Database_SYS.Set_Default_File_Encoding;
END Write_Xml_File;

PROCEDURE Write_File_Data (
   rec_ IN OUT ext_file_load_tab%ROWTYPE,
   blob_loc_    IN     BLOB )
IS   
BEGIN
   NULL;
END Write_File_Data;

-- This Function accept a LineTabType array and pack it to a CLOB
FUNCTION Pack_To_Clob(
   line_recs_ External_File_Utility_API.LineTabType) RETURN CLOB
IS
   tclob_ CLOB;
BEGIN
   FOR count_ IN 1..line_recs_.COUNT() LOOP
      tclob_ := tclob_ || TO_CLOB(line_recs_(count_)) || CHR(13)||CHR(10);
   END LOOP; 
   RETURN tclob_;   
END Pack_To_Clob;

-- This Function accept a LineTabType array and pack it to a BLOB
FUNCTION Pack_To_Blob(
   line_recs_  IN External_File_Utility_API.LineTabType) RETURN BLOB
IS
   dest_offset_   NUMBER := 1;
   src_offset_    NUMBER := 1;
   lang_context_  NUMBER := 0;
   warning_       NUMBER := 0;
   tclob_         CLOB;
   tblob_         BLOB;
BEGIN
   DBMS_LOB.CreateTemporary (tblob_, TRUE);
   tclob_ := Pack_To_Clob(line_recs_);
   DBMS_LOB.CreateTemporary (tblob_, TRUE);
   DBMS_LOB.ConvertToBlob(tblob_, tclob_, DBMS_LOB.Getlength(tclob_), dest_offset_, src_offset_, 0, lang_context_, warning_);
   RETURN tblob_;   
END Pack_To_Blob;

FUNCTION Get_File_Data(
   load_file_id_ IN NUMBER) RETURN CLOB
IS
   line_recs_   External_File_Utility_API.LineTabType; 
   i_           NUMBER :=1;
   CURSOR get_lines IS
      SELECT file_line
      FROM   ext_file_trans_tab
      WHERE  load_file_id = load_file_id_      
      ORDER BY row_no;   
BEGIN   
   FOR rec_ IN get_lines LOOP
      line_recs_(i_) := rec_.file_line;
      i_ := i_+1;
   END LOOP;
   RETURN External_File_Utility_API.Pack_To_Clob(line_recs_);   
END Get_File_Data;

FUNCTION Clob_To_Blob(
   clob_data_  IN CLOB) RETURN BLOB
IS
   blob_data_     BLOB;
   amount_        INTEGER := Dbms_Lob.lobmaxsize;
   dest_offset_   INTEGER := 1;
   src_offset_    INTEGER := 1;
   csid_          NUMBER  := Dbms_Lob.default_csid;
   lang_context_  INTEGER := Dbms_Lob.default_lang_ctx;
   warning_       INTEGER;
BEGIN
   dbms_lob.createtemporary(blob_data_, TRUE);
   dbms_lob.Converttoblob(blob_data_, clob_data_, amount_, dest_offset_, src_offset_, csid_, lang_context_, warning_);
   RETURN blob_data_;
END Clob_To_Blob;

FUNCTION Pack_Ext_Trans_To_Blob(
   load_file_id_ NUMBER) RETURN BLOB
IS
   line_recs_ LineTabType;
   i_         NUMBER := 1;
   temp_blob_ BLOB;
   CURSOR get_file_trans IS
      SELECT file_line
      FROM   ext_file_trans_tab
      WHERE  load_file_id = load_file_id_
      AND    row_state IN ('2','7')
      ORDER BY row_no;
BEGIN
   FOR rec_ IN get_file_trans LOOP
      line_recs_(i_) := rec_.file_line;
      i_ := i_+1;
   END LOOP;
   IF line_recs_.Count = 0 THEN
      Error_SYS.Appl_General(lu_name_, 'NORECS: No Records to Export');
   END IF;
   temp_blob_:= Pack_To_Blob(line_recs_);
   RETURN temp_blob_;
END Pack_Ext_Trans_To_Blob;

FUNCTION Get_Xml_Data(
   load_file_id_ NUMBER) RETURN CLOB
IS
   temp_clob_ CLOB;
   CURSOR get_xml_data IS
      SELECT clob_file
      FROM   ext_file_xml
      WHERE  load_file_id = load_file_id_;   
BEGIN
   OPEN get_xml_data;
   FETCH get_xml_data INTO temp_clob_;
   CLOSE get_xml_data;
   IF Dbms_Lob.Getlength(temp_clob_) IS NULL THEN
      Error_SYS.Appl_General(lu_name_, 'NOXML: No XML data');
   END IF;
   RETURN temp_clob_;   
END Get_Xml_Data;

FUNCTION Get_String(
   string_    IN VARCHAR2,
   position_  IN NUMBER,
   separator_ IN VARCHAR2) RETURN VARCHAR2 
IS
   start_pos_        NUMBER;
   end_pos_          NUMBER;
   seperator_length_ NUMBER := LENGTH(separator_);
   start_length_     NUMBER := 0;
   end_length_       NUMBER := 0;
BEGIN
   IF position_ = 1 THEN
      start_pos_ := 0;
      end_length_ := 1;
   ELSE
      start_pos_ := INSTR(string_, separator_, 1, position_ - 1);
      start_length_ := seperator_length_;
      end_length_ := seperator_length_;
   END IF;

   end_pos_ := INSTR(string_, separator_, 1, position_);
   RETURN SUBSTR(string_, start_pos_ + start_length_, end_pos_ - start_pos_  - end_length_);
END Get_String;

PROCEDURE Create_Load_Id_Param_ (
   load_file_id_         IN OUT NUMBER,
   parameter_string_     IN     VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Ext_File_Load_API.Create_Load_Id_Param(load_file_id_, parameter_string_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Create_Load_Id_Param_;

PROCEDURE Load_Client_File_ (
   action_           IN     VARCHAR2,
   load_file_id_     IN OUT NUMBER,
   file_template_id_ IN     VARCHAR2,
   file_type_        IN     VARCHAR2,
   message_          IN     BLOB,
   company_          IN     VARCHAR2,
   file_name_        IN     VARCHAR2 )
IS 
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Load_Aurena_Client_File_ ( action_,
                              load_file_id_,
                              file_template_id_,
                              file_type_,
                              message_,
                              company_,
                              file_name_ );
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Load_Client_File_;

PROCEDURE Unpack_Ext_Line_ ( 
   file_type_            IN     VARCHAR2,
   file_template_id_     IN     VARCHAR2,
   load_file_id_         IN     NUMBER,
   company_              IN     VARCHAR2 DEFAULT NULL )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Unpack_Ext_Line(file_type_, file_template_id_, load_file_id_, company_); 
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Unpack_Ext_Line_;

PROCEDURE Start_Input_Online_ (
   info_         IN OUT VARCHAR2,
   load_file_id_ IN     NUMBER )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Start_Input_Online(info_, load_file_id_);
   @ApproveTransactionStatement(2019-06-06,pkurlk)
   COMMIT;
END Start_Input_Online_;

PROCEDURE Store_File_Identities_ (
   load_file_id_ IN NUMBER )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Store_File_Identities(load_file_id_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Store_File_Identities_;

PROCEDURE Start_Api_To_Call_ (
   info_         IN OUT VARCHAR2,
   load_file_id_ IN     NUMBER )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Start_Api_To_Call (info_, load_file_id_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Start_Api_To_Call_;

PROCEDURE Pack_Out_Ext_Line_ (
   file_type_              IN VARCHAR2,
   file_template_id_       IN VARCHAR2,
   load_file_id_           IN NUMBER,
   company_                IN VARCHAR2 DEFAULT NULL )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Pack_Out_Ext_Line(file_type_, file_template_id_, load_file_id_, company_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Pack_Out_Ext_Line_;

PROCEDURE Modify_File_Name_ (
   load_file_id_ IN     NUMBER,
   file_name_    IN OUT VARCHAR2 )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Modify_File_Name(load_file_id_, file_name_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Modify_File_Name_;

PROCEDURE Update_State_ (
   load_file_id_         IN OUT NUMBER,
   parameter_string_     IN     VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Ext_File_Load_API.Update_State(load_file_id_, parameter_string_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Update_State_;

PROCEDURE Create_Xml_File_ (
   load_file_id_     IN NUMBER,
   file_is_xml_type_ OUT VARCHAR2)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Create_Xml_File(load_file_id_, file_is_xml_type_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Create_Xml_File_;

PROCEDURE Process_Xml_File_ (
   objid_         IN OUT   VARCHAR2,
   load_file_id_  IN       NUMBER)
IS   
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Process_Xml_File(objid_, load_file_id_);
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Process_Xml_File_;

PROCEDURE Clear_Temp_Data
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   Clear_Temp_Data_;
   @ApproveTransactionStatement(2019-04-10,pkurlk)
   COMMIT;
END Clear_Temp_Data;

PROCEDURE Get_Default_File_Type_Info(
   file_type_         IN OUT VARCHAR2,
   set_id_            IN OUT VARCHAR2,
   file_template_     IN OUT VARCHAR2,
   company_           IN OUT VARCHAR2,
   file_direction_db_ IN OUT VARCHAR2,
   file_direction_    IN OUT VARCHAR2,
   file_name_         IN OUT VARCHAR2,
   param_str_         IN OUT VARCHAR2,
   process_option_    IN  VARCHAR2)
IS 
   client_server_       VARCHAR2(1000);
   column_name_         VARCHAR2(32000);
   column_value_        VARCHAR2(32000);
   
   view_name_           VARCHAR2(200);
   package_name_        VARCHAR2(200);
   ext_file_rec_        Ext_File_Type_API.Public_Rec;
BEGIN
   view_name_     := Ext_File_Type_API.Get_View_Name(file_type_);
   package_name_  := Ext_File_Type_API.Get_Api_To_Call_Output(file_type_);
   ext_file_rec_ := Ext_File_Type_API.Get(file_type_);
   IF ((ext_file_rec_.system_defined = 'FALSE') OR (ext_file_rec_.input_projection_action IS NULL AND ext_file_rec_.output_projection_action IS NULL)) THEN
      Error_SYS.Appl_General(lu_name_, 'FILETYPENOTAVAILABLE: File type :P1 is not available for the user.', file_type_);
   ELSIF ((view_name_ IS NOT NULL) AND (NOT Security_SYS.Is_Proj_Action_Available('ExternalFileAssistantHandling', ext_file_rec_.input_projection_action))) THEN
      Error_SYS.Appl_General(lu_name_, 'NOPROJACTAVAILABLE: Projection action :P1 is not available for the user.', ext_file_rec_.input_projection_action);      
   ELSIF ((package_name_ IS NOT NULL) AND (NOT Security_SYS.Is_Proj_Action_Available('ExternalFileAssistantHandling', ext_file_rec_.output_projection_action))) THEN
      Error_SYS.Appl_General(lu_name_, 'NOPROJACTAVAILABLE: Projection action :P1 is not available for the user.', ext_file_rec_.output_projection_action);      
   END IF;
   
   IF process_option_ = 'Online' THEN
      client_server_ := 'C';
   ELSE
      client_server_ := 'S';
   END IF;
   
   Ext_File_Message_API.Return_For_Trans_Form ( file_type_,
                                                set_id_,
                                                param_str_,
                                                file_template_,
                                                file_direction_db_,
                                                file_direction_,
                                                file_name_,
                                                company_,
                                                client_server_,
                                                column_name_,
                                                column_value_);
                                                          
   IF file_name_ IS NULL AND client_server_ = 'S'THEN
      file_name_ := Accrul_Attribute_API.Get_Attribute_Value('SERVER_DIRECTORY');
   END IF;                     
   
END Get_Default_File_Type_Info;

PROCEDURE Check_View_Col_Diff ( 
   view_diff_exist_  OUT VARCHAR2,
   base_view_        OUT VARCHAR2,
   view_name_        IN VARCHAR2 ) 
IS
   logical_unit_     VARCHAR2(30);
   
   CURSOR get_colname IS
   SELECT column_name
   FROM   Dictionary_Sys_View_Column_Act
   WHERE  view_name = base_view_
   AND    type_flag IN ('P', 'K');  
BEGIN
   logical_unit_ := Dictionary_SYS.Get_Logical_Unit(view_name_,'VIEW');
   base_view_    := Dictionary_SYS.Get_Base_View(logical_unit_);

   IF view_name_ != base_view_ THEN      
      FOR rec_ IN get_colname LOOP
         IF (Check_View_Col_Exist(view_name_, rec_.column_name) = 'FALSE') THEN
            view_diff_exist_ := 'TRUE';
            RETURN;
         END IF;
      END LOOP;
   END IF;
   view_diff_exist_ := 'FALSE';
END Check_View_Col_Diff;
