-----------------------------------------------------------------------------
--
--  Logical unit: CostStructureItem
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  160620  KGAMLK   FINLIFE-45, Moved ProjCostStructureItem to ACCRUL as CostStructureItem, Changes in plsql logic.
--  130724  SAALLK   Bug 111115, Fixed translation issue (missing fullstop) in NODEUSEDONPROJ constant.
--  130121  JEGUSE   Bug 107348, Merged Budget and Forecast Revenue.
--                   Added new views PROJ_STRUCTURE_COST_TYPE_LOV and PROJ_STRUCTURE_REV_TYPE_LOV
--  120324  Chselk   EASTRTM-4404. Modified check_node cursor in Validate_Record___.
--  110919  Disklk   EASTTWO-13238, Removed L flag for proj_cost_struct_item_type_db in view comments PROJ_COST_STRUCTURE_ITEM_LOV.
--  110613  Ersruk   Performance improved in Change_Level_Id(), Move_Branch().
--  110518  Ersruk   Modified Change_Level_Id() and Update_Level_Id().
--  110412  Chselk   EASTONE-15255. Modified Move_Branch to fetch the correct level_id relavant to level_no.
--  110221  THTHLK  HIGHPK-6967, Added Update_Level_Id().
--  101209  Ersruk   Added function Check_Cost_Element_Exist().
--  101203  Janslk   Added function Check_Exist.
--  101201  Ersruk   Added the function Check_Node_Exist()
--  101118  Vwloza  HIGHPK-3382, technical correction.
--  101007  Ersruk   Added Get_Cost_Struct_Item_Type().
--  100923  THTHLK   Added New View PROJ_COST_STRUCTURE_ITEM_LOV
--  100825  Ersruk   Added level_id.
--  100719  Ersruk   Added Change_Level_Id() and Get_Parent_Plus_Level_Id().
--  100712  Janslk   Changed Check_Delete___ not to delete the top node.
--  100707  Janslk   Changed Validate_Record___ to apply level validations only for Node type nodes.
--  100624  Janslk   Changed Modify__ and Update___ to update item_above of children records
--                   if the name_value is changed.
--  100623  Janslk   Changed the view column struct_level in PROJ_COST_STRUCTURE_ITEM_DISP.
--                   Removed the connect by prior in the same view. Changed Validate_Record_to
--                   add validations for level positions for items.__
--  100518  Ersruk   Renamed STRUCTURE_ID to COST_STRUCTURE_ID
--  100514  Janslk   Renamed cbs_item_type to PROJ_COST_STRUCT_ITEM_TYPE.
--  100514  Janslk   Changed all places where COSTELEMENT type isued to replace it with COST_ELEMENT.
--  100505  Ersruk   Created
--  270918  Jadulk   FIUXX-1687 Added Modify_Structure_Item
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Record___ (
   newrec_         IN cost_structure_item_tab%ROWTYPE,
   old_name_value_ IN VARCHAR2 DEFAULT NULL )
IS
   tmp_               NUMBER;
   level_id_          VARCHAR2(20);
   name_value_        cost_structure_item_tab.name_value%TYPE;
   parent_level_no_   cost_structure_item_tab.level_no%TYPE;
   parent_level_id_   VARCHAR2(20);
   project_id_        VARCHAR2(10);

   CURSOR check_node IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company = newrec_.company
      AND    cost_structure_id          = newrec_.cost_structure_id
      AND    name_value                != name_value_
      AND    cost_struct_item_type = 'NODE'
      AND    item_above                 IS NULL;

   CURSOR check_item_above IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company                    = newrec_.company
      AND    cost_structure_id          = newrec_.cost_structure_id
      AND    name_value                 = newrec_.item_above
      AND    cost_struct_item_type = 'NODE';

BEGIN
   Cost_Structure_API.Validate_Changing_Structure (newrec_.company, newrec_.cost_structure_id);
   IF (newrec_.cost_struct_item_type = 'COST_ELEMENT') THEN
      IF (Cost_Structure_API.Get_Single_Project(newrec_.company, newrec_.cost_structure_id) = 'TRUE') THEN
         $IF (Component_Projbf_SYS.INSTALLED) $THEN
            project_id_ := Cost_Structure_API.Get_Project_Id (newrec_.company, newrec_.cost_structure_id);
         $ELSE
            NULL;
         $END
      END IF;
      IF (project_id_ IS NOT NULL) THEN
         $IF (Component_Projbf_SYS.INSTALLED) $THEN
            Proj_Cost_El_Code_P_Dem_API.Exist (newrec_.company, newrec_.name_value, project_id_);
         $ELSE
            NULL;
         $END
      ELSE
         Project_Cost_Element_API.Exist (newrec_.company, newrec_.name_value, TRUE);
      END IF;
   END IF;
   IF (newrec_.cost_struct_item_type = 'NODE') THEN
      --Check for elements irrespective of Cost/Revenue or even Obsolete.
      IF (Project_Cost_Element_API.Check_Exist( newrec_.company, newrec_.name_value)='TRUE') THEN
         Error_SYS.Record_general (lu_name_, 'NODEEXISTCE: A Cost Element with the proposed name already exists in company :P1.', newrec_.company);
      END IF;
   END IF;
   name_value_ := nvl(old_name_value_, newrec_.name_value);
   --If item above is null---------------------------------
   IF (newrec_.item_above IS NULL) THEN
      --level_id_ := Proj_Cost_Structure_Level_API.Get_Level_Id(newrec_.company, newrec_.cost_structure_id, newrec_.level_no);
      OPEN  check_node;
      FETCH check_node INTO tmp_;
      CLOSE check_node;
      IF (NVL(tmp_, 0) = 0) THEN
         --This validation needs to be reviewed
         NULL;
      ELSE
         --If there is already exist top node (record with level above null) then item above column must have a value.
         Error_SYS.Check_Not_Null(lu_name_, 'ITEM_ABOVE', '');
      END IF;
   END IF;
   --If item above is not null-----------------------------
   IF (newrec_.item_above IS NOT NULL) THEN
      --Should be a node
      OPEN  check_item_above;
      FETCH check_item_above INTO tmp_;
      IF (check_item_above%NOTFOUND) THEN
         CLOSE check_item_above;
         Error_SYS.Record_general( lu_name_, 'NODEABOVEERR1: Node ID/Cost Element :P1 must be connected to a Node as Parent Node ID.', newrec_.name_value);
      END IF;
      CLOSE check_item_above;
      --Node cannot be connected to itself as parent node
      IF (newrec_.item_above = newrec_.name_value) THEN
         Error_SYS.Record_general( lu_name_, 'NODEABOVEERR2: Node ID :P1 cannot be connected to itself as Parent Node ID.', newrec_.name_value);
      END IF;
      --There must be a top node
      OPEN  check_node;
      FETCH check_node INTO tmp_;
      IF (check_node%NOTFOUND) THEN
         CLOSE check_node;
         Error_SYS.Record_general( lu_name_, 'TOPNODENOTEXIST: Parent Node ID should be null for top node.');
      END IF;
      CLOSE check_node;
      --Cannot connect a level higher than a level connected to the parent
       parent_level_no_ := Get_Level_No (newrec_.company,newrec_.cost_structure_id, newrec_.item_above, Cost_Struct_Item_Type_API.Decode('NODE'));
       parent_level_id_ := Cost_Structure_Level_API.Get_Level_Id (newrec_.company, newrec_.cost_structure_id, parent_level_no_);
       level_id_        := Cost_Structure_Level_API.Get_Level_Id (newrec_.company, newrec_.cost_structure_id, newrec_.level_no);
       IF (newrec_.cost_struct_item_type = 'NODE') THEN
          IF (Cost_Structure_Level_API.Get_Level_Position(newrec_.company, newrec_.cost_structure_id, level_id_) <=
             Cost_Structure_Level_API.Get_Level_Position(newrec_.company, newrec_.cost_structure_id, parent_level_id_)) THEN
             Error_SYS.Record_general( lu_name_, 'INVALIDLEVEL: Level cannot be a level lower than the level of the parent item.');
          END IF;
       END IF;
   END IF;
END Validate_Record___;


@Override
PROCEDURE Update___ (
   objid_         IN     VARCHAR2,
   oldrec_        IN     cost_structure_item_tab%ROWTYPE,
   newrec_        IN OUT cost_structure_item_tab%ROWTYPE,
   attr_          IN OUT VARCHAR2,
   objversion_    IN OUT VARCHAR2,
   by_keys_       IN     BOOLEAN DEFAULT FALSE )
IS
   old_name_value_       cost_structure_item_tab.name_value%TYPE;
   move_node_            VARCHAR2(5);
   from_change_level_id_ VARCHAR2(5) := FND_Boolean_API.DB_FALSE;
BEGIN
   move_node_            := Client_SYS.Get_Item_Value('MOVE_NODE',            attr_);
   from_change_level_id_ := Client_SYS.Get_Item_Value('FROM_CHANGE_LEVEL_ID', attr_);
   IF (move_node_ IS NULL AND oldrec_.name_value != newrec_.name_value) THEN
      move_node_         := FND_Boolean_API.DB_TRUE;
   END IF;
   IF (oldrec_.level_id != newrec_.level_id) AND (from_change_level_id_ = FND_Boolean_API.DB_FALSE) THEN
      Change_Level_Id (newrec_.company,
                       newrec_.cost_structure_id,
                       newrec_.name_value,
                       newrec_.cost_struct_item_type,
                       newrec_.level_id,
                       FALSE );
   END IF;
   old_name_value_ := oldrec_.name_value;

   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);

   IF (move_node_ = FND_Boolean_API.DB_TRUE) THEN
      UPDATE cost_structure_item_tab
         SET item_above     = newrec_.name_value
      WHERE  company           = newrec_.company
      AND    cost_structure_id = newrec_.cost_structure_id
      AND    item_above        = old_name_value_;
   END IF;
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN cost_structure_item_tab%ROWTYPE )
IS
   tmp_       NUMBER;
   CURSOR item_used IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company           = remrec_.company
      AND    cost_structure_id = remrec_.cost_structure_id
      AND    item_above        = remrec_.name_value;
BEGIN
   Cost_Structure_API.Validate_Changing_Structure (remrec_.company, remrec_.cost_structure_id);
   IF (remrec_.cost_struct_item_type = 'NODE') THEN
      OPEN item_used;
      FETCH item_used INTO tmp_;
      IF (item_used%FOUND) THEN
         CLOSE item_used;
         Error_Sys.Appl_General(lu_name_, 'ITEMUSED: Node :P1 is used within the structure :P2',remrec_.name_value,remrec_.cost_structure_id  );
      END IF;
      CLOSE item_used;
      IF (remrec_.item_above IS NULL) THEN
         Error_Sys.Appl_General(lu_name_, 'CANNOTDELTOPNODE: Top node cannot be deleted, the top node can only be deleted by deleting the structure.');
      END IF;
      super(remrec_);
   END IF;
END Check_Delete___;


PROCEDURE Validate_Modify_Delete___ (
   company_                    IN VARCHAR2,
   cost_structure_id_          IN VARCHAR2,
   name_value_                 IN VARCHAR2,
   cost_struct_item_type_ IN VARCHAR2 )
IS
   used_on_                       VARCHAR2(2000);
BEGIN
   $IF (Component_Projbf_SYS.INSTALLED) $THEN
      used_on_ := Project_Forecast_Item_API.Get_Node_Used (company_, cost_structure_id_, name_value_, cost_struct_item_type_);
      IF (used_on_ IS NOT NULL) THEN
         Error_SYS.Record_general( lu_name_, 'NODEUSEDONPROJ: There are forecast lines for project :P1 with CBS node :P2 used. Node cannot be changed/deleted.',used_on_, name_value_);
      END IF;
   $ELSE
      NULL;
   $END
END Validate_Modify_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT cost_structure_item_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   IF (newrec_.level_no IS NOT NULL) AND (newrec_.level_id IS NULL) THEN
      newrec_.level_id := Cost_Structure_Level_API.Get_Level_Id(newrec_.company, newrec_.cost_structure_id, newrec_.level_no);
   END IF;
   IF (newrec_.level_no IS NULL) AND (newrec_.level_id IS NOT NULL) THEN
      newrec_.level_no := Cost_Structure_Level_API.Get_Level_No(newrec_.company, newrec_.cost_structure_id, newrec_.level_id);
   END IF;
   --Retrieve type of cost/revenue element
   IF (newrec_.cost_struct_item_type != 'NODE') THEN
      newrec_.element_type := Project_Cost_Element_API.Get_Element_Type_Db( newrec_.company, newrec_.name_value);
   ELSE
      newrec_.element_type := NULL;
   END IF;

   super(newrec_, indrec_, attr_);

   IF (indrec_.level_id AND newrec_.level_id IS NOT NULL) THEN
      Cost_Structure_Level_API.Exist_Level_Id(newrec_.company, newrec_.cost_structure_id, newrec_.level_id);
   END IF;
   Validate_Record___( newrec_ );
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_    IN     cost_structure_item_tab%ROWTYPE,
   newrec_    IN OUT cost_structure_item_tab%ROWTYPE,
   indrec_    IN OUT Indicator_Rec,
   attr_      IN OUT VARCHAR2 )
IS
   old_name_value_   cost_structure_item_tab.name_value%TYPE;
BEGIN
   old_name_value_ := oldrec_.name_value;
   IF (indrec_.level_id) THEN
      newrec_.level_no := Cost_Structure_Level_API.Get_Level_No(newrec_.company, newrec_.cost_structure_id, newrec_.level_id);
   END IF;
   --Retrieve type of cost/revenue element
   IF (newrec_.cost_struct_item_type != 'NODE') THEN
      newrec_.element_type := Project_Cost_Element_API.Get_Element_Type_Db( newrec_.company, newrec_.name_value);
   ELSE
      newrec_.element_type := NULL;
   END IF;

   super(oldrec_, newrec_, indrec_, attr_);

   IF (indrec_.level_id AND newrec_.level_id IS NOT NULL) THEN
      Cost_Structure_Level_API.Exist_Level_Id(newrec_.company, newrec_.cost_structure_id, newrec_.level_id);
   END IF;
   Validate_Record___( newrec_, old_name_value_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE New_Node__(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   name_value_        IN VARCHAR2,
   description_       IN VARCHAR2,
   item_above_        IN VARCHAR2,
   level_no_          IN NUMBER)
IS
   highest_no_           NUMBER;
   new_level_            NUMBER;
   attr_                 VARCHAR2(4000);
   objid_                cost_structure_item.objid%TYPE;
   objversion_           cost_structure_item.objversion%TYPE;
   newrec_               cost_structure_item_tab%ROWTYPE;
   indrec_               Indicator_Rec;

   CURSOR max_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;

BEGIN
   OPEN  max_level_no;
   FETCH max_level_no INTO highest_no_;
   CLOSE max_level_no;
   IF (highest_no_ IS NULL) THEN
      Cost_Structure_Level_API.Insert_Level__(company_, cost_structure_id_);
   ELSIF highest_no_ <= level_no_ THEN
      Cost_Structure_Level_API.Insert_Level__(company_, cost_structure_id_);
   END IF;
   new_level_ := level_no_ + 1;
   --insert new node--
   Client_SYS.Clear_Attr( attr_);
   Client_SYS.Add_To_Attr( 'COMPANY',                       company_,           attr_);
   Client_SYS.Add_To_Attr( 'COST_STRUCTURE_ID',             cost_structure_id_, attr_);
   Client_SYS.Add_To_Attr( 'NAME_VALUE',                    name_value_,        attr_);
   Client_SYS.Add_To_Attr( 'DESCRIPTION',                   description_,       attr_);
   Client_SYS.Add_To_Attr( 'ITEM_ABOVE',                    item_above_,        attr_);
   Client_SYS.Add_To_Attr( 'COST_STRUCT_ITEM_TYPE_DB', 'NODE',             attr_);
   Client_SYS.Add_To_Attr( 'LEVEL_NO', new_level_, attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New_Node__;


PROCEDURE Insert_Start_Node__(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
BEGIN
   new_node__ (company_, cost_structure_id_, 1, '<1>', NULL, 0);
END Insert_Start_Node__;


@UncheckedAccess
FUNCTION Get_Level_No__ (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   name_value_        IN VARCHAR2 ) RETURN NUMBER
IS
   level_no_ NUMBER;
   CURSOR getlevel IS
      SELECT level_no
      FROM   cost_structure_item
      WHERE  company                       = company_
      AND    cost_structure_id             = cost_structure_id_
      AND    name_value                    = name_value_
      AND    cost_struct_item_type_db = 'NODE';
BEGIN
   OPEN  getlevel;
   FETCH getlevel INTO level_no_;
   CLOSE getlevel;
   RETURN level_no_;
END Get_Level_No__;


PROCEDURE Get_Item_Info__(
   description_       OUT VARCHAR2,
   objid_             OUT VARCHAR2,
   objversion_        OUT VARCHAR2,
   company_           IN  VARCHAR2,
   cost_structure_id_ IN  VARCHAR2,
   name_value_        IN  VARCHAR2)
IS
   CURSOR get_item_info IS
      SELECT description, rowid, TO_CHAR(rowversion,'YYYYMMDDHH24MISS')
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    name_value        = name_value_;
BEGIN
   OPEN  get_item_info;
   FETCH get_item_info INTO description_, objid_, objversion_;
   CLOSE get_item_info;
END Get_Item_Info__;


PROCEDURE New_Top_Node__(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   name_value_        IN VARCHAR2,
   description_       IN VARCHAR2)
IS
   attr_                 VARCHAR2(4000);
   objid_                cost_structure_item.objid%TYPE;
   objversion_           cost_structure_item.objversion%TYPE;
   newrec_               cost_structure_item_tab%ROWTYPE;
   indrec_               Indicator_Rec;
BEGIN
   UPDATE cost_structure_item_tab
      SET level_no = level_no + 1
   WHERE  company           =  company_
   AND    cost_structure_id = cost_structure_id_;

   UPDATE cost_structure_item_tab
      SET item_above = name_value_
   WHERE  company           =  company_
   AND    cost_structure_id = cost_structure_id_
   AND    item_above        IS NULL;

   Client_SYS.Clear_Attr( attr_);
   Client_SYS.Add_To_Attr( 'COMPANY',                       company_,           attr_);
   Client_SYS.Add_To_Attr( 'COST_STRUCTURE_ID',             cost_structure_id_, attr_);
   Client_SYS.Add_To_Attr( 'NAME_VALUE',                    name_value_,        attr_);
   Client_SYS.Add_To_Attr( 'DESCRIPTION',                   description_,       attr_);
   Client_SYS.Add_To_Attr( 'ITEM_ABOVE',                    '',                 attr_);
   Client_SYS.Add_To_Attr( 'COST_STRUCT_ITEM_TYPE_DB', 'NODE',             attr_);
   Client_SYS.Add_To_Attr( 'LEVEL_NO',                      '1',                attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
   Cost_Structure_Level_API.New_Top_Level__(company_, cost_structure_id_);
END New_Top_Node__;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Delete_Node__ (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   objid_             IN VARCHAR2,
   objversion_        IN VARCHAR2 )
IS
   remrec_               cost_structure_item_tab%ROWTYPE;
   key_                  VARCHAR2(2000);
BEGIN
   remrec_ := Lock_By_Id___(objid_, objversion_);
   key_    := remrec_.company || '^' || remrec_.cost_structure_id || '^' || remrec_.name_value || '^' || remrec_.cost_struct_item_type || '^';
   Validate_Modify_Delete___ (remrec_.company, remrec_.cost_structure_id, remrec_.name_value, remrec_.cost_struct_item_type);
   Cost_Structure_API.Validate_Changing_Structure(remrec_.company, remrec_.cost_structure_id);
   Reference_SYS.Do_Cascade_Delete(lu_name_, key_);

   DELETE
   FROM   cost_structure_item_tab a
   WHERE  company           = remrec_.company
   AND    cost_structure_id = remrec_.cost_structure_id
   AND   (name_value, cost_struct_item_type) IN (SELECT name_value, cost_struct_item_type
                                                      FROM  (SELECT *
                                                             FROM   cost_structure_item_tab a
                                                             WHERE  a.company           = remrec_.company
                                                             AND    a.cost_structure_id = remrec_.cost_structure_id) b
                                                             START WITH name_value = remrec_.name_value
                                                             AND cost_struct_item_type = 'NODE'
                                                             CONNECT BY company           = PRIOR company
                                                             AND        cost_structure_id = PRIOR cost_structure_id
                                                             AND        item_above        = PRIOR name_value
                                                             AND        (item_above || DECODE(cost_struct_item_type, 'COST_ELEMENT', 'NODE', cost_struct_item_type) = PRIOR (name_value || cost_struct_item_type)));

   Cost_Structure_Level_API.Delete_Unused_Levels__(remrec_.company, remrec_.cost_structure_id);
END Delete_Node__;


PROCEDURE Copy__ (
   company_               IN VARCHAR2,
   cost_structure_id_     IN VARCHAR2,
   new_cost_structure_id_ IN VARCHAR2 )
IS
   rec2_                     cost_structure_item_tab%ROWTYPE;
   attr_                     VARCHAR2(4000);
   objid_                    cost_structure_item.objid%TYPE;
   objversion_               cost_structure_item.objversion%TYPE;
   indrec_                   Indicator_Rec;
   CURSOR cur IS
      SELECT *
      FROM  (SELECT *
             FROM   cost_structure_item_tab a
             WHERE  a.company           = company_
             AND    a.cost_structure_id = cost_structure_id_)
             START WITH item_above IS NULL
             CONNECT BY company           = PRIOR company
             AND        cost_structure_id = PRIOR cost_structure_id
             AND        item_above        = PRIOR name_value
             AND       (item_above || DECODE(cost_struct_item_type, 'COST_ELEMENT', 'NODE', cost_struct_item_type) = PRIOR (name_value || cost_struct_item_type));


BEGIN
   Cost_Structure_API.Exist(company_, cost_structure_id_);
   Cost_Structure_API.Exist(company_, new_cost_structure_id_);
   FOR rec_ IN cur LOOP
      Client_SYS.Clear_Attr( attr_);
      Client_SYS.Add_To_Attr('COMPANY',           company_,               attr_);
      Client_SYS.Add_To_Attr('COST_STRUCTURE_ID', new_cost_structure_id_, attr_);
      Client_SYS.Add_To_Attr('NAME_VALUE',        rec_.name_value,        attr_);
      IF (rec_.cost_struct_item_type <> 'NODE') THEN
         rec_.description := Project_Cost_Element_API.Get_Description(company_, rec_.name_value);
      END IF;
      Client_SYS.Add_To_Attr('DESCRIPTION',       rec_.description,       attr_);
      Client_SYS.Add_To_Attr('LEVEL_NO',          rec_.level_no,          attr_);
      Client_SYS.Add_To_Attr('LEVEL_ID',          rec_.level_id,          attr_);
      Client_SYS.Add_To_Attr('ITEM_ABOVE',        rec_.item_above,        attr_);
      Client_SYS.Add_To_Attr('COST_STRUCT_ITEM_TYPE_DB', rec_.cost_struct_item_type, attr_);
      Unpack___(rec2_, indrec_, attr_);
      Check_Insert___(rec2_, indrec_, attr_);
      Insert___( objid_, objversion_, rec2_, attr_);
   END LOOP;
END Copy__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

@UncheckedAccess
FUNCTION Get_Description_Db (
   company_                       IN VARCHAR2,
   cost_structure_id_             IN VARCHAR2,
   name_value_                    IN VARCHAR2,
   cost_struct_item_type_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_                             cost_structure_item_tab.description%TYPE;
   CURSOR get_attr IS
      SELECT description
      FROM   cost_structure_item_tab
      WHERE  company                    = company_
      AND    cost_structure_id          = cost_structure_id_
      AND    name_value                 = name_value_
      AND    cost_struct_item_type = cost_struct_item_type_db_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Description_Db;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Change_Level_Id (
   company_                    IN VARCHAR2,
   cost_structure_id_          IN VARCHAR2,
   name_value_                 IN VARCHAR2,
   cost_struct_item_type_ IN VARCHAR2,
   new_level_id_               IN VARCHAR2,
   from_rmb_change_level_id_   IN BOOLEAN DEFAULT TRUE )
IS
   source_item_                   cost_structure_item_tab.name_value%TYPE;
   source_item_type_              cost_structure_item_tab.cost_struct_item_type%TYPE;
   oldrec_                        cost_structure_item_tab%ROWTYPE;
   newrec_                        cost_structure_item_tab%ROWTYPE;
   attr_                          VARCHAR2(4000);
   objid_                         cost_structure_item.OBJID%TYPE;
   objversion_                    cost_structure_item.OBJVERSION%TYPE;
   source_level_                  NUMBER;
   highest_level_                 NUMBER;
   max_in_move_                   NUMBER;
   needed_levels_                 NUMBER;
   diff_in_tree_                  NUMBER;
   target_level_                  NUMBER;
   update_with_this_              NUMBER;
   n_index_                       NUMBER;
   item_level_no_                 NUMBER;
   level_no_                      NUMBER;
   parent_level_no_               NUMBER;

   CURSOR max_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;

   CURSOR highest_level_move IS
      SELECT MAX(level_no)
      FROM   cost_structure_item_tab a
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    name_value        IN (SELECT name_value
                                   FROM (SELECT *
                                         FROM   cost_structure_item_tab a
                                         WHERE  a.company                    = company_
                                         AND    a.cost_structure_id          = cost_structure_id_
                                         AND    a.cost_struct_item_type = source_item_type_) b
                                   START WITH name_value = source_item_
                                   AND        cost_struct_item_type = newrec_.cost_struct_item_type
                                   CONNECT BY company                    = PRIOR company
                                   AND        cost_structure_id          = PRIOR cost_structure_id
                                   AND        item_above                 = PRIOR name_value
                                   AND        cost_struct_item_type = PRIOR cost_struct_item_type);

BEGIN
   source_item_      := name_value_;
   source_item_type_ := cost_struct_item_type_;
   newrec_           := Get_Object_By_Keys___(company_, cost_structure_id_, source_item_, source_item_type_);
   source_level_     := newrec_.level_no;
   level_no_         := Cost_Structure_Level_API.Get_Level_No(company_, cost_structure_id_, new_level_id_);
   target_level_     := level_no_;
   newrec_.level_no  := level_no_;
   newrec_.level_id  := new_level_id_;
   Validate_Modify_Delete___ (newrec_.company, newrec_.cost_structure_id, newrec_.name_value, newrec_.cost_struct_item_type);
   --if new level id is equal or lower to level id of it's parent node then error
   parent_level_no_ := Get_Level_No__(company_, cost_structure_id_, Get_Item_Above(company_, cost_structure_id_, source_item_, source_item_type_));
   IF (target_level_ <= parent_level_no_) AND (source_item_type_='NODE') THEN
      Error_SYS.Record_general( lu_name_, 'PARENTNODEBELOW: Level ID must be set to a level below the Level ID of parent node.');
   END IF;
   IF (target_level_ < parent_level_no_) AND (source_item_type_='COST_ELEMENT') THEN
      Error_SYS.Record_general( lu_name_, 'PARENTNODEBELOWCE: Level ID must be set to same level or a level below the Level ID of parent node.');
   END IF;
   OPEN  max_level_no;
   FETCH max_level_no INTO highest_level_;
   CLOSE max_level_no;
   IF (newrec_.cost_struct_item_type = 'NODE') THEN
      OPEN  highest_level_move;
      FETCH highest_level_move INTO max_in_move_;
      CLOSE highest_level_move;
   END IF;
   diff_in_tree_     := max_in_move_ - source_level_;
   needed_levels_    := target_level_ + diff_in_tree_;
   update_with_this_ := needed_levels_ - highest_level_;
   item_level_no_    := (target_level_ - source_level_); -- + 1;
   n_index_          := 0;

   UPDATE cost_structure_item_tab a
      SET level_no = level_no + item_level_no_,
          level_id = NVL(Cost_Structure_Level_API.Get_Level_Id(company_, cost_structure_id_, level_no + item_level_no_), level_no + item_level_no_)
   WHERE  company           = company_
   AND    cost_structure_id = cost_structure_id_
   AND   (name_value, cost_struct_item_type) IN (SELECT name_value, cost_struct_item_type
                                                      FROM  (SELECT *
                                                             FROM   cost_structure_item_tab a
                                                             WHERE  a.company           = company_
                                                             AND    a.cost_structure_id = cost_structure_id_) b
                                                      START WITH name_value = source_item_
                                                      AND        cost_struct_item_type = source_item_type_
                                                      CONNECT BY company           = PRIOR company
                                                      AND        cost_structure_id = PRIOR cost_structure_id
                                                      AND        item_above        = PRIOR name_value
                                                      AND        (item_above || DECODE(cost_struct_item_type, 'COST_ELEMENT', 'NODE', cost_struct_item_type) = PRIOR (name_value || cost_struct_item_type)));

   IF (update_with_this_ > 0 AND newrec_.cost_struct_item_type = 'NODE') THEN
      WHILE(n_index_ < update_with_this_) LOOP
         Cost_Structure_Level_API.Insert_Level__(company_, cost_structure_id_);
         n_index_ := n_index_ + 1;
      END LOOP;
   END IF;
   IF (update_with_this_ <= 0) THEN
      Cost_Structure_Level_API.Delete_Unused_Levels__(company_, cost_structure_id_);
   END IF;
   IF (from_rmb_change_level_id_) THEN
      Validate_Record___( newrec_ );
      Client_SYS.Add_To_Attr('MOVE_NODE',            Fnd_Boolean_API.DB_FALSE, attr_);
      Client_SYS.Add_To_Attr('FROM_CHANGE_LEVEL_ID', Fnd_Boolean_API.DB_TRUE,  attr_);
      Update___ (objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
   END IF;

END Change_Level_Id;


@UncheckedAccess
FUNCTION Get_Parent_Plus_Level_Id (
   company_                    IN VARCHAR2,
   cost_structure_id_          IN VARCHAR2,
   name_value_                 IN VARCHAR2,
   cost_struct_item_type_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   parent_plus_level_id_          VARCHAR2(20);
   parent_level_no_               NUMBER;
BEGIN
   parent_level_no_      := Get_Level_No__(company_, cost_structure_id_, Get_Item_Above(company_, cost_structure_id_, name_value_, cost_struct_item_type_));
   parent_plus_level_id_ := Cost_Structure_Level_API.Get_Level_Id(company_, cost_structure_id_, parent_level_no_+1);
   RETURN parent_plus_level_id_;
END Get_Parent_Plus_Level_Id;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Move_Branch (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   source_item_       IN VARCHAR2,
   source_item_type_  IN VARCHAR2,
   target_item_       IN VARCHAR2,
   target_item_type_  IN VARCHAR2 )
IS
   oldrec_               cost_structure_item_tab%ROWTYPE;
   newrec_               cost_structure_item_tab%ROWTYPE;
   attr_                 VARCHAR2(4000);
   objid_                cost_structure_item.objid%TYPE;
   objversion_           cost_structure_item.objversion%TYPE;
   source_level_         NUMBER;
   highest_level_        NUMBER;
   max_in_move_          NUMBER;
   needed_levels_        NUMBER;
   diff_in_tree_         NUMBER;
   target_level_         NUMBER;
   update_with_this_     NUMBER;
   n_index_              NUMBER;
   item_level_no_        NUMBER;
   level_no_             NUMBER;

   CURSOR max_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;

   CURSOR highest_level_move IS
      SELECT MAX(level_no)
      FROM  (SELECT *
             FROM   cost_structure_item_tab a
             WHERE  a.company                    = company_
             AND    a.cost_structure_id          = cost_structure_id_
             AND    a.cost_struct_item_type = source_item_type_) a
      START WITH name_value = source_item_
      AND        cost_struct_item_type = newrec_.cost_struct_item_type
      CONNECT BY company                    = PRIOR company
      AND        cost_structure_id          = PRIOR cost_structure_id
      AND        item_above                 = PRIOR name_value
      AND        cost_struct_item_type = PRIOR cost_struct_item_type;
BEGIN
   newrec_             := Get_Object_By_Keys___(company_, cost_structure_id_, source_item_, source_item_type_);
   source_level_       := newrec_.level_no;
   newrec_.item_above  := target_item_;
   IF (newrec_.cost_struct_item_type = 'NODE') THEN -- IF it is a node
      level_no_        := Get_Level_No__(company_, cost_structure_id_, target_item_);
      target_level_    := level_no_;
      newrec_.level_no := level_no_+1;
      newrec_.level_id := NVL(Cost_Structure_Level_API.Get_Level_Id(newrec_.company, newrec_.cost_structure_id, newrec_.level_no), newrec_.level_no);
   END IF;
   IF (newrec_.cost_struct_item_type = 'COST_ELEMENT') THEN -- IF it is a leaf
      level_no_        := Get_Level_No__(company_, cost_structure_id_, target_item_);
      target_level_    := level_no_;
      newrec_.level_no := level_no_;
      newrec_.level_id := NVL(Cost_Structure_Level_API.Get_Level_Id(newrec_.company, newrec_.cost_structure_id, newrec_.level_no), newrec_.level_no);
   END IF;
   OPEN  max_level_no;
   FETCH max_level_no INTO highest_level_;
   CLOSE max_level_no;
   IF (newrec_.cost_struct_item_type = 'NODE') THEN
      OPEN  highest_level_move;
      FETCH highest_level_move INTO max_in_move_;
      CLOSE highest_level_move;
   END IF;
   diff_in_tree_       := max_in_move_ - source_level_;
   diff_in_tree_       := diff_in_tree_+ 1;
   needed_levels_      := target_level_ + diff_in_tree_;
   update_with_this_   := needed_levels_ - highest_level_;
   item_level_no_      := (target_level_ - source_level_) + 1;
   n_index_            := 0;

   UPDATE cost_structure_item_tab a
      SET level_no = level_no + item_level_no_,
          level_id = NVL(Cost_Structure_Level_API.Get_Level_Id(newrec_.company, newrec_.cost_structure_id, level_no + item_level_no_), level_no + item_level_no_)
   WHERE  company           = company_
   AND    cost_structure_id = cost_structure_id_
   AND    (name_value, cost_struct_item_type) IN (SELECT name_value, cost_struct_item_type
                                                       FROM  (SELECT *
                                                              FROM   cost_structure_item_tab a
                                                              WHERE  a.company           = company_
                                                              AND    a.cost_structure_id = cost_structure_id_) b
                                                       START WITH name_value = source_item_
                                                       AND        cost_struct_item_type = source_item_type_
                                                       CONNECT BY company           = PRIOR company
                                                       AND        cost_structure_id = PRIOR cost_structure_id
                                                       AND        item_above        = PRIOR name_value
                                                       AND       (item_above || DECODE(cost_struct_item_type, 'COST_ELEMENT', 'NODE', cost_struct_item_type) = PRIOR (name_value || cost_struct_item_type)));

   IF (update_with_this_ > 0 AND newrec_.cost_struct_item_type = 'NODE') THEN
      WHILE(n_index_ < update_with_this_) LOOP
         Cost_Structure_Level_API.Insert_Level__(company_, cost_structure_id_);
         n_index_ := n_index_ + 1;
      END LOOP;
   END IF;
   IF (update_with_this_ <= 0) THEN
      Cost_Structure_Level_API.Delete_Unused_Levels__(company_, cost_structure_id_);
   END IF;
   Validate_Record___( newrec_ );
   Update___ ( objid_, oldrec_, newrec_, attr_, objversion_, TRUE);
END Move_Branch;


PROCEDURE Add_Branch (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   source_node_       IN VARCHAR2,
   new_item_          IN VARCHAR2 )
IS
   attr_                 VARCHAR2(4000);
   newrec_               cost_structure_item_tab%ROWTYPE;
   indrec_               Indicator_Rec;
   objid_                cost_structure_item.objid%TYPE;
   objversion_           cost_structure_item.objversion%TYPE;
BEGIN
   Client_SYS.Clear_Attr( attr_);
   Client_SYS.Add_To_Attr('COMPANY',                       company_,           attr_);
   Client_SYS.Add_To_Attr('COST_STRUCTURE_ID',             cost_structure_id_, attr_);
   Client_SYS.Add_To_Attr('NAME_VALUE',                    new_item_,          attr_);
   Client_SYS.Add_To_Attr('DESCRIPTION',                   Project_Cost_Element_API.Get_Description(company_, new_item_), attr_);
   Client_SYS.Add_To_Attr('LEVEL_NO',                      Get_Level_No__(company_, cost_structure_id_, source_node_), attr_);
   Client_SYS.Add_To_Attr('ITEM_ABOVE',                    source_node_,       attr_);
   Client_SYS.Add_To_Attr('COST_STRUCT_ITEM_TYPE_DB', 'COST_ELEMENT',     attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END Add_Branch;


PROCEDURE Del_Branch (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   del_item_          IN VARCHAR2,
   del_item_type_     IN VARCHAR2 )
IS
   remrec_               cost_structure_item_tab%ROWTYPE;
   objid_                cost_structure_item.objid%TYPE;
   objversion_           cost_structure_item.objversion%TYPE;
BEGIN
   Exist_Db(company_, cost_structure_id_, del_item_, del_item_type_);
   Get_Id_Version_By_Keys___ (objid_, objversion_, company_, cost_structure_id_, del_item_, del_item_type_);
   remrec_ := Lock_By_Id___(objid_, objversion_);
   Check_Delete___(remrec_);
   Delete___(objid_, remrec_);
END Del_Branch;


@UncheckedAccess
FUNCTION Is_Level_Exist (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_no_          IN NUMBER ) RETURN VARCHAR2
IS
   temp_                 NUMBER;
   CURSOR level_exist IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_no          = level_no_;
BEGIN
   OPEN  level_exist;
   FETCH level_exist INTO temp_;
   IF (level_exist%FOUND) THEN
      CLOSE level_exist;
      RETURN('TRUE');
   ELSE
      CLOSE level_exist;
      RETURN('FALSE');
   END IF;
END Is_Level_Exist;


@UncheckedAccess
FUNCTION Get_Cost_Struct_Item_Type (
   company_                    IN VARCHAR2,
   cost_structure_id_          IN VARCHAR2,
   name_value_                 IN VARCHAR2 ) RETURN VARCHAR2
IS
   cost_struct_item_type_    cost_structure_item_tab.cost_struct_item_type%TYPE;
   CURSOR get_item_type_ IS
      SELECT cost_struct_item_type
      FROM   cost_structure_item_tab
      WHERE  company            = company_
      AND    cost_structure_id = cost_structure_id_
      AND    name_value        = name_value_;

BEGIN
   OPEN  get_item_type_;
   FETCH get_item_type_ INTO cost_struct_item_type_;
   CLOSE get_item_type_;
   RETURN cost_struct_item_type_;
END Get_Cost_Struct_Item_Type;


@UncheckedAccess
FUNCTION Check_Node_Exist (
   company_    IN VARCHAR2,
   name_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_         NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company                    = company_
      AND    name_value                 = name_value_
      AND    cost_struct_item_type = 'NODE';
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Node_Exist;


@UncheckedAccess
FUNCTION Check_Cost_Element_Exist (
   company_    IN VARCHAR2,
   name_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_         NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company                    = company_
      AND    name_value                 = name_value_
      AND    cost_struct_item_type = 'COST_ELEMENT';
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Cost_Element_Exist;


@UncheckedAccess
FUNCTION Check_Exist (
   company_                       IN VARCHAR2,
   cost_structure_id_             IN VARCHAR2,
   name_value_                    IN VARCHAR2,
   cost_struct_item_type_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_                            NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   cost_structure_item_tab
      WHERE  company                    = company_
      AND    cost_structure_id          = cost_structure_id_
      AND    name_value                 = name_value_
      AND    cost_struct_item_type = cost_struct_item_type_db_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN('TRUE');
   END IF;
   CLOSE exist_control;
   RETURN('FALSE');
END Check_Exist;


PROCEDURE Update_Level_Id (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   old_level_id_      IN VARCHAR2,
   new_level_id_      IN VARCHAR2 )
IS
   objid_                cost_structure_item.objid%TYPE;
   objversion_           cost_structure_item.objversion%TYPE;
   attr_                 VARCHAR2(4000);
   oldrec_               cost_structure_item_tab%ROWTYPE;
   newrec_               cost_structure_item_tab%ROWTYPE;

   CURSOR level_exist_rec IS
      SELECT *
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_id          = old_level_id_;
BEGIN
   FOR rec_ IN level_exist_rec LOOP
      Client_SYS.Clear_Attr(attr_);
      Get_Id_Version_By_Keys___ (objid_, objversion_, rec_.company, rec_.cost_structure_id, rec_.name_value, rec_.cost_struct_item_type);
      oldrec_ := Lock_By_Id___(objid_, objversion_);
      newrec_ := oldrec_;
      newrec_.level_id := new_level_id_;
      Client_SYS.Add_To_Attr('MOVE_NODE',            Fnd_Boolean_API.DB_FALSE, attr_);
      Client_SYS.Add_To_Attr('FROM_CHANGE_LEVEL_ID', Fnd_Boolean_API.DB_TRUE,  attr_);
      Update___ (objid_, oldrec_, newrec_, attr_, objversion_, FALSE);
   END LOOP;
END Update_Level_Id;


@UncheckedAccess
FUNCTION Get_Item_Above_Db (
   company_                       IN VARCHAR2,
   cost_structure_id_             IN VARCHAR2,
   name_value_                    IN VARCHAR2,
   cost_struct_item_type_db_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   above_                            VARCHAR2(100);

   CURSOR getabove IS
      SELECT item_above
      FROM   cost_structure_item_tab
      WHERE  company                    = company_
      AND    cost_structure_id          = cost_structure_id_
      AND    name_value                 = name_value_
      AND    cost_struct_item_type = cost_struct_item_type_db_;
BEGIN
   OPEN  getabove;
   FETCH getabove INTO above_;
   CLOSE getabove;
   RETURN above_;
END Get_Item_Above_Db;


@UncheckedAccess
FUNCTION Get_Top_Node (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2) RETURN VARCHAR2
IS
   name_value_                       VARCHAR2(100);
   CURSOR gettop IS
      SELECT name_value
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    item_above        IS NULL;
BEGIN
   OPEN  gettop;
   FETCH gettop INTO name_value_;
   CLOSE gettop;
   RETURN name_value_;
END Get_Top_Node;


PROCEDURE Modify_Structure_Item(
   item_rec_    IN OUT  cost_structure_item_tab%ROWTYPE )
IS
BEGIN
   Modify___(item_rec_, TRUE);
END Modify_Structure_Item;   
