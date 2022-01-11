-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileSeparator
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021023  PPerse  Created
--  311023  Clstlk  Bug 105860,Corrected in Insert___,Update___ and delete___.
--  131023  PRatlk  CAHOOK-2837, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     EXT_FILE_SEPARATOR_TAB%ROWTYPE,
   newrec_     IN OUT EXT_FILE_SEPARATOR_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN BOOLEAN DEFAULT FALSE )
IS
BEGIN
   IF (oldrec_.separator = newrec_.separator) AND (oldrec_.separator_ascii != newrec_.separator_ascii) THEN
      newrec_.separator := chr(newrec_.separator_ascii);
      Client_SYS.Set_Item_Value('SEPARATOR', newrec_.separator, attr_);
   END IF;
   IF (oldrec_.separator_ascii = newrec_.separator_ascii) AND (oldrec_.separator != newrec_.separator) THEN
      newrec_.separator_ascii := ascii(newrec_.separator);
      Client_SYS.Set_Item_Value('SEPARATOR_ASCII', newrec_.separator_ascii, attr_);
   END IF;
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_file_separator_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_             VARCHAR2(30);
   value_            VARCHAR2(4000);
BEGIN
   IF (newrec_.separator IS NULL) AND (newrec_.separator_ascii IS NOT NULL) THEN
      newrec_.separator := chr(newrec_.separator_ascii);
   END IF;
   IF (newrec_.separator_ascii IS NULL) AND (newrec_.separator IS NOT NULL) THEN
      IF (LENGTH(newrec_.separator) = 1) THEN
         newrec_.separator_ascii := ascii(newrec_.separator);
      ELSE
         newrec_.separator_ascii := NULL;
      END IF;
   END IF;
   super(newrec_, indrec_, attr_);
   IF (newrec_.separator IS NULL) AND (newrec_.separator_ascii IS NOT NULL) THEN
      Client_SYS.Set_Item_Value('SEPARATOR', newrec_.separator, attr_);
   END IF;
   IF (newrec_.separator_ascii IS NULL) AND (newrec_.separator IS NOT NULL) THEN
      IF (LENGTH(newrec_.separator) = 1) THEN
         Client_SYS.Set_Item_Value('SEPARATOR_ASCII', newrec_.separator_ascii, attr_);
      ELSE
         newrec_.separator_ascii := NULL;
         Client_SYS.Set_Item_Value('SEPARATOR_ASCII', '', attr_);
      END IF;
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_file_separator_tab%ROWTYPE,
   newrec_ IN OUT ext_file_separator_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_             VARCHAR2(30);
   value_            VARCHAR2(4000);
BEGIN
   IF (newrec_.separator IS NOT NULL) THEN
      IF (LENGTH(newrec_.separator) = 1) THEN
         newrec_.separator_ascii := ascii(newrec_.separator);
      ELSE
         newrec_.separator_ascii := NULL;
      END IF;
   END IF;
   IF ((newrec_.separator IS NULL) AND (newrec_.separator_ascii IS NOT NULL)) THEN
      newrec_.separator := chr(newrec_.separator_ascii);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   IF (newrec_.separator IS NOT NULL) THEN
      IF (LENGTH(newrec_.separator) = 1) THEN
         Client_SYS.Set_Item_Value('SEPARATOR_ASCII', ascii(newrec_.separator), attr_);
      ELSE
         Client_SYS.Set_Item_Value('SEPARATOR_ASCII', '', attr_);
      END IF;
      Client_SYS.Set_Item_Value('SEPARATOR', newrec_.separator, attr_);
   END IF;
   IF ((newrec_.separator IS NULL) AND (newrec_.separator_ascii IS NOT NULL)) THEN
      Client_SYS.Set_Item_Value('SEPARATOR', chr(newrec_.separator_ascii), attr_);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   newrec_        IN EXT_FILE_SEPARATOR_TAB%ROWTYPE)
IS
   rec_              EXT_FILE_SEPARATOR_TAB%ROWTYPE;
BEGIN
   rec_ := newrec_;
   IF (NOT Check_Exist___(rec_.separator_id)) THEN
      INSERT INTO ext_file_separator_tab (
         separator_id,
         description,
         separator,
         separator_ascii,
         rowversion)
      VALUES (
         newrec_.separator_id,
         newrec_.description,
         newrec_.separator,
         newrec_.separator_ascii,
         newrec_.rowversion);
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.separator_id,
                                                          rec_.description);
   ELSE
      Basic_Data_Translation_API.Insert_Prog_Translation( 'ACCRUL',
                                                          lu_name_,
                                                          rec_.separator_id,
                                                          rec_.description);
      UPDATE EXT_FILE_SEPARATOR_TAB
         SET description = rec_.description
      WHERE  separator_id = rec_.separator_id;
   END IF;
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

