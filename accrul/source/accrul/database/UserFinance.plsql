-----------------------------------------------------------------------------
--
--  Logical unit: UserFinance
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  190506  Rakuse  TEUXXCC-2149, Added procedure Is_User_Authorized.
--  960517  xxxx    Base Table to Logical Unit Generator 1.0A
--  970606  JoTh    Bug # 97-0021 fixed in function User_Id.
--  970709  SLKO    Converted to Foundation 1.2.2d
--  980308  MiJo    Bug #3439, Added new function Get_Max_User and Get_Min_User.
--  980311  ANDJ    Bug # 3831. New view, new function to connect user to company.
--  990707  HIMM    Modified withrespect to template changes
--  991001  JOELSE  Add current fnd user to new company
--  000619  Kumudu  Bug 40188 corrected. Modified view USER_FINANCE. Added call to
--                  FND_USER_API.Get_Description.
--  000620  Uma     Changed Get_Oracle_User to Get_Fnd_User.
--  000914  HiMu    Added General_SYS.Init_Method
--  001130  OVJOSE  For new Create Company concept added new view user_finance_ect and user_finance_pct.
--                  Added procedures Make_Company, Copy___, Import___ and Export___.
--  010112  ToOs    Bug #19024 Modified User_Connected___ and call it from Insert___
--                  and Update___ for use of F1-method Remove_Value.
--  010124  OVJOSE  Bug #19247 Modified User_Connected___.
--  010320  OVJOSE  Bug #19103 Correction.
--  010517  LiSv    For new create company concept changed procedure User_Connected___.
--  010706  AjRolk  Bug ID 23036 Fixed ,Interchanged parameters in NVL(User_Profile_Sys.New_Value)
--  010706  AjRolk  Bug ID 23036 Recorrected .
--  010816  OVJOSE  Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK  IID 20001 Enhancement of Update Company. Changes inside make_company method
--                  Changed Import___, Export___ and Copy___ methods to use records
--  020129  THSRLK  IID 20004 - Removed def_tab from methord Export___.
--  020213  Mnisse  Removed description, should always use FND_USER.description
--  020306  Shsalk  Call Id 77400 Corrected.
--  020815  ovjose  Bug #32114 Corrected.
--  040329  Gepelk  2004 SP1 Merge.
--  040617  sachlk  FIPR338A2: Unicode Changes.
--  040712  anpelk  B115738, Modified view USER_FIN_PROPERTIES
--  040720  Hecolk  FIPR309, Added new Method Check_Exist
--  061201  Samwlk Added new funtion Get_Default_Company_Func.    
--  070420  Krpelk  B142305 - Create a new public procedure called 'Register_Company_User'
--  060416  Shsalk  LCS Merge 64778. Change the cursor get_data in Copy___()
--  080912  Hiralk  Bug 76755, Created new public function called 'Get_Company_List'
--  091015  OVJOSE  EAFH-382 - Removed code that add appowner and ifsadmin in the company during 
--                  company creation. Also some general cleanup in the file.
--  100312  OVJOSE Added Exist_Current_User, Is_User_Authorized. Added Micro Cache.Changes in Import___/Copy___
--  100730  Mawelk  Bug 92155 Fixed. Introduce a new method called Exist_User()
--  100805  OVJOSE  Added method Is_Allowed, returns the string TRUE/FALSE if current user is allowed to company
--  100805  OVJOSE  Added method Has_Finance_Company_Adm_Priv, checks if the user has Finance administrator privileges
--  101208  DIFELK  RAVEN-1396, added validation for null company in Is_User_Authorized
--  121117  Mohrlk SFI-1321, Added Method Validate_Inv_Recipient().
--  121207  Maaylk  PEPA-183, Removed global variable
--  141214  NuKuLK  PRSA-6030, Added @UncheckedAccess to Check_Exist().
--  210212  Umdolk  FISPRING20-9081, Replaced obsolete ManageUser activity check with UserHandling projection check. 
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE User_Connected___ (
   company_ IN VARCHAR2,
   user_ IN VARCHAR2,
   mode_ IN VARCHAR2 )
IS
   ecode_   VARCHAR2(10) := 'COMPANY';
   default_ VARCHAR2(20);
BEGIN
   default_ := User_Profile_Sys.Get_Default(ecode_,user_);
   BEGIN
      User_Profile_SYS.Remove_Value( ecode_, user_, company_ );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF (mode_ = 'UPDATE') THEN
      User_Profile_SYS.New_Value( ecode_, user_, company_, company_ );
   ELSIF (mode_ = 'INSERT_DEFAULT_NULL') THEN
      User_Profile_SYS.New_Value( ecode_, user_, company_, nvl(default_,company_) );
   ELSIF (mode_ = 'INSERT_DEFAULT_NOTNULL') THEN
      User_Profile_SYS.New_Value( ecode_, user_, company_, company_ );
   ELSE
      default_ := User_Profile_SYS.Get_Default(ecode_,user_);
      IF (default_ IS NULL) THEN
         User_Profile_SYS.New_Value('COMPANY', user_, company_, company_);
      ELSE
         User_Profile_SYS.New_Value('COMPANY', user_, company_);
      END IF;
   END IF;
END User_Connected___;


PROCEDURE Import___ (
   crecomp_rec_      IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec,
   make_comp_attr_   IN VARCHAR2 )
IS
   newrec_        USER_FINANCE_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   update_by_key_ BOOLEAN;
   fnd_user_      Fnd_User.Identity%TYPE := Fnd_Session_API.Get_Fnd_User;
   emptyrec_      USER_FINANCE_TAB%ROWTYPE;
   comp_exist_    BOOLEAN := FALSE;
   is_process_create_company_ BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT C1
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1 
                      FROM USER_FINANCE_TAB dest
                      WHERE dest.company = crecomp_rec_.company
                      AND dest.userid = Decode(src.C1,'<FNDUSER>',fnd_user_,C1));
BEGIN

   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);

   comp_exist_ := Exist_Any___(crecomp_rec_.company);

   -- Make sure that the company finance object exists before starting to insert users. IF not error will be raised
   Exist_Company_Finance___(crecomp_rec_.company);

   -- Checking what process is executing, ("CREATE COMPANY", "UPDATE COMPANY" or "UPDATE TRANSLATION")
   -- defaulting to "CREATE COMPANY" if empty
   IF (NVL(Client_SYS.Get_Item_Value('MAIN_PROCESS', make_comp_attr_),'CREATE COMPANY') = 'CREATE COMPANY') THEN
      is_process_create_company_ := TRUE;
   ELSE
      is_process_create_company_ := FALSE;
   END IF;

   -- IF the create company process have been executed ok in CompanyFinance LU then the user
   -- that is creating the company have already been inserted at this point.
   -- IF the user creating the company has not been added for some reason and the LU is empty then add the user
   IF (NOT Check_Exist___(crecomp_rec_.company, fnd_user_) AND (NOT comp_exist_) ) THEN
      i_ := 1;
      INSERT INTO USER_FINANCE_TAB (rowversion, company, userid)
      VALUES (sysdate, crecomp_rec_.company, fnd_user_);

      User_Connected___( crecomp_rec_.company, fnd_user_, 'MAKE_COMPANY' );
      Invalidate_Cache___;
   ELSIF (is_process_create_company_) THEN
      -- set i_ for the code to know that a row have been added to the LU (from CompanyFinance LU)
      -- to state the correct text in the log.
      i_ := 1;
   END IF;

   IF ( update_by_key_ OR is_process_create_company_ ) THEN
      FOR rec_ IN get_data LOOP
         newrec_ := emptyrec_;
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-24,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            -- In older versions of Application (Prior Accrul 8.12) <APPOWNER> was used. IF some template 
            -- uses that then ignore the row. The NVL is just a dummy value that cannot exist as an identity
            IF ( NVL(rec_.c1, '#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#') != '<APPOWNER>' ) THEN
               IF ( rec_.c1 = '<FNDUSER>' ) THEN
                  newrec_.userid := fnd_user_;
               ELSE
                  newrec_.userid := rec_.c1;
               END IF;
               
               newrec_.userid    := rec_.c1;
               newrec_.company   := crecomp_rec_.company;
               New___(newrec_);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'Error', msg_);
         END;
      END LOOP;

      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- update_by_key_ and is_process_create_company_ are both FALSE
   IF ( NOT update_by_key_ AND NOT is_process_create_company_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedWithErrors');
END Import___;


PROCEDURE Copy___ (
   crecomp_rec_      IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec,
   make_comp_attr_   IN VARCHAR2 )
   
IS
   newrec_           USER_FINANCE_TAB%ROWTYPE;
   msg_              VARCHAR2(2000);
   update_by_key_    BOOLEAN;
   i_                NUMBER := 0;   
   fnd_user_         Fnd_User.Identity%TYPE := Fnd_Session_API.Get_Fnd_User;
   emptyrec_         USER_FINANCE_TAB%ROWTYPE;
   comp_exist_       BOOLEAN := FALSE;
   is_process_create_company_ BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT userid,
             sysdate
      FROM   USER_FINANCE_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1
                      FROM USER_FINANCE_TAB dest
                      WHERE dest.company = crecomp_rec_.company
                      AND dest.userid = src.userid);
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);

   comp_exist_ := Exist_Any___(crecomp_rec_.company);

   -- Make sure that the company finance object exists before starting to insert users. IF not error will be raised
   Exist_Company_Finance___(crecomp_rec_.company);
   
   -- Checking what process is executing, ("CREATE COMPANY", "UPDATE COMPANY" or "UPDATE TRANSLATION")
   -- defaulting to "CREATE COMPANY" if empty
   IF (NVL(Client_SYS.Get_Item_Value('MAIN_PROCESS', make_comp_attr_),'CREATE COMPANY') = 'CREATE COMPANY')  THEN
      is_process_create_company_ := TRUE;
   ELSE
      is_process_create_company_ := FALSE;
   END IF;
   
   -- IF the create company process have been executed ok in CompanyFinance LU then the user
   -- that is creating the company have already been inserted at this point.
   -- IF the user creating the company has not been added for some reason and the LU is empty then add the user
   IF (NOT Check_Exist___(crecomp_rec_.company, fnd_user_) AND (NOT comp_exist_) ) THEN
      i_ := 1;
      INSERT INTO USER_FINANCE_TAB (rowversion, company, userid)
      VALUES (sysdate, crecomp_rec_.company, fnd_user_);

      User_Connected___( crecomp_rec_.company, fnd_user_, 'MAKE_COMPANY' );
      Invalidate_Cache___;
   ELSIF (is_process_create_company_) THEN
      -- set i_ for the code to know that a row have been added to the LU (from CompanyFinance LU)
      -- to state the correct text in the log.
      i_ := 1;
   END IF;

   IF ( update_by_key_ OR is_process_create_company_ ) THEN
      FOR rec_ IN get_data LOOP
         newrec_ := emptyrec_;
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-24,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_.company := crecomp_rec_.company;
            newrec_.userid := rec_.userid;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;    
               @ApproveTransactionStatement(2014-03-24,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedWithErrors');                     
         END IF;                     
      END IF;      
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- update_by_key_ and is_process_create_company_ are both FALSE
   IF ( NOT update_by_key_ AND NOT is_process_create_company_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_FINANCE_API', 'CreatedWithErrors');
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;

   CURSOR get_data IS
      SELECT userid
      FROM   user_finance_tab
      WHERE  company = crecomp_rec_.company;

   CURSOR get_def_data IS
      SELECT *
       FROM   CREATE_COMPANY_TEMPLATE_PUB
       WHERE  COMPONENT = 'ACCRUL'
       AND    LU        = 'UserFinance'
       AND    template_id = crecomp_rec_.user_template_id;

BEGIN
   IF (crecomp_rec_.user_template_id IS NULL) THEN
      FOR pctrec_ IN get_data LOOP
         pub_rec_.template_id := crecomp_rec_.template_id;
         pub_rec_.component := 'ACCRUL';
         pub_rec_.version  := crecomp_rec_.version;
         pub_rec_.lu := lu_name_;
         pub_rec_.item_id := i_;
         pub_rec_.c1 := pctrec_.userid;
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

         IF pctrec_.c1 = '<APPOWNER>' THEN
            -- Using <APPOWNER> was an old construction used prior to Accrul 8.12.0
            pub_rec_.c1 := '<FNDUSER>';
         ELSE
            pub_rec_.c1 := pctrec_.c1;
         END IF;         
         Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
         i_ := i_ + 1;
      END LOOP;
   END IF;
END Export___;


PROCEDURE Exist_Company_Finance___ (
   company_    IN VARCHAR2)
IS
BEGIN
   IF (NOT Company_Finance_API.Check_Exist(company_)) THEN
      Error_SYS.Record_General(lu_name_,'NOCOMPFIN: Company Finance object :P1 does not exist!', 
                               company_);
   END IF;
END Exist_Company_Finance___;


FUNCTION Exist_Any___(
   company_    IN VARCHAR2 ) RETURN BOOLEAN
IS
   b_exist_  BOOLEAN  := TRUE;
   idum_     PLS_INTEGER;
   CURSOR exist_control IS
      SELECT 1
      FROM   USER_FINANCE_TAB
      WHERE  company = company_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO idum_;
   IF ( exist_control%NOTFOUND) THEN
      b_exist_ := FALSE;
   END IF;
   CLOSE exist_control;
   RETURN b_exist_;
END Exist_Any___;

FUNCTION Has_User_Admin_Grants___ RETURN BOOLEAN
IS
BEGIN   
   RETURN ((Security_SYS.Has_System_Privilege('ADMINISTRATOR') = 'TRUE') AND (Security_SYS.Is_Projection_Available('UserHandling')));
END Has_User_Admin_Grants___;
   
PROCEDURE Exist_User_Admin___ (
   company_ IN VARCHAR2,
   userid_  IN VARCHAR2)
IS
BEGIN
   IF NOT (Check_Exist___(company_, userid_) OR Has_User_Admin_Grants___) THEN
      Error_SYS.Appl_General(lu_name_,
                             'RECNOTEXISTADMIN: Access denied! User :P1 are not authorized to add/modify/remove users to Company :P2',
                             userid_,
                             company_);
   END IF;                                   
END Exist_User_Admin___;   


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     user_finance_tab%ROWTYPE,
   newrec_ IN OUT user_finance_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   current_user_     VARCHAR2(30) := Fnd_Session_API.Get_Fnd_User;
   prev_ind_         BOOLEAN := indrec_.company;
BEGIN
   -- Special handling to support add/modify/remove to a company from the Solution Manager client 
   -- If the has Has_Admin_Grants___ then the user can add/modify/remove users to the company    
   IF (Has_User_Admin_Grants___) THEN
      -- Currently the Company_Finance_API.Exist method has an implicit company security check (very old construction). Once we have removed that 
      -- the maniuplation of indrec should be removed to have the standard exist check againt CompanyFinance.
      indrec_.company := FALSE;   
   END IF;

   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
   --Add post-processing code here
   indrec_.company := prev_ind_;
   
   -- Make sure that the company exists in CompanyFinance first, if not error will be raised in Exist_Company_Finance___. This
   -- could be removed once we have removed the implicit company security check within Company_Finance_API.Exist
   Exist_Company_Finance___(newrec_.company);
   -- If it is the first user then no validation needed otherwise the following rule:
   -- Special handling to support add/modify/remove to a company from the Solution Manager client 
   -- If the user has Has_Admin_Grants___ then the user can add/modify/remove users to the company 
   -- Else the user adding the data (a new additional user to the company)
   -- must be an allowed user in the company.    
   IF (Exist_Any___(newrec_.company)) THEN
      Exist_User_Admin___(newrec_.company, current_user_);
   END IF;         
END Check_Common___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT USER_FINANCE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   default_company_  USER_FINANCE.default_company%type ;
BEGIN
   default_company_ := Client_SYS.Get_Item_Value('DEFAULT_COMPANY', attr_);
   Client_SYS.Clear_Attr(attr_);
   super(objid_, objversion_, newrec_, attr_);
   IF (default_company_ IS NULL OR default_company_ = 'FALSE') THEN
      User_Connected___(newrec_.company, newrec_.userid, 'INSERT_DEFAULT_NULL' );
   ELSE
      User_Connected___(newrec_.company, newrec_.userid, 'INSERT_DEFAULT_NOTNULL' );
   END IF;
   Invalidate_Cache___;
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     USER_FINANCE_TAB%ROWTYPE,
   newrec_     IN OUT USER_FINANCE_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN BOOLEAN DEFAULT FALSE )
IS
BEGIN
   Client_SYS.Clear_Attr(attr_);
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   User_Connected___( newrec_.company, newrec_.userid, 'UPDATE' );
   Invalidate_Cache___;
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN USER_FINANCE_TAB%ROWTYPE )
IS   
   n_dummy_           NUMBER ;
   default_company_   USER_FINANCE.default_company%TYPE;
BEGIN
   -- Check that the user is allowed to the company.
   -- IF the user is an Administrator then the user can add/modify/remove users to the company otherwise
   -- the user needs to be an user within the company to be allowed to add users to the company.
   IF NOT (Has_User_Admin_Grants___) THEN   
      Exist_Current_User(remrec_.company);
   END IF;
   default_company_ := User_Finance_API.Is_Default_Company(remrec_.company, remrec_.userid);
   
   super(remrec_);
   
   -- check if it's the record with default company and not the only one User Id
   Count_Userid(n_dummy_, remrec_.userid);
   IF (n_dummy_ > 1  AND default_company_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'USERWITHDEFAULT: Not allowed to delete User :P1 with default company!', remrec_.userid);
   END IF;
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN USER_FINANCE_TAB%ROWTYPE )
IS   
BEGIN
   super(objid_, remrec_);   
   BEGIN
      User_Profile_SYS.Remove_Value('COMPANY', remrec_.userid, remrec_.company);      
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;   

   $IF Component_Mpccom_SYS.INSTALLED $THEN
      User_Allowed_Site_API.Remove_User_Allowed_Site(remrec_.userid, remrec_.company);
   $END
   Invalidate_Cache___;
END Delete___;


@Override 
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   userid_ IN VARCHAR2 )
IS
BEGIN  
   -- Creating a backdoor for application owner during installation. 
   -- This to make it possible to run some scripts during installation e.g. Manual Post scripts.
   -- The scripts needs to set installation mode before executing package methods that end up
   -- validating the user in this method.
   -- If installation mode is not set then the application owner will be validated as any other user.
   IF (userid_ = Fnd_Session_API.Get_App_Owner AND Database_SYS.Get_Installation_Mode) THEN
      -- Do not raise an error in this case.
      RETURN;       
   ELSE
      Error_SYS.Record_Not_Exist(lu_name_,
                                 'RECNOTEXIST: Access denied! User :P1 is not connected to Company :P2',
                                 userid_,
                                 company_);
   END IF;
   super(company_, userid_);
END Raise_Record_Not_Exist___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Create_Client_Mapping__ (
   client_window_ IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
 
   clmapprec_    Client_Mapping_API.Client_Mapping_Pub;
   clmappdetrec_ Client_Mapping_API.Client_Mapping_Detail_Pub;
BEGIN
   clmapprec_.module := module_;
   clmapprec_.lu := lu_name_;
   clmapprec_.mapping_id := 'CCD_USERGROUPMEMBERFINANCE';
   clmapprec_.client_window := client_window_;  
   clmapprec_.rowversion := sysdate;
   Client_Mapping_API.Insert_Mapping(clmapprec_);

   clmappdetrec_.module := module_;
   clmappdetrec_.lu := lu_name_;
   clmappdetrec_.mapping_id :=  'CCD_USERGROUPMEMBERFINANCE';
   clmappdetrec_.column_type := 'NORMAL';  
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := sysdate;  

   clmappdetrec_.column_id := 'C1' ;
   clmappdetrec_.translation_link := 'USER_GROUP_MEMBER_FINANCE.USER_GROUP';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C2' ;
   clmappdetrec_.translation_link := 'USER_GROUP_MEMBER_FINANCE.USERID';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
   
   clmappdetrec_.column_id := 'C3' ;
   clmappdetrec_.translation_link := 'USER_GROUP_MEMBER_FINANCE.DEFAULT_GROUP';
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);

END Create_Client_Mapping__;   


PROCEDURE Create_Company_Reg__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE,
   account_related_   IN     BOOLEAN  DEFAULT FALSE,
   standard_table_    IN     BOOLEAN  DEFAULT TRUE )
IS
   
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, 'USER_FINANCE_API',
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      'CCD_USERFINANCE', 'C1');
   Enterp_Comp_Connect_V170_API.Reg_Add_Table(
       module_,'USER_FINANCE_TAB',
       CASE standard_table_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);  
   Enterp_Comp_Connect_V170_API.Reg_Add_Table_Detail(
      module_,'USER_FINANCE_TAB','COMPANY','<COMPANY>');
   execution_order_ := execution_order_+1;
END Create_Company_Reg__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------


PROCEDURE Exist_User (
   company_ IN VARCHAR2,
   userid_ IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_, userid_)) THEN
      Error_Sys.Record_General(lu_name_, 'EXTUSERCHK: User :P1 is not connected to company :P2.', userid_, company_ );
   END IF;
END Exist_User;


PROCEDURE Count_Userid (
   count_      OUT NUMBER,
   user_id_    IN  VARCHAR2 )
IS
  CURSOR fetch_rec IS
     SELECT count(*)
     FROM  USER_FINANCE_TAB
     WHERE userid  = user_id_ ;
BEGIN
   OPEN fetch_rec ;
   FETCH fetch_rec INTO count_ ;
   CLOSE fetch_rec;
END Count_Userid;


@UncheckedAccess
FUNCTION User_Id RETURN VARCHAR2
IS
BEGIN
   RETURN Fnd_Session_API.Get_Fnd_User;
END User_Id;


@UncheckedAccess
PROCEDURE Get_Default_Company (
   company_    OUT VARCHAR2 )
IS
BEGIN
   company_ := Get_Default_Company_Func;
END Get_Default_Company;


@UncheckedAccess
FUNCTION Check_User (
   company_       IN VARCHAR2,
   userid_        IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
   IF Check_Exist___(company_, userid_) THEN
      RETURN TRUE;
   END IF;
   RETURN FALSE;
END Check_User;


@UncheckedAccess   
FUNCTION Check_Exist (
   company_ IN VARCHAR2,
   userid_  IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF Check_Exist___(company_, userid_) THEN
      RETURN 'TRUE';
   END IF;
   RETURN 'FALSE';
END Check_Exist;


@UncheckedAccess
FUNCTION Get_Max_User (
   company_       IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR getmaxuser IS
      SELECT max(userid)
      FROM    USER_FINANCE_TAB
      WHERE   Company = company_;

   user_  VARCHAR2(30) := 'Z';

BEGIN
   OPEN getmaxuser;
   FETCH getmaxuser INTO user_;
   CLOSE getmaxuser;
   RETURN user_;
END Get_Max_User;


@UncheckedAccess
FUNCTION Get_Min_User (
   company_       IN VARCHAR2 ) RETURN VARCHAR2
IS

CURSOR getminuser IS
   SELECT min(userid)
   FROM    USER_FINANCE_TAB
   WHERE   Company = company_;

   user_  VARCHAR2(30) := 'A';
BEGIN
   OPEN getminuser;
   FETCH getminuser INTO user_;
   CLOSE getminuser;
   RETURN user_;
END Get_Min_User;


@ServerOnlyAccess
PROCEDURE Register_Company_User (
   company_ IN VARCHAR2,
   userid_  IN VARCHAR2 )
IS
   newrec_     USER_FINANCE_TAB%ROWTYPE;
   ext_attr_   VARCHAR2(2000);
   objid_      VARCHAR2(100);
   objversion_ VARCHAR2(100);
   indrec_     Indicator_Rec;
BEGIN
   Client_SYS.Add_To_Attr('COMPANY', company_, ext_attr_ );
   Client_SYS.Add_To_Attr('USERID', userid_, ext_attr_ );
   IF (Check_Exist(company_, userid_) = 'FALSE') THEN
      Unpack___(newrec_, indrec_, ext_attr_);
      indrec_ := Get_Indicator_Rec___(newrec_);
      -- Currently the Company_Finance_API.Exist method has an implicit company security check (very old construction). Once we have removed that 
      -- the maniuplation of indrec should be removed to have the standard exist check againt CompanyFinance.      
      indrec_.company := FALSE;
      Check_Insert___(newrec_, indrec_, ext_attr_);
      Insert___(objid_, objversion_, newrec_, ext_attr_);
   END IF;
END Register_Company_User;


PROCEDURE Make_Company (
   attr_       IN VARCHAR2 )
IS
   rec_        Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN

   rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec('ACCRUL', attr_);

   IF (rec_.make_company = 'EXPORT') THEN
      Export___(rec_);
   ELSIF (rec_.make_company = 'IMPORT') THEN
      IF (rec_.action = 'NEW') THEN
         Import___(rec_, attr_);
      ELSIF (rec_.action = 'DUPLICATE') THEN
         Copy___(rec_, attr_);
      END IF;
   END IF;
END Make_Company;


@UncheckedAccess
FUNCTION Get_Default_Company_Func RETURN VARCHAR2
IS
   userid_  VARCHAR2(30);
BEGIN
   userid_ := User_Id;
   RETURN User_Profile_SYS.Get_Default('COMPANY', userid_);
END Get_Default_Company_Func;


@UncheckedAccess
FUNCTION Get_Company_List(
   user_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   all_user_companies_ VARCHAR2(32000);
   
   CURSOR get_logged_user_company IS
      SELECT  company
      FROM    USER_FINANCE_TAB
      WHERE   userid = user_id_;
 
BEGIN
    FOR rec_ IN get_logged_user_company LOOP
       all_user_companies_ := all_user_companies_ || rec_.company || '^';
    END LOOP;
    RETURN all_user_companies_;
END Get_Company_List;


-- Is_User_Authorized
--   Returns TRUE/FALSE depending on if the user is authorized to the given company
--   (or if the user has Finance Company Adm Privileges)
@UncheckedAccess
FUNCTION Is_User_Authorized (
   company_      IN VARCHAR2) RETURN BOOLEAN
IS
   fnd_user_   fnd_user.identity%TYPE := Fnd_Session_API.Get_Fnd_User;
BEGIN
   -- Return false if the company is null so that we will not return true even if it is the appowner.
   IF (company_ IS NULL) THEN
      RETURN FALSE;
   END IF;
      
   -- Return true if the user has special privileges
   IF (Has_Finance_Company_Adm_Priv(company_) = 'TRUE') THEN
      RETURN TRUE;
   END IF;

   -- Ordinary check against User Finance Table
   Update_Cache___(company_, fnd_user_);
   IF (company_ = micro_cache_value_.company) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END Is_User_Authorized;


-- Is_User_Authorized
--   Check if user is authorized to the given company.
--   Raises Appl_Failure if user is not authorized.
@UncheckedAccess
PROCEDURE Is_User_Authorized (
   company_ IN VARCHAR2)
IS
BEGIN
   IF (NOT (Is_User_Authorized(company_))) THEN
      Error_SYS.Appl_Failure(lu_name_, err_source_ => 'User_Finance_API.Is_User_Authorized(company_)');
   END IF;
END Is_User_Authorized;


-- Is_Allowed
--   Returns the string TRUE/FALSE depending on if the user is authorized to the given company
--   (or if the user has Finance Company Adm Privileges)
@UncheckedAccess
FUNCTION Is_Allowed  (
   company_      IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (Is_User_Authorized(company_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Is_Allowed;


-- Exist_Current_User
--   Validates that the current (foundation) user is an allowed user
--   in the given company. If the user is not allowed then error is raised.
PROCEDURE Exist_Current_User (
   company_ IN VARCHAR2)
IS
BEGIN
   Exist(company_, Fnd_Session_API.Get_Fnd_User);
END Exist_Current_User;


-- Exist_User_Admin
--   Validates that the current (foundation) user is an allowed user in the given
--   company or if the user Has_User_Admin_Rights___. If the user is not allowed then error is raised.
--   This method should only be used from logical units that needs to let an administrator pass ordinary
--   User Finance validation when administrating user in Solution Manager
PROCEDURE Exist_User_Admin (
   company_ IN VARCHAR2)
IS
BEGIN
   Exist_User_Admin___(company_, Fnd_Session_API.Get_Fnd_User);   
END Exist_User_Admin;


-- Exist_Current_User
--   Function that returns TRUE if the user has administrator privileges to the financial company according
--   to what has been decided from the Financials product point of view in this method.
--   The checks within the method can be changed in the future
--   The method could also be customized to fit customers need on what they define as "Finance Administrator"
--   Currently the parameter company_ is not used within the method but might be in the future. If for example
--   there can be different administrator for different companies.
@UncheckedAccess
FUNCTION Has_Finance_Company_Adm_Priv (
   company_ IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
   IF (company_ IS NULL) THEN
      RETURN 'FALSE';
   END IF;

   -- The following check if user is Administrator has been commented out and should NOT be used by default. 
   -- It could though be used in a customization where someone want the Administrator to be able to extract 
   -- company data. It should be used with care
   -- It will still not be possible to create/update/remove any financial transactions, just read data from views.
   /*
   -- Check if the user has the system privilege ADMINISTRATOR (always true for appowner, SYS and SYSTEM)
   IF (Security_SYS.Has_System_Privilege('ADMINISTRATOR') = 'TRUE') THEN 
      RETURN 'TRUE';
   END IF;
   */

   -- Creating a backdoor for application owner during installation. 
   -- This to make it possible to run some scripts during installation e.g. Manual Post scripts.
   -- The scripts needs to set installation mode before executing package methods that end up
   -- validating the user in this method.
   -- IF installation mode is not set (to true) then the application owner will be validated as any other user.
   IF (Database_SYS.Get_Installation_Mode AND Fnd_Session_API.Get_Fnd_User = Fnd_Session_API.Get_App_Owner) THEN
      RETURN 'TRUE';
   END IF;

   RETURN 'FALSE';
END Has_Finance_Company_Adm_Priv;


@UncheckedAccess
FUNCTION Get_Description (
   userid_ IN VARCHAR2 ) RETURN VARCHAR2
IS

BEGIN
   RETURN Fnd_User_API.Get_Description(userid_);
END Get_Description;


@UncheckedAccess
FUNCTION Is_Default_Company (
   company_    IN VARCHAR2,
   userid_     IN VARCHAR2 ) RETURN VARCHAR2
IS
   def_company_   VARCHAR2(20);
BEGIN
   def_company_ := NVL(User_Profile_SYS.Get_Default('COMPANY', userid_), '#');
   IF (def_company_ = company_) THEN
      RETURN 'TRUE';
   END IF;
   RETURN 'FALSE';
END Is_Default_Company;



