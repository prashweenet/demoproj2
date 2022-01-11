-----------------------------------------------------------------------------
--
--  Logical unit: FooterConnection
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  121011  Bmekse  Bug 105894, Modified method Split___
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  131108  PRatlk  PBFI-2039, Refactored according to the new template
--  131123  MEALLK  PBFI-2042, modified
--  140411  Nudilk  PBFI-6468, Merged Bug 116025, Modified Get_Footer_Details.  
--  151203  chiblk  STRFI-682,removing sub methods and rewriting them as implementation methods
--  200701  Tkavlk  Bug 154601, Added Remove_company

-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE t_varchar2 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE footer_arr IS TABLE OF t_varchar2 INDEX BY BINARY_INTEGER;


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Split___ (
   list_      VARCHAR2,
   delim_     VARCHAR2 ) RETURN t_varchar2
IS
   ret_       t_varchar2;
   i_         INTEGER;
   ctr_       INTEGER;
   temp_list_ VARCHAR2(32000) := list_;
BEGIN
   ctr_ := 0;
   LOOP
      i_ := INSTR(temp_list_, delim_);
      IF i_ > 0 THEN
         ret_(ctr_) := RTRIM(SUBSTR(temp_list_,1,i_-1));
         temp_list_ := SUBSTR(temp_list_, i_ + LENGTH(delim_));
      ELSE
         ret_(ctr_) := RTRIM(temp_list_);
         EXIT;
      END IF;
      ctr_ := ctr_ + 1;
   END LOOP;
   RETURN ret_;
END Split___;


PROCEDURE Import_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   newrec_        FOOTER_CONNECTION_TAB%ROWTYPE;
   empty_rec_     FOOTER_CONNECTION_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT C1,C2,C3
      FROM   Create_Company_Template_Pub src
      WHERE  component = module_
      AND    lu    = lu_
      AND    template_id = crecomp_rec_.template_id
      AND    version     = crecomp_rec_.version
      AND    NOT EXISTS (SELECT 1 
                         FROM FOOTER_CONNECTION_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND   dest.report_id = src.C1
                         AND   dest.contract = src.C2);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_, module_);
   
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         BEGIN
            newrec_ := empty_rec_;

            newrec_.company                     := crecomp_rec_.company;
            newrec_.report_id                   := rec_.c1;
            newrec_.contract                    := rec_.c2;
            newrec_.footer_id                   := rec_.c3;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := Language_SYS.Translate_Constant(lu_name_, 'NODATAFOUND: No Data Found');
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
END Import_Gen___;


PROCEDURE Copy_Gen___ (
   module_        IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   newrec_        FOOTER_CONNECTION_TAB%ROWTYPE;
   empty_rec_     FOOTER_CONNECTION_TAB%ROWTYPE;
   msg_           VARCHAR2(2000);
   i_             NUMBER := 0;
   run_crecomp_   BOOLEAN := FALSE;

   CURSOR get_data IS
      SELECT src.*
      FROM   FOOTER_CONNECTION_TAB src, Footer_Connection_Master_Tab b
      WHERE  company = crecomp_rec_.old_company
      AND    src.report_id = b.report_id
      AND    b.module = module_
      AND    NOT EXISTS (SELECT 1
                         FROM FOOTER_CONNECTION_TAB dest
                         WHERE dest.company = crecomp_rec_.company
                         AND   dest.report_id = src.report_id
                         AND   dest.contract = src.contract);
BEGIN
   run_crecomp_ := Check_If_Do_Create_Company___(crecomp_rec_, module_);
   IF (run_crecomp_) THEN
      FOR rec_ IN get_data LOOP
         i_ := i_ + 1;
         BEGIN
            -- Reset variables
            newrec_ := empty_rec_;
            -- Assign copy record
            newrec_ := rec_;
            newrec_.rowkey := NULL;
            -- Assign new values for new company, all other attributes are copied in the previous row
            newrec_.company      := crecomp_rec_.company;
            New___(newrec_);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);
         END;
      END LOOP;
      IF ( i_ = 0 ) THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
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


PROCEDURE Export_Gen___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   FOOTER_CONNECTION_GEN_PCT
      WHERE  company = crecomp_rec_.company
      AND    module = module_
      ORDER BY report_id;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.report_id;
      pub_rec_.c2 := pctrec_.contract;
      pub_rec_.c3 := pctrec_.footer_id;
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
      FROM   FOOTER_CONNECTION_TAB a, Footer_Connection_Master_Tab b
      WHERE  company = company_
      AND    a.report_id = b.report_id
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
PROCEDURE Check_Delete___ (
   remrec_ IN FOOTER_CONNECTION_TAB%ROWTYPE )
IS
BEGIN
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT footer_connection_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(newrec_, indrec_, attr_);
   
   Report_Definition_API.Exist(newrec_.report_id);
   IF (newrec_.contract != '*') THEN
      IF (Footer_Connection_Master_API.Get_Contract_Dependent_Db(newrec_.report_id) = 'FALSE') THEN 
         Error_SYS.Appl_General(lu_name_,'SITENOTVLD: Site is not valid for this report, value * must be used' );
      ELSE
         $IF Component_Mpccom_SYS.INSTALLED $THEN
            IF Site_API.Get_Company(newrec_.contract) != newrec_.company THEN
               Error_SYS.Appl_General(lu_name_,'COSITENOTEXIST: Site :P1 does not exist in company :P2 ', newrec_.contract,newrec_.company);
            END IF;
            Site_API.Exist(newrec_.contract);
         $ELSE
            NULL;    
         $END
      END IF;     
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     footer_connection_tab%ROWTYPE,
   newrec_ IN OUT footer_connection_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


PROCEDURE Insert_Map_Head___(
   footer_connection_module_ IN VARCHAR2,
   footer_connection_lu_     IN VARCHAR2,
   client_window_            IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
   clmapprec_  Client_Mapping_API.Client_Mapping_Pub;
BEGIN
   clmapprec_.module        := footer_connection_module_;
   clmapprec_.lu            := footer_connection_lu_;
   clmapprec_.mapping_id    := 'CCD_'||UPPER(footer_connection_lu_); -- assume naming-convention
   clmapprec_.client_window := client_window_;   
   clmapprec_.rowversion    := SYSDATE;
   Client_Mapping_API.Insert_Mapping(clmapprec_);
END Insert_Map_Head___;

PROCEDURE Insert_Map_Detail___(         
   footer_connection_module_ IN VARCHAR2,
   footer_connection_lu_     IN VARCHAR2,   
   column_id_                IN VARCHAR2,                               
   translation_link_         IN VARCHAR2 )
IS                               
   clmappdetrec_  Client_Mapping_API.Client_Mapping_Detail_Pub;                            
BEGIN
   clmappdetrec_.module := footer_connection_module_;
   clmappdetrec_.lu := footer_connection_lu_;
   clmappdetrec_.mapping_id := 'CCD_'||UPPER(footer_connection_lu_);  -- assume naming-convention
   clmappdetrec_.column_id := column_id_ ;
   clmappdetrec_.column_type := 'NORMAL';
   clmappdetrec_.translation_link := translation_link_;
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := SYSDATE;   
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
END Insert_Map_Detail___;    

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Client_Map_Footer_Conn_Gen__ (
   footer_connection_module_ IN VARCHAR2,
   footer_connection_lu_     IN VARCHAR2,
   client_window_            IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS   
     
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(footer_connection_module_,
                      footer_connection_lu_,
                      client_window_);
                      
   -- Insert Map Detail
   Insert_Map_Detail___(footer_connection_module_,footer_connection_lu_,'C1', 'FOOTER_CONNECTION_GEN_PCT.REPORT_ID');
   Insert_Map_Detail___(footer_connection_module_,footer_connection_lu_,'C2', 'FOOTER_CONNECTION_GEN_PCT.CONTRACT');
   Insert_Map_Detail___(footer_connection_module_,footer_connection_lu_,'C3', 'FOOTER_CONNECTION_GEN_PCT.FOOTER_ID');  
END Client_Map_Footer_Conn_Gen__;

PROCEDURE Comp_Reg_Footer_Conn_Gen__ (
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
      'C1^C2');
   execution_order_ := execution_order_+1;
END Comp_Reg_Footer_Conn_Gen__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-- Get_Footer_Details
--   Procedure that returns Document Footer rows with column titles and column texts based on given
--   company, report and contract, lang_code_ to control if if values should be return in the given language or the sessions language
--   sys_def_params_ could be used to pass data that could be used to retrieve values for system defined footer fields. If NULL then
--   only company will be used to gather this data.
--   System Defined Footer Fields must define a function that takes two parameters and return a varchar2. The first parameter
--   should be company and the second should be an attribute string in which sys_def_params_ will be passed.
--   Purpose: Public general method for Create Company handling of Footer Connection.
--   The method is called by component specific footer connection control API:s.
PROCEDURE Get_Footer_Details(
   row_              OUT NUMBER,
   column_title_     OUT footer_arr,
   column_text_      OUT footer_arr,
   company_          IN VARCHAR2,
   report_id_        IN VARCHAR2,
   contract_         IN VARCHAR2,
   lang_code_        IN VARCHAR2 DEFAULT NULL,
   sys_def_params_   IN VARCHAR2 DEFAULT NULL)
IS
   footer_id_              Footer_Definition_Tab.footer_id%TYPE;
   footer_rec_             Footer_Definition_API.Public_Rec;
   footer_field_desc_      Footer_Field_Tab.footer_field_desc%TYPE;
   empty_arr_              t_varchar2;
   footer_profile_         t_varchar2;
   footer_pos_             t_number;
   col_                    NUMBER;
   col_width_              NUMBER;
   ctr_                    NUMBER;
   footer_                 footer_arr;
   footer_field_           t_varchar2;
   footer_text_            t_varchar2;
   field_text_             t_varchar2;
   field_id_               VARCHAR2(2000);
   max_                    BINARY_INTEGER;
   text_                   VARCHAR2(2000);
   f_title_                t_varchar2;
   f_text_                 t_varchar2;
   field_rec_              Footer_Field_API.Public_Rec;
   package_method_         VARCHAR2(100);
BEGIN

   footer_id_  := Get_Footer_Id(company_, report_id_,contract_);
   
   IF footer_id_ IS NULL THEN
      footer_id_  := Get_Footer_Id(company_, report_id_,'*');
   END IF;
   
   footer_rec_ := Footer_Definition_API.Get(company_, footer_id_); 

   max_ := 0;
   FOR i IN 0..footer_rec_.no_of_columns-1 LOOP
      CASE i
         WHEN 0 THEN field_id_ := footer_rec_.column1_field;
         WHEN 1 THEN field_id_ := footer_rec_.column2_field;
         WHEN 2 THEN field_id_ := footer_rec_.column3_field;
         WHEN 3 THEN field_id_ := footer_rec_.column4_field;
         WHEN 4 THEN field_id_ := footer_rec_.column5_field;
         WHEN 5 THEN field_id_ := footer_rec_.column6_field;
         WHEN 6 THEN field_id_ := footer_rec_.column7_field;
         WHEN 7 THEN field_id_ := footer_rec_.column8_field;
         WHEN 8 THEN field_id_ := footer_rec_.column9_field;
         WHEN 9 THEN field_id_ := footer_rec_.column10_field;
      END CASE;

      IF field_id_ IS NOT NULL THEN
         footer_field_ := Split___(field_id_, ',');
         ctr_ := 0;
         footer_text_ := empty_arr_;
         FOR n IN footer_field_.FIRST..footer_field_.LAST LOOP
            footer_field_desc_   := Footer_Field_API.Get_Footer_Field_Desc_Trans(company_, footer_field_(n),lang_code_);
            text_                := Footer_Field_API.Get_Footer_Text_Trans(company_, footer_field_(n),lang_code_);
            field_rec_           := Footer_Field_API.Get(company_, footer_field_(n));
            
            IF footer_field_desc_ IS NOT NULL THEN
               footer_text_(ctr_) := footer_field_desc_ || ':';
               ctr_        := ctr_ + 1;
            END IF;
            
            field_text_ := Split___(text_, CHR(13) || CHR(10));

            FOR j IN field_text_.FIRST..field_text_.LAST LOOP
               IF (field_rec_.system_defined = 'TRUE') THEN
                  package_method_ := System_Footer_Field_API.Get_Package_Method(footer_field_(n));
                  IF (package_method_ IS NOT NULL) THEN
                     Assert_SYS.Assert_Is_Package_Method(package_method_);
                     @ApproveDynamicStatement(2012-08-24,ovjose)
                     EXECUTE IMMEDIATE 'BEGIN :footer_text_ := ' || package_method_ ||'(:company_, :sys_def_params_); END;' USING OUT footer_text_(ctr_), IN company_, IN sys_def_params_;
                  END IF;
               ELSE
                  footer_text_(ctr_) := field_text_(j);
               END IF;
               ctr_ := ctr_ + 1;
            END LOOP;
         END LOOP;
         IF ctr_ > max_ THEN
            max_ := ctr_;
         END IF;
         footer_(i) := footer_text_;
      ELSE
         footer_(i) := empty_arr_;
      END IF;
   END LOOP;

   col_       := CEIL(40/footer_rec_.no_of_columns);
   col_width_ := 25;

   footer_profile_ := Split___(footer_rec_.last_profile, ';');
   footer_pos_(0) := 1;
   ctr_ := 1;
   FOR i IN footer_profile_.FIRST..footer_profile_.LAST-1 LOOP
      ctr_ := ctr_ + col_;
      IF footer_profile_(i) > 0 THEN
         WHILE footer_profile_(i) > 0 LOOP
            ctr_ := ctr_ + 1;
            footer_profile_(i) := footer_profile_(i) - col_width_;
         END LOOP;
      ELSIF footer_profile_(i) < 0 THEN
         WHILE footer_profile_(i) < 0 LOOP
            ctr_ := ctr_ - 1;
            footer_profile_(i) := footer_profile_(i) + col_width_;
         END LOOP;
      END IF;
      footer_pos_(i+1) := ctr_;
   END LOOP;

   FOR n IN 0..max_ LOOP
      f_title_(0) := 'IS_FREE_TEXT';
      f_text_(0)  := 'FALSE';
      FOR i IN 1..footer_rec_.no_of_columns LOOP
         footer_text_ := footer_(i-1);
         f_title_(i) := 'TEXT' || footer_pos_(i-1);
         IF footer_text_.EXISTS(n) THEN
            f_text_(i) := footer_text_(n);
         ELSE
            f_text_(i) := '';
         END IF;
      END LOOP;
      column_title_(n) := f_title_;
      column_text_(n)  := f_text_;
   END LOOP;

   f_title_ := empty_arr_;
   f_text_  := empty_arr_;
   IF footer_rec_.free_text IS NOT NULL THEN
      max_ := max_ + 1;
      f_title_(0) := 'IS_FREE_TEXT';
      f_text_(0)  := 'TRUE';
      f_title_(1) := 'TEXT1';
      f_text_(1)  := Footer_Field_API.Get_Translated_Footer_Text(company_,footer_rec_.free_text,lang_code_);
      column_title_(max_) := f_title_;
      column_text_(max_)  := f_text_;
   END IF;
   row_ := max_;
END Get_Footer_Details;


@UncheckedAccess
FUNCTION Is_Report_Footer_Connected (
   company_   IN VARCHAR2,
   report_id_ IN VARCHAR2,
   contract_  IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM  FOOTER_CONNECTION_TAB
      WHERE company = company_
      AND   report_id = report_id_
      AND   footer_id IS NOT NULL 
      AND   (contract = contract_ OR contract = '*');
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Is_Report_Footer_Connected;


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
         FROM FOOTER_CONNECTION_TAB
         WHERE company = company_;
   END IF;   
END Remove_Company;
