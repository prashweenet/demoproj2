-----------------------------------------------------------------------------
--
--  Logical unit: FooterField
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  131123  MEALLK  PBFI-2042, refactored cod
--  140411  Nudilk  PBFI-6468, Merged Bug 116025, Added Get_Translated_Footer_Text.
--  151203  chiblk  STRFI-682,removing sub methods and rewriting them as implementation methods
--  180912  Nudilk  Bug 144144, Corrected.
--  200701  Tkavlk  Bug 154601, Added Remove_Company
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   --Client_SYS.Add_To_Attr('SYSTEM_DEFINED', Fnd_Boolean_API.Decode('FALSE'),attr_);
   --Client_SYS.Add_To_Attr('FREE_TEXT', Fnd_Boolean_API.Decode('FALSE'),attr_);
   Client_SYS.Add_To_Attr('SYSTEM_DEFINED_DB', 'FALSE',attr_);
   Client_SYS.Add_To_Attr('FREE_TEXT_DB', 'FALSE',attr_);
END Prepare_Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN FOOTER_FIELD_TAB%ROWTYPE )
IS
BEGIN
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT footer_field_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);

   -- validate that the Footer Field is a system defined Footer Field
   IF (newrec_.system_defined = 'TRUE') THEN
      System_Footer_Field_API.Exist(newrec_.footer_field_id);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     footer_field_tab%ROWTYPE,
   newrec_ IN OUT footer_field_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF Validate_SYS.Is_Changed(oldrec_.free_text, newrec_.free_text) THEN
      Field_Used_Define_Footer___(newrec_);
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (newrec_.free_text = 'TRUE' AND Validate_SYS.Is_Changed(oldrec_.footer_text, newrec_.footer_text)) THEN
      Update_Free_Text_If_Used___(oldrec_, newrec_);
   END IF;
END Check_Update___;

PROCEDURE Field_Used_Define_Footer___(
   newrec_ IN OUT footer_field_tab%ROWTYPE)
IS
   footer_id_              footer_definition_tab.footer_id%TYPE;
   field_seperator_        CONSTANT VARCHAR2(1) := ',';
   footer_field_with_sep_  VARCHAR2(100);
   
   CURSOR free_text_used IS
      SELECT footer_id
      FROM footer_definition_tab  
      WHERE company = newrec_.company
      AND free_text = newrec_.footer_text;
   
   CURSOR non_free_text_used IS
      SELECT footer_id
      FROM footer_definition_tab 
      WHERE company = newrec_.company
      AND ((INSTR(field_seperator_ ||column1_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column2_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column3_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column4_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column5_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column6_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column7_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column8_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column9_field|| field_seperator_, footer_field_with_sep_ ) > 0) OR
           (INSTR(field_seperator_ ||column10_field|| field_seperator_, footer_field_with_sep_ ) > 0));
BEGIN
   footer_field_with_sep_ := field_seperator_ || newrec_.footer_field_id ||field_seperator_;
   
   IF newrec_.free_text = 'FALSE' THEN
      OPEN free_text_used;
      FETCH free_text_used INTO footer_id_;
      IF free_text_used%FOUND THEN
         CLOSE free_text_used;
         Error_SYS.Record_General(lu_name_, 'FREETEXTUSED: Cannot uncheck the Free Text field as it is used in Result Text field in Define Footer Tab for Footer ID :P1.', footer_id_);
      ELSE
         CLOSE free_text_used;
      END IF;
   ELSE
      OPEN non_free_text_used;
      FETCH non_free_text_used INTO footer_id_;
      IF non_free_text_used%FOUND THEN
         CLOSE non_free_text_used;
         Error_SYS.Record_General(lu_name_, 'NONFREETEXTUSED: Cannot check the Free Text field as it is used in Result field in Define Footer Tab for Footer ID :P1.', footer_id_);
      ELSE
         CLOSE non_free_text_used;
      END IF;
   END IF;
END Field_Used_Define_Footer___;

PROCEDURE Update_Free_Text_If_Used___(
   oldrec_ IN     footer_field_tab%ROWTYPE,
   newrec_ IN OUT footer_field_tab%ROWTYPE)
IS
   CURSOR free_text_used IS
      SELECT footer_id
      FROM  footer_definition_tab
      WHERE company = oldrec_.company
      AND free_text = oldrec_.footer_text;
BEGIN
   FOR rec_ IN free_text_used LOOP
      Footer_Definition_API.Update_Free_Text(newrec_.company, rec_.footer_id, newrec_.footer_text);
   END LOOP;
END Update_Free_Text_If_Used___;

@Override
@SecurityCheck Company.UserExist(newrec_.company)
PROCEDURE Check_Common___ (
   oldrec_ IN     footer_field_tab%ROWTYPE,
   newrec_ IN OUT footer_field_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   --Add pre-processing code here
   super(oldrec_, newrec_, indrec_, attr_);
END Check_Common___;

PROCEDURE Export_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   pub_rec_ Enterp_Comp_Connect_V170_API.Tem_Public_Rec;
   i_       NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM  Footer_Field_Gen_Pct
      WHERE company = crecomp_rec_.company
      AND   module  = module_;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_;
      pub_rec_.item_id     := i_;
      pub_rec_.c1          := pctrec_.footer_field_id;
      pub_rec_.c2          := pctrec_.footer_field_desc;
      pub_rec_.c3          := pctrec_.system_defined_db;
      pub_rec_.c4          := pctrec_.free_text_db;
      pub_rec_.c5          := pctrec_.footer_text;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);
      i_ := i_ + 1;
   END LOOP;
END Export_Gen___;
   
PROCEDURE Import_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_      footer_field_tab%ROWTYPE;
   empty_rec_   footer_field_tab%ROWTYPE;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  Create_Company_Template_Pub src
      WHERE component   = module_
      AND   lu          = lu_
      AND   template_id = crecomp_rec_.template_id
      AND   version     = crecomp_rec_.version
      AND NOT EXISTS (SELECT 1
                      FROM  footer_field_tab
                      WHERE company = crecomp_rec_.company
                      AND   footer_field_id = src.c1);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(module_, lu_, crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR pub_rec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2015-02-05,DipeLK)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            newrec_.company             := crecomp_rec_.company;
            newrec_.footer_field_id     := pub_rec_.c1;
            newrec_.footer_field_desc   := pub_rec_.c2;
            newrec_.system_defined      := pub_rec_.c3;
            newrec_.free_text           := pub_rec_.c4;
            newrec_.footer_text         := pub_rec_.c5;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2015-02-05,DipeLK)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
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
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_ IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   newrec_      footer_field_tab%ROWTYPE;
   empty_rec_   footer_field_tab%ROWTYPE;
   msg_         VARCHAR2(2000);
   i_           NUMBER := 0;
   run_crecomp_ BOOLEAN := FALSE;
   CURSOR get_data IS
      SELECT *
      FROM  footer_field_tab src
      WHERE company = crecomp_rec_.old_company
      AND NOT EXISTS (SELECT 1
                      FROM  footer_field_tab
                      WHERE company = crecomp_rec_.company
                      AND   footer_field_id = src.footer_field_id);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(module_, lu_, crecomp_rec_);
   IF (run_crecomp_) THEN
      FOR oldrec_ IN get_data LOOP
         i_ := i_ + 1;
         @ApproveTransactionStatement(2015-02-05,DipeLK)
         SAVEPOINT make_company_insert;
         BEGIN
            newrec_ := empty_rec_;
            newrec_.company            := crecomp_rec_.company;
            newrec_.footer_field_id    := oldrec_.footer_field_id;
            newrec_.footer_field_desc  := oldrec_.footer_field_desc;
            newrec_.system_defined     := oldrec_.system_defined;
            newrec_.free_text          := oldrec_.free_text;
            newrec_.footer_text        := oldrec_.footer_text;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               @ApproveTransactionStatement(2015-02-05,DipeLK)
               ROLLBACK TO make_company_insert;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := language_sys.translate_constant(lu_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully', msg_);
      ELSE
         IF msg_ IS NULL THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
         END IF;
      END IF;
   END IF;
   -- this statement is to add to the log that the Create company process for LUs is finished if
   -- run_crecomp_ are FALSE
   IF ( NOT run_crecomp_ ) THEN
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
END Copy_Gen___;
   
FUNCTION Check_If_Do_Create_Company___ (
   module_      IN VARCHAR2,
   lu_          IN VARCHAR2,
   crecomp_rec_ IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec ) RETURN BOOLEAN
IS
   perform_update_ BOOLEAN;
   update_by_key_  BOOLEAN;
BEGIN
   perform_update_ := FALSE;
   update_by_key_ := Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_, crecomp_rec_);
   IF (update_by_key_) THEN
      perform_update_ := TRUE;
   ELSE
      IF (NOT Component_Exist_Any___(crecomp_rec_.company, module_)) THEN
         perform_update_ := TRUE;
      END IF;
   END IF;
   RETURN perform_update_;
      
END Check_If_Do_Create_Company___;

FUNCTION Component_Exist_Any___ (
   company_ IN VARCHAR2,
   module_  IN VARCHAR2) RETURN BOOLEAN
IS
   b_exist_  BOOLEAN  := TRUE;
   idum_     PLS_INTEGER;
   CURSOR exist_control IS
      SELECT 1
      FROM  footer_field_tab a, system_footer_field_tab b
      WHERE a.company         = company_
      AND   a.footer_field_id = b.footer_field_id
      AND   b.module          = module_;
   BEGIN
      OPEN exist_control;
      FETCH exist_control INTO idum_;
         IF (exist_control%NOTFOUND) THEN
            b_exist_ := FALSE;
         END IF;
      CLOSE exist_control;
      RETURN b_exist_;
END Component_Exist_Any___;

PROCEDURE Insert_Map_Head___(
   footer_field_module_ IN VARCHAR2,
   footer_field_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
   clmapprec_  Client_Mapping_API.Client_Mapping_Pub;
BEGIN
   clmapprec_.module        := footer_field_module_;
   clmapprec_.lu            := footer_field_lu_;
   clmapprec_.mapping_id    := 'CCD_'||UPPER(footer_field_lu_); -- assume naming-convention
   clmapprec_.client_window := client_window_;   
   clmapprec_.rowversion    := SYSDATE;
   Client_Mapping_API.Insert_Mapping(clmapprec_);
END Insert_Map_Head___;

PROCEDURE Insert_Map_Detail___(         
   footer_field_module_ IN VARCHAR2,
   footer_field_lu_     IN VARCHAR2,   
   column_id_           IN VARCHAR2,                               
   translation_link_    IN VARCHAR2 )
IS                               
   clmappdetrec_  Client_Mapping_API.Client_Mapping_Detail_Pub;                            
BEGIN
   clmappdetrec_.module := footer_field_module_;
   clmappdetrec_.lu := footer_field_lu_;
   clmappdetrec_.mapping_id := 'CCD_'||UPPER(footer_field_lu_);  -- assume naming-convention
   clmappdetrec_.column_id := column_id_ ;
   clmappdetrec_.column_type := 'NORMAL';
   clmappdetrec_.translation_link := translation_link_;
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := SYSDATE;   
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
END Insert_Map_Detail___; 
      
-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-- Import_System_Footer_Field__
--   Method to Import System defined Footer Fields to the company
PROCEDURE Import_System_Footer_Field__(
   company_    IN VARCHAR2)
IS
   newrec_     FOOTER_FIELD_TAB%ROWTYPE;
   empty_rec_  FOOTER_FIELD_TAB%ROWTYPE;
   CURSOR get_footers IS
      SELECT *
      FROM system_footer_field_tab s
      WHERE NOT EXISTS (SELECT 1 
                        FROM FOOTER_FIELD_TAB f
                        WHERE f.company = company_
                        AND f.footer_field_id = s.footer_field_id);
BEGIN
   FOR rec_ IN get_footers LOOP
      newrec_ := empty_rec_;

      newrec_.company            := company_;
      newrec_.footer_field_id    := rec_.footer_field_id;
      newrec_.footer_field_desc  := rec_.footer_field_desc;
      newrec_.system_defined     := rec_.system_defined;
      newrec_.free_text          := rec_.free_text;
      newrec_.footer_text        := rec_.footer_text;

      New___(newrec_);
   END LOOP;
END Import_System_Footer_Field__;

PROCEDURE Comp_Reg_Ft_Field_Gen__ (
   execution_order_   IN OUT NOCOPY NUMBER,
   module_            IN     VARCHAR2,
   lu_name_           IN     VARCHAR2,
   pkg_               IN     VARCHAR2,
   create_and_export_ IN     BOOLEAN  DEFAULT TRUE,
   active_            IN     BOOLEAN  DEFAULT TRUE,
   account_related_   IN     BOOLEAN  DEFAULT FALSE,
   standard_table_    IN     BOOLEAN  DEFAULT TRUE )
IS
BEGIN
   Enterp_Comp_Connect_V170_API.Reg_Add_Component_Detail(
      module_, lu_name_, pkg_,
      CASE create_and_export_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      execution_order_,
      CASE active_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      CASE account_related_ WHEN TRUE THEN 'TRUE' ELSE 'FALSE' END,
      'CCD_'||UPPER(lu_name_), 'C1', 'FOOTER_DESC,<NULL>', 'C2,C5');
   execution_order_ := execution_order_+1;
      
END Comp_Reg_Ft_Field_Gen__;

PROCEDURE Client_Map_Ft_Field_Gen__ (
   footer_field_module_module_ IN VARCHAR2,
   footer_field_module_lu_     IN VARCHAR2,
   client_window_              IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS   
     
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(footer_field_module_module_,
                      footer_field_module_lu_,
                      client_window_);
                      
   -- Insert Map Detail
   Insert_Map_Detail___(footer_field_module_module_,footer_field_module_lu_,'C1', 'FOOTER_FIELD.FOOTER_FIELD_ID');
   Insert_Map_Detail___(footer_field_module_module_,footer_field_module_lu_,'C2', 'FOOTER_FIELD.FOOTER_FIELD_DESC');
   Insert_Map_Detail___(footer_field_module_module_,footer_field_module_lu_,'C3', 'FOOTER_FIELD.SYSTEM_DEFINED');
   Insert_Map_Detail___(footer_field_module_module_,footer_field_module_lu_,'C4', 'FOOTER_FIELD.FREE_TEXT');
   Insert_Map_Detail___(footer_field_module_module_,footer_field_module_lu_,'C5', 'FOOTER_FIELD.FOOTER_TEXT');  
END Client_Map_Ft_Field_Gen__;   

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@UncheckedAccess
FUNCTION Get_Translated_Footer_Text(
   company_     IN VARCHAR2,
   footer_text_ IN VARCHAR2,
   lang_code_   IN VARCHAR2 ) RETURN VARCHAR2
IS

   footer_field_id_  FOOTER_FIELD_TAB.footer_field_id%TYPE;
   temp_text_        FOOTER_FIELD_TAB.footer_text%TYPE;
   CURSOR get_attr IS
      SELECT footer_field_id
      FROM   FOOTER_FIELD_TAB
      WHERE  company     = company_
       AND   footer_text = footer_text_;
BEGIN
  
   OPEN get_attr;
   FETCH get_attr INTO footer_field_id_;
   CLOSE get_attr;
   
   temp_text_ := Substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_,'ACCRUL', 'FooterField', footer_field_id_, lang_code_), 1, 2000);
      
   IF (temp_text_ IS NOT NULL) THEN
      RETURN temp_text_;
   ELSE
      RETURN footer_text_;
   END IF;
   
END Get_Translated_Footer_Text;

@UncheckedAccess   
FUNCTION Get_Footer_Field_Desc_Trans (
   company_         IN VARCHAR2,
   footer_field_id_ IN VARCHAR2,
   lang_code_       IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   temp_ FOOTER_FIELD_TAB.footer_field_desc%TYPE;
   CURSOR get_attr IS
      SELECT footer_field_desc
      FROM   FOOTER_FIELD_TAB
      WHERE  company = company_
       AND   footer_field_id = footer_field_id_;
BEGIN
   temp_ := Substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_,'ACCRUL', 'FooterField', footer_field_id_ ||'^FOOTER_DESC', lang_code_),1, 200);
   IF (temp_ IS NULL) THEN
      OPEN get_attr;
      FETCH get_attr INTO temp_;
      CLOSE get_attr;
   END IF;
   RETURN temp_;
END Get_Footer_Field_Desc_Trans;

@UncheckedAccess
FUNCTION Get_Footer_Text_Trans (
   company_         IN VARCHAR2,
   footer_field_id_ IN VARCHAR2,
   lang_code_       IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
   temp_ FOOTER_FIELD_TAB.footer_text%TYPE;
   CURSOR get_attr IS
      SELECT footer_text
      FROM   FOOTER_FIELD_TAB
      WHERE  company = company_
       AND   footer_field_id = footer_field_id_;
BEGIN
   temp_ := Substr(Enterp_Comp_Connect_V170_API.Get_Company_Translation(company_,'ACCRUL', 'FooterField', footer_field_id_, lang_code_), 1, 2000);
   IF (temp_ IS NULL) THEN
      OPEN get_attr;
      FETCH get_attr INTO temp_;
      CLOSE get_attr;
   END IF;
   RETURN temp_;
END Get_Footer_Text_Trans;

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
         Copy_Gen___(module_, lu_, pkg_, crecomp_rec_);         
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
      FROM FOOTER_FIELD_TAB
      WHERE company = company_;
   END IF;     
END Remove_Company;
