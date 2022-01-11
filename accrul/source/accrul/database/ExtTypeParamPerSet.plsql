-----------------------------------------------------------------------------
--
--  Logical unit: ExtTypeParamPerSet
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  020920  PPer   Created
--  040329  Gepelk 2004 SP1 Merge.
--  100801  Mawelk Bug 92155 Fixed. added a new method Exist_Valid_Set_Id()
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'SHOW_AT_LOAD',      'TRUE',  attr_);
   Client_SYS.Add_To_Attr( 'INPUTABLE_AT_LOAD', 'TRUE',  attr_);
   Client_SYS.Add_To_Attr( 'MANDATORY_PARAM',   'FALSE', attr_);
END Prepare_Insert___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

FUNCTION Check_Detail_Exist (
   file_type_ IN VARCHAR2,
   set_id_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_TYPE_PARAM_PER_SET_TAB
      WHERE  file_type = file_type_
      AND    set_id    = set_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Detail_Exist;


FUNCTION Check_Param_Id_Exist (
   file_type_     IN VARCHAR2,
   set_id_        IN VARCHAR2,
   param_id_      IN VARCHAR2,
   default_value_ IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
IS
   dummy_            NUMBER;
   default_valuex_   VARCHAR2(20);
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_Type_Param_Per_Set2
      WHERE  file_type     = file_type_
      AND    set_id        = set_id_
      AND    param_id      = param_id_;
   CURSOR value_control IS
      SELECT 1
      FROM   Ext_Type_Param_Per_Set2
      WHERE  file_type     = file_type_
      AND    set_id        = set_id_
      AND    param_id      = param_id_
      AND    default_value = NVL(default_valuex_,default_value);
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      IF (default_value_ IS NULL) THEN
         RETURN('TRUE');
      ELSE
         default_valuex_ := default_value_;
         OPEN value_control;
         FETCH value_control INTO dummy_;
         IF (value_control%FOUND) THEN
            CLOSE value_control;
            RETURN('TRUE');
         ELSE
            CLOSE value_control;
            IF (param_id_ = 'FILE_DIRECTION_DB') THEN
               IF (default_value_ = '1') THEN
                  default_valuex_ := '2';
               ELSE
                  default_valuex_ := '1';
               END IF;
               OPEN value_control;
               FETCH value_control INTO dummy_;
               IF (value_control%FOUND) THEN
                  CLOSE value_control;
                  RETURN('FALSE');
               ELSE
                  CLOSE value_control;
                  RETURN('TRUE');
               END IF;
            ELSE
               RETURN('FALSE');
            END IF;
         END IF;
      END IF;
   ELSE
      CLOSE exist_control;
      IF (default_value_ IS NULL) THEN
         RETURN('FALSE');
      ELSE
         RETURN('TRUE');
      END IF;
   END IF;
END Check_Param_Id_Exist;


PROCEDURE Copy_Param_Set (
   file_type_ IN VARCHAR2,
   set_id_    IN VARCHAR2 )
IS
   newrecx_                   EXT_TYPE_PARAM_PER_SET_TAB%ROWTYPE;
   objid_                     VARCHAR2(2000);
   objversion_                VARCHAR2(2000);
   attr_                      VARCHAR2(2000);
   CURSOR GetSet IS
      SELECT param_no
      FROM   Ext_File_Type_Param_Tab
      WHERE  file_type = file_type_;
BEGIN
   IF (Check_Detail_Exist ( file_type_,
                            set_id_ ) = 'TRUE') THEN
      Error_SYS.Appl_General( lu_name_, 'FASEROWS: Parameter set already contain details, copy is not allowed' );
   ELSE
      FOR rec_ IN GetSet LOOP
         Client_SYS.Clear_Attr(attr_);
         newrecx_.file_type         := file_type_;
         newrecx_.param_no          := rec_.param_no;
         newrecx_.set_id            := set_id_;
         newrecx_.default_value     := NULL;
         newrecx_.mandatory_param   := 'FALSE';
         newrecx_.show_at_load      := 'TRUE';
         newrecx_.inputable_at_load := 'TRUE';
         newrecx_.rowversion        := SYSDATE;
         newrecx_.rowkey            := NULL;
         Insert___ ( objid_,
                     objversion_,
                     newrecx_,
                     attr_ );
      END LOOP;
   END IF;
END Copy_Param_Set;


PROCEDURE Insert_Record (
   newrec_     IN EXT_TYPE_PARAM_PER_SET_TAB%ROWTYPE )
IS
   newrecx_       EXT_TYPE_PARAM_PER_SET_TAB%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   IF (NOT Check_Exist___(newrecx_.file_type,
                          newrecx_.param_no,
                          newrecx_.set_id)) THEN
      newrecx_.rowkey := NULL;                    
      Insert___ ( objid_,
                  objversion_,
                  newrecx_,
                  attr_ );
   END IF;
END Insert_Record;


PROCEDURE Remove_File_Type (
   file_type_  IN VARCHAR2 )
IS
BEGIN
   DELETE
   FROM EXT_TYPE_PARAM_PER_SET_TAB
   WHERE file_type = file_type_;
END Remove_File_Type;


PROCEDURE Remove_Param_Set (
   file_type_  IN VARCHAR2,
   set_id_     IN VARCHAR2 )
IS
BEGIN
   DELETE
   FROM EXT_TYPE_PARAM_PER_SET_TAB
   WHERE file_type = file_type_
   AND   set_id    = set_id_;
END Remove_Param_Set;


PROCEDURE Exist_Valid_Set_Id (
     file_type_    IN VARCHAR2,
     set_id_       IN VARCHAR2 )
IS
  dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   EXT_TYPE_PARAM_PER_SET_TAB
      WHERE  file_type = file_type_
      AND    set_id    = set_id_ ; 
      
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%NOTFOUND) THEN
      CLOSE exist_control;
      Error_Sys.Record_General('ExtTypeParamPerSet','EXTVALSETID: :P1 parameter set ID is not connected to  :P2 file type.',set_id_, file_type_ );
   END IF;
   CLOSE exist_control; 
END Exist_Valid_Set_Id;


