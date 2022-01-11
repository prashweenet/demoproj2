-----------------------------------------------------------------------------
--
--  Logical unit: ProjectCostElement
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  070621  Bmekse Created
--  070810  Shwilk Done Assert_SYS corrections.
--  080326  DIFELK Bug 71921 corrected. Added dynamic calls to procedure Copy___
--  080428  JARALK  Bug 73185 Merge of the PEAK developments to supp
--  090605  THPELK  Bug 82609 - Added UNDEFINE section and the missing statements for VIEW_LOV, VIEWPCT.
            --  090216  MAKRLK Added column element_type to PROJECT_COST_ELEMENT_TAB
            --  090604  MAKRLK added column element_type to PROJECT_COST_ELEMENT_PCT
            --                 and modified the mothods Copy___(),Export___() and Import___() 
            --  090625  MAKRLK Added the function Get_Element_Type()
            --  090924  JANSLK Added view PROJECT_COST_TYPE_ELEMENT_LOV which shows only cost type follow-up elements.
            --  100121  MAKRLK  TWIN PEAKS Merge.
--  100930  MAKRLK  Bug 93297 Modified the method Unpack_Check_Insert___() to restrict the use of 1,2,3,4 as cost elements.
--  101201   Ersruk Added the function Check_Exist() and validation for node in Unpack_Check_Insert___().
--  101209   Ersruk Added validation for Cost Element in Project CBS in Check_Delete___().
--  101221  NEKOLK  EAPM-12247 Modified error message related to the tag COSTELEMENTNOTALLOW.
--  110330  SAALLK  Merged Bug 94009.
--  110727  RUFELK  FIDEAGLE-889 - Merged Bug ID 97212.
--  110915  DeKoLK  EASTTWO-13493 Modified Check_Delete___ to check if there exists estimats on Project Activity, when deleting a cost element.
--  110918  DeKoLK  EASTTWO-13980 Modified Check_Delete___ to check if cost element is used in project connected task, when deleting a cost element.
--  110921  DeKoLK  EASTTWO-11061 Modified Check_Delete___ to check if cost element is used in Project Cost/Revenue Element per Code Part Value window, when deleting a cost element.
--  111001  DeKoLK  EASTTWO-13980 Modified Check_Delete___ to check if cost element is used in Resource Groups,Change Order and Document Package when deleting a cost element.
--  111025  Saallk  SPJ-662, Modified Check_Delete___() to check if project element is used in secondary mapping.
--  120228  Sacalk  SFI-2396, Added Default_No_Base column
--  120321  Sacalk  EASTRTM-2647, modified in Export___ and in Import___
--  120404  Sacalk  EASTRTM-6275, modified in Import___
--  121018  Mawelk  Bug 105738 Fixed.
--  121207  Maaylk  PEPA-183, Removed global variables
--  121220  Jobase  Bug 107348, Merged Budget and Forecast Revenue.
--                  Added element_type_db to PROJECT_COST_ELEMENT_LOV and added PROJECT_REV_TYPE_ELEMENT_LOV
--  171107  HWIDLK  STRPJ-25160 Modified the Import___ procedure to allow a default revenue element.
--  200701  Tkavlk  Bug 154601, Added Remove_Company
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------
 

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Copy___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_      project_cost_element_tab%ROWTYPE;
   empty_rec_   project_cost_element_tab%ROWTYPE;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  project_cost_element_tab src
      WHERE company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1
                      FROM  project_cost_element_tab
                      WHERE company = crecomp_rec_.company
                      AND   project_cost_element = src.project_cost_element);
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
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithErrors');
END Copy___;
   
      
PROCEDURE Export___ (
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM  project_cost_element_tab
      WHERE company = crecomp_rec_.company;
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
   crecomp_rec_ IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   newrec_               PROJECT_COST_ELEMENT_TAB%ROWTYPE;
   empty_rec_            PROJECT_COST_ELEMENT_TAB%ROWTYPE;
   msg_                  VARCHAR2(2000);
   i_                    NUMBER  := 0;
   run_crecomp_          BOOLEAN := FALSE;
   temp_                 NUMBER  := 0 ;
   dup_default_revenue_  BOOLEAN := FALSE;
   dup_default_cost_     BOOLEAN := FALSE;
   dup_cost_no_base_     BOOLEAN := FALSE;
   revenue_no_base_      BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT C1, C2, C3, C5 , C6
      FROM   Create_Company_Template_Pub src
      WHERE  component = 'ACCRUL'
      AND    lu    = lu_name_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM PROJECT_COST_ELEMENT_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND dest.project_cost_element = src.C1);

   CURSOR check_default_revenue IS
       SELECT 1
       FROM   project_cost_element_tab
       WHERE  default_cost_element = 'TRUE'
       AND    company              = crecomp_rec_.company
       AND    element_type         = 'REVENUE';
       
   CURSOR check_default_cost IS
       SELECT 1
       FROM   project_cost_element_tab
       WHERE  default_cost_element = 'TRUE'
       AND    company              = crecomp_rec_.company
       AND    element_type         = 'COST';

   CURSOR check_default_no_base_cost IS
       SELECT 1
       FROM   project_cost_element_tab
       WHERE  default_no_base = 'TRUE'
       AND    company         = crecomp_rec_.company
       AND    element_type    = 'COST';

BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_);
   
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2014-03-25,dipelk)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_                          := empty_rec_;

            newrec_.company                  := crecomp_rec_.company;
            newrec_.project_cost_element     := rec_.c1;
            newrec_.description              := rec_.c2;
            newrec_.element_type             := rec_.c5; 

            IF (newrec_.element_type = 'REVENUE') THEN
               OPEN check_default_revenue;
               FETCH check_default_revenue INTO temp_;
               IF (check_default_revenue%FOUND) THEN
                  IF (rec_.c3 = 'TRUE') THEN
                     dup_default_revenue_      := TRUE;
                  END IF;
                  CLOSE check_default_revenue;
                  newrec_.default_cost_element := 'FALSE';
               ELSE
                  CLOSE check_default_revenue;
                  newrec_.default_cost_element := rec_.c3;
               END IF;
               
               IF (rec_.c6  = 'TRUE') THEN
                  newrec_.default_no_base      := 'FALSE';
                  revenue_no_base_             := TRUE;
               END IF;
            ELSE
               OPEN check_default_cost;
               FETCH check_default_cost INTO temp_;
               IF (check_default_cost%FOUND) THEN
                  IF (rec_.c3 = 'TRUE') THEN
                     dup_default_cost_         := TRUE;
                  END IF;
                  CLOSE check_default_cost;
                  newrec_.default_cost_element := 'FALSE';
               ELSE
                  CLOSE check_default_cost;
                  newrec_.default_cost_element := rec_.c3;
               END IF;
               
               OPEN check_default_no_base_cost;
               FETCH check_default_no_base_cost INTO temp_;
               IF (check_default_no_base_cost%FOUND) THEN
                  IF (rec_.c6 = 'TRUE') THEN
                     dup_cost_no_base_         := TRUE;
                  END IF;
                  CLOSE check_default_no_base_cost;
                  newrec_.default_no_base      := 'FALSE';
               ELSE
                  CLOSE check_default_no_base_cost;
                  newrec_.default_no_base      := rec_.c6;
               END IF;
            END IF;
            
            -- In case description is missing in template due to use of old template.
            IF ( newrec_.description IS NULL ) THEN
               newrec_.description  := newrec_.project_cost_element;
            END IF;

            IF (newrec_.default_cost_element IS NULL ) THEN
               newrec_.default_cost_element  := 'FALSE';
            END IF;

            IF (newrec_.default_no_base IS NULL ) THEN
               newrec_.default_no_base  := 'FALSE';
            END IF;
            New___(newrec_);

         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2014-03-25,dipelk)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'Error', msg_);
         END;
      END LOOP;
      
      IF (dup_default_revenue_) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'DUPDEFAULTREVENUE: A Revenue Element has already been set as Default');
         Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithComments', msg_);
      END IF;
      
      IF (dup_default_cost_) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'DUPDEFAULTCOST: A Cost Element has already been set as Default');
         Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithComments', msg_);
      END IF;

      IF (dup_cost_no_base_) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'DUPCOSTDEFAULTNOBASE: A Cost Element has already been set as Default No Base Value');
         Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithComments', msg_);
      END IF;

      IF (revenue_no_base_)THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'REVDEFAULTNOBASE: It is not possible to set a Revenue Element as Default No Base Value');
         Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithComments', msg_);
      END IF ;

      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   
   -- This statement is to add to the log that the Create company process for LUs is finished if
   -- update_by_key_ and empty_lu are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedSuccessfully');
   END IF;
   
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'Error', msg_);                                          
      Enterp_Comp_Connect_V190_API.Log_Logging(crecomp_rec_.company, module_, 'PROJECT_COST_ELEMENT_API', 'CreatedWithErrors');                           
END Import___;


@Override
PROCEDURE Export_Assign___ (
   pub_rec_     IN OUT Enterp_Comp_Connect_V170_API.Tem_Public_Rec,
   crecomp_rec_ IN     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   exprec_      IN     project_cost_element_tab%ROWTYPE )
IS
BEGIN
   super(pub_rec_, crecomp_rec_, exprec_);
   pub_rec_.c4 := 'FALSE'; 
END Export_Assign___;
   

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr( 'DEFAULT_COST_ELEMENT', 'FALSE', attr_);   
   Client_SYS.Add_To_Attr( 'DEFAULT_NO_BASE', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT PROJECT_COST_ELEMENT_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);

   $IF (Component_Projbf_SYS.INSTALLED) $THEN      
      Proj_C_Cost_El_Code_P_Dem_API.Insert_Auto( newrec_.company, newrec_.project_cost_element );     
   $END   
EXCEPTION
   WHEN dup_val_on_index THEN      
      Error_SYS.Record_General(lu_name_, 'OBJECTNOTEXIST: The Project Cost/Revenue Element object already exists');      
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     PROJECT_COST_ELEMENT_TAB%ROWTYPE,
   newrec_     IN OUT PROJECT_COST_ELEMENT_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN      
      Error_SYS.Record_General(lu_name_, 'OBJECTNOTEXIST: The Project Cost/Revenue Element object already exists');      
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN PROJECT_COST_ELEMENT_TAB%ROWTYPE )
IS
   activity_seq_        NUMBER;
   resource_id_         VARCHAR2(100);
   package_no_          VARCHAR2(10);

BEGIN

   -- Check if project element is used in secondary mapping
   Cost_Ele_To_Accnt_Secmap_API.Check_Project_Element_Used(remrec_.company, remrec_.project_cost_element);

   $IF (Component_Projbf_SYS.INSTALLED) $THEN
      --Check if the attribute value is used as a cost element code part demand in project basic data
      IF Proj_Cost_El_Code_P_Dem_API.Check_Exist(remrec_.company, remrec_.project_cost_element) = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'CANTRMVATTVAL: It is not possible to remove Project Cost Element :P1 since it is used in Company :P2 in PCE Code Part Info Tab in Project.', remrec_.project_cost_element, remrec_.company);
      END IF;
   $END

   IF (Cost_Structure_Item_API.Check_Cost_Element_Exist( remrec_.company, remrec_.project_cost_element ) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'EXISTINPROJSTRUCTURE: It is not possible to remove Project Cost Element :P1 since it is used in Project Cost Breakdown Structure for Company :P2.', remrec_.project_cost_element, remrec_.company);
   END IF;

   IF(Cost_Element_To_Account_API.Is_Account_Connected(remrec_.company, remrec_.project_cost_element)) THEN
      Error_SYS.Record_General(lu_name_, 'EXISTINCODEPART: It is not possible to delete Cost/Revenue Element :P1, as it has been linked to a Code Part in the ''Project Cost/Revenue Element per Code Part Value'' window.', remrec_.project_cost_element);
   END IF;

   $IF Component_Proj_SYS.INSTALLED $THEN
      activity_seq_ := Activity_Estimate_API.Check_For_Activity_Estimates( remrec_.company, remrec_.project_cost_element );
      IF (activity_seq_ != 0) THEN
         Error_SYS.Record_General(lu_name_, 'EXISTINPROJCOSTESTIMATE: It is not possible to remove Project Cost Element :P1 since it is connected to an estimated value on project activity :P2.', remrec_.project_cost_element,activity_seq_);
      END IF;
   $END

   $IF Component_Proj_SYS.INSTALLED $THEN
      Activity_Task_API.Check_Cost_Elements_On_Tasks(remrec_.company, remrec_.project_cost_element);
   $END

   $IF Component_Proj_SYS.INSTALLED $THEN
      resource_id_ := Resource_Cost_Element_API.Check_Project_Cost_Elements( remrec_.company, remrec_.project_cost_element );
      IF (resource_id_ IS NOT NULL) THEN
         Error_SYS.Record_General(lu_name_, 'EXISTINRESGROUP: It is not possible to remove Project Cost Element :P1 since it is used by Resource Group :P2.', remrec_.project_cost_element,resource_id_);
      END IF;
   $END

   $IF Component_Pdmcon_SYS.INSTALLED $THEN
       Eco_Action_API.Check_Project_Cost_Elements (remrec_.company, remrec_.project_cost_element);
   $END

   $IF Component_Docman_SYS.INSTALLED $THEN
      package_no_ := Doc_Package_Template_API.Check_Project_Cost_Elements(remrec_.company, remrec_.project_cost_element);
      IF (package_no_ IS NOT NULL) THEN
          Error_SYS.Record_General(lu_name_, 'COSTELEMENTINDOCPKG: It is not possible to remove Project Cost Element :P1 since it is used in Document Package :P2.', remrec_.project_cost_element,package_no_);
      END IF;
   $END

   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     project_cost_element_tab%ROWTYPE,
   newrec_ IN OUT project_cost_element_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN   
   super(oldrec_, newrec_, indrec_, attr_);
   
   ----JADASE
   /*IF (newrec_.default_cost_element = 'TRUE') THEN      
      IF (newrec_.element_type = 'REVENUE') THEN
         Error_SYS.Record_General(lu_name_, 'ONLYCOSTDEFAULT: It is only allowed to set one cost element as default per company. The element must be of the element type Cost.');
      END IF;
   END IF;*/  
   ---- JADASE
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT project_cost_element_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   
   IF (newrec_.project_cost_element IN ('1','2','3','4')) THEN
         Error_SYS.Record_General( lu_name_,'COSTELEMENTNOTALLOW: 1, 2, 3 and 4 are not allowed to be used as cost/revenue elements.');
   END IF;
   -- It is not allowed to save a Project Cost Element with value 4. This since in the 
   -- old concept was 4 reserved for hours
   IF (newrec_.project_cost_element = '4') THEN
         Error_SYS.Record_General( lu_name_,
                                   'COSTREVELEMENTHOUR: Project Cost/Revenue Element :P1 is reserved for Hours.', newrec_.project_cost_element );
   END IF;   

   IF (Cost_Structure_Item_API.Check_Node_Exist( newrec_.company, newrec_.project_cost_element ) = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'EXISTPROJSTRUCTURE: A Node with the proposed name already exists in Project Cost Breakdown Structure.');
   END IF;
END Check_Insert___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Check_Default_Element__ (
   company_ IN VARCHAR2)
IS
   ---- JADASE
   nr_of_c_elements_ NUMBER := 0; 
   nr_of_r_elements_ NUMBER := 0;
      
   CURSOR  count_cost IS
      SELECT   count(*) count
      FROM     PROJECT_COST_ELEMENT_TAB
      WHERE    company              = company_
      AND      default_cost_element = 'TRUE'
      AND      element_type = 'COST';
      
   CURSOR  count_revenue IS
      SELECT   count(*) count
      FROM     PROJECT_COST_ELEMENT_TAB
      WHERE    company              = company_
      AND      default_cost_element = 'TRUE'
      AND      element_type = 'REVENUE';
BEGIN
   OPEN count_cost;
   FETCH count_cost INTO nr_of_c_elements_;
   CLOSE count_cost;
   
   OPEN count_revenue;
   FETCH count_revenue INTO nr_of_r_elements_;
   CLOSE count_revenue;
   
   IF (nr_of_c_elements_ + nr_of_r_elements_ >= 3) THEN
      Error_SYS.Record_General(lu_name_,'ONEREVENUEONECOST: It is only allowed to set two default values per company. One for a Cost element and one for a Revenue element.');
   ELSIF (nr_of_c_elements_ > 1) THEN 
      Error_SYS.Record_General(lu_name_, 'TWOCOSTELEMENTS: It is only allowed to set one Cost element as default per company.');
   ELSIF (nr_of_r_elements_ > 1) THEN   
      Error_SYS.Record_General(lu_name_, 'TWOREVENUEELEMENTS: It is only allowed to set one Revenue element as default per company.');
   END IF; 
   ---- JADASE
END Check_Default_Element__;


PROCEDURE Check_Default_No_Base_Exist__ ( 
   result_  OUT VARCHAR2 ,
   company_ IN  VARCHAR2)
IS
    CURSOR count_default_no_base IS
      SELECT   1
      FROM     PROJECT_COST_ELEMENT_TAB 
      WHERE    company   = company_
      AND      default_no_base  = 'TRUE';
     
    count_     NUMBER  DEFAULT  0;

BEGIN
   OPEN   count_default_no_base ;
   FETCH  count_default_no_base INTO  count_ ;
   CLOSE  count_default_no_base ;     
     
   result_ := count_ ;
END Check_Default_No_Base_Exist__ ;


PROCEDURE Set_Default_No_Base__ ( 
   company_       IN  VARCHAR2,
   cost_element_  IN  VARCHAR2)
IS 
   current_default_no_base_  PROJECT_COST_ELEMENT_TAB.Project_Cost_Element%TYPE;

BEGIN

   current_default_no_base_ := Get_Default_No_Base ( company_ );

   IF ( current_default_no_base_ IS NOT NULL ) THEN 
      UPDATE PROJECT_COST_ELEMENT_TAB t
      SET    default_no_base = 'FALSE'  
      WHERE  company               = company_ 
      AND    project_cost_element  = current_default_no_base_ ;
   END IF;

   UPDATE PROJECT_COST_ELEMENT_TAB 
   SET    default_no_base = 'TRUE'  
   WHERE  company               = company_ 
   AND    project_cost_element  = cost_element_ ;
END Set_Default_No_Base__ ;


PROCEDURE Reset_Default_No_Base__ ( 
   company_       IN  VARCHAR2,
   cost_element_  IN  VARCHAR2 )
IS 
   
BEGIN
   
   UPDATE PROJECT_COST_ELEMENT_TAB t
   SET    default_no_base = 'FALSE'  
   WHERE  company               = company_ 
   AND    project_cost_element  = cost_element_ ;

END Reset_Default_No_Base__ ;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_              IN VARCHAR2,
   project_cost_element_ IN VARCHAR2 )
IS
BEGIN
   Error_SYS.Record_General(lu_name_, 'COSTREVELENOTEXIST: The Cost/Revenue Element object does not exist.');     
   super(company_, project_cost_element_);   
END Raise_Record_Not_Exist___;

@Override
PROCEDURE Raise_Record_Exist___ (
   rec_ IN project_cost_element_tab%ROWTYPE )
IS
BEGIN
   Error_Sys.Record_General(lu_name_, 'COSTREVELEEXIST: The Cost/Revenue Element object already exists.');
   super(rec_);   
END Raise_Record_Exist___;

@Override
PROCEDURE Set_Blocked__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   newrec_     project_cost_element_tab%ROWTYPE;
BEGIN
   newrec_ := Get_Object_By_Id___(objid_);   
   IF (Cost_Element_To_Account_API.Is_Account_Connected(newrec_.company,
                                                        newrec_.project_cost_element)) THEN
      Error_SYS.Record_General(lu_name_, 'CADEPVALCONNECTED: Project Cost/Revenue Element :P1 is connected to a Code Part Value. It is not allowed to set it to Blocked for Use.', newrec_.project_cost_element );         
   END IF;  
   IF (newrec_.default_cost_element = 'TRUE') THEN      
      Error_SYS.Record_General(lu_name_, 'BLOCKEDANDDEFAULT: It is not allowed to set a Project Cost/Revenue Element both to default and Blocked for Use.' );
   END IF;
   IF (newrec_.default_no_base = 'TRUE') THEN 
       Error_SYS.Record_General(lu_name_, 'CANNOTUSETOGETHER: It is not allowed to set a Project Cost/Revenue Element both to Default No Base Value and Blocked for Use.');  
   END IF ;   
   super(info_, objid_, objversion_, attr_, action_);
END Set_Blocked__;


@Override
PROCEDURE Set_Hidden__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   newrec_     project_cost_element_tab%ROWTYPE;
BEGIN
   newrec_ := Get_Object_By_Id___(objid_);
   IF (Cost_Element_To_Account_API.Is_Account_Connected(newrec_.company,
                                                        newrec_.project_cost_element)) THEN
      Error_SYS.Record_General(lu_name_, 'CADEPVALCONNECTED2: Project Cost/Revenue Element :P1 is connected to a Code Part Value. It is not allowed to set it to Hidden.', newrec_.project_cost_element );         
   END IF;  
   IF (newrec_.default_cost_element = 'TRUE') THEN      
      Error_SYS.Record_General(lu_name_, 'BLOCKEDANDDEFAULT2: It is not allowed to set a Project Cost/Revenue Element both to default and Hidden.' );
   END IF;
   IF (newrec_.default_no_base = 'TRUE') THEN 
       Error_SYS.Record_General(lu_name_, 'CANNOTUSETOGETHER2: It is not allowed to set a Project Cost/Revenue Element both to Default No Base Value and Hidden.');  
   END IF ;  
   super(info_, objid_, objversion_, attr_, action_);
END Set_Hidden__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Default_For_Company (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_default IS
      SELECT project_cost_element
      FROM   PROJECT_COST_ELEMENT_TAB
      WHERE  company              = company_
      AND    default_cost_element = 'TRUE'
      AND    element_type         = 'COST';
   dummy_ PROJECT_COST_ELEMENT_TAB.project_cost_element%TYPE;
BEGIN
   OPEN  get_default;
   FETCH get_default INTO dummy_;
   IF get_default%NOTFOUND THEN
      CLOSE get_default;
      RETURN NULL;
   ELSE
      CLOSE get_default;
      RETURN dummy_;
   END IF;   
END Get_Default_For_Company;


PROCEDURE Insert_Proj_Cost_Element (
   company_              IN VARCHAR2,
   project_cost_element_ IN VARCHAR2,
   description_          IN VARCHAR2,
   default_cost_element_ IN VARCHAR2 DEFAULT 'FALSE',   
   element_type_         IN VARCHAR2 DEFAULT 'COST' )
IS
   newrec_           PROJECT_COST_ELEMENT_TAB%ROWTYPE;
   attr_             VARCHAR2(32000);
   objid_            VARCHAR2(2000);
   objversion_       VARCHAR2(2000);

BEGIN

   newrec_.company               := company_;
   newrec_.project_cost_element  := project_cost_element_;
   newrec_.description           := description_;
   newrec_.default_cost_element  := default_cost_element_;   
   newrec_.element_type          := element_type_;

   Insert___(objid_, objversion_, newrec_, attr_); 

END Insert_Proj_Cost_Element;


@UncheckedAccess
FUNCTION Get_Element_Type_Client (
   company_                  IN VARCHAR2,
   project_followup_element_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ PROJECT_COST_ELEMENT_TAB.element_type%TYPE;
   CURSOR get_attr IS
      SELECT element_type
      FROM PROJECT_COST_ELEMENT_TAB
      WHERE company              = company_
      AND   project_cost_element = project_followup_element_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN Prj_Followup_Element_Type_API.Decode(temp_);
END Get_Element_Type_Client;


@UncheckedAccess
FUNCTION Get_Default_Rev_For_Company (
   company_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_default IS
      SELECT project_cost_element
      FROM   PROJECT_COST_ELEMENT_TAB
      WHERE  company              = company_
      AND    default_cost_element = 'TRUE'
      AND    element_type         = 'REVENUE';
   dummy_ PROJECT_COST_ELEMENT_TAB.project_cost_element%TYPE;
BEGIN
   OPEN  get_default;
   FETCH get_default INTO dummy_;
   IF get_default%NOTFOUND THEN
      CLOSE get_default;
      RETURN NULL;
   ELSE
      CLOSE get_default;
      RETURN dummy_;
   END IF;   
END Get_Default_Rev_For_Company;


@UncheckedAccess
FUNCTION Check_Exist (
   company_              IN VARCHAR2,
   project_cost_element_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   PROJECT_COST_ELEMENT_TAB
      WHERE  company              = company_
      AND    project_cost_element = project_cost_element_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Exist;

@UncheckedAccess
FUNCTION Get_Default_No_Base (
   company_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_       PROJECT_COST_ELEMENT_TAB.Project_Cost_Element%TYPE;
   
   CURSOR get_attr IS
      SELECT project_cost_element
      FROM   PROJECT_COST_ELEMENT_TAB 
      WHERE  company            =  company_
      AND    default_no_base    =  'TRUE';
BEGIN
   OPEN get_attr;
   FETCH  get_attr INTO temp_;
   CLOSE  get_attr;
   RETURN temp_;
END Get_Default_No_Base;

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_    IN VARCHAR2)
IS
BEGIN  
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN 
      $IF Component_Projbf_SYS.INSTALLED $THEN
      DELETE
         FROM PROJ_C_COST_EL_CODE_P_DEM_TAB
         WHERE company = company_; 
      $END
      DELETE
         FROM PROJECT_COST_ELEMENT_TAB
         WHERE company = company_;
   END IF;
END Remove_Company;
