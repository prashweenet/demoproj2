-----------------------------------------------------------------------------
--
--  Logical unit: CtrlTypeAllowedValue
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  010917  LiSv     Created for bug #21794.
--  010922  Uma      Bug #21794. Added a parameter to Get_Allowed_Info__.
--  011018  Ovjose   Bug #25597. Double byte compability, changed substr to substr_b.
--  050926  Chajlk   LCS merge (52669).
--  060605  Iswalk   FIPL614A, added Ctrl_Type_Category and removed Combined.
--  060605  Rufelk   FIPL614A - Added ctrl_type_category_db into CTRL_TYPE_ALLOWED_VALUE.
--  060619  Rufelk   FIPL614A - Removed the Get_Allowed_Default__ Method.
--  060626  Iswalk   FIPL614A - added OutCtrlTypeCategoryDb to Get_Allowed_Info__( ).
--  061208  GaDaLK   B140017 Changes to CTRL_TYPE_ALLOWED_VALUE
--  070507  anpelk   B143263, see the Bug 56554, Added the method Get_Ctrl_Type_Category_
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

@UncheckedAccess
PROCEDURE Get_Allowed_Info__ (
   module_                    OUT VARCHAR2,
   out_ctrl_type_category_    OUT VARCHAR2,
   out_ctrl_type_category_db_ OUT VARCHAR2,
   comb_control_type_desc_    OUT VARCHAR2,
   company_                   IN  VARCHAR2,
   code_part_                 IN  VARCHAR2,
   posting_type_              IN  VARCHAR2,
   control_type_              IN  VARCHAR2,
   ctrl_type_category_        IN  VARCHAR2)
IS
   allow_prepost_det_db_      VARCHAR2(20);
BEGIN   
   Get_Allowed_Info__ (module_,
                       out_ctrl_type_category_,
                       out_ctrl_type_category_db_,
                       comb_control_type_desc_,
                       allow_prepost_det_db_,
                       company_,
                       code_part_,
                       posting_type_,
                       control_type_,
                       ctrl_type_category_);   
END Get_Allowed_Info__;

@UncheckedAccess
PROCEDURE Get_Allowed_Info__ (
   module_                    OUT VARCHAR2,
   out_ctrl_type_category_    OUT VARCHAR2,
   out_ctrl_type_category_db_ OUT VARCHAR2,
   comb_control_type_desc_    OUT VARCHAR2,
   allow_prepost_det_db_      OUT VARCHAR2,
   company_                   IN  VARCHAR2,
   code_part_                 IN  VARCHAR2,
   posting_type_              IN  VARCHAR2,
   control_type_              IN  VARCHAR2,
   ctrl_type_category_        IN  VARCHAR2)
IS
   ctrl_type_cat_ VARCHAR2(100);
   count_         NUMBER;

   CURSOR Get_Info IS
      SELECT module, control_type_desc
      FROM   CTRL_TYPE_ALLOWED_VALUE
      WHERE  company            = company_
      AND    posting_type       = posting_type_
      AND    control_type       = control_type_
      AND    code_part          = code_part_
      AND    ctrl_type_category = ctrl_type_cat_;
   CURSOR Get_Ctrl_Cat IS
      SELECT ctrl_type_category, ctrl_type_category_db
      FROM   CTRL_TYPE_ALLOWED_VALUE
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    control_type = control_type_
      AND    code_part    = code_part_;
   CURSOR Get_Count IS
      SELECT count(*)
      FROM   CTRL_TYPE_ALLOWED_VALUE
      WHERE  company      = company_
      AND    posting_type = posting_type_
      AND    control_type = control_type_
      AND    code_part    = code_part_;
BEGIN
   IF (ctrl_type_category_ IS NULL) THEN
      OPEN Get_Count;
      FETCH Get_Count INTO count_;
      IF (count_ > 1) THEN
         Error_SYS.appl_general(lu_name_, 'COUNTCOMB: Control Type :P1 is both a Control Type defined by the system and a user defined Combination Control Type. You have to choose from LOV to know if it is a System Defined or Combination Control Type.', control_type_);
         CLOSE Get_Count;
      ELSE
         CLOSE Get_Count;
      END IF;
      OPEN  Get_Ctrl_Cat;
      FETCH Get_Ctrl_Cat INTO out_ctrl_type_category_, out_ctrl_type_category_db_;
      CLOSE Get_Ctrl_Cat;
   END IF;

   ctrl_type_cat_ := out_ctrl_type_category_;

   IF (ctrl_type_cat_ IS NULL) THEN
      ctrl_type_cat_             := ctrl_type_category_;
      out_ctrl_type_category_    := ctrl_type_category_;
      out_ctrl_type_category_db_ := Ctrl_Type_Category_API.Encode(ctrl_type_category_);      
   END IF;
   allow_prepost_det_db_ := NVL(Posting_Ctrl_Posting_Type_API.Get_Allow_Prepost_Det_Db(posting_type_), 'FALSE');

   OPEN  Get_Info;
   FETCH get_Info INTO module_, comb_control_type_desc_;
   CLOSE Get_Info;
END Get_Allowed_Info__;


FUNCTION Validate_Allowed_Comb__ (
   company_            IN VARCHAR2,
   posting_type_       IN VARCHAR2,
   module_             IN VARCHAR2,
   control_type_       IN VARCHAR2,
   code_part_          IN VARCHAR2,
   ctrl_type_category_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_       NUMBER;
   --
   CURSOR validate_comb IS
      SELECT 1
      FROM   CTRL_TYPE_ALLOWED_VALUE
      WHERE  company            = company_
      AND    posting_type       = posting_type_
      AND    control_type       = control_type_
      AND    code_part          = code_part_
      AND    ctrl_type_category = ctrl_type_category_;
   --
BEGIN
   OPEN   validate_comb;
   FETCH  validate_comb INTO dummy_;

   IF (validate_comb%FOUND) THEN
      CLOSE  validate_comb;
      RETURN TRUE;
   ELSE
      CLOSE  validate_comb;
      RETURN FALSE;
   END IF;
END Validate_Allowed_Comb__;


PROCEDURE Get_Ctrl_Type_Category__ (
   ctrl_type_category_ IN OUT    VARCHAR2,
   module_             IN        VARCHAR2,
   control_type_       IN        VARCHAR2,
   combined_           IN        VARCHAR2 )
IS
   --
   no_ctrl_type_category_ EXCEPTION;
   --
   CURSOR get_ctrl_type_category IS
      SELECT ctrl_type_category
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  module      =  module_
      AND    control_type = control_type_;
   --
BEGIN

   IF (combined_ != 'COMBINATION') THEN
      OPEN get_ctrl_type_category;
      FETCH get_ctrl_type_category INTO ctrl_type_category_;
      IF (get_ctrl_type_category%NOTFOUND) THEN
         CLOSE get_ctrl_type_category;
         RAISE no_ctrl_type_category_;
      END IF;
      CLOSE get_ctrl_type_category;
   ELSE
      ctrl_type_category_ := 'ORDINARY';
   END IF;
EXCEPTION
   WHEN no_ctrl_type_category_ THEN
      Error_SYS.appl_general(lu_name_, 'NOALLDEF: Ctrl Type Category is missing for control type :P1', control_type_);
END Get_Ctrl_Type_Category__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

