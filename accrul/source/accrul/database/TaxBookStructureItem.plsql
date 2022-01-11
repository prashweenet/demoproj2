-----------------------------------------------------------------------------
--
--  Logical unit: TaxBookStructureItem
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  281002  SHSALK SALSA-IID ITFI101E Created.
--  030328  RISRLK IID RDFI140NF. Modified the Db_Values.
--  131101  Umdolk PBFI-2104, Refactoring
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Record___ (
   newrec_         IN TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE )
IS
   tmp_            NUMBER;
   CURSOR top_node IS
      SELECT   1
         FROM  TAX_BOOK_STRUCTURE_ITEM_TAB
         WHERE company       = newrec_.company
         AND   structure_id  = newrec_.structure_id
         AND   name_value   != newrec_.name_value
         AND   level_id      = newrec_.level_id
         AND   item_above   IS NULL;

   CURSOR check_node IS
      SELECT   1
         FROM  TAX_BOOK_STRUCTURE_ITEM_TAB
         WHERE company       = newrec_.company
         AND   structure_id  = newrec_.structure_id
         AND   name_value   != newrec_.name_value
         AND   item_above   IS NULL;

BEGIN
   IF  newrec_.structure_item_type = 'NODE' THEN
         -- Node --
      IF newrec_.level_id = Tax_Book_Structure_Level_API.Get_Bottom_Level( newrec_.company, newrec_.structure_id) THEN
         Error_SYS.Record_general( lu_name_, 'INVLEVEL1: Nodes must NOT be connected to the bottom level');
      END IF;

      IF newrec_.item_above IS NULL THEN
         OPEN  check_node;
         FETCH check_node INTO tmp_;
         CLOSE check_node;
         IF Tax_Book_Structure_Level_API.Get_Level_Position( newrec_.company, newrec_.structure_id, newrec_.level_id) != 1 THEN
            IF (NVL(tmp_, 0) = 0) THEN
               Error_SYS.Record_general( lu_name_, 'NOTOP: Top Node must be defined at Top Level');
            ELSE
               Error_SYS.Check_Not_Null( lu_name_, 'ITEM_ABOVE', '');
            END IF;
         END IF;
         OPEN  top_node;
         FETCH top_node INTO tmp_;
         IF (top_node%FOUND) THEN
            CLOSE top_node;
            Error_SYS.Record_general( lu_name_, 'DUPTOPNODES: Only one top node allowed');
         END IF;
         CLOSE top_node;
      ELSE
         IF Tax_Book_Structure_Level_API.Get_Level_Position( newrec_.company, newrec_.structure_id, newrec_.level_id) <=
            Tax_Book_Structure_Level_API.Get_Level_Position( newrec_.company, newrec_.structure_id,
            Get_Level_Id( newrec_.company, newrec_.structure_id, newrec_.item_above)) THEN
            Error_SYS.Record_General( lu_name_, 'INVLEVEL3: The Node must NOT be on the same or higher level as its parent');
         END IF;
      END IF;
   ELSE

      IF newrec_.level_id != Tax_Book_Structure_Level_API.Get_Bottom_Level( newrec_.company, newrec_.structure_id) THEN
         Error_SYS.Record_general( lu_name_, 'INVLEVEL2: Code Part values must be connected to the bottom level');
      END IF;

      SELECT COUNT(*) INTO tmp_
      FROM   TAX_BOOK_STRUCTURE_ITEM_TAB
      WHERE  company      = newrec_.company
      AND    structure_id = newrec_.structure_id
      AND    name_value   = newrec_.item_above;
      IF tmp_ != 1 THEN
         Error_SYS.Record_General( lu_name_, 'INVNODEABOVE1: Node above does not exist');
      END IF;
   END IF;
END Validate_Record___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   IF newrec_.item_above IS NULL THEN
      BEGIN
         UPDATE   tax_book_structure_item_tab
            SET   item_above    = newrec_.name_value
            WHERE company       = newrec_.company
            AND   structure_id  = newrec_.structure_id
            AND   name_value   != newrec_.name_value
            AND   item_above   IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
      END;
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
        Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE )
IS
   tmp_         NUMBER;

   CURSOR item_used IS
      SELECT 1
      FROM   TAX_BOOK_STRUCTURE_ITEM_TAB
      WHERE  company      = remrec_.company
      AND    structure_id = remrec_.structure_id
      AND    item_above   = remrec_.name_value;
BEGIN   
   OPEN item_used;
   FETCH item_used INTO tmp_;
   IF (item_used%FOUND) THEN
      CLOSE item_used;
      Error_Sys.Appl_General(lu_name_, 'ITEMUSED: Node :P1 is used within the structure :P2',remrec_.name_value,remrec_.structure_id  );
   END IF;
   CLOSE item_used;
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     tax_book_structure_item_tab%ROWTYPE,
   newrec_ IN OUT tax_book_structure_item_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF(newrec_.structure_item_type = 'TAXBOOK') THEN
      newrec_.description := Tax_Book_API.Get_Description(newrec_.company,newrec_.name_value);
   END IF;
   super(oldrec_, newrec_, indrec_, attr_);
   IF (indrec_.item_above) THEN
      IF (newrec_.item_above IS NOT NULL) THEN
         Tax_Book_Structure_Item_API.Exist(newrec_.company, newrec_.structure_id,newrec_.item_above);
      END IF;
   END IF;
   Validate_Record___( newrec_);
END Check_Common___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT tax_book_structure_item_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);    
   
   IF (indrec_.structure_item_type) THEN
      IF (newrec_.structure_item_type = 'TAXBOOK') THEN
         Tax_Book_API.Exist(newrec_.company,newrec_.name_value);
      END IF;
      Tax_Book_Struc_Item_Type_API.Exist_Db(newrec_.structure_item_type);
   END IF;   
END Check_Insert___;

@Override
PROCEDURE Raise_Record_Not_Exist___ (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   name_value_ IN VARCHAR2 )
IS
BEGIN   
   Error_SYS.Record_Not_Exist(lu_name_, 'NDNOTEXISTB: Tax Book Structure Node ":P1" does not exist',
      name_value_ );
   super(company_, structure_id_, name_value_);   
END Raise_Record_Not_Exist___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Create_Top_Node (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   name_value_   IN VARCHAR2,
   description_  IN VARCHAR2 )
IS
   attr_         VARCHAR2(999);
   rec_          TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE;
   objid_        TAX_BOOK_STRUCTURE_ITEM.OBJID%TYPE;
   objversion_   TAX_BOOK_STRUCTURE_ITEM.OBJVERSION%TYPE;
   indrec_       Indicator_Rec;
BEGIN
      Client_SYS.Clear_Attr( attr_);
      Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr( 'STRUCTURE_ID', structure_id_, attr_);
      Client_SYS.Add_To_Attr( 'NAME_VALUE', name_value_, attr_);
      Client_SYS.Add_To_Attr( 'DESCRIPTION', description_, attr_);
      Client_SYS.Add_To_Attr( 'LEVEL_ID', Tax_Book_Structure_Level_API.Get_Level_Name(
      company_, structure_id_, 1), attr_);
      Client_SYS.Add_To_Attr( 'STRUCTURE_ITEM_TYPE', Tax_Book_Struc_Item_Type_API.Decode('NODE'), attr_);
      indrec_ := Get_Indicator_Rec___(rec_);
      Check_Insert___(rec_, indrec_, attr_);
      Insert___( objid_, objversion_, rec_, attr_);
END Create_Top_Node;


@UncheckedAccess
FUNCTION Get_Node_Level (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   name_value_   IN VARCHAR2 ) RETURN VARCHAR2
IS
   level_ VARCHAR2(10);
   CURSOR getnode IS
      SELECT level_id
      FROM   TAX_BOOK_STRUCTURE_ITEM_TAB
      WHERE  company      = company_
      AND    structure_id = structure_id_
      AND    name_value   = name_value_;
BEGIN
   OPEN   getnode;
   FETCH  getnode INTO level_;
   CLOSE  getnode;
   RETURN level_;
END Get_Node_Level;




@UncheckedAccess
FUNCTION Get_Node_Name (
   company_          IN VARCHAR2,
   structure_id_     IN VARCHAR2,
   level_id_         IN VARCHAR2,
   code_part_value_  IN VARCHAR2 ) RETURN VARCHAR2
IS
   node_name_ VARCHAR2(2000);
-- This cursor traverses the tree from leaf node upwards
   CURSOR node_name IS
      SELECT name_value
      FROM   TAX_BOOK_STRUCTURE_ITEM_TAB
      WHERE  company        = company_
      AND    structure_id   = structure_id_
      AND    level_id       = level_id_
      START WITH name_value = code_part_value_
      CONNECT by company    = PRIOR company
      AND     structure_id  = PRIOR structure_id
      AND     name_value    = PRIOR item_above;
BEGIN
   OPEN  node_name;
   FETCH node_name INTO node_name_;
   IF node_name%NOTFOUND THEN
      node_name_ := NULL;
   END IF;
   CLOSE  node_name;
   RETURN node_name_;
END Get_Node_Name;




@UncheckedAccess
FUNCTION Get_Top_Node (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   top_  VARCHAR2(10);
   CURSOR getTop IS
      select name_value
      from   tax_book_structure_item_tab
      where  company      = company_
      AND    structure_id = structure_id_
      AND    item_above IS NULL;
BEGIN
   OPEN   getTop;
   FETCH  getTop INTO top_;
   CLOSE  getTop;
   RETURN top_;
END Get_Top_Node;



@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Move_Branch (
   company_ IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   source_item_ IN VARCHAR2,
   target_item_ IN VARCHAR2 )
IS
   oldrec_        TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE;
   newrec_        TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE;
   level_id_      VARCHAR2(10);
   attr_          VARCHAR2(2000);
   objid_         TAX_BOOK_STRUCTURE_ITEM.OBJID%TYPE;
   objversion_    TAX_BOOK_STRUCTURE_ITEM.OBJVERSION%TYPE;

   CURSOR get_level_below IS
      select level_id
      from   TAX_BOOK_STRUCTURE_LEVEL_TAB
      where  company      = company_
      AND    structure_id = structure_id_
      AND    level_above  = level_id_;

BEGIN
   newrec_ := Get_Object_By_Keys___(company_, structure_id_, source_item_);

   newrec_.item_above := target_item_;
   IF (newrec_.structure_item_type = 'NODE') THEN -- IF it is a node
      level_id_ := Get_Level_Id(company_, structure_id_, target_item_);
      OPEN   get_level_below;
      FETCH  get_level_below INTO level_id_;
      CLOSE  get_level_below;
      newrec_.level_id := level_id_;
   END IF;
   Validate_Record___( newrec_ );
   Update___ ( objid_, oldrec_, newrec_, attr_,objversion_, TRUE );
END Move_Branch;

-- This metod is to be used by Aurena
FUNCTION Get_Node_Count (
   company_          IN VARCHAR2,
   structure_id_     IN VARCHAR2) RETURN NUMBER
IS
   node_count_ NUMBER;
   
   CURSOR node_count IS
      SELECT count(*)
      FROM   TAX_BOOK_STRUCTURE_ITEM_TAB
      WHERE  company             = company_
      AND    structure_id        = structure_id_
      AND    structure_item_type = 'NODE';
BEGIN
   OPEN  node_count;
   FETCH node_count INTO node_count_;
   IF node_count%NOTFOUND THEN
      node_count_ := 0;
   END IF;
   CLOSE  node_count;
   RETURN node_count_;
END Get_Node_Count;

-- This metod is to be used by Aurena
PROCEDURE Add_Branch (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   source_node_  IN VARCHAR2,
   new_item_     IN VARCHAR2 )
IS
   attr_          VARCHAR2(2000);
   newrec_        TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE;
   objid_         TAX_BOOK_STRUCTURE_ITEM.objid%TYPE;
   objversion_    TAX_BOOK_STRUCTURE_ITEM.objversion%TYPE;
   indrec_        Indicator_Rec;
      
BEGIN
   Client_SYS.Clear_Attr( attr_);
   Client_SYS.Add_To_Attr('COMPANY',  company_, attr_);
   Client_SYS.Add_To_Attr('STRUCTURE_ID', structure_id_, attr_);
   Client_SYS.Add_To_Attr('NAME_VALUE', new_item_, attr_);
   Client_SYS.Add_To_Attr('DESCRIPTION', Tax_Book_API.Get_Description(company_, new_item_), attr_);
   Client_SYS.Add_To_Attr('ITEM_ABOVE', source_node_, attr_);
   Client_SYS.Add_To_Attr('STRUCTURE_ITEM_TYPE_DB', 'TAXBOOK', attr_);
   Client_SYS.Add_To_Attr('LEVEL_ID', Tax_Book_Structure_Level_API.Get_Bottom_Level(company_, structure_id_), attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END Add_Branch;

-- This metod is to be used by Aurena
PROCEDURE Del_Branch (
   company_      IN VARCHAR2,
   structure_id_ IN VARCHAR2,
   del_item_     IN VARCHAR2)
IS
   remrec_        TAX_BOOK_STRUCTURE_ITEM_TAB%ROWTYPE;
   objid_         TAX_BOOK_STRUCTURE_ITEM.objid%TYPE;
   objversion_    TAX_BOOK_STRUCTURE_ITEM.objversion%TYPE;    
BEGIN
   Exist(company_, structure_id_, del_item_);
   Get_Id_Version_By_Keys___(objid_, objversion_, company_, structure_id_, del_item_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Del_Branch;

