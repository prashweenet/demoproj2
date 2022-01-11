-----------------------------------------------------------------------------
--
--  Logical unit: PostingCtrlCrecomp
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  050704  Reanpl   FIAD376, Removed column valid_until
--  050524  Ovjose   New generic concept. All handling in <Module>PostingCtrl and
--                   <Module>PostingCtrlDetail files will be handled in here.
--  060206  Rufelk   B132171, Modified the Get_First_Date_From_Tmpl___() function so
--                   that it considered both PostingCtrl & PostingCtrlDetail modules.
--  070208  ovjose   Changed handling of the pc_valid_from and valid_from for posting control
--                   Only active and future active posting control (and sub LU:s) values will be
--                   created in the company. Inactive will be skipped.
--                   Modified most methods. Added Modify_Key_Date_Others___. Removed Get_First_Date___ and Get_First_Date_From_Tmpl___. 
--  070810  Shwilk   Done Assert_SYS corrections.
--  090721  Nsillk   Bug 81727, Corrected.Modified methods Import_Detail_Spec___ and Import_Comb_Detail___
--  090723  Nsillk   Bug 81727, Recorrected. Modified method Import_Comb_Detail_Spec__
--  151204  chiblk   STRFI-682,removing sub methods and rewriting them as implementation methods
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

TYPE r_crecomp_pctrlm IS RECORD(
    code_part           POSTING_CTRL_PUB.code_part%TYPE,
    posting_type        POSTING_CTRL_PUB.posting_type%TYPE,
    control_type        POSTING_CTRL_PUB.control_type%TYPE,
    module              POSTING_CTRL_PUB.module%TYPE,
    override_db         POSTING_CTRL_PUB.override_db%TYPE,
    default_value       POSTING_CTRL_PUB.default_value%TYPE,
    default_value_no_ct POSTING_CTRL_PUB.default_value_no_ct%TYPE,
    pc_valid_from       POSTING_CTRL_PUB.pc_valid_from%TYPE );
TYPE r_crecomp_pctrld IS RECORD(
    code_part                POSTING_CTRL_DETAIL_PUB.code_part%TYPE,
    posting_type             POSTING_CTRL_DETAIL_PUB.posting_type%TYPE,
    code_part_value          POSTING_CTRL_DETAIL_PUB.code_part_value%TYPE,
    control_type_value       POSTING_CTRL_DETAIL_PUB.control_type_value%TYPE,
    control_Type             POSTING_CTRL_DETAIL_PUB.control_type%TYPE,
    module                   POSTING_CTRL_DETAIL_PUB.module%TYPE,
    spec_control_type        POSTING_CTRL_DETAIL_PUB.spec_control_type%TYPE,
    spec_module              POSTING_CTRL_DETAIL_PUB.spec_module%TYPE,
    spec_default_value       POSTING_CTRL_DETAIL_PUB.spec_default_value%TYPE,
    spec_default_value_no_ct POSTING_CTRL_DETAIL_PUB.spec_default_value_no_ct%TYPE,
    valid_from               POSTING_CTRL_DETAIL_PUB.valid_from%TYPE,
    pc_valid_from            POSTING_CTRL_DETAIL_PUB.pc_valid_from%TYPE,
    no_code_part_value       POSTING_CTRL_DETAIL_PUB.no_code_part_value_db%TYPE,
    item_id                  Create_Company_Template_Pub.item_id%TYPE );
TYPE t_crecomp_pctrld IS TABLE OF r_crecomp_pctrld INDEX BY BINARY_INTEGER;
TYPE r_crecomp_pctrl_cd IS RECORD(
    posting_type             POSTING_CTRL_COMB_DETAIL_PUB.posting_type%TYPE,
    comb_control_type        POSTING_CTRL_COMB_DETAIL_PUB.comb_control_type%TYPE,
    control_type1            POSTING_CTRL_COMB_DETAIL_PUB.control_type1%TYPE,
    control_type1_value      POSTING_CTRL_COMB_DETAIL_PUB.control_type1_value%TYPE,
    control_type2            POSTING_CTRL_COMB_DETAIL_PUB.control_type2%TYPE,
    control_type2_value      POSTING_CTRL_COMB_DETAIL_PUB.control_type2_value%TYPE,
    comb_module              POSTING_CTRL_COMB_DETAIL_PUB.comb_module%TYPE,
    module1                  POSTING_CTRL_COMB_DETAIL_PUB.module1%TYPE,
    module2                  POSTING_CTRL_COMB_DETAIL_PUB.module2%TYPE,
    code_part                POSTING_CTRL_COMB_DETAIL_PUB.code_part%TYPE,
    code_part_value          POSTING_CTRL_COMB_DETAIL_PUB.code_part_value%TYPE,
    valid_from               POSTING_CTRL_COMB_DETAIL_PUB.valid_from%TYPE,
    pc_valid_from            POSTING_CTRL_COMB_DETAIL_PUB.pc_valid_from%TYPE,
    no_code_part_value       POSTING_CTRL_COMB_DETAIL_PUB.no_code_part_value_db%TYPE,
    item_id                  Create_Company_Template_Pub.item_id%TYPE );
TYPE t_crecomp_pctrl_cd IS TABLE OF r_crecomp_pctrl_cd INDEX BY BINARY_INTEGER;
TYPE r_crecomp_pctrl_ds IS RECORD(
    code_part                POSTING_CTRL_DETAIL_SPEC_PUB.code_part%TYPE,
    posting_type             POSTING_CTRL_DETAIL_SPEC_PUB.posting_type%TYPE,
    control_type_value       POSTING_CTRL_DETAIL_SPEC_PUB.control_type_value%TYPE,
    spec_control_type        POSTING_CTRL_DETAIL_SPEC_PUB.spec_control_type%TYPE,
    spec_control_type_value  POSTING_CTRL_DETAIL_SPEC_PUB.spec_control_type_value%TYPE,
    spec_module              POSTING_CTRL_DETAIL_SPEC_PUB.spec_module%TYPE,
    code_part_value          POSTING_CTRL_DETAIL_SPEC_PUB.code_part_value%TYPE,
    valid_from               POSTING_CTRL_DETAIL_SPEC_PUB.valid_from%TYPE,
    pc_valid_from            POSTING_CTRL_DETAIL_SPEC_PUB.pc_valid_from%TYPE,
    no_code_part_value       POSTING_CTRL_DETAIL_SPEC_PUB.no_code_part_value_db%TYPE);
TYPE t_crecomp_pctrl_ds IS TABLE OF r_crecomp_pctrl_ds INDEX BY BINARY_INTEGER;
TYPE r_crecomp_pctrl_cds IS RECORD(
    code_part                 POSTING_CTRL_COMB_DET_SPEC_PUB.code_part%TYPE,
    posting_type              POSTING_CTRL_COMB_DET_SPEC_PUB.posting_type%TYPE,
    control_type_value        POSTING_CTRL_COMB_DET_SPEC_PUB.control_type_value%TYPE,
    spec_comb_control_type    POSTING_CTRL_COMB_DET_SPEC_PUB.spec_comb_control_type%TYPE,
    spec_control_type1        POSTING_CTRL_COMB_DET_SPEC_PUB.spec_control_type1%TYPE,
    spec_control_type1_value  POSTING_CTRL_COMB_DET_SPEC_PUB.spec_control_type1_value%TYPE,
    spec_module1              POSTING_CTRL_COMB_DET_SPEC_PUB.spec_module1%TYPE,
    spec_control_type2        POSTING_CTRL_COMB_DET_SPEC_PUB.spec_control_type2%TYPE,
    spec_control_type2_value  POSTING_CTRL_COMB_DET_SPEC_PUB.spec_control_type2_value%TYPE,
    spec_module2              POSTING_CTRL_COMB_DET_SPEC_PUB.spec_module2%TYPE,
    code_part_value           POSTING_CTRL_COMB_DET_SPEC_PUB.code_part_value%TYPE,
    valid_from                POSTING_CTRL_COMB_DET_SPEC_PUB.valid_from%TYPE,
    pc_valid_from             POSTING_CTRL_COMB_DET_SPEC_PUB.pc_valid_from%TYPE,
    no_code_part_value        POSTING_CTRL_COMB_DET_SPEC_PUB.no_code_part_value_db%TYPE);
TYPE t_crecomp_pctrl_cds IS TABLE OF r_crecomp_pctrl_cds INDEX BY BINARY_INTEGER;

-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

FUNCTION Modify_Company_Data___(
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN ENTERP_COMP_CONNECT_V170_API.Crecomp_Lu_Public_Rec,
   level_         IN VARCHAR2 ) RETURN BOOLEAN
IS
   idum_             PLS_INTEGER;
   perform_update_   BOOLEAN;
   TYPE ref_cursor   IS REF CURSOR;
   exist_company_     ref_cursor;
   stmt_             VARCHAR2(2000);
   view_source_      VARCHAR2(30);
BEGIN
   perform_update_ := FALSE;
   view_source_    := 'POSTING_CTRL_PUB';
   view_source_ := CASE level_
                      WHEN 'Master'         THEN 'POSTING_CTRL_PUB'
                      WHEN 'Detail'         THEN 'POSTING_CTRL_DETAIL_PUB'
                      WHEN 'CombDetail'     THEN 'POSTING_CTRL_COMB_DETAIL_PUB'
                      WHEN 'DetailSpec'     THEN 'POSTING_CTRL_DETAIL_SPEC_PUB'
                      WHEN 'CombDetailSpec' THEN 'POSTING_CTRL_COMB_DET_SPEC_PUB'
                   END;
   stmt_ := 'SELECT 1 '                                ||
            'FROM <view_source> '                      ||
            'WHERE company   = :company_ '             ||
            'AND   component = :module_';
   stmt_ := REPLACE(stmt_, '<view_source>', view_source_ );
   --
   IF ( Enterp_Comp_Connect_V170_API.Use_Keys(module_, lu_, crecomp_rec_) ) THEN
      perform_update_ := TRUE;
   ELSE
      @ApproveDynamicStatement(2006-01-27,jeguse)
      OPEN  exist_company_ FOR stmt_ USING crecomp_rec_.company, module_;
      FETCH exist_company_ INTO idum_;
      IF exist_company_%NOTFOUND THEN
         perform_update_ := TRUE;
      END IF;
      CLOSE exist_company_;
   END IF;
   RETURN perform_update_;
END Modify_Company_Data___;


PROCEDURE Import_Master___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   stmt_          VARCHAR2(2000);
BEGIN
   -- Only select the current "active" posting types with regards to pc_valid_from date and posting types
   -- with pc_valid_from dates newer than company valid_from date.
   stmt_  :=
      'SELECT C1 code_part, '                                          ||
             'C2 posting_type, '                                       ||
             'C3 control_type, '                                       ||
             'C4 module, '                                             ||
             'C5 override_db, '                                        ||
             'C6 default_value, '                                      ||
             'C7 default_value_no_ct, '                                ||
             'TRUNC(D1) pc_valid_from '                                ||
      'FROM   Create_Company_Template_Pub s1 '                         ||
      'WHERE  component   = :module_ '                                 ||
      'AND    lu          = :lu_ '                                     ||
      'AND    template_id = :template_id_ '                            ||
      'AND    version     = :version_ '                                ||
      'AND    (D1 > :cre_valid_from '                                  ||
              'OR D1 = (SELECT MAX(s2.D1) '                            ||
              'FROM Create_Company_Template_Pub s2 '                   ||
              'WHERE s1.template_id = s2.template_id '                 ||
              'AND s1.component = s2.component '                       ||
              'AND s1.lu = s2.lu '                                     ||
              'AND s1.version = s2.version '                           ||
              'AND s1.C1 = s2.C1 '                                     ||
              'AND s1.C2 = s2.C2 '                                     ||
              'AND s2.D1 <= :cre_valid_from)) '                        ||
      'ORDER BY D1 ';
   Import_Copy_Master___( module_, lu_, pkg_, crecomp_rec_, stmt_, 'ImportMaster' );  
END Import_Master___;   


PROCEDURE Copy_Master___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   stmt_          VARCHAR2(2000);            
BEGIN
   stmt_ :=
   'SELECT code_part, '                                              ||
          'posting_type, '                                           ||
          'control_type, '                                           ||
          'module, '                                                 ||
          'override_db, '                                            ||
          'default_value, '                                          ||
          'default_value_no_ct, '                                    ||
          'TRUNC(pc_valid_from) '                                    ||
   'FROM   POSTING_CTRL_PUB s1 '                                                ||
   'WHERE  company   = :old_company_ '                               ||
   'AND    component = :module_ '                                    ||
   'AND    (pc_valid_from > :cre_valid_from '                        ||
           'OR pc_valid_from = (SELECT MAX(s2.pc_valid_from) '       ||
           'FROM POSTING_CTRL_PUB s2 '                                          ||
           'WHERE s1.company = s2.company '                          ||
           'AND s1.component = s2.component '                        ||
           'AND s1.code_part = s2.code_part '                        ||
           'AND s1.posting_type = s2.posting_type '                  ||
           'AND s2.pc_valid_from <= :cre_valid_from)) '              ||
   'ORDER BY pc_valid_from ';
   Import_Copy_Master___( module_, lu_, pkg_, crecomp_rec_, stmt_ , 'CopyMaster');
END Copy_Master___;


PROCEDURE Export_Master___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_       Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   POSTING_CTRL_GEN_PCT
      WHERE  company = crecomp_rec_.company
      AND    component = module_;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component := module_;
      pub_rec_.version  := crecomp_rec_.version;
      pub_rec_.lu := lu_;
      pub_rec_.item_id := i_;
      pub_rec_.c1 := pctrec_.code_part;
      pub_rec_.c2 := pctrec_.posting_type;
      pub_rec_.c3 := pctrec_.control_type;
      pub_rec_.c4 := pctrec_.module;
      pub_rec_.c5 := pctrec_.override_db;
      pub_rec_.c6 := pctrec_.default_value;
      pub_rec_.c7 := pctrec_.default_value_no_ct;
      pub_rec_.d1 := pctrec_.pc_valid_from;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Master___;


PROCEDURE Import_Copy_Master___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   stmt_          IN VARCHAR2,
   bind_using_    IN VARCHAR2 ) 
IS
   msg_               VARCHAR2(2000);
   i_                 NUMBER := 0;
   TYPE RecordType    IS REF CURSOR;
   get_data_          RecordType;
   master_rec_        r_crecomp_pctrlm;

   company_valid_from_  DATE;
BEGIN
   IF (Modify_Company_Data___(module_, lu_, crecomp_rec_, 'Master') ) THEN
      IF (bind_using_ = 'ImportMaster') THEN
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING module_, 
                                       lu_, 
                                       crecomp_rec_.template_id,
                                       crecomp_rec_.version,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      ELSE
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING crecomp_rec_.old_company,
                                       module_,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      END IF;

      company_valid_from_ := TRUNC(crecomp_rec_.valid_from);

      FETCH get_data_ INTO master_rec_;
      WHILE get_data_%FOUND LOOP
         i_ := i_ + 1;

         -- only modify pc_valid_from if earlier than create company valid from date. 
         IF ( master_rec_.pc_valid_from < company_valid_from_ ) THEN
            master_rec_.pc_valid_from := company_valid_from_;
         END IF;

         BEGIN            
            Posting_Ctrl_API.Insert_Posting_Control(crecomp_rec_.company,
                                                    master_rec_.posting_type,
                                                    master_rec_.code_part,
                                                    master_rec_.control_type,
                                                    master_rec_.module,
                                                    master_rec_.override_db,
                                                    master_rec_.default_value,
                                                    master_rec_.default_value_no_ct,
                                                    master_rec_.pc_valid_from);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);                     
         END;
         FETCH get_data_ INTO master_rec_;
      END LOOP;
      CLOSE get_data_;
      -- Should this if statemenst be removed ? The check if 1_ = 0 since displaying No Data Found is not any use for the user
      IF ( i_ = 0 ) THEN
         msg_ := language_sys.translate_constant(lu_name_, 'NODATAFOUND: No Data Found');
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully', msg_);
      ELSE
         IF (msg_ IS NULL) THEN
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
         ELSE
            Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
         END IF;                     
      END IF;  
   ELSE
      -- This statement is to add to the log that the Create company process for the LU is finished
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);            
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');                           
END Import_Copy_Master___;   


PROCEDURE Modify_Key_Date_Master___( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )
IS
   template_rec_       Create_Company_Tem_API.Public_Rec_Templ;
   i_                  NUMBER := 0;
   do_update_          BOOLEAN := FALSE;

   CURSOR get_template_data IS
      SELECT *
      FROM   Create_Company_Template_Pub s1
      WHERE  component   = module_
      AND    lu          = lu_
      AND    template_id = crecomp_rec_.template_id
      AND    (D1 > crecomp_rec_.valid_from
             OR D1 = (SELECT MAX(D1)
             FROM Create_Company_Template_Pub s2
             WHERE s1.component = s2.component 
             AND   s1.lu = s2.lu
             AND   s1.template_id = s2.template_id
             AND   s2.D1 <= crecomp_rec_.valid_from))
      ORDER BY D1
      FOR UPDATE NOWAIT;
BEGIN
   OPEN  get_template_data;
   FETCH get_template_data INTO template_rec_;
   WHILE get_template_data%FOUND LOOP
      i_ := i_ + 1;

      do_update_ := FALSE;
      -- only modify d1(pc_valid_from) if earlier than create company valid from date. 
      IF (template_rec_.d1 < crecomp_rec_.valid_from) THEN
         do_update_ := TRUE;
         -- Need to modify child LU data as well since it is parent key in child LU.
         Upd_Diff_Templ_Pctrl_Gen___(template_rec_,
                                     'PostingCtrlDetail',
                                     crecomp_rec_.valid_from,
                                     NULL );

         Upd_Diff_Templ_Pctrl_Gen___(template_rec_,
                                     'PostingCtrlCombDet',
                                     crecomp_rec_.valid_from,
                                     NULL );
         --
         template_rec_.d1 := crecomp_rec_.valid_from;
      END IF;

      IF do_update_ THEN
         Enterp_Comp_Connect_V170_API.Update_Diff_Template( template_rec_ );
      END IF;

      --Enterp_Comp_Connect_V170_API.Update_Diff_Template( template_rec_ );
      FETCH get_template_data INTO template_rec_;
   END LOOP;
   CLOSE get_template_data;
END Modify_Key_Date_Master___;


PROCEDURE Import_Detail___ ( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
   'SELECT C1        code_part, '                             ||
          'C2        posting_type, '                          ||
          'C3        code_part_value, '                       ||
          'C4        control_type_value, '                    ||
          'C5        control_type, '                          ||
          'C6        module, '                                ||
          'C7        spec_control_type, '                     ||
          'C8        spec_module, '                           ||
          'C9        spec_default_value, '                    ||
          'C10       spec_default_value_no_ct, '              ||
          'trunc(D1) valid_from, '                            ||
          'trunc(D3) pc_valid_from, '                         ||
          'C11       no_code_part_value, '                    ||
          'ITEM_ID   item_id '                                ||
   'FROM   Create_Company_Template_Pub s1 '                   ||
   'WHERE  component   = :module_ '                           ||
   'AND    lu          = :lu_ '                               ||
   'AND    template_id = :template_id_ '                      ||
   'AND    version     = :version_ '                          ||
   'AND    (D1 > :cre_valid_from '                            ||
           'OR D1 = (SELECT MAX(s2.D1) '                      ||
                    'FROM Create_Company_Template_Pub s2 '    ||
                    'WHERE s1.template_id = s2.template_id '  ||
                    'AND s1.component = s2.component '        ||
                    'AND s1.lu = s2.lu '                      ||
                    'AND s1.version = s2.version '            ||
                    'AND s1.C1 = s2.C1 '                      ||
                    'AND s1.C2 = s2.C2 '                      ||
                    'AND s1.C4 = s2.C4 '                      ||
                    'AND s1.D3 = s2.D3 '                      ||
                    'AND s2.D1 <= :cre_valid_from)) '         ||
   'AND    D3 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :master_lu '             ||
                 'AND s1.C1 = s3.C1 '                         ||
                 'AND s1.C2 = s3.C2 '                         ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '     ||
                             'WHERE s3.template_id = s4.template_id '   ||
                             'AND s3.component = s4.component '         ||
                             'AND s3.lu = s4.lu '                       ||
                             'AND s3.C1 = s4.C1 '                       ||
                             'AND s3.C2 = s4.C2 '                       ||
                             'AND s4.D1 <= :cre_valid_from))) '         ||
   'ORDER BY D3, D1 ' ;
   --
   Import_Copy_Detail___( module_, lu_, pkg_, crecomp_rec_, stmt_, 'ImportDetail' );
END Import_Detail___;   


PROCEDURE Copy_Detail___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
      'SELECT code_part                 code_part, '                ||
             'posting_type              posting_type, '             ||
             'code_part_value           code_part_value, '          ||
             'control_type_value        control_type_value, '       ||
             'control_type              control_type, '             ||
             'module                    module, '                   ||
             'spec_control_type         spec_control_type, '        ||
             'spec_module               spec_module, '              ||
             'spec_default_value        spec_default_value, '       ||
             'spec_default_value_no_ct  spec_default_value_no_ct, ' ||
             'trunc(valid_from)         valid_from, '               ||
             'trunc(pc_valid_from)      pc_valid_from, '            ||
             'no_code_part_value_db     no_code_part_value, '       ||
             '0                         item_id '                   ||
       'FROM   POSTING_CTRL_DETAIL_PUB s1 '                                    ||
       'WHERE  company  = :old_company '                            ||
       'AND    component= :module_ '                                ||
       'AND    (valid_from > :cre_valid_from '                      ||
               'OR valid_from = (SELECT MAX(valid_from) '           ||
                        'FROM POSTING_CTRL_DETAIL_PUB s2 '                     ||
                        'WHERE s1.company = s2.company '            ||
                        'AND s1.component = s2.component '          ||
                        'AND s1.code_part = s2.code_part '          ||
                        'AND s1.posting_type = s2.posting_type '    ||
                        'AND s1.control_type_value = s2.control_type_value '||
                        'AND s1.pc_valid_from = s2.pc_valid_from '  ||
                        'AND valid_from <= :cre_valid_from)) '      ||
       'AND    pc_valid_from IN (SELECT pc_valid_from '             ||
                     'FROM POSTING_CTRL_PUB s3 '                               ||
                     'WHERE s1.company = s3.company '               ||
                     'AND s1.component = s3.component '             ||
                     'AND s1.code_part = s3.code_part '             ||
                     'AND s1.posting_type = s3.posting_type '       ||
                     'AND (s3.pc_valid_from > :cre_valid_from '     ||
                     'OR s3.pc_valid_from = (SELECT MAX(s4.pc_valid_from) '   ||
                                 'FROM POSTING_CTRL_PUB s4 '                             ||
                                 'WHERE s1.company = s4.company '             ||
                                 'AND s1.component = s4.component '           ||
                                 'AND s1.code_part = s4.code_part '           ||
                                 'AND s1.posting_type = s4.posting_type '     ||
                                 'AND s4.pc_valid_from <= :cre_valid_from))) '||
       'ORDER BY pc_valid_from, valid_from ' ;
   Import_Copy_Detail___( module_, lu_, pkg_, crecomp_rec_, stmt_ , 'CopyDetail');
END Copy_Detail___;


PROCEDURE Export_Detail___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   POSTING_CTRL_DETAIL_GEN_PCT
      WHERE  company = crecomp_rec_.company
      AND    component = module_;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_;
      pub_rec_.item_id     := i_;
      pub_rec_.c1          := pctrec_.code_part;
      pub_rec_.c2          := pctrec_.posting_type;
      pub_rec_.c3          := pctrec_.code_part_value;
      pub_rec_.c4          := pctrec_.control_type_value;
      pub_rec_.c5          := pctrec_.control_type;
      pub_rec_.c6          := pctrec_.module;
      pub_rec_.c7          := pctrec_.spec_control_type;
      pub_rec_.c8          := pctrec_.spec_module;
      pub_rec_.c9          := pctrec_.spec_default_value;
      pub_rec_.c10         := pctrec_.spec_default_value_no_ct;
      pub_rec_.d1          := pctrec_.valid_from;
      pub_rec_.d3          := pctrec_.pc_valid_from;
      pub_rec_.c11         := pctrec_.no_code_part_value_db;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Detail___;


PROCEDURE Import_Copy_Detail___( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   stmt_          IN VARCHAR2,
   bind_using_    IN VARCHAR2 )
IS
   crecomp_pctrl_tab_      t_crecomp_pctrld;
BEGIN
   IF (Modify_Company_Data___(module_, lu_, crecomp_rec_, 'Detail' ) ) THEN
      -- If current LU in current company shall be updated, then start with
      -- collecting all posting control information in a table. Each record in the
      -- table will also be modified with respect to valid_from date
      Create_Table_Rec_Detail___( crecomp_pctrl_tab_,
                                  module_,
                                  lu_,
                                  crecomp_rec_,
                                  stmt_,
                                  bind_using_ );
       -- Now perform the update of posting control detail information for the current company
      Update_Pctrl_Detail___( module_, pkg_, crecomp_rec_.company, crecomp_pctrl_tab_ );
   END IF;
END Import_Copy_Detail___;


PROCEDURE Create_Table_Rec_Detail___( 
   crecomp_pctrl_tab_ OUT t_crecomp_pctrld,
   module_            IN  VARCHAR2,
   lu_                IN  VARCHAR2,
   crecomp_rec_       IN  Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   stmt_              IN  VARCHAR2,
   bind_using_        IN  VARCHAR2)
IS
   TYPE RecordType         IS REF CURSOR;
   get_data_               RecordType;
   crecomp_pctr_rec_       r_crecomp_pctrld;
   i_                      INTEGER := 0;

   company_valid_from_     DATE;
BEGIN
   -- Collect all posting control information in a table. Each record in the
   -- table will also be modified with respect to valid_from date
   IF (bind_using_ = 'ImportDetail') THEN
      @ApproveDynamicStatement(2006-01-27,jeguse)
      OPEN get_data_ FOR stmt_ USING module_, 
                                    lu_, 
                                    crecomp_rec_.template_id, 
                                    crecomp_rec_.version,
                                    crecomp_rec_.valid_from,
                                    crecomp_rec_.valid_from,
                                    UPPER(module_||'PostingCtrl'),           -- join with master lu
                                    crecomp_rec_.valid_from,
                                    crecomp_rec_.valid_from;
   ELSIF (bind_using_ = 'CopyDetail') THEN
      @ApproveDynamicStatement(2006-01-27,jeguse)
      OPEN get_data_ FOR stmt_ USING crecomp_rec_.old_company, 
                                    module_,
                                    crecomp_rec_.valid_from,
                                    crecomp_rec_.valid_from,
                                    crecomp_rec_.valid_from,
                                    crecomp_rec_.valid_from;
   ELSE
      RETURN;
   END IF;

   company_valid_from_ := TRUNC(crecomp_rec_.valid_from);

   FETCH get_data_ INTO crecomp_pctr_rec_;
   WHILE get_data_%FOUND LOOP
      i_ := i_ + 1;
      
      -- only modify pc_valid_from and valid_from dates if earlier than create company valid from date. 
      IF ( crecomp_pctr_rec_.pc_valid_from < company_valid_from_ ) THEN
         crecomp_pctr_rec_.pc_valid_from := company_valid_from_;
      END IF;

      IF ( crecomp_pctr_rec_.valid_from < company_valid_from_ ) THEN
         crecomp_pctr_rec_.valid_from := company_valid_from_;
      END IF;

      crecomp_pctrl_tab_(i_) := crecomp_pctr_rec_;
           
      FETCH get_data_ INTO crecomp_pctr_rec_;
   END LOOP;
   CLOSE get_data_;   
END Create_Table_Rec_Detail___;


PROCEDURE Update_Pctrl_Detail___( 
   module_             IN VARCHAR2, 
   pkg_                IN VARCHAR2,
   company_            IN VARCHAR2,
   crecomp_pctrl_tab_  IN t_crecomp_pctrld)
IS
   dummy_  VARCHAR2(1);
   msg_    VARCHAR2(2000);
   i1_     INTEGER;
   i2_     INTEGER;
   CURSOR exist_key (posting_type_       IN VARCHAR2, 
                     code_part_          IN VARCHAR2, 
                     pc_valid_from_      IN DATE,
                     control_type_value_ IN VARCHAR2,
                     valid_from_         IN DATE) IS
      SELECT 'X'
      FROM   POSTING_CTRL_DETAIL_PUB
      WHERE  company            = company_
      AND    posting_type       = posting_type_
      AND    code_part          = code_part_
      AND    pc_valid_from      = pc_valid_from_
      AND    control_type_value = control_type_value_
      AND    valid_from         = valid_from_;
BEGIN
   IF (crecomp_pctrl_tab_.COUNT > 0) THEN
      i1_ := crecomp_pctrl_tab_.FIRST;
      i2_ := crecomp_pctrl_tab_.LAST;
      FOR j_ IN i1_..i2_ LOOP
         OPEN exist_key(crecomp_pctrl_tab_(j_).posting_type, 
                        crecomp_pctrl_tab_(j_).code_part, 
                        crecomp_pctrl_tab_(j_).pc_valid_from,
                        crecomp_pctrl_tab_(j_).control_type_value,
                        crecomp_pctrl_tab_(j_).valid_from);
         FETCH exist_key INTO dummy_;
         IF (exist_key%NOTFOUND) THEN
            BEGIN
               Posting_Ctrl_API.Insert_Posting_Control_Detail(
                                company_,
                                crecomp_pctrl_tab_(j_).posting_type,
                                crecomp_pctrl_tab_(j_).code_part,
                                crecomp_pctrl_tab_(j_).code_part_value,
                                crecomp_pctrl_tab_(j_).control_type,
                                crecomp_pctrl_tab_(j_).control_type_value,
                                crecomp_pctrl_tab_(j_).module,
                                crecomp_pctrl_tab_(j_).valid_from,
                                crecomp_pctrl_tab_(j_).pc_valid_from,
                                crecomp_pctrl_tab_(j_).spec_control_type,
                                crecomp_pctrl_tab_(j_).spec_module,
                                crecomp_pctrl_tab_(j_).spec_default_value,
                                crecomp_pctrl_tab_(j_).spec_default_value_no_ct,
                                crecomp_pctrl_tab_(j_).no_code_part_value );
            EXCEPTION
               WHEN OTHERS THEN
                  msg_ := SQLERRM;
                  Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, pkg_, 'Error', msg_);                     
            END;
         END IF;
         CLOSE exist_key;
      END LOOP;
      IF (msg_ IS NULL) THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, pkg_, 'CreatedSuccessfully');                  
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, pkg_, 'CreatedWithErrors');                     
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, pkg_, 'Error', msg_);            
      Enterp_Comp_Connect_V170_API.Log_Logging(company_, module_, pkg_, 'CreatedWithErrors');                           
END Update_Pctrl_Detail___;


PROCEDURE Modify_Key_Date_Detail___( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   attr_          IN VARCHAR2 )
IS
   template_rec_       Create_Company_Tem_API.Public_Rec_Templ;
   i_                  NUMBER := 0;
   master_lu_          VARCHAR2(30) := UPPER(module_ || 'PostingCtrl');

   do_update_          BOOLEAN := FALSE;
   temp_date1_         DATE;
   temp_date2_         DATE;

   CURSOR get_template_data IS
      SELECT *
      FROM   Create_Company_Template_Pub s1
      WHERE  component   = module_
      AND    lu          = lu_
      AND    template_id = crecomp_rec_.template_id
      AND    (D1 > crecomp_rec_.valid_from
              OR D1 = (SELECT MAX(s2.D1)
                       FROM Create_Company_Template_Pub s2
                       WHERE s1.template_id = s2.template_id
                       AND s1.component = s2.component
                       AND s1.lu = s2.lu
                       AND s1.version = s2.version
                       AND s1.C1 = s2.C1
                       AND s1.C2 = s2.C2
                       AND s1.C4 = s2.C4
                       AND s1.D3 = s2.D3
                       AND s2.D1 <= crecomp_rec_.valid_from))
      AND    D3 IN (SELECT s3.D1
                    FROM Create_Company_Template_Pub s3
                    WHERE s1.template_id = s3.template_id
                    AND s1.component = s3.component
                    AND UPPER(s3.LU) = master_lu_
                    AND s1.C1 = s3.C1
                    AND s1.C2 = s3.C2
                    AND (s3.D1 > crecomp_rec_.valid_from 
                    OR s3.D1 = (SELECT MAX(s4.D1)
                                FROM Create_Company_Template_Pub s4
                                WHERE s3.template_id = s4.template_id
                                AND s3.component = s4.component
                                AND s3.lu = s4.lu
                                AND s3.C1 = s4.C1
                                AND s3.C2 = s4.C2
                                AND s4.D1 <= crecomp_rec_.valid_from)))
      ORDER BY D3, D1
      FOR UPDATE NOWAIT;
BEGIN
   OPEN  get_template_data;
   FETCH get_template_data INTO template_rec_;
   WHILE get_template_data%FOUND LOOP
      i_ := i_ + 1;
      do_update_ := FALSE;
      temp_date1_ := NULL;
      temp_date2_ := NULL;

      -- only modify pc_valid_from and valid_from dates if earlier than create company valid from date. 
      IF ( template_rec_.d3 < crecomp_rec_.valid_from ) THEN
         temp_date1_ := crecomp_rec_.valid_from;
         do_update_ := TRUE;
      END IF;

      IF (template_rec_.d1 < crecomp_rec_.valid_from) THEN
         temp_date2_ := crecomp_rec_.valid_from;
         do_update_ := TRUE;
      END IF;

      IF do_update_ THEN

         Upd_Diff_Templ_Pctrl_Gen___(template_rec_,
                                     'PostingCtrlDetSpec',
                                     temp_date1_,
                                     temp_date2_ );
         Upd_Diff_Templ_Pctrl_Gen___(template_rec_,
                                     'PostingCtrlCDetSpec',
                                     temp_date1_,
                                     temp_date2_ );

         template_rec_.d1 := NVL(temp_date2_, template_rec_.d1);
         template_rec_.d3 := NVL(temp_date1_, template_rec_.d3);
         Enterp_Comp_Connect_V170_API.Update_Diff_Template( template_rec_ );
      END IF;
      FETCH get_template_data INTO template_rec_;
   END LOOP;
   CLOSE get_template_data;
END Modify_Key_Date_Detail___;


PROCEDURE Import_Comb_Detail___ ( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
   'SELECT C1              posting_type, '             ||
          'C2              comb_control_type, '        ||
          'C3              control_type1, '            ||
          'C4              control_type1_value, '      ||
          'C5              control_type2, '            ||
          'C6              control_type2_value, '      ||
          'C7              comb_module, '              ||
          'C8              module1, '                  ||
          'C9              module2, '                  ||
          'C10             code_part, '                ||
          'C11             code_part_value, '          ||
          'trunc(D1)       valid_from, '               ||
          'trunc(D2)       pc_valid_from, '            ||
          'C12             no_code_part_value, '       ||
          'item_id         item_id '                   ||
   'FROM   Create_Company_Template_Pub s1 '            ||
   'WHERE  component   = :module_ '                    ||
   'AND    lu          = :lu_ '                        ||
   'AND    template_id = :template_id_ '               ||
   'AND    version     = :version_ '                   ||
   'AND    (D1 > :cre_valid_from '                     ||
           'OR D1 = (SELECT MAX(s2.D1) '               ||
           'FROM Create_Company_Template_Pub s2 '      ||
           'WHERE s1.template_id = s2.template_id '    ||
           'AND s1.component = s2.component '          ||
           'AND s1.lu = s2.lu '                        ||
           'AND s1.version = s2.version '              ||
           'AND s1.C1 = s2.C1 '                        ||
           'AND s1.C2 = s2.C2 '                        ||
           'AND s1.C3 = s2.C3 '                        ||
           'AND s1.C4 = s2.C4 '                        ||
           'AND s1.C5 = s2.C5 '                        ||
           'AND s1.C6 = s2.C6 '                        ||
           'AND s1.C10 = s2.C10 '                      ||
           'AND s1.D2 = s2.D2 '                        ||
           'AND D1 <= :cre_valid_from)) '              ||
   'AND    D2 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :master_lu '             ||
                 'AND s1.C1 = s3.C2 '                         ||
                 'AND s1.C10 = s3.C1 '                        ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '     ||
                             'WHERE s3.template_id = s4.template_id '   ||
                             'AND s3.component = s4.component '         ||
                             'AND s3.lu = s4.lu '                       ||
                             'AND s3.C1 = s4.C1 '                       ||
                             'AND s3.C2 = s4.C2 '                      ||
                             'AND s4.D1 <= :cre_valid_from))) '         ||
   'ORDER BY D2, D1 ' ;
   --
   Import_Copy_Comb_Detail___( module_, lu_, pkg_, crecomp_rec_, stmt_, 'ImportCombDetail' );
END Import_Comb_Detail___;   


PROCEDURE Copy_Comb_Detail___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
      'SELECT posting_type              posting_type, '              ||
             'comb_control_type         comb_control_type, '         ||
             'control_type1             control_type1, '             ||
             'control_type1_value       control_type1_value, '       ||
             'control_type2             control_type2, '             ||
             'control_type2_value       control_type2_value, '       ||
             'comb_module               comb_module, '               ||
             'module1                   module1, '                   ||
             'module2                   module2, '                   ||
             'code_part                 code_part, '                 ||
             'code_part_value           code_part_value, '           ||
             'trunc(valid_from)         valid_from, '                ||
             'trunc(pc_valid_from)      pc_valid_from, '             ||
             'no_code_part_value_db     no_code_part_value, '        ||
             '0                         item_id '                    ||
       'FROM   POSTING_CTRL_COMB_DETAIL_PUB s1 '                                    ||
       'WHERE  company  = :old_company '                             ||
       'AND    component= :module_ '                                 ||
       'AND    (valid_from > :cre_valid_from '                       ||
               'OR valid_from = (SELECT MAX(valid_from) '            ||
               'FROM POSTING_CTRL_COMB_DETAIL_PUB s2 '                              ||
               'WHERE s1.company = s2.company '                      ||
               'AND s1.component = s2.component '                    ||
               'AND s1.posting_type = s2.posting_type '              ||
               'AND s1.comb_control_type = s2.comb_control_type '    ||
               'AND s1.control_type1 = s2.control_type1 '            ||
               'AND s1.control_type1_value = s2.control_type1_value '||
               'AND s1.control_type2 = s2.control_type2 '            ||
               'AND s1.control_type2_value = s2.control_type2_value '||
               'AND s1.code_part = s2.code_part '                    ||
               'AND s1.pc_valid_from = s2.pc_valid_from '            ||
               'AND valid_from <= :cre_valid_from)) '                ||
       'AND    pc_valid_from IN (SELECT s3.pc_valid_from '                 ||
                     'FROM POSTING_CTRL_PUB s3 '                                      ||
                     'WHERE s1.company = s3.company '                      ||
                     'AND s1.component = s3.component '                    ||
                     'AND s1.posting_type = s3.posting_type '              ||
                     'AND s1.code_part = s3.code_part '                    ||
                     'AND (s3.pc_valid_from > :cre_valid_from '            ||
                     'OR s3.pc_valid_from = (SELECT MAX(s4.pc_valid_from) '||
                                 'FROM POSTING_CTRL_PUB s4 '                          ||
                                 'WHERE s3.company = s4.company '          ||
                                 'AND s3.component = s4.component '        ||
                                 'AND s3.posting_type = s4.posting_type '  ||
                                 'AND s3.code_part = s4.code_part '        ||
                                 'AND s4.pc_valid_from <= :cre_valid_from))) '||
       'ORDER BY pc_valid_from, valid_from ' ;
   Import_Copy_Comb_Detail___( module_, lu_, pkg_, crecomp_rec_, stmt_ , 'CopyCombDetail');
END Copy_Comb_Detail___;


PROCEDURE Export_Comb_Detail___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   POSTING_CTRL_COMB_DET_GEN_PCT
      WHERE  company = crecomp_rec_.company
      AND    component = module_;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_;
      pub_rec_.item_id     := i_;     
      pub_rec_.c1          := pctrec_.posting_type;
      pub_rec_.c2          := pctrec_.comb_control_type;
      pub_rec_.c3          := pctrec_.control_type1;
      pub_rec_.c4          := pctrec_.control_type1_value;
      pub_rec_.c5          := pctrec_.control_type2;
      pub_rec_.c6          := pctrec_.control_type2_value;
      pub_rec_.c7          := pctrec_.comb_module;
      pub_rec_.c8          := pctrec_.module1;
      pub_rec_.c9          := pctrec_.module2;
      pub_rec_.c10         := pctrec_.code_part;
      pub_rec_.c11         := pctrec_.code_part_value;     
      pub_rec_.d1          := pctrec_.valid_from;
      pub_rec_.d2          := pctrec_.pc_valid_from;
      pub_rec_.c12         := pctrec_.no_code_part_value_db;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Comb_Detail___;


PROCEDURE Import_Copy_Comb_Detail___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   stmt_          IN VARCHAR2,
   bind_using_    IN VARCHAR2 ) 
IS
   msg_                VARCHAR2(2000);
   i_                  NUMBER := 0;
   TYPE RecordType     IS REF CURSOR;
   get_data_           RecordType;
   detail_rec_         r_crecomp_pctrl_cd;   
   company_valid_from_ DATE;
BEGIN
   IF (Modify_Company_Data___(module_, lu_, crecomp_rec_, 'CombDetail') ) THEN
      IF (bind_using_ = 'ImportCombDetail') THEN
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING module_, 
                                       lu_, 
                                       crecomp_rec_.template_id,
                                       crecomp_rec_.version,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       UPPER(module_||'PostingCtrl'),
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      ELSIF (bind_using_ = 'CopyCombDetail') THEN
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING crecomp_rec_.old_company,
                                       module_,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      END IF;

      company_valid_from_ := TRUNC(crecomp_rec_.valid_from);

      FETCH get_data_ INTO detail_rec_;
      WHILE get_data_%FOUND LOOP
         i_ := i_ + 1;
         -- only modify pc_valid_from and valid_from dates if earlier than create company valid from date. 
         IF ( detail_rec_.pc_valid_from < company_valid_from_ ) THEN
            detail_rec_.pc_valid_from := company_valid_from_;
         END IF;

         IF ( detail_rec_.valid_from < company_valid_from_ ) THEN
            detail_rec_.valid_from := company_valid_from_;
         END IF;

         BEGIN            
            Posting_Ctrl_Comb_Detail_API.Insert_Posting_Ctrl_Comb_Det
                                                   (crecomp_rec_.company,
                                                    detail_rec_.posting_type,
                                                    detail_rec_.pc_valid_from,
                                                    detail_rec_.comb_control_type,
                                                    detail_rec_.control_type1,
                                                    detail_rec_.control_type1_value,
                                                    detail_rec_.control_type2,
                                                    detail_rec_.control_type2_value,
                                                    detail_rec_.comb_module,
                                                    detail_rec_.module1,
                                                    detail_rec_.module2,
                                                    detail_rec_.code_part,
                                                    detail_rec_.code_part_value,
                                                    detail_rec_.valid_from,
                                                    detail_rec_.no_code_part_value);
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);                     
         END;
         FETCH get_data_ INTO detail_rec_;
      END LOOP;
      CLOSE get_data_;
      IF (msg_ IS NULL) THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
      END IF;                     
   ELSE
      -- This statement is to add to the log that the Create company process for the LU is finished
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);            
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');                           
END Import_Copy_Comb_Detail___;   


PROCEDURE Import_Detail_Spec___ ( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
   'SELECT C1        code_part, '                             ||
          'C2        posting_type, '                          ||
          'C3        control_type_value, '                    ||
          'C4        spec_control_type, '                     ||
          'C5        spec_control_type_value, '               ||
          'C6        spec_module, '                           ||
          'C7        code_part_value, '                       ||
          'trunc(D1) valid_from, '                            ||
          'trunc(D2) pc_valid_from, '                         ||
          'C8        no_code_part_value '                     ||
   'FROM   Create_Company_Template_Pub s1 '                   ||
   'WHERE  component   = :module_ '                           ||
   'AND    lu          = :lu_ '                               ||
   'AND    template_id = :template_id_ '                      ||
   'AND    version     = :version_ '                          ||
   'AND    D1 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :detail_lu '             ||
                 'AND s1.C1 = s3.C1 '                         ||
                 'AND s1.C2 = s3.C2 '                         ||
                 'AND s1.C3 = s3.C4 '                         ||
                 'AND s1.D2 = s3.D3 '                         ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '    ||
                             'WHERE s3.template_id = s4.template_id '  ||
                             'AND s3.component = s4.component '        ||
                             'AND s3.lu = s4.lu '                      ||
                             'AND s3.version = s4.version '            ||
                             'AND s3.C1 = s4.C1 '                      ||
                             'AND s3.C2 = s4.C2 '                      ||
                             'AND s3.C4 = s4.C4 '                      ||
                             'AND s3.D3 = s4.D3 '                      ||
                             'AND s4.D1 <= :cre_valid_from)) '         ||
                 'AND    s3.D3 IN (SELECT s5.D1 '                      ||
                               'FROM Create_Company_Template_Pub s5 '  ||
                               'WHERE s3.template_id = s5.template_id '||
                               'AND s3.component = s5.component '      ||
                               'AND UPPER(s5.LU) = :master_lu '        ||
                               'AND s3.C1 = s5.C1 '                    ||
                               'AND s3.C2 = s5.C2 '                    ||
                               'AND (s5.D1 > :cre_valid_from '         ||
                               'OR s5.D1 = (SELECT MAX(s6.D1) '                     ||
                                           'FROM Create_Company_Template_Pub s6 '   ||
                                           'WHERE s5.template_id = s6.template_id ' ||
                                           'AND s5.component = s6.component '       ||
                                           'AND s5.lu = s6.lu '                     ||
                                           'AND s5.C1 = s6.C1 '                     ||
                                           'AND s5.C2 = s6.C2 '                     ||
                                           'AND s6.D1 <= :cre_valid_from)))) '      ||
   'ORDER BY D2, D1 ' ;
   --
   Import_Copy_Detail_Spec___( module_, lu_, pkg_, crecomp_rec_, stmt_, 'ImportDetailSpec' );
END Import_Detail_Spec___;   


PROCEDURE Copy_Detail_Spec___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
   'SELECT code_part                 code_part, '                ||
          'posting_type              posting_type, '             ||
          'control_type_value        control_type_value, '       ||
          'spec_control_type         spec_control_type, '        ||
          'spec_control_type_value   spec_control_type_value, '  ||
          'spec_module               spec_module, '              ||
          'code_part_value           code_part_value, '          ||
          'trunc(valid_from)         valid_from, '               ||
          'trunc(pc_valid_from)      pc_valid_from, '            ||
          'no_code_part_value_db     no_code_part_value '        ||
   'FROM   POSTING_CTRL_DETAIL_SPEC_PUB s1 '                                    ||
   'WHERE  company  = :old_company '                             ||
   'AND    component= :module_ '                                 ||
   'AND    valid_from IN (SELECT s3.valid_from '                           ||
                 'FROM POSTING_CTRL_DETAIL_PUB s3 '                                   ||
                 'WHERE s1.company = s3.company '                          ||
                 'AND s1.component = s3.component '                        ||
                 'AND s1.code_part = s3.code_part '                        ||
                 'AND s1.posting_type = s3.posting_type '                  ||
                 'AND s1.control_type_value = s3.control_type_value '      ||
                 'AND s1.pc_valid_from = s3.pc_valid_from '                ||
                 'AND (s3.valid_from > :cre_valid_from '                   ||
                 'OR s3.valid_from = (SELECT MAX(s4.valid_from) '                ||
                             'FROM POSTING_CTRL_DETAIL_PUB s4 '                             ||
                             'WHERE s3.company = s4.company '                    ||
                             'AND s3.component = s4.component '                  ||
                             'AND s3.code_part = s4.code_part '                  ||
                             'AND s3.posting_type = s4.posting_type '            ||
                             'AND s3.control_type_value = s4.control_type_value '||
                             'AND s3.pc_valid_from = s4.pc_valid_from '          ||
                             'AND s4.valid_from <= :cre_valid_from)) '           ||
                 'AND    s3.pc_valid_from IN (SELECT s5.pc_valid_from '          ||
                               'FROM POSTING_CTRL_PUB s5 '                                  ||
                               'WHERE s3.company = s5.company '                  ||
                               'AND s3.component = s5.component '                ||
                               'AND s3.code_part = s5.code_part '                ||
                               'AND s3.posting_type = s5.posting_type '          ||
                               'AND (s5.pc_valid_from > :cre_valid_from '        ||
                               'OR s5.pc_valid_from = (SELECT MAX(s6.pc_valid_from) '  ||
                                           'FROM POSTING_CTRL_PUB s6 '                            ||
                                           'WHERE s5.company = s6.company '            ||
                                           'AND s5.component = s6.component '          ||
                                           'AND s5.code_part = s6.code_part '          ||
                                           'AND s5.posting_type = s6.posting_type '    ||
                                           'AND s6.pc_valid_from <= :cre_valid_from)))) '||
       'ORDER BY pc_valid_from, valid_from ' ;
   Import_Copy_Detail_Spec___( module_, lu_, pkg_, crecomp_rec_, stmt_ , 'CopyDetailSpec');
END Copy_Detail_Spec___;


PROCEDURE Export_Detail_Spec___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   POSTING_CTRL_DET_SPEC_GEN_PCT
      WHERE  company = crecomp_rec_.company
      AND    component = module_;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_;
      pub_rec_.item_id     := i_;
      pub_rec_.c1          := pctrec_.code_part;
      pub_rec_.c2          := pctrec_.posting_type;
      pub_rec_.c3          := pctrec_.control_type_value;
      pub_rec_.c4          := pctrec_.spec_control_type;
      pub_rec_.c5          := pctrec_.spec_control_type_value;
      pub_rec_.c6          := pctrec_.spec_module;
      pub_rec_.c7          := pctrec_.code_part_value;
      pub_rec_.d1          := pctrec_.valid_from;
      pub_rec_.d2          := pctrec_.pc_valid_from;
      pub_rec_.c8          := pctrec_.no_code_part_value_db;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Detail_Spec___;


PROCEDURE Import_Copy_Detail_Spec___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   stmt_          IN VARCHAR2,
   bind_using_    IN VARCHAR2 ) 
IS
   msg_                VARCHAR2(2000);
   i_                  NUMBER := 0;
   TYPE RecordType     IS REF CURSOR;
   get_data_           RecordType;
   detail_rec_         r_crecomp_pctrl_ds;   

   company_valid_from_     DATE;
BEGIN
   IF (Modify_Company_Data___(module_, lu_, crecomp_rec_, 'DetailSpec') ) THEN
      IF (bind_using_ = 'ImportDetailSpec') THEN
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING module_, 
                                       lu_, 
                                       crecomp_rec_.template_id,
                                       crecomp_rec_.version,
                                       UPPER(module_||'PostingCtrlDetail'),
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       UPPER(module_||'PostingCtrl'),
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;

      ELSIF (bind_using_ = 'CopyDetailSpec') THEN
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING crecomp_rec_.old_company,
                                       module_,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      END IF;

      company_valid_from_ := TRUNC(crecomp_rec_.valid_from);

      FETCH get_data_ INTO detail_rec_;
      WHILE get_data_%FOUND LOOP
         i_ := i_ + 1;

         -- only modify pc_valid_from and valid_from dates if earlier than create company valid from date. 
         IF ( detail_rec_.pc_valid_from < company_valid_from_ ) THEN
            detail_rec_.pc_valid_from := company_valid_from_;
         END IF;

         IF ( detail_rec_.valid_from < company_valid_from_ ) THEN
            detail_rec_.valid_from := company_valid_from_;
         END IF;

         BEGIN            
            Posting_Ctrl_Detail_Spec_API.Insert_Posting_Ctrl_Det_Spec
                                                   (crecomp_rec_.company,
                                                    detail_rec_.posting_type,
                                                    detail_rec_.code_part,
                                                    detail_rec_.pc_valid_from,
                                                    detail_rec_.control_type_value,
                                                    detail_rec_.valid_from,
                                                    detail_rec_.spec_control_type_value,
                                                    detail_rec_.spec_control_type,
                                                    detail_rec_.spec_module,
                                                    detail_rec_.code_part_value,
                                                    detail_rec_.no_code_part_value );
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);                     
         END;
         FETCH get_data_ INTO detail_rec_;
      END LOOP;
      CLOSE get_data_;
      IF (msg_ IS NULL) THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
      END IF;                     
   ELSE
      -- This statement is to add to the log that the Create company process for the LU is finished
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);            
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');                           
END Import_Copy_Detail_Spec___;   


PROCEDURE Import_Comb_Detail_Spec___ ( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec ) 
IS
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
   'SELECT C1              code_part, '                ||
          'C2              posting_type, '             ||
          'C3              control_type_value, '       ||
          'C4              spec_comb_control_type, '   ||
          'C5              spec_control_type1, '       ||
          'C6              spec_control_type1_value, ' ||
          'C7              spec_module1, '             ||
          'C8              spec_control_type2, '       ||
          'C9              spec_control_type2_value, ' ||
          'C10             spec_module2, '             ||
          'C11             code_part_value, '          ||
          'trunc(D1)       valid_from, '               ||
          'trunc(D2)       pc_valid_from, '            ||
          'C12             no_code_part_value '        ||
   'FROM   Create_Company_Template_Pub s1 '            ||
   'WHERE  component   = :module_ '                    ||
   'AND    lu          = :lu_ '                        ||
   'AND    template_id = :template_id_ '               ||
   'AND    version     = :version_ '                   ||
   'AND    D1 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :detail_lu '             ||
                 'AND s1.C1 = s3.C1 '                         ||
                 'AND s1.C2 = s3.C2 '                         ||
                 'AND s1.C3 = s3.C4 '                         ||
                 'AND s1.D2 = s3.D3 '                         ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '    ||
                             'WHERE s3.template_id = s4.template_id '  ||
                             'AND s3.component = s4.component '        ||
                             'AND s3.lu = s4.lu '                      ||
                             'AND s3.version = s4.version '            ||
                             'AND s3.C1 = s4.C1 '                      ||
                             'AND s3.C2 = s4.C2 '                      ||
                             'AND s3.C4 = s4.C4 '                      ||
                             'AND s3.D3 = s4.D3 '                      ||
                             'AND s4.D1 <= :cre_valid_from)) '         ||
                 'AND    s3.D3 IN (SELECT s5.D1 '                      ||
                               'FROM Create_Company_Template_Pub s5 '  ||
                               'WHERE s3.template_id = s5.template_id '||
                               'AND s3.component = s5.component '      ||
                               'AND UPPER(s5.LU) = :master_lu '        ||
                               'AND s3.C1 = s5.C1 '                    ||
                               'AND s3.C2 = s5.C2 '                    ||
                               'AND (s5.D1 > :cre_valid_from '         ||
                               'OR s5.D1 = (SELECT MAX(s6.D1) '                     ||
                                           'FROM Create_Company_Template_Pub s6 '   ||
                                           'WHERE s5.template_id = s6.template_id ' ||
                                           'AND s5.component = s6.component '       ||
                                           'AND s5.lu = s6.lu '                     ||
                                           'AND s5.C1 = s6.C1 '                     ||
                                           'AND s5.C2 = s6.C2 '                     ||
                                           'AND s6.D1 <= :cre_valid_from)))) '      ||
   'ORDER BY D2, D1 ' ;
   --
   Import_Copy_Comb_Det_Spec___( module_, lu_, pkg_, crecomp_rec_, stmt_, 'ImportCombDetailSpec' );
END Import_Comb_Detail_Spec___;   


PROCEDURE Copy_Comb_Detail_Spec___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )      
IS 
   stmt_   VARCHAR2(4000); 
BEGIN
   stmt_  :=   
   'SELECT code_part                code_part, '                 ||
          'posting_type             posting_type, '              ||
          'control_type_value       control_type_value, '        ||
          'spec_comb_control_type   spec_comb_control_type, '    ||
          'spec_control_type1       spec_control_type1, '        ||
          'spec_control_type1_value spec_control_type1_value, '  ||
          'spec_module1             spec_module1, '              ||
          'spec_control_type2       spec_control_type2, '        || 
          'spec_control_type2_value spec_control_type2_value, '  ||
          'spec_module2             spec_module2, '              ||
          'code_part_value          code_part_value, '           ||
          'trunc(valid_from)        valid_from, '                ||
          'trunc(pc_valid_from)     pc_valid_from, '             ||
          'no_code_part_value_db    no_code_part_value '         ||
    'FROM   POSTING_CTRL_COMB_DET_SPEC_PUB s1 '                                  ||
    'WHERE  company  = :old_company '                            ||
    'AND    component= :module_ '                                ||
    'AND    valid_from IN (SELECT s3.valid_from '                          ||
                 'FROM POSTING_CTRL_DETAIL_PUB s3 '                                   ||
                 'WHERE s1.company = s3.company '                          ||
                 'AND s1.component = s3.component '                        ||
                 'AND s1.code_part = s3.code_part '                        ||
                 'AND s1.posting_type = s3.posting_type '                  ||
                 'AND s1.control_type_value = s3.control_type_value '      ||
                 'AND s1.pc_valid_from = s3.pc_valid_from '                ||
                 'AND (s3.valid_from > :cre_valid_from '                   ||
                 'OR s3.valid_from = (SELECT MAX(s4.valid_from) '                ||
                             'FROM POSTING_CTRL_DETAIL_PUB s4 '                             ||
                             'WHERE s3.company = s4.company '                    ||
                             'AND s3.component = s4.component '                  ||
                             'AND s3.code_part = s4.code_part '                  ||
                             'AND s3.posting_type = s4.posting_type '            ||
                             'AND s3.control_type_value = s4.control_type_value '||
                             'AND s3.pc_valid_from = s4.pc_valid_from '          ||
                             'AND s4.valid_from <= :cre_valid_from)) '           ||
                 'AND    s3.pc_valid_from IN (SELECT s5.pc_valid_from '          ||
                               'FROM POSTING_CTRL_PUB s5 '                                  ||
                               'WHERE s3.company = s5.company '                  ||
                               'AND s3.component = s5.component '                ||
                               'AND s3.code_part = s5.code_part '                ||
                               'AND s3.posting_type = s5.posting_type '          ||
                               'AND (s5.pc_valid_from > :cre_valid_from '        ||
                               'OR s5.pc_valid_from = (SELECT MAX(s6.pc_valid_from) '  ||
                                           'FROM POSTING_CTRL_PUB s6 '                            ||
                                           'WHERE s5.company = s6.company '            ||
                                           'AND s5.component = s6.component '          ||
                                           'AND s5.code_part = s6.code_part '          ||
                                           'AND s5.posting_type = s6.posting_type '    ||
                                           'AND s6.pc_valid_from <= :cre_valid_from)))) '||
       'ORDER BY pc_valid_from, valid_from ' ;
   Import_Copy_Comb_Det_Spec___( module_, lu_, pkg_, crecomp_rec_, stmt_ , 'CopyCombDetailSpec');
END Copy_Comb_Detail_Spec___;


PROCEDURE Export_Comb_Detail_Spec___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec )  
IS 
   pub_rec_        Enterp_Comp_Connect_V170_API.Tem_Public_Rec;   
   i_              NUMBER := 1;
   CURSOR get_data IS
      SELECT *
      FROM   POSTING_CTRL_CDET_SPEC_GEN_PCT
      WHERE  company = crecomp_rec_.company
      AND    component = module_;
BEGIN
   FOR pctrec_ IN get_data LOOP
      pub_rec_.template_id := crecomp_rec_.template_id;
      pub_rec_.component   := module_;
      pub_rec_.version     := crecomp_rec_.version;
      pub_rec_.lu          := lu_;
      pub_rec_.item_id     := i_;     
      pub_rec_.c1          := pctrec_.code_part;
      pub_rec_.c2          := pctrec_.posting_type;
      pub_rec_.c3          := pctrec_.control_type_value;
      pub_rec_.c4          := pctrec_.spec_comb_control_type;
      pub_rec_.c5          := pctrec_.spec_control_type1;
      pub_rec_.c6          := pctrec_.spec_control_type1_value;
      pub_rec_.c7          := pctrec_.spec_module1;
      pub_rec_.c8          := pctrec_.spec_control_type2;
      pub_rec_.c9          := pctrec_.spec_control_type2_value;
      pub_rec_.c10         := pctrec_.spec_module2;
      pub_rec_.c11         := pctrec_.code_part_value;     
      pub_rec_.d1          := pctrec_.valid_from;
      pub_rec_.d2          := pctrec_.pc_valid_from;
      pub_rec_.c12         := pctrec_.no_code_part_value_db;
      Enterp_Comp_Connect_V170_API.Tem_Insert_Detail_Data(pub_rec_);      
      i_ := i_ + 1;
   END LOOP;
END Export_Comb_Detail_Spec___;


PROCEDURE Import_Copy_Comb_Det_Spec___ (
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   pkg_           IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   stmt_          IN VARCHAR2,
   bind_using_    IN VARCHAR2 ) 
IS
   msg_                VARCHAR2(2000);
   i_                  NUMBER := 0;
   TYPE RecordType     IS REF CURSOR;
   get_data_           RecordType;
   detail_rec_         r_crecomp_pctrl_cds;   

   company_valid_from_  DATE;
BEGIN
   IF (Modify_Company_Data___(module_, lu_, crecomp_rec_, 'CombDetailSpec') ) THEN
      IF (bind_using_ = 'ImportCombDetailSpec') THEN
         @ApproveDynamicStatement(2006-01-27,jeguse)
         OPEN get_data_ FOR stmt_ USING module_, 
                                       lu_, 
                                       crecomp_rec_.template_id,
                                       crecomp_rec_.version,
                                       UPPER(module_||'PostingCtrlDetail'),
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       UPPER(module_||'PostingCtrl'),
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      ELSIF (bind_using_ = 'CopyCombDetailSpec') THEN
         @ApproveDynamicStatement(2006-02-15,ovjose)
         OPEN get_data_ FOR stmt_ USING crecomp_rec_.old_company,
                                       module_,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from,
                                       crecomp_rec_.valid_from;
      END IF;

      company_valid_from_ := TRUNC(crecomp_rec_.valid_from);

      FETCH get_data_ INTO detail_rec_;
      WHILE get_data_%FOUND LOOP
         i_ := i_ + 1;

         -- only modify pc_valid_from and valid_from dates if earlier than create company valid from date. 
         IF ( detail_rec_.pc_valid_from < company_valid_from_ ) THEN
            detail_rec_.pc_valid_from := company_valid_from_;
         END IF;

         IF ( detail_rec_.valid_from < company_valid_from_ ) THEN
            detail_rec_.valid_from := company_valid_from_;
         END IF;

         BEGIN            
            Posting_Ctrl_Comb_Det_Spec_API.Insert_Post_Ctrl_Comb_Det_Spec(crecomp_rec_.company,
                                                                          detail_rec_.posting_type,
                                                                          detail_rec_.code_part,
                                                                          detail_rec_.pc_valid_from,
                                                                          --new_pc_valid_from_,
                                                                          detail_rec_.control_type_value,
                                                                          detail_rec_.valid_from,
                                                                          --new_valid_from_,
                                                                          detail_rec_.spec_comb_control_type,
                                                                          detail_rec_.spec_control_type1,
                                                                          detail_rec_.spec_control_type1_value,
                                                                          detail_rec_.spec_module1,
                                                                          detail_rec_.spec_control_type2,
                                                                          detail_rec_.spec_control_type2_value,
                                                                          detail_rec_.spec_module2,
                                                                          detail_rec_.code_part_value,
                                                                          detail_rec_.no_code_part_value );
         EXCEPTION
            WHEN OTHERS THEN
               msg_ := SQLERRM;
               Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);                     
         END;
         FETCH get_data_ INTO detail_rec_;
      END LOOP;
      CLOSE get_data_;
      IF (msg_ IS NULL) THEN
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
      ELSE
         Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');
      END IF;                     
   ELSE
      -- This statement is to add to the log that the Create company process for the LU is finished
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedSuccessfully');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      msg_ := SQLERRM;
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'Error', msg_);            
      Enterp_Comp_Connect_V170_API.Log_Logging(crecomp_rec_.company, module_, pkg_, 'CreatedWithErrors');                           
END Import_Copy_Comb_Det_Spec___;   


PROCEDURE Modify_Key_Date_Others___( 
   module_        IN VARCHAR2,
   lu_            IN VARCHAR2,
   crecomp_rec_   IN Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec,
   attr_          IN VARCHAR2,
   identifier_    IN VARCHAR2 )
IS
   template_rec_        Create_Company_Tem_API.Public_Rec_Templ;

   TYPE RecordType      IS REF CURSOR;
   get_data_            RecordType;
   i_                   NUMBER := 0;

   stmt_tot_            VARCHAR2(4000);
   stmt_select_         VARCHAR2(200);
   stmt_order_by_       VARCHAR2(50);
   stmt_comb_detail_    VARCHAR2(2000);
   stmt_comb_det_spec_  VARCHAR2(2000);
   stmt_detail_spec_    VARCHAR2(2000);
BEGIN

   stmt_select_ :=
   'SELECT * '                                        ||
   'FROM   Create_Company_Template_Pub s1 '           ||
   'WHERE  component   = :module '                    ||
   'AND    lu          = :lu '                        ||
   'AND    template_id = :template_id ';

   stmt_order_by_ := 
   'ORDER BY D2, D1 '  ||
   'FOR UPDATE NOWAIT ';

   stmt_comb_detail_ := 
   'AND    (D1 > :cre_valid_from '                     ||
           'OR D1 = (SELECT MAX(s2.D1) '               ||
           'FROM Create_Company_Template_Pub s2 '      ||
           'WHERE s1.template_id = s2.template_id '    ||
           'AND s1.component = s2.component '          ||
           'AND s1.lu = s2.lu '                        ||
           'AND s1.version = s2.version '              ||
           'AND s1.C1 = s2.C1 '                        ||
           'AND s1.C2 = s2.C2 '                        ||
           'AND s1.C3 = s2.C3 '                        ||
           'AND s1.C4 = s2.C4 '                        ||
           'AND s1.C5 = s2.C5 '                        ||
           'AND s1.C6 = s2.C6 '                        ||
           'AND s1.C10 = s2.C10 '                      ||
           'AND s1.D2 = s2.D2 '                        ||
           'AND D1 <= :cre_valid_from)) '              ||
   'AND    D2 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :master_lu '             ||
                 'AND s1.C1 = s3.C2 '                         ||
                 'AND s1.C10 = s3.C1 '                        ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '     ||
                             'WHERE s3.template_id = s4.template_id '   ||
                             'AND s3.component = s4.component '         ||
                             'AND s3.lu = s4.lu '                       ||
                             'AND s3.C1 = s4.C1 '                       ||
                             'AND s3.C2 = s4.C2 '                      ||
                             'AND s4.D1 <= :cre_valid_from))) ';

   stmt_comb_det_spec_ :=
   'AND    D1 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :detail_lu '             ||
                 'AND s1.C1 = s3.C1 '                         ||
                 'AND s1.C2 = s3.C2 '                         ||
                 'AND s1.C3 = s3.C4 '                         ||
                 'AND s1.D2 = s3.D3 '                         ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '    ||
                             'WHERE s3.template_id = s4.template_id '  ||
                             'AND s3.component = s4.component '        ||
                             'AND s3.lu = s4.lu '                      ||
                             'AND s3.version = s4.version '            ||
                             'AND s3.C1 = s4.C1 '                      ||
                             'AND s3.C2 = s4.C2 '                      ||
                             'AND s3.C4 = s4.C4 '                      ||
                             'AND s3.D3 = s4.D3 '                      ||
                             'AND s4.D1 <= :cre_valid_from)) '         ||
                 'AND    s3.D3 IN (SELECT s5.D1 '                      ||
                               'FROM Create_Company_Template_Pub s5 '  ||
                               'WHERE s3.template_id = s5.template_id '||
                               'AND s3.component = s5.component '      ||
                               'AND UPPER(s5.LU) = :master_lu '        ||
                               'AND s3.C1 = s5.C1 '                    ||
                               'AND s3.C2 = s5.C2 '                    ||
                               'AND (s5.D1 > :cre_valid_from '         ||
                               'OR s5.D1 = (SELECT MAX(s6.D1) '                     ||
                                           'FROM Create_Company_Template_Pub s6 '   ||
                                           'WHERE s5.template_id = s6.template_id ' ||
                                           'AND s5.component = s6.component '       ||
                                           'AND s5.lu = s6.lu '                     ||
                                           'AND s5.C1 = s6.C1 '                     ||
                                           'AND s5.C2 = s6.C2 '                     ||
                                           'AND s6.D1 <= :cre_valid_from)))) ';

   stmt_detail_spec_ := 
   'AND    D1 IN (SELECT s3.D1 '                              ||
                 'FROM Create_Company_Template_Pub s3 '       ||
                 'WHERE s1.template_id = s3.template_id '     ||
                 'AND s1.component = s3.component '           ||
                 'AND UPPER(s3.LU) = :detail_lu '             ||
                 'AND s1.C1 = s3.C1 '                         ||
                 'AND s1.C2 = s3.C2 '                         ||
                 'AND s1.C3 = s3.C4 '                         ||
                 'AND s1.D2 = s3.D3 '                         ||
                 'AND (s3.D1 > :cre_valid_from '              ||
                 'OR s3.D1 = (SELECT MAX(s4.D1) '             ||
                             'FROM Create_Company_Template_Pub s4 '    ||
                             'WHERE s3.template_id = s4.template_id '  ||
                             'AND s3.component = s4.component '        ||
                             'AND s3.lu = s4.lu '                      ||
                             'AND s3.version = s4.version '            ||
                             'AND s3.C1 = s4.C1 '                      ||
                             'AND s3.C2 = s4.C2 '                      ||
                             'AND s3.C4 = s4.C4 '                      ||
                             'AND s3.D3 = s4.D3 '                      ||
                             'AND s4.D1 <= :cre_valid_from)) '         ||
                 'AND    s3.D3 IN (SELECT s5.D1 '                      ||
                               'FROM Create_Company_Template_Pub s5 '  ||
                               'WHERE s3.template_id = s5.template_id '||
                               'AND s3.component = s5.component '      ||
                               'AND UPPER(s5.LU) = :master_lu '        ||
                               'AND s3.C1 = s5.C1 '                    ||
                               'AND s3.C2 = s5.C2 '                    ||
                               'AND (s5.D1 > :cre_valid_from '         ||
                               'OR s5.D1 = (SELECT MAX(s6.D1) '                     ||
                                           'FROM Create_Company_Template_Pub s6 '   ||
                                           'WHERE s5.template_id = s6.template_id ' ||
                                           'AND s5.component = s6.component '       ||
                                           'AND s5.lu = s6.lu '                     ||
                                           'AND s5.C1 = s6.C1 '                     ||
                                           'AND s5.C2 = s6.C2 '                     ||
                                           'AND s6.D1 <= :cre_valid_from)))) ';


   IF (identifier_ = 'DetailSpec') THEN
      stmt_tot_ := stmt_select_ || stmt_detail_spec_ || stmt_order_by_;
      @ApproveDynamicStatement(2007-08-10,shwilk)
      OPEN get_data_ FOR stmt_tot_ USING module_,
                                        lu_,
                                        crecomp_rec_.template_id,
                                        UPPER(module_ || 'PostingCtrlDetail'),
                                        crecomp_rec_.valid_from,
                                        crecomp_rec_.valid_from,
                                        UPPER(module_ || 'PostingCtrl'),
                                        crecomp_rec_.valid_from,
                                        crecomp_rec_.valid_from;

   ELSIF (identifier_ = 'CombDetail') THEN
      stmt_tot_ := stmt_select_ || stmt_comb_detail_ || stmt_order_by_;
      @ApproveDynamicStatement(2007-08-10,shwilk)
      OPEN get_data_ FOR stmt_tot_ USING module_,
                                        lu_,
                                        crecomp_rec_.template_id,
                                        crecomp_rec_.valid_from,
                                        crecomp_rec_.valid_from,
                                        UPPER(module_ || 'PostingCtrl'),
                                        crecomp_rec_.valid_from,
                                        crecomp_rec_.valid_from;
   ELSIF (identifier_ = 'CombDetailSpec') THEN
      stmt_tot_ := stmt_select_ || stmt_comb_det_spec_ || stmt_order_by_;
      @ApproveDynamicStatement(2007-08-10,shwilk)
      OPEN get_data_ FOR stmt_tot_ USING module_,
                                        lu_,
                                        crecomp_rec_.template_id,
                                        UPPER(module_ || 'PostingCtrlDetail'),
                                        crecomp_rec_.valid_from,
                                        crecomp_rec_.valid_from,
                                        UPPER(module_ || 'PostingCtrl'),
                                        crecomp_rec_.valid_from,
                                        crecomp_rec_.valid_from;
   ELSE
      RETURN;
   END IF;

   FETCH get_data_ INTO template_rec_;
   WHILE get_data_%FOUND LOOP
      i_ := i_ + 1;

      -- only modify d1(pc_valid_from) and d2(valid_from) dates if earlier than create company valid from date. 
      IF (template_rec_.d1 < crecomp_rec_.valid_from) THEN
         template_rec_.d1 := crecomp_rec_.valid_from;
      END IF;

      IF ( template_rec_.d2 < crecomp_rec_.valid_from ) THEN
         template_rec_.d2 := crecomp_rec_.valid_from;
      END IF;

      Enterp_Comp_Connect_V170_API.Update_Diff_Template( template_rec_ );
      FETCH get_data_ INTO template_rec_;
   END LOOP;
   CLOSE get_data_;
END Modify_Key_Date_Others___;


PROCEDURE Upd_Diff_Templ_Pctrl_Gen___(
   template_rec_        IN Create_Company_Tem_API.Public_Rec_Templ,
   lu_                  IN VARCHAR2,
   pc_valid_from_date_  IN DATE,
   valid_from_date_     IN DATE)
IS
   change_templ_rec_    Create_Company_Tem_API.Public_Rec_Templ;

   TYPE RecordType      IS REF CURSOR;
   get_data_            RecordType;
   i_                   NUMBER := 0;
   stmt_                VARCHAR2(4000);
   stmt2_               VARCHAR2(2000);
   stmt3_               VARCHAR2(20);
   next_lu_             VARCHAR2(30);
   upper_lu_            VARCHAR2(40);
BEGIN
   upper_lu_ := UPPER(template_rec_.component || lu_);

   stmt_ := 'SELECT * '||
            'FROM Create_Company_Template_Pub s1 '||
            'WHERE template_id = :template_id '||
            'AND   component   = :component '||
            'AND   UPPER(lu)   = :upper_lu ';

   stmt3_ := ' FOR UPDATE NOWAIT ';

   IF (lu_ = 'PostingCtrlDetail') THEN
      stmt2_ := 'AND   c1          = :c1 '||
                'AND   c2          = :c2 '||
                'AND   d3          = :d1 ';

      stmt_ := stmt_ || stmt2_ ||stmt3_;
      @ApproveDynamicStatement(2010-08-20,ovjose)
      OPEN get_data_ FOR stmt_ USING template_rec_.template_id,
                                    template_rec_.component,
                                    upper_lu_,
                                    template_rec_.c1,
                                    template_rec_.c2,
                                    template_rec_.d1;

   ELSIF (lu_ = 'PostingCtrlDetSpec') THEN
      stmt2_ := 'AND   c1          = :c1 '||
                'AND   c2          = :c2 '||
                'AND   c3          = :c4 '||
                'AND   d2          = :d3 ';

      stmt_ := stmt_ || stmt2_ ||stmt3_;
      @ApproveDynamicStatement(2010-08-20,ovjose)
      OPEN get_data_ FOR stmt_ USING template_rec_.template_id,
                                    template_rec_.component,
                                    upper_lu_,
                                    template_rec_.c1,
                                    template_rec_.c2,
                                    template_rec_.c4,
                                    template_rec_.d3;

   ELSIF (lu_ = 'PostingCtrlCombDet') THEN
      stmt2_ := 'AND   c1          = :c2 '||
                'AND   c10         = :c1 '||
                'AND   d2          = :d1 ';

      stmt_ := stmt_ || stmt2_ ||stmt3_;
      @ApproveDynamicStatement(2010-08-20,ovjose)
      OPEN get_data_ FOR stmt_ USING template_rec_.template_id,
                                    template_rec_.component,
                                    upper_lu_,
                                    template_rec_.c2,
                                    template_rec_.c1,
                                    template_rec_.d1;

   ELSIF (lu_ = 'PostingCtrlCDetSpec') THEN
      stmt2_ := 'AND   c1          = :c1 '||
                'AND   c2          = :c2 '||
                'AND   c3          = :c4 '||
                'AND   d2          = :d3 ';

      stmt_ := stmt_ || stmt2_ ||stmt3_;
      @ApproveDynamicStatement(2010-08-20,ovjose)
      OPEN get_data_ FOR stmt_ USING template_rec_.template_id,
                                    template_rec_.component,
                                    upper_lu_,
                                    template_rec_.c1,
                                    template_rec_.c2,
                                    template_rec_.c4,
                                    template_rec_.d3;
   ELSE
      RETURN;
   END IF;

   IF (stmt2_ IS NOT NULL) THEN
      FETCH get_data_ INTO change_templ_rec_;
      WHILE get_data_%FOUND LOOP
         i_ := i_ + 1;

         IF (lu_ = 'PostingCtrlDetail') THEN
            NULL;
            --  both 'PostingCtrlDetSpec' AND 'PostingCtrlCDetSpec' will be called
            --  even though just one is set at this point.
            next_lu_ := 'PostingCtrlDetSpec';
         ELSIF (lu_ = 'PostingCtrlDetSpec') THEN
            next_lu_ := NULL;
         ELSIF (lu_ = 'PostingCtrlCombDet') THEN
            next_lu_ := 'PostingCtrlCDetSpec';
         ELSIF (lu_ = 'PostingCtrlCDetSpec') THEN
            next_lu_ := NULL;
         END IF;
         IF (next_lu_ IS NOT NULL) THEN
            IF (lu_ = 'PostingCtrlDetail') THEN
               next_lu_ := 'PostingCtrlDetSpec';
               Upd_Diff_Templ_Pctrl_Gen___(change_templ_rec_,
                                           next_lu_,
                                           pc_valid_from_date_,
                                           valid_from_date_);

               next_lu_ := 'PostingCtrlCDetSpec';
               Upd_Diff_Templ_Pctrl_Gen___(change_templ_rec_,
                                           next_lu_,
                                           pc_valid_from_date_,
                                           valid_from_date_);
            ELSE
               Upd_Diff_Templ_Pctrl_Gen___(change_templ_rec_,
                                           next_lu_,
                                           pc_valid_from_date_,
                                           valid_from_date_);

            END IF;
         END IF;

         IF (lu_ = 'PostingCtrlDetail') THEN
            next_lu_ := 'PostingCtrlDetSpec';
            change_templ_rec_.d3 := NVL(pc_valid_from_date_, change_templ_rec_.d3);
            change_templ_rec_.d1 := NVL(valid_from_date_, change_templ_rec_.d1);
         ELSIF (lu_ = 'PostingCtrlDetSpec') THEN
            next_lu_ := NULL;
            change_templ_rec_.d2 := NVL(pc_valid_from_date_, change_templ_rec_.d2);
            change_templ_rec_.d1 := NVL(valid_from_date_, change_templ_rec_.d1);
         ELSIF (lu_ = 'PostingCtrlCombDet') THEN
            next_lu_ := 'PostingCtrlCDetSpec';
            change_templ_rec_.d2 := NVL(pc_valid_from_date_, change_templ_rec_.d2);
            change_templ_rec_.d1 := NVL(valid_from_date_, change_templ_rec_.d1);
         ELSIF (lu_ = 'PostingCtrlCDetSpec') THEN
            next_lu_ := NULL;
            change_templ_rec_.d2 := NVL(pc_valid_from_date_, change_templ_rec_.d2);
            change_templ_rec_.d1 := NVL(valid_from_date_, change_templ_rec_.d1);
         END IF;
   
         Enterp_Comp_Connect_V170_API.Update_Diff_Template( change_templ_rec_ );
         FETCH get_data_ INTO change_templ_rec_;
      END LOOP;
      CLOSE get_data_;
   END IF;
END Upd_Diff_Templ_Pctrl_Gen___;

PROCEDURE Insert_Map_Head___(
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
   clmapprec_  Client_Mapping_API.Client_Mapping_Pub;
BEGIN
   clmapprec_.module        := posting_ctrl_module_;
   clmapprec_.lu            := posting_ctrl_lu_;
   clmapprec_.mapping_id    := 'CCD_'||UPPER(posting_ctrl_lu_); -- assume naming-convention
   clmapprec_.client_window := client_window_;   
   clmapprec_.rowversion    := SYSDATE;
   Client_Mapping_API.Insert_Mapping(clmapprec_);
END Insert_Map_Head___;

PROCEDURE Insert_Map_Detail___(         
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,   
   column_id_           IN VARCHAR2,                               
   translation_link_    IN VARCHAR2 )
IS                               
   clmappdetrec_  Client_Mapping_API.Client_Mapping_Detail_Pub;                            
BEGIN
   clmappdetrec_.module := posting_ctrl_module_;
   clmappdetrec_.lu := posting_ctrl_lu_;
   clmappdetrec_.mapping_id := 'CCD_'||UPPER(posting_ctrl_lu_);  -- assume naming-convention
   clmappdetrec_.column_id := column_id_ ;
   clmappdetrec_.column_type := 'NORMAL';
   clmappdetrec_.translation_link := translation_link_;
   clmappdetrec_.translation_type := 'SRDPATH';
   clmappdetrec_.rowversion := SYSDATE;   
   Client_Mapping_API.Insert_Mapping_Detail(clmappdetrec_);
END Insert_Map_Detail___;      


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
PROCEDURE Client_Map_Master_Gen__ (
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS   
     
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(posting_ctrl_module_,
                      posting_ctrl_lu_,
                      client_window_);
   
   -- Insert Map Detail      
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C1', 'POSTING_CTRL_GEN_PCT.CODE_PART');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C2', 'POSTING_CTRL_GEN_PCT.POSTING_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C3', 'POSTING_CTRL_GEN_PCT.CONTROL_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C4', 'POSTING_CTRL_GEN_PCT.MODULE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C5', 'POSTING_CTRL_GEN_PCT.OVERRIDE_DB');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C6', 'POSTING_CTRL_GEN_PCT.DEFAULT_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C7', 'POSTING_CTRL_GEN_PCT.DEFAULT_VALUE_NO_CT');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D1', 'POSTING_CTRL_GEN_PCT.PC_VALID_FROM');
END Client_Map_Master_Gen__;

PROCEDURE Client_Map_Detail_Gen__ (
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS   
    
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(posting_ctrl_module_,
                      posting_ctrl_lu_,
                      client_window_);
   
   -- Insert Map Detail
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C1', 'POSTING_CTRL_DETAIL_GEN_PCT.CODE_PART');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C2', 'POSTING_CTRL_DETAIL_GEN_PCT.POSTING_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C3', 'POSTING_CTRL_DETAIL_GEN_PCT.CODE_PART_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C4', 'POSTING_CTRL_DETAIL_GEN_PCT.CONTROL_TYPE_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C5', 'POSTING_CTRL_DETAIL_GEN_PCT.CONTROL_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C6', 'POSTING_CTRL_DETAIL_GEN_PCT.MODULE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C7', 'POSTING_CTRL_DETAIL_GEN_PCT.SPEC_CONTROL_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C8', 'POSTING_CTRL_DETAIL_GEN_PCT.SPEC_MODULE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C9', 'POSTING_CTRL_DETAIL_GEN_PCT.SPEC_DEFAULT_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C10','POSTING_CTRL_DETAIL_GEN_PCT.SPEC_DEFAULT_VALUE_NO_CT');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D1', 'POSTING_CTRL_DETAIL_GEN_PCT.VALID_FROM');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D3', 'POSTING_CTRL_DETAIL_GEN_PCT.PC_VALID_FROM');

END Client_Map_Detail_Gen__;

PROCEDURE Client_Map_Detail_Spec_Gen__ (
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS
     
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(posting_ctrl_module_,
                      posting_ctrl_lu_,
                      client_window_);
   
   -- Insert Map Detail
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C1', 'POSTING_CTRL_DET_SPEC_GEN_PCT.CODE_PART');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C2', 'POSTING_CTRL_DET_SPEC_GEN_PCT.POSTING_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C3', 'POSTING_CTRL_DET_SPEC_GEN_PCT.CONTROL_TYPE_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C4', 'POSTING_CTRL_DET_SPEC_GEN_PCT.SPEC_CONTROL_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C5', 'POSTING_CTRL_DET_SPEC_GEN_PCT.SPEC_CONTROL_TYPE_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C6', 'POSTING_CTRL_DET_SPEC_GEN_PCT.SPEC_MODULE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C7', 'POSTING_CTRL_DET_SPEC_GEN_PCT.CODE_PART_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D1', 'POSTING_CTRL_DET_SPEC_GEN_PCT.VALID_FROM');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D2', 'POSTING_CTRL_DET_SPEC_GEN_PCT.PC_VALID_FROM');
END Client_Map_Detail_Spec_Gen__;

PROCEDURE Client_Map_Comb_Detail_Gen__ (
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS   
      
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(posting_ctrl_module_,
                      posting_ctrl_lu_,
                      client_window_);
   
   -- Insert Map Detail
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C1', 'POSTING_CTRL_COMB_DET_GEN_PCT.POSTING_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C2', 'POSTING_CTRL_COMB_DET_GEN_PCT.COMB_CONTROL_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C3', 'POSTING_CTRL_COMB_DET_GEN_PCT.CONTROL_TYPE1');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C4', 'POSTING_CTRL_COMB_DET_GEN_PCT.CONTROL_TYPE1_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C5', 'POSTING_CTRL_COMB_DET_GEN_PCT.CONTROL_TYPE2');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C6', 'POSTING_CTRL_COMB_DET_GEN_PCT.CONTROL_TYPE2_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C7', 'POSTING_CTRL_COMB_DET_GEN_PCT.COMB_MODULE');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C8', 'POSTING_CTRL_COMB_DET_GEN_PCT.MODULE1');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C9', 'POSTING_CTRL_COMB_DET_GEN_PCT.MODULE2');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C10','POSTING_CTRL_COMB_DET_GEN_PCT.CODE_PART');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'C11','POSTING_CTRL_COMB_DET_GEN_PCT.CODE_PART_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'D1', 'POSTING_CTRL_COMB_DET_GEN_PCT.VALID_FROM');
   Insert_Map_Detail___(posting_ctrl_module_, posting_ctrl_lu_,'D2', 'POSTING_CTRL_COMB_DET_GEN_PCT.PC_VALID_FROM');
END Client_Map_Comb_Detail_Gen__;

PROCEDURE Client_Map_Comb_Det_Spec_Gen__ (
   posting_ctrl_module_ IN VARCHAR2,
   posting_ctrl_lu_     IN VARCHAR2,
   client_window_       IN VARCHAR2 DEFAULT 'frmCreateCompanyTemDetail' )
IS   
      
BEGIN         
   -- Insert Map Head   
   Insert_Map_Head___(posting_ctrl_module_,
                      posting_ctrl_lu_,
                      client_window_);
   
   -- Insert Map Detail
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C1', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.CODE_PART');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C2', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.POSTING_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C3', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.CONTROL_TYPE_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C4', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_COMB_CONTROL_TYPE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C5', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_CONTROL_TYPE1');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C6', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_CONTROL_TYPE1_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C7', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_MODULE1');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C8', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_CONTROL_TYPE2');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C9', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_CONTROL_TYPE2_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C10','POSTING_CTRL_CDET_SPEC_GEN_PCT.SPEC_MODULE2');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'C11','POSTING_CTRL_CDET_SPEC_GEN_PCT.CODE_PART_VALUE');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D1', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.VALID_FROM');
   Insert_Map_Detail___(posting_ctrl_module_,posting_ctrl_lu_,'D2', 'POSTING_CTRL_CDET_SPEC_GEN_PCT.PC_VALID_FROM');
END Client_Map_Comb_Det_Spec_Gen__;


PROCEDURE Comp_Reg_Master_Gen__ (
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
      'TRUE',
      'CCD_'||UPPER(lu_name_),
      'C1^C2');
   execution_order_ := execution_order_+1;
END Comp_Reg_Master_Gen__;


PROCEDURE Comp_Reg_Detail_Gen__ (
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
      'TRUE',
      'CCD_'||UPPER(lu_name_),
      'C2^C1^C4^D1');
   execution_order_ := execution_order_+1;
END Comp_Reg_Detail_Gen__;


PROCEDURE Comp_Reg_Detail_Spec_Gen__ (
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
      'TRUE',
      'CCD_'||UPPER(lu_name_),
      'C2^C1^D2^C3^D1^C4');
   execution_order_ := execution_order_+1;
END Comp_Reg_Detail_Spec_Gen__;


PROCEDURE Comp_Reg_Comb_Detail_Gen__ (
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
      'TRUE',
      'CCD_'||UPPER(lu_name_),
      'C1^D2^C2^C10^C3^C4^C5^C6^D1');
   execution_order_ := execution_order_+1;
END Comp_Reg_Comb_Detail_Gen__;


PROCEDURE Comp_Reg_Comb_Det_Spec_Gen__ (
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
      'TRUE',
      'CCD_'||UPPER(lu_name_),
      'C2^C1^D2^C3^D1^C4^C6^C9');
   execution_order_ := execution_order_+1;
END Comp_Reg_Comb_Det_Spec_Gen__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

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
      Export_Master___(module_, lu_, crecomp_rec_);      
   ELSIF (crecomp_rec_.make_company = 'IMPORT') THEN
      IF (crecomp_rec_.action = 'NEW') THEN
         Import_Master___(module_, lu_, pkg_, crecomp_rec_);         
      ELSIF (crecomp_rec_.action = 'DUPLICATE') THEN 
         Copy_Master___(module_, lu_, pkg_, crecomp_rec_);         
      END IF;      
   ELSIF (crecomp_rec_.make_company = 'MODIFY_KEY_DATE') THEN
      Modify_Key_Date_Master___( module_, lu_, crecomp_rec_ );
   END IF;
END Make_Company_Gen;


PROCEDURE Make_Company_Detail_Gen (
   module_  IN VARCHAR2,
   lu_      IN VARCHAR2,
   pkg_     IN VARCHAR2,
   attr_    IN VARCHAR2 )
IS
   crecomp_rec_     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN
   crecomp_rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec(module_, attr_);
   IF (crecomp_rec_.make_company = 'EXPORT') THEN
      Export_Detail___(module_, lu_, crecomp_rec_);      
   ELSIF (crecomp_rec_.make_company = 'IMPORT') THEN
      IF (crecomp_rec_.action = 'NEW') THEN
         Import_Detail___(module_, lu_, pkg_, crecomp_rec_);         
      ELSIF (crecomp_rec_.action = 'DUPLICATE') THEN 
         Copy_Detail___(module_, lu_, pkg_, crecomp_rec_);         
      END IF;      
   ELSIF (crecomp_rec_.make_company = 'MODIFY_KEY_DATE') THEN
      Modify_Key_Date_Detail___( module_, lu_, crecomp_rec_, attr_);
   END IF;
END Make_Company_Detail_Gen;


PROCEDURE Make_Company_Comb_Detail_Gen (
   module_  IN VARCHAR2,
   lu_      IN VARCHAR2,
   pkg_     IN VARCHAR2,
   attr_    IN VARCHAR2 )
IS
   crecomp_rec_     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN
   crecomp_rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec(module_, attr_);
   IF (crecomp_rec_.make_company = 'EXPORT') THEN
      Export_Comb_Detail___(module_, lu_, crecomp_rec_);      
   ELSIF (crecomp_rec_.make_company = 'IMPORT') THEN
      IF (crecomp_rec_.action = 'NEW') THEN
         Import_Comb_Detail___(module_, lu_, pkg_, crecomp_rec_);         
      ELSIF (crecomp_rec_.action = 'DUPLICATE') THEN 
         Copy_Comb_Detail___(module_, lu_, pkg_, crecomp_rec_);         
      END IF;      
   ELSIF (crecomp_rec_.make_company = 'MODIFY_KEY_DATE') THEN
      Modify_Key_Date_Others___( module_, lu_, crecomp_rec_, attr_, 'CombDetail' );
   END IF;
END Make_Company_Comb_Detail_Gen;


PROCEDURE Make_Company_Detail_Spec_Gen (
   module_  IN VARCHAR2,
   lu_      IN VARCHAR2,
   pkg_     IN VARCHAR2,
   attr_    IN VARCHAR2 )
IS
   crecomp_rec_     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN
   crecomp_rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec(module_, attr_);
   IF (crecomp_rec_.make_company = 'EXPORT') THEN
      Export_Detail_Spec___(module_, lu_, crecomp_rec_);      
   ELSIF (crecomp_rec_.make_company = 'IMPORT') THEN
      IF (crecomp_rec_.action = 'NEW') THEN
         Import_Detail_Spec___(module_, lu_, pkg_, crecomp_rec_);         
      ELSIF (crecomp_rec_.action = 'DUPLICATE') THEN 
         Copy_Detail_Spec___(module_, lu_, pkg_, crecomp_rec_);         
      END IF;      
   ELSIF (crecomp_rec_.make_company = 'MODIFY_KEY_DATE') THEN
      Modify_Key_Date_Others___( module_, lu_, crecomp_rec_, attr_, 'DetailSpec' );
   END IF;
END Make_Company_Detail_Spec_Gen;


PROCEDURE Make_Company_Comb_Det_Spec_Gen (
   module_  IN VARCHAR2,
   lu_      IN VARCHAR2,
   pkg_     IN VARCHAR2,
   attr_    IN VARCHAR2 )
IS
   crecomp_rec_     Enterp_Comp_Connect_V170_API.Crecomp_Lu_Public_Rec;
BEGIN
   crecomp_rec_ := Enterp_Comp_Connect_V170_API.Get_Crecomp_Lu_Rec(module_, attr_);
   IF (crecomp_rec_.make_company = 'EXPORT') THEN
      Export_Comb_Detail_Spec___(module_, lu_, crecomp_rec_);      
   ELSIF (crecomp_rec_.make_company = 'IMPORT') THEN
      IF (crecomp_rec_.action = 'NEW') THEN
         Import_Comb_Detail_Spec___(module_, lu_, pkg_, crecomp_rec_);         
      ELSIF (crecomp_rec_.action = 'DUPLICATE') THEN 
         Copy_Comb_Detail_Spec___(module_, lu_, pkg_, crecomp_rec_);         
      END IF;      
   ELSIF (crecomp_rec_.make_company = 'MODIFY_KEY_DATE') THEN
      Modify_Key_Date_Others___( module_, lu_, crecomp_rec_, attr_, 'CombDetailSpec' );
   END IF;   
END Make_Company_Comb_Det_Spec_Gen;



