-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileMessage
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021018  JeGu    Created
--  040329  Gepelk  2004 SP1 Merge.
--  060317  Miablk  B137519, Increased length of from_valuex_ variable in Param_To_Where() method. 
--  070426  Chsalk  LCS Bug 64667 Merged.
--  070614  Shsalk  LCS Bug 65135, Fixed character set conversion problem.
--  071207  Maaylk  Bug 67699, Added method Comment_To_Reference()
--  071226  AjPelk  Bug 69856, Modified an error msg SETEXIST
--  090121  Jeguse  Bug 79498, Increased length of variables
--  091026  RUFELK  Bug 86605, Corrected in Create_Parameter_Msg().
--  111004  AJPELK  EASTTWO-15655, Bug 98827 merged.
--  120215  LASELK   SFI-1579, Bug 100665 merged
--  140225  Umdolk  PBFI-5526, Modified Param_To_Where.
--  140324  Umdolk  PBFI-6208, Modified Comment_To_Reference.
--  160713  Kagalk  STRFI-3075, Merged Bug 130352, Modified Comment_To_Reference to get lu name when using CUSTOM references.
--  181231  AjPelk  Bug 146039, Corrected, When load_type changes the relevant parameter values wont fetch if it calls RAISE NotChanged. 
--                  Therefore this should not call at this time.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

message_name_         CONSTANT VARCHAR2(30)  := 'PARAMETER_MESSAGE';

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Check_And_Replace_Attribute_ (
   my_msg_  IN OUT VARCHAR2,
   name_    IN     VARCHAR2,
   value_   IN     VARCHAR2,
   replace_ IN     VARCHAR2 DEFAULT 'TRUE' )
IS
   tmp_           VARCHAR2(2000) := NULL;
   dummy_         VARCHAR2(10)   := '<DUMMY>';
BEGIN
   tmp_ := Message_SYS.Find_Attribute (my_msg_, name_, dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      IF (replace_ = 'TRUE') THEN
         Message_SYS.Set_Attribute (my_msg_, name_, value_);
      END IF;
   ELSE
      Message_Sys.Add_Attribute (my_msg_, name_, value_);
   END IF;
END Check_And_Replace_Attribute_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Create_Param_Set_Msg (
   msg_       IN OUT VARCHAR2,
   file_type_ IN     VARCHAR2,
   set_id_    IN     VARCHAR2 )
IS
   tmp_              VARCHAR2(2000) := NULL;
   dummy_            VARCHAR2(10)   := '<DUMMY>';
   set_idx_          VARCHAR2(20);
   value_            VARCHAR2(2000);
   company_          VARCHAR2(20);
   base_currency_    VARCHAR2(3);
   CURSOR params IS
      SELECT param_id, 
             default_value
      FROM   ext_type_param_per_set_tab a,
             ext_file_type_param_tab    b
      WHERE  a.set_id            = set_idx_
      AND    a.param_no          = b.param_no
      AND    a.file_type         = b.file_type
      AND    a.file_type         = file_type_;
BEGIN
   Trace_SYS.Message ('Create_Param_Set_Msg set_id_ : '||set_id_); 
   IF (set_id_ IS NULL) THEN
      set_idx_ := Ext_File_Company_Default_API.Get_Set_Id_All ( file_type_,
                                                            NULL,
                                                            Fnd_Session_API.Get_Fnd_User );
      IF (set_idx_ IS NULL) THEN
         set_idx_ := Ext_Type_Param_Set_API.Get_Default_Set_Id ( file_type_ );
      END IF;
   ELSE
      set_idx_ := set_id_;
   END IF;
   Trace_SYS.Message ('Create_Param_Set_Msg set_idx_ : '||set_idx_); 
   IF (NVL(msg_,' ') NOT LIKE '%'||message_name_||'%') THEN
      msg_ := Message_Sys.Construct(message_name_);
   END IF;
   Check_And_Replace_Attribute_ (msg_,
                                 'FILE_TYPE',
                                 file_type_,
                                 'FALSE');
   Check_And_Replace_Attribute_ (msg_,
                                 'SET_ID',
                                 set_idx_,
                                 'FALSE');
   
   FOR param_ IN params LOOP      
      value_ := param_.default_value;
      IF (value_ = '<SYSDATE>') THEN
         value_ := TO_CHAR(TRUNC(SYSDATE),Client_SYS.date_format_);
      END IF;
      IF (value_ = '<COMPANY>') THEN         
         tmp_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);
         IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
            value_ := tmp_;
         ELSE
            User_Finance_API.Get_Default_Company ( company_ );
         END IF;
      END IF;
      IF (value_ = '<USER_ID>') THEN
         value_ := Fnd_Session_API.Get_Fnd_User;
      END IF;
      IF  (value_ = '<USER_GROUP>')  THEN
         value_ := User_Group_Member_Finance_API.Get_Default_Group(Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_),
                                                                  Fnd_Session_API.Get_Fnd_User);
      END IF;
      IF (value_ = '<BASE_CURRENCY>') THEN
         tmp_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);
         IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
            company_ := tmp_;
         ELSE
            User_Finance_API.Get_Default_Company ( company_ );
         END IF;
         value_ := Company_Finance_API.Get_Currency_Code ( company_ );
      END IF;
      IF (value_ = '<CURR_TYPE>') THEN
         tmp_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);
         IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
            company_ := tmp_;
         ELSE
            company_ := NULL;
         END IF;
         value_ := Currency_Type_API.Get_Default_Type ( company_ );
      END IF;
      IF (value_ = '<CURR_INVERT>') THEN
         tmp_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);
         IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
            company_ := tmp_;
         ELSE
            company_ := NULL;
         END IF;
         tmp_ := Message_SYS.Find_Attribute (msg_, 'BASE_CURRENCY', dummy_);
         IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
            base_currency_ := tmp_;
         ELSE
            base_currency_ := Company_Finance_API.Get_Currency_Code ( company_ );
         END IF;
         value_ := Currency_Code_API.Get_Inverted ( company_, base_currency_ );
      END IF;
      Check_And_Replace_Attribute_ (msg_,
                                    param_.param_id,
                                    value_,
                                    'TRUE');
   END LOOP;
   Check_And_Replace_Attribute_ (msg_,
                                 'PARAM_SET',
                                 'TRUE',
                                 'FALSE');
END Create_Param_Set_Msg;


PROCEDURE Create_Parameter_Msg (
   msg_               IN OUT VARCHAR2,
   file_type_         IN     VARCHAR2 DEFAULT NULL,
   set_id_            IN     VARCHAR2 DEFAULT NULL,
   client_server_     IN     VARCHAR2 DEFAULT 'C',
   column_name_       IN     VARCHAR2 DEFAULT NULL )
IS
   tmp_                   VARCHAR2(2000) := NULL;
   dummy_                 VARCHAR2(10)   := '<DUMMY>';
   file_typex_            VARCHAR2(30);
   company_               VARCHAR2(20);
   set_idx_               VARCHAR2(30);
   file_template_idx_     VARCHAR2(30);
   file_direction_dbx_    VARCHAR2(1);
   file_name_             VARCHAR2(2000);
   target_default_method_ VARCHAR2(100);
   instr_target_          NUMBER;
   package_               VARCHAR2(30);
   method_                VARCHAR2(30);
   stmt_                  VARCHAR2(32000);
   valid_template_        VARCHAR2(5);
BEGIN
   IF (NVL(msg_,' ') NOT LIKE '%'||message_name_||'%') THEN
      msg_ := Message_Sys.Construct(message_name_);
   END IF;
   Check_And_Replace_Attribute_ (msg_,
                                 'FILE_TYPE',
                                 file_type_,
                                 'FALSE');
   Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, 'CLIENT_SERVER', client_server_);
   --
   -- File Type
   IF (file_type_ IS NULL) THEN
      file_typex_ := Message_SYS.Find_Attribute (msg_, 'FILE_TYPE', dummy_);
   ELSE
      file_typex_ := file_type_;
   END IF;
   Trace_SYS.Message ('Create_Parameter_Msg set_id_ : '||set_id_); 
   IF (set_id_ IS NULL) THEN
      set_idx_    := Message_SYS.Find_Attribute (msg_, 'SET_ID', dummy_);
      Trace_SYS.Message ('Create_Parameter_Msg 1 set_idx_ : '||set_idx_); 
      IF (NVL(set_idx_,dummy_) = dummy_) THEN
         company_ := Message_SYS.Find_Attribute( msg_, 'COMPANY', dummy_);
         IF ( NVL(company_, ' ') = '<DUMMY>' ) THEN
            User_Finance_API.Get_Default_Company ( company_ );
         END IF;

         set_idx_ := Ext_File_Company_Default_API.Get_Set_Id_All( file_typex_,
                                                               company_,
                                                               Fnd_Session_API.Get_Fnd_User );
         Trace_SYS.Message ('Create_Parameter_Msg 2 set_idx_ : '||set_idx_); 
         IF (set_idx_ IS NULL) THEN
            set_idx_ := Ext_Type_Param_Set_API.Get_Default_Set_Id ( file_typex_ );
         END IF;
         Trace_SYS.Message ('Create_Parameter_Msg 3 set_idx_ : '||set_idx_); 
         Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, 'SET_ID', set_idx_);
      END IF;
   ELSE
      set_idx_ := set_id_;
   END IF;
   Trace_SYS.Message ('Create_Parameter_Msg 4 set_idx_ : '||set_idx_); 
   --
   -- File Template Id
   tmp_ := Message_SYS.Find_Attribute (msg_, 'FILE_TEMPLATE_ID', dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      file_template_idx_ := tmp_;
   ELSE
      company_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);                                          
      
      IF ( NVL(company_,' ') = '<DUMMY>' ) THEN
         User_Finance_API.Get_Default_Company ( company_ );
      END IF;
      
      file_template_idx_ := Ext_File_Company_Default_API.Get_File_Template_Id_All( file_typex_,
                                                                                company_,
                                                                                Fnd_Session_API.Get_Fnd_User );
      IF (file_template_idx_ IS NOT NULL) THEN
         valid_template_ := Ext_File_Template_API.Get_Valid_Definition ( file_template_idx_ );
         IF (valid_template_ = 'FALSE') THEN
            file_template_idx_ := NULL;
         END IF;
      END IF;
      IF (file_template_idx_ IS NULL) THEN
         file_template_idx_ := Ext_File_Template_API.Get_Default_File_Template_Id ( file_typex_ );
      END IF;
      IF (file_template_idx_ IS NULL) THEN
         Error_SYS.Appl_General( lu_name_, 'NOTEMPL: There is no valid template defined for file type :P1',file_typex_ );
      END IF;
   END IF;
   Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, 'FILE_TEMPLATE_ID', file_template_idx_);
   --
   -- File Direction
   IF (NVL(column_name_,' ') IN ('NULL','FILE_TEMPLATE_ID')) THEN
      tmp_ := '<DUMMY>';
   ELSE
      tmp_ := Message_SYS.Find_Attribute (msg_, 'FILE_DIRECTION_DB', dummy_);
   END IF;
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      file_direction_dbx_ := tmp_;
   ELSE
      file_direction_dbx_ := Ext_File_Template_Dir_API.Get_File_Direction_Db ( file_template_idx_ );
   END IF;
   Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, 'FILE_DIRECTION_DB', file_direction_dbx_);
   --
   -- Parameters from Parameter Set
   tmp_ := Message_SYS.Find_Attribute (msg_, 'PARAM_SET', dummy_);
   IF ( NVL(tmp_,' ') = '<DUMMY>' ) THEN
      Create_Param_Set_Msg (msg_, 
                            file_typex_,
                            set_idx_);
      tmp_ := Message_SYS.Find_Attribute (msg_, 'FILE_DIRECTION_DB', dummy_);
      IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
         file_direction_dbx_ := tmp_;
      END IF;
   END IF;
   --
   -- File Name
   IF (column_name_ IN ('FILE_TEMPLATE_ID','FILE_DIRECTION_DB')) THEN
      tmp_ := '<DUMMY>';
   ELSE
      tmp_ := Message_SYS.Find_Attribute (msg_, 'FILE_NAME', dummy_);
   END IF;
   
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      file_name_ := tmp_;
   ELSE
      file_name_ := Ext_File_Template_Dir_API.Get_File_Path_Name ( file_template_idx_,
                                                                   file_direction_dbx_,
                                                                   client_server_ );
   END IF;
   Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, 'FILE_NAME', file_name_);
   
   tmp_ := Message_SYS.Find_Attribute (msg_, 'LU_SET', dummy_);
   IF ( NVL(tmp_,' ') = '<DUMMY>' ) THEN
      target_default_method_ := Ext_File_Type_API.Get_Target_Default_Method (file_typex_);
      IF (target_default_method_ IS NOT NULL) THEN
         instr_target_       := INSTR(target_default_method_,'.');
         package_            := SUBSTR(target_default_method_,1,instr_target_-1);
         method_             := SUBSTR(target_default_method_,instr_target_+1);
         Assert_SYS.Assert_Is_Package_Method(package_,method_);
         stmt_ := 'BEGIN ' || package_ || '.' || method_ || ' ( :msg_); ' ||
                  'END;' ;
         @ApproveDynamicStatement(2005-12-05,ovjose)
         EXECUTE IMMEDIATE stmt_ USING IN OUT msg_;
         Check_And_Replace_Attribute_ (msg_,
                                       'LU_SET',
                                       'TRUE',
                                       'FALSE');
      END IF;
   END IF;
END Create_Parameter_Msg;


PROCEDURE Validate_Parameter2 (
   msg_             IN VARCHAR2,
   name_            IN VARCHAR2,
   value_           IN VARCHAR2 )
IS
   tmp_                VARCHAR2(2000) := NULL;
   dummy_              VARCHAR2(10)   := '<DUMMY>';
   file_type_          VARCHAR2(30);
   validate_method_    VARCHAR2(200);
   parameter_string_   VARCHAR2(2000);
   instr_              NUMBER;
   length_             NUMBER;
   package_            VARCHAR2(30);
   method_             VARCHAR2(30);
   param_id_           VARCHAR2(30);
   par_value_          VARCHAR2(2000);
   stmt_               VARCHAR2(32000);
   ndummy_             NUMBER := 0;
   from_param_         VARCHAR2(2000);
   to_param_           VARCHAR2(2000);
BEGIN
   from_param_ := NULL;
   to_param_   := NULL;
   IF (Ext_File_Message_API.Switch_Parse_Parameter ( value_,
                                                     from_param_,
                                                     to_param_ )) THEN
      NULL;
   END IF;
   IF (name_ = 'COMPANY') THEN
      Company_Finance_API.Exist ( value_ );
      IF (NOT Company_Finance_API.Is_User_Authorized(value_)) THEN
         Error_SYS.Appl_General( lu_name_, 'COMPNOTAUTH: You are not authorized to company :P1',value_ );
      END IF;
   ELSIF (name_ = 'FILE_TEMPLATE_ID') THEN
      Ext_File_Template_API.Exist_Valid ( value_ );
   ELSIF (name_ = 'FILE_DIRECTION_DB') THEN
      tmp_ := Message_SYS.Find_Attribute (msg_, 'FILE_TEMPLATE_ID', dummy_);
      IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
         Ext_File_Template_Dir_API.Exist_Db (tmp_, value_);
      END IF;
   ELSE
      tmp_ := Message_SYS.Find_Attribute (msg_, 'FILE_TYPE', dummy_);
      IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
         file_type_                 := tmp_;
         validate_method_           := Ext_File_Type_Param_API.Get_Validate_Method ( file_type_, name_ );
         IF (validate_method_ IS NOT NULL) THEN
            instr_                  := INSTR(validate_method_,'.');
            package_                := SUBSTR(validate_method_,1,instr_-1);
            validate_method_        := SUBSTR(validate_method_,instr_+1);
            instr_                  := INSTR(validate_method_,'<');
            IF (NVL(instr_,0) = 0) THEN
               method_              := SUBSTR(validate_method_,1);
               parameter_string_    := NULL;
            ELSE
               method_              := SUBSTR(validate_method_,1,instr_-1);
               validate_method_     := REPLACE(REPLACE(SUBSTR(validate_method_,instr_),'<'),'>');
               validate_method_     := validate_method_ || ',';
               parameter_string_    := validate_method_;
               LOOP
                  instr_ := INSTR(validate_method_,',');
                  IF (NVL(instr_,0) = 0) THEN
                     EXIT;
                  END IF;
                  ndummy_           := ndummy_ + 1;
                  IF (ndummy_ > 10) THEN
                     EXIT;
                  END IF;
                  param_id_         := SUBSTR(validate_method_,1,instr_-1);
                  tmp_ := Message_SYS.Find_Attribute (msg_, param_id_, dummy_);
                  IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
                     par_value_     := tmp_;
                  ELSE
                     IF (param_id_ = 'COMPANY') THEN
                        User_Finance_API.Get_Default_Company ( par_value_ );
                     ELSE
                        par_value_     := NULL;
                     END IF;
                  END IF;
                  parameter_string_ := REPLACE(parameter_string_,param_id_||',',CHR(39)||par_value_||CHR(39)||',');
                  validate_method_  := SUBSTR(validate_method_,instr_+1);
               END LOOP;
               length_              := LENGTH(parameter_string_);
               parameter_string_    := SUBSTR(parameter_string_,1,length_-1);
            END IF;
            --
            IF (NOT Dictionary_SYS.Method_Is_Active ( package_, method_ )) THEN
               Error_SYS.Appl_General( lu_name_, 'NOVMETHOD: Validate method :P1 not found in package :P2', method_, package_ );
            ELSE
               Assert_SYS.Assert_Is_Package_Method(package_,method_);
               IF (parameter_string_ IS NULL) THEN
                  stmt_ := 'BEGIN ' || package_ || '.' || method_ || '; ' ||
                           'END;' ;
               ELSE
                  stmt_ := 'BEGIN ' || package_ || '.' || method_ || ' ( '|| parameter_string_ || ' ); ' ||
                           'END;' ;
               END IF;
               @ApproveDynamicStatement(2006-01-03,pperse)
               EXECUTE IMMEDIATE stmt_;
            END IF;
            --      
         END IF;
      END IF;
   END IF;
END Validate_Parameter2;


PROCEDURE Validate_Parameter (
   msg_             IN VARCHAR2,
   name_            IN VARCHAR2,
   value_           IN VARCHAR2 )
IS
   from_param_         VARCHAR2(2000);
   to_param_           VARCHAR2(2000);
   last_char_          VARCHAR2(10) := Database_SYS.Get_Last_Character;
BEGIN
   from_param_ := NULL;
   to_param_   := NULL;
   IF (value_ != '%') THEN
      IF (Ext_File_Message_API.Switch_Parse_Parameter ( value_,
                                                        from_param_,
                                                        to_param_ )) THEN
         NULL;
      END IF;      
      IF (from_param_ != CHR(0))  THEN
         Validate_Parameter2 ( msg_, name_, from_param_ );
      END IF;
      IF (NVL(to_param_,' ') != NVL(from_param_,' '))  THEN
         IF (to_param_ != last_char_)  THEN
            Validate_Parameter2 ( msg_, name_, to_param_ );
         END IF;
      END IF;
   END IF;
END Validate_Parameter;


PROCEDURE Change_Attr_Parameter_Msg (
   msg_   IN OUT VARCHAR2,
   name_  IN     VARCHAR2,
   value_ IN     VARCHAR2 )
IS
   tmp_msg_      VARCHAR2(2000);
BEGIN
   tmp_msg_ := msg_;
   Ext_File_Message_API.Check_And_Replace_Attribute_ (tmp_msg_, name_, value_);
   Ext_File_Message_API.Validate_Parameter ( tmp_msg_, name_, value_ );
   Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, name_, value_);
END Change_Attr_Parameter_Msg;


PROCEDURE Change_Attr_Parameter_Msg (
   msg_   IN OUT VARCHAR2,
   name_  IN     VARCHAR2,
   value_ IN     DATE )
IS
   valuex_       VARCHAR2(2000);
BEGIN
   valuex_  := TO_CHAR(value_);
   Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, name_, valuex_);
END Change_Attr_Parameter_Msg;

@UncheckedAccess
FUNCTION Get_Attr_Parameter_Msg (
   name_  IN VARCHAR2,
   msg_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   tmp_      VARCHAR2(2000) := NULL;
   dummy_    VARCHAR2(10)   := '<DUMMY>';
BEGIN
   tmp_ := Message_SYS.Find_Attribute (msg_, name_, dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      RETURN tmp_;
   ELSE
      RETURN NULL;
   END IF;
END Get_Attr_Parameter_Msg;


PROCEDURE Return_For_Trans_Form (
   file_type_         IN     VARCHAR2,
   set_id_            IN OUT VARCHAR2,
   msg_               IN OUT VARCHAR2,
   file_template_id_  IN OUT VARCHAR2,
   file_direction_db_ IN OUT VARCHAR2,
   file_direction_    IN OUT VARCHAR2,
   file_name_         IN OUT VARCHAR2,
   company_           IN OUT VARCHAR2,
   client_server_     IN     VARCHAR2 DEFAULT 'C',
   column_name_       IN     VARCHAR2 DEFAULT NULL,
   column_value_      IN     VARCHAR2 DEFAULT NULL )
IS
   tmp_                      VARCHAR2(2000) := NULL;
   dummy_                    VARCHAR2(10)   := '<DUMMY>';
   column_valuex_            VARCHAR2(2000);
   set_idx_                  VARCHAR2(30);
   file_template_idx_        VARCHAR2(30);
   file_direction_dbx_       VARCHAR2(1);
   file_namex_               VARCHAR2(2000);
   file_nameold_             VARCHAR2(2000);
   file_directionold_        VARCHAR2(1);
   file_templateold_         VARCHAR2(30);
   companyx_                 VARCHAR2(20);
   client_serverx_           VARCHAR2(1);
   NotChanged                EXCEPTION;
BEGIN
   column_valuex_ := column_value_;
   IF (column_name_ = 'SET_ID' AND column_valuex_ IS NULL) THEN
      column_valuex_ := set_id_;
      IF (Ext_Type_Param_Set_API.Check_Any_Exist (file_type_) ) THEN
         Error_SYS.Appl_General( lu_name_, 'SETEXIST: Parameter Set Exist on File Type, cannot be empty' );
      END IF;
   END IF;
   IF (column_name_ IN ('SET_ID','FILE_TEMPLATE_ID','FILE_DIRECTION_DB')) THEN
      file_nameold_      := Get_Attr_Parameter_Msg ('FILE_NAME',         msg_);
      file_directionold_ := file_direction_db_;
      file_templateold_  := file_template_id_;
   END IF;
   IF (column_name_ = 'FILE_TEMPLATE_ID' AND column_valuex_ IS NULL) THEN
      column_valuex_ := file_template_id_;
   END IF;
   IF (column_name_ = 'FILE_DIRECTION_DB' AND column_valuex_ IS NULL) THEN
      column_valuex_ := file_direction_db_;
   END IF;
   IF (column_name_ = 'FILE_DIRECTION_DB') THEN
      IF (Ext_File_Template_Dir_API.Check_Rec_Exist (file_template_id_, column_valuex_) = 'FALSE' ) THEN
         Error_SYS.Appl_General( lu_name_, 'WRONGDIRTMP: Wrong direction according to file template definition' );
      END IF;
      IF (set_id_ IS NOT NULL) THEN
         IF (Ext_Type_Param_Per_Set_API.Check_Param_Id_Exist (file_type_,
                                                              set_id_,
                                                              'FILE_DIRECTION_DB',
                                                              column_valuex_) = 'FALSE' ) THEN
            Error_SYS.Appl_General( lu_name_, 'WRONGDIRSET: Wrong direction according to parameter set' );
         END IF;
      END IF;
   END IF;
   IF (column_name_ = 'FILE_NAME' AND column_valuex_ IS NULL) THEN
      column_valuex_ := file_name_;
   END IF;
   IF (column_name_ IN ('FILE_TYPE','SET_ID','FILE_TEMPLATE_ID')) THEN
      msg_ := NULL;
   END IF;
   IF (NVL(msg_,' ') NOT LIKE '%'||message_name_||'%') THEN
      msg_ := Message_Sys.Construct(message_name_);
   END IF;
   Check_And_Replace_Attribute_ (msg_, 'FILE_TYPE', file_type_);
   Check_And_Replace_Attribute_ (msg_, 'SET_ID',    set_id_);
   IF (NVL(column_name_,' ') != 'SET_ID') THEN
      Check_And_Replace_Attribute_ (msg_, 'FILE_NAME', file_name_);
   END IF;
   Check_And_Replace_Attribute_ (msg_, 'COMPANY',   company_);       
   IF (file_template_id_ IS NOT NULL) THEN
      IF (column_name_ IS NULL AND column_value_ IS NULL) THEN
         IF (Message_SYS.Find_Attribute (msg_, 'FILE_TEMPLATE_ID', '<DUMMY>') = '<DUMMY>') THEN
            Message_SYS.Set_Attribute (msg_,'FILE_TEMPLATE_ID', file_template_id_);
         END IF;
      END IF;
   END IF;   
   client_serverx_ := NVL(client_server_,'C');
   IF (msg_ IS NOT NULL)  THEN
      Message_SYS.Remove_Attribute ( msg_, 'LU_SET' );
   END IF;
   --
   IF (NVL(column_name_,'NULL') NOT IN ('NULL','FILE_TYPE','SET_ID')) THEN
      tmp_ := Message_SYS.Find_Attribute (msg_, column_name_, dummy_);
      IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
         IF (tmp_ = column_value_) THEN
            IF (column_name_ != 'NEW_LOAD_TYPE') THEN   
               RAISE NotChanged;
            END IF;
         END IF;
      END IF;
      Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, column_name_, column_valuex_);
   END IF;
   --
   IF (NVL(column_name_,' ') != 'NULL') THEN
      Create_Parameter_Msg ( msg_,
                             file_type_,
                             set_id_,
                             client_serverx_,
                             column_name_ );
   END IF;
   --
   tmp_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);
   IF ( NVL(tmp_,' ') != '<DUMMY>' ) THEN
      companyx_ := tmp_;
      IF (NVL(companyx_,' ') != ' ') THEN
         company_ := companyx_;
      END IF;
   END IF;
   set_idx_  := Get_Attr_Parameter_Msg ('SET_ID',  msg_);
   IF (NVL(set_idx_,NVL(set_id_,' ')) != NVL(set_id_,' ')) THEN
      set_id_ := set_idx_;
   END IF;
   file_template_idx_  := Get_Attr_Parameter_Msg ('FILE_TEMPLATE_ID',  msg_);
   IF (NVL(file_template_idx_,NVL(file_template_id_,' ')) != NVL(file_template_id_,' ')) THEN
      file_template_id_ := file_template_idx_;
   END IF;
   file_namex_         := Get_Attr_Parameter_Msg ('FILE_NAME',         msg_);
   file_name_       := file_namex_;
   --
   file_direction_dbx_ := Get_Attr_Parameter_Msg ('FILE_DIRECTION_DB', msg_);
   IF (NVL(file_direction_dbx_,NVL(file_direction_db_,' ')) != NVL(file_direction_db_,' ')) THEN
      file_direction_db_  := file_direction_dbx_;
      file_direction_     := SUBSTR(File_Direction_API.Decode(file_direction_dbx_),1,200);
   END IF;
   IF (file_directionold_ = file_direction_db_ AND
       file_templateold_  = file_template_id_) THEN
      IF (file_nameold_ IS NOT NULL) THEN
         file_name_  := file_nameold_;
         Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_, 'FILE_NAME', file_name_);
      END IF;
   END IF;
   --
EXCEPTION
   WHEN NotChanged THEN
      NULL;
END Return_For_Trans_Form;


FUNCTION Switch_Parse_Parameter (
   parameter_    IN  VARCHAR2,
   from_param_   OUT VARCHAR2,
   to_param_     OUT VARCHAR2) RETURN BOOLEAN
IS
   from_       NUMBER;
   to_         NUMBER;
   pos_        NUMBER;
   value_      VARCHAR2(500);
   from_value_ VARCHAR2(500);
   to_value_   VARCHAR2(500);
   parm_list_  VARCHAR2(32000);
   first_      VARCHAR2(1);
   last_       VARCHAR2(10) := Database_SYS.Get_Last_Character;
BEGIN
   first_:= CHR(0);
   IF (parameter_ IS NULL) THEN
      from_param_ := first_;
      to_param_   := last_;
      RETURN (FALSE);
   ELSE
      parm_list_ := parameter_ || ';';
   END IF;
   from_ := 1;
   to_ := instr(parm_list_, ';', from_);
   IF (to_ > 0) THEN
      value_ := ltrim(rtrim(substr(parm_list_, from_, to_ - from_)));
      pos_   := instr(value_, '..');
      IF (pos_ > 0) THEN
         IF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
            from_param_ := first_;
            to_param_   := last_;
            RETURN (TRUE);
         ELSE
            from_value_ := substr(value_, 1, pos_ - 1);
            to_value_ := substr(value_, pos_ + 2);
            IF (from_value_ <= to_value_) THEN
               from_param_ := from_value_;
               to_param_   := to_value_;
               RETURN (FALSE);
            ELSE
               from_param_ := to_value_;
               to_param_   := from_value_;
               RETURN (FALSE);
            END IF;
         END IF;
      ELSIF (instr(value_, '%') > 0 OR instr(value_, '_') > 0 ) THEN
         IF (instr(value_, '..') > 0) THEN
            from_param_ := first_;
            to_param_   := last_;
            RETURN (TRUE);
         ELSE
            from_param_ := first_;
            to_param_   := last_;
            RETURN (TRUE);
         END IF;
      ELSIF (substr(value_, 1, 2) = '<=') THEN
         from_param_ := first_;
         to_param_   := ltrim(substr(value_,3));
         RETURN (FALSE);
      ELSIF (substr(value_, 1, 2) = '>=') THEN
         from_param_ := ltrim(substr(value_,3));
         to_param_   := last_;
         RETURN (FALSE);
      ELSIF (substr(value_, 1, 2) = '!=') THEN
         from_param_ := first_;
         to_param_   := last_;
         RETURN (TRUE);
      ELSIF (substr(value_, 1, 1) = '<') THEN
         from_param_ := first_;
         to_param_   := ltrim(substr(value_,2));
         RETURN (TRUE);
      ELSIF (substr(value_, 1, 1) = '>') THEN
         from_param_ := ltrim(substr(value_,2));
         to_param_   := last_;
         RETURN (TRUE);
      ELSE
         from_:=to_+1;
         to_:= instr(parm_list_,';',from_);
         IF (to_>0) THEN
            from_param_ := first_;
            to_param_   := last_;
            RETURN (TRUE);
         ELSE
            from_param_ := value_;
            to_param_   := value_;
            RETURN (FALSE);
         END IF;
      END IF;
   END IF;
   from_param_ := first_;
   to_param_   := last_;
   RETURN (TRUE);
END Switch_Parse_Parameter;


PROCEDURE Check_Param_Value (
   skip_         IN OUT VARCHAR2,
   data_type_    IN     VARCHAR2,
   test_value_   IN     VARCHAR2,
   where_type_   IN     VARCHAR2,
   from_value_   IN     VARCHAR2,
   to_value_     IN     VARCHAR2 ) 
IS
   test_value_n_        NUMBER;
   in_value_            VARCHAR2(100);
   from_valuex_         VARCHAR2(500);
   from_valuey_         VARCHAR2(500);
   to_                  NUMBER;
BEGIN
   skip_ := 'TRUE';
   IF (data_type_ = '2') THEN
      test_value_n_ := test_value_;
      IF (where_type_ IN ('IN','NOT IN')) THEN
         IF (where_type_ = 'NOT IN') THEN
            skip_ := 'FALSE';
         END IF;
         from_valuex_ := from_value_;
         LOOP
            to_   := INSTR(from_valuex_, ';');
            IF (NVL(to_,0) = 0) THEN
               EXIT;
            END IF;
            from_valuey_ := SUBSTR(from_valuex_,to_+1);
            in_value_    := SUBSTR(from_valuex_,1,to_-1);
            IF (test_value_n_ = in_value_) THEN
               IF (where_type_ = 'IN') THEN
                  skip_ := 'FALSE';
               ELSE
                  skip_ := 'TRUE';
               END IF;
               EXIT;
            END IF;
            from_valuex_ := from_valuey_;
         END LOOP;
      ELSIF (where_type_ = 'BETWEEN') THEN
         IF (test_value_n_ BETWEEN from_value_ AND to_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = 'NOT BETWEEN') THEN
         IF (test_value_n_ NOT BETWEEN from_value_ AND to_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '>=') THEN
         IF (test_value_n_ >= from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '<=') THEN
         IF (test_value_n_ <= from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '>') THEN
         IF (test_value_n_ > from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '<') THEN
         IF (test_value_n_ < from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '!=') THEN
         IF (test_value_n_ != from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = 'LIKE') THEN
         IF (test_value_n_ LIKE from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = 'NOT LIKE') THEN
         IF (test_value_n_ NOT LIKE from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      END IF;
   ELSE
      IF (where_type_ IN ('IN','NOT IN')) THEN
         IF (where_type_ = 'NOT IN') THEN
            skip_ := 'FALSE';
         END IF;
         from_valuex_ := from_value_;
         LOOP
            to_   := INSTR(from_valuex_, ';');
            IF (NVL(to_,0) = 0) THEN
               EXIT;
            END IF;
            from_valuey_ := SUBSTR(from_valuex_,to_+1);
            in_value_    := SUBSTR(from_valuex_,1,to_-1);
            IF (test_value_ = in_value_) THEN
               IF (where_type_ = 'IN') THEN
                  skip_ := 'FALSE';
               ELSE
                  skip_ := 'TRUE';
               END IF;
               EXIT;
            END IF;
            from_valuex_ := from_valuey_;
         END LOOP;
      ELSIF (where_type_ = 'BETWEEN') THEN
         IF (test_value_ BETWEEN from_value_ AND to_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = 'NOT BETWEEN') THEN
         IF (test_value_ NOT BETWEEN from_value_ AND to_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '>=') THEN
         IF (test_value_ >= from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '<=') THEN
         IF (test_value_ <= from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '>') THEN
         IF (test_value_ > from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '<') THEN
         IF (test_value_ < from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = '!=') THEN
         IF (test_value_ != from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = 'LIKE') THEN
         IF (test_value_ LIKE from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      ELSIF (where_type_ = 'NOT LIKE') THEN
         IF (test_value_ NOT LIKE from_value_) THEN
            skip_ := 'FALSE';
         END IF;
      END IF;
   END IF;
END Check_Param_Value;


PROCEDURE Is_Date_Format_Ok (
   value_     IN VARCHAR2 )
IS
   tmp_date_     DATE;
BEGIN
   tmp_date_ := TO_DATE(value_,Client_SYS.date_format_);
EXCEPTION
   WHEN OTHERS THEN
      Error_SYS.Appl_General( lu_name_, 'DATEERROR: Error on date format' );
END Is_Date_Format_Ok;


@UncheckedAccess
FUNCTION Is_Column_Numeric (
   value_     IN VARCHAR2 ) RETURN BOOLEAN
IS
   tmp_num_      NUMBER;
BEGIN
   tmp_num_ := TO_NUMBER(value_);
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END Is_Column_Numeric;



PROCEDURE Param_To_Where (
   where_        IN OUT VARCHAR2,
   where_type_   IN OUT VARCHAR2,
   from_value_   IN OUT VARCHAR2,
   to_value_     IN OUT VARCHAR2,
   parameter_    IN     VARCHAR2,
   param_id_     IN     VARCHAR2,
   description_  IN     VARCHAR2,
   data_type_    IN     VARCHAR2,
   date_format_  IN     VARCHAR2 ) 
IS
   param_entered_    VARCHAR2(5);
   from_             NUMBER;
   to_               NUMBER;
   tox_              NUMBER;
   pos_              NUMBER;
   value_            VARCHAR2(500);
   from_valuex_      VARCHAR2(32000);
   to_valuex_        VARCHAR2(500);
   parm_list_        VARCHAR2(32000);
   first_            VARCHAR2(1);
   last_             VARCHAR2(10) := Database_SYS.Get_Last_Character;
   ok_               VARCHAR2(5) := 'FALSE';
   multi_list_       VARCHAR2(5) := 'FALSE';
   date_             DATE;
BEGIN
   first_:= CHR(0);
   IF (parameter_ IS NULL) THEN
      param_entered_ := 'FALSE';
   ELSE
      parm_list_ := parameter_ || ';';
      param_entered_ := 'TRUE';
   END IF;
   from_ := 1;
   to_   := INSTR(parm_list_, ';', from_);
   tox_  := INSTR(parm_list_, ';', -1);
   IF (NVL(tox_,to_) != to_) THEN
      multi_list_ := 'TRUE';
   END IF;
   IF (param_entered_ = 'TRUE') THEN
      value_ := SUBSTR(parm_list_, from_, to_ - from_);
      IF (multi_list_ = 'TRUE') THEN
         from_value_ := parm_list_;
         to_value_   := NULL;
         IF (SUBSTR(from_value_,1,1) = '!') THEN
            from_value_ := SUBSTR(from_value_,2);
            where_type_ := 'NOT IN';
         ELSE
            where_type_ := 'IN';
         END IF;
         ok_ := 'TRUE';
      ELSE
         pos_   := INSTR(value_, '..');
         IF (pos_ > 0) THEN
            from_value_ := NVL(SUBSTR(value_, 1, pos_ - 1),first_);
            IF (INSTR(from_value_, '%') > 0) THEN
               from_value_ := REPLACE(from_value_,'%',first_);
            END IF;
            to_value_   := NVL(SUBSTR(value_, pos_ + 2),last_);
            IF (INSTR(to_value_, '%') > 0) THEN
               to_value_ := REPLACE(to_value_,'%',last_);
            END IF;
            IF (SUBSTR(from_value_,1,1) = '!') THEN
               from_value_ := SUBSTR(from_value_,2);
               where_type_ := 'NOT BETWEEN';
            ELSE
               where_type_ := 'BETWEEN';
            END IF;
            ok_ := 'TRUE';
         END IF;
         IF (ok_ = 'FALSE') THEN
            pos_   := INSTR(value_, '<=');
            IF (pos_ > 0) THEN
               from_value_ := NVL(SUBSTR(value_, pos_ + 2),last_);
               to_value_   := NULL;
               where_type_ := '<=';
               ok_ := 'TRUE';
            END IF;
         END IF;
         IF (ok_ = 'FALSE') THEN
            pos_   := INSTR(value_, '>=');
            IF (pos_ > 0) THEN
               from_value_ := NVL(SUBSTR(value_, pos_ + 2),last_);
               to_value_   := NULL;
               where_type_ := '>=';
               ok_ := 'TRUE';
            END IF;
         END IF;
         IF (ok_ = 'FALSE') THEN
            pos_   := INSTR(value_, '!=');
            IF (pos_ > 0) THEN
               from_value_ := NVL(SUBSTR(value_, pos_ + 2),last_);
               to_value_   := NULL;
               where_type_ := '!=';
               ok_ := 'TRUE';
            END IF;
         END IF;
         IF (ok_ = 'FALSE') THEN
            pos_   := INSTR(value_, '<');
            IF (pos_ > 0) THEN
               from_value_ := NVL(SUBSTR(value_, pos_ + 1),last_);
               to_value_   := NULL;
               where_type_ := '<';
               ok_ := 'TRUE';
            END IF;
         END IF;
         IF (ok_ = 'FALSE') THEN
            pos_   := INSTR(value_, '>');
            IF (pos_ > 0) THEN
               from_value_ := NVL(SUBSTR(value_, pos_ + 1),last_);
               to_value_   := NULL;
               where_type_ := '>';
               ok_ := 'TRUE';
            END IF;
         END IF;
         IF (ok_ = 'FALSE') THEN
            IF (INSTR(value_, '%') > 0 OR INSTR(value_, '_') > 0 ) THEN
               from_value_ := value_;
               to_value_   := NULL;
               IF (SUBSTR(from_value_,1,1) = '!') THEN
                  from_value_ := SUBSTR(from_value_,2);
                  where_type_ := 'NOT LIKE';
               ELSE
                  where_type_ := 'LIKE';
               END IF;
               ok_ := 'TRUE';
            END IF;
         END IF;
      END IF;
      IF (ok_ = 'FALSE') THEN
         from_value_ := value_;
         to_value_   := NULL;
         where_type_ := '=';
         ok_ := 'TRUE';
      END IF;
      IF (INSTR(from_value_, '>') > 0 OR 
          INSTR(from_value_, '<') > 0 OR
          INSTR(from_value_, '=') > 0 OR 
          INSTR(from_value_, '!') > 0) THEN
         Error_SYS.Appl_General( lu_name_, 'INVFROMVAL: Invalid from parameter value :P1 for :P2',value_, description_ );
      END IF;
      IF (INSTR(to_value_, '>') > 0 OR 
          INSTR(to_value_, '<') > 0 OR
          INSTR(to_value_, '=') > 0 OR 
          INSTR(to_value_, '!') > 0) THEN
         Error_SYS.Appl_General( lu_name_, 'INVTOVAL: Invalid to parameter value :P1 for :P2',value_, description_ );
      END IF;
      
      IF (multi_list_ = 'TRUE') THEN
         IF (data_type_ = '2') THEN
            from_valuex_ := REPLACE(SUBSTR(from_value_,1,LENGTH(from_value_)-1),';',',');
         ELSE
            from_valuex_ := CHR(39)||REPLACE(SUBSTR(from_value_,1,LENGTH(from_value_)-1),';',CHR(39)||','||CHR(39))||CHR(39);
         END IF;
         where_ := param_id_ || ' ' || where_type_ || ' (' || from_valuex_ || ') ';
      ELSE
         IF (data_type_ = '1') THEN
            from_valuex_ := CHR(39)||from_value_||CHR(39);
            to_valuex_   := CHR(39)||to_value_||CHR(39);
         END IF;
         IF (data_type_ = '2') THEN
            from_valuex_ := from_value_;
            IF (INSTR(from_valuex_,'%') > 0) THEN
               from_valuex_ := CHR(39)||from_valuex_||CHR(39);
            END IF;
            to_valuex_   := to_value_;
            IF (INSTR(to_valuex_,'%') > 0) THEN
               to_valuex_ := CHR(39)||to_valuex_||CHR(39);
            END IF;
         END IF;
         IF (data_type_ = '3') THEN
            IF (from_value_ = last_) THEN
               from_valuex_ := 'TO_DATE('||CHR(39)||'19000101'||CHR(39)||','||CHR(39)||'yyyymmdd'||CHR(39)||')';
            ELSE
               BEGIN
                  date_ := TO_DATE(from_value_,date_format_);
               EXCEPTION
                  WHEN OTHERS THEN
                     Error_SYS.Appl_General( lu_name_, 'INVDATVAL: Invalid date parameter value :P1 for :P2 have to be in format :P3',value_,description_,date_format_ );
               END;
               from_valuex_ := 'TO_DATE('||CHR(39)||from_value_||CHR(39)||','||CHR(39)||date_format_||CHR(39)||')';
            END IF;
            IF (to_value_ = last_) THEN
               to_valuex_ := 'TO_DATE('||CHR(39)||'99991231'||CHR(39)||','||CHR(39)||'yyyymmdd'||CHR(39)||')';
            ELSIF (to_value_ IS NULL) THEN
               to_valuex_ := NULL;
            ELSE
               BEGIN
                  date_ := TO_DATE(to_value_,date_format_);
               EXCEPTION
                  WHEN OTHERS THEN
                     Error_SYS.Appl_General( lu_name_, 'INVDATVAL: Invalid date parameter value :P1 for :P2 have to be in format :P3',value_,description_,date_format_ );
               END;
               to_valuex_ := 'TO_DATE('||CHR(39)||to_value_||CHR(39)||','||CHR(39)||date_format_||CHR(39)||')';
            END IF;
         END IF;
         where_ := param_id_ || ' ' || where_type_ || ' ' || from_valuex_;
         IF (where_type_ = 'BETWEEN') THEN
            where_ := where_ || ' AND ' || to_valuex_;
         END IF;
      END IF;
   END IF;
END Param_To_Where;


PROCEDURE Create_Out_Where (
   where_                  IN OUT VARCHAR2,
   msg_                    IN     VARCHAR2,
   file_type_              IN     VARCHAR2,
   date_format_            IN     VARCHAR2,
   view_name_              IN     VARCHAR2,
   set_id_                 IN     VARCHAR2 )
IS
   tmp_                      VARCHAR2(2000) := NULL;
   dummy_                    VARCHAR2(10)   := '<DUMMY>';
   first_                    VARCHAR2(5) := 'TRUE';
   where_part_               VARCHAR2(500);
   where_type_               VARCHAR2(20);
   from_value_               VARCHAR2(500);
   to_value_                 VARCHAR2(500);
   data_type_                VARCHAR2(1);
   param_id_                 VARCHAR2(30);
   description_              VARCHAR2(100);
   company_auth_             VARCHAR2(100) :=
      ' EXISTS (SELECT * FROM Company_Finance_Auth1 c WHERE a.company = c.company)';
   CURSOR params IS
      SELECT b.param_id,
             b.description,
             b.param_no
      FROM   ext_type_param_per_set_tab a,
             ext_file_type_param_tab    b
      WHERE  a.set_id    = set_id_
      AND    a.param_no  = b.param_no
      AND    a.file_type = b.file_type
      AND    a.file_type = file_type_
      AND    b.param_id  != 'ORDER_BY';
BEGIN
   FOR param_ IN params LOOP
      description_ := NVL(RTRIM(RPAD(Basic_Data_Translation_API.Get_Basic_Data_Translation('ACCRUL', 'ExtFileTypeParam', file_type_ || '^' || param_.param_no ),100)),param_.description);
      param_id_ := param_.param_id;
      IF (param_id_ = 'FILE_TYPEX') THEN
         param_id_ := 'FILE_TYPE';
      END IF;
      IF (param_id_ = 'FILE_TEMPLATE_IDX') THEN
         param_id_ := 'FILE_TEMPLATE_ID';
      END IF;
      IF (param_id_ = 'COMPANY') THEN
         tmp_ := Message_SYS.Find_Attribute (msg_, 'COMPANY', dummy_);
         IF ( tmp_ IS NULL ) THEN
            Error_SYS.Appl_General( lu_name_, 'CMPNULL: Parameter for Company is empty' );
         END IF;
      END IF;
      tmp_ := Message_SYS.Find_Attribute (msg_, param_.param_id, dummy_);  
      IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
         IF (External_File_Utility_API.Check_View_Col_Exist (view_name_, param_id_) = 'TRUE') THEN
            data_type_ := NVL(Ext_File_Type_Rec_Column_API.Get_Data_Type_Db ( file_type_, param_.param_id),'1');
            Param_To_Where ( where_part_,
                             where_type_,
                             from_value_,
                             to_value_,
                             tmp_,
                             param_id_,
                             description_,
                             data_type_,
                             date_format_ ); 
            IF (first_ = 'TRUE') THEN
               first_ := 'FALSE';
               where_ := 'WHERE ' || where_part_;
            ELSE
               where_ := where_ || ' AND ' || where_part_;
            END IF;
         END IF;
      END IF;
   END LOOP;
   --
   IF (External_File_Utility_API.Check_View_Col_Exist (view_name_, 'COMPANY') = 'TRUE') THEN
      IF (first_ = 'TRUE') THEN
         where_ := 'WHERE ' || company_auth_;
      ELSE
         where_ := where_ || ' AND ' || company_auth_;
      END IF;
   END IF;
   --
END Create_Out_Where;


PROCEDURE Is_True_False (
   value_          IN     VARCHAR2 )
IS
BEGIN
   IF (UPPER(value_) NOT IN ('TRUE','FALSE')) THEN
      Error_SYS.Appl_General( lu_name_, 'NOTRUEFALSE: Only TRUE or FALSE is allowed' );
   END IF;
END Is_True_False;


@UncheckedAccess
FUNCTION Comment_Value (
   name_    IN VARCHAR2,
   comment_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   nlen_ NUMBER;
   from_ NUMBER;
   to_   NUMBER;
BEGIN
   nlen_ := length(name_);
   from_ := instr(upper('^'||comment_), '^'||name_||'=');
   IF (from_ > 0) THEN
      to_ := instr(comment_, '^', from_);
      IF ( to_ = 0 ) THEN
        to_ := length(comment_) + 1;
      END IF;
      RETURN(substr(comment_, from_+nlen_+1, to_-from_-nlen_-1));
   ELSE
      RETURN(NULL);
   END IF;
END Comment_Value;



FUNCTION Translate_Value_Sql (
   err_msg_       OUT VARCHAR2,
   value_         IN  VARCHAR2,
   argument_      IN  VARCHAR2 ) RETURN VARCHAR2
IS
   argumentx_            VARCHAR2(2000);
   instr_                NUMBER;
   start_translate_      NUMBER;
   new_value_            VARCHAR2(2000);
   stmnt_                VARCHAR2(2000);
BEGIN
   new_value_          := value_;
   IF (argument_ LIKE 'SQL:%') THEN
      start_translate_ := INSTR(argument_,'SQL:');
      argumentx_  := SUBSTR(argument_,start_translate_+4);
      IF (SUBSTR(argumentx_,-1,1) != ';') THEN
         argumentx_ := argumentx_ || ';';
      END IF;
      Trace_SYS.Message ('SQL argument_ : '||argumentx_);
      LOOP
         instr_             := NVL(INSTR(argumentx_, ';'),0);
         IF (instr_ = 0) THEN
            EXIT;
         END IF;
         stmnt_             := SUBSTR(argumentx_,1,instr_-1);
         BEGIN
            stmnt_          := REPLACE(stmnt_,'<VALUE>',CHR(39)||new_value_||CHR(39));
            stmnt_          := 'SELECT ' ||stmnt_||' FROM dual';
            Trace_SYS.Message ('stmnt_ : '||stmnt_);
            @ApproveDynamicStatement(2006-01-03,pperse)
            EXECUTE IMMEDIATE stmnt_ INTO new_value_;
            --Trace_SYS.Message ('new_value_ : '||new_value_);
         EXCEPTION
            WHEN OTHERS THEN
               err_msg_   := Language_SYS.Translate_Constant (lu_name_, 'EXTSQLERR1: SQL statement is not valid');
               EXIT;
         END;
         argumentx_    := SUBSTR(argumentx_,instr_+1);
      END LOOP;
   END IF;
   RETURN new_value_;
END Translate_Value_Sql;


FUNCTION Translate_Values_Sql (
   err_msg_           OUT VARCHAR2,
   argument_          IN  VARCHAR2,
   file_type_         IN  VARCHAR2,
   record_type_id_    IN  VARCHAR2,
   transrec_          IN  Ext_File_Trans_Tab%ROWTYPE ) RETURN VARCHAR2
IS
   argumentx_            VARCHAR2(2000);
   instr_                NUMBER;
   dest_instr1_          NUMBER;
   dest_instr2_          NUMBER;
   dest_length_          NUMBER;
   cond_column_          VARCHAR2(30);
   dest_column_          VARCHAR2(30);
   dest_value_           VARCHAR2(4000);
   start_translate_      NUMBER;
   new_value_            VARCHAR2(2000);
   stmnt_                VARCHAR2(32000);
   stmnt2_               VARCHAR2(32000);
   xxx_                  NUMBER := 0;
   yyy_                  NUMBER := 0;
   data_type_db_         VARCHAR2(1);
BEGIN
   IF (argument_ LIKE 'SQL:%') THEN
      IF (argument_ LIKE 'SQL:%') THEN
         start_translate_ := INSTR(argument_,'SQL:');
         argumentx_  := SUBSTR(argument_,start_translate_+4);
         IF (SUBSTR(argumentx_,-1,1) != ';') THEN
            argumentx_ := argumentx_ || ';';
         END IF;
         Trace_SYS.Message ('SQL argument_ : '||argumentx_);
         LOOP
            xxx_ := xxx_ + 1;
            IF (xxx_ > 10) THEN
               EXIT;
            END IF;
            instr_             := NVL(INSTR(argumentx_, ';'),0);
            IF (instr_ = 0) THEN
               EXIT;
            END IF;
            stmnt_             := SUBSTR(argumentx_,1,instr_-1);
            BEGIN
               LOOP
                  yyy_ := yyy_ + 1;
                  IF (yyy_ > 10) THEN
                     EXIT;
                  END IF;
                  dest_instr1_  := NVL(INSTR(stmnt_, '<'),0);
                  IF (dest_instr1_ = 0) THEN
                     EXIT;
                  END IF;
                  dest_instr2_  := NVL(INSTR(stmnt_, '>'),0);
                  IF (dest_instr2_ = 0) THEN
                     EXIT;
                  END IF;
                  dest_length_  := dest_instr2_ - (dest_instr1_ + 1);
                  cond_column_  := SUBSTR(stmnt_,dest_instr1_ + 1,dest_length_);
                  IF (cond_column_ = 'FILE_LINE') THEN
                     dest_value_ := CHR(39) || transrec_.file_line || CHR(39);
                  ELSE
                     data_type_db_ := Ext_File_Type_Rec_Column_API.Get_Data_Type_Db (file_type_,
                                                                                     record_type_id_,
                                                                                     cond_column_); 
                     dest_column_  := Ext_File_Type_Rec_Column_API.Get_Destination_Column ( file_type_,
                                                                                            record_type_id_,
                                                                                            cond_column_ );
                     dest_value_   := Ext_File_Column_Util_API.Return_C_Value ( dest_column_, transrec_ );
                     IF (data_type_db_ = '1') THEN
                        dest_value_ := CHR(39) || dest_value_ || CHR(39);
                     END IF;
                  END IF;
                  stmnt2_ := SUBSTR(stmnt_,1,dest_instr1_ - 1) || dest_value_ || SUBSTR(stmnt_,dest_instr2_ + 1);
                  stmnt_ := stmnt2_;
               END LOOP;
               stmnt_          := 'SELECT ' ||stmnt_||' FROM dual';               
               @ApproveDynamicStatement(2006-01-03,pperse)
               EXECUTE IMMEDIATE stmnt_ INTO new_value_;
               Trace_SYS.Message ('new_value_ : '||new_value_);
            EXCEPTION
               WHEN OTHERS THEN
                  Trace_SYS.Message ('EXCEPTION Translate_Values_Sql');
                  err_msg_   := Language_SYS.Translate_Constant (lu_name_, 'EXTSQLERR1: SQL statement is not valid');
                  EXIT;
            END;
            argumentx_    := SUBSTR(argumentx_,instr_+1);
         END LOOP;
      END IF;
   END IF;
   RETURN new_value_;
END Translate_Values_Sql;


@UncheckedAccess
FUNCTION Comment_To_Reference (
   comment_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   reference_  VARCHAR2(2000);
   params_     VARCHAR2(2000);
   view_       VARCHAR2(200);
   par1_       NUMBER     := 0;
   par2_       NUMBER     := 0;
BEGIN
   par1_   := INSTR(comment_,'(');
   par2_   := INSTR(comment_,'/');
   IF (par1_ = 0 AND par2_ = 0) THEN
      IF (comment_ IS NOT NULL) THEN
         view_     := Dictionary_SYS.Get_Base_View(comment_);
      END IF;
   ELSE
      IF (par1_ != 0) THEN
         reference_ := SUBSTR(comment_,1,par1_-1);
         params_    := SUBSTR(comment_,par1_);
         par2_      := INSTR(params_,'/');
         IF (par2_ != 0) THEN
            params_ := SUBSTR(params_,1,par2_-1);
         END IF;
      ELSE
         reference_ := SUBSTR(comment_,1,par2_-1);
         params_    := NULL;
      END IF;
      IF (reference_ IS NOT NULL) THEN
         par2_   := INSTR(reference_,'/');
         IF (par2_ != 0) THEN
            reference_ := SUBSTR(reference_,1,par2_-1);
         END IF;                 
         view_         := Dictionary_SYS.Get_Base_View(reference_);
      END IF;      
      IF (view_ IS NOT NULL AND par2_ = 0) THEN   
         view_ := view_||UPPER(params_);
      END IF;
   END IF;
   RETURN view_;
END Comment_To_Reference;



@UncheckedAccess
FUNCTION Instr_In_Line (
   file_line_ IN VARCHAR2,
   value_     IN VARCHAR2,
   plus_pos_  IN VARCHAR2 DEFAULT NULL,
   max_pos_   IN NUMBER   DEFAULT NULL) RETURN VARCHAR2
IS
   instra_       NUMBER;
   valuex_       VARCHAR2(100);
   valuey_       VARCHAR2(100);
   instr_        NUMBER         := 0;
BEGIN
   valuex_    := value_;
   IF (SUBSTR(valuex_,LENGTH(valuex_),1) != ';') THEN
      valuex_ := valuex_ || ';';
   END IF;
   LOOP
      instra_ := INSTR(valuex_,';');
      IF (NVL(instra_,0) = 0) THEN
         EXIT;
      END IF;
      valuey_ := SUBSTR(valuex_,1,instra_-1);
      valuex_ := SUBSTR(valuex_,instra_+1);
      instr_  := INSTR(file_line_,valuey_);
      IF (max_pos_ IS NOT NULL AND instr_ > max_pos_) THEN
         instr_ := 0;
      END IF;
      IF (instr_ > 0) THEN
         EXIT;
      END IF;
   END LOOP;
   IF (plus_pos_ = 'A' AND instr_ > 0) THEN
      instr_ := instr_ + LENGTH(valuey_);
   END IF;
   IF (plus_pos_ BETWEEN '1' AND '9' AND instr_ > 0) THEN
      instr_ := instr_ + plus_pos_;
   END IF;
   RETURN TO_CHAR(instr_);
END Instr_In_Line;



@UncheckedAccess
FUNCTION Find_Attribute (
   file_line_      IN VARCHAR2,
   find_attr_      IN VARCHAR2,
   separator_from_ IN VARCHAR2 DEFAULT NULL,
   separator_to_   IN VARCHAR2 DEFAULT NULL,
   attr_q_start_   IN VARCHAR2 DEFAULT NULL,
   attr_q_end_     IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
   separator_fromx_   VARCHAR2(20);
   separator_tox_     VARCHAR2(20);
   file_linex_        VARCHAR2(4000);
   find_attrx_        VARCHAR2(200);
   start_             NUMBER;
   end_               NUMBER;
   length_            NUMBER;
   attr1_             VARCHAR2(2000);
   attr2_             VARCHAR2(2000);
BEGIN
   separator_fromx_   := NVL(LTRIM(RTRIM(separator_from_)),' ');
   separator_tox_     := NVL(LTRIM(RTRIM(separator_to_)),' ');
   file_linex_        := REPLACE(REPLACE(file_line_,CHR(13),' '),CHR(10),' ');
   find_attrx_        := find_attr_;
   IF (attr_q_start_ IS NOT NULL) THEN
      find_attrx_     := attr_q_start_ || find_attrx_;
   END IF;
   IF (attr_q_end_ IS NOT NULL) THEN
      find_attrx_     := find_attrx_ || attr_q_end_;
   END IF;
   start_             := INSTR(UPPER(file_linex_),UPPER(find_attrx_));
   IF (NVL(start_,0) = 0) THEN
      RETURN NULL;
   END IF;
   start_ := start_ + LENGTH(find_attrx_);
   IF (attr_q_end_ IS NOT NULL) THEN
      start_ := start_ - 1;
   END IF;
   attr1_ := LTRIM(SUBSTR(file_linex_,start_));
   start_ := INSTR(attr1_,separator_fromx_) + 1;
   attr1_ := LTRIM(SUBSTR(attr1_,start_));
   end_   := INSTR(attr1_,NVL(separator_tox_,' '));
   IF (end_ = 0) THEN
      attr2_ := attr1_;
   ELSE
      length_   := end_ - 1;
      IF (length_ >= 0) THEN
         attr2_ := SUBSTR(attr1_,1,length_);
      ELSE
         attr2_ := NULL;
      END IF;
   END IF;
   RETURN attr2_;
END Find_Attribute;



@UncheckedAccess
FUNCTION Find_X_Attribute (
   file_line_      IN VARCHAR2,
   find_attr_      IN VARCHAR2,
   column_id_      IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
   find_attrx_        VARCHAR2(100);
BEGIN
   IF (UPPER(find_attr_) LIKE 'XATTR:%') THEN
      find_attrx_ := LTRIM(RTRIM(SUBSTR(find_attr_,7)));
   ELSE
      find_attrx_ := LTRIM(RTRIM(find_attr_));
   END IF;
   IF (find_attrx_ IS NULL) THEN
      find_attrx_ := column_id_;
   END IF;
   RETURN Find_Attribute (file_line_,
                          find_attrx_,
                          '>',
                          '<',
                          '<',
                          '>');
END Find_X_Attribute;



@UncheckedAccess
FUNCTION Method_Is_Valid (
   package_name_ IN VARCHAR2,
   method_name_  IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR get_method IS
      SELECT 1
      FROM   Dictionary_Sys_Method_Active
      WHERE  package_name = UPPER(package_name_)
      AND    method_name  = INITCAP(method_name_)
      AND    method_type  = 'P';
BEGIN
   OPEN  get_method;
   FETCH get_method INTO dummy_;
   IF (get_method%FOUND) THEN
      CLOSE get_method;
      RETURN TRUE;
   ELSE
      CLOSE get_method;
      RETURN FALSE;
   END IF;
END Method_Is_Valid;




