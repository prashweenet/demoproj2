-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTypeRecColumn
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  040329  Gepelk  2004 SP1 Merge.
--  100603  Jofise  Bug Id 90722 fixed. Updated Get_Next_Column. 
--  100807  Mawelk  Bug 92305 Fixed. Changes to  Insert___()
--  110528  THPELK  EASTONE-21645 Added missing General_SYS and PRAGMA.
--  111116  Swralk  SFI-742, Removed General_SYS.Init statement from FUNCTION Get_Destination_Column.
--  121012  Kagalk  Bug 105774, Modified to register translatable attributes as system defined attributes
--  130531  Hecolk  Bug 110381, Modified to set correct data_type values
--  131030  PRatlk  PBFI-1918, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Get_Correct_Data_Type___ (
   dest_col_data_type_ IN OUT VARCHAR2,
   destination_column_ IN VARCHAR2 )
IS
   dest_col_type_   VARCHAR2(1); 
BEGIN
   IF (dest_col_data_type_ = Exty_Data_Type_API.DB_STRING) THEN
      dest_col_type_ := substr(destination_column_, 1, 1);
      IF dest_col_type_ = 'N' THEN
         dest_col_data_type_ := Exty_Data_Type_API.DB_NUMBER;   
      ELSIF dest_col_type_ = 'D' THEN    
         dest_col_data_type_ := Exty_Data_Type_API.DB_DATE;
      END IF;
   END IF;   
END Get_Correct_Data_Type___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'MANDATORY', 'FALSE', attr_ );
   Client_SYS.Add_To_Attr( 'DATA_TYPE', Exty_Data_Type_API.Decode ('1'), attr_ );
END Prepare_Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN EXT_FILE_TYPE_REC_COLUMN_TAB%ROWTYPE )
IS
BEGIN
   IF (Ext_File_Type_API.Get_System_Defined (remrec_.file_type) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'SYSDEFMOD: Is is not allowed to modify a system defined file type !');
   END IF;
   super(objid_, remrec_);
END Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_file_type_rec_column_tab%ROWTYPE,
   newrec_ IN OUT ext_file_type_rec_column_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (Ext_File_Type_API.Get_System_Defined (newrec_.file_type) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'SYSDEFMOD: Is is not allowed to modify a system defined file type !');
   END IF;
END Check_Common___;



@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_type_rec_column_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   Client_SYS.Add_To_Attr( 'DESTINATION_COLUMN', newrec_.destination_column, attr_ );
   IF (newrec_.destination_column IS NULL) THEN
      Ext_File_Type_Rec_Column_API.Get_Next_Column (newrec_.file_type,
                                                    newrec_.record_type_id,
                                                    Exty_Data_Type_API.Decode (newrec_.data_type),
                                                    newrec_.destination_column);
   END IF;
   Check_Destination ( newrec_.file_type,
                       newrec_.record_type_id,
                       newrec_.destination_column,
                       newrec_.column_id );
   Get_Correct_Data_Type___ (newrec_.data_type, newrec_.destination_column);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_file_type_rec_column_tab%ROWTYPE,
   newrec_ IN OUT ext_file_type_rec_column_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.destination_column IS NOT NULL) THEN
      Check_Destination ( newrec_.file_type,
                          newrec_.record_type_id,
                          newrec_.destination_column,
                          newrec_.column_id );
      Get_Correct_Data_Type___ (newrec_.data_type, newrec_.destination_column);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_        IN EXT_FILE_TYPE_REC_COLUMN_TAB%ROWTYPE)
IS
   rec_              EXT_FILE_TYPE_REC_COLUMN_TAB%ROWTYPE;
BEGIN

   rec_ := newrec_;
   IF (NOT Check_Exist___(rec_.file_type, rec_.record_type_id, rec_.column_id)) THEN
      INSERT INTO EXT_FILE_TYPE_REC_COLUMN_TAB (
         file_type,
         record_type_id,
         column_id,
         mandatory,
         destination_column,
         data_type,
         description,
         rowversion)
      VALUES (
         newrec_.file_type,
         newrec_.record_type_id,
         newrec_.column_id,
         newrec_.mandatory,
         newrec_.destination_column,
         newrec_.data_type,
         newrec_.description,
         newrec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                           lu_name_,
                                                           rec_.file_type || '^' || rec_.record_type_id || '^' || rec_.column_id,
                                                           rec_.description);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                           lu_name_,
                                                           rec_.file_type || '^' || rec_.record_type_id || '^' || rec_.column_id,
                                                           rec_.description);
      UPDATE EXT_FILE_TYPE_REC_COLUMN_TAB
         SET description = rec_.description
      WHERE  file_type      = rec_.file_type
        AND  record_type_id = rec_.record_type_id
        AND  column_id      = rec_.column_id;
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Column_Id (
   file_type_          IN VARCHAR2,
   destination_column_ IN VARCHAR2,
   record_type_id_     IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TYPE_REC_COLUMN_TAB.column_id%TYPE;
   CURSOR get_attr IS
      SELECT column_id
      FROM EXT_FILE_TYPE_REC_COLUMN_TAB
      WHERE file_type          = file_type_
      AND   destination_column = destination_column_
      AND   record_type_id     = record_type_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Column_Id;




@UncheckedAccess
FUNCTION Get_Data_Type_Db (
   file_type_      IN VARCHAR2,
   column_id_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TYPE_REC_COLUMN_TAB.data_type%TYPE;
   CURSOR get_attr IS
      SELECT data_type
      FROM EXT_FILE_TYPE_REC_COLUMN_TAB
      WHERE file_type = file_type_
      AND   column_id = column_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Data_Type_Db;









PROCEDURE Check_Destination (
   file_type_          IN VARCHAR2,
   record_type_id_     IN VARCHAR2,
   destination_column_ IN VARCHAR2,
   column_id_          IN VARCHAR2 ) 
IS
   column_idx_            VARCHAR2(30);
   CURSOR exist_control IS
      SELECT column_id
      FROM   EXT_FILE_TYPE_REC_COLUMN_TAB
      WHERE file_type          = file_type_
      AND   record_type_id     = record_type_id_
      AND   destination_column = destination_column_
      AND   column_id          != column_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO column_idx_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      Error_SYS.Appl_General( lu_name_, 'DESTALREX: Destination Column :P1 Already Exists for Column :P2',destination_column_,column_idx_ );
   END IF;
   CLOSE exist_control;
   IF (substr(destination_column_,1,1) NOT IN ('C','N','D')) THEN
      Error_SYS.Appl_General( lu_name_, 'DESTNOTOK1: Destination Column :P1 Have To Start With C N or D',destination_column_ );
   END IF;
   IF (NOT Database_SYS.Column_Exist ('EXT_FILE_TRANS_TAB',
                                      destination_column_)) THEN
      Error_SYS.Appl_General( lu_name_, 'DESTNOTOK2: Destination Column :P1 Is Illegal',destination_column_ );
   END IF;
END Check_Destination;


@UncheckedAccess
FUNCTION Get_Destination_Column (
   file_type_      IN VARCHAR2,
   record_type_id_ IN VARCHAR2,
   column_id_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_FILE_TYPE_REC_COLUMN_TAB.destination_column%TYPE;
   CURSOR get_attr IS
      SELECT destination_column
      FROM EXT_FILE_TYPE_REC_COLUMN_TAB
      WHERE file_type = file_type_
      AND   record_type_id = record_type_id_
      AND   column_id = column_id_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Destination_Column;




PROCEDURE Remove_File_Type (
   file_type_      IN VARCHAR2 ) 
IS
BEGIN
   DELETE
   FROM EXT_FILE_TYPE_REC_COLUMN_TAB
   WHERE file_type      = file_type_;
END Remove_File_Type;


PROCEDURE Get_Next_Column (
   file_type_      IN  VARCHAR2,
   record_type_id_ IN  VARCHAR2,
   data_type_      IN  VARCHAR2,
   column_name_    OUT VARCHAR2 )
IS
   temp_               NUMBER;
   max_column_         NUMBER;
   dummy_              NUMBER;
   data_type_db_       VARCHAR2(10);
   CURSOR get_attr IS
      SELECT 1
      FROM   ext_file_type_rec_column_tab
      WHERE  file_type                    = file_type_
      AND    record_type_id               = record_type_id_
      AND    data_type                    = data_type_db_
      AND    SUBSTR(destination_column,2) = temp_;
BEGIN
   data_type_db_  := Exty_Data_Type_API.Encode ( data_type_ );
   IF (data_type_db_ = '1' OR data_type_db_ = '2' ) THEN
      max_column_ := 99;
   ELSE
      max_column_ := 19;
   END IF;
   temp_ := 1;
   LOOP
      IF (temp_ = max_column_) THEN
         EXIT;
      END IF;
      OPEN get_attr;
      FETCH get_attr INTO dummy_;
      IF (get_attr%NOTFOUND) THEN
         IF (data_type_db_ = '1') THEN
            column_name_ := 'C'||temp_;
         ELSIF (data_type_db_ = '2') THEN
            column_name_ := 'N'||temp_;
         ELSE
            column_name_ := 'D'||temp_;
         END IF;
         EXIT;
      END IF;
      temp_ := temp_ + 1;
      CLOSE get_attr;
   END LOOP;
END Get_Next_Column;


FUNCTION Check_Column_Exist (
   file_type_      IN VARCHAR2,
   record_type_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_FILE_TYPE_REC_COLUMN_TAB
      WHERE file_type      = file_type_
      AND   record_type_id = record_type_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Column_Exist;


FUNCTION Check_Exist_Str (
   file_type_      IN VARCHAR2,
   record_type_id_ IN VARCHAR2,
   column_id_      IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___ (file_type_, record_type_id_, column_id_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist_Str;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Type_Rec_Column_Tab%ROWTYPE )
IS
   newrecx_       Ext_File_Type_Rec_Column_Tab%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   newrecx_.rowkey := NULL;
   Insert___ ( objid_,
               objversion_,
               newrecx_,
               attr_ );
END Insert_Record;


