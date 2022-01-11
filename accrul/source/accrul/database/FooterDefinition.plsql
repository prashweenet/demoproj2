-----------------------------------------------------------------------------
--
--  Logical unit: FooterDefinition
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  180912  Nudilk  Bug 144144, Corrected.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Delete___ (
   remrec_ IN FOOTER_DEFINITION_TAB%ROWTYPE )
IS
BEGIN
   super(remrec_);
END Check_Delete___;

@Override
@SecurityCheck Company.UserExist(newrec_.company)
PROCEDURE Check_Common___ (
   oldrec_ IN     footer_definition_tab%ROWTYPE,
   newrec_ IN OUT footer_definition_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Footer_Field_Used(
   company_          IN VARCHAR2,
   footer_field_id_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   footers_    VARCHAR2(2000);
   delim_      VARCHAR2(2);
   CURSOR get_footer IS
      SELECT *
        FROM FOOTER_DEFINITION_TAB
       WHERE company = company_
         AND (INSTR(column1_field, footer_field_id_) > 0 OR
              INSTR(column2_field, footer_field_id_) > 0 OR
              INSTR(column3_field, footer_field_id_) > 0 OR
              INSTR(column4_field, footer_field_id_) > 0 OR
              INSTR(column5_field, footer_field_id_) > 0 OR
              INSTR(column6_field, footer_field_id_) > 0 OR
              INSTR(column7_field, footer_field_id_) > 0 OR
              INSTR(column8_field, footer_field_id_) > 0 OR
              INSTR(column9_field, footer_field_id_) > 0 OR
              INSTR(column10_field, footer_field_id_) > 0);
BEGIN
   delim_ := NULL;
   FOR rec_ IN get_footer LOOP
      footers_ := footers_ || delim_ || rec_.footer_id;
      delim_ := ',';
   END LOOP;
   RETURN footers_;
END Get_Footer_Field_Used;


PROCEDURE Remove_Connected_Footer(
   company_          IN VARCHAR2,
   footer_field_id_  IN VARCHAR2 )
IS
   n_             NUMBER;
   field_length_  NUMBER;
   field_id_      VARCHAR2(100);

   oldrec_        FOOTER_DEFINITION_TAB%ROWTYPE;
   newrec_        FOOTER_DEFINITION_TAB%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(200);

   CURSOR get_footer IS
      SELECT *
        FROM footer_definition_tab
       WHERE company = company_
         AND (INSTR(',' || column1_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column2_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column3_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column4_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column5_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column6_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column7_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column8_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column9_field || ',', ',' || footer_field_id_ || ',') > 0 OR
              INSTR(',' || column10_field || ',', ',' || footer_field_id_ || ',') > 0);
BEGIN
   field_length_ := LENGTH(footer_field_id_);
   field_id_     := ',' || footer_field_id_ || ',';
   FOR rec_ IN get_footer LOOP
      oldrec_ := Lock_By_Keys___(rec_.company, rec_.footer_id);
      newrec_ := oldrec_;
      n_ := INSTR(',' || rec_.column1_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column1_field := REPLACE(',' || rec_.column1_field || ',', field_id_, ',');
         newrec_.column1_field := SUBSTR(newrec_.column1_field, 2, LENGTH(newrec_.column1_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column2_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column2_field := REPLACE(',' || rec_.column2_field || ',', field_id_, ',');
         newrec_.column2_field := SUBSTR(newrec_.column2_field, 2, LENGTH(newrec_.column2_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column3_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column3_field := REPLACE(',' || rec_.column3_field || ',', field_id_, ',');
         newrec_.column3_field := SUBSTR(newrec_.column3_field, 2, LENGTH(newrec_.column3_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column4_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column4_field := REPLACE(',' || rec_.column4_field || ',', field_id_, ',');
         newrec_.column4_field := SUBSTR(newrec_.column4_field, 2, LENGTH(newrec_.column4_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column5_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column5_field := REPLACE(',' || rec_.column5_field || ',', field_id_, ',');
         newrec_.column5_field := SUBSTR(newrec_.column5_field, 2, LENGTH(newrec_.column5_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column6_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column6_field := REPLACE(',' || rec_.column6_field || ',', field_id_, ',');
         newrec_.column6_field := SUBSTR(newrec_.column6_field, 2, LENGTH(newrec_.column6_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column7_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column7_field := REPLACE(',' || rec_.column7_field || ',', field_id_, ',');
         newrec_.column7_field := SUBSTR(newrec_.column7_field, 2, LENGTH(newrec_.column7_field) - 2);
      END IF;

      n_ := INSTR(',' || rec_.column8_field || ',', field_id_);
      IF n_ != 0 THEN
         newrec_.column8_field := REPLACE(',' || rec_.column8_field || ',', field_id_, ',');
         newrec_.column8_field := SUBSTR(newrec_.column8_field, 2, LENGTH(newrec_.column8_field) - 2);
      END IF;

      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END LOOP;
END Remove_Connected_Footer;


PROCEDURE Update_Profile (
   company_ IN VARCHAR2,
   footer_id_ IN VARCHAR2,
   text_    IN VARCHAR2 )
IS
   oldrec_     FOOTER_DEFINITION_TAB%ROWTYPE;
   newrec_     FOOTER_DEFINITION_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      ROWID;
   objversion_ VARCHAR2(2000);
   indrec_ Indicator_Rec;
BEGIN

   Client_SYS.Add_To_Attr('LAST_PROFILE', text_, attr_);

   oldrec_ := Lock_By_Keys___(company_, footer_id_);
   newrec_ := oldrec_;
   Unpack___(newrec_, indrec_, attr_);
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Update_Profile;


PROCEDURE Update_Position (
   company_ IN VARCHAR2,
   footer_id_ IN VARCHAR2,
   text_    IN VARCHAR2 )
IS
   oldrec_     FOOTER_DEFINITION_TAB%ROWTYPE;
   newrec_     FOOTER_DEFINITION_TAB%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      ROWID;
   objversion_ VARCHAR2(2000);
   indrec_ Indicator_Rec;   
BEGIN
   Client_SYS.Add_To_Attr('LAST_POSITION', text_, attr_);

   oldrec_ := Lock_By_Keys___(company_, footer_id_);
   newrec_ := oldrec_;
   Unpack___(newrec_, indrec_, attr_);
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Update_Position;

PROCEDURE Update_Free_Text (
   company_    IN VARCHAR2,
   footer_id_  IN VARCHAR2,
   free_text_  IN VARCHAR2 )
IS
   oldrec_     footer_definition_tab%ROWTYPE;
   newrec_     footer_definition_tab%ROWTYPE;
   attr_       VARCHAR2(2000);
   objid_      ROWID;
   objversion_ VARCHAR2(2000);
   indrec_     Indicator_Rec;
BEGIN
   oldrec_ := Lock_By_Keys___(company_, footer_id_);
   newrec_ := oldrec_;
   newrec_.free_text := free_text_;
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Update_Free_Text;

@UncheckedAccess
FUNCTION Get_Column_Width (
   company_   IN VARCHAR2,   
   footer_id_ IN VARCHAR2,
   column_no_ IN NUMBER ) RETURN NUMBER
   
IS
   column_width_  NUMBER;
   last_position_ VARCHAR2(2000);
BEGIN
   last_position_ := Footer_Definition_API.Get_Last_Position(company_, footer_id_);
   column_width_ := (REGEXP_SUBSTR(last_position_,'(.*?;){'||(column_no_ -1)||'}([^;]*)', 1, 1, '', 2)+1)/8;
   RETURN column_width_;
END Get_Column_Width;
