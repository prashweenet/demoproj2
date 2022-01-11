-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileLoad
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  020527  JeGu    Bug 29562 Corrected
--  020529  JeGu    Bug 29562 Recorrected
--  021011  PPerse  Merged External Files
--  040324  Gepelk  2004 SP1 Merge.
--  051027  gadalk  B128186 Date Convertion error through Message_SYS.
--  061020  Samwlk  LCS Merge 60713, Modification done in File_Template_Used Function.
--  071226  AjPelk  Bug 69856, Modified an error msg SETEXIST
--  080911  Maselk  Bug 76523, Corrected in Create_Load_Id_Param().
--  100322  Jeguse  EAFH-2475 
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA
--  131123  MEALLK  PBFI-2017, MOdified Create_Load_Id_Param
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   load_file_id_       EXT_FILE_LOAD_TAB.load_file_id%TYPE;
   user_id_            EXT_FILE_LOAD_TAB.user_id%TYPE;
BEGIN
   super(attr_);
   load_file_id_ := External_File_Utility_API.Get_Next_Seq;
   user_id_      := Fnd_Session_API.Get_Fnd_User;
   Client_SYS.Add_To_Attr( 'LOAD_FILE_ID', load_file_id_, attr_ );
   Client_SYS.Add_To_Attr( 'USER_ID', user_id_, attr_ );
   Client_SYS.Add_To_Attr( 'LOAD_DATE', SYSDATE, attr_ );
   Client_SYS.Add_To_Attr( 'STATE', Ext_File_State_API.Decode('1'), attr_ );
   Client_SYS.Add_To_Attr( 'STATE_DB', '1', attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT EXT_FILE_LOAD_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   lattr_             VARCHAR2(3000);
   fnd_user_          VARCHAR2(30);
   lobjid_            VARCHAR2(30);
   lobjversion_       VARCHAR2(30);
   linfo_             VARCHAR2(2000);
BEGIN
    newrec_.state := 1;  
   super(objid_, objversion_, newrec_, attr_);
   
   fnd_user_ := Fnd_Session_API.Get_Fnd_User;
   Client_SYS.Clear_Attr(lattr_);
   Client_SYS.Add_To_Attr('LOAD_FILE_ID', newrec_.load_file_id, lattr_);
   Client_SYS.Add_To_Attr('SEQ_NO',       1,                    lattr_);
   Client_SYS.Add_To_Attr('STATE_DB',     '1',                  lattr_);
   Client_SYS.Add_To_Attr('FND_USER',     fnd_user_,            lattr_);
   Client_SYS.Add_To_Attr('LOG_DATE',     SYSDATE,              lattr_);
   --
   Ext_File_Log_API.New__ (linfo_,
                           lobjid_,
                           lobjversion_,
                           lattr_,
                           'DO');
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;




@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN EXT_FILE_LOAD_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);

END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_load_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'FILE_TEMPLATE_ID', newrec_.file_template_id);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_load_tab%ROWTYPE,
   newrec_ IN OUT ext_file_load_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.set_id IS NULL) THEN
      IF (Ext_Type_Param_Set_API.Check_Any_Exist (newrec_.file_type) ) THEN
         Error_SYS.Appl_General( lu_name_, 'SETEXIST: Parameter Set Exist on File Type, cannot be empty' );
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
END Check_Common___;

PROCEDURE Write_File_Data__ (
   objversion_ IN OUT VARCHAR2,
   objid_      IN     ROWID,
   lob_loc_    IN     BLOB )
IS
   blob_loc_ BLOB;
   load_file_id_ NUMBER; 
   lu_rec_ ext_file_load_tab%ROWTYPE;
BEGIN
   blob_loc_ := lob_loc_;
   lu_rec_ := Get_Object_By_Id___(objid_);
   --load_file_id_ := lu_rec_.load_file_id;
   External_File_Utility_API.Write_File_Data(lu_rec_,blob_loc_);
END Write_File_Data__;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Check_Exist_File_Load (
   load_file_id_ IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Load_Tab
      WHERE load_file_id = load_file_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist_File_Load;


PROCEDURE Insert_File_Load (
   load_file_id_         IN NUMBER,
   file_template_id_     IN VARCHAR2,
   file_direction_       IN VARCHAR2,
   file_type_            IN VARCHAR2,
   company_              IN VARCHAR2,
   file_name_            IN VARCHAR2 )
IS
   newrecx_              EXT_FILE_LOAD_TAB%ROWTYPE;
   objid_                VARCHAR2(2000);
   objversion_           VARCHAR2(2000);
   attr_                 VARCHAR2(2000);
   companyx_             VARCHAR2(20);
BEGIN
   IF (company_ IS NOT NULL) THEN
      companyx_ := company_;
      Trace_SYS.Message ('1 companyx_ : '||companyx_);
   ELSE
      User_Finance_API.Get_Default_Company ( companyx_ );
      Trace_SYS.Message ('2 companyx_ : '||companyx_);
   END IF;
   newrecx_.load_file_id     := load_file_id_;
   newrecx_.file_template_id := file_template_id_;
   newrecx_.file_direction   := file_direction_;
   newrecx_.file_type        := file_type_;
   newrecx_.load_date        := TRUNC(SYSDATE);
   newrecx_.company          := companyx_;
   newrecx_.state            := '2';
   newrecx_.file_name        := file_name_;
   newrecx_.user_id          := Fnd_Session_API.Get_Fnd_User;
   newrecx_.rowversion       := SYSDATE;
   Insert___ ( objid_,
               objversion_,
               newrecx_,
               attr_ );
END Insert_File_Load;


PROCEDURE Update_State (
   load_file_id_   IN NUMBER,
   state_          IN VARCHAR2,
   file_name_      IN VARCHAR2 DEFAULT NULL )
IS
   lattr_             VARCHAR2(3000);
   seq_no_            NUMBER;
   fnd_user_          VARCHAR2(30);
   lobjid_            VARCHAR2(30);
   lobjversion_       VARCHAR2(30);
   linfo_             VARCHAR2(2000);
BEGIN
   Trace_SYS.Message ('Update_State load_file_id_ : '||TO_CHAR(load_file_id_)||' state_ : '||state_);
   UPDATE Ext_File_Load_Tab
      SET state = state_,
          file_name = DECODE(file_name_,NULL,file_name,file_name_)
   WHERE  load_file_id = load_file_id_;
   --
   fnd_user_ := Fnd_Session_API.Get_Fnd_User;
   seq_no_   := Ext_File_Log_API.Get_Next_Seq_No (load_file_id_);
   Client_SYS.Clear_Attr(lattr_);
   Client_SYS.Add_To_Attr('LOAD_FILE_ID', load_file_id_, lattr_);
   Client_SYS.Add_To_Attr('SEQ_NO',       seq_no_,       lattr_);
   Client_SYS.Add_To_Attr('STATE_DB',     state_,        lattr_);
   Client_SYS.Add_To_Attr('FND_USER',     fnd_user_,     lattr_);
   Client_SYS.Add_To_Attr('LOG_DATE',     SYSDATE,       lattr_);
   --
   Ext_File_Log_API.New__ (linfo_,
                           lobjid_,
                           lobjversion_,
                           lattr_,
                           'DO');
END Update_State;


PROCEDURE Create_Load_Id_Param (
   load_file_id_         IN OUT NUMBER,
   parameter_string_     IN     VARCHAR2)
IS
   attr_             VARCHAR2(3000);
   rec_              Ext_File_Load_Tab%ROWTYPE;
   objid_            VARCHAR2(30);
   objversion_       VARCHAR2(30);
   newinfo_          VARCHAR2(2000);
   string_           VARCHAR2(2000);
   load_date_str_    VARCHAR2(100);
BEGIN
   Client_SYS.Clear_Attr(attr_);
   string_ := REPLACE (parameter_string_,'$',CHR(10)||'$');
   IF (Message_SYS.Find_Attribute(string_, 'COMPANY', rec_.company) IS NULL) THEN
      User_Finance_API.Get_Default_Company ( rec_.company );
   ELSE
      Message_SYS.Get_Attribute(string_,'COMPANY',   rec_.company);
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'USER_ID', rec_.user_id) IS NULL) THEN
      rec_.user_id := Fnd_Session_API.Get_Fnd_User;
   ELSE
      Message_SYS.Get_Attribute(string_,'USER_ID',   rec_.user_id);
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'LOAD_DATE', rec_.load_date) IS NULL) THEN
      rec_.load_date := TRUNC(SYSDATE);
   ELSE
      Message_SYS.Get_Attribute(string_,'LOAD_DATE', load_date_str_);
      rec_.load_date := TO_DATE( load_date_str_, Client_sys.date_format_ );
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'FILE_NAME', rec_.file_name) IS NULL) THEN
      rec_.file_name := NULL;
   ELSE
      Message_SYS.Get_Attribute(string_,'FILE_NAME', rec_.file_name);
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'FILE_TYPE', rec_.file_type) IS NULL) THEN
      rec_.file_type := NULL;
   ELSE
      Message_SYS.Get_Attribute(string_,'FILE_TYPE', rec_.file_type);
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'FILE_TEMPLATE_ID', rec_.file_template_id) IS NULL) THEN
      rec_.file_template_id := NULL;
   ELSE
      Message_SYS.Get_Attribute(string_,'FILE_TEMPLATE_ID',   rec_.file_template_id);
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'FILE_DIRECTION_DB', rec_.file_direction) IS NULL) THEN
      rec_.file_direction := '1';
   ELSE
      Message_SYS.Get_Attribute(string_,'FILE_DIRECTION_DB', rec_.file_direction);
   END IF;
   IF (Message_SYS.Find_Attribute(string_, 'SET_ID', rec_.set_id) IS NULL) THEN
      rec_.set_id := Ext_Type_Param_Set_API.Get_Default_Set_Id ( rec_.file_type );
   ELSE
      Message_SYS.Get_Attribute(string_,'SET_ID', rec_.set_id);
   END IF;
   --
   load_file_id_ := External_File_Utility_API.Get_Next_Seq;
   --
   Trace_SYS.Message('***** Create_Load_Id_Param *****');
   Trace_SYS.Message('COMPANY           : '||rec_.company);
   Trace_SYS.Message('USER_ID           : '||rec_.user_id);
   Trace_SYS.Message('FILE_TYPE         : '||rec_.file_type);
   Trace_SYS.Message('SET_ID            : '||rec_.set_id);
   Trace_SYS.Message('FILE_TEMPLATE_ID  : '||rec_.file_template_id);
   Trace_SYS.Message('FILE_DIRECTION_DB : '||rec_.file_direction);
   Trace_SYS.Message('********************************');
   --
   IF (Ext_File_Template_Dir_API.Check_Rec_Exist ( rec_.file_template_id,
                                                   rec_.file_direction ) = 'FALSE') THEN
      Error_SYS.Appl_General( lu_name_, 'NODIRECTION: No parameters specified for :P1',File_Direction_API.Decode(rec_.file_direction) );
   ELSE
      IF (Ext_File_Template_Dir_API.Get_Api_To_Call ( rec_.file_template_id,
                                                      File_Direction_API.Decode(rec_.file_direction )) IS NULL ) THEN
         Error_SYS.Appl_General( lu_name_, 'NOAPITOCALL: No api to call specified for :P1',File_Direction_API.Decode(rec_.file_direction) );
      END IF;
   END IF;
   --
   Client_SYS.Add_To_Attr('COMPANY',          rec_.company,            attr_);
   Client_SYS.Add_To_Attr('USER_ID',          rec_.user_id,            attr_);
   Client_SYS.Add_To_Attr('LOAD_DATE',        rec_.load_date,          attr_);
   Client_SYS.Add_To_Attr('FILE_NAME',        rec_.file_name,          attr_);
   Client_SYS.Add_To_Attr('FILE_TYPE',        rec_.file_type,          attr_);
   Client_SYS.Add_To_Attr('FILE_TEMPLATE_ID', rec_.file_template_id,   attr_);
   Client_SYS.Add_To_Attr('LOAD_FILE_ID',     load_file_id_,           attr_);
   Client_SYS.Add_To_Attr('PARAMETER_STRING', parameter_string_,       attr_);
   Client_SYS.Add_To_Attr('STATE_DB',         '1',                     attr_);
   Client_SYS.Add_To_Attr('FILE_DIRECTION_DB', rec_.file_direction,    attr_);
   Client_SYS.Add_To_Attr('SET_ID',           rec_.set_id,             attr_);
   --
   Ext_File_Load_API.New__ (newinfo_,
                            objid_,
                            objversion_,
                            attr_,
                            'DO');
   --
END Create_Load_Id_Param;


PROCEDURE Delete_File_Load (
   load_file_id_         IN     NUMBER )
IS
BEGIN

   DELETE
   FROM   Ext_File_Load_Tab
   WHERE  load_file_id = load_file_id_;
   Ext_File_Trans_API.Delete_File_Trans ( load_file_id_ );
   Ext_File_Log_API.Delete_File_Log ( load_file_id_ );
END Delete_File_Load;


@UncheckedAccess
FUNCTION File_Template_Used (
   file_template_id_ IN VARCHAR2, 
   file_direction_   IN VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_LOAD_TAB
      WHERE  file_template_id = file_template_id_
      AND    file_direction   = NVL(file_direction_,file_direction);
      
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END File_Template_Used;


@UncheckedAccess
FUNCTION File_Type_Used (
   file_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_LOAD_TAB
      WHERE file_type = file_type_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END File_Type_Used;


PROCEDURE Update_File_Name (
   load_file_id_         IN NUMBER,
   file_name_            IN VARCHAR2 )
IS
BEGIN
   UPDATE Ext_File_Load_Tab
      SET file_name = file_name_
   WHERE  load_file_id = load_file_id_;
END Update_File_Name;


PROCEDURE Update_Parameter_String (
   load_file_id_         IN NUMBER,
   parameter_string_     IN VARCHAR2 )
IS
BEGIN

   UPDATE Ext_File_Load_Tab
      SET parameter_string = parameter_string_
   WHERE  load_file_id = load_file_id_;
END Update_Parameter_String;


@UncheckedAccess
FUNCTION File_Type_Used_Id (
   file_type_ IN VARCHAR2 ) RETURN NUMBER
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT load_file_id
      FROM   EXT_FILE_LOAD_TAB
      WHERE file_type = file_type_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(dummy_);
   END IF;
   CLOSE exist_control;
   RETURN(NULL);
END File_Type_Used_Id;


@UncheckedAccess
FUNCTION File_Template_Used_Id (
   file_template_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT load_file_id
      FROM   EXT_FILE_LOAD_TAB
      WHERE  file_template_id = file_template_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(dummy_);
   END IF;
   CLOSE exist_control;
   RETURN(NULL);
END File_Template_Used_Id;