-----------------------------------------------------------------------------
--
--  Logical unit: ExtParameters
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  970127  MaGu   Created
--  970128  MaGu   Modified the prompts in the comments on view VIEW
--                 modified the checking for existence of voucher type in
--                 Unpack_Check_Insert.
--  970415  MaGu   Added a message in Unpack_Check_Insert___ and Unpack_Check_Update___.
--  970807  SLKO   Converted to Foundation 1.2.2d
--  990713  UMAB   Modified with respect to new template
--  000912  HiMu   Added General_SYS.Init_Method
--  001005  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  010228  JeGu   Bug # 20361 Performance, New Function Get_Ext_Group_Item
--  010402  Uma    Bug# 20944 - Merge of Wizard Modifications. Added VIEW1.
--  010531  Bmekse Removed methods used by the old way for transfer basic data from
--                 master to slave (nowdays is Replication used instead)
--  020208  Asodse IID 21003 Company Translations, Replaced "Text Field Translation"
--  021002  Nimalk Removed usage of the view Company_Finance_Auth in EXT_PARAMETERS,EXT_PARAM_VOUCHER_TYPES view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021011  PPerse Merged External Files
--  030107  Nimalk Removed usage of the view Company_Finance_Auth and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  030805  prdilk SP4 Merge.
--  040329  Gepelk 2004 SP1 Merge.
--  040706  Chprlk Corrected the ext_alter_trans column in EXT_PARAMETERS view 
--  051229  Rufelk B130516 - Removed the ext_alter_trans column from the EXT_PARAMETERS view & renamed
--                 the ext_alter_trans_db column as ext_alter_trans.
--  060310  Samwlk LCS Bug 55726, Merged.
--  060724  Shsalk LCS Bug 57054 Merged. Set Correction default value as FLASE when creating a new row.
--  061025  GaDaLK LCS Bug 59910 Merged.
--  070112  Samwlk used SUBSTR instead of SUBSTRB.
--  071017  Maselk Bug 67684 Added the L flag to voucher_type in the EXT_PARAMETERS view.
--  090929  AjPelk EAST-250 Removed the Ref of ext_alter_trans since it is not required.
--  101011  AjPelk Bug 92374 Corrected. Add a new field , use_codestr_compl
--  130605  Clstlk Bug 110457, Added VIEWPCT,Import___,Copy___ ,Export___, Exist_Any___ and Check_If_Do_Create_Company___
--  151117  Bhhilk STRFI-12, Removed annotation from public get methords.
--  190107  Nudilk Bug 146161, Corrected.
--  190226  Nudilk Bug 147060, Corrected.
--  200109  Snuwlk Bug 151391, Corrected.
--  210126  Lakhlk FISPRING20-8906, Merged LCS Bug 156066, Corrections rollbacked of the Bug 151391.
--  210303  Savmlk FISPRING20-9412, LCS Bug 158115 Merged.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
   company_     VARCHAR2(20);
   def_type_    VARCHAR2(5);
BEGIN
   company_ := Client_SYS.Get_Item_Value ( 'COMPANY',
                                           attr_ );
   Trace_SYS.Message ('company_ : '||company_);
   Check_Default__ ( company_,
                     NULL,
                     def_type_,
                     'PREPARE' );
   super(attr_);
   Client_SYS.Add_To_Attr( 'CREATE_WHEN_CHECKED',  'FALSE',   attr_);
   Client_SYS.Add_To_Attr( 'CHECK_WHEN_LOADED',    'FALSE',   attr_);
   Client_SYS.Add_To_Attr( 'ALLOW_PARTIAL_CREATE', 'FALSE',   attr_);
   Client_SYS.Add_To_Attr( 'EXT_ALTER_TRANS',      'FALSE',   attr_);
   Client_SYS.Add_To_Attr( 'DEF_TYPE',             def_type_, attr_);
   Client_SYS.Add_To_Attr('CORRECTION',             'FALSE',  attr_);
   Client_SYS.Add_To_Attr( 'AUTO_TAX_CALC',         Finance_Yes_No_API.Decode('N'), attr_);
   Client_SYS.Add_To_Attr('USE_CODESTR_COMPL',      'FALSE' , attr_);
   Client_SYS.Add_To_Attr('CALCULATE_RATE',         'FALSE',  attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT EXT_PARAMETERS_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   Check_Default__ ( newrec_.company,
                     newrec_.load_type,
                     newrec_.def_type,
                     'INSERT' );
   super(objid_, objversion_, newrec_, attr_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     EXT_PARAMETERS_TAB%ROWTYPE,
   newrec_     IN OUT EXT_PARAMETERS_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
      Check_Default__ ( newrec_.company,
                     newrec_.load_type,
                     newrec_.def_type,
                     'UPDATE' );
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN EXT_PARAMETERS_TAB%ROWTYPE )
IS
   def_type_  VARCHAR2(5);
BEGIN
   def_type_ := remrec_.def_type;
   Check_Default__ ( remrec_.company,
                     remrec_.load_type,
                     def_type_,
                     'DELETE' );
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT ext_parameters_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_            VARCHAR2(30);
   value_           VARCHAR2(2000);
   function_group_  VARCHAR2(10);
BEGIN
   IF (newrec_.correction IS NULL) THEN
      newrec_.correction := 'FALSE';
   END IF;
   super(newrec_, indrec_, attr_);

   IF newrec_.correction = 'TRUE' AND function_group_ NOT IN('M','K','Q') THEN
      Error_SYS.Appl_General(lu_name_, 'NOCORRECTION: Use Correction rows allowed only for Voucher Types connected to Function groups M, K and Q.');
   END IF;


EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     ext_parameters_tab%ROWTYPE,
   newrec_ IN OUT ext_parameters_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_            VARCHAR2(30);
   value_           VARCHAR2(2000);
   function_group_  VARCHAR2(10);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);

   IF newrec_.correction = 'TRUE' AND NVL(function_group_, Voucher_Type_API.Get_Voucher_Group(newrec_.company, newrec_.voucher_type)) NOT IN ('K','M','Q') THEN
   
      Error_SYS.Appl_General(lu_name_, 'NOCORRECTION: Use Correction rows allowed only for Voucher Types connected to Function groups M, K and Q.');
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

@Override 
PROCEDURE Check_Common___ (
   oldrec_ IN     ext_parameters_tab%ROWTYPE,
   newrec_ IN OUT ext_parameters_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
  function_group_  VARCHAR2(10);  
BEGIN
   newrec_.calculate_rate := NVL(newrec_.calculate_rate, 'FALSE');
   IF(newrec_.voucher_type IS NOT NULL) THEN
      function_group_ := Voucher_Type_API.Get_Voucher_Group(newrec_.company, newrec_.voucher_type);      
   END IF;
   IF (newrec_.ext_alter_trans IS NOT NULL) THEN
      Fnd_Boolean_API.Exist_Db(newrec_.ext_alter_trans);
   END IF;
   IF (newrec_.check_when_loaded = 'FALSE') AND (newrec_.create_when_checked = 'TRUE') THEN
      Error_SYS.Record_General('ExtParameters', 'CHECKCREATE: It is not allowed to create vouchers with out checking them first');
   END IF;
   
   IF (function_group_ ='YE') THEN
      Error_SYS.Record_General('ExtParameters', 'FUNGROUPYE: Voucher type with YE function group is not allowed in External Voucher transaction');
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
      Check_Voucher_Allot__ (newrec_.company,
                          newrec_.voucher_type,
                          newrec_.ext_voucher_no_alloc,
                          newrec_.ext_group_item);
END Check_Common___;

PROCEDURE Export___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS   
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM  ext_parameters_tab e
      WHERE company = crecomp_rec_.company
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = e.company
               AND   vt.voucher_type = e.voucher_type),' ') IN ('00','*',' ');
BEGIN
   FOR exprec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_name_;
      pub_rec_.item_id     := i_;
      Export_Assign___(pub_rec_, crecomp_rec_, exprec_);
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export___;

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   newrec_      ext_parameters_tab%ROWTYPE;
   empty_rec_   ext_parameters_tab%ROWTYPE;
   indrec_      Indicator_Rec;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  Create_Company_Template_Pub src
      WHERE component   = module_
      AND   lu          = lu_name_
      AND   template_id = crecomp_rec_.template_id
      AND   version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM  ext_parameters_tab
                      WHERE company = crecomp_rec_.company
                      AND   load_type = src.c1);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR pub_rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2019-01-01,nudilk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Import_Assign___(newrec_, crecomp_rec_, pub_rec_);
            Client_SYS.Clear_Attr(attr_);
            indrec_ := Get_Indicator_Rec___(newrec_);
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2019-01-01,nudilk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedWithErrors');
END Import___;

PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   attr_        VARCHAR2(2000);
   objid_       VARCHAR2(2000);
   objversion_  VARCHAR2(2000);
   newrec_      ext_parameters_tab%ROWTYPE;
   empty_rec_   ext_parameters_tab%ROWTYPE;
   indrec_      Indicator_Rec;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  ext_parameters_tab src
      WHERE company = crecomp_rec_.old_company
      AND NVL((SELECT ledger_id
               FROM  voucher_type_tab vt
               WHERE vt.company      = src.company
               AND   vt.voucher_type = src.voucher_type),' ') IN ('00','*',' ')
      AND NOT EXISTS (SELECT 1
                      FROM  ext_parameters_tab
                      WHERE company = crecomp_rec_.company
                      AND   load_type = src.load_type);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR oldrec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2019-01-01,nudilk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Copy_Assign___(newrec_, crecomp_rec_, oldrec_);
            Client_SYS.Clear_Attr(attr_);
            indrec_ := Get_Indicator_Rec___(newrec_);
            Check_Insert___(newrec_, indrec_, attr_);
            Insert___(objid_, objversion_, newrec_, attr_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2019-01-01,nudilk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'EXT_PARAMETERS_API', 'CreatedWithErrors');
END Copy___;
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Default__ (
   company_    IN     VARCHAR2,
   load_type_  IN     VARCHAR2,
   def_type_   IN OUT VARCHAR2,
   operation_  IN     VARCHAR2)
IS
   dummy_             NUMBER;
   def_load_type_old_ VARCHAR2(20);
   def_typex_         VARCHAR2(5);
   CURSOR exist_control IS
     SELECT 1
     FROM   Ext_Parameters_Tab
     WHERE  company = company_;
BEGIN
   def_typex_ := def_type_;
   IF (operation_ = 'PREPARE') THEN
      OPEN  exist_control;
      FETCH exist_control INTO dummy_;
      IF (exist_control%FOUND) THEN
         def_type_ := 'FALSE';
      ELSE
         def_type_ := 'TRUE';
      END IF;
      CLOSE exist_control;
   ELSIF (operation_ = 'DELETE' AND def_typex_ = 'TRUE') THEN
      OPEN  exist_control;
      FETCH exist_control INTO dummy_;
      IF (exist_control%FOUND) THEN
         FETCH exist_control INTO dummy_;
         IF (exist_control%FOUND) THEN
            CLOSE exist_control;
            Error_SYS.Appl_General( lu_name_, 'REMDEFERR: It is not allowed to remove a default load type');
         END IF;
      END IF;
      CLOSE exist_control;
   ELSIF (operation_ = 'INSERT' AND def_typex_ = 'FALSE') THEN
      OPEN  exist_control;
      FETCH exist_control INTO dummy_;
      IF (exist_control%NOTFOUND) THEN
         def_type_ := 'TRUE'; -- Always set the first load_type to default = TRUE
      END IF;
      CLOSE exist_control;
   ELSE
      IF (def_typex_ = 'FALSE') THEN
         def_load_type_old_ := Get_Default_Load_Type ( company_ );
         IF (def_load_type_old_ IS NULL) THEN
            def_typex_ := 'TRUE';
         END IF;
         IF (def_load_type_old_ = load_type_) THEN
            def_type_ := 'TRUE';
         END IF;
      END IF;
      IF (def_typex_ = 'TRUE') THEN
         UPDATE Ext_Parameters_Tab
           SET    def_type = decode(load_type,load_type_,'TRUE','FALSE')
         WHERE  company = company_;
      END IF;
   END IF;
END Check_Default__;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Check_Update__ (
   company_    IN VARCHAR2 )
IS
   CURSOR defaults IS
     SELECT load_type
     FROM   EXT_PARAMETERS_TAB
     WHERE  company = company_
     AND    def_type = 'TRUE';
BEGIN
   FOR rec_ IN defaults LOOP
      UPDATE Ext_Parameters_Tab
        SET    def_type = 'FALSE'
        WHERE  company = company_
        AND    load_type = rec_.load_type;
   END LOOP;
END Check_Update__;


PROCEDURE Check_Voucher_Allot__ (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   voucher_no_alloc_ IN VARCHAR2,
   group_item_       IN VARCHAR2)
IS
   auto_allot_          VARCHAR2(1);
BEGIN
   IF (voucher_no_alloc_ = '1') AND (group_item_ != '1') THEN
      Error_SYS.Record_General('ExtParameters', 'INVCOMBVOU: It is not allowed to combine the Voucher Number Allocation parameter :P1 with the Grouping Criterion parameter :P2 ',
         Ext_Voucher_No_Alloc_API.Decode(voucher_no_alloc_),
         Ext_Group_Item_API.Decode(group_item_));
   END IF;
   IF (voucher_no_alloc_ = '2') AND (group_item_ = '1') THEN
      Error_SYS.Record_General('ExtParameters', 'INVCOMBVOU: It is not allowed to combine the Voucher Number Allocation parameter :P1 with the Grouping Criterion parameter :P2 ',
         Ext_Voucher_No_Alloc_API.Decode(voucher_no_alloc_),
         Ext_Group_Item_API.Decode(group_item_));
   END IF;
   auto_allot_ := Voucher_Type_API.Get_Automatic_Allot_Db ( company_,
                                                         voucher_type_ );
   IF (auto_allot_ = 'N') AND (voucher_no_alloc_  = '2') THEN
      Error_SYS.Record_General(lu_name_, 'NOTAUTOALLOT: The Voucher Type :P1 is not using automatic allotment and can not be used when Voucher No Allocation is set to :P2',
         voucher_type_, Ext_Voucher_No_Alloc_API.Decode(voucher_no_alloc_));
   END IF;
   IF (auto_allot_ = 'Y') AND (voucher_no_alloc_  = '1') THEN
      Error_SYS.Record_General(lu_name_, 'AUTOALLOT: The Voucher Type :P1 is using automatic allotment and can not be used when Voucher No Allocation is set to :P2',
         voucher_type_, Ext_Voucher_No_Alloc_API.Decode(voucher_no_alloc_));
   END IF;
END Check_Voucher_Allot__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

   
PROCEDURE Get_Ext_Voucher_No_Alloc (
   ext_voucher_no_alloc_ OUT VARCHAR2,
   company_              IN  VARCHAR2,
   load_type_            IN  VARCHAR2 )
IS
   dummy_  VARCHAR2(1);
   CURSOR getval IS
      SELECT ext_voucher_no_alloc
      FROM   Ext_Parameters_Tab
      WHERE  company = company_
      AND    load_type = load_type_;
BEGIN

   OPEN getval;
   FETCH getval INTO dummy_;
   IF (getval%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtParameters', 'VOU_REC_NOT_EXIST: External interface parameters does not exist for company :P1, voucher type :P2', company_, load_type_ );
   END IF;
   CLOSE getval;
   ext_voucher_no_alloc_ := dummy_;
END Get_Ext_Voucher_No_Alloc;


PROCEDURE Get_Ext_Voucher_Diff (
   ext_voucher_diff_ OUT VARCHAR2,
   company_          IN  VARCHAR2,
   load_type_        IN  VARCHAR2 )
IS
   dummy_  VARCHAR2(1);
   CURSOR getval IS
      SELECT ext_voucher_diff
      FROM   Ext_Parameters_Tab
      WHERE  company = company_
      AND    load_type = load_type_;
BEGIN

   OPEN getval;
   FETCH getval INTO dummy_;
   IF (getval%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtParameters', 'VOU_REC_NOT_EXIST: External interface parameters does not exist for company :P1, voucher type :P2', company_, load_type_ );
   END IF;
   CLOSE getval;
   ext_voucher_diff_ := dummy_;
END Get_Ext_Voucher_Diff;


PROCEDURE Get_Ext_Group_Item (
   ext_group_item_ OUT VARCHAR2,
   company_        IN  VARCHAR2,
   load_type_      IN  VARCHAR2 )
IS
   dummy_  VARCHAR2(1);
   CURSOR getval IS
      SELECT ext_group_item
      FROM   Ext_Parameters_Tab
      WHERE  company = company_
      AND    load_type = load_type_;
BEGIN

   OPEN getval;
   FETCH getval INTO dummy_;
   IF (getval%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtParameters', 'VOU_REC_NOT_EXIST: External interface parameters does not exist for company :P1, voucher type :P2', company_, load_type_ );
   END IF;
   CLOSE getval;
   ext_group_item_ := dummy_;
END Get_Ext_Group_Item;


PROCEDURE Get_Ext_Voucher_Date (
   ext_voucher_date_ OUT VARCHAR2,
   company_          IN  VARCHAR2,
   load_type_        IN  VARCHAR2 )
IS
   dummy_  VARCHAR2(1);
   CURSOR getval IS
      SELECT ext_voucher_date
      FROM   Ext_Parameters_Tab
      WHERE  company = company_
      AND    load_type = load_type_;
BEGIN

   OPEN getval;
   FETCH getval INTO dummy_;
   IF (getval%NOTFOUND) THEN
      Error_SYS.Record_General( 'ExtParameters', 'VOU_REC_NOT_EXIST: External interface parameters does not exist for company :P1, voucher type :P2', company_, load_type_ );
   END IF;
   CLOSE getval;
   ext_voucher_date_ := dummy_;
END Get_Ext_Voucher_Date;

@UncheckedAccess
FUNCTION Get_Ext_Alter_Trans (
   company_   IN  VARCHAR2,
   load_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_  VARCHAR2(5);
   CURSOR getval IS
      SELECT ext_alter_trans
      FROM   Ext_Parameters_Tab
      WHERE  company = company_
      AND    load_type = load_type_;
BEGIN
   OPEN getval;
   FETCH getval INTO dummy_;
   CLOSE getval;
   RETURN dummy_;
END Get_Ext_Alter_Trans;


@UncheckedAccess
FUNCTION Get_Company (
   company_   IN VARCHAR2,
   load_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Ext_Parameters_Tab.company%TYPE;
   CURSOR get_attr IS
      SELECT company
      FROM Ext_Parameters_Tab
      WHERE company = company_
      AND   load_type = load_type_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Company;


@UncheckedAccess
FUNCTION Get_Default_Load_Type (
   company_   IN  VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ Ext_Parameters_Tab.load_type%TYPE;
   CURSOR get_attr IS
      SELECT load_type
      FROM Ext_Parameters_Tab
      WHERE company = company_
      AND   def_type = 'TRUE';
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Default_Load_Type;


PROCEDURE Create_Parameter_Msg (
   msg_            IN OUT VARCHAR2 )
IS
   tmp_                   VARCHAR2(2000) := NULL;
   dummy_                 VARCHAR2(10)   := '<DUMMY>';
   company_               VARCHAR2(20);
   load_type_             VARCHAR2(20);
   new_company_           VARCHAR2(20);
   new_load_type_         VARCHAR2(20);
   new_defaults_          VARCHAR2(5)    := 'TRUE';
   CURSOR get_default IS
      SELECT *
      FROM   ext_parameters_tab
      WHERE  company   = company_
      AND    load_type = load_type_;
   tmp_rec_ get_default%ROWTYPE;
   --
   --
BEGIN
   --
   tmp_ := Message_SYS.Find_Attribute (msg_,
                                       'NEW_COMPANY',
                                       dummy_);
   IF ( tmp_ != '<DUMMY>' ) THEN
      new_company_ := tmp_;
      Message_SYS.Remove_Attribute ( msg_,
                                     'NEW_COMPANY' );
   ELSE
      new_company_ := NULL;
   END IF;
   --
   tmp_ := Message_SYS.Find_Attribute (msg_,
                                       'NEW_LOAD_TYPE',
                                       dummy_);
   IF ( tmp_ != '<DUMMY>' ) THEN
      new_load_type_ := tmp_;
      Message_SYS.Remove_Attribute ( msg_,
                                     'NEW_LOAD_TYPE' );
   ELSE
      new_load_type_ := NULL;
   END IF;
   --
   tmp_ := Message_SYS.Find_Attribute (msg_,
                                       'COMPANY',
                                       dummy_);
   IF ( tmp_ != '<DUMMY>' ) THEN
      company_ := tmp_;
   ELSE
      User_Finance_API.Get_Default_Company ( company_ );
      Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                         'COMPANY',
                                                         company_);
      Message_Sys.Add_Attribute (msg_, 'COMPANY', company_);
   END IF;
   --
   tmp_ := Message_SYS.Find_Attribute (msg_,
                                       'LOAD_TYPE',
                                       dummy_);
   IF ( tmp_ != '<DUMMY>' ) THEN
      load_type_ := tmp_;
      IF (NVL(load_type_,'<LOAD_TYPE>') = '<LOAD_TYPE>') THEN
         load_type_ := Ext_Parameters_API.Get_Def_Load_Type ( company_ );
         Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                            'LOAD_TYPE',
                                                            load_type_);
      END IF;
   ELSE
      load_type_ := Ext_Parameters_API.Get_Def_Load_Type ( company_ );
      Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                         'LOAD_TYPE',
                                                         load_type_);
   END IF;
   --
   IF ( new_company_ IS NOT NULL ) THEN
      IF ( new_company_ = company_ ) THEN
         new_defaults_ := 'FALSE';
      ELSE
         -- Company have been changed
         company_       := new_company_;
         load_type_     := Ext_Parameters_API.Get_Def_Load_Type ( company_ );
         new_load_type_ := NULL;
         Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                            'COMPANY',
                                                            company_);
         Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                            'LOAD_TYPE',
                                                            load_type_);
      END IF;
   END IF;
   --
   IF ( new_load_type_ IS NOT NULL ) THEN
      IF ( new_load_type_ = load_type_ ) THEN
         new_defaults_ := 'FALSE';
      ELSE
         -- Load_Type have been changed
         load_type_ := new_load_type_;
         Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                            'LOAD_TYPE',
                                                            load_type_);
      END IF;
   END IF;
   --
   IF (new_defaults_ = 'TRUE') THEN
      OPEN  get_default;
      FETCH get_default INTO tmp_rec_;
      CLOSE get_default;
      Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                         'FILE_DIRECTION_DB',
                                                         '1');
      Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                         'CHECK_WHEN_LOADED',
                                                         tmp_rec_.check_when_loaded);
      Ext_File_Message_API.Check_And_Replace_Attribute_ (msg_,
                                                         'CREATE_WHEN_CHECKED',
                                                         tmp_rec_.create_when_checked);
   END IF;
END Create_Parameter_Msg;


@UncheckedAccess
FUNCTION Get_Def_Load_Type (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ EXT_PARAMETERS_TAB.load_type%TYPE;
   CURSOR GetDefLoadType IS
      SELECT load_type
      FROM   EXT_PARAMETERS_TAB
      WHERE  company  = company_
      AND    def_type = 'TRUE';
BEGIN
   OPEN  GetDefLoadType;
   FETCH GetDefLoadType INTO temp_;
   CLOSE GetDefLoadType;
   RETURN temp_;
END Get_Def_Load_Type;


