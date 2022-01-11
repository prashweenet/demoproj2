-----------------------------------------------------------------------------
--
--  Logical unit: FinSelTemplValues
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  151007  chiblk  STRFI-200, New__ changed to New___ in Insert_Values
--  151203  chiblk  STRFI-682, removing sub methods and rewriting them as implementation methods
--  200701  Tkavlk  Bug 154601, Added Remove_Company

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
PROCEDURE Import_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   newrec_        fin_sel_templ_values_tab%ROWTYPE;
   empty_rec_     fin_sel_templ_values_tab%ROWTYPE;
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
                      FROM  fin_sel_templ_values_tab
                      WHERE company = crecomp_rec_.company
                      AND   object_group_id = src.c1
                      AND   template_id = src.c2
                      AND   item_id = src.n1
                      AND   value = src.c3);   
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
            newrec_.item_id                       := rec_.n1;
            newrec_.value                         := rec_.c3;
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
   newrec_        fin_sel_templ_values_tab%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT src.*
      FROM   fin_sel_templ_values_tab src, fin_obj_grp_tab b
      WHERE  company = crecomp_rec_.old_company
      AND    src.object_group_id = b.object_group_id
      AND    b.module = module_
      AND NOT EXISTS (SELECT 1
                      FROM  fin_sel_templ_values_tab
                      WHERE company = crecomp_rec_.company
                      AND   object_group_id = src.object_group_id
                      AND   template_id = src.template_id
                      AND   item_id = src.item_id
                      AND   value = src.value);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_, module_);
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2015-02-03,ovjose)
         SAVEPOINT make_company_insert;         
         BEGIN
            -- Assign copy record
            newrec_ := rec_;
            newrec_.rowkey := NULL;
            -- Assign new values for new company, all other attributes are copied in the previous row
            newrec_.company := crecomp_rec_.company;            
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
      FROM   Fin_Sel_Templ_Val_Gen_Pct
      WHERE  company = crecomp_rec_.company
      AND    module = module_
      ORDER BY template_id, item_id;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_;
      pub_rec_.item_id := i_;
      pub_rec_.c1          := pctrec_.object_group_id;
      pub_rec_.c2          := pctrec_.template_id;
      pub_rec_.n1          := pctrec_.item_id;
      pub_rec_.c3          := pctrec_.value;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Gen___;


FUNCTION Component_Exist_Any___(
   company_    IN VARCHAR2,
   module_     IN VARCHAR2 ) RETURN BOOLEAN
IS
   b_exist_  BOOLEAN := TRUE;
   idum_     PLS_INTEGER;
   CURSOR exist_control IS
      SELECT 1
      FROM   fin_sel_templ_values_tab a, fin_obj_grp_tab b
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

PROCEDURE Insert_Map_Head___(
   fin_sel_templ_val_module_ IN VARCHAR2,
   fin_sel_templ_val_lu_     IN VARCHAR2,
   client_window_            IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
   clmapprec_  Client_Mapping_API.Client_Mapping_Pub;
BEGIN
   clmapprec_.module        := fin_sel_templ_val_module_;
   clmapprec_.lu            := fin_sel_templ_val_lu_;
   clmapprec_.mapping_id    := 'CCD_'||UPPER(fin_sel_templ_val_lu_); -- assume naming-convention
   clmapprec_.client_window := client_window_;   
   clmapprec_.rowversion    := SYSDATE;
   Client_Mapping_API.Insert_Mapping(clmapprec_);
END Insert_Map_Head___;

PROCEDURE Insert_Map_Detail___(         
   fin_sel_templ_val_module_ IN VARCHAR2,
   fin_sel_templ_val_lu_     IN VARCHAR2,
   column_id_                IN VARCHAR2,                               
   translation_link_         IN VARCHAR2 )
IS                               
   clmappdetrec_  Client_Mapping_API.Client_Mapping_Detail_Pub;                            
BEGIN
   clmappdetrec_.module := fin_sel_templ_val_module_;
   clmappdetrec_.lu := fin_sel_templ_val_lu_;
   clmappdetrec_.mapping_id := 'CCD_'||UPPER(fin_sel_templ_val_lu_);  -- assume naming-convention
   clmappdetrec_.column_id := column_id_ ;
   clmappdetrec_.column_type := 'NORMAL';
   clmappdetrec_.translation_link := translation_link_;
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := SYSDATE;   
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
END Insert_Map_Detail___;    

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
PROCEDURE Create_Client_Mapping_Gen__ (
   fin_sel_templ_val_module_ IN VARCHAR2,
   fin_sel_templ_val_lu_     IN VARCHAR2,
   client_window_            IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS         
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(fin_sel_templ_val_module_,
                      fin_sel_templ_val_lu_,
                      client_window_);
   -- Insert Map Detail
   Insert_Map_Detail___(fin_sel_templ_val_module_,fin_sel_templ_val_lu_,'C1', 'Fin_Sel_Obj_Templ_Val_GEN_PCT.OBJECT_GROUP_ID');
   Insert_Map_Detail___(fin_sel_templ_val_module_,fin_sel_templ_val_lu_,'C2', 'Fin_Sel_Obj_Templ_Val_GEN_PCT.TEMPLATE_ID');
   Insert_Map_Detail___(fin_sel_templ_val_module_,fin_sel_templ_val_lu_,'N1', 'Fin_Sel_Obj_Templ_Val_GEN_PCT.ITEM_ID');
   Insert_Map_Detail___(fin_sel_templ_val_module_,fin_sel_templ_val_lu_,'C3', 'Fin_Sel_Obj_Templ_Val_GEN_PCT.VALUE');  
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
      'C1^C2^N1^C3');
   execution_order_ := execution_order_+1;
END Create_Company_Reg_Gen__;
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Is_Value_Exist (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_      IN VARCHAR2,
   item_id_          IN NUMBER,
   value_            IN VARCHAR2 ) RETURN NUMBER
IS
   dummy_   NUMBER;
   CURSOR exist IS
      SELECT 1
        FROM FIN_SEL_TEMPL_VALUES_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND template_id = template_id_
         AND item_id = item_id_
         AND value = value_;
BEGIN
   OPEN  exist;
   FETCH exist INTO dummy_;
   IF exist%NOTFOUND THEN
      CLOSE exist;
      RETURN 0;
   END IF;
   CLOSE exist;
   RETURN 1;
END Is_Value_Exist;


@UncheckedAccess
FUNCTION Is_Value_Exist (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_      IN VARCHAR2,
   item_id_          IN NUMBER ) RETURN VARCHAR2
IS
   dummy_   NUMBER;
   CURSOR exist IS
      SELECT 1
        FROM FIN_SEL_TEMPL_VALUES_TAB
       WHERE company = company_
         AND object_group_id = object_group_id_
         AND template_id = template_id_
         AND item_id = item_id_;
BEGIN
   OPEN  exist;
   FETCH exist INTO dummy_;
   IF exist%NOTFOUND THEN
      CLOSE exist;
      RETURN 'FALSE';
   END IF;
   CLOSE exist;
   RETURN 'TRUE';
END Is_Value_Exist;


PROCEDURE Insert_Values (
   company_          IN VARCHAR2,
   object_group_id_  IN VARCHAR2,
   template_id_      IN VARCHAR2,
   item_id_          IN NUMBER,
   value_str_        IN VARCHAR2 )
IS
   rec_        fin_sel_templ_values_tab%ROWTYPE;
   value_         VARCHAR2(50);
   action_        NUMBER;
   n_             NUMBER;
   pos_           NUMBER;
BEGIN

   n_ := 1;
   pos_ := INSTR(value_str_, '^', n_);
   WHILE (pos_ > 0) LOOP
      value_  := substr(value_str_, n_, pos_ - n_);
      action_ := substr(value_, -1);
      value_  := substr(value_, 1, length(value_) - 1 );
      n_ := pos_ + 1;
      pos_ := INSTR(value_str_, '^', n_);
      IF ( action_ = 1 AND Is_Value_Exist( company_, object_group_id_, template_id_, item_id_, value_ ) != 1 ) THEN
         rec_.company            := company_;
         rec_.object_group_id    := object_group_id_;
         rec_.template_id        := template_id_;
         rec_.item_id            := item_id_;
         rec_.value              := value_;
         
         New___(rec_);
      ELSIF (action_=0) THEN
         rec_ := Lock_By_Keys___ (company_, object_group_id_, template_id_, item_id_, value_);

         DELETE FROM fin_sel_templ_values_tab
         WHERE  company = company_
         AND    object_group_id = object_group_id_
         AND    template_id = template_id_
         AND    item_id = item_id_
         AND    value = value_;
      END IF;
   END LOOP;
END Insert_Values;


PROCEDURE Create_Template_Values (
   attr_      IN OUT VARCHAR2 )
IS
   newrec_     FIN_SEL_TEMPL_VALUES_TAB%ROWTYPE;
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);
   indrec_ Indicator_Rec;
BEGIN
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END Create_Template_Values;

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

-- DO NOT CHANGE OR USE THIS METHOD FOR OTHER PURPOSES. 
-- Note: This method only used from Remove Company functionality in Remove_Company_API.Start_Remove_Company__.
@ServerOnlyAccess 
PROCEDURE Remove_Company (
   company_        IN VARCHAR2)
IS
BEGIN  
   IF Company_API.Remove_Company_Allowed(company_) = 'TRUE' THEN
      DELETE 
      FROM FIN_SEL_TEMPL_VALUES_TAB
      WHERE company = company_;
   END IF;   
END Remove_Company;
