-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlAllowedComb
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960313  MijO     Created.
--  970625  Mijo     Changed in procedure Remove_Allowed_Comb.
--  970627  Slko     Converted to Foundation1 1.2.2d
--  971126  Joth     Bug # 2388 fixed.
--  980127  Slko     Converted to Foundation1 2.0.0
--  990416  Jps      Performed Template Changes. (Foundation 2.2.1)
--  001005  Prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  010611  Lisv     Changes according to new create company concept. 
--  010917  Lisv     Bug #21794 Corrected. Moved Get_Allowed_Info_ and Validate_Allowed_Comb_ to Ctrl_Type_Allowed_Value_API.
--  020128  Ovjose   Changed call in views for get descriptions, removed use of create_company_reg_api
--  060620  Rufelk   FIPL614A - Added the columns ctrl_type_category and ctrl_type_category_db into POSTING_CTRL_ALLOWED_COMB.
--  060816  Iswalk   FIPL614A - modified view and made it company specific to introduce combination control types. 
--  091208  Mawelk   Bug 86988 Fixed. Added a public method called Any_Control_Type_Exist(
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT posting_ctrl_allowed_comb_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF Client_SYS.Item_Exist('CODE_PART_DB',attr_) THEN
      newrec_.code_part := Client_SYS.Get_Item_Value('CODE_PART_DB',attr_);
      IF (newrec_.code_part IS NOT NULL) THEN
         Posting_Ctrl_All_Codepart_API.Exist_Db(newrec_.code_part);
      END IF;
   END IF;
   super(newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     posting_ctrl_allowed_comb_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_allowed_comb_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   IF Client_SYS.Item_Exist('CODE_PART_DB',attr_) THEN
      newrec_.code_part := Client_SYS.Get_Item_Value('CODE_PART_DB',attr_);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Insert_Allowed_Comb_ (
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2,
   code_part_    IN VARCHAR2 )
IS
   CURSOR check_rec IS
      SELECT 1
      FROM   POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE  posting_type = posting_type_
      AND    control_type = control_type_
      AND    module = module_
      AND    code_part = code_part_;
   dummy_ NUMBER;
BEGIN
   OPEN check_rec;
   FETCH check_rec INTO dummy_;
   IF (check_rec%NOTFOUND) THEN
      CLOSE check_rec;
      INSERT INTO POSTING_CTRL_ALLOWED_COMB_TAB
               ( POSTING_TYPE, CONTROL_TYPE, MODULE, CODE_PART, ROWVERSION )
         VALUES(posting_type_, control_type_, module_, code_part_, sysdate);
   ELSE
      CLOSE check_rec;
   END IF;
END Insert_Allowed_Comb_;


PROCEDURE Remove_Allowed_Comb_ (
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2,
   code_part_    IN VARCHAR2 )
IS
   CURSOR check_rec IS
      SELECT 1
      FROM   POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE  posting_type = posting_type_
      AND    control_type = control_type_
      AND    module = module_
      AND    code_part = code_part_;
   dummy_ NUMBER;
BEGIN
   OPEN check_rec;
   FETCH check_rec INTO dummy_;
   IF (check_rec%FOUND) THEN
      CLOSE check_rec;
      DELETE FROM POSTING_CTRL_ALLOWED_COMB_TAB
         WHERE posting_type = posting_type_
         AND   control_type = control_type_
         AND   module = module_
         AND   code_part = decode(code_part_, NULL, code_part, code_part_);
   ELSE
      CLOSE check_rec;
   END IF;
END Remove_Allowed_Comb_;


PROCEDURE Check_Allowed_For_Ctrl_Type_ (
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2 )
IS
   dummy_    NUMBER;
   CURSOR Check_Allowed IS
      SELECT 1
      FROM POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE Posting_Type = posting_type_
      AND Control_Type = control_type_;
BEGIN
   OPEN Check_Allowed;
   FETCH Check_Allowed INTO dummy_;
   IF (Check_Allowed%NOTFOUND) THEN
      Error_SYS.Record_General(lu_name_, 'CTRLNOTALLOW: Control Type :P1 is not allowed for Posting Type :P2', control_type_, posting_type_ );
   END IF;
   CLOSE Check_Allowed;
END Check_Allowed_For_Ctrl_Type_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Any_Posting_Type_Exist (
   posting_type_      IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_posting IS
      SELECT 1
      FROM   POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE  posting_type = posting_type_ ;

BEGIN
   OPEN exist_posting;
   FETCH exist_posting INTO dummy_;
   IF (exist_posting%FOUND) THEN
      CLOSE exist_posting;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_posting;
   RETURN 'FALSE';
END Any_Posting_Type_Exist;


PROCEDURE Insert_Control_Type (
   posting_type_ IN VARCHAR2,
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2,
   code_part_    IN VARCHAR2,
   row_version_  IN DATE )
IS

   CURSOR check_rec IS
      SELECT 1
      FROM   POSTING_CTRL_ALLOWED_COMB_TAB
      WHERE  posting_type = posting_type_
      AND    control_type = control_type_
      AND    module       = module_
      AND    code_part    = code_part_;
   dummy_ NUMBER;

BEGIN
   OPEN  check_rec;
   FETCH check_rec INTO dummy_;
   IF (check_rec%NOTFOUND) THEN
      CLOSE check_rec;
      INSERT INTO POSTING_CTRL_ALLOWED_COMB_TAB
               ( POSTING_TYPE, CONTROL_TYPE, MODULE, CODE_PART, ROWVERSION )
         VALUES(posting_type_, control_type_, module_, code_part_, sysdate );
   ELSE
      CLOSE check_rec;
   END IF;

END Insert_Control_Type;



