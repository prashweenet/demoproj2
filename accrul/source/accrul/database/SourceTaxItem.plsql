-----------------------------------------------------------------------------
--
--  Logical unit: SourceTaxItem
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  151222          Created for HomeRun project
--  181226  MaRalk  FIUXX-7198, Added implementation method Get_Tax_Codes___ and modified the method Get_Tax_Codes accordingly.
--  181226          Added additional method Get_Tax_Codes with different signature in order to use in the tax line assistant implementation in Aurena. 
--  190111  AjPelk  Bug 146252, Corrected. Code modification done in Get_Total_Use_Tax_Amounts and Get_Total_Use_Tax_Dom_Amounts. 
--  200406  Janslk  Bug 152870, Changed Get_Line_Tax_Calc_Structure_Id and 
--                  Get_Tax_Items to include additional cursor to be used 
--                  when parameters are null.
--  200417  Nudilk  Bug 152777, Added method Same_Tax_Code_Percentage_Exist.
--  200629  Janslk  Bug 154577, Changed Get_Total_Tax_Curr_Amount and 
--                  Get_Total_Ndt_Curr_Amount to include additional cursor to be used 
--                  when all parameters are not null.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------

TYPE source_public_rec IS RECORD
   (company                        source_tax_item_tab.company%TYPE,
    source_ref_type                source_tax_item_tab.source_ref_type%TYPE,
    source_ref1                    source_tax_item_tab.source_ref1%TYPE,
    source_ref2                    source_tax_item_tab.source_ref2%TYPE,
    source_ref3                    source_tax_item_tab.source_ref3%TYPE,
    source_ref4                    source_tax_item_tab.source_ref4%TYPE,
    source_ref5                    source_tax_item_tab.source_ref5%TYPE,
    tax_item_id                    source_tax_item_tab.tax_item_id%TYPE,
    "rowid"                        ROWID,
    rowversion                     source_tax_item_tab.rowversion%TYPE,
    rowkey                         source_tax_item_tab.rowkey%TYPE,
    ROWTYPE                        source_tax_item_tab.ROWTYPE%TYPE,
    tax_code                       source_tax_item_tab.tax_code%TYPE,
    tax_percentage                 source_tax_item_tab.tax_percentage%TYPE,
    tax_calc_structure_id          source_tax_item_tab.tax_calc_structure_id%TYPE,
    tax_calc_structure_item_id     source_tax_item_tab.tax_calc_structure_item_id%TYPE,
    tax_curr_amount                source_tax_item_tab.tax_curr_amount%TYPE,
    tax_dom_amount                 source_tax_item_tab.tax_dom_amount%TYPE,
    tax_parallel_amount            source_tax_item_tab.tax_parallel_amount%TYPE,
    tax_base_curr_amount           source_tax_item_tab.tax_base_curr_amount%TYPE,
    tax_base_dom_amount            source_tax_item_tab.tax_base_dom_amount%TYPE,
    tax_base_parallel_amount       source_tax_item_tab.tax_base_parallel_amount%TYPE,
    transferred                    source_tax_item_tab.transferred%TYPE,    
    non_ded_tax_curr_amount        source_tax_item_tab.non_ded_tax_curr_amount%TYPE,
    non_ded_tax_dom_amount         source_tax_item_tab.non_ded_tax_dom_amount%TYPE,
    non_ded_tax_parallel_amount    source_tax_item_tab.non_ded_tax_parallel_amount%TYPE,
    tax_limit_curr_amount          source_tax_item_tab.tax_limit_curr_amount%TYPE);

TYPE source_tax_table IS TABLE OF source_public_rec INDEX BY BINARY_INTEGER;

TYPE amounts_per_tax_code IS RECORD 
   (tax_code                      VARCHAR2(20),
    tax_curr_amount               NUMBER,            
    tax_dom_amount                NUMBER,            
    tax_parallel_amount           NUMBER,            
    non_ded_tax_curr_amount       NUMBER,            
    non_ded_tax_dom_amount        NUMBER,           
    non_ded_tax_parallel_amount   NUMBER,            
    tax_base_curr_amount          NUMBER,
    tax_base_dom_amount           NUMBER,
    tax_base_parallel_amount      NUMBER);

TYPE amounts_per_tax_code_table IS TABLE OF amounts_per_tax_code INDEX BY BINARY_INTEGER;

-------------------- PRIVATE DECLARATIONS -----------------------------------
                                               
-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- IMPLEMENTATION METHODS FOR COMMON LOGIC ----------------

PROCEDURE Add_To_Tax_Codes_Message___ (
   tax_code_msg_        IN OUT VARCHAR2,
   tax_table_           IN     source_tax_table,   
   add_tax_curr_amount_ IN     VARCHAR2 )
IS
BEGIN
   tax_code_msg_ := Message_SYS.Construct('TAX_CODES');
   FOR i IN 1..tax_table_.COUNT LOOP
      Message_SYS.Add_Attribute(tax_code_msg_, 'TAX_CALC_STRUCTURE_ID', tax_table_(i).tax_calc_structure_id);
      Message_SYS.Add_Attribute(tax_code_msg_, 'TAX_CALC_STRUCTURE_ITEM_ID', tax_table_(i).tax_calc_structure_item_id);
      Message_SYS.Add_Attribute(tax_code_msg_, 'TAX_CODE', tax_table_(i).tax_code);
      Message_SYS.Add_Attribute(tax_code_msg_, 'TAX_PERCENTAGE', tax_table_(i).tax_percentage);
      IF (tax_table_(i).transferred = Fnd_Boolean_API.DB_TRUE) THEN
         Message_SYS.Add_Attribute(tax_code_msg_, 'TAX_BASE_CURR_AMOUNT', tax_table_(i).tax_base_curr_amount);
      END IF;
      IF (NVL(add_tax_curr_amount_, Fnd_Boolean_API.DB_FALSE) = Fnd_Boolean_API.DB_TRUE) THEN
         Message_SYS.Add_Attribute(tax_code_msg_, 'TAX_CURR_AMOUNT', tax_table_(i).tax_curr_amount);
      END IF;
   END LOOP;   
END Add_To_Tax_Codes_Message___;


FUNCTION Tax_Items_Count___ (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS   
   result_   NUMBER := 0;
   CURSOR get_tax_items_ref  IS
      SELECT COUNT(*)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_;
   CURSOR get_tax_items IS
      SELECT COUNT(*)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN get_tax_items;
      FETCH get_tax_items INTO result_;
      CLOSE get_tax_items;
   ELSE
 	   OPEN get_tax_items_ref;
      FETCH get_tax_items_ref INTO result_;
      CLOSE get_tax_items_ref; 	
 	END IF;
   RETURN result_;
END Tax_Items_Count___;


PROCEDURE Get_Tax_Codes___ (
   tax_code_msg_           OUT VARCHAR2,
   tax_code_               OUT VARCHAR2,
   tax_calc_structure_id_  OUT VARCHAR2,
   tax_percentage_         OUT NUMBER,
   tax_base_curr_amount_   OUT NUMBER,
   tax_table_              IN  source_tax_table,
   add_tax_curr_amount_    IN  VARCHAR2 )
IS
BEGIN
   IF (tax_table_.COUNT = 0) THEN
      tax_code_msg_          := NULL;
      tax_code_              := NULL;
      tax_percentage_        := NULL;
      tax_calc_structure_id_ := NULL;
      tax_base_curr_amount_  := NULL;
   ELSIF (tax_table_.COUNT = 1) THEN
      IF (tax_table_(1).tax_calc_structure_id IS NOT NULL) THEN
         Add_To_Tax_Codes_Message___(tax_code_msg_, tax_table_, add_tax_curr_amount_);
         tax_code_              := NULL;
         tax_percentage_        := NULL; 
         tax_calc_structure_id_ := tax_table_(1).tax_calc_structure_id;
         tax_base_curr_amount_  := NULL;
      ELSE
         tax_code_msg_          := NULL;
         tax_code_              := tax_table_(1).tax_code;
         tax_percentage_        := tax_table_(1).tax_percentage;
         tax_calc_structure_id_ := NULL;
         IF (tax_table_(1).transferred = Fnd_Boolean_API.DB_TRUE) THEN
            tax_base_curr_amount_ := tax_table_(1).tax_base_curr_amount;
         END IF;      
      END IF;
   ELSIF (tax_table_.COUNT > 1) THEN
      Add_To_Tax_Codes_Message___(tax_code_msg_, tax_table_, add_tax_curr_amount_);
      tax_code_              := NULL;
      tax_percentage_        := NULL;
      tax_calc_structure_id_ := tax_table_(1).tax_calc_structure_id;
      tax_base_curr_amount_  := NULL;
   END IF;
END Get_Tax_Codes___;   

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------
                                               
-------------------- LU SPECIFIC PROTECTED METHODS --------------------------
                                               
-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

-------------------- PUBLIC METHODS FOR FETCHING TAX CODE INFO --------------

@UncheckedAccess
FUNCTION Get_Line_Tax_Code ( 
   company_                      IN  VARCHAR2,
   source_ref_type_              IN  VARCHAR2,
   source_ref1_                  IN  VARCHAR2,
   source_ref2_                  IN  VARCHAR2,
   source_ref3_                  IN  VARCHAR2,
   source_ref4_                  IN  VARCHAR2,
   source_ref5_                  IN  VARCHAR2 ) RETURN VARCHAR2
IS
   is_multiple_tax_              VARCHAR2(5);
   tax_code_on_line_             VARCHAR2(20); 
   CURSOR get_tax_code_ref IS
      SELECT tax_code
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    tax_calc_structure_id IS NULL;       
   CURSOR get_tax_code IS
      SELECT tax_code
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5)
      AND    tax_calc_structure_id IS NULL;  
BEGIN
   is_multiple_tax_  := Multiple_Tax_Items_Exist(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   IF (is_multiple_tax_ = Fnd_Boolean_API.DB_TRUE) THEN
      tax_code_on_line_ := NULL;
   ELSE
      IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
         OPEN  get_tax_code;
         FETCH get_tax_code INTO tax_code_on_line_;
         CLOSE get_tax_code; 
      ELSE
         OPEN  get_tax_code_ref;
         FETCH get_tax_code_ref INTO tax_code_on_line_;
         CLOSE get_tax_code_ref; 
      END IF;            
   END IF;
   RETURN tax_code_on_line_;
END Get_Line_Tax_Code;


@UncheckedAccess
FUNCTION Get_Line_Tax_Calc_Structure_Id ( 
   company_                      IN  VARCHAR2,
   source_ref_type_              IN  VARCHAR2,
   source_ref1_                  IN  VARCHAR2,
   source_ref2_                  IN  VARCHAR2,
   source_ref3_                  IN  VARCHAR2,
   source_ref4_                  IN  VARCHAR2,
   source_ref5_                  IN  VARCHAR2 ) RETURN VARCHAR2
IS
   tax_calc_structure_id_        source_tax_item_tab.tax_calc_structure_id%TYPE;
   CURSOR get_tax_calc_structure_ref IS
      SELECT tax_calc_structure_id 
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_;
   CURSOR get_tax_calc_structure IS
      SELECT tax_calc_structure_id 
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN 
      OPEN  get_tax_calc_structure;
      FETCH get_tax_calc_structure INTO tax_calc_structure_id_;
      CLOSE get_tax_calc_structure;           
   ELSE
      OPEN  get_tax_calc_structure_ref;
      FETCH get_tax_calc_structure_ref INTO tax_calc_structure_id_;
      CLOSE get_tax_calc_structure_ref;        
   END IF;
   RETURN tax_calc_structure_id_;   
END Get_Line_Tax_Calc_Structure_Id;


--This method is to be used by Aurena
PROCEDURE Get_Tax_Codes (   
   tax_code_msg_           OUT VARCHAR2,
   tax_code_               OUT VARCHAR2,
   tax_calc_structure_id_  OUT VARCHAR2,
   tax_percentage_         OUT NUMBER,
   tax_base_curr_amount_   OUT NUMBER,
   tax_table_              IN  source_tax_table,  
   add_tax_curr_amount_    IN  VARCHAR2 )
IS 
BEGIN
   Get_Tax_Codes___(tax_code_msg_, tax_code_, tax_calc_structure_id_, tax_percentage_, tax_base_curr_amount_, tax_table_, add_tax_curr_amount_);
END Get_Tax_Codes;


PROCEDURE Get_Tax_Codes (   
   tax_code_msg_           OUT VARCHAR2,
   tax_code_               OUT VARCHAR2,
   tax_calc_structure_id_  OUT VARCHAR2,
   tax_percentage_         OUT NUMBER,
   tax_base_curr_amount_   OUT NUMBER,
   company_                IN  VARCHAR2,
   source_ref_type_        IN  VARCHAR2,   
   source_ref1_            IN  VARCHAR2,
   source_ref2_            IN  VARCHAR2,
   source_ref3_            IN  VARCHAR2,
   source_ref4_            IN  VARCHAR2,
   source_ref5_            IN  VARCHAR2,
   add_tax_curr_amount_    IN  VARCHAR2 )
IS 
   tax_table_              source_tax_table;
BEGIN
   tax_table_ := Get_Tax_Items(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   Get_Tax_Codes___(tax_code_msg_, tax_code_, tax_calc_structure_id_, tax_percentage_, tax_base_curr_amount_, tax_table_, add_tax_curr_amount_);
END Get_Tax_Codes;


FUNCTION Get_Tax_Items (
   company_             IN  VARCHAR2,
   source_ref_type_     IN  VARCHAR2,
   source_ref1_         IN  VARCHAR2,
   source_ref2_         IN  VARCHAR2,
   source_ref3_         IN  VARCHAR2,
   source_ref4_         IN  VARCHAR2,
   source_ref5_         IN  VARCHAR2 ) RETURN source_tax_table
IS 
   temp_         source_tax_table;
   CURSOR get_tax_record_ref IS
      SELECT company,
             source_ref_type,
             source_ref1,
             source_ref2,
             source_ref3,
             source_ref4,
             source_ref5,
             tax_item_id,
             ROWID,
             rowversion,
             rowkey,
             ROWTYPE,
             tax_code,
             tax_percentage,
             tax_calc_structure_id, 
             tax_calc_structure_item_id,
             tax_curr_amount,
             tax_dom_amount,
             tax_parallel_amount,
             tax_base_curr_amount,
             tax_base_dom_amount,
             tax_base_parallel_amount,
             transferred,              
             non_ded_tax_curr_amount,
             non_ded_tax_dom_amount,
             non_ded_tax_parallel_amount,
             tax_limit_curr_amount            
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_;    
   CURSOR get_tax_record IS
      SELECT company,
             source_ref_type,
             source_ref1,
             source_ref2,
             source_ref3,
             source_ref4,
             source_ref5,
             tax_item_id,
             ROWID,
             rowversion,
             rowkey,
             ROWTYPE,
             tax_code,
             tax_percentage,
             tax_calc_structure_id, 
             tax_calc_structure_item_id,
             tax_curr_amount,
             tax_dom_amount,
             tax_parallel_amount,
             tax_base_curr_amount,
             tax_base_dom_amount,
             tax_base_parallel_amount,
             transferred,              
             non_ded_tax_curr_amount,
             non_ded_tax_dom_amount,
             non_ded_tax_parallel_amount,
             tax_limit_curr_amount            
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5);       
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN 
      OPEN  get_tax_record;
      FETCH get_tax_record BULK COLLECT INTO temp_;
      CLOSE get_tax_record;
   ELSE
      OPEN  get_tax_record_ref;
      FETCH get_tax_record_ref BULK COLLECT INTO temp_;
      CLOSE get_tax_record_ref;
   END IF;   
   RETURN temp_;
END Get_Tax_Items;


FUNCTION Get_Tax_Item (
   company_             IN  VARCHAR2,
   source_ref_type_     IN  VARCHAR2,
   source_ref1_         IN  VARCHAR2,
   source_ref2_         IN  VARCHAR2,
   source_ref3_         IN  VARCHAR2,
   source_ref4_         IN  VARCHAR2,
   source_ref5_         IN  VARCHAR2,
   tax_item_id_         IN  NUMBER ) RETURN source_public_rec
IS 
   rec_                source_public_rec;   
   CURSOR get_tax_item IS
      SELECT company,
             source_ref_type,
             source_ref1,
             source_ref2,
             source_ref3,
             source_ref4,
             source_ref5,
             tax_item_id,
             ROWID,
             rowversion,
             rowkey,
             ROWTYPE,
             tax_code,
             tax_percentage,
             tax_calc_structure_id, 
             tax_calc_structure_item_id,
             tax_curr_amount,
             tax_dom_amount,
             tax_parallel_amount,
             tax_base_curr_amount,
             tax_base_dom_amount,
             tax_base_parallel_amount,
             transferred,              
             non_ded_tax_curr_amount,
             non_ded_tax_dom_amount,
             non_ded_tax_parallel_amount,
             tax_limit_curr_amount            
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    tax_item_id     = tax_item_id_;       
BEGIN
   OPEN  get_tax_item;
   FETCH get_tax_item INTO rec_;
   CLOSE get_tax_item;
   RETURN rec_;
END Get_Tax_Item;

-------------------- PUBLIC METHODS FOR FETCHING TAX RELATED INFO ----------

@UncheckedAccess
FUNCTION Get_Max_Tax_Item_Id (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS
   CURSOR max_tax_item_id_ref  IS
      SELECT MAX(tax_item_id)
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_;      
   CURSOR max_tax_item_id IS
      SELECT MAX(tax_item_id)
      FROM   source_tax_item_tab
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5);
   max_tax_item_id_ NUMBER;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN  max_tax_item_id;
      FETCH max_tax_item_id INTO max_tax_item_id_;
      CLOSE max_tax_item_id;
   ELSE
      OPEN  max_tax_item_id_ref;
      FETCH max_tax_item_id_ref INTO max_tax_item_id_;
      CLOSE max_tax_item_id_ref;  
   END IF;   
   RETURN NVL(max_tax_item_id_, 0);
END Get_Max_Tax_Item_Id;


-- Tax_Items_Exist
-- If at least one tax item exist return TRUE. Otherwise FALSE.
@UncheckedAccess
FUNCTION Tax_Items_Exist (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN VARCHAR2
IS   
   result_   NUMBER := 0;
BEGIN
   result_ := Tax_Items_Count___(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   IF (result_ > 0) THEN
      RETURN Fnd_Boolean_API.DB_TRUE;
   ELSE
      RETURN Fnd_Boolean_API.DB_FALSE;
   END IF;
END Tax_Items_Exist;


-- One_Tax_Item_Exists
-- If one tax item exist return TRUE. Otherwise FALSE. 
@UncheckedAccess
FUNCTION One_Tax_Item_Exists (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN VARCHAR2
IS
   result_   NUMBER := 0;
BEGIN
   result_ := Tax_Items_Count___(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   IF (result_ = 1) THEN
      RETURN Fnd_Boolean_API.DB_TRUE;
   ELSE
      RETURN Fnd_Boolean_API.DB_FALSE;
   END IF;
END One_Tax_Item_Exists;


-- Multiple_Tax_Items_Exist
-- If more than one tax item exist return TRUE. Otherwise FALSE. 
@UncheckedAccess
FUNCTION Multiple_Tax_Items_Exist (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN VARCHAR2
IS
   result_   NUMBER := 0;
BEGIN
   result_ := Tax_Items_Count___(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   IF (result_ > 1) THEN
      RETURN Fnd_Boolean_API.DB_TRUE;
   ELSE
      RETURN Fnd_Boolean_API.DB_FALSE;
   END IF;
END Multiple_Tax_Items_Exist;


-- Tax_Items_Taxable_Exist
-- If at least one tax item exist with percentage greater than 0 return TRUE. Otherwise FALSE.
@UncheckedAccess
FUNCTION Tax_Items_Taxable_Exist (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN VARCHAR2
IS   
   result_   VARCHAR2(20) := Fnd_Boolean_API.DB_FALSE;
   CURSOR get_tax_items_taxable_ref IS
      SELECT 'TRUE'
      FROM   source_tax_item_pub
      WHERE  company             = company_
      AND    source_ref_type_db  = source_ref_type_
      AND    source_ref1         = source_ref1_
      AND    source_ref2         = source_ref2_
      AND    source_ref3         = source_ref3_
      AND    source_ref4         = source_ref4_
      AND    source_ref5         = source_ref5_
      AND    tax_type_db         = Fee_Type_API.DB_TAX
      AND    tax_percentage     != 0;      
   CURSOR get_tax_items_taxable IS
      SELECT 'TRUE'
      FROM   source_tax_item_pub
      WHERE  company             = company_
      AND    source_ref_type_db  = source_ref_type_
      AND    source_ref1         = source_ref1_
      AND    source_ref2         = NVL(source_ref2_, source_ref2)
      AND    source_ref3         = NVL(source_ref3_, source_ref3)
      AND    source_ref4         = NVL(source_ref4_, source_ref4)
      AND    source_ref5         = NVL(source_ref5_, source_ref5)
      AND    tax_type_db         = Fee_Type_API.DB_TAX
      AND    tax_percentage     != 0;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN  get_tax_items_taxable;
      FETCH get_tax_items_taxable INTO result_;
      CLOSE get_tax_items_taxable; 
   ELSE
      OPEN  get_tax_items_taxable_ref;
      FETCH get_tax_items_taxable_ref INTO result_;
      CLOSE get_tax_items_taxable_ref;  
   END IF;
   RETURN result_;
END Tax_Items_Taxable_Exist;


-- Tax_Calc_Structure_Used
-- If at least one tax item with Tax Structure exist return TRUE. Otherwise FALSE.
@UncheckedAccess
FUNCTION Tax_Calc_Structure_Used (
   company_                IN VARCHAR2,
   tax_calc_structure_id_  IN VARCHAR2 ) RETURN BOOLEAN
IS
   result_   VARCHAR2(20) := Fnd_Boolean_API.DB_FALSE;
   CURSOR get_tax_items IS
      SELECT 'TRUE'
      FROM   source_tax_item_tab
      WHERE  company               = company_
      AND    tax_calc_structure_id = tax_calc_structure_id_;
BEGIN
   OPEN  get_tax_items;
   FETCH get_tax_items INTO result_;
   IF (get_tax_items%FOUND) THEN      
      CLOSE get_tax_items;
      RETURN TRUE;
   END IF;
   CLOSE get_tax_items;
   RETURN FALSE;
END Tax_Calc_Structure_Used;


@UncheckedAccess
FUNCTION Non_Deductible_Tax_Items_Exist ( 
   company_          IN VARCHAR2,
   source_ref_type_  IN VARCHAR2,
   source_ref1_      IN VARCHAR2,
   source_ref2_      IN VARCHAR2,
   source_ref3_      IN VARCHAR2,
   source_ref4_      IN VARCHAR2,
   source_ref5_      IN VARCHAR2 ) RETURN VARCHAR2
IS 
   result_      VARCHAR2(20) := Fnd_Boolean_API.DB_FALSE;   
   CURSOR check_non_ded_tax_ref IS
      SELECT 'TRUE'
      FROM   source_tax_item_tab             
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    NVL(non_ded_tax_curr_amount, 0) != 0;      
   CURSOR check_non_ded_tax IS
      SELECT 'TRUE'
      FROM   source_tax_item_tab             
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5)
      AND    NVL(non_ded_tax_curr_amount, 0) != 0;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN check_non_ded_tax;
      FETCH check_non_ded_tax INTO result_;
      CLOSE check_non_ded_tax;
   ELSE
      OPEN check_non_ded_tax_ref;
      FETCH check_non_ded_tax_ref INTO result_;
      CLOSE check_non_ded_tax_ref;
   END IF;
   RETURN result_;
END Non_Deductible_Tax_Items_Exist;


-- Note: This method is used to check same tax code with same percentage has been already used in the source. 
--       If such existance found then raise an error message to avoid duplicates.
--       This method will be called from all Source_Tax_Item_<Module>_API before inserting records.
PROCEDURE Same_Tax_Code_Percentage_Exist ( 
   company_          IN VARCHAR2,
   source_ref_type_  IN VARCHAR2,
   source_ref1_      IN VARCHAR2,
   source_ref2_      IN VARCHAR2,
   source_ref3_      IN VARCHAR2,
   source_ref4_      IN VARCHAR2,
   source_ref5_      IN VARCHAR2,
   tax_code_         IN VARCHAR2,
   tax_percentage_   IN NUMBER )
IS 
   result_      VARCHAR2(20) := Fnd_Boolean_API.DB_FALSE;
   CURSOR check_tax_code_percentage IS
      SELECT 'TRUE'
      FROM   source_tax_item_tab             
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    tax_code        = tax_code_
      AND    tax_percentage  = tax_percentage_;
BEGIN
   OPEN check_tax_code_percentage;
   FETCH check_tax_code_percentage INTO result_;
   CLOSE check_tax_code_percentage;
   IF (result_ = Fnd_Boolean_API.DB_TRUE) THEN
      Error_SYS.Record_General(lu_name_, 'DUPLICATETAXCODE: Identical tax codes are not allowed. Adjust tax setup on address and/or object level.');
   END IF;
END Same_Tax_Code_Percentage_Exist;


-- Get_Total_Tax_Percentage
--   This method returns the total tax percentage for a particular object line.
@UncheckedAccess
FUNCTION Get_Total_Tax_Percentage (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2 ,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS
   total_tax_percentage_  source_tax_item_tab.tax_percentage%TYPE;
   CURSOR get_total_percent_ref IS
      SELECT NVL(SUM(tax_percentage),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_;      
   CURSOR get_total_percent IS
      SELECT NVL(SUM(tax_percentage),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN  get_total_percent;
      FETCH get_total_percent INTO total_tax_percentage_;
      CLOSE get_total_percent;  
   ELSE 
      OPEN  get_total_percent_ref;
      FETCH get_total_percent_ref INTO total_tax_percentage_;
      CLOSE get_total_percent_ref;  
   END IF;
   RETURN total_tax_percentage_;
END Get_Total_Tax_Percentage;
  

PROCEDURE Get_Line_Tax_Code_Info (
   tax_code_on_line_             OUT VARCHAR2,
   total_tax_precentage_         OUT VARCHAR2,
   line_tax_curr_amount_         OUT NUMBER, 
   line_tax_dom_amount_          OUT NUMBER, 
   line_tax_para_amount_         OUT NUMBER,
   line_non_ded_tax_curr_amount_ OUT NUMBER, 
   line_non_ded_tax_dom_amount_  OUT NUMBER, 
   line_non_ded_tax_para_amount_ OUT NUMBER,   
   company_                      IN  VARCHAR2,
   source_ref_type_              IN  VARCHAR2,
   source_ref1_                  IN  VARCHAR2,
   source_ref2_                  IN  VARCHAR2,
   source_ref3_                  IN  VARCHAR2,
   source_ref4_                  IN  VARCHAR2,
   source_ref5_                  IN  VARCHAR2 )
IS   
   CURSOR get_line_tax_amounts_ref IS
      SELECT NVL(SUM(tax_percentage),0),
             NVL(SUM(tax_curr_amount),0), 
             NVL(SUM(tax_dom_amount),0), 
             NVL(SUM(tax_parallel_amount),0),
             NVL(SUM(non_ded_tax_curr_amount),0), 
             NVL(SUM(non_ded_tax_dom_amount),0), 
             NVL(SUM(non_ded_tax_parallel_amount),0)
      FROM   source_tax_item_pub
      WHERE  company            = company_
      AND    source_ref_type_db = source_ref_type_
      AND    source_ref1        = source_ref1_
      AND    source_ref2        = source_ref2_
      AND    source_ref3        = source_ref3_
      AND    source_ref4        = source_ref4_
      AND    source_ref5        = source_ref5_
      AND    tax_type_db        = Fee_Type_API.DB_TAX;      
   CURSOR get_line_tax_amounts IS
      SELECT NVL(SUM(tax_percentage),0),
             NVL(SUM(tax_curr_amount),0), 
             NVL(SUM(tax_dom_amount),0), 
             NVL(SUM(tax_parallel_amount),0),
             NVL(SUM(non_ded_tax_curr_amount),0), 
             NVL(SUM(non_ded_tax_dom_amount),0), 
             NVL(SUM(non_ded_tax_parallel_amount),0)
      FROM   source_tax_item_pub
      WHERE  company            = company_
      AND    source_ref_type_db = source_ref_type_
      AND    source_ref1        = source_ref1_
      AND    source_ref2        = NVL(source_ref2_, source_ref2)
      AND    source_ref3        = NVL(source_ref3_, source_ref3)
      AND    source_ref4        = NVL(source_ref4_, source_ref4)
      AND    source_ref5        = NVL(source_ref5_, source_ref5)
      AND    tax_type_db        = Fee_Type_API.DB_TAX;    
BEGIN
   tax_code_on_line_ := Get_Line_Tax_Code(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN  get_line_tax_amounts;
      FETCH get_line_tax_amounts INTO total_tax_precentage_, line_tax_curr_amount_, line_tax_dom_amount_, line_tax_para_amount_, line_non_ded_tax_curr_amount_, line_non_ded_tax_dom_amount_, line_non_ded_tax_para_amount_;
      CLOSE get_line_tax_amounts;
   ELSE 
      OPEN  get_line_tax_amounts_ref;
      FETCH get_line_tax_amounts_ref INTO total_tax_precentage_, line_tax_curr_amount_, line_tax_dom_amount_, line_tax_para_amount_, line_non_ded_tax_curr_amount_, line_non_ded_tax_dom_amount_, line_non_ded_tax_para_amount_;
      CLOSE get_line_tax_amounts_ref;
   END IF;
END Get_Line_Tax_Code_Info;


-- Get_Total_Tax_Curr_Amount
--   This method returns the total tax amount in transaction currency for a particular object line.
@UncheckedAccess
FUNCTION Get_Total_Tax_Curr_Amount (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2 ,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS
   tax_curr_amount_  source_tax_item_tab.tax_curr_amount%TYPE;
   CURSOR get_total_tax_curr_ref IS
      SELECT NVL(SUM(tax_curr_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_;
   CURSOR get_total_tax_curr IS
      SELECT NVL(SUM(tax_curr_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN   get_total_tax_curr;
      FETCH  get_total_tax_curr INTO tax_curr_amount_;
      CLOSE  get_total_tax_curr;
   ELSE
      OPEN   get_total_tax_curr_ref;
      FETCH  get_total_tax_curr_ref INTO tax_curr_amount_;
      CLOSE  get_total_tax_curr_ref;
   END IF;   
   RETURN tax_curr_amount_;
END Get_Total_Tax_Curr_Amount;


-- Get_Total_Tax_Dom_Amount
--   This method returns the total tax amount in accounting currency for a particular object line.
@UncheckedAccess
FUNCTION Get_Total_Tax_Dom_Amount (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2 ,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS
   tax_dom_amount_  source_tax_item_tab.tax_dom_amount%TYPE;   
   CURSOR get_total_tax_dom_ref IS
      SELECT NVL(SUM(tax_dom_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_;      
   CURSOR get_total_tax_dom IS
      SELECT NVL(SUM(tax_dom_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN   get_total_tax_dom;
      FETCH  get_total_tax_dom INTO tax_dom_amount_;
      CLOSE  get_total_tax_dom;
   ELSE
      OPEN   get_total_tax_dom_ref;
      FETCH  get_total_tax_dom_ref INTO tax_dom_amount_;
      CLOSE  get_total_tax_dom_ref;
   END IF;
   RETURN tax_dom_amount_;
END Get_Total_Tax_Dom_Amount;


-- Get_Total_Ndt_Curr_Amount
--   This method returns the total non deductible tax amount in transaction currency for a particular object line.
@UncheckedAccess
FUNCTION Get_Total_Ndt_Curr_Amount (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2 ,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS
   non_ded_tax_curr_amount_  source_tax_item_tab.non_ded_tax_curr_amount%TYPE;
   CURSOR get_total_non_ded_tax_curr_ref IS
      SELECT NVL(SUM(non_ded_tax_curr_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_;
   CURSOR get_total_non_ded_tax_curr IS
      SELECT NVL(SUM(non_ded_tax_curr_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN   get_total_non_ded_tax_curr;
      FETCH  get_total_non_ded_tax_curr INTO non_ded_tax_curr_amount_;
      CLOSE  get_total_non_ded_tax_curr;
   ELSE
      OPEN   get_total_non_ded_tax_curr_ref;
      FETCH  get_total_non_ded_tax_curr_ref INTO non_ded_tax_curr_amount_;
      CLOSE  get_total_non_ded_tax_curr_ref;
   END IF;   
   RETURN non_ded_tax_curr_amount_;   
END Get_Total_Ndt_Curr_Amount;


-- Get_Total_Ndt_Dom_Amount
--   This method returns the total non deductible tax amount in accounting currency for a particular object line.
@UncheckedAccess
FUNCTION Get_Total_Ndt_Dom_Amount (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2 ,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2 ) RETURN NUMBER
IS
   non_ded_tax_dom_amount_  source_tax_item_tab.non_ded_tax_dom_amount%TYPE;
   CURSOR get_total_non_ded_tax_dom_ref IS
      SELECT NVL(SUM(non_ded_tax_dom_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_;      
   CURSOR get_total_non_ded_tax_dom IS
      SELECT NVL(SUM(non_ded_tax_dom_amount),0)
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5);
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN   get_total_non_ded_tax_dom;
      FETCH  get_total_non_ded_tax_dom INTO non_ded_tax_dom_amount_;
      CLOSE  get_total_non_ded_tax_dom;
   ELSE
      OPEN   get_total_non_ded_tax_dom_ref;
      FETCH  get_total_non_ded_tax_dom_ref INTO non_ded_tax_dom_amount_;
      CLOSE  get_total_non_ded_tax_dom_ref;
   END IF;
   RETURN non_ded_tax_dom_amount_;
END Get_Total_Ndt_Dom_Amount;


-- Get_Total_Use_Tax_Amounts
--   This method returns the total tax curr amount and non deductible tax amount for use tax of a particular object line.
PROCEDURE Get_Total_Use_Tax_Amounts (
   tax_curr_amount_          OUT NUMBER,
   non_ded_tax_curr_amount_  OUT NUMBER,
   company_                  IN  VARCHAR2,
   source_ref_type_          IN  VARCHAR2,
   source_ref1_              IN  VARCHAR2,
   source_ref2_              IN  VARCHAR2,
   source_ref3_              IN  VARCHAR2,
   source_ref4_              IN  VARCHAR2,
   source_ref5_              IN  VARCHAR2 )
IS
   CURSOR get_total_item_use_tax_amounts_ref IS
      SELECT NVL(SUM(tax_curr_amount),0), 
             NVL(SUM(non_ded_tax_curr_amount),0)
      FROM   source_tax_item_pub
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    tax_type_db     = Fee_Type_API.DB_USE_TAX;      
   CURSOR get_total_item_use_tax_amounts IS
      SELECT NVL(SUM(tax_curr_amount),0), 
             NVL(SUM(non_ded_tax_curr_amount),0)
      FROM   source_tax_item_pub
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5)
      AND    tax_type_db     = Fee_Type_API.DB_USE_TAX;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN  get_total_item_use_tax_amounts;
      FETCH get_total_item_use_tax_amounts INTO tax_curr_amount_, non_ded_tax_curr_amount_;
      CLOSE get_total_item_use_tax_amounts;
   ELSE
      OPEN  get_total_item_use_tax_amounts_ref;
      FETCH get_total_item_use_tax_amounts_ref INTO tax_curr_amount_, non_ded_tax_curr_amount_;
      CLOSE get_total_item_use_tax_amounts_ref;
   END IF;
END Get_Total_Use_Tax_Amounts;


-- Get_Total_Use_Tax_Dom_Amounts
--   This method returns the total tax dom amount and non deductible tax dom amount for use tax of a particular object line.
PROCEDURE Get_Total_Use_Tax_Dom_Amounts (
   tax_dom_amount_           OUT NUMBER,
   non_ded_tax_dom_amount_   OUT NUMBER,
   company_                  IN  VARCHAR2,
   source_ref_type_          IN  VARCHAR2,
   source_ref1_              IN  VARCHAR2,
   source_ref2_              IN  VARCHAR2,
   source_ref3_              IN  VARCHAR2,
   source_ref4_              IN  VARCHAR2,
   source_ref5_              IN  VARCHAR2 )
IS
   CURSOR get_tot_item_use_tax_dom_amts_ref IS
      SELECT NVL(SUM(tax_dom_amount),0), 
             NVL(SUM(non_ded_tax_dom_amount),0)
      FROM   source_tax_item_pub
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    tax_type_db     = Fee_Type_API.DB_USE_TAX;      
   CURSOR get_tot_item_use_tax_dom_amts IS
      SELECT NVL(SUM(tax_dom_amount),0), 
             NVL(SUM(non_ded_tax_dom_amount),0)
      FROM   source_tax_item_pub
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5)
      AND    tax_type_db     = Fee_Type_API.DB_USE_TAX;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      OPEN  get_tot_item_use_tax_dom_amts;
      FETCH get_tot_item_use_tax_dom_amts INTO tax_dom_amount_, non_ded_tax_dom_amount_;
      CLOSE get_tot_item_use_tax_dom_amts;
   ELSE  
      OPEN  get_tot_item_use_tax_dom_amts_ref;
      FETCH get_tot_item_use_tax_dom_amts_ref INTO tax_dom_amount_, non_ded_tax_dom_amount_;
      CLOSE get_tot_item_use_tax_dom_amts_ref;
   END IF;
END Get_Total_Use_Tax_Dom_Amounts;


@UncheckedAccess
FUNCTION Get_Tax_Code_Percentage (
   company_         IN VARCHAR2,
   source_ref_type_ IN VARCHAR2,
   source_ref1_     IN VARCHAR2,
   source_ref2_     IN VARCHAR2,
   source_ref3_     IN VARCHAR2,
   source_ref4_     IN VARCHAR2,
   source_ref5_     IN VARCHAR2,
   tax_code_        IN VARCHAR2 ) RETURN NUMBER
IS
   tax_percentage_  source_tax_item_tab.tax_percentage%TYPE := NULL;
   CURSOR get_tax_percent_ref IS
      SELECT tax_percentage
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = source_ref2_
      AND    source_ref3      = source_ref3_
      AND    source_ref4      = source_ref4_
      AND    source_ref5      = source_ref5_
      AND    tax_code         = tax_code_;      
   CURSOR get_tax_percent IS
      SELECT tax_percentage
      FROM   source_tax_item_tab
      WHERE  company          = company_
      AND    source_ref_type  = source_ref_type_
      AND    source_ref1      = source_ref1_
      AND    source_ref2      = NVL(source_ref2_, source_ref2)
      AND    source_ref3      = NVL(source_ref3_, source_ref3)
      AND    source_ref4      = NVL(source_ref4_, source_ref4)
      AND    source_ref5      = NVL(source_ref5_, source_ref5)
      AND    tax_code         = tax_code_;
BEGIN
   IF (tax_code_ IS NOT NULL) THEN
      IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
         OPEN get_tax_percent;
         FETCH get_tax_percent INTO tax_percentage_;
         CLOSE get_tax_percent;  
      ELSE
         OPEN get_tax_percent_ref;
         FETCH get_tax_percent_ref INTO tax_percentage_;
         CLOSE get_tax_percent_ref; 
      END IF;
   END IF;
   RETURN tax_percentage_;
END Get_Tax_Code_Percentage;


PROCEDURE Get_Amounts_Per_Tax_Code (
   tax_table_                OUT amounts_per_tax_code_table,
   company_                  IN  VARCHAR2,
   source_ref_type_          IN  VARCHAR2,
   source_ref1_              IN  VARCHAR2,
   source_ref2_              IN  VARCHAR2,
   source_ref3_              IN  VARCHAR2,
   source_ref4_              IN  VARCHAR2,
   source_ref5_              IN  VARCHAR2 )
IS
   index_ NUMBER := 0;
   CURSOR get_tax_amounts_info_ref IS
      SELECT tax_code, 
             NVL(SUM(tax_curr_amount),0)              tax_curr_amount, 
             NVL(SUM(tax_dom_amount),0)               tax_dom_amount, 
             NVL(SUM(tax_parallel_amount),0)          tax_parallel_amount,
             NVL(SUM(non_ded_tax_curr_amount),0)      non_ded_tax_curr_amount, 
             NVL(SUM(non_ded_tax_dom_amount),0)       non_ded_tax_dom_amount, 
             NVL(SUM(non_ded_tax_parallel_amount),0)  non_ded_tax_parallel_amount,
             NVL(SUM(tax_base_curr_amount),0)         tax_base_curr_amount, 
             NVL(SUM(tax_base_dom_amount),0)          tax_base_dom_amount, 
             NVL(SUM(tax_base_parallel_amount),0)     tax_base_parallel_amount
      FROM   source_tax_item_tab 
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      GROUP BY tax_code;      
   CURSOR get_tax_amounts_info IS
      SELECT tax_code, 
             NVL(SUM(tax_curr_amount),0)              tax_curr_amount, 
             NVL(SUM(tax_dom_amount),0)               tax_dom_amount, 
             NVL(SUM(tax_parallel_amount),0)          tax_parallel_amount,
             NVL(SUM(non_ded_tax_curr_amount),0)      non_ded_tax_curr_amount, 
             NVL(SUM(non_ded_tax_dom_amount),0)       non_ded_tax_dom_amount, 
             NVL(SUM(non_ded_tax_parallel_amount),0)  non_ded_tax_parallel_amount,
             NVL(SUM(tax_base_curr_amount),0)         tax_base_curr_amount, 
             NVL(SUM(tax_base_dom_amount),0)          tax_base_dom_amount, 
             NVL(SUM(tax_base_parallel_amount),0)     tax_base_parallel_amount
      FROM   source_tax_item_tab 
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5)
      GROUP BY tax_code;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      FOR tax_info_ IN get_tax_amounts_info LOOP
         index_ := index_ + 1;
         tax_table_(index_).tax_code                     := tax_info_.tax_code;
         tax_table_(index_).tax_curr_amount              := tax_info_.tax_curr_amount;
         tax_table_(index_).tax_dom_amount               := tax_info_.tax_dom_amount;
         tax_table_(index_).tax_parallel_amount          := tax_info_.tax_parallel_amount;
         tax_table_(index_).non_ded_tax_curr_amount      := tax_info_.non_ded_tax_curr_amount;
         tax_table_(index_).non_ded_tax_dom_amount       := tax_info_.non_ded_tax_dom_amount;
         tax_table_(index_).non_ded_tax_parallel_amount  := tax_info_.non_ded_tax_parallel_amount;
         tax_table_(index_).tax_base_curr_amount         := tax_info_.tax_base_curr_amount;
         tax_table_(index_).tax_base_dom_amount          := tax_info_.tax_base_dom_amount;
         tax_table_(index_).tax_base_parallel_amount     := tax_info_.tax_base_parallel_amount;
      END LOOP;   
   ELSE
      FOR tax_info_ IN get_tax_amounts_info_ref LOOP
         index_ := index_ + 1;
         tax_table_(index_).tax_code                     := tax_info_.tax_code;
         tax_table_(index_).tax_curr_amount              := tax_info_.tax_curr_amount;
         tax_table_(index_).tax_dom_amount               := tax_info_.tax_dom_amount;
         tax_table_(index_).tax_parallel_amount          := tax_info_.tax_parallel_amount;
         tax_table_(index_).non_ded_tax_curr_amount      := tax_info_.non_ded_tax_curr_amount;
         tax_table_(index_).non_ded_tax_dom_amount       := tax_info_.non_ded_tax_dom_amount;
         tax_table_(index_).non_ded_tax_parallel_amount  := tax_info_.non_ded_tax_parallel_amount;
         tax_table_(index_).tax_base_curr_amount         := tax_info_.tax_base_curr_amount;
         tax_table_(index_).tax_base_dom_amount          := tax_info_.tax_base_dom_amount;
         tax_table_(index_).tax_base_parallel_amount     := tax_info_.tax_base_parallel_amount;
      END LOOP;
   END IF;
END Get_Amounts_Per_Tax_Code;


PROCEDURE Get_Amounts_Per_Tax_Code (
   tax_table_                OUT amounts_per_tax_code_table,
   company_                  IN  VARCHAR2,
   source_ref_type_          IN  VARCHAR2,
   source_ref1_              IN  VARCHAR2,
   source_ref2_              IN  VARCHAR2,
   source_ref3_              IN  VARCHAR2,
   source_ref4_              IN  VARCHAR2,
   source_ref5_              IN  VARCHAR2,
   tax_code_                 IN  VARCHAR2 )
IS
   index_ NUMBER := 0;
   CURSOR get_tax_amounts_info_ref IS
      SELECT NVL(SUM(tax_curr_amount),0)              tax_curr_amount, 
             NVL(SUM(tax_dom_amount),0)               tax_dom_amount, 
             NVL(SUM(tax_parallel_amount),0)          tax_parallel_amount,
             NVL(SUM(non_ded_tax_curr_amount),0)      non_ded_tax_curr_amount, 
             NVL(SUM(non_ded_tax_dom_amount),0)       non_ded_tax_dom_amount, 
             NVL(SUM(non_ded_tax_parallel_amount),0)  non_ded_tax_parallel_amount,
             NVL(SUM(tax_base_curr_amount),0)         tax_base_curr_amount, 
             NVL(SUM(tax_base_dom_amount),0)          tax_base_dom_amount, 
             NVL(SUM(tax_base_parallel_amount),0)     tax_base_parallel_amount
      FROM   source_tax_item_tab 
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = source_ref2_
      AND    source_ref3     = source_ref3_
      AND    source_ref4     = source_ref4_
      AND    source_ref5     = source_ref5_
      AND    tax_code        = tax_code_;      
   CURSOR get_tax_amounts_info IS
      SELECT NVL(SUM(tax_curr_amount),0)              tax_curr_amount, 
             NVL(SUM(tax_dom_amount),0)               tax_dom_amount, 
             NVL(SUM(tax_parallel_amount),0)          tax_parallel_amount,
             NVL(SUM(non_ded_tax_curr_amount),0)      non_ded_tax_curr_amount, 
             NVL(SUM(non_ded_tax_dom_amount),0)       non_ded_tax_dom_amount, 
             NVL(SUM(non_ded_tax_parallel_amount),0)  non_ded_tax_parallel_amount,
             NVL(SUM(tax_base_curr_amount),0)         tax_base_curr_amount, 
             NVL(SUM(tax_base_dom_amount),0)          tax_base_dom_amount, 
             NVL(SUM(tax_base_parallel_amount),0)     tax_base_parallel_amount
      FROM   source_tax_item_tab 
      WHERE  company         = company_
      AND    source_ref_type = source_ref_type_
      AND    source_ref1     = source_ref1_
      AND    source_ref2     = NVL(source_ref2_, source_ref2)
      AND    source_ref3     = NVL(source_ref3_, source_ref3)
      AND    source_ref4     = NVL(source_ref4_, source_ref4)
      AND    source_ref5     = NVL(source_ref5_, source_ref5)
      AND    tax_code        = tax_code_;
BEGIN
   IF (source_ref2_ IS NULL OR source_ref3_ IS NULL OR source_ref4_ IS NULL OR source_ref5_ IS NULL) THEN
      FOR tax_info_ IN get_tax_amounts_info LOOP
         index_ := index_ + 1;
         tax_table_(index_).tax_code                     := tax_code_;
         tax_table_(index_).tax_curr_amount              := tax_info_.tax_curr_amount;
         tax_table_(index_).tax_dom_amount               := tax_info_.tax_dom_amount;
         tax_table_(index_).tax_parallel_amount          := tax_info_.tax_parallel_amount;
         tax_table_(index_).non_ded_tax_curr_amount      := tax_info_.non_ded_tax_curr_amount;
         tax_table_(index_).non_ded_tax_dom_amount       := tax_info_.non_ded_tax_dom_amount;
         tax_table_(index_).non_ded_tax_parallel_amount  := tax_info_.non_ded_tax_parallel_amount;
         tax_table_(index_).tax_base_curr_amount         := tax_info_.tax_base_curr_amount;
         tax_table_(index_).tax_base_dom_amount          := tax_info_.tax_base_dom_amount;
         tax_table_(index_).tax_base_parallel_amount     := tax_info_.tax_base_parallel_amount;
      END LOOP; 
   ELSE
      FOR tax_info_ IN get_tax_amounts_info_ref LOOP
         index_ := index_ + 1;
         tax_table_(index_).tax_code                     := tax_code_;
         tax_table_(index_).tax_curr_amount              := tax_info_.tax_curr_amount;
         tax_table_(index_).tax_dom_amount               := tax_info_.tax_dom_amount;
         tax_table_(index_).tax_parallel_amount          := tax_info_.tax_parallel_amount;
         tax_table_(index_).non_ded_tax_curr_amount      := tax_info_.non_ded_tax_curr_amount;
         tax_table_(index_).non_ded_tax_dom_amount       := tax_info_.non_ded_tax_dom_amount;
         tax_table_(index_).non_ded_tax_parallel_amount  := tax_info_.non_ded_tax_parallel_amount;
         tax_table_(index_).tax_base_curr_amount         := tax_info_.tax_base_curr_amount;
         tax_table_(index_).tax_base_dom_amount          := tax_info_.tax_base_dom_amount;
         tax_table_(index_).tax_base_parallel_amount     := tax_info_.tax_base_parallel_amount;
      END LOOP;
   END IF;      
END Get_Amounts_Per_Tax_Code;

-------------------- PUBLIC METHODS FOR RECORD HANDLING --------------------

PROCEDURE Assign_Pubrec_To_Record (
   outrec_    OUT source_tax_item_tab%ROWTYPE,
   inrec_     IN  source_public_rec )
IS
BEGIN
   outrec_.company                     := inrec_.company;
   outrec_.source_ref_type             := inrec_.source_ref_type;
   outrec_.source_ref1                 := inrec_.source_ref1;
   outrec_.source_ref2                 := inrec_.source_ref2;
   outrec_.source_ref3                 := inrec_.source_ref3;
   outrec_.source_ref4                 := inrec_.source_ref4;
   outrec_.source_ref5                 := inrec_.source_ref5;
   outrec_.tax_item_id                 := inrec_.tax_item_id;
   outrec_.tax_code                    := inrec_.tax_code;
   outrec_.tax_percentage              := inrec_.tax_percentage;
   outrec_.tax_calc_structure_id       := inrec_.tax_calc_structure_id;
   outrec_.tax_calc_structure_item_id  := inrec_.tax_calc_structure_item_id;
   outrec_.tax_curr_amount             := inrec_.tax_curr_amount;
   outrec_.tax_dom_amount              := inrec_.tax_dom_amount;
   outrec_.non_ded_tax_curr_amount     := inrec_.non_ded_tax_curr_amount;
   outrec_.non_ded_tax_dom_amount      := inrec_.non_ded_tax_dom_amount;
   outrec_.non_ded_tax_parallel_amount := inrec_.non_ded_tax_parallel_amount;   
   outrec_.tax_parallel_amount         := inrec_.tax_parallel_amount;      
   outrec_.tax_base_curr_amount        := inrec_.tax_base_curr_amount;
   outrec_.tax_base_dom_amount         := inrec_.tax_base_dom_amount;
   outrec_.tax_base_parallel_amount    := inrec_.tax_base_parallel_amount;
   outrec_.transferred                 := inrec_.transferred;
   outrec_.tax_limit_curr_amount       := inrec_.tax_limit_curr_amount;
END Assign_Pubrec_To_Record;


PROCEDURE Assign_Param_To_Record (
   outrec_                     OUT source_tax_item_tab%ROWTYPE,
   company_                    IN  VARCHAR2,
   source_ref_type_            IN  VARCHAR2,
   source_ref1_                IN  VARCHAR2,
   source_ref2_                IN  VARCHAR2,
   source_ref3_                IN  VARCHAR2,
   source_ref4_                IN  VARCHAR2,
   source_ref5_                IN  VARCHAR2,
   tax_code_                   IN  VARCHAR2,
   tax_calc_structure_id_      IN  VARCHAR2,
   tax_calc_structure_item_id_ IN  VARCHAR2,
   transferred_                IN  VARCHAR2,
   tax_item_id_                IN  NUMBER,
   tax_percentage_             IN  NUMBER,
   tax_curr_amount_            IN  NUMBER,
   tax_dom_amount_             IN  NUMBER,
   tax_para_amount_            IN  NUMBER,
   non_ded_tax_curr_amount_    IN  NUMBER,
   non_ded_tax_dom_amount_     IN  NUMBER,
   non_ded_tax_para_amount_    IN  NUMBER,      
   tax_base_curr_amount_       IN  NUMBER,
   tax_base_dom_amount_        IN  NUMBER,
   tax_base_para_amount_       IN  NUMBER,
   tax_limit_curr_amount_      IN  NUMBER )
IS
BEGIN
   outrec_.company                     := company_;
   outrec_.source_ref_type             := source_ref_type_;
   outrec_.source_ref1                 := source_ref1_;
   outrec_.source_ref2                 := source_ref2_;
   outrec_.source_ref3                 := source_ref3_;
   outrec_.source_ref4                 := source_ref4_;
   outrec_.source_ref5                 := source_ref5_;
   outrec_.tax_item_id                 := tax_item_id_;
   outrec_.tax_code                    := tax_code_;
   outrec_.tax_percentage              := tax_percentage_;
   outrec_.tax_calc_structure_id       := tax_calc_structure_id_;
   outrec_.tax_calc_structure_item_id  := tax_calc_structure_item_id_;
   outrec_.tax_curr_amount             := tax_curr_amount_;
   outrec_.tax_dom_amount              := tax_dom_amount_;
   outrec_.tax_parallel_amount         := tax_para_amount_;
   outrec_.non_ded_tax_curr_amount     := non_ded_tax_curr_amount_;
   outrec_.non_ded_tax_dom_amount      := non_ded_tax_dom_amount_;
   outrec_.non_ded_tax_parallel_amount := non_ded_tax_para_amount_;   
   outrec_.tax_base_curr_amount        := tax_base_curr_amount_;
   outrec_.tax_base_dom_amount         := tax_base_dom_amount_;
   outrec_.tax_base_parallel_amount    := tax_base_para_amount_;
   outrec_.transferred                 := transferred_;
   outrec_.tax_limit_curr_amount       := tax_limit_curr_amount_;
END Assign_Param_To_Record;


PROCEDURE Assign_Message_To_Pubrec (
   tax_rec_     OUT source_tax_table,
   no_of_tax_   OUT NUMBER,
   msg_         IN  VARCHAR2 )
IS
   count_           NUMBER;
   index_           NUMBER := 0;   
   m_s_names_       Message_SYS.name_table;
   m_s_values_      Message_SYS.line_table;   
BEGIN
   Message_SYS.Get_Attributes(msg_, count_, m_s_names_, m_s_values_);
   FOR dummy_ IN 1..count_ LOOP
      IF (m_s_names_(dummy_) = 'TAX_ITEM_ID') THEN
         index_ := index_ + 1;
         tax_rec_(index_).tax_item_id := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));        
      ELSIF (m_s_names_(dummy_) = 'TAX_CODE') THEN
         tax_rec_(index_).tax_code := m_s_values_(dummy_);
      ELSIF (m_s_names_(dummy_) = 'TAX_PERCENTAGE') THEN
         tax_rec_(index_).tax_percentage := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'TAX_CALC_STRUCTURE_ID') THEN
         tax_rec_(index_).tax_calc_structure_id := m_s_values_(dummy_);
      ELSIF (m_s_names_(dummy_) = 'TAX_CALC_STRUCTURE_ITEM_ID') THEN
         tax_rec_(index_).tax_calc_structure_item_id := m_s_values_(dummy_);
      ELSIF (m_s_names_(dummy_) = 'TAX_CURR_AMOUNT') THEN
         tax_rec_(index_).tax_curr_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'TAX_DOM_AMOUNT') THEN
         tax_rec_(index_).tax_dom_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'TAX_PARALLEL_AMOUNT') THEN
         tax_rec_(index_).tax_parallel_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'TAX_BASE_CURR_AMOUNT') THEN
         tax_rec_(index_).tax_base_curr_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'TAX_BASE_DOM_AMOUNT') THEN
         tax_rec_(index_).tax_base_dom_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'TAX_BASE_PARALLEL_AMOUNT') THEN
         tax_rec_(index_).tax_base_parallel_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'NON_DED_TAX_CURR_AMOUNT') THEN
         tax_rec_(index_).non_ded_tax_curr_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'NON_DED_TAX_DOM_AMOUNT') THEN
         tax_rec_(index_).non_ded_tax_dom_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));
      ELSIF (m_s_names_(dummy_) = 'NON_DED_TAX_PARALLEL_AMOUNT') THEN
         tax_rec_(index_).non_ded_tax_parallel_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));         
      ELSIF (m_s_names_(dummy_) = 'TAX_LIMIT_CURR_AMOUNT') THEN
         tax_rec_(index_).tax_limit_curr_amount := Client_SYS.Attr_Value_To_Number(m_s_values_(dummy_));   
      ELSIF (m_s_names_(dummy_) = 'TRANSFERRED') THEN
         tax_rec_(index_).transferred := m_s_values_(dummy_);
      ELSE
         NULL;
      END IF;
   END LOOP;
   no_of_tax_ := index_;   
END Assign_Message_To_Pubrec;

-------------------- PUBLIC METHODS FOR COMMON LOGIC -----------------------

PROCEDURE Get_Tax_Item_Msg (
   msg_             IN OUT  VARCHAR2,
   company_         IN      VARCHAR2,
   source_ref_type_ IN      VARCHAR2,
   source_ref1_     IN      VARCHAR2,
   source_ref2_     IN      VARCHAR2,
   source_ref3_     IN      VARCHAR2,
   source_ref4_     IN      VARCHAR2,
   source_ref5_     IN      VARCHAR2 )
IS
   tax_table_    source_tax_table;
BEGIN
   msg_       := Message_SYS.Construct('TAX_INFORMATION');
   tax_table_ := Get_Tax_Items(company_, source_ref_type_, source_ref1_, source_ref2_, source_ref3_, source_ref4_, source_ref5_);
   IF (tax_table_.COUNT = 0) THEN
      msg_ := NULL;
   END IF;
   FOR i IN 1 .. tax_table_.COUNT LOOP      
      tax_table_(i).tax_item_id := -1;      
      Add_To_Tax_Message(msg_, tax_table_(i), company_);
   END LOOP;
END Get_Tax_Item_Msg;


PROCEDURE Add_To_Tax_Message (
   msg_                  IN OUT VARCHAR2,
   tax_source_rec_       IN     source_public_rec,
   company_              IN     VARCHAR2 )
IS
   tax_rec_   Statutory_Fee_API.Public_Rec; 
BEGIN
   IF (Message_SYS.Get_Name(msg_) = 'TAX_INFORMATION') THEN 
      tax_rec_  := Statutory_Fee_API.Get(company_, tax_source_rec_.tax_code);
      Message_SYS.Add_Attribute(msg_, 'TAX_ITEM_ID', tax_source_rec_.tax_item_id);
      Message_SYS.Add_Attribute(msg_, 'TAX_CALC_STRUCTURE_ID', tax_source_rec_.tax_calc_structure_id);
      Message_SYS.Add_Attribute(msg_, 'TAX_CALC_STRUCTURE_ITEM_ID', tax_source_rec_.tax_calc_structure_item_id);
      Message_SYS.Add_Attribute(msg_, 'TAX_CODE', tax_source_rec_.tax_code);
      Message_SYS.Add_Attribute(msg_, 'TAX_PERCENTAGE', tax_source_rec_.tax_percentage);
      Message_SYS.Add_Attribute(msg_, 'TAX_TYPE_DB', tax_rec_.fee_type);
      Message_SYS.Add_Attribute(msg_, 'TAX_TYPE', Fee_Type_API.Decode(tax_rec_.fee_type));
      Message_SYS.Add_Attribute(msg_, 'TOTAL_TAX_CURR_AMOUNT', tax_source_rec_.tax_curr_amount + tax_source_rec_.non_ded_tax_curr_amount);
      Message_SYS.Add_Attribute(msg_, 'TOTAL_TAX_DOM_AMOUNT', tax_source_rec_.tax_dom_amount + tax_source_rec_.non_ded_tax_dom_amount);
      Message_SYS.Add_Attribute(msg_, 'TOTAL_TAX_PARALLEL_AMOUNT', NVL(tax_source_rec_.tax_parallel_amount + tax_source_rec_.non_ded_tax_parallel_amount, 0));
      Message_SYS.Add_Attribute(msg_, 'TAX_CURR_AMOUNT', tax_source_rec_.tax_curr_amount);
      Message_SYS.Add_Attribute(msg_, 'TAX_DOM_AMOUNT', tax_source_rec_.tax_dom_amount);
      Message_SYS.Add_Attribute(msg_, 'TAX_PARALLEL_AMOUNT', NVL(tax_source_rec_.tax_parallel_amount, 0));
      Message_SYS.Add_Attribute(msg_, 'TAX_BASE_CURR_AMOUNT', tax_source_rec_.tax_base_curr_amount);
      Message_SYS.Add_Attribute(msg_, 'TAX_BASE_DOM_AMOUNT', tax_source_rec_.tax_base_dom_amount);
      Message_SYS.Add_Attribute(msg_, 'TAX_BASE_PARALLEL_AMOUNT', NVL(tax_source_rec_.tax_base_parallel_amount, 0));
      Message_SYS.Add_Attribute(msg_, 'NON_DED_TAX_CURR_AMOUNT', tax_source_rec_.non_ded_tax_curr_amount);
      Message_SYS.Add_Attribute(msg_, 'NON_DED_TAX_DOM_AMOUNT', tax_source_rec_.non_ded_tax_dom_amount);
      Message_SYS.Add_Attribute(msg_, 'NON_DED_TAX_PARALLEL_AMOUNT', NVL(tax_source_rec_.non_ded_tax_parallel_amount, 0));
      Message_SYS.Add_Attribute(msg_, 'TAX_CODE_DOM_AMOUNT_LIMIT', NVL(tax_rec_.tax_amt_limit,0));
      Message_SYS.Add_Attribute(msg_, 'TAX_LIMIT_CURR_AMOUNT', tax_source_rec_.tax_limit_curr_amount);
      Message_SYS.Add_Attribute(msg_, 'TRANSFERRED', tax_source_rec_.transferred);
      Message_SYS.Add_Attribute(msg_, 'DEDUCTIBLE_PERCENTAGE', tax_rec_.deductible);
   END IF;
END Add_To_Tax_Message;
