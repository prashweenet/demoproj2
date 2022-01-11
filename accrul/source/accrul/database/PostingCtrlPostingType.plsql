-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlPostingType
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960313  MIJO     Created.
--  970627  SLKO     Converted to Foundation 1.2.2d
--  980127  SLKO     Converted to Foundation1 2.0.0
--  990415  JPS      Performed Template Changes.(Foundation 2.2.1)
--  000704  LeKa     A521: Added tax_flag.
--  000914  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  010611  LiSv     Changes according to new create company concept.
--  020128  ovjose   Changed call in views for get descriptions, removed use of create_company_reg_api
--  020219  Shsalk   Added new attribute Cct_enabled and functions Set_Cct_Enabled, Cct_Enabled.
--  020604  ovjose   Bug #30435 Corrected. Insert_Posting_Type_ now handles update
--  030122  GEPELK   BEFI102EC - Added currev_flag attribute in procedure Insert_Posting_Typ
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   objversion_ := to_char(newrec_.rowversion,'YYYYMMDDHH24MISS');
   IF (newrec_.tax_flag IS NULL) THEN
      newrec_.tax_flag := 'N';
   END IF;
   super(objid_, objversion_, newrec_, attr_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE,
   newrec_     IN OUT POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN BOOLEAN DEFAULT FALSE )
IS
BEGIN
   objversion_ := to_char(newrec_.rowversion,'YYYYMMDDHH24MISS');
   IF (newrec_.tax_flag IS NULL) THEN
      newrec_.tax_flag := 'N';
   END IF;

   IF (oldrec_.module != newrec_.module) THEN
      Module_API.Exist(newrec_.module);
   END IF;
   IF (oldrec_.ledg_flag != newrec_.ledg_flag) THEN
      Posting_Ctrl_Ledger_Flag_API.Exist_Db(newrec_.ledg_flag);
   END IF;
   IF ( NVL(oldrec_.tax_flag,'#$#$') != newrec_.tax_flag ) THEN
      Posting_Ctrl_Ledger_Flag_API.Exist_Db(newrec_.tax_flag);
   END IF;
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT posting_ctrl_posting_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   newrec_.cct_enabled  := NVL(newrec_.cct_enabled, 'FALSE');
   super(newrec_, indrec_, attr_);
   Module_API.Exist(newrec_.module);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     posting_ctrl_posting_type_tab%ROWTYPE,
   newrec_ IN OUT posting_ctrl_posting_type_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
      Error_SYS.Check_Not_Null(lu_name_, 'POSTING_TYPE', newrec_.posting_type);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Get_Module_ (
   module_            IN OUT VARCHAR2,
   posting_type_      IN     VARCHAR2 )
IS
   no_module EXCEPTION;
   --
   CURSOR get_module IS
      SELECT module
      FROM   POSTING_CTRL_POSTING_TYPE_TAB
      WHERE  posting_type = posting_type_;
   --
BEGIN

   OPEN get_module;
   FETCH get_module INTO module_;
   IF (get_module%NOTFOUND) THEN
      CLOSE get_module;
      RAISE no_module;
   END IF;
   CLOSE get_module;
EXCEPTION
   WHEN no_module THEN
      Error_SYS.appl_general(lu_name_, 'NOMODULE: Module is missing for :P1', posting_type_ );
END Get_Module_;


FUNCTION Is_Ledg_Flag_ (
   posting_type_  IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR Get_Ledg_Flag IS
      SELECT ledg_flag
      FROM   POSTING_CTRL_POSTING_TYPE_TAB
      WHERE  posting_type = posting_type_;
   --
   ledg_flag_    POSTING_CTRL_POSTING_TYPE_TAB.ledg_flag%TYPE;
   --
BEGIN
   OPEN get_ledg_flag;
   FETCH get_ledg_flag INTO ledg_flag_;
   IF (get_ledg_flag%NOTFOUND) THEN
      CLOSE Get_Ledg_Flag;
      RETURN FALSE;
   ELSE
      CLOSE Get_Ledg_Flag;
      RETURN TRUE;
   END IF;
EXCEPTION 
   WHEN no_data_found THEN
      Error_SYS.Record_Not_Exist(lu_name_);
END Is_Ledg_Flag_;


FUNCTION Is_Tax_Flag_ (
   posting_type_  IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR Get_Tax_Flag IS
      SELECT tax_flag
      FROM   POSTING_CTRL_POSTING_TYPE_TAB
      WHERE  posting_type = posting_type_;
   --
   tax_flag_    POSTING_CTRL_POSTING_TYPE_TAB.tax_flag%TYPE;
   --
BEGIN
   OPEN get_tax_flag;
   FETCH get_tax_flag INTO tax_flag_;
   IF (get_tax_flag%NOTFOUND) THEN
      CLOSE Get_Tax_Flag;
      RETURN FALSE;
   ELSE
      CLOSE Get_Tax_Flag;
      RETURN TRUE;
   END IF;
EXCEPTION 
   WHEN no_data_found THEN
      Error_SYS.Record_Not_Exist(lu_name_);
END Is_Tax_Flag_;


PROCEDURE Get_Posting_Type_Attri_ (
   description_   OUT VARCHAR2,
   module_        OUT VARCHAR2,
   ledg_flag_     OUT VARCHAR2,
   tax_flag_      OUT VARCHAR2, 
   posting_type_  IN  VARCHAR2 )
IS
   allow_prepost_det_   VARCHAR2(20);      
BEGIN
   Get_Posting_Type_Attri_(description_,
                           module_,
                           ledg_flag_,
                           tax_flag_, 
                           allow_prepost_det_,
                           posting_type_);       
END Get_Posting_Type_Attri_;


PROCEDURE Get_Posting_Type_Attri_ (
   description_         OUT VARCHAR2,
   module_              OUT VARCHAR2,
   ledg_flag_           OUT VARCHAR2,
   tax_flag_            OUT VARCHAR2, 
   allow_prepost_det_   OUT VARCHAR2, 
   posting_type_        IN  VARCHAR2 )
IS
   --
   no_value EXCEPTION;
   desc_    VARCHAR2(200);
   lu_      POSTING_CTRL_POSTING_TYPE_TAB.lu%TYPE;
   --
   CURSOR get_information IS
     SELECT description, module, ledg_flag, tax_flag, lu, allow_prepost_det
     FROM   posting_ctrl_posting_type_tab
     WHERE  posting_type = posting_type_;
BEGIN
   OPEN get_information;
   FETCH get_information INTO description_, module_, ledg_flag_, tax_flag_, lu_, allow_prepost_det_;
   IF (get_information%NOTFOUND) THEN
      RAISE no_value;
   END IF;
   desc_ := Substr(Basic_Data_Translation_API.Get_Basic_Data_Translation(module_, lu_, 'PostingCtrlPostingType'||'^'||posting_type_),1,100);
   IF (desc_ IS NOT NULL) THEN
      description_ := desc_;
   END IF;
   CLOSE get_information;
   allow_prepost_det_ := NVL(allow_prepost_det_, 'FALSE');
EXCEPTION
   WHEN no_value THEN
      CLOSE get_information;
      Error_SYS.Record_General(lu_name_, 'NOINFO: Values for :P1 is missing', posting_type_);
END Get_Posting_Type_Attri_;


PROCEDURE Insert_Posting_Type_ (
   posting_type_        IN VARCHAR2,
   description_         IN VARCHAR2,
   module_              IN VARCHAR2,
   ledg_flag_           IN VARCHAR2,
   tax_flag_            IN VARCHAR2 DEFAULT NULL,
   currev_flag_         IN VARCHAR2 DEFAULT NULL,
   logical_unit_        IN VARCHAR2 DEFAULT NULL, 
   sort_order_          IN NUMBER   DEFAULT NULL,
   allow_prepost_det_   IN VARCHAR2 DEFAULT NULL)
IS
   lu_            VARCHAR2(30);
   mod_module_    VARCHAR2(20);
   attr_          VARCHAR2(2000);
   newrec_        POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE;
   oldrec_        POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE;
   existrec_      POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE;
   objid_         VARCHAR2(100);
   objversion_    VARCHAR2(2000);
   indrec_        Indicator_Rec;
BEGIN

   IF (logical_unit_ IS NULL) THEN
      -- Get posting control lu for the module to support basic data translaition
      -- Assume that for every module that have posting type also have a LU named like
      -- <Module>PostingCtrl or <Module>PostingCtrlTrans
   
      -- Make the module having init cap.
      mod_module_ := Substr(module_,1,1) || Lower(Substr(module_,2));
      lu_ := mod_module_ || 'PostingCtrl';
   
      IF NOT Database_SYS.Package_Exist(Dictionary_SYS.Clientnametodbname_(lu_||'Api')) THEN
         lu_ := mod_module_ || 'PostingCtrlTrans';
         IF NOT Database_SYS.Package_Exist(Dictionary_SYS.Clientnametodbname_(lu_||'Api')) THEN
            lu_ := 'PostingCtrlPostingType';
         END IF;
      END IF;
   ELSE
      lu_ := logical_unit_;
   END IF;
   existrec_ := Get_Object_By_Keys___(posting_type_);
   IF (existrec_.posting_type IS NOT NULL) THEN
      newrec_ := existrec_;
   END IF;
   newrec_.posting_type := posting_type_;
   newrec_.description  := description_;
   newrec_.module       := module_;
   newrec_.ledg_flag    := ledg_flag_;
   newrec_.tax_flag     := NVL(tax_flag_, 'N');
   newrec_.currev_flag  := currev_flag_;
   newrec_.lu           := lu_;
   newrec_.sort_order   := sort_order_;
   newrec_.allow_prepost_det := NVL(allow_prepost_det_, 'FALSE');
   
   IF (existrec_.posting_type IS NULL) THEN
      newrec_.cct_enabled := 'FALSE';
      indrec_ := Get_Indicator_Rec___(newrec_);
      Check_Insert___(newrec_, indrec_, attr_);
      newrec_.rowkey := NULL;
      Insert___(objid_, objversion_, newrec_, attr_);
   ELSE
      oldrec_ := Lock_By_Keys___(newrec_.posting_type);
      newrec_.cct_enabled := oldrec_.cct_enabled;
      indrec_ := Get_Indicator_Rec___(oldrec_, newrec_);
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;
   
   Basic_Data_Translation_API.Insert_Prog_Translation(module_, lu_, 'PostingCtrlPostingType'||'^'||posting_type_, description_);
END Insert_Posting_Type_;


PROCEDURE Remove_Posting_Type_ (
   posting_type_  IN VARCHAR2 )
IS
   lu_rec_  POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE;

   CURSOR check_rec IS
      SELECT *
      FROM   POSTING_CTRL_POSTING_TYPE_TAB
      WHERE  posting_type = posting_type_;
BEGIN
   OPEN check_rec;
   FETCH check_rec INTO lu_rec_;
   IF (check_rec%FOUND) THEN
      CLOSE check_rec;
      DELETE FROM POSTING_CTRL_POSTING_TYPE_TAB
      WHERE posting_type = posting_type_;

      Basic_Data_Translation_API.Remove_Basic_Data_Translation(lu_rec_.module, lu_rec_.lu, 'PostingCtrlPostingType'||'^'||posting_type_);
   ELSE
      CLOSE check_rec;
   END IF;
END Remove_Posting_Type_;


PROCEDURE Modify_Posting_Type_ (
   posting_type_ IN VARCHAR2,
   description_  IN VARCHAR2,
   module_       IN VARCHAR2 )
IS
   lu_rec_  POSTING_CTRL_POSTING_TYPE_TAB%ROWTYPE;

   CURSOR check_rec IS
      SELECT *
      FROM   POSTING_CTRL_POSTING_TYPE_TAB
      WHERE  posting_type = posting_type_;
BEGIN

   OPEN check_rec;
   FETCH check_rec INTO lu_rec_;
   IF (check_rec%FOUND) THEN
      CLOSE check_rec;
      UPDATE POSTING_CTRL_POSTING_TYPE_TAB
         SET description = description_,
             module = module_,
             rowversion = sysdate
         WHERE posting_type = posting_type_;
   ELSE
      CLOSE check_rec;
   END IF;
   Basic_Data_Translation_API.Insert_Basic_Data_Translation(module_, lu_rec_.lu, 'PostingCtrlPostingType'||'^'||posting_type_, NULL, description_, NULL);   
END Modify_Posting_Type_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@UncheckedAccess
PROCEDURE Get_Description (
   description_  OUT VARCHAR2,
   posting_type_ IN  VARCHAR2 )
IS
BEGIN
   description_  := Get_Description(posting_type_ );
END Get_Description;

   
PROCEDURE Set_Cct_Enabled (
   posting_type_ IN VARCHAR2 )
IS
   CURSOR get_data IS
      SELECT 1 
      FROM posting_ctrl_posting_type_tab
      WHERE posting_type = posting_type_
      AND Cct_Enabled = 'FALSE'
      FOR UPDATE OF Cct_Enabled;
BEGIN
   FOR fetch_data IN get_data LOOP
      UPDATE posting_ctrl_posting_type_tab
         SET Cct_Enabled = 'TRUE'
         WHERE CURRENT OF get_data;
   END LOOP;   
END Set_Cct_Enabled;


FUNCTION Cct_Enabled (
   posting_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_    VARCHAR2(5);
   CURSOR get_Cct_State IS
     SELECT cct_enabled
     FROM   posting_ctrl_posting_type_tab
     WHERE  posting_type = posting_type_;
BEGIN
   OPEN get_Cct_State;
   FETCH get_Cct_State INTO dummy_;
   CLOSE get_Cct_State;
   RETURN dummy_;
END Cct_Enabled;



