-----------------------------------------------------------------------------
--
--  Logical unit: UserGroupFinance
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960326  PeJon    Created
--  970708  SLKO     Converted to Foundation 1.2.2d
--  980921  BREN     Master Slave Connection
--                   Added Send_User_Grp_Info___, Send_User_Grp_Info_Delete___,
--                   Send_User_Grp_Info_Modify___, Receive_User_Grp_Info___.
--  990707  HiMu     Modified withrespect to template changes
--  000915  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method
--  001219  OVJOSE   For new Create Company concept added public procedure Make Company and added implementation
--                   procedures Import___, Copy___, Export___.
--  010531  Bmekse   Removed methods used by the old way for transfer basic data from
--                   master to slave (nowdays is Replication used instead)
--  010730  Brwelk   Added new column Allowed_Accounting_Period. Added Get_Allowed_Acc_Period (23412)
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020129  THSRLK  IID 20004 - Removed def_tab from methord Export___.
--  020212  Mnisse  IID 21003, Added company_translation support
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020611  ovjose   Bug 29600 Corrected. Removed function call in USER_GROUP_FINANCE_PCT.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in USER_GROUP_FINANCE view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021030  KuPelk   IID ESFI110N  Year End Accounting.Added new view as YEAR_END_USER_GROUP_LOV.
--  021128  KuPelk   Bug# 91598 Corrected by changing the view YEAR_END_USER_GROUP_LOV .
--
--  040617  sachlk   FIPR338A2: Unicode Changes.
--  070402  ovjose   Added user_group_finance_adm. This is used from Solution Manager via Extended Server.
--  070510  Prdilk   B141476, Modified Unpack_Check_Update___ to support translations.
--  071109  MAWELK   Bug Id 67914 Added Year_End_User_Group_Exist() and Ord_User_Group_Exist()
--  090605  THPELK   Bug 82609 - Added missing UNDEFINE statements for VIEW_ADM.
--  091217  HimRlk   Reverse engineering correction, Removed method call User_Group_Member_Finance_API.Check_Delete_Group
--  091217           in Check_Delete___.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package
--  180508  Bhhilk  Bug 141473, Modified Check_Update___, Check_Change_Allowed___ to validate user group period.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_      user_group_finance_tab%ROWTYPE;
   empty_rec_   user_group_finance_tab%ROWTYPE;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  user_group_finance_tab src
      WHERE company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1
                      FROM  user_group_finance_tab
                      WHERE company = crecomp_rec_.company
                      AND   user_group = src.user_group);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR oldrec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-08-27,difelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Copy_Assign___(newrec_, crecomp_rec_, oldrec_);
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-08-27,difelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedWithErrors');
END Copy___;
   

PROCEDURE Import___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_      user_group_finance_tab%ROWTYPE;
   empty_rec_   user_group_finance_tab%ROWTYPE;
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
                      FROM  user_group_finance_tab
                      WHERE company = crecomp_rec_.company
                      AND   user_group = src.c1);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR pub_rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-08-27,difelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            Import_Assign___(newrec_, crecomp_rec_, pub_rec_);
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-08-27,difelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_FINANCE_API', 'CreatedWithErrors');
END Import___;
   
   
PROCEDURE Export___ (
   crecomp_rec_ IN     ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT user_group, description, allowed_accounting_period
      FROM  user_group_finance_tab
      WHERE company = crecomp_rec_.company;

   CURSOR get_def_data IS
       SELECT *
       FROM   CREATE_COMPANY_TEMPLATE_PUB
       WHERE  COMPONENT = 'ACCRUL'
       AND    LU    = 'UserGroupFinance'
       AND    template_id = crecomp_rec_.user_template_id;
BEGIN
   IF (crecomp_rec_.user_template_id IS NULL) THEN
      FOR pctrec_ IN get_data LOOP
         pub_rec_.template_id := crecomp_rec_.template_id;
         pub_rec_.component   := module_;
         pub_rec_.version     := crecomp_rec_.version;
         pub_rec_.lu          := lu_name_;
         pub_rec_.item_id     := i_;
         pub_rec_.c1          := pctrec_.user_group;
         pub_rec_.c2          := pctrec_.description;
         pub_rec_.c3          := pctrec_.allowed_accounting_period;
         Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
         i_ := i_ + 1;
      END LOOP;
   ELSE
      FOR pctrec_ IN get_def_data LOOP
         pub_rec_.template_id := crecomp_rec_.template_id;
         pub_rec_.component := 'ACCRUL';
         pub_rec_.version  := crecomp_rec_.version;
         pub_rec_.lu := lu_name_;
         pub_rec_.item_id := i_;
         pub_rec_.c1 := pctrec_.c1;
         pub_rec_.c2 := pctrec_.c2;
         pub_rec_.c3 := pctrec_.c3;
         Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
         i_ := i_ + 1;
      END LOOP;
   END IF;
END Export___;

@Deprecated
PROCEDURE Check_Change_Allowed___ (
   company_ IN VARCHAR2,
   user_group_ IN VARCHAR2 )
IS
BEGIN
   Check_Change_Allowed___(company_, user_group_, '');
END Check_Change_Allowed___;


PROCEDURE Check_Change_Allowed___ (
   company_ IN VARCHAR2,
   user_group_ IN VARCHAR2,
   allowed_accounting_period_ IN VARCHAR2)
IS
   change_not_allowed_ BOOLEAN := FALSE;
   acc_period_type_ VARCHAR2(20);
BEGIN
   acc_period_type_ := User_Group_Period_API.Get_User_Grp_Period_Type(company_, user_group_);
   IF (acc_period_type_ IS NOT NULL ) THEN
      IF (acc_period_type_ = 'ORDINARY' AND allowed_accounting_period_ = '2') THEN
         Error_SYS.Appl_General(lu_name_, 
                             'CHGNOTALOWDORD: Cannot modify the Allowed Accounting Period as User Group :P1 is already connected to :P2 Accounting Periods.', 
                             user_group_, Period_Type_API.Decode(acc_period_type_));         
      ELSIF (acc_period_type_ != 'ORDINARY' AND allowed_accounting_period_ = '1') THEN
         Error_SYS.Appl_General(lu_name_, 
                             'CHGNOTALOWDEND: Cannot modify the Allowed Accounting Period as User Group :P1 is already connected to :P2/:P3 Accounting Periods.', 
                             user_group_, Period_Type_API.Decode('YEAROPEN'), Period_Type_API.Decode('YEARCLOSE'));
      END IF;
   END IF;
   -- Check Hold table
   IF (VOUCHER_API.Is_Usergroup_Used(company_,
                                     user_group_)= 'TRUE') THEN
      change_not_allowed_ := TRUE;
   ELSE
      -- Hold Table is clear, Check Genled
      $IF Component_Genled_SYS.INSTALLED $THEN
         IF (Gen_Led_Voucher_API.Is_Usergroup_Used(company_,
                                                   user_group_)= 'TRUE') THEN
   
              change_not_allowed_ := TRUE;
         END IF;
      $ELSE
         NULL;
      $END
   END IF;

   IF (change_not_allowed_) THEN
      Error_SYS.Appl_General(lu_name_,
                             'CHNOTALLWED: Usergroup is connected to vouchers - Cannot modify Allowed Accounting Period' );
   END IF;
END Check_Change_Allowed___;


FUNCTION Has_User_Admin_Grants___ RETURN BOOLEAN
IS
BEGIN
   RETURN ((Security_SYS.Has_System_Privilege('ADMINISTRATOR') = 'TRUE') AND (Security_SYS.Is_Activity_Available('ManageUsers')));
END Has_User_Admin_Grants___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'ALLOWED_ACCOUNTING_PERIOD', Allowed_Accounting_Periods_Api.Decode('1'), attr_ );
END Prepare_Insert___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT user_group_finance_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   exists_     VARCHAR2(10);
   prev_ind_   BOOLEAN := indrec_.company;
BEGIN
   -- Special handling to support add/modify/remove user data to a company from the Solution Manager client 
   -- If the has Has_Admin_Grants___ then the user can add/modify/remove users to the company    
   IF (Has_User_Admin_Grants___) THEN
      -- Currently the Company_Finance_API.Exist method has an implicit company security check (very old construction). Once we have removed that 
      -- the maniuplation of indrec should be removed to have the standard exist check againt CompanyFinance.
      indrec_.company := FALSE;   
   END IF;   
   super(newrec_, indrec_, attr_);
   indrec_.company := prev_ind_;
   
   -- IMPORTANT NOTE!
   -- Replaced usage of Company_Finance_API.Exist with Company_Finance_Exist_Adm to be able to connect other users to a company
   -- based on system privilege "Administrator" and granted a specific activity and not only by being an existing user in the company.
   -- Do not change this back without checking the consequence of the codechange.
   -- Once the implicit UserFinance check is removed from Company_Finance_API.Exist standard validation can be used and
   -- instead use the validation method User_Finance_API.Exist_User_Admin should be used to see if the user is 
   -- allowed or not to add/modify/remove data
   Company_Finance_API.Exist_Adm(newrec_.company);  
   --------------------------
   Check_User_Company(exists_, newrec_.user_group, newrec_.company);
   IF (exists_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'COMPANY_EXIST: The combination company/user group already exists');
   END IF;
END Check_Insert___;



@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     user_group_finance_tab%ROWTYPE,
   newrec_ IN OUT user_group_finance_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_          VARCHAR2(30);
   value_ VARCHAR2(4000);

BEGIN

   super(oldrec_, newrec_, indrec_, attr_);


   IF(oldrec_.allowed_accounting_period != newrec_.allowed_accounting_period) THEN
      Check_Change_Allowed___(newrec_.company, newrec_.user_group, newrec_.allowed_accounting_period);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Check_User_Company (
   exists_        OUT VARCHAR2,
   user_group_    IN VARCHAR2,
   company_       IN VARCHAR2 )
IS
   CURSOR cur IS
   SELECT 'TRUE'
     FROM USER_GROUP_FINANCE_TAB
    WHERE user_group = user_group_
      AND company    = company_;
BEGIN
   OPEN cur;
   FETCH cur INTO exists_;
   IF cur%NOTFOUND THEN
      exists_ := 'FALSE';
   END IF;
   CLOSE cur;
END Check_User_Company;


@UncheckedAccess
FUNCTION Get_User_Group_Description (
   company_       IN VARCHAR2,
   user_group_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   desc_  USER_GROUP_FINANCE.description%TYPE;
   CURSOR get_desc IS
      SELECT description
      FROM   USER_GROUP_FINANCE
      WHERE  company          = company_
      AND    user_group       = user_group_;
BEGIN
   OPEN  get_desc;
   FETCH get_desc INTO desc_;
   CLOSE get_desc;
   RETURN desc_;
END Get_User_Group_Description;




PROCEDURE Get_Control_Type_Value_Desc (
   description_   OUT VARCHAR2,
   company_       IN VARCHAR2,
   user_group_    IN VARCHAR2 )
IS
BEGIN
   description_ := Get_User_Group_Description( company_, user_group_ );
END Get_Control_Type_Value_Desc;


@UncheckedAccess
FUNCTION Get_Allowed_Acc_Period (
   company_       IN VARCHAR2,
   user_group_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   allowed_acc_period_   VARCHAR2(1);

   CURSOR Get_allowed_acc_period_ IS
      SELECT Allowed_Accounting_Period
        FROM USER_GROUP_FINANCE_TAB
       WHERE company    = company_
         AND user_group = user_group_;

BEGIN
   OPEN   Get_allowed_acc_period_;
   FETCH  Get_allowed_acc_period_ INTO allowed_acc_period_;
   CLOSE  Get_allowed_acc_period_;
   RETURN allowed_acc_period_;
END Get_Allowed_Acc_Period;




PROCEDURE Year_End_User_Group_Exist (
   company_       IN VARCHAR2,
   user_group_    IN VARCHAR2 )

IS
   dummy_ NUMBER;

   CURSOR exist_Year_End_User_Group IS
      SELECT 1
      FROM   USER_GROUP_FINANCE_TAB
      WHERE  company = company_
      AND    user_group = user_group_
      AND    allowed_accounting_period = '2';
BEGIN
   
   OPEN exist_Year_End_User_Group;
   FETCH exist_Year_End_User_Group INTO dummy_;
   IF (exist_Year_End_User_Group%NOTFOUND) THEN
      CLOSE exist_Year_End_User_Group;
      Error_SYS.Appl_General(lu_name_,'YEARENDUSERNOTALLWED: Year End User Group :P1 does not belong to a Year End period.', user_group_);
   END IF;
   CLOSE exist_Year_End_User_Group;
END Year_End_User_Group_Exist;


PROCEDURE Ord_User_Group_Exist (
   company_       IN VARCHAR2,
   user_group_    IN VARCHAR2 )

IS
   dummy_ NUMBER;

   CURSOR exist_ordinary_user_group IS
      SELECT 1
      FROM   USER_GROUP_FINANCE_TAB
      WHERE  company = company_
      AND    user_group = user_group_
      AND    allowed_accounting_period = '1';
BEGIN
   
   OPEN exist_ordinary_user_group;
   FETCH exist_ordinary_user_group INTO dummy_;
   IF (exist_ordinary_user_group%NOTFOUND) THEN
      CLOSE exist_ordinary_user_group;
      Error_SYS.Appl_General(lu_name_, 'ORDEIUSERNOTALLWED: User Group :P1 does not belong to an Ordinary Period', user_group_ );
   END IF;
   CLOSE exist_ordinary_user_group;
END Ord_User_Group_Exist;


