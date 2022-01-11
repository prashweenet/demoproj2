-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileTrans
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021011  PPerse  Merged External Files
--  030805  prdilk  SP4 Merge.
--  040329  Gepelk  2004 SP1 Merge.
--  040906  Camk    FIPR302 - N31 added
--  061016  Kagalk  LCS Merge 57354, Increased length of C12 to VARCHAR2(4000)
--  070123  Gadalk  LCS Merge 60420   
--  071105  RUFELK  Bug 68737 - Added new method Update_File_Load_State().
--  080922  Jeguse  Bug 77126, Taken care of new anonymous columns
--  090605  THPELK   Bug 82609 - Added missing UNDEFINE statements for VIEWH, VIEWD, VIEWE
--  090810  LaPrlk  Bug 79846, Removed the precisions defined for NUMBER type variables.
--  091007  Jeguse  Bug 86411, Added view ext_file_trans_taxno
--  111118  Swralk  SFI-743, Removed General_SYS.Init method from Functions CHECK_EXIST_FILE_TRANS2 and CHECK_EXIST_FILE_TRANS. 
--  130206  SALIDE   EDEL-1995, Added C100..C199.
--  131029  Umdolk PBFI-1332, Corrected model file errors.
--  131120  MEALLK PBFI-2019, Refactored code for the splitting proces
--  140228  MAWELK PBFI-5325 (Lcs Bug Id 115054) fixed
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Modify (
   load_file_id_ IN NUMBER,
   row_no_       IN NUMBER,
   attr_         IN VARCHAR2 )
IS
   info_          VARCHAR2(2000);
   dum_attr_      VARCHAR2(32000);
   objid_         EXT_FILE_TRANS.objid%TYPE;
   objversion_    EXT_FILE_TRANS.objversion%TYPE;
   
   CURSOR get_rec IS
      SELECT objid, objversion
      FROM EXT_FILE_TRANS
      WHERE  load_file_id  = load_file_id_
      AND row_no = row_no_;
BEGIN
   dum_attr_:= attr_;
      
   OPEN get_rec;
   FETCH get_rec INTO objid_, objversion_;
   IF get_rec%NOTFOUND THEN
      CLOSE get_rec;
   ELSE
      CLOSE get_rec;
      Modify__(info_, objid_, objversion_, dum_attr_ , 'DO');
   END IF;
END Modify;


PROCEDURE Modify (
   newrec_     IN OUT EXT_FILE_TRANS_TAB%ROWTYPE )
IS
   attr_          VARCHAR2(32000);
   objid_         EXT_FILE_TRANS.objid%TYPE;
   objversion_    EXT_FILE_TRANS.objversion%TYPE;
BEGIN
   Update___ (objid_, newrec_, newrec_, attr_, objversion_, TRUE);
END Modify;


PROCEDURE Remove_File_Trans(
   load_file_id_    IN NUMBER,
   state_           IN VARCHAR2 DEFAULT NULL)
IS
   statex_             VARCHAR2(1);
BEGIN
   statex_ := NVL(state_,'1');
   DELETE
   FROM  Ext_File_Trans_Tab
   WHERE load_file_id = load_file_id_;
   Ext_File_Load_API.Update_State (load_file_id_,
                                   statex_); 
END Remove_File_Trans;


PROCEDURE Remove_Dec_File_Trans(
   load_file_id_    IN NUMBER)
IS
BEGIN
   DELETE
   FROM  Ext_File_Trans_Tab
   WHERE load_file_id = load_file_id_
   AND   row_no       != TRUNC(row_no);
END Remove_Dec_File_Trans;


PROCEDURE Delete_File_Trans (
   load_file_id_         IN     NUMBER )
IS
BEGIN
   DELETE
   FROM   Ext_File_Trans_Tab
   WHERE  load_file_id = load_file_id_;
END Delete_File_Trans;


PROCEDURE Delete_File_Trans (
   load_file_id_         IN NUMBER,
   row_no_               IN NUMBER )
IS
BEGIN
   DELETE
   FROM   Ext_File_Trans_Tab
   WHERE  load_file_id = load_file_id_
   AND    row_no       = row_no_;
END Delete_File_Trans;


FUNCTION Exist_Not_Loaded_File_Trans (
   load_file_id_ IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       != ROUND(row_no);
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Exist_Not_Loaded_File_Trans;


PROCEDURE Delete_Not_Loaded_File_Trans (
   load_file_id_         IN     NUMBER )
IS
BEGIN
   DELETE
   FROM   Ext_File_Trans_Tab
   WHERE  load_file_id =  load_file_id_
   AND    row_no       != ROUND(row_no);
END Delete_Not_Loaded_File_Trans;


PROCEDURE Set_Unused_File_Trans (
   load_file_id_         IN NUMBER )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET use_line = 'FALSE'
   WHERE  load_file_id = load_file_id_;
END Set_Unused_File_Trans;


PROCEDURE Update_Row_State (
   load_file_id_         IN NUMBER,
   row_no_               IN NUMBER,
   row_state_            IN VARCHAR2,
   error_text_           IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET row_state = row_state_,
          error_text = DECODE(error_text_,NULL,error_text,error_text_)
   WHERE  load_file_id = load_file_id_
   AND    row_no       = row_no_;
END Update_Row_State;


PROCEDURE Update_Row_State (
   load_file_id_         IN NUMBER,
   row_state_            IN VARCHAR2,
   error_text_           IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET row_state = row_state_,
          error_text = DECODE(error_text_,NULL,error_text,error_text_)
   WHERE  load_file_id = load_file_id_;
END Update_Row_State;


PROCEDURE Update_State_Load (
   load_file_id_         IN NUMBER,
   old_row_state_        IN VARCHAR2,
   row_state_            IN VARCHAR2 )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET row_state = row_state_
   WHERE  load_file_id = load_file_id_
   AND    row_state    = old_row_state_;
END Update_State_Load;


PROCEDURE Update_Record_Set_State (
   load_file_id_         IN NUMBER,
   record_set_no_        IN NUMBER,
   row_state_            IN VARCHAR2,
   error_text_           IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET row_state = row_state_,
          error_text = DECODE(error_text_,NULL,error_text,error_text_)
   WHERE  load_file_id  = load_file_id_
   AND    record_set_no = record_set_no_
   AND    row_state     != '3';
END Update_Record_Set_State;


PROCEDURE Update_File_Line (
   load_file_id_         IN NUMBER,
   row_no_               IN NUMBER,
   file_line_            IN VARCHAR2 )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET file_line = file_line_
   WHERE  load_file_id = load_file_id_
   AND    row_no       = row_no_;
END Update_File_Line;


PROCEDURE Update_Columns_Null (
   load_file_id_         IN NUMBER )
IS
BEGIN
   UPDATE Ext_File_Trans_Tab
      SET row_state = '1',
          error_text = NULL,
          c1  = NULL,
          c2  = NULL,
          c3  = NULL,
          c4  = NULL,
          c5  = NULL,
          c6  = NULL,
          c7  = NULL,
          c8  = NULL,
          c9  = NULL,
          c10 = NULL,
          c11 = NULL,
          c12 = NULL,
          c13 = NULL,
          c14 = NULL,
          c15 = NULL,
          c16 = NULL,
          c17 = NULL,
          c18 = NULL,
          c19 = NULL,
          c20 = NULL,
          c21 = NULL,
          c22 = NULL,
          c23 = NULL,
          c24 = NULL,
          c25 = NULL,
          c26 = NULL,
          c27 = NULL,
          c28 = NULL,
          c29 = NULL,
          c30 = NULL,
          c31 = NULL,
          c32 = NULL,
          c33 = NULL,
          c34 = NULL,
          c35 = NULL,
          c36 = NULL,
          c37 = NULL,
          c38 = NULL,
          c39 = NULL,
          c40 = NULL,
          c41 = NULL,
          c42 = NULL,
          c43 = NULL,
          c44 = NULL,
          c45 = NULL,
          c46 = NULL,
          c47 = NULL,
          c48 = NULL,
          c49 = NULL,
          c50 = NULL,
          c51 = NULL,
          c52 = NULL,
          c53 = NULL,
          c54 = NULL,
          c55 = NULL,
          c56 = NULL,
          c57 = NULL,
          c58 = NULL,
          c59 = NULL,
          c60 = NULL,
          c61 = NULL,
          c62 = NULL,
          c63 = NULL,
          c64 = NULL,
          c65 = NULL,
          c66 = NULL,
          c67 = NULL,
          c68 = NULL,
          c69 = NULL,
          c70 = NULL,
          c71 = NULL,
          c72 = NULL,
          c73 = NULL,
          c74 = NULL,
          c75 = NULL,
          c76 = NULL,
          c77 = NULL,
          c78 = NULL,
          c79 = NULL,
          c80 = NULL,
          c81 = NULL,
          c82 = NULL,
          c83 = NULL,
          c84 = NULL,
          c85 = NULL,
          c86 = NULL,
          c87 = NULL,
          c88 = NULL,
          c89 = NULL,
          c90 = NULL,
          c91 = NULL,
          c92 = NULL,
          c93 = NULL,
          c94 = NULL,
          c95 = NULL,
          c96 = NULL,
          c97 = NULL,
          c98 = NULL,
          c99 = NULL,
          c0  = NULL,
          c100 = NULL,
          c101 = NULL,
          c102 = NULL,
          c103 = NULL,
          c104 = NULL,
          c105 = NULL,
          c106 = NULL,
          c107 = NULL,
          c108 = NULL,
          c109 = NULL,
          c110 = NULL,
          c111 = NULL,
          c112 = NULL,
          c113 = NULL,
          c114 = NULL,
          c115 = NULL,
          c116 = NULL,
          c117 = NULL,
          c118 = NULL,
          c119 = NULL,
          c120 = NULL,
          c121 = NULL,
          c122 = NULL,
          c123 = NULL,
          c124 = NULL,
          c125 = NULL,
          c126 = NULL,
          c127 = NULL,
          c128 = NULL,
          c129 = NULL,
          c130 = NULL,
          c131 = NULL,
          c132 = NULL,
          c133 = NULL,
          c134 = NULL,
          c135 = NULL,
          c136 = NULL,
          c137 = NULL,
          c138 = NULL,
          c139 = NULL,
          c140 = NULL,
          c141 = NULL,
          c142 = NULL,
          c143 = NULL,
          c144 = NULL,
          c145 = NULL,
          c146 = NULL,
          c147 = NULL,
          c148 = NULL,
          c149 = NULL,
          c150 = NULL,
          c151 = NULL,
          c152 = NULL,
          c153 = NULL,
          c154 = NULL,
          c155 = NULL,
          c156 = NULL,
          c157 = NULL,
          c158 = NULL,
          c159 = NULL,
          c160 = NULL,
          c161 = NULL,
          c162 = NULL,
          c163 = NULL,
          c164 = NULL,
          c165 = NULL,
          c166 = NULL,
          c167 = NULL,
          c168 = NULL,
          c169 = NULL,
          c170 = NULL,
          c171 = NULL,
          c172 = NULL,
          c173 = NULL,
          c174 = NULL,
          c175 = NULL,
          c176 = NULL,
          c177 = NULL,
          c178 = NULL,
          c179 = NULL,
          c180 = NULL,
          c181 = NULL,
          c182 = NULL,
          c183 = NULL,
          c184 = NULL,
          c185 = NULL,
          c186 = NULL,
          c187 = NULL,
          c188 = NULL,
          c189 = NULL,
          c190 = NULL,
          c191 = NULL,
          c192 = NULL,
          c193 = NULL,
          c194 = NULL,
          c195 = NULL,
          c196 = NULL,
          c197 = NULL,
          c198 = NULL,
          c199 = NULL,
          n1  = NULL,
          n2  = NULL,
          n3  = NULL,
          n4  = NULL,
          n5  = NULL,
          n6  = NULL,
          n7  = NULL,
          n8  = NULL,
          n9  = NULL,
          n10 = NULL,
          n11 = NULL,
          n12 = NULL,
          n13 = NULL,
          n14 = NULL,
          n15 = NULL,
          n16 = NULL,
          n17 = NULL,
          n18 = NULL,
          n19 = NULL,
          n20 = NULL,
          n21 = NULL,
          n22 = NULL,
          n23 = NULL,
          n24 = NULL,
          n25 = NULL,
          n26 = NULL,
          n27 = NULL,
          n28 = NULL,
          n29 = NULL,
          n30 = NULL,
          n31 = NULL,
          n32 = NULL,
          n33 = NULL,
          n34 = NULL,
          n35 = NULL,
          n36 = NULL,
          n37 = NULL,
          n38 = NULL,
          n39 = NULL,
          n40 = NULL,
          n41 = NULL,
          n42 = NULL,
          n43 = NULL,
          n44 = NULL,
          n45 = NULL,
          n46 = NULL,
          n47 = NULL,
          n48 = NULL,
          n49 = NULL,
          n50 = NULL,
          n51 = NULL,
          n52 = NULL,
          n53 = NULL,
          n54 = NULL,
          n55 = NULL,
          n56 = NULL,
          n57 = NULL,
          n58 = NULL,
          n59 = NULL,
          n60 = NULL,
          n61 = NULL,
          n62 = NULL,
          n63 = NULL,
          n64 = NULL,
          n65 = NULL,
          n66 = NULL,
          n67 = NULL,
          n68 = NULL,
          n69 = NULL,
          n70 = NULL,
          n71 = NULL,
          n72 = NULL,
          n73 = NULL,
          n74 = NULL,
          n75 = NULL,
          n76 = NULL,
          n77 = NULL,
          n78 = NULL,
          n79 = NULL,
          n80 = NULL,
          n81 = NULL,
          n82 = NULL,
          n83 = NULL,
          n84 = NULL,
          n85 = NULL,
          n86 = NULL,
          n87 = NULL,
          n88 = NULL,
          n89 = NULL,
          n90 = NULL,
          n91 = NULL,
          n92 = NULL,
          n93 = NULL,
          n94 = NULL,
          n95 = NULL,
          n96 = NULL,
          n97 = NULL,
          n98 = NULL,
          n99 = NULL,
          n0  = NULL,
          parent_row_no  = NULL,
          d1  = NULL,
          d2  = NULL,
          d3  = NULL,
          d4  = NULL,
          d5  = NULL,
          d6  = NULL,
          d7  = NULL,
          d8  = NULL,
          d9  = NULL,
          d10 = NULL,
          d11 = NULL,
          d12 = NULL,
          d13 = NULL,
          d14 = NULL,
          d15 = NULL,
          d16 = NULL,
          d17 = NULL,
          d18 = NULL,
          d19 = NULL,
          d20 = NULL
   WHERE  load_file_id = load_file_id_
   AND    row_state    != '3';
END Update_Columns_Null;


PROCEDURE Insert_File_Trans (
   load_file_id_         IN NUMBER,
   row_no_               IN NUMBER,
   file_line_            IN VARCHAR2,
   row_state_            IN VARCHAR2 DEFAULT '1',
   record_type_id_       IN VARCHAR2 DEFAULT NULL )
IS
   newrec_                  Ext_File_Trans_Tab%ROWTYPE;
BEGIN
   newrec_.Load_File_Id   := load_file_id_;
   newrec_.Row_No         := row_no_;
   newrec_.File_Line      := file_line_;
   newrec_.row_state      := row_state_;
   newrec_.record_type_id := record_type_id_;
   newrec_.Rowversion     := SYSDATE;
   Insert_Record ( newrec_ );
END Insert_File_Trans;


@UncheckedAccess
FUNCTION Get_Max_Row_No (
   load_file_id_ IN NUMBER ) RETURN NUMBER
IS
   row_no_        NUMBER;
   CURSOR Get_Rowno IS
      SELECT MAX(row_no)
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_;
BEGIN
   OPEN  Get_Rowno;
   FETCH Get_Rowno INTO row_no_;
   CLOSE Get_Rowno;
   row_no_ := NVL(row_no_,0) + 1;
   RETURN ( row_no_ );
END Get_Max_Row_No;


@UncheckedAccess
FUNCTION Get_Max_Dec_Row_No (
   load_file_id_ IN NUMBER,
   row_no_       IN NUMBER,
   max_test_     IN NUMBER DEFAULT NULL ) RETURN NUMBER
IS
   max_row_no_      NUMBER;
   max_text_row_no_ NUMBER := NVL(max_test_,0.9);
   CURSOR Get_Rowno IS
      SELECT MAX(row_no)
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       >= row_no_ 
      AND    row_no       < (row_no_ + max_text_row_no_);
BEGIN
   OPEN  Get_Rowno;
   FETCH Get_Rowno INTO max_row_no_;
   CLOSE Get_Rowno;
   max_row_no_ := NVL(max_row_no_,0) + 0.001;
   RETURN ( max_row_no_ );
END Get_Max_Dec_Row_No;


@UncheckedAccess
FUNCTION Get_Next_Rec_Row_No (
   load_file_id_   IN NUMBER,
   row_no_         IN NUMBER,
   record_type_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   max_row_no_      NUMBER;
   CURSOR Get_Next_Rowno IS
      SELECT row_no - 0.001
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       > row_no_ 
      AND    record_type_id = record_type_id_;
   CURSOR Get_Max_Rowno IS
      SELECT MAX(row_no) + 0.900
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_ ;
BEGIN
   OPEN  Get_Next_Rowno;
   FETCH Get_Next_Rowno INTO max_row_no_;
   IF (Get_Next_Rowno%NOTFOUND) THEN
      max_row_no_ := 0;
   END IF;
   CLOSE Get_Next_Rowno;
   IF (max_row_no_ = 0) THEN
      OPEN  Get_Max_Rowno;
      FETCH Get_Max_Rowno INTO max_row_no_;
      CLOSE Get_Max_Rowno;
   END IF;
   RETURN ( max_row_no_ );
END Get_Next_Rec_Row_No;


PROCEDURE Get_Column_Names (
   msg_              OUT VARCHAR2,
   file_template_id_ IN  VARCHAR2,
   record_type_id_   IN  VARCHAR2  )
IS
   detail_msg_     VARCHAR2(30000);
   line_msg_       VARCHAR2(1000);
   i_              PLS_INTEGER := 1;
   CURSOR get_attr IS
      SELECT b.column_id,
             b.description,
             b.destination_column,
             b.record_type_id
      FROM   ext_file_template_detail_tab a,
             ext_file_template_tab        t,
             ext_file_type_rec_column b
      WHERE  a.file_template_id = file_template_id_
      AND    a.record_type_id   = record_type_id_
      AND    NVL(a.hide_column,'FALSE') = 'FALSE'       
      AND    t.file_template_id = a.file_template_id
      AND    b.file_type        = t.file_type
      AND    b.column_id        = a.column_id
      AND    b.record_type_id   = a.record_type_id
      ORDER BY b.destination_column, b.column_id;
BEGIN
   msg_          := Message_SYS.Construct( 'COLUMNNAMES' );
   detail_msg_   := Message_SYS.Construct( 'DETAILS' );
   FOR rec_ IN get_attr LOOP
      Trace_SYS.Message ('rec_.description : '||rec_.description);
      line_msg_ := NULL;
      line_msg_ := Message_SYS.Construct('LINE' );
      Message_SYS.Add_Attribute( line_msg_, 'NAME', rec_.destination_column);
      Message_SYS.Add_Attribute( line_msg_, 'TRANS', rec_.description);
      Message_SYS.Add_Attribute( detail_msg_, to_char(i_) , line_msg_ );
      i_ := i_ + 1;
   END LOOP;
   Message_SYS.Add_Attribute( msg_, to_char(i_) , detail_msg_ );
END Get_Column_Names;


FUNCTION Get_Column_Name (
   file_template_id_   IN VARCHAR2,
   record_type_id_     IN VARCHAR2,
   destination_column_ IN VARCHAR2  )  RETURN VARCHAR2
IS
   column_name_           VARCHAR2(100);
   CURSOR get_attr IS
      SELECT b.description
      FROM   ext_file_template_detail_tab a,
             ext_file_template_tab        t,
             ext_file_type_rec_column b
      WHERE  a.file_template_id = file_template_id_
      AND    a.record_type_id   = record_type_id_
      AND    NVL(a.hide_column,'FALSE') = 'FALSE'       
      AND    t.file_template_id   = a.file_template_id
      AND    b.file_type          = t.file_type
      AND    b.column_id          = a.column_id
      AND    b.record_type_id     = a.record_type_id
      AND    b.destination_column = destination_column_ ;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO column_name_;
   IF (get_attr%NOTFOUND) THEN
      column_name_ := '';
   END IF;
   CLOSE get_attr;
   RETURN column_name_;
END Get_Column_Name;


@UncheckedAccess
FUNCTION Check_Exist_File_Trans (
   load_file_id_ IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE load_file_id = load_file_id_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist_File_Trans;


@UncheckedAccess
FUNCTION Check_Exist_File_Trans (
   load_file_id_ IN NUMBER,
   row_no_       IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_no       = row_no_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist_File_Trans;


@UncheckedAccess
FUNCTION Check_Exist_File_Trans2 (
   load_file_id_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   IF (Check_Exist_File_Trans (load_file_id_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Check_Exist_File_Trans2;


FUNCTION Check_Exist_Control_Id (
   load_file_id_ IN NUMBER ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    control_id   IS NOT NULL;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist_Control_Id;


FUNCTION Check_Exist_Row_State (
   load_file_id_ IN NUMBER,
   row_state_    IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_state    = row_state_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN(TRUE);
   END IF;
   CLOSE exist_control;
   RETURN(FALSE);
END Check_Exist_Row_State;


@UncheckedAccess
FUNCTION Check_Exist_Row_State2 (
   load_file_id_ IN NUMBER,
   row_state_    IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    row_state    = row_state_;
BEGIN
   OPEN exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Exist_Row_State2;


PROCEDURE Insert_Record (
   newrec_     IN Ext_File_Trans_Tab%ROWTYPE ) 
IS
   newrecx_       Ext_File_Trans_Tab%ROWTYPE;
   objid_         VARCHAR2(2000);
   objversion_    VARCHAR2(2000);
   attr_          VARCHAR2(2000);
BEGIN
   newrecx_ := newrec_;
   newrecx_.rowkey := NULL;
   Insert___ ( objid_,
               objversion_,
               newrecx_,
               attr_ );
END Insert_Record;


PROCEDURE Get_Count_Row_State (
   load_file_id_   IN NUMBER,
   seq_no_         IN NUMBER  )
IS
   lattr_             VARCHAR2(3000);
   lobjid_            VARCHAR2(30);
   lobjversion_       VARCHAR2(30);
   linfo_             VARCHAR2(2000);
   CURSOR get_attr IS
      SELECT row_state, count(*) no_of_records
      FROM   ext_file_trans_tab
      WHERE  load_file_id = load_file_id_
      GROUP BY row_state;
BEGIN
   FOR rec_ IN get_attr LOOP
      Client_SYS.Clear_Attr(lattr_);
      Client_SYS.Add_To_Attr('LOAD_FILE_ID', load_file_id_,      lattr_);
      Client_SYS.Add_To_Attr('SEQ_NO',       seq_no_,            lattr_);
      Client_SYS.Add_To_Attr('ROW_STATE_DB', rec_.row_state,     lattr_);
      Client_SYS.Add_To_Attr('NO_OF_RECORDS',rec_.no_of_records, lattr_);
      --
      Ext_File_Log_Detail_API.New__ (linfo_, 
                                     lobjid_, 
                                     lobjversion_, 
                                     lattr_, 
                                     'DO');
   END LOOP;
END Get_Count_Row_State;


PROCEDURE Remove_Ready_Trans (
   info_             IN OUT VARCHAR2,
   load_file_id_     IN     NUMBER,
   parameter_string_ IN     VARCHAR2 DEFAULT NULL ) 
IS
   newrec_                  Ext_File_Trans_Tab%ROWTYPE;
   row_no_                  NUMBER := 0;
   rec_load_file_id_        NUMBER;
   no_of_records_           NUMBER;
   parameter_attr_          VARCHAR2(2000);                
   tmp_                     VARCHAR2(2000)  := NULL;       
   dummy_                   VARCHAR2(10)    := '<DUMMY>';  
   file_type_               VARCHAR2(30)    := '%';        
   file_template_id_        VARCHAR2(30)    := '%';        
   remove_all_states_       VARCHAR2(5)     := 'FALSE';    
   remove_ok_               VARCHAR2(5)     := 'FALSE';    
   CURSOR get_attr IS
      SELECT x.load_file_id,
             x.log_date,
             x.state,
             TRUNC(x.log_date) + d.remove_days remove_date,
             l.file_type,
             l.file_template_id, 
             l.file_direction,
             d.remove_days,
             d.remove_complete
      FROM   ext_file_log x,
             ext_file_load_tab l,
             ext_file_template_dir_tab d
      WHERE  l.load_file_id     = x.load_file_id
      AND    l.load_file_id     != load_file_id_
      AND    l.state            = x.state_db
      AND    d.file_template_id = l.file_template_id
      AND    d.file_direction   = l.file_direction 
      AND    d.remove_days      IS NOT NULL
      AND    (TRUNC(x.log_date) + d.remove_days) <= SYSDATE
      AND    l.file_type        LIKE file_type_
      AND    d.file_template_id LIKE file_template_id_;
   CURSOR get_count IS
      SELECT count(*) no_of_records
      FROM   ext_file_trans_tab
      WHERE  load_file_id = rec_load_file_id_;
BEGIN
   parameter_attr_ := Ext_File_Load_API.Get_Parameter_String ( load_file_id_ );
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'FILE_TYPEX',
                                       dummy_);
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      file_type_ := tmp_;
   END IF;
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'FILE_TEMPLATE_IDX',
                                       dummy_);
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      file_template_id_ := tmp_;
   END IF;
   tmp_ := Message_SYS.Find_Attribute (parameter_attr_,
                                       'REMOVE_ALL_LOAD_STATES',
                                       dummy_);
   IF ( NVL(tmp_,'<DUMMY>') != '<DUMMY>' ) THEN
      remove_all_states_ := tmp_;
   END IF;
   FOR rec_ IN get_attr LOOP
      rec_load_file_id_    := rec_.load_file_id;
      IF (remove_all_states_ = 'TRUE') THEN
         remove_ok_ := 'TRUE';
      ELSE
         IF (rec_.state IN ('4','7') ) THEN
            remove_ok_ := 'TRUE';
         ELSE
            remove_ok_ := 'FALSE';
         END IF;
      END IF;
      IF (remove_ok_ = 'TRUE') THEN
         OPEN  get_count;
         FETCH get_count INTO no_of_records_;
         IF (get_count%NOTFOUND) THEN
            no_of_records_ := 0;
         END IF;
         CLOSE get_count;
         IF (NVL(rec_.remove_complete,'FALSE') = 'TRUE') THEN
            Ext_File_Load_API.Delete_File_Load ( rec_.load_file_id );
         ELSE
            Ext_File_Trans_API.Remove_File_Trans ( rec_.load_file_id,
                                                   '8' );
         END IF;
         row_no_              := row_no_ + 1;
         newrec_.load_file_id := load_file_id_;
         newrec_.row_no       := row_no_;
         newrec_.row_state    := '1';
         newrec_.n1           := rec_.load_file_id;
         newrec_.c1           := rec_.file_type;
         newrec_.c2           := rec_.file_template_id;
         newrec_.c3           := rec_.file_direction;
         newrec_.c4           := rec_.state;
         newrec_.d1           := rec_.log_date;
         newrec_.n2           := rec_.remove_days;
         newrec_.d2           := rec_.remove_date;
         newrec_.n3           := no_of_records_;
         newrec_.c5           := rec_.remove_complete;
         Ext_File_Trans_API.Insert_Record ( newrec_ );
      END IF;
   END LOOP;
END Remove_Ready_Trans;


PROCEDURE Update_Error_Budget (
   objid_        IN     VARCHAR2,
   err_txt_      IN     VARCHAR2,
   error_no_     IN OUT NUMBER )
IS
   dummy_flag_      NUMBER;
   dummy_text_      VARCHAR2(2000);
   CURSOR get_error_flags IS
      SELECT n30, 
             error_text
      FROM Ext_File_Trans_Tab
      WHERE  rowid        = objid_;
BEGIN
   error_no_ := error_no_ + 1;
   OPEN  get_error_flags;
   FETCH get_error_flags INTO dummy_flag_, 
                              dummy_text_;
   CLOSE get_error_flags;
   IF (NVL(dummy_flag_,0) = 0 OR 
       NVL(dummy_text_,' ') = ' ')THEN
      UPDATE Ext_File_Trans_Tab SET 
         error_text = err_txt_, 
         n30        = 1,
         row_state  = '5'
      WHERE  rowid        = objid_;
   ELSE
      UPDATE Ext_File_Trans_Tab SET 
         error_text = (dummy_text_ || '
               ' || err_txt_),
         n30        = NVL(dummy_flag_,0) + 1,
         row_state  = '5'
      WHERE  rowid = objid_;
   END IF;
END Update_Error_Budget;


PROCEDURE Update_File_Load_State (
   load_file_id_ IN NUMBER )
IS
   dummy_           NUMBER;

   CURSOR get_not_transfered IS
      SELECT 1
      FROM  ext_file_trans_tab t
      WHERE t.load_file_id = load_file_id_
      AND   t.row_state != '3';
BEGIN

   IF (Check_Exist_File_Trans(load_file_id_) AND
      Ext_File_Load_API.Get_State_Db(load_file_id_) = '10') THEN
      OPEN get_not_transfered;
      FETCH get_not_transfered INTO dummy_;

      IF (get_not_transfered%NOTFOUND) THEN
         Ext_File_Load_API.Update_State(load_file_id_, '4'); 
      END IF;

      CLOSE get_not_transfered;
   END IF;
END Update_File_Load_State;


@UncheckedAccess
FUNCTION Get_Record_Type_Out (
   load_file_id_   IN NUMBER,
   record_type_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   file_type_           Ext_File_Type_Tab.file_type%TYPE;
   first_in_record_set_ VARCHAR2(5);
   last_in_record_set_  VARCHAR2(5);
   CURSOR get_attr IS
      SELECT first_in_record_set,
             last_in_record_set
      FROM   ext_file_type_rec_tab
      WHERE  file_type      = file_type_
      AND    record_type_id = record_type_id_;
BEGIN
   IF (record_type_id_ LIKE '%TAXNO%') THEN
      RETURN 'TAXNO';
   END IF;
   file_type_ := Ext_File_Load_API.Get_File_Type (load_file_id_);
   OPEN  get_attr;
   FETCH get_attr INTO first_in_record_set_, last_in_record_set_;
   CLOSE get_attr;
   IF (first_in_record_set_ = 'TRUE') THEN
      RETURN 'HEAD';
   ELSIF (last_in_record_set_ = 'TRUE') THEN
      RETURN 'END';
   ELSE
      RETURN 'DETAIL';
   END IF;
END Get_Record_Type_Out;



