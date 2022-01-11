-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlControlType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960313  Mijo   Created.
--  970418  Mijo   Added procedure Get_Control_Type_Info__
--  970627  Slko   Converted to Foundation 1.2.2d
--  970925  Joth   Bug # 97-0066 fixed
--  971104  Andj   Reintroduced Bug-fix # 97-0059.
--  980127  Slko   Converted to Foundation1 2.0.0
--  990416  Jps    Performed Template Changes.(Foundation 2.2.1)
--  000912  Himu   Added General_SYS.Init_Method
--  010111  Hdahse Bug #18988 - missing call to Pres_Object_Util_Api. Added call in Insert_Control_Type_
--                              to Pres_Object_Util_Api.
--  010116  Andj   Additional mods. for Bug #18988.
--  010611  Lisv   Changes according to new create company concept.
--  010710  Sumalk Bug 23170 Fixed.(The lengh of Description field in View Comments is set to 100)
--  010713  Sumalk Bug 22932 Fixed. Removed dynamic sql and added Execute Immediate.
--  010917  Lisv   Bug #21794 Corrected. Moved Get_Allowed_Default_ to Ctrl_Type_Allowed_Value_API.
--  020124  Kagalk IID 10997 Modified Get_Control_Type_Desc_ for state codes
--  020128  Ovjose Changed call in views for get descriptions, removed use of create_company_reg_api
--  020213  Lisv   IID 10120 Modified Get_Control_Type_Desc_ for type1099.
--  020605  Ovjose Bug #30435 Corrected. Insert_Control_Type_ now handles update
--  03012   Machlk IID ARFI124N. Moved Income Type to ENTERP.
--  030206  Mgutse Bug 93742 corrected. Changed view TYPE1099 to TYPE1099_LOV.
--  030225  Mgutse Bug 94305. New key in LU IncomeType.
--  030305  Mgutse Bug 94305. New key in LU Type1099.
--  041223  Umdolk LCS Merge (47895)
--  050926  Chajlk LCS merge (52669)
--  060605  iswalk FIPL614A - added ctrl_type_category.
--  060605  Rufelk FIPL614A - Modified ALLOWED_CONTROL_TYPE to select only Ordinary Control Types.
--  060619  Iswalk FIPL614A - Replaced allowed_default_ with ctrl_type_category_.
--  060619  Iswalk FIPL614A - Introduce temporary solution to interface with allowed defaults till other products fix.
--  060626  Iswalk FIPL614A - Changed Get_Allowed_Info( ).
--  060626  Rufelk FIPL614A - Modified Get_Control_Type_Value_Desc().
--  060824  Iswalk FIPL614A - removed temporary solution to introduce ctrl_type_category instead of allowed_default.
--  061108  Iswalk FIPL614A and FIPL609A - Disallow invalid control type categories to be entered.
--  061208  GaDaLK B140017 Changes to Get_Description
--  061228  GaDaLK B140017 Changes to ALLOWED_CONTROL_TYPE cartesian join with company_finance
--  080811  AsHelk Bug 75985, Corrected.
--  080828  AsHelk Bug 75985, Added Function Get_Type1099_Ctrl_Type_Val.
--  120214  Hawalk SFI-2334, Merged bug 100135, Modified Get_Control_Type_Value_Desc__() and Get_Control_Type_Desc_() with the addition
--  120214         of inpar3_ and valid_from_ respectively (to support report codes from project reporting) to the parameter list (75 
--  120214         correction done by Kanslk).
--  120215  Hawalk SFI-2334, Merged bug 100135, Inside Get_Control_Type_Desc_(), included the check for 'REPORT_COST_API', to rid 
--  120215         Get_Control_Type_Value_Desc__() of package name checks. This part of the correction differs from 75, where the latter
--  120215         method contains package name checks.
--  120315  Umdolk EASTRTM-3085, Checked the use translations check box to enable translations for control types.
--   121204   Maaylk PEPA-183, Removed global variables
--  130902  THPELK  Bug 112154, Corrected QA script cleanup - Financials  Type Cursor usage in procedure / function
--  130930  MEALLK  MASU-60, modified code in Get_Control_Type_Desc_ to return the description of elimination ID in GROCON
--  131108  Umdolk  PBFI-2078, Refactoring
--  141219  PRatlk  PRFI-4139, Discription not displayed when using Elimination Rule.
--  200325  Chwtlk  Bug 152941, Introduced new function Get_Control_Type_Desc_.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN POSTING_CTRL_CONTROL_TYPE_TAB%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);

   Basic_Data_Translation_API.Remove_Basic_Data_Translation(remrec_.module, remrec_.lu, 'PostingCtrlControlType'||'^'||remrec_.control_type);
END Delete___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Get_Extern_Lov__ (
   lov_            OUT VARCHAR2,
   pkg_            OUT VARCHAR2,
   package_name_   IN  VARCHAR2,
   procedure_name_ IN  VARCHAR2,
   inpar1_         IN  VARCHAR2 )
IS
   --
   block_      VARCHAR2(300);
   outpar1_    VARCHAR2(500);
   outpar2_    VARCHAR2(500);
   bindinpar1_ VARCHAR2(100) := inpar1_;
BEGIN

   Assert_SYS.Assert_Is_Package_Method(package_name_,procedure_name_);
   block_ := 'BEGIN ' || package_name_ || '.' || procedure_name_ || '( ';
   block_ := block_ || ':output1_';
   block_ := block_ || ',:output2_';
   block_ := block_ || ', :bindinpar1_';
   block_ := block_ || ' ); END;';

   @ApproveDynamicStatement(2005-11-11,shsalk)
   EXECUTE IMMEDIATE block_ using IN OUT outpar1_,IN OUT outpar2_,IN OUT bindinpar1_;

   lov_ := outpar1_;
   pkg_ := outpar2_;
END Get_Extern_Lov__;


PROCEDURE Get_Control_Type_Value_Desc__ (
   description_ IN OUT VARCHAR2,
   pkg_name_    IN     VARCHAR2,
   proc_name_   IN     VARCHAR2,
   inpar1_      IN     VARCHAR2,
   inpar2_      IN     VARCHAR2,
   inpar3_      IN     DATE DEFAULT NULL )
IS
   --
   block_      VARCHAR2(300);
   outpar_     VARCHAR2(32000);
   bindinpar1_ VARCHAR2(100) := inpar1_;
   bindinpar2_ VARCHAR2(100) := inpar2_;
   bindinpar3_ DATE          := inpar3_;
BEGIN

   Assert_SYS.Assert_Is_Package_Method(pkg_name_,proc_name_);
   block_ := 'BEGIN ' || pkg_name_ || '.' || proc_name_ || '( ';
   block_ := block_ || ':output_';
   block_ := block_ || ', :bindinpar1_, :bindinpar2_';

   IF (inpar3_ IS NOT NULL) THEN
      block_ := block_ || ', :bindinpar3_';        
   END IF;

   block_ := block_ || ' ); END;';

   IF (inpar3_ IS NULL) THEN
      @ApproveDynamicStatement(2005-11-11,shsalk)
      EXECUTE IMMEDIATE block_ using  IN OUT outpar_ ,bindinpar1_, bindinpar2_;
   ELSE
      @ApproveDynamicStatement(2012-02-14,hawalk)
      EXECUTE IMMEDIATE block_ using  IN OUT outpar_ ,bindinpar1_, bindinpar2_, bindinpar3_;
   END IF;

   description_ := outpar_;
END Get_Control_Type_Value_Desc__;


PROCEDURE Get_Control_Type_Info__ (
   control_type_value_desc_   IN OUT VARCHAR2,
   view_name_                 IN OUT VARCHAR2,
   pkg_name_                  IN OUT VARCHAR2,
   ctrl_type_category_        IN OUT VARCHAR2,
   control_type_desc_         OUT    VARCHAR2,
   company_                   IN     VARCHAR2,
   control_type_              IN     VARCHAR2,
   control_type_value_        IN     VARCHAR2,
   module_                    IN     VARCHAR2 )
IS
BEGIN
   Get_Control_Type_Attri_(control_type_desc_, 
                           ctrl_type_category_, 
                           view_name_,
                           pkg_name_, 
                           control_type_, 
                           module_);
END Get_Control_Type_Info__;

FUNCTION Get_View__(
   control_type_       IN  VARCHAR2,
   module_             IN  VARCHAR2,
   company_            IN  VARCHAR2) RETURN VARCHAR2
IS
   dummy_description_         VARCHAR2(1000);
   dummy_ctrl_type_category_  VARCHAR2(1000);
   dummy_pkg_name_            VARCHAR2(1000);
   view_name_                 VARCHAR2(1000);
BEGIN
   Get_Control_Type_Attri_(dummy_description_, 
                           dummy_ctrl_type_category_, 
                           view_name_,
                           dummy_pkg_name_, 
                           control_type_, 
                           module_,
                           company_);
   RETURN view_name_;
END Get_View__;

FUNCTION Get_Pkg_Name__ (
   control_type_       IN  VARCHAR2,
   module_             IN  VARCHAR2,
   company_            IN  VARCHAR2) RETURN VARCHAR2
IS
   dummy_description_         VARCHAR2(1000);
   dummy_ctrl_type_category_  VARCHAR2(1000);
   pkg_name_                  VARCHAR2(1000);
   dummy_view_name_           VARCHAR2(1000);
BEGIN
   Get_Control_Type_Attri_(dummy_description_, 
                           dummy_ctrl_type_category_, 
                           dummy_view_name_,
                           pkg_name_, 
                           control_type_, 
                           module_,
                           company_);
   RETURN pkg_name_;
END Get_Pkg_Name__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

@UncheckedAccess
PROCEDURE Get_Control_Type_Attri_ (
   description_        OUT VARCHAR2,
   ctrl_type_category_ OUT VARCHAR2,
   view_name_          OUT VARCHAR2,
   pkg_name_           OUT VARCHAR2,
   control_type_       IN  VARCHAR2,
   module_             IN  VARCHAR2,
   company_            IN VARCHAR2 DEFAULT NULL )
IS
   no_value      EXCEPTION;
   package_      VARCHAR2(30);
   get_lov_      VARCHAR2(30) := 'Get_Lov';
   lov_          VARCHAR2(100);

   CURSOR get_information IS
    SELECT ctrl_type_category, view_name, pkg_name
    FROM   posting_ctrl_control_type_tab
    WHERE  control_type = control_type_
    AND    module       = module_;
BEGIN

   OPEN get_information;
   FETCH get_information INTO ctrl_type_category_, view_name_, pkg_name_;
   IF (get_information%NOTFOUND) THEN
      RAISE no_value;
   END IF;
   CLOSE get_information;

   description_ := Get_Description(control_type_, module_, company_);

   IF (module_ = 'MPC4') THEN
      package_ := module_||'_Am_API';
      Get_Extern_Lov__( lov_, pkg_name_, package_, get_lov_, control_type_ );
      view_name_ := lov_;
   ELSIF (module_ = 'SYS4MS') THEN
      package_ := module_||'_Am_API';
      Get_Extern_Lov__( lov_, pkg_name_, package_, get_lov_, control_type_ );
      view_name_ := lov_;
   ELSIF (module_ = 'INVORS') THEN
      package_ := module_||'_Am_API';
      Get_Extern_Lov__( lov_, pkg_name_, package_, get_lov_, control_type_ );
      view_name_ := lov_;
   END IF;
EXCEPTION
   WHEN no_value THEN
      CLOSE get_information;
       Error_SYS.Record_General(lu_name_, 'NOINFO: Values for :P1 is missing', control_type_);
END Get_Control_Type_Attri_;


@UncheckedAccess
FUNCTION Get_Control_Type_Desc_ (
   company_             IN     VARCHAR2,
   control_type_        IN     VARCHAR2,
   control_type_value_  IN     VARCHAR2,
   view_name_           IN     VARCHAR2,
   pkg_name_            IN     VARCHAR2,
   module_              IN     VARCHAR2,
   valid_from_          IN     DATE DEFAULT NULL )  RETURN VARCHAR2
IS
   desc_                 VARCHAR2(2000);
   internal_id_          NUMBER;
   --
   --stmt_                 VARCHAR2(1000);
BEGIN

   IF (view_name_ = 'ISO_LANGUGAGE') THEN
      desc_ := Iso_Language_API.Get_Description(control_type_value_);
   ELSIF (view_name_ = 'ISO_COUNTRY') THEN
      desc_ := Iso_Country_API.Get_Description(control_type_value_);
   ELSIF (view_name_ = 'CONCATENATED_STATE_INFO') THEN      
      Concatenated_State_Info_API.Get_Control_Type_Value_Desc(desc_, control_type_value_);
   ELSIF (view_name_ = 'TYPE1099_LOV(COUNTRY_CODE)') THEN
      -- Control type IC8, Report Code, needs country_code to get the internal id
      -- that is used to get description.
      $IF Component_Invoic_SYS.INSTALLED $THEN
         internal_id_ := Type1099_API.Get_Internal_Type1099(control_type_value_, Company_API.Get_Country_Db(company_));
         desc_ := Type1099_API.Get_Description(internal_id_);
      $ELSE
         NULL;
      $END               
      /*
      stmt_ := 'BEGIN :internal_id_ := Type1099_API.Get_Internal_Type1099(:control_type_value_,
         Company_API.Get_Country_Db(:company_)); END;';
      @ApproveDynamicStatement(2005-11-11,shsalk)
      EXECUTE IMMEDIATE stmt_ using IN OUT internal_id_, control_type_value_, company_;

      stmt_ := 'BEGIN :desc_ := Type1099_API.Get_Description(:internal_id_); END;';
      @ApproveDynamicStatement(2005-11-11,shsalk)
      EXECUTE IMMEDIATE stmt_ using IN OUT desc_ ,internal_id_;
      */

   ELSIF (view_name_ = 'INCOME_TYPE_LOV(COUNTRY_CODE, CURRENCY_CODE)') THEN
      -- Control type IC7, Income Type, needs currency code and country_code to get the internal id
      -- that is used to get description.
      internal_id_ := Income_Type_API.Get_Internal_Income_Type(control_type_value_,
                                                               Company_Finance_API.Get_Currency_Code(company_),
                                                               Company_API.Get_Country_Db(company_));

      desc_ := Income_Type_API.Get_Description(internal_id_);
   ELSIF (view_name_ = 'INTER_COMPANY_ELIM_ACC_MAP_LOV(COMPANY, TO_CHAR(PC_VALID_FROM, ''YYYY-MM''))') THEN
      $IF Component_Grocon_SYS.INSTALLED $THEN
         desc_ := Inter_Company_Elim_Acc_Map_API.Get_Elim_Rule_Description(company_, control_type_value_, NVL(TO_CHAR(valid_from_, 'YYYY-MM'), TO_CHAR(SYSDATE, 'YYYY-MM')));
      $END
      NULL;         
   ELSE
      Get_Control_Type_Value_Desc__ ( desc_, 
                                      pkg_name_,
                                      'GET_CONTROL_TYPE_VALUE_DESC',
                                      company_, 
                                      control_type_value_ );
   END IF;
   RETURN substr(desc_, 1, 2000);
END Get_Control_Type_Desc_;

@UncheckedAccess
FUNCTION Get_Control_Type_Desc_ (
   company_             IN     VARCHAR2,
   module_              IN     VARCHAR2,
   control_type_        IN     VARCHAR2,
   control_type_value_  IN     VARCHAR2) RETURN VARCHAR2
IS
   description_ VARCHAR2(2000);
   ctrl_type_category_ VARCHAR2(2000);
   view_name_ VARCHAR2(2000);
   pkg_name_ VARCHAR2(2000);
BEGIN
   Get_Control_Type_Attri_(description_, 
                           ctrl_type_category_, 
                           view_name_,
                           pkg_name_, 
                           control_type_, 
                           module_);
                           
   RETURN Get_Control_Type_Desc_(company_,
                                 control_type_,
                                 control_type_value_, 
                                 view_name_,
                                 pkg_name_, 
                                 module_);
END Get_Control_Type_Desc_;

PROCEDURE Insert_Control_Type_ (
   control_type_       IN VARCHAR2,
   module_             IN VARCHAR2,
   description_        IN VARCHAR2,
   ctrl_type_category_ IN VARCHAR2,
   view_name_          IN VARCHAR2,
   pkg_name_           IN VARCHAR2,
   logical_unit_       IN VARCHAR2 DEFAULT NULL )
IS
   dummy_      NUMBER;
   allowed_    VARCHAR2(5);
   tmp_        VARCHAR2(100);
   lu_         VARCHAR2(30);
   mod_module_ VARCHAR2(20);

   CURSOR check_rec IS
      SELECT 1
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  control_type = control_type_
      AND    module       = module_;

BEGIN

   -- IN-param cannot be modified => tmp_ variable
   -- Remove parent keys when included in view_name_
   tmp_ := view_name_;
   IF ( INSTR( tmp_,'(' ) > 0 ) THEN
      tmp_ := substr( tmp_, 1, instr( tmp_, '(' ) - 1 );
   END IF;
   -- Register the view as a LOV-view for the Presentation Object. To enable full access for this presentation object.
   Pres_Object_Util_Api.New_Pres_Object_Sec('frmPostCtrlDet',tmp_,'VIEW','5','Manual');

   IF (ctrl_type_category_ IN ('FIXED', 'PREPOSTING')) THEN
      allowed_ := 'NO';
   ELSE
      allowed_ := 'YES';
   END IF;

   IF logical_unit_ IS NULL THEN
      -- Get posting control lu for the module to support basic data translaition
      -- Assume that for every module that have control type also have a LU named like
      -- <Module>PostingCtrl or <Module>PostingCtrlTrans

      -- Make the module having init cap.
      mod_module_ := Substr(module_,1,1) || Lower(Substr(module_,2));
      lu_ := mod_module_ || 'PostingCtrl';

      IF NOT Database_SYS.Package_Exist(Dictionary_SYS.Clientnametodbname_(lu_||'Api')) THEN
         lu_ := mod_module_ || 'PostingCtrlTrans';
         IF NOT Database_SYS.Package_Exist(Dictionary_SYS.Clientnametodbname_(lu_||'Api')) THEN
            lu_ := 'PostingCtrlControlType';
         END IF;
      END IF;
   ELSE
      lu_ := logical_unit_;
   END IF;

   Ctrl_Type_Category_API.Exist_Db(ctrl_type_category_);

   OPEN check_rec;
   FETCH check_rec INTO dummy_;
   IF (check_rec%NOTFOUND) THEN
      CLOSE check_rec;
      INSERT INTO POSTING_CTRL_CONTROL_TYPE_TAB
               ( CONTROL_TYPE, MODULE, DESCRIPTION, VIEW_NAME, PKG_NAME, ALLOWED_FOR_COMB, CTRL_TYPE_CATEGORY, ROWVERSION, LU )
         VALUES (control_type_, module_, description_, view_name_, pkg_name_, allowed_, ctrl_type_category_, sysdate, lu_);
   ELSE
      CLOSE check_rec;
      UPDATE POSTING_CTRL_CONTROL_TYPE_TAB
         SET control_type       = control_type_,
             module             = module_,
             description        = description_,
             ctrl_type_category = ctrl_type_category_,
             view_name          = view_name_,
             pkg_name           = pkg_name_,
             allowed_for_comb   = allowed_,
             lu                 = lu_,
             rowversion         = sysdate
         WHERE control_type = control_type_
         AND   module = module_;
   END IF;
   Basic_Data_Translation_API.Insert_Prog_Translation(module_, lu_, 'PostingCtrlControlType'||'^'||control_type_, description_);
   IF (Language_Sys_Imp_API.Get_Use_Translation_Db(UPPER(mod_module_),lu_) = 'FALSE') THEN
      Language_Sys_Imp_API.Set_Use_Translation (UPPER(mod_module_), lu_, 'TRUE');                                                              
   END IF;
END Insert_Control_Type_;


PROCEDURE Remove_Control_Type_ (
   control_type_  IN VARCHAR2,
   module_        IN VARCHAR2 )
IS
   lu_rec_  POSTING_CTRL_CONTROL_TYPE_TAB%ROWTYPE;

   CURSOR check_rec IS
     SELECT *
     FROM   POSTING_CTRL_CONTROL_TYPE_TAB
     WHERE  control_type = control_type_
     AND    module = module_;

BEGIN

   OPEN check_rec;
   FETCH check_rec INTO lu_rec_;
   IF (check_rec%FOUND) THEN
      CLOSE check_rec;
      DELETE FROM POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE control_type = control_type_
      AND   module = module_;

      Basic_Data_Translation_API.Remove_Basic_Data_Translation(module_, lu_rec_.lu, 'PostingCtrlControlType'||'^'||control_type_);
   ELSE
      CLOSE check_rec;
   END IF;
END Remove_Control_Type_;


PROCEDURE Modify_Control_Type_ (
   control_type_       IN VARCHAR2,
   module_             IN VARCHAR2,
   description_        IN VARCHAR2,
   ctrl_type_category_ IN VARCHAR2,
   view_name_          IN VARCHAR2,
   pkg_name_           IN VARCHAR2,
   logical_unit_       IN VARCHAR2 DEFAULT NULL )
IS
   lu_rec_   POSTING_CTRL_CONTROL_TYPE_TAB%ROWTYPE;

   CURSOR check_rec IS
     SELECT *
     FROM   POSTING_CTRL_CONTROL_TYPE_TAB
     WHERE  control_type = control_type_
     AND    module = module_;

BEGIN
   Ctrl_Type_Category_API.Exist_Db(ctrl_type_category_);

   OPEN check_rec;
   FETCH check_rec INTO lu_rec_;
   IF (check_rec%FOUND) THEN
      CLOSE check_rec;
      UPDATE POSTING_CTRL_CONTROL_TYPE_TAB
      SET description = description_,
          ctrl_type_category = ctrl_type_category_,
          view_name = view_name_,
          pkg_name = pkg_name_,
          rowversion = sysdate,
          lu = nvl(logical_unit_, lu_rec_.lu)
      WHERE control_type = control_type_
      AND   module = module_;
   ELSE
      CLOSE check_rec;
   END IF;
   Basic_Data_Translation_API.Insert_Basic_Data_Translation(module_, 'PostingCtrlControlType', control_type_, NULL, description_, NULL);
END Modify_Control_Type_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
PROCEDURE Get_Description (
   description_  OUT VARCHAR2,
   control_type_ IN  VARCHAR2,
   module_       IN  VARCHAR2,
   company_      IN  VARCHAR2 DEFAULT NULL )
IS
BEGIN
   description_ := Get_Description(control_type_, module_, company_);
END Get_Description;


@UncheckedAccess
FUNCTION Get_Description (
   control_type_ IN VARCHAR2,
   module_       IN VARCHAR2,
   company_      IN VARCHAR2) RETURN VARCHAR2
IS
   lu_rec_ POSTING_CTRL_CONTROL_TYPE_TAB%ROWTYPE;
   CURSOR get_description IS
      SELECT description, lu
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  control_type = control_type_
      AND    module = module_;
   code_part_ VARCHAR2(1);
BEGIN
   OPEN get_description;
   FETCH get_description INTO lu_rec_.description, lu_rec_.lu;
   CLOSE get_description;   
   IF (module_ = 'ACCRUL' AND
       company_ IS NOT NULL AND
       control_type_ IN ('AC11','AC12','AC13','AC14','AC15','AC16','AC17','AC18','AC19','AC20')) THEN
       /*
        * Control types AC11..AC20 is related to codeparts A..J
        * The description of these control types should be the internal names (code_name) of those code parts.
        */
       code_part_ :=  CASE control_type_
                      WHEN 'AC11' THEN 'A'
                      WHEN 'AC12' THEN 'B'
                      WHEN 'AC13' THEN 'C'
                      WHEN 'AC14' THEN 'D'
                      WHEN 'AC15' THEN 'E'
                      WHEN 'AC16' THEN 'F'
                      WHEN 'AC17' THEN 'G'
                      WHEN 'AC18' THEN 'H'
                      WHEN 'AC19' THEN 'I'
                      WHEN 'AC20' THEN 'J'
                      ELSE NULL
                      END;
       lu_rec_.description := Accounting_Code_Parts_API.Get_Name(company_, code_part_);
   ELSE
       lu_rec_.description := Nvl(Substr(Basic_Data_Translation_API.Get_Basic_Data_Translation(module_,
                                                                                               lu_rec_.lu,
                                                                                               'PostingCtrlControlType'||'^'||control_type_),1,100), lu_rec_.description);
   END IF;
   RETURN lu_rec_.description;
END Get_Description;


@UncheckedAccess
FUNCTION Get_Control_Type_Module (
   control_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   control_type_module_     VARCHAR2(20);

   CURSOR Get_Module IS
      SELECT Module
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  control_type = control_type_;

BEGIN
   OPEN Get_Module;
   FETCH Get_Module INTO control_type_module_;
   CLOSE Get_Module;
   RETURN control_type_module_;
END Get_Control_Type_Module;


@UncheckedAccess
FUNCTION Check_Exist (
   control_type_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  control_type = control_type_
      AND    module = module_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist;


PROCEDURE Get_Allowed_Info (
   module_                    OUT VARCHAR2,
   out_ctrl_type_category_    OUT VARCHAR2,
   comb_control_type_desc_    OUT VARCHAR2,
   company_                   IN  VARCHAR2,
   code_part_                 IN  VARCHAR2,
   posting_type_              IN  VARCHAR2,
   control_type_              IN  VARCHAR2,
   ctrl_type_category_        IN  VARCHAR2 )
IS
   out_ctrl_type_category_db_ POSTING_CTRL_CONTROL_TYPE_TAB.ctrl_type_category%TYPE;
BEGIN
   Ctrl_Type_Allowed_Value_API.Get_Allowed_Info__(module_,
                                                  out_ctrl_type_category_,
                                                  out_ctrl_type_category_db_,
                                                  comb_control_type_desc_,
                                                  company_,
                                                  code_part_,
                                                  posting_type_,
                                                  control_type_,
                                                  ctrl_type_category_);
END Get_Allowed_Info;

@UncheckedAccess 
FUNCTION Get_Control_Type_Value_Desc (
   company_                   IN     VARCHAR2,
   control_type_              IN     VARCHAR2,
   control_type_value_        IN     VARCHAR2,
   module_                    IN     VARCHAR2 ) RETURN VARCHAR2  
IS  
   valid_from_   DATE;
BEGIN
   valid_from_ := NULL;
   RETURN Get_Control_Type_Value_Desc( company_,
                                       control_type_,
                                       control_type_value_,
                                       module_,
                                       valid_from_);    
END Get_Control_Type_Value_Desc;      

FUNCTION Get_Control_Type_Value_Desc (
   company_                   IN     VARCHAR2,
   control_type_              IN     VARCHAR2,
   control_type_value_        IN     VARCHAR2,
   module_                    IN     VARCHAR2, 
   valid_from_                IN     DATE) RETURN VARCHAR2
IS
   control_type_value_desc_   VARCHAR2(100);
   view_name_                 VARCHAR2(100);
   pkg_name_                  VARCHAR2(100);
   ctrl_type_category_        POSTING_CTRL_CONTROL_TYPE_TAB.ctrl_type_category%TYPE;
   control_type_desc_         VARCHAR2(100);
BEGIN

   Get_Control_Type_Info__(control_type_value_desc_,
                           view_name_,
                           pkg_name_,
                           ctrl_type_category_,
                           control_type_desc_,
                           company_,
                           control_type_,
                           control_type_value_,
                           module_);
   
   control_type_value_desc_ := Get_Control_Type_Desc_( company_,
                                                       control_type_,
                                                       control_type_value_, 
                                                       view_name_,
                                                       pkg_name_, 
                                                       module_,
                                                       valid_from_);

   RETURN control_type_value_desc_;
END Get_Control_Type_Value_Desc;


@UncheckedAccess
FUNCTION Get_Type1099_Ctrl_Type_Val (
   control_type_value_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   ctrl_type_value_1099_  VARCHAR2(100) := NULL;
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
       ctrl_type_value_1099_ := Type1099_API.Get_Irs1099_Type_Id(control_type_value_);
   $END
   RETURN ctrl_type_value_1099_;
END Get_Type1099_Ctrl_Type_Val;


@UncheckedAccess
FUNCTION Get_Allowed_For_Comb (
   control_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   allowed_for_comb_    VARCHAR2(5);
   CURSOR get_allowed IS
      SELECT allowed_for_comb
      FROM   POSTING_CTRL_CONTROL_TYPE_TAB
      WHERE  control_type = control_type_;
BEGIN
   OPEN get_allowed;
   FETCH get_allowed INTO allowed_for_comb_;
   CLOSE get_allowed;
   RETURN allowed_for_comb_;
END Get_Allowed_For_Comb;



