-----------------------------------------------------------------------------
--
--  Logical unit: UserGroupMemberFinance
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960325  PEJON    Created
--  970318  AnDj     Deleted CLOSE CURSOR in Get_Default_Group
--  970325  MaGu     Added CLOSE CURSOR clause in proc. Get_User_Group and other procs.
--  970709  SLKO     Conversion to Foundation 1.2.2d
--  980121  PICZ     Added function Get_User_Group
--  980304  PICZ     Changed comments to VIEW2: when used as LOV onlu user group is shown
--  980320  ARBI     Added Is_User_Member_Of_Group
--  990317  Bren     Bug #: 5779. Added protected & implementation procedure/function
--                   to handle overloaded functions.
--  990413  JPS      Performed the Template Changes.(Foundation 2.2.1)
--  991001  JOELSE   Add current fnd user into a user group. (See company_finance_api.create_company)
--  000403  Uma      Corrected Bug Id# 37201.
--  000508  Uma      Added view USER_GROUP_MEMBER_FINANCE3.
--  000620  Uma      Changed Get_Oracle_User to Get_Fnd_User.
--  000915  HiMu     Added General_SYS.Init_Method
--  001005  prtilk   BUG # 15677  Checked General_SYS.Init_Method 
--  001130  OVJOSE   For new Create Company concept added new view user_group_member_finance_ect and 
--                   user_group_member_finance_pct. 
--                   Added procedures Make_Company, Copy___, Import___ and Export___.
--  010626  Gawilk   Bug # 22689 fixed. 
--  010816  OVJOSE   Added Create Company translation method Create_Company_Translations___
--  020102  THSRLK   IID 20001 Enhancement of Update Company. Changes inside make_company method
--                   Changed Import___, Export___ and Copy___ methods to use records
--  020129  THSRLK  IID 20004 - Removed def_tab from methord Export___. 
--  020320  Mnisse   Copy__ changed FOUND -> NOTFOUND
--  020618  ASHELK   Bug 30756, Added View USER_GROUP_MEMBER_FINANCE4.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in USER_GROUP_MEMBER_FINANCE,USER_GROUP_MEMBER_FINANCE_PCT view 
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  040623  anpelk   FIPR338A2: Unicode Changes.
--  050518  upunlk   LCS Merge 50897
--  051118  WAPELK   Merged the Bug 52783. Correct the user group variable's width.
--  070402  ovjose   Added view user_group_member_finance_adm. This is used from Solution Manager via Extended Server.
--  080924  MAKRLK   Bug 76726 Corrected. Added new function User_Group_Exist().
--  090525  AsHelk   Bug 80221, Adding Transaction Statement Approved Annotation.
--  090603  Nsillk   Bug 83233, Corrected.Modified in method Unpack_Check_Insert__
--  090605  THPELK   Bug 82609 - Added missing UNDEFINE statement for VIEW_ADM.
--  091005  Mawelk   Bug 86158 Fixed. Made Default Group is mandetory in the view USER_GROUP_MEMBER_FINANCE
--  091015  OVJOSE   EAFH-382 - Removed code that add appowner in the company during 
--                   company creation. Also some general cleanup in the file.
--  091111  Nsillk   EAFH-203 , removed SAVEPOINT and ROLLBACK
--  091217  HimRlk   Reverse engineering correction, Removed procedure Check_Delete_Group.
--  100121  Thpelk   Bug 88116 - Corrected in New__() and Modify__(). 
--  100419  KiSalk   Modified Check_Delete___ as a workaround for REF mismatch in BudgetTemplate
--  101015  Laselk   Bug 93512, Added new method Check_Valid_User() to validate user group of a user.
--  111031  Shdilk   SFI-96, Added Get_User_Groups.
--  121207  Maaylk   PEPA-183, Removed global variable
--  140127  Umdolk   PBFI-4979, override check_insert to check/update default user group.
--  151118  Bhhilk   STRFI-39, Modified DefaultGroup enumeration to FinanceYesNo.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Get_User_Group___ (
   company_   IN VARCHAR2,
   user_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_group_  user_group_member_finance_tab.user_group%type;
   CURSOR get_user_group IS
      SELECT user_group
      FROM   user_group_member_finance_tab
      WHERE  company = company_
      AND  userid  = user_name_
      AND  default_group = 'Y';
BEGIN
   OPEN get_user_group;
   FETCH get_user_group INTO user_group_;
   IF (get_user_group%NOTFOUND) THEN
      CLOSE get_user_group;
      RETURN NULL;
   ELSE
      CLOSE get_user_group;
   END IF;
   RETURN user_group_;
END Get_User_Group___;


PROCEDURE Import___ (
   crecomp_rec_ IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   dummy_         VARCHAR2(1);
   newrec_        USER_GROUP_MEMBER_FINANCE_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   counter_       NUMBER := 0;
   update_by_key_ BOOLEAN;    
   empty_lu_      BOOLEAN := FALSE;
   fnd_user_      VARCHAR2(30) := Fnd_Session_API.Get_Fnd_User;
   emptyrec_      USER_GROUP_MEMBER_FINANCE_TAB%ROWTYPE;
   user_created_  BOOLEAN := FALSE;
   
   CURSOR get_data IS
      SELECT C1, C2, C3
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1       
                      FROM USER_GROUP_MEMBER_FINANCE_TAB dest
                      WHERE company = crecomp_rec_.company
                      AND user_group = src.c1
                      AND userid = Decode(src.C2, '<FNDUSER>', fnd_user_, src.C2))
      ORDER BY C2, Decode(C3, 'Y', 1, 2) ASC;

   CURSOR user_group IS
      SELECT DISTINCT C1              
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1       
                      FROM USER_GROUP_MEMBER_FINANCE_TAB dest
                      WHERE company = crecomp_rec_.company
                      AND user_group = src.c1
                      AND userid = fnd_user_);

   CURSOR exist_fnd_user IS
      SELECT 'X' 
      FROM USER_GROUP_MEMBER_FINANCE_TAB
      WHERE company = crecomp_rec_.company
      AND userid = fnd_user_;

   CURSOR exist_company IS
      SELECT 'X'
      FROM   USER_GROUP_MEMBER_FINANCE_TAB
      WHERE  company = crecomp_rec_.company;  
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);   

   IF (NOT update_by_key_) THEN
      empty_lu_ := FALSE;
      OPEN exist_company;
      FETCH exist_company INTO dummy_;
      IF exist_company%NOTFOUND THEN
         CLOSE exist_company;
         empty_lu_ := TRUE;
      END IF;
   END IF;

   IF (update_by_key_ OR empty_lu_) THEN      
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-24,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := emptyrec_;
            -- In older versions of Application (Prior Accrul 8.12.0) <APPOWNER> was used. IF some template 
            -- uses that then ignore the row. The NVL is just a dummy value that cannot exist as an identity
            IF ( NVL(rec_.c2, '#$#$#$#$#$#$#$#$#$#$#$#$#$#$#$#') != '<APPOWNER>' ) THEN
               newrec_.company       := crecomp_rec_.company;
               newrec_.user_group    := rec_.c1;
               IF ( rec_.c2 = '<FNDUSER>' ) THEN
                  newrec_.userid        := fnd_user_;
               ELSE
                  newrec_.userid        := rec_.c2;
               END IF;
               newrec_.default_group := rec_.c3; 
               New___(newrec_);
               -- IF data is created for the fnd_user then no need to open user_group cursor
               IF (newrec_.userid = fnd_user_) THEN
                  user_created_ := TRUE;   
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                                   
         END;
      END LOOP;      

      -- Check if the user exists in the company. IF not then use next for loop to try to get data.
      IF NOT user_created_ THEN
         OPEN exist_fnd_user;
         FETCH exist_fnd_user INTO dummy_;
         IF exist_fnd_user%FOUND THEN
            user_created_ := TRUE;
         END IF;
         CLOSE exist_fnd_user;
      END IF;
      
      counter_ := 0;
      -- IF the fnd_user was not in the template (as user of <FNDUSER> )then insert values for the fnd_user based on any 
      -- existing template data.
      IF (NOT user_created_) THEN
         FOR rec_ IN user_group LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-24,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN
               newrec_ := emptyrec_;
               newrec_.company       := crecomp_rec_.company;
               newrec_.user_group    := rec_.c1;
               newrec_.userid        := fnd_user_;
               counter_ := counter_ + 1;
               -- To make sure that a default group exist when inserting the first row. Order By in cursor would also fix it. 
               IF (counter_ = 1) THEN
                  newrec_.default_group := 'Y'; 
               ELSE
                  newrec_.default_group := 'N'; 
               END IF;
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                                   
            END;
         END LOOP;   
      END IF;

      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedWithErrors');                     
         END IF;                     
      END IF;      
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- update_by_key_ and empty_lu are FALSE
   IF (NOT update_by_key_ AND NOT empty_lu_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                          
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedWithErrors');                           
END Import___;   


PROCEDURE Copy___ (
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   dummy_         VARCHAR2(1);
   msg_           VARCHAR2(2000);
   counter_       NUMBER := 0;
   i_             NUMBER := 0;   
   update_by_key_ BOOLEAN;             
   fnd_user_      VARCHAR2(30) := Fnd_Session_API.Get_Fnd_User;
   created_by_    VARCHAR2(30);
   newrec_        USER_GROUP_MEMBER_FINANCE_TAB%ROWTYPE;
   emptyrec_      USER_GROUP_MEMBER_FINANCE_TAB%ROWTYPE;
   empty_lu_      BOOLEAN := FALSE;
   user_created_  BOOLEAN := FALSE;
   
   CURSOR exist_company IS
      SELECT 'X'
      FROM   USER_GROUP_MEMBER_FINANCE_TAB
      WHERE  company = crecomp_rec_.company;

   CURSOR get_data IS
      SELECT user_group,
             userid,
             default_group
      FROM   USER_GROUP_MEMBER_FINANCE_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1       
                      FROM USER_GROUP_MEMBER_FINANCE_TAB dest
                      WHERE company = crecomp_rec_.company
                      AND user_group = src.user_group
                      AND userid = src.userid)
      ORDER BY userid ASC,  Decode(default_group, 'Y', 1, 2) ASC;

   -- IF the fnd_user does not exist in the source company then copy the 
   -- creator of the source company's rows
   CURSOR user_group IS 
      SELECT *
      FROM   USER_GROUP_MEMBER_FINANCE_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND    userid = created_by_
      AND NOT EXISTS (SELECT 1       
                      FROM USER_GROUP_MEMBER_FINANCE_TAB dest
                      WHERE company = crecomp_rec_.company
                      AND user_group = src.user_group
                      AND fnd_user_ = src.userid)
      ORDER BY Decode(default_group, 'Y', 1, 2) ASC;

   -- IF the fnd_user or the creator of the source company does not exist in the source company then copy  
   -- data from any user just to get some user group data
   CURSOR any_user_group IS 
      SELECT DISTINCT user_group
      FROM   USER_GROUP_MEMBER_FINANCE_TAB src
      WHERE  company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1       
                      FROM USER_GROUP_MEMBER_FINANCE_TAB dest
                      WHERE company = crecomp_rec_.company
                      AND user_group = src.user_group
                      AND fnd_user_ = src.userid);

   CURSOR exist_fnd_user IS
      SELECT 'X' 
      FROM USER_GROUP_MEMBER_FINANCE_TAB
      WHERE company = crecomp_rec_.company
      AND userid = fnd_user_;
BEGIN
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);         

   IF (NOT update_by_key_) THEN
      empty_lu_ := FALSE;
      OPEN exist_company;
      FETCH exist_company INTO dummy_;
      IF exist_company%NOTFOUND THEN
         CLOSE exist_company;
         empty_lu_ := TRUE;
      END IF;
   END IF;

   IF (update_by_key_ OR empty_lu_) THEN
      counter_ := 0;
      -- Adding the users in the source company to the LU for existing user groups
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-24,dipelk)
            SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := emptyrec_;           
            -- In older versions of Application (Prior Accrul 8.12) <APPOWNER> was used. IF some template 
            -- uses that then ignore the row.
            newrec_.company       := crecomp_rec_.company;
            newrec_.user_group    := rec_.user_group;
            newrec_.userid        := rec_.userid;
            newrec_.default_group := rec_.default_group; 
            New___(newrec_);
            IF (newrec_.userid = fnd_user_) THEN
               user_created_ := TRUE;   
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-24,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                                   
         END;
      END LOOP;      

      -- Check if the user exists in the company. IF not then use next for loop to try to get data.
      IF NOT user_created_ THEN
         OPEN exist_fnd_user;
         FETCH exist_fnd_user INTO dummy_;
         IF exist_fnd_user%FOUND THEN
            user_created_ := TRUE;
         END IF;
         CLOSE exist_fnd_user;
      END IF;
      
      -- IF the fnd_user was not added to the LU in the previous cursor then try to make use of the same 
      -- data as the creator of the source company
      IF (NOT user_created_) THEN
         created_by_ := Company_API.Get_Created_By(crecomp_rec_.old_company);
         FOR rec_ IN user_group LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-24,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN
               newrec_ := emptyrec_;
               newrec_.company       := crecomp_rec_.company;
               newrec_.user_group    := rec_.user_group;
               newrec_.userid        := fnd_user_;
               newrec_.default_group := rec_.default_group;
               New___(newrec_);

               user_created_ := TRUE;   
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                                   
            END;
         END LOOP;   
      END IF;

      -- Check if the user exists in the company. IF not then use next for loop to try to get data.
      IF NOT user_created_ THEN
         OPEN exist_fnd_user;
         FETCH exist_fnd_user INTO dummy_;
         IF exist_fnd_user%FOUND THEN
            user_created_ := TRUE;
         END IF;
         CLOSE exist_fnd_user;
      END IF;
      
      -- IF the fnd_user was not added to the LU in the previous cursor then try to make use of any 
      -- data from the source company
      IF (NOT user_created_) THEN
         counter_ := 0;
         FOR rec_ IN any_user_group LOOP
            i_ := i_ + 1;
            @ApproveTransactionStatement(2014-03-24,dipelk)
            SAVEPOINT make_company_insert;
            BEGIN
               newrec_ := emptyrec_;
               newrec_.company       := crecomp_rec_.company;
               newrec_.user_group    := rec_.user_group;
               newrec_.userid        := fnd_user_;
               counter_ := counter_ + 1;
               IF (counter_ = 1) THEN
                  newrec_.default_group := 'Y'; 
               ELSE
                  newrec_.default_group := 'N'; 
               END IF;
               New___(newrec_);
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  @ApproveTransactionStatement(2014-03-24,dipelk)
                  ROLLBACK TO make_company_insert;
                  Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                                   
            END;
         END LOOP;   
      END IF;

      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedSuccessfully', msg_);                                                   
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedSuccessfully');                  
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedWithErrors');                     
         END IF;                     
      END IF;      
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- update_by_key_ and empty_lu are FALSE
   IF (NOT update_by_key_ AND NOT empty_lu_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'Error', msg_);                                                
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'USER_GROUP_MEMBER_FINANCE_API', 'CreatedWithErrors');                           
END Copy___;


PROCEDURE Export___ (
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_              NUMBER := 1;
   
   CURSOR get_data IS
      SELECT user_group, userid, default_group
      FROM   user_group_member_finance_tab 
      WHERE  company = crecomp_rec_.company;      

   CURSOR get_def_data IS
       SELECT *
       FROM   create_company_template_pub
       WHERE  COMPONENT = 'ACCRUL' 
       AND    LU    = lu_name_ 
       AND    template_id = crecomp_rec_.user_template_id;  
           
BEGIN
   IF (crecomp_rec_.user_template_id IS NULL) THEN
      FOR pctrec_ IN get_data LOOP
            pub_rec_.template_id := crecomp_rec_.template_id;
            pub_rec_.component := 'ACCRUL';
            pub_rec_.version  := crecomp_rec_.version;
            pub_rec_.lu := lu_name_;
            pub_rec_.item_id := i_;
            pub_rec_.c1 := pctrec_.user_group;
            pub_rec_.c2 := pctrec_.userid;
            pub_rec_.c3 := pctrec_.default_group;
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
         IF ( pctrec_.c2 = '<APPOWNER>' ) THEN
            -- Using <APPOWNER> was an old construction used prior to Accrul 8.12.0
            pub_rec_.c2 := '<FNDUSER>';
         ELSE
            pub_rec_.c2 := pctrec_.c2;
         END IF; 
         pub_rec_.c3 := pctrec_.c3;
         Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
         i_ := i_ + 1;
      END LOOP;
   END IF;
END Export___;

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'DEFAULT_GROUP', Finance_Yes_No_API.Get_Client_Value(0), attr_ );
END Prepare_Insert___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT NOCOPY user_group_member_finance_tab%ROWTYPE,
   indrec_ IN OUT NOCOPY Indicator_Rec,
   attr_   IN OUT NOCOPY VARCHAR2 )
IS   
BEGIN
   super(newrec_, indrec_, attr_);
   IF (newrec_.default_group = 'N') THEN
      Check_If_Default_Exist__(newrec_.company, newrec_.user_group, newrec_.userid);
   END IF;
END Check_Insert___;

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT user_group_member_finance_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   IF (newrec_.default_group = 'Y') THEN
      Update_Default__(newrec_.company, newrec_.user_group, newrec_.userid);
   END IF;   
   super(objid_, objversion_, newrec_, attr_);
   --Add post-processing code here
END Insert___;



@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     user_group_member_finance_tab%ROWTYPE,
   newrec_     IN OUT user_group_member_finance_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   IF (newrec_.default_group = 'Y') THEN
      Update_Default__(newrec_.company, newrec_.user_group, newrec_.userid);
   END IF;   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);   
END Update___;

@Override
PROCEDURE Check_Delete___(
   remrec_ IN user_group_member_finance_tab%ROWTYPE)
IS
   count_ NUMBER;
BEGIN
   IF (remrec_.default_group = 'Y') THEN
      User_Group_Member_Finance_API.Count_User_Groups_Per_User__(count_, remrec_.company, remrec_.userid);   
      IF (count_ > 1) THEN
         Error_Sys.Record_General(lu_name_, 'NOTALLOWEDDELETE: This is the default group for this user. Before you delete, set one of the other user groups connected to :P1 as default.', remrec_.userid);
      ELSE
         Client_SYS.Add_Warning(lu_name_, 'DEFAULTGROUP: This will delete the default user group for this user. No other user group is connected to the user :P1.', remrec_.userid);
      END IF;
   END IF;
   super(remrec_);
END Check_Delete___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Pre_Delete__ (
   company_         IN VARCHAR2,
   userid_          IN VARCHAR2 )
IS
   CURSOR attr_val IS
      SELECT 'X'
      FROM   user_group_member_finance_tab
      WHERE  company = company_
      AND    userid =  userid_;
   dummy_ VARCHAR2(1);
BEGIN
   OPEN attr_val;
   FETCH attr_val INTO dummy_;
   CLOSE attr_val;
   IF (dummy_ = 'X') THEN
      Error_SYS.Record_General( 'UserGroupMemberFinance', 'ISUSED: The Dependent data is still exist !');
   END IF;
END Pre_Delete__;


PROCEDURE Update_Default__ (
   company_        IN VARCHAR2,
   user_group_     IN VARCHAR2,
   userid_         IN VARCHAR2 )
IS
BEGIN
   UPDATE user_group_member_finance_tab
   SET   default_group = 'N'
   WHERE company = company_
   AND   userid = userid_;
   --
   UPDATE user_group_member_finance_tab
   SET   default_group = 'Y'
   WHERE company = company_
   AND   userid = userid_
   AND   user_group = user_group_;
END Update_Default__;


PROCEDURE Check_If_Default_Exist__ (
   company_    IN VARCHAR2,
   user_group_ IN VARCHAR2,
   userid_     IN VARCHAR2 )
IS
   x_     VARCHAR2(1);
   CURSOR check_default IS
      SELECT 'X'
      FROM  user_group_member_finance_tab
      WHERE company = company_
      AND userid = userid_
      AND default_group = 'Y';
BEGIN
   OPEN check_default;
   FETCH check_default INTO x_;
   IF (check_default%NOTFOUND) THEN
      CLOSE check_default;
      Error_SYS.Record_General(lu_name_, 'NO_DEF_TYPE1: There must exist a default group for this user');
   ELSE
      CLOSE check_default;
   END IF;
END Check_If_Default_Exist__;


PROCEDURE Check_If_This_Is_Default__ (
   company_    IN VARCHAR2,
   user_group_ IN VARCHAR2,
   userid_     IN VARCHAR2 )
IS
   x_       VARCHAR2(1);
   CURSOR check_default IS
      SELECT 'X'
      FROM  user_group_member_finance_tab
      WHERE company = company_
      AND userid = userid_
      AND user_group = user_group_
      AND default_group = 'Y';
BEGIN
   OPEN check_default;
   FETCH check_default INTO x_;
   IF (check_default%NOTFOUND) THEN
      CLOSE check_default;
   ELSE
      CLOSE check_default;
      Error_SYS.Record_General(lu_name_, 'IS_DEF: This is the default group for this user - it cannot be deleted');
   END IF;
END Check_If_This_Is_Default__;


PROCEDURE Count_User_Groups_Per_User__ (
   count_ OUT NUMBER,
   company_ IN VARCHAR2,
   userid_ IN VARCHAR2 )
IS
   CURSOR get_count IS
      SELECT COUNT(*)
      FROM user_group_member_finance_tab
      WHERE company = company_
      AND   userid  = userid_ ;
BEGIN
   OPEN get_count;
   FETCH get_count INTO count_;
   CLOSE get_count;
END Count_User_Groups_Per_User__;


PROCEDURE Create_Client_Mapping__ (
   client_window_ IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
 
   clmapprec_    Client_Mapping_API.Client_Mapping_Pub;
   clmappdetrec_ Client_Mapping_API.Client_Mapping_Detail_Pub;
BEGIN
   clmapprec_.module := module_;
   clmapprec_.lu := lu_name_;
   clmapprec_.mapping_id := 'CCD_USERFINANCE';
   clmapprec_.client_window := client_window_;  
   clmapprec_.rowversion := sysdate;
   Client_Mapping_API.Insert_Mapping(clmapprec_);

   clmappdetrec_.module := module_;
   clmappdetrec_.lu := lu_name_;
   clmappdetrec_.mapping_id :=  'CCD_USERFINANCE';
   clmappdetrec_.column_type := 'NORMAL';  
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := sysdate;  

   clmappdetrec_.column_id := 'C1' ;
   clmappdetrec_.translation_link := 'USER_FINANCE.USERID';
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
      module_, lu_name_, 'USER_GROUP_MEMBER_FINANCE_API',
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      'CCD_USERGROUPMEMBERFINANCE', 'C1^C2');
   Enterp_Comp_Connect_V170_API.Reg_Add_Table(
      module_,'USER_GROUP_MEMBER_FINANCE_TAB',
      CASE standard_table_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END);  
   Enterp_Comp_Connect_V170_API.Reg_Add_Table_Detail(
      module_,'USER_GROUP_MEMBER_FINANCE_TAB','COMPANY','<COMPANY>');
   execution_order_ := execution_order_+1;
END Create_Company_Reg__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Get_User_Group_ (
   user_group_    IN  OUT VARCHAR2,
   company_ IN VARCHAR2,
   user_name_ IN VARCHAR2 )
IS
   user_group_missing     EXCEPTION;
   user_group_tmp_        user_group_member_finance_tab.user_group%type;
BEGIN
   user_group_tmp_ := Get_User_Group___(company_, user_name_);
   IF (user_group_tmp_ IS NULL) THEN
      RAISE user_group_missing;
   END IF;
   user_group_ := user_group_tmp_;
EXCEPTION
   WHEN user_group_missing THEN
       Error_SYS.Appl_General(lu_name_,'NOUSERGR: You are not registered in any user group.');
END Get_User_Group_;

@UncheckedAccess
PROCEDURE Get_User_Group_Of_User_ (
   user_group_ IN OUT VARCHAR2,
   company_ IN VARCHAR2,
   userid_ IN VARCHAR2 )
IS
   current_user_  VARCHAR2(30);  
BEGIN
   current_user_ := User_Finance_API.User_Id;
   IF  Is_User_Member_Of_Group ( company_, current_user_, user_group_ ) = 'FALSE' THEN
      user_group_ := Get_Default_Group(company_, current_user_);   
   END IF;   
END Get_User_Group_Of_User_;

FUNCTION Get_User_Group_Of_User_ (      
   company_    IN VARCHAR2,
   user_group_ IN VARCHAR2,
   userid_     IN VARCHAR2 ) RETURN VARCHAR2
IS
   new_user_group_  user_group_member_finance_tab.user_group%type;   
BEGIN
   new_user_group_ := user_group_;
   Get_User_Group_Of_User_(new_user_group_, company_, userid_); 
   RETURN new_user_group_;
END Get_User_Group_Of_User_;   

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_User_Groups (
   company_   IN VARCHAR2,
   user_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_groups_          VARCHAR2(2000);
   CURSOR get_user_groups IS
      SELECT user_group
      FROM   user_group_member_finance_tab
      WHERE  company = company_
      AND    userid  = user_name_;
BEGIN
   FOR user_rec_ IN get_user_groups LOOP
      user_groups_ := user_groups_ || user_rec_.user_group || ',';
   END LOOP;
   RETURN user_groups_;
END Get_User_Groups;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Get_User_Group (
   user_group_         IN OUT VARCHAR2,
   company_            IN     VARCHAR2,
   user_name_          IN     VARCHAR2 )
IS
   user_group_missing     EXCEPTION;
   user_group_tmp_   user_group_member_finance_tab.user_group%type;
BEGIN
   user_group_tmp_ := Get_User_Group___(company_, user_name_);
   IF (user_group_tmp_ IS NULL) THEN  
      RAISE user_group_missing;
   END IF;
   user_group_ := user_group_tmp_;
EXCEPTION
   WHEN user_group_missing THEN
      Error_SYS.Appl_General(lu_name_,'NOUSERGR: You are not registered in any user group.');
END Get_User_Group;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_User_Group (
   company_   IN VARCHAR2,
   user_name_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_group_          VARCHAR2(2000);
BEGIN
   user_group_ := Get_User_Group___(company_, user_name_);
   RETURN user_group_;
END Get_User_Group;


PROCEDURE Get_User_Group (
   user_groups_ OUT VARCHAR2,
   default_user_group_ OUT VARCHAR2,
   company_ IN VARCHAR2,
   voucher_date_ IN DATE )
IS
   user_name_          VARCHAR2(30);
   user_group_         user_group_member_finance_tab.user_group%type;
   accounting_year_    NUMBER;
   accounting_period_  NUMBER;
   dummy_user_type_    VARCHAR2(500);
   chk_exist_          NUMBER;

   CURSOR user_groups IS
      SELECT user_group
      FROM user_group_member_finance_tab
      WHERE userid = user_name_
      AND company = company_;
BEGIN
   user_groups_ := CHR(31);
   user_name_ := User_Finance_API.User_Id;
   FOR usgroups_ IN  user_groups LOOP
      user_group_ := usgroups_.user_group;
      User_Group_Period_API.Get_Period(accounting_year_,
                                       accounting_period_,
                                       company_,
                                       user_group_,
                                       voucher_date_);
      IF (User_Group_Period_API.Is_Period_Open(company_,
                                               accounting_year_,
                                               accounting_period_,
                                               user_group_ ) = 'TRUE') THEN

         chk_exist_ := 0;
         dummy_user_type_ := NULL;
         dummy_user_type_ := CHR(31)||user_group_||CHR(31);
         chk_exist_ := INSTR(user_groups_, dummy_user_type_, 1, 1);

         IF (chk_exist_ = 0) THEN
            user_groups_:=user_groups_||user_group_||CHR(31);
         END IF;
      END IF;
   END LOOP;
   default_user_group_ := Get_Default_Group(company_, user_name_);
END Get_User_Group;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_User_Group_Description (
   company_    IN VARCHAR2,
   user_group_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   description_   VARCHAR2(100);
   CURSOR get_user_group_description IS
      SELECT  description
      FROM    user_group_finance_tab
      WHERE   company = company_
      AND     user_group = user_group_;
BEGIN
   OPEN get_user_group_description;
   FETCH get_user_group_description INTO description_;
   IF (get_user_group_description%NOTFOUND) THEN
      CLOSE get_user_group_description;
      description_ := NULL;
   ELSE
      CLOSE get_user_group_description;
   END IF;
   RETURN description_;
END Get_User_Group_Description;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Default_Group (
   company_ IN VARCHAR2,
   userid_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_group_          user_group_member_finance_tab.user_group%type;
   CURSOR get_default_group IS
      SELECT user_group
      FROM   user_group_member_finance_tab
      WHERE  company = company_
      AND  userid  = userid_
      AND  Default_group = 'Y';
BEGIN
   OPEN get_default_group;
   FETCH get_default_group INTO user_group_;
   CLOSE get_default_group;
   RETURN user_group_;
END Get_Default_Group;








@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_User_Member_Of_Group (
   company_    IN VARCHAR2,
   user_name_  IN VARCHAR2,
   user_group_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   exist_    NUMBER;
   CURSOR get_check IS
      SELECT 1
      FROM USER_GROUP_MEMBER_FINANCE_TAB
      WHERE company    = company_
      AND userid     = user_name_
      AND user_group = user_group_;
BEGIN
   OPEN get_check;
   FETCH get_check INTO exist_;
   IF get_check%NOTFOUND THEN
      CLOSE get_check;
      RETURN( 'FALSE' );
   END IF;
   CLOSE get_check;
   RETURN( 'TRUE' );
END Is_User_Member_Of_Group;




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
         Import___(rec_);         
      ELSIF (rec_.action = 'DUPLICATE') THEN 
         Copy___(rec_);         
      END IF;      
   END IF;
END Make_Company;


FUNCTION Get_User_Group_Of_User_Web (
   user_group_ IN VARCHAR2,
   company_    IN VARCHAR2,
   user_id_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_group2_        user_group_member_finance_tab.user_group%type;
   current_user_       VARCHAR2(30);
   is_user_member_     VARCHAR2(5);
BEGIN
   is_user_member_ := Is_User_Member_Of_Group ( company_, current_user_, user_group_ );
   current_user_ := User_Finance_API.User_Id;
   IF (user_id_ != current_user_) OR (is_user_member_ = 'FALSE') THEN
      user_group2_ := Get_Default_Group ( company_, current_user_ );
   END IF;
   IF (user_group2_ IS NOT NULL) THEN
      RETURN user_group2_;
   ELSIF (is_user_member_ = 'TRUE') THEN
      RETURN user_group_;
   ELSE
      RETURN user_group2_;
   END IF;   
END Get_User_Group_Of_User_Web;


@UncheckedAccess
FUNCTION User_Group_Exist (
   company_    IN VARCHAR2,
   user_group_ IN VARCHAR2,
   userid_     IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist___(company_, user_group_, userid_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END User_Group_Exist;




PROCEDURE Check_Valid_User (
   company_        IN VARCHAR2,
   user_group_     IN VARCHAR2) 
IS
   user_name_ VARCHAR2(30);
BEGIN
   user_name_ := Fnd_Session_API.Get_Fnd_User;
   IF (Is_User_Member_Of_Group(company_,
                               user_name_,
                               user_group_)= 'FALSE')THEN
      Error_SYS.appl_general(lu_name_, 'NOTAUTHORIZEDUSER: User :P1 does not belong to :P2 user group. ',user_name_,user_group_); 
   END IF;                                                       
                                              
END Check_Valid_User;


