-----------------------------------------------------------------------------
--
--  Logical unit: TextType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960322  xxxx  Base Table to Logical Unit Generator 1.0A
--  960410  PiBu  Adding  abstract Company column for client-side User -
--                Profile Solutions
--  970718  SLKO  Converted to Foundation 1.2.2d
--  990707  HIMM  Modified withrespect to template change
--  151008  chiblk  STRFI-200, New__ changed to New___ in Insert_Values
--  151103  THPELK STRFI-307,New_Text_Type().
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT translation_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (Client_SYS.Item_Exist('COMPANY',attr_)) THEN
      Error_SYS.Item_Insert(lu_name_, 'COMPANY');
   END IF;
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     translation_type_tab%ROWTYPE,
   newrec_ IN OUT translation_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF (Client_SYS.Item_Exist('COMPANY',attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'COMPANY');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'TEXT_TYPE', newrec_.text_type);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Get_Desc_View (
   text_type_        IN      VARCHAR2,
   description_      IN OUT  VARCHAR2,
   view_name_        IN OUT  VARCHAR2 )
IS
--
-- desc_   VARCHAR2(100);
-- view_   VARCHAR2(100);
--
   CURSOR get_text is
      SELECT  description, view_name
      FROM    TRANSLATION_TYPE_TAB
      WHERE   text_type =  text_type_ ;
BEGIN
   OPEN get_text;
   FETCH get_text into  description_ , view_name_ ;
   IF ( get_text%NOTFOUND ) THEN
      CLOSE get_text;
      description_ := null;
      view_name_ := null;
   END IF;
END Get_Desc_View;


