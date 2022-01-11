-----------------------------------------------------------------------------
--
--  Logical unit: FinSelObjTempl
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  111121  Umdolk  SFI-339, Corrected the length of variable in Copy_Selection_Template 
--  111121          and Get_User_Default_Template
--  120316  Waudlk  EASTRTM-2636, Added Check_Template_Exists
--  151203  chiblk  STRFI-682,removing sub methods and rewriting them as implementation methods
--  200701  Tkavlk  Bug 154601, Added Remove_company

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Update_Default_Template___ (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   ownership_        IN VARCHAR2,
   owner_            IN VARCHAR2 )
IS
   rec_        FIN_SEL_OBJ_TEMPL_TAB%ROWTYPE;
   CURSOR getrec IS
      SELECT *
        FROM FIN_SEL_OBJ_TEMPL_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND ownership = ownership_
         AND owner = DECODE(ownership_, 'PRIVATE', owner_, owner)
         AND default_template = 'TRUE'
      FOR UPDATE;
BEGIN
   OPEN  getrec;
   FETCH getrec INTO rec_;
   IF (getrec%FOUND) THEN
      UPDATE FIN_SEL_OBJ_TEMPL_TAB
         SET default_template = 'FALSE'
       WHERE CURRENT OF getrec; 
   END IF;
   CLOSE getrec;
END Update_Default_Template___;

PROCEDURE Import_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   newrec_        fin_sel_obj_templ_tab%ROWTYPE;
   empty_rec_     fin_sel_obj_templ_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT *
      FROM  Create_Company_Template_Pub src
      WHERE component   = module_
      AND   lu          = lu_
      AND   template_id = crecomp_rec_.template_id
      AND   version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM  fin_sel_obj_templ_tab
                      WHERE company = crecomp_rec_.company
                      AND   object_group_id = src.c1
                      AND   template_id = src.c2);   
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_, module_);
   
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2015-02-03,ovjose)
         SAVEPOINT make_company_insert;         
         BEGIN
            newrec_ := empty_rec_;
            
            newrec_.company                       := crecomp_rec_.company;
            newrec_.object_group_id               := rec_.c1;
            newrec_.template_id                   := rec_.c2;
            newrec_.description                   := rec_.c3;
            newrec_.ownership                     := rec_.c4;
            newrec_.owner                         := rec_.c5;
            newrec_.default_template              := rec_.c6;                        
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2015-02-03,ovjose)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully', msg_);
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
END Import_Gen___;


PROCEDURE Copy_Gen___ (
   module_        IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   newrec_        fin_sel_obj_templ_tab%ROWTYPE;
   empty_rec_     fin_sel_obj_templ_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT src.*
      FROM   fin_sel_obj_templ_tab src, fin_obj_grp_tab b
      WHERE  company = crecomp_rec_.old_company
      AND    src.object_group_id = b.object_group_id
      AND    b.module = module_
      AND NOT EXISTS (SELECT 1
                      FROM  fin_sel_obj_templ_tab
                      WHERE company = crecomp_rec_.company
                      AND   object_group_id = src.object_group_id
                      AND   template_id = src.template_id);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_, module_);
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2015-02-03,ovjose)
         SAVEPOINT make_company_insert;         
         BEGIN
            -- Reset variables
            newrec_ := empty_rec_;
            -- Assign copy record
            newrec_ := rec_;
            newrec_.rowkey := NULL;
            -- Assign new values for new company, all other attributes are copied in the previous row
            newrec_.company := crecomp_rec_.company;
            newrec_.module  := NULL;
            newrec_.lu      := NULL;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2015-02-03,ovjose)
               ROLLBACK TO make_company_insert;               
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
         END;
      END LOOP;
      IF (i_ = 0) THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully', msg_);
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF (NOT run_crecomp_) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
END Copy_Gen___;


PROCEDURE Export_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   Fin_Sel_Obj_Templ_Gen_Pct
      WHERE  company = crecomp_rec_.company
      AND    module = module_
      ORDER BY template_id;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_;
      pub_rec_.item_id := i_;
      pub_rec_.c1          := pctrec_.object_group_id;
      pub_rec_.c2          := pctrec_.template_id;
      pub_rec_.c3          := pctrec_.description;
      pub_rec_.c4          := pctrec_.ownership_db;
      pub_rec_.c5          := pctrec_.owner;
      pub_rec_.c6          := pctrec_.default_template;      
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Gen___;


FUNCTION Component_Exist_Any___(
   company_    IN VARCHAR2,
   module_     IN VARCHAR2 ) RETURN BOOLEAN
IS
   b_exist_  BOOLEAN  := TRUE;
   idum_     PLS_INTEGER;
   CURSOR exist_control IS
      SELECT 1
      FROM   fin_sel_obj_templ_tab a, fin_obj_grp_tab b
      WHERE  company = company_
      AND    a.object_group_id = b.object_group_id
      AND    b.module = module_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO idum_;
   IF ( exist_control%NOTFOUND) THEN
      b_exist_ := FALSE;
   END IF;
   CLOSE exist_control;
   RETURN b_exist_;
END Component_Exist_Any___;


FUNCTION Check_If_Do_Create_Company___(
   crecomp_rec_    IN  Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   module_         IN  VARCHAR2 ) RETURN BOOLEAN
IS
   perform_update_         BOOLEAN;
   update_by_key_          BOOLEAN;
BEGIN
   perform_update_ := FALSE;
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_name_, crecomp_rec_);
   IF ( update_by_key_ ) THEN
      perform_update_ := TRUE;
   ELSE
      IF ( NOT Component_Exist_Any___( crecomp_rec_.company, module_ ) ) THEN
         perform_update_ := TRUE;
      END IF;
   END IF;
   RETURN perform_update_;
END Check_If_Do_Create_Company___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_To_Attr('DEFAULT_TEMPLATE', 'FALSE', attr_);
END Prepare_Insert___;

@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT fin_sel_obj_templ_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   fin_obj_grp_rec_  Fin_Obj_Grp_API.Public_Rec;
BEGIN
   IF newrec_.owner IS NULL THEN
      newrec_.owner := Fnd_Session_API.Get_Fnd_User;
   END IF;
   fin_obj_grp_rec_ := Fin_Obj_Grp_API.Get(newrec_.object_group_id);
   newrec_.module := fin_obj_grp_rec_.module;
   newrec_.lu := fin_obj_grp_rec_.lu;
   super(newrec_, indrec_, attr_);

END Check_Insert___;




@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT FIN_SEL_OBJ_TEMPL_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.default_template = 'TRUE' AND 
      Is_Valid_Default_Template(newrec_.company, newrec_.object_group_id, newrec_.ownership, newrec_.owner) = 'FALSE') THEN
      Update_Default_Template___ (newrec_.company, newrec_.object_group_id, newrec_.ownership, newrec_.owner);
   END IF;   
   super(objid_, objversion_, newrec_, attr_);
   Enterp_Comp_Connect_V170_API.Insert_Company_Translation(newrec_.company, newrec_.module, newrec_.lu,
      newrec_.object_group_id||'^'||newrec_.template_id,
      NULL, newrec_.description);  

END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     FIN_SEL_OBJ_TEMPL_TAB%ROWTYPE,
   newrec_     IN OUT FIN_SEL_OBJ_TEMPL_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   IF (newrec_.default_template = 'TRUE' AND 
      Is_Valid_Default_Template(newrec_.company, newrec_.object_group_id, newrec_.ownership, newrec_.owner) = 'FALSE') THEN
      Update_Default_Template___ (newrec_.company, newrec_.object_group_id, newrec_.ownership, newrec_.owner);
   END IF;   
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
   Enterp_Comp_Connect_V170_API.Insert_Company_Translation(newrec_.company, newrec_.module, newrec_.lu,
      newrec_.object_group_id||'^'||newrec_.template_id,
      NULL, newrec_.description, oldrec_.description);   
END Update___;

@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN fin_sel_obj_templ_tab%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);
   Enterp_Comp_Connect_V170_API.Remove_Company_Attribute_Key(remrec_.company, remrec_.module, remrec_.lu,
      remrec_.object_group_id||'^'||remrec_.template_id);   
END Delete___;

PROCEDURE Insert_Map_Head___(
   fin_sel_templ_module_ IN VARCHAR2,
   fin_sel_templ_lu_     IN VARCHAR2,
   client_window_        IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
   clmapprec_  Client_Mapping_API.Client_Mapping_Pub;
BEGIN
   clmapprec_.module        := fin_sel_templ_module_;
   clmapprec_.lu            := fin_sel_templ_lu_;
   clmapprec_.mapping_id    := 'CCD_'||UPPER(fin_sel_templ_lu_); -- assume naming-convention
   clmapprec_.client_window := client_window_;   
   clmapprec_.rowversion    := SYSDATE;
   Client_Mapping_API.Insert_Mapping(clmapprec_);
END Insert_Map_Head___;

PROCEDURE Insert_Map_Detail___(         
   fin_sel_templ_module_ IN VARCHAR2,
   fin_sel_templ_lu_     IN VARCHAR2,
   column_id_            IN VARCHAR2,                               
   translation_link_     IN VARCHAR2 )
IS                               
   clmappdetrec_  Client_Mapping_API.Client_Mapping_Detail_Pub;                            
BEGIN
   clmappdetrec_.module := fin_sel_templ_module_;
   clmappdetrec_.lu := fin_sel_templ_lu_;
   clmappdetrec_.mapping_id := 'CCD_'||UPPER(fin_sel_templ_lu_);  -- assume naming-convention
   clmappdetrec_.column_id := column_id_ ;
   clmappdetrec_.column_type := 'NORMAL';
   clmappdetrec_.translation_link := translation_link_;
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := SYSDATE;   
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
END Insert_Map_Detail___;    

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Create_Client_Mapping_Gen__ (
   fin_sel_templ_module_ IN VARCHAR2,
   fin_sel_templ_lu_     IN VARCHAR2,
   client_window_        IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS      
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(fin_sel_templ_module_,
                      fin_sel_templ_lu_,
                      client_window_);
   -- Insert Map Detail  
   Insert_Map_Detail___(fin_sel_templ_module_,fin_sel_templ_lu_,'C1', 'Fin_Sel_Obj_Templ_GEN_PCT.OBJECT_GROUP_ID');
   Insert_Map_Detail___(fin_sel_templ_module_,fin_sel_templ_lu_,'C2', 'Fin_Sel_Obj_Templ_GEN_PCT.TEMPLATE_ID');
   Insert_Map_Detail___(fin_sel_templ_module_,fin_sel_templ_lu_,'C3', 'Fin_Sel_Obj_Templ_GEN_PCT.DESCRIPTION');
   Insert_Map_Detail___(fin_sel_templ_module_,fin_sel_templ_lu_,'C4', 'Fin_Sel_Obj_Templ_GEN_PCT.OWNERSHIP_DB');
   Insert_Map_Detail___(fin_sel_templ_module_,fin_sel_templ_lu_,'C5', 'Fin_Sel_Obj_Templ_GEN_PCT.OWNER');
   Insert_Map_Detail___(fin_sel_templ_module_,fin_sel_templ_lu_,'C6', 'Fin_Sel_Obj_Templ_GEN_PCT.DEFAULT_TEMPLATE');  
END Create_Client_Mapping_Gen__;

PROCEDURE Create_Company_Reg_Gen__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   module_            IN     VARCHAR2,
   lu_name_           IN     VARCHAR2,
   pkg_               IN     VARCHAR2,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE )
IS
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, pkg_,
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      'FALSE',
      'CCD_'||UPPER(lu_name_),
      'C1^C2', NULL, 'C3');
   execution_order_ := execution_order_+1;
END Create_Company_Reg_Gen__;
   

PROCEDURE Check_Default_Template__ (
   warning_          OUT VARCHAR2,
   company_          IN VARCHAR,
   object_group_id_  IN VARCHAR2,
   ownership_        IN VARCHAR2,
   owner_            IN VARCHAR2 )
IS
   ownership_db_  VARCHAR2(10);
BEGIN
   warning_ := NULL;
   ownership_db_ := Fin_Ownership_API.Encode(ownership_);
   IF Is_Valid_Default_Template(company_, object_group_id_, ownership_db_, owner_) = 'FALSE' THEN
      IF ownership_db_ = 'PRIVATE' THEN
         warning_ := Language_SYS.Translate_Constant(lu_name_, 'DEFPRVEXIST: A default private template already exists for owner :P1. Do you want to set this template as default template?', NULL, owner_);
      ELSE
         warning_ := Language_SYS.Translate_Constant(lu_name_, 'DEFPUBEXIST: A default public template already exists. Do you want to set this template as default template?');
      END IF;
   END IF;
END Check_Default_Template__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Is_Valid_Default_Template (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   ownership_        IN VARCHAR2,
   owner_            IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_   NUMBER;
   CURSOR check_valid IS
      SELECT 1
        FROM FIN_SEL_OBJ_TEMPL_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND ownership = ownership_
         AND owner = DECODE(ownership_, 'PRIVATE', owner_, owner)
         AND default_template = 'TRUE';
BEGIN
   OPEN  check_valid;
   FETCH check_valid INTO dummy_;
   IF check_valid%FOUND THEN
      CLOSE check_valid;
      RETURN 'FALSE';
   END IF;
   CLOSE check_valid;
   RETURN 'TRUE';
END Is_Valid_Default_Template;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Copy_Selection_Template (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_      IN VARCHAR2,
   new_template_id_  IN VARCHAR2,
   description_      IN VARCHAR2,
   ownership_        IN VARCHAR2 )
IS
   user_          VARCHAR2(20) := Fnd_Session_API.Get_Fnd_User;
   ownership_db_  VARCHAR2(10);
   item_id_       NUMBER;
   attr_          VARCHAR2(2000);

   CURSOR get_head IS
      SELECT *
        FROM FIN_SEL_OBJ_TEMPL_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND template_id = template_id_;

   CURSOR get_item IS
      SELECT *
        FROM fin_sel_obj_templ_det_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND template_id = template_id_;
   
   CURSOR get_values IS
      SELECT *
        FROM fin_sel_templ_values_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND template_id = template_id_
         AND item_id = item_id_;
   
BEGIN
   ownership_db_ := Fin_Ownership_API.Encode(ownership_);
   FOR head_ IN get_head LOOP
      INSERT
         INTO fin_sel_obj_templ_tab (
            company,
            object_group_id,
            template_id,
            description,
            ownership,
            owner,
            default_template,
            module,
            lu,
            rowversion)
         VALUES (
            head_.company,
            head_.object_group_id,
            new_template_id_,
            description_,
            ownership_db_,
            user_,
            'FALSE',
            head_.module,
            head_.lu,
            SYSDATE);
   END LOOP;

   FOR item_ IN get_item LOOP
      attr_ := NULL;
      Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr('OBJECT_GROUP_ID', object_group_id_, attr_);
      Client_SYS.Add_To_Attr('TEMPLATE_ID', new_template_id_, attr_);
      Client_SYS.Add_To_Attr('ITEM_ID', item_.item_id, attr_);
      Client_SYS.Add_To_Attr('SELECTION_OBJECT_ID', item_.selection_object_id, attr_);
      Client_SYS.Add_To_Attr('SELECTION_OPERATOR_DB', item_.selection_operator, attr_);
      Client_SYS.Add_To_Attr('VALUE_FROM', item_.value_from, attr_);
      Client_SYS.Add_To_Attr('VALUE_TO', item_.value_to, attr_);
      Client_SYS.Add_To_Attr('VALUE_FROM_DATE', item_.value_from_date, attr_);
      Client_SYS.Add_To_Attr('VALUE_TO_DATE', item_.value_to_date, attr_);
      Client_SYS.Add_To_Attr('VALUE_EXIST', item_.value_exist, attr_);
      Client_SYS.Add_To_Attr('MANUAL_INPUT_DB', item_.manual_input, attr_);

      Fin_Sel_Obj_Templ_Det_API.Create_Template_Detail (attr_);

      IF item_.selection_operator IN ('INCL','EXCL') THEN
         item_id_ := item_.item_id;
         FOR val_ IN get_values LOOP
            Client_SYS.Clear_Attr(attr_);
            Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
            Client_SYS.Add_To_Attr('OBJECT_GROUP_ID', object_group_id_, attr_);
            Client_SYS.Add_To_Attr('TEMPLATE_ID', new_template_id_, attr_);
            Client_SYS.Add_To_Attr('ITEM_ID', item_.item_id, attr_);
            Client_SYS.Add_To_Attr('VALUE', val_.value, attr_);
            Fin_Sel_Templ_Values_API.Create_Template_Values (attr_);
         END LOOP;
      END IF;
   END LOOP;
END Copy_Selection_Template;

@UncheckedAccess
FUNCTION Get_User_Default_Template (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   user_          VARCHAR2(20) := Fnd_Session_API.Get_Fnd_User;
   template_id_   VARCHAR2(20);

   CURSOR get_def_private IS
      SELECT template_id
        FROM fin_sel_obj_templ_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND ownership = 'PRIVATE'
         AND owner = user_
         AND default_template = 'TRUE';

   CURSOR get_def_public IS
      SELECT template_id
        FROM fin_sel_obj_templ_tab
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND ownership = 'PUBLIC'
         AND default_template = 'TRUE';
BEGIN
   template_id_ := NULL;
   OPEN  get_def_private;
   FETCH get_def_private INTO template_id_;
   IF get_def_private%NOTFOUND THEN
      OPEN get_def_public;
      FETCH get_def_public INTO template_id_;
      CLOSE get_def_public;
   END IF;
   CLOSE get_def_private;
   RETURN template_id_;
END Get_User_Default_Template;

PROCEDURE Create_Template (
   attr_    IN OUT VARCHAR2 )
IS
   newrec_     FIN_SEL_OBJ_TEMPL_TAB%ROWTYPE;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   indrec_ Indicator_Rec;
BEGIN
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END Create_Template;


PROCEDURE Check_Template_Exists (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_ IN VARCHAR2 )
IS
BEGIN
   IF (NOT Check_Exist___(company_, object_group_id_, template_id_)) THEN
      Error_SYS.Record_General( lu_name_, 'TEMPLATENOTEXISTS: The template ID does not exist.');
   END IF;
END Check_Template_Exists;

PROCEDURE Make_Company_Gen (
   module_  IN VARCHAR2,
   lu_      IN VARCHAR2,
   pkg_     IN VARCHAR2,
   attr_    IN VARCHAR2 )
IS
   crecomp_rec_        Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;         
BEGIN
   crecomp_rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec(module_, attr_);
   IF (crecomp_rec_.make_company = 'EXPORT') THEN
      Export_Gen___(module_, lu_, crecomp_rec_);      
   ELSIF (crecomp_rec_.make_company = 'IMPORT') THEN
      IF (crecomp_rec_.action = 'NEW') THEN
         Import_Gen___(module_, lu_, pkg_, crecomp_rec_);         
      ELSIF (crecomp_rec_.action = 'DUPLICATE') THEN 
         Copy_Gen___(module_, pkg_, crecomp_rec_);         
      END IF;      
   END IF;
END Make_Company_Gen;

PROCEDURE Is_Valid_Template (
   company_         IN VARCHAR2,
   object_group_id_ IN VARCHAR2,
   template_id_     IN VARCHAR2)
IS
   rec_   fin_sel_obj_templ_tab%ROWTYPE;
   CURSOR get_rec IS
      SELECT *
      FROM   fin_sel_obj_templ_tab
      WHERE  company = company_
      AND    object_group_id = object_group_id_
      AND    template_id = template_id_;
BEGIN
   OPEN  get_rec;
   FETCH get_rec INTO rec_;
   CLOSE get_rec;
   IF (rec_.ownership = 'PRIVATE' AND NOT (rec_.owner = Fnd_Session_API.Get_Fnd_User() OR Security_SYS.Has_System_Privilege('ADMINISTRATOR') = '%')) THEN
      Error_SYS.Record_General(lu_name_, 'INVALIDTEMPLATE: The template is invalid');
   END IF;   
END Is_Valid_Template;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     fin_sel_obj_templ_tab%ROWTYPE,
   newrec_ IN OUT fin_sel_obj_templ_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.default_template IS NOT NULL OR newrec_.description IS NOT NULL) THEN
      Is_Valid_Template(newrec_.company, newrec_.object_group_id, newrec_.template_id);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     fin_sel_obj_templ_tab%ROWTYPE,
   newrec_ IN OUT fin_sel_obj_templ_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.ownership IS NOT NULL) THEN
      IF (newrec_.owner != Fnd_Session_API.Get_Fnd_User()) THEN
         Error_SYS.Record_General(lu_name_, 'INVALIDOWNDERSHIP: Ownership cannot have a value when Owner is not the current user');
      END IF;
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Update___;

PROCEDURE Set_Default__ (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_      IN VARCHAR2,
   ownership_        IN VARCHAR2,
   owner_            IN VARCHAR2 )
IS 
   objid_               VARCHAR2(20);
   objversion_          VARCHAR2(100);
   attr_                VARCHAR2(32000);
   indrec_              Indicator_rec;
   oldrec_              fin_sel_obj_templ_tab%ROWTYPE;
   newrec_              fin_sel_obj_templ_tab%ROWTYPE;
   temp_template_id_    VARCHAR2(20);
   default_temp_exists_ VARCHAR2(5) := 'FALSE';
   CURSOR get_default_template(ownership_ VARCHAR2) IS
      SELECT template_id
      FROM   fin_sel_obj_templ_tab
      WHERE  company          = company_
      AND    object_group_id  = object_group_id_
      AND    ownership        = ownership_
      AND    owner            = owner_
      AND    default_template = 'TRUE';   
BEGIN
   OPEN get_default_template(Fin_Ownership_API.Encode(ownership_));
   FETCH get_default_template INTO temp_template_id_;
   IF get_default_template%FOUND THEN
      CLOSE get_default_template;
      default_temp_exists_ := 'TRUE';
   ELSE
      CLOSE get_default_template;
   END IF;
   IF( default_temp_exists_ = 'TRUE') THEN
      oldrec_ := Lock_By_Keys___(company_, object_group_id_, temp_template_id_);
      newrec_ := oldrec_;
      newrec_.default_template := 'FALSE';
      Check_Update___(oldrec_, newrec_, indrec_, attr_);
      Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
      objid_      := '';
      objversion_ := '';
      indrec_     := NULL;
      oldrec_     := NULL;
      newrec_     := NULL;
   END IF;
   oldrec_ := Lock_By_Keys___(company_, object_group_id_, template_id_);
   newrec_ := oldrec_;
   newrec_.default_template := 'TRUE';
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);   
END Set_Default__;

PROCEDURE Reset_Default__ (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_      IN VARCHAR2 )
IS
   objid_       VARCHAR2(20);
   objversion_  VARCHAR2(100);
   attr_        VARCHAR2(32000);
   indrec_      Indicator_rec;
   oldrec_      fin_sel_obj_templ_tab%ROWTYPE;
   newrec_      fin_sel_obj_templ_tab%ROWTYPE;
BEGIN   
   oldrec_ := Lock_By_Keys___(company_, object_group_id_, template_id_);
   newrec_ := oldrec_;
   newrec_.default_template := 'FALSE';
   Check_Update___(oldrec_, newrec_, indrec_, attr_);
   Update___(objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Reset_Default__;

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_        IN VARCHAR2)
IS
BEGIN 
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN 
      DELETE 
         FROM FIN_SEL_OBJ_TEMPL_TAB
         WHERE company = company_;
   END IF;  
END Remove_Company;
