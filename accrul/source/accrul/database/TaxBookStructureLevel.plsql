-----------------------------------------------------------------------------
--
--  Logical unit: TaxBookStructureLevel
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  281002  SHSALK SALSA-IID ITFI101E Created. 
--    121207   Maaylk  PEPA-183, Removed global variable
--  060720  CHAULK LCS 154656 - Created Delete_Bottom_Level__.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT TAX_BOOK_STRUCTURE_LEVEL_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   top_node_name_ VARCHAR2(10);
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   objversion_ := to_char(newrec_.rowversion,'YYYYMMDDHH24MISS');
   
   BEGIN
      UPDATE tax_book_structure_level_tab
         SET level_above = newrec_.level_id
         WHERE company = newrec_.company
         AND   structure_id = newrec_.structure_id
         AND   NVL(level_above,chr(0)) = NVL(newrec_.level_above,chr(0))
         AND   level_id != newrec_.level_id;
      EXCEPTION WHEN OTHERS THEN NULL;
   END;
   top_node_name_ := Client_SYS.Get_Item_Value('TOP_NODE_NAME',attr_);
   IF top_node_name_ IS NOT NULL THEN
      Tax_Book_Structure_Item_API.Create_Top_Node( newrec_.company, newrec_.structure_id,
         top_node_name_, '');
   END IF;
   Client_SYS.Clear_Attr(attr_);

EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN TAX_BOOK_STRUCTURE_LEVEL_TAB%ROWTYPE )
IS
   tmp_ NUMBER;
   CURSOR botem_level IS
      SELECT   1
         FROM  tax_book_structure_tab
         WHERE company = remrec_.company
         AND   structure_id = remrec_.structure_id;

BEGIN
   IF remrec_.bottom_level IS NOT NULL THEN
      OPEN botem_level;
      FETCH botem_level INTO tmp_;
      IF (botem_level%FOUND) THEN
         CLOSE botem_level;
         Error_SYS.Record_General(lu_name_, 'DONTDELBOTLEVEL: The bottom level must not be deleted');
      END IF;
      CLOSE botem_level;
   END IF;

   super(objid_, remrec_);

   UPDATE tax_book_structure_level_tab
      SET level_above = remrec_.level_above
      WHERE company = remrec_.company
      AND   structure_id = remrec_.structure_id
      AND   level_above = remrec_.level_id;


END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_book_structure_level_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
   tmp_   NUMBER;
   top_node_name_ VARCHAR2(10);

   CURSOR bottom_exist IS
      SELECT 1
         FROM TAX_BOOK_STRUCTURE_LEVEL_TAB
         WHERE company = newrec_.company
         AND structure_id = newrec_.structure_id
         AND bottom_level IS NOT NULL;

   CURSOR connected_items IS
      SELECT 1
         FROM tax_book_structure_item
         WHERE company = newrec_.company AND structure_id = newrec_.structure_id;

BEGIN
   top_node_name_ := Client_SYS.Cut_Item_Value('TOP_NODE_NAME',attr_);
   super(newrec_, indrec_, attr_);
   
   IF newrec_.level_above IS NOT NULL THEN                                                                                                                                          
      Exist(newrec_.company, newrec_.structure_id, newrec_.level_above);
   END IF;
   

      -- Only ONE record must have the flag BOTTOM_LEVEL set to not null

   IF newrec_.bottom_level IS NOT NULL THEN
      OPEN bottom_exist;
      FETCH bottom_exist INTO tmp_;
      IF (bottom_exist%FOUND) THEN
         CLOSE bottom_exist;
         Error_SYS.Record_General(lu_name_, 'BOTTOMEXISTS: Bottom level already exists');
      END IF;
      CLOSE bottom_exist;
   END IF;

      -- Check if there are any items connected to this structure

   OPEN connected_items;
   FETCH connected_items INTO tmp_;
   IF (connected_items%FOUND) THEN
      CLOSE connected_items;
      IF top_node_name_ IS NULL THEN
         Error_SYS.Record_General( lu_name_, 'NOTOPNODE: A top node name must be specified when levels' ||
            ' are created at the top and the structure has nodes defined');
      END IF;
   ELSE
      CLOSE connected_items;
      top_node_name_ := NULL;
   END IF;
   
   IF top_node_name_ IS NOT NULL THEN
      Client_SYS.Add_To_Attr('TOP_NODE_NAME', top_node_name_, attr_);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     tax_book_structure_level_tab%ROWTYPE,
   newrec_ IN OUT tax_book_structure_level_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_  VARCHAR2(30);
   value_ VARCHAR2(4000);
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', newrec_.company);
   Error_SYS.Check_Not_Null(lu_name_, 'STRUCTURE_ID', newrec_.structure_id);
   Error_SYS.Check_Not_Null(lu_name_, 'LEVEL_ID', newrec_.level_id);

EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Fetch_As_String__ (
   attr_      OUT VARCHAR2,
   company_   IN  VARCHAR2,
   structure_id_ IN  VARCHAR2 )
IS
   tmp_attr_ VARCHAR2( 999);
   CURSOR get_record IS
      SELECT     *
      FROM       TAX_BOOK_STRUCTURE_LEVEL_TAB
      WHERE      company      = company_
      AND        structure_id = structure_id_;

BEGIN
   tmp_attr_ := NULL;
   FOR rec_ IN get_record LOOP
      tmp_attr_ := tmp_attr_ || rec_.level_id || chr(31) || rec_.description || chr(30);
   END LOOP;
   attr_ := tmp_attr_;
END Fetch_As_String__;


PROCEDURE Store_As_String__ (
   company_       IN VARCHAR2,
   structure_id_  IN VARCHAR2,
   attr_          IN VARCHAR2 )
IS
   tmp_         VARCHAR2(2000);
   level_id_    TAX_BOOK_STRUCTURE_LEVEL_TAB.level_id%TYPE;
   description_ TAX_BOOK_STRUCTURE_LEVEL_TAB.description%TYPE;
   old_         VARCHAR2(2000);
   old_id_      TAX_BOOK_STRUCTURE_LEVEL_TAB.level_id%TYPE;
   old_desc_    TAX_BOOK_STRUCTURE_LEVEL_TAB.description%TYPE;
   rec_         TAX_BOOK_STRUCTURE_LEVEL_TAB%ROWTYPE;
   remrec2_     TAX_BOOK_STRUCTURE_LEVEL_TAB%ROWTYPE;
   new_attr_    VARCHAR2(2000);
   level_above_ TAX_BOOK_STRUCTURE_LEVEL_TAB.level_above%TYPE := NULL;
   objid_       TAX_BOOK_STRUCTURE_LEVEL.objid%TYPE;
   objversion_  TAX_BOOK_STRUCTURE_LEVEL.objversion%TYPE;
   indrec_      Indicator_Rec;
   
   CURSOR rem_record IS
      SELECT *
      FROM   TAX_BOOK_STRUCTURE_LEVEL
      WHERE  company = company_
      AND    structure_id = structure_id_
      AND    level_id = level_id_
      AND    INSTR( chr(30)||attr_, chr(30)||level_id||chr(31)) = 0
      AND    bottom_level IS NULL;
BEGIN

      -- Remove levels that doesn't exist any longer

   FOR remrec_ IN rem_record LOOP
      remrec2_ := Get_Object_By_Keys___( company_, structure_id_, level_id_);
      Check_Delete___( remrec2_);
      Delete___( remrec_.objid, remrec2_);
   END LOOP;

      -- Loop through all levels, and modify descriptions or insert new levels

   Fetch_As_String__( old_, company_, structure_id_);
   tmp_ := attr_;

   WHILE tmp_ IS NOT NULL LOOP
      level_id_ := SUBSTR( tmp_, 1, INSTR( tmp_, chr(31)) - 1);
      old_id_   := SUBSTR( old_, 1, INSTR( old_, chr(31)) - 1);

      description_ := SUBSTR( tmp_, FINANCE_LIB_API.Fin_Length( level_id_) + 2, INSTR( tmp_, chr(30)) - FINANCE_LIB_API.Fin_Length( level_id_) - 2);
      old_desc_    := SUBSTR( old_, FINANCE_LIB_API.Fin_Length( old_id_)   + 2, INSTR( old_, chr(30)) - FINANCE_LIB_API.Fin_Length( old_id_)   - 2);

      tmp_ := SUBSTR( tmp_, INSTR( tmp_||chr(30), chr(30)) + 1);

      IF level_id_ = old_id_ THEN
         IF NVL(description_,chr(1)) != NVL(old_desc_,chr(1)) THEN
            rec_ := Lock_By_Keys___( company_, structure_id_, level_id_);
            Client_SYS.Clear_Attr( new_attr_);
            Client_SYS.Add_To_Attr( 'DESCRIPTION', description_, new_attr_);
            Get_Id_Version_By_Keys___( objid_, objversion_, company_, structure_id_, level_id_);
            Unpack___(rec_, indrec_, new_attr_);
            Check_Update___(rec_, rec_, indrec_, new_attr_); 
            Update___( objid_, rec_, rec_, new_attr_,objversion_);
         END IF;
         old_ := SUBSTR( old_, INSTR( old_||chr(30), chr(30)) + 1);
      ELSE
         Client_SYS.Clear_Attr( new_attr_);
         Client_SYS.Add_To_Attr( 'COMPANY', company_, new_attr_);
         Client_SYS.Add_To_Attr( 'STRUCTURE_ID', structure_id_, new_attr_);
         Client_SYS.Add_To_Attr( 'LEVEL_ID', level_id_, new_attr_);
         Client_SYS.Add_To_Attr( 'DESCRIPTION', description_, new_attr_);
         Client_SYS.Add_To_Attr( 'LEVEL_ABOVE', level_above_, new_attr_);
         Unpack___(rec_, indrec_, new_attr_);
         Check_Insert___(rec_, indrec_, new_attr_);         
         Insert___( objid_, objversion_, rec_, new_attr_);
      END IF;
      level_above_ := level_id_;
   END LOOP;

      -- Validate...
   Fetch_As_String__( tmp_, company_, structure_id_);
   IF old_ IS NOT NULL OR tmp_ != attr_ THEN
      Error_SYS.Record_Modified(lu_name_);
   END IF;
END Store_As_String__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Create_Bottom_Level (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2 )
IS
   attr_        VARCHAR2( 99);
   objid_       TAX_BOOK_STRUCTURE_LEVEL.objid%TYPE;
   objversion_  TAX_BOOK_STRUCTURE_LEVEL.objversion%TYPE;
   newrec_      TAX_BOOK_STRUCTURE_LEVEL_TAB%ROWTYPE;
   indrec_      Indicator_Rec;
BEGIN
   Client_SYS.Clear_Attr( attr_);
   Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr( 'STRUCTURE_ID', structure_id_, attr_);
   Client_SYS.Add_To_Attr( 'LEVEL_ID','TAX BOOK',attr_);   
   Client_SYS.Add_To_Attr( 'BOTTOM_LEVEL', 'X', attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END Create_Bottom_Level;


@UncheckedAccess
FUNCTION Get_Level_Name (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   level_position_ IN NUMBER ) RETURN VARCHAR2
IS
   CURSOR cur IS
      SELECT     level_id
      FROM       tax_book_structure_level_tab
      WHERE      company      = company_
      AND        structure_id = structure_id_
      AND        level        = level_position_
      START WITH level_above  IS NULL
      CONNECT BY company      = PRIOR company
      AND        structure_id = PRIOR structure_id
      AND        level_above  = PRIOR level_id;
   level_id_ TAX_BOOK_STRUCTURE_LEVEL_TAB.level_id%TYPE;
BEGIN
   OPEN cur;
   FETCH cur INTO level_id_;
   IF cur%NOTFOUND THEN
      level_id_ := NULL;
   END IF;
   CLOSE cur;
   RETURN level_id_;
END Get_Level_Name;


@UncheckedAccess
FUNCTION Get_Level_Position (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   level_id_ IN VARCHAR2 ) RETURN NUMBER
IS
   ret_ NUMBER;
   CURSOR pos IS
      SELECT     LEVEL
      FROM       tax_book_structure_level_tab
      WHERE      company = company_
      AND        structure_id = structure_id_
      AND        level_id = level_id_
      START WITH level_above    IS NULL
      CONNECT BY company      = PRIOR company
      AND        structure_id = PRIOR structure_id
      AND        level_above  = PRIOR level_id;
BEGIN
   OPEN pos;
   FETCH pos INTO ret_;
   IF pos%NOTFOUND THEN
      ret_ := NULL;
   END IF;
   CLOSE pos;
   RETURN ret_;
END Get_Level_Position;


@UncheckedAccess
FUNCTION Get_Top_Level (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   top_level_id_ TAX_BOOK_STRUCTURE_LEVEL_TAB.level_id%TYPE;
   CURSOR cur IS
      SELECT level_id
      FROM   TAX_BOOK_STRUCTURE_LEVEL_TAB
      WHERE  company = company_
      AND    structure_id = structure_id_
      AND    level_above IS NULL;
BEGIN
   OPEN cur;
   FETCH cur INTO top_level_id_;
   CLOSE cur;
   RETURN top_level_id_;
END Get_Top_Level;


@UncheckedAccess
FUNCTION Get_Bottom_Level (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   bottom_level_id_ TAX_BOOK_STRUCTURE_LEVEL_TAB.level_id%TYPE;
   CURSOR cur IS
      SELECT level_id
      FROM   TAX_BOOK_STRUCTURE_LEVEL_TAB
      WHERE  company = company_
      AND    structure_id = structure_id_
      AND    bottom_level IS NOT NULL;
BEGIN
   OPEN cur;
   FETCH cur INTO bottom_level_id_;
   CLOSE cur;
   RETURN bottom_level_id_;
END Get_Bottom_Level;

--This method is to be used by Aurena
FUNCTION Is_Level_Above_Exist (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   level_above_   IN VARCHAR2) RETURN VARCHAR2
IS
   temp_                   NUMBER;
   CURSOR check_level_above IS
      SELECT 1
      FROM  tax_book_structure_level_tab
      WHERE company      = company_
      AND   structure_id = structure_id_
      AND   level_above  = level_above_;
BEGIN
   OPEN  check_level_above;
   FETCH check_level_above INTO temp_;
   IF check_level_above%FOUND THEN
      CLOSE check_level_above;
      RETURN 'TRUE';
   END IF;
   CLOSE check_level_above;
   RETURN 'FALSE';
END Is_Level_Above_Exist;

@ServerOnlyAccess
PROCEDURE Delete_Bottom_Level__ (
    company_      IN VARCHAR2,
    structure_id_ IN VARCHAR2)  
IS
   tmp_                   NUMBER;
   CURSOR botem_level IS
      SELECT count(level_id)
      FROM   tax_book_structure_level_tab
      WHERE  company = company_
      AND    structure_id = structure_id_;
BEGIN   
   OPEN  botem_level;
   FETCH botem_level INTO tmp_;
   IF (botem_level%FOUND) THEN
         CLOSE botem_level;
      IF (tmp_ = 1)THEN
         DELETE
            FROM  tax_book_structure_level_tab
            WHERE company = company_
            AND   structure_id = structure_id_
            AND   bottom_level = 'X';
      END IF;
   ELSE
      CLOSE botem_level;
   END IF;
END Delete_Bottom_Level__;
