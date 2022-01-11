-----------------------------------------------------------------------------
--
--  Logical unit: CostStructure
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  160620  KGAMLK   FINLIFE-45, Moved ProjCostStructure to ACCRUL as CostStructure, Changes in plsql logic.
--  130121  JEGUSE   Bug 107348, Merged Budget and Forecast Revenue.
--  120405  CHSELK   EASTRTM-8648. Modified Validate_Record___ to check for CBS node usage in project forecast and budget control rules.  
--  111209  PESULK   SPJ-984, Modified Insert__(), Set objversion_ after the call to Finite_State_Init___().
--  110215  THTHLK   HIGHPK-6968, Modified Check_Delete___. Check if CBS connected to a project.
--  110112  Ersruk   HIGHPK-5362, Modified Validate_Record___() add a warning.
--  110104  THTHLK   HIGHPK-3202, Added Create_Active_New
--  101201  THTHLK   HIGHPK-3202, Added new VIEW PROJ_CBS_TEMPLATE_ACTIVE and Modified PROJ_COST_STRUCTURE_ACTIVE.
--  100820  Ersruk   Added column multiple_projects.
--  100816  Ersruk   Added copied_from in Copy__().
--  100804  Janslk   Changed PROJ_COST_STRUCTURE_ACTIVE to filter records correctly with "template" field.
--                   Changed Prepare_Insert___ to insert "FALSE" to template field when creating a new record.
--                   Added new error message in Validate_Record___ when the company of the project selected
--                   for the CBS is not the same company as of the CBS.
--  100721  Ersruk   Added Validate_Project_Connection().
--  100713  Ersruk   Added Update_Project_Id, Validate_Record___ and update project details for CBS. 
--  100712  Janslk   Changed Delete___ to delete items and levels connected 
--                   to the Cost Breakdown Structure.
--  100708  Ersruk   Added column project_id and function Get_Project_Name().
--  100708  Ersruk   Added template, copied_from and note columns.
--  100518  Ersruk   Renamed STRUCTURE_ID to COST_STRUCTURE_ID
--  100514  Janslk   Added method Get_State to get the db value of state.
--  100505  Ersruk   Created
--  171018  Jadulk   FIUXX-1726 Added Create_New_Structure
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------

state_separator_   CONSTANT VARCHAR2(1)   := Client_SYS.field_separator_;


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Record___ (
   newrec_  IN cost_structure_tab%ROWTYPE,
   oldrec_  IN cost_structure_tab%ROWTYPE DEFAULT NULL )
IS
BEGIN
   $IF Component_Proj_SYS.INSTALLED $THEN
      IF (oldrec_.template = 'FALSE' AND newrec_.template = 'TRUE' AND Project_API.Is_Structure_Connected(newrec_.company, newrec_.cost_structure_id) = 'TRUE') THEN
         Error_SYS.Record_general(lu_name_, 'PROJTEMPLATEINVALID: Cost Breakdown Structure cannot be a template and connected to projects at the same time.');
      END IF;
      IF (
         (Project_API.Get_Proj_Count_to_CBS(newrec_.company, newrec_.cost_structure_id) > 1) AND 
         (Project_API.Is_Structure_Connected(newrec_.company, newrec_.cost_structure_id) = 'TRUE') 
         AND (oldrec_.single_project='FALSE') AND (newrec_.single_project='TRUE')) THEN
         Error_SYS.Record_general(lu_name_, 'MULTPROJECTCONNECTED: Structure ID :P1 is connected to multiple projects and cannot be set as single project.', newrec_.cost_structure_id);
      END IF;
   $ELSE
      NULL;
   $END
END Validate_Record___;

@Override
PROCEDURE Finite_State_Add_To_Attr___ (
   rec_  IN     cost_structure_tab%ROWTYPE,
   attr_ IN OUT VARCHAR2 )
IS
   state_       VARCHAR2(30);
BEGIN
   super(rec_, attr_);
   Client_SYS.Add_To_Attr('OBJSTATE', state_, attr_);
END Finite_State_Add_To_Attr___;


@Override
PROCEDURE Prepare_Insert___ (
   attr_ IN OUT VARCHAR2 )
IS
BEGIN
   super(attr_);
   Client_SYS.Add_to_Attr('TEMPLATE', 'FALSE', attr_);
   Client_SYS.Add_to_Attr('SINGLE_PROJECT', 'FALSE', attr_);
END Prepare_Insert___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT cost_structure_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
   create_node_       VARCHAR2(5) := Fnd_Boolean_API.DB_TRUE;   
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   create_node_ := NVL(Client_SYS.Get_Item_Value('CREATE_NODE', attr_), Fnd_Boolean_API.DB_TRUE);   
   IF (create_node_ = Fnd_Boolean_API.DB_TRUE) THEN
      Cost_Structure_Item_API.Insert_Start_Node__(newrec_.company, newrec_.cost_structure_id);
   END IF;   
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_       IN     VARCHAR2,
   oldrec_      IN     cost_structure_tab%ROWTYPE,
   newrec_      IN OUT cost_structure_tab%ROWTYPE,
   attr_        IN OUT VARCHAR2,
   objversion_  IN OUT VARCHAR2,
   by_keys_     IN     BOOLEAN DEFAULT FALSE )
IS
BEGIN
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN cost_structure_tab%ROWTYPE )
IS
BEGIN
   $IF Component_Proj_SYS.INSTALLED $THEN
      IF (Project_API.Is_Structure_Connected(remrec_.company, remrec_.cost_structure_id) = 'TRUE') THEN
         Error_SYS.Record_general(lu_name_, 'ERRORDELPROJCONNECT: Cost structure connected to 1 or more projects cannot be deleted.');
      END IF;
   $END
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN cost_structure_tab%ROWTYPE )
IS
BEGIN
   super(objid_, remrec_);

   --  Not deleted by Cascade Delete:
   DELETE
   FROM   cost_structure_item_tab
   WHERE  company           = remrec_.company
   AND    cost_structure_id = remrec_.cost_structure_id;
   DELETE
   FROM   cost_structure_level_tab
   WHERE  company           = remrec_.company
   AND    cost_structure_id = remrec_.cost_structure_id;
END Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT cost_structure_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(newrec_, indrec_, attr_);
   IF (newrec_.template IS NULL) THEN
      newrec_.template := 'FALSE';
   END IF;
   IF (newrec_.single_project IS NULL) THEN
      newrec_.single_project := 'FALSE';
   END IF;
   Validate_Record___( newrec_ );
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     cost_structure_tab%ROWTYPE,
   newrec_ IN OUT cost_structure_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   Validate_Record___( newrec_, oldrec_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------


PROCEDURE Copy__ (
   company_               IN VARCHAR2,
   cost_structure_id_     IN VARCHAR2,
   new_cost_structure_id_ IN VARCHAR2,
   new_description_       IN VARCHAR2 )
IS
   rec_                      cost_structure_tab%ROWTYPE;
   indrec_                   Indicator_Rec;
   attr_                     VARCHAR2(32000);
   objid_                    cost_structure.objid%TYPE;
   objversion_               cost_structure.objversion%TYPE;
   structure_rec_            cost_structure_tab%ROWTYPE;

   CURSOR get_structure_rec IS
      SELECT *
      FROM   cost_structure_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;

BEGIN
   Client_SYS.Clear_Attr( attr_);
   Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr( 'COST_STRUCTURE_ID', new_cost_structure_id_, attr_);
   Client_SYS.Add_To_Attr( 'DESCRIPTION', new_description_, attr_);
   Client_SYS.Add_To_Attr( 'COPIED_FROM', cost_structure_id_, attr_);
   OPEN  get_structure_rec;
   FETCH get_structure_rec INTO structure_rec_;
   CLOSE get_structure_rec;
   Client_SYS.Add_To_Attr( 'NOTE',     structure_rec_.note, attr_);
   Client_SYS.Add_To_Attr( 'SINGLE_PROJECT', structure_rec_.single_project, attr_);
   Unpack___(rec_, indrec_, attr_);
   Check_Insert___(rec_, indrec_, attr_);
   Client_SYS.Add_To_Attr('CREATE_NODE', Fnd_Boolean_API.DB_FALSE, attr_);
   Insert___( objid_, objversion_, rec_, attr_);
   Cost_Structure_Level_API.Copy__( company_, cost_structure_id_, new_cost_structure_id_);
   Cost_Structure_Item_API.Copy__( company_, cost_structure_id_, new_cost_structure_id_);
END Copy__;


@Override
PROCEDURE Activate__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   rec_ cost_structure_tab%ROWTYPE;
BEGIN
   super(info_, objid_, objversion_, attr_, action_);
   IF (action_ = 'DO') THEN
      rec_ := Get_Object_By_Id___(objid_);
      Cost_Structure_Util_API.Refresh_Structure_Cache(rec_.company, rec_.cost_structure_id);
   END IF;   
END Activate__;


@Override
PROCEDURE Re_Open__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   rec_ cost_structure_tab%ROWTYPE;
BEGIN
   super(info_, objid_, objversion_, attr_, action_);
   IF (action_ = 'DO') THEN
      rec_ := Get_Object_By_Id___(objid_);
      Cost_Structure_Util_API.Remove_Structure_Cache(rec_.company, rec_.cost_structure_id);
   END IF;   
END Re_Open__;


@Override
PROCEDURE Set_Obsolete__ (
   info_       OUT    VARCHAR2,
   objid_      IN     VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   rec_ cost_structure_tab%ROWTYPE;
BEGIN
   IF (action_ = 'CHECK') THEN
      rec_ := Get_Object_By_Id___(objid_);
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF (Project_API.Is_Structure_Connected(rec_.company, rec_.cost_structure_id) = 'TRUE') THEN
            Client_SYS.Add_Warning(lu_name_, 'PROJECTCONNECTED: Cost structure is connected to 1 or more projects. Do you still want to set obsolete?');
         END IF;
      $END
   END IF;      
   super(info_, objid_, objversion_, attr_, action_);
   IF (action_ = 'DO') THEN
      rec_ := Get_Object_By_Id___(objid_);
      Cost_Structure_Util_API.Remove_Structure_Cache(rec_.company, rec_.cost_structure_id);
   END IF;   
END Set_Obsolete__;


PROCEDURE Check_CBS_ID_Already_Exist__(
   company_ IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2    )
IS
BEGIN
   IF (Check_Exist___(company_, cost_structure_id_)) THEN
      Error_SYS.Record_Exist(lu_name_);      
   END IF;   
END Check_CBS_ID_Already_Exist__;
   


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Create_Active_New (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   description_       IN VARCHAR2,
   copied_from_       IN VARCHAR2 )
IS
   rec_                  cost_structure_tab%ROWTYPE;
   indrec_               Indicator_Rec;
   attr_                 VARCHAR2(32000);
   objid_                cost_structure.objid%TYPE;
   objversion_           cost_structure.objversion%TYPE;
   structure_rec_        cost_structure_tab%ROWTYPE;

   CURSOR get_structure_rec IS
      SELECT *
      FROM   cost_structure_tab
      WHERE  company           = company_
      AND    cost_structure_id = copied_from_;
BEGIN
   IF (NOT Check_Exist___(company_, cost_structure_id_)) THEN
      IF (copied_from_ IS NOT NULL) THEN
         IF (NOT Check_Exist___(company_, copied_from_)) THEN
            Error_SYS.Record_Not_Exist(lu_name_);
         ELSE
            Client_SYS.Clear_Attr( attr_);
            Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
            Client_SYS.Add_To_Attr( 'COST_STRUCTURE_ID', cost_structure_id_, attr_);
            Client_SYS.Add_To_Attr( 'DESCRIPTION', description_, attr_);
            Client_SYS.Add_To_Attr( 'COPIED_FROM', copied_from_, attr_);
            OPEN  get_structure_rec;
            FETCH get_structure_rec INTO structure_rec_;
            CLOSE get_structure_rec;
            Client_SYS.Add_To_Attr( 'TEMPLATE', 'FALSE', attr_);
            Client_SYS.Add_To_Attr( 'NOTE',     structure_rec_.note, attr_);
            Client_SYS.Add_To_Attr( 'SINGLE_PROJECT', structure_rec_.single_project, attr_);
            Unpack___(rec_, indrec_, attr_);
            Check_Insert___(rec_, indrec_, attr_);
            Client_SYS.Add_To_Attr('CREATE_NODE', Fnd_Boolean_API.DB_FALSE, attr_);
            Insert___( objid_, objversion_, rec_, attr_);
            Cost_Structure_Level_API.Copy__( company_, copied_from_, cost_structure_id_);
            Cost_Structure_Item_API.Copy__( company_, copied_from_, cost_structure_id_);
         END IF;
      ELSE
         Prepare_Insert___(attr_);
         Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
         Client_SYS.Add_To_Attr('COST_STRUCTURE_ID', cost_structure_id_, attr_);
         Client_SYS.Add_To_Attr('DESCRIPTION', description_, attr_);
         Client_SYS.Add_To_Attr('SINGLE_PROJECT', 'TRUE', attr_);
         Unpack___(rec_, indrec_, attr_);
         Check_Insert___(rec_, indrec_, attr_);
         Insert___(objid_, objversion_, rec_, attr_);
      END IF;
      rec_ := Lock_By_Keys___(company_, cost_structure_id_);
      Finite_State_Machine___(rec_, 'Activate', attr_);
   END IF;
END Create_Active_New;


PROCEDURE Validate_Changing_Structure (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
   objstate_             cost_structure.objstate%TYPE;
   state_                cost_structure.state%TYPE;
   CURSOR get_state IS
      SELECT objstate, state
      FROM   cost_structure
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;
BEGIN
   OPEN  get_state;
   FETCH get_state INTO objstate_, state_;
   CLOSE get_state;
   IF (objstate_ NOT IN ('In Progress'))  THEN
      Error_SYS.Record_general(lu_name_, 'NOTVALIDATED: The cost breakdown structure cannot be modified when it has status :P1', state_);
   END IF;
END Validate_Changing_Structure;


@UncheckedAccess
FUNCTION Get_Project_Name (
   project_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   $IF Component_Proj_SYS.INSTALLED $THEN
      RETURN Project_API.Get_Name(project_id_);
   $ELSE
      NULL;
   $END
END Get_Project_Name;

PROCEDURE Validate_Project_Connection (
   company_                IN VARCHAR2,
   cost_structure_id_      IN VARCHAR2 )
IS
   cost_structure_rowstate_   cost_structure_tab.rowstate%TYPE;
   cost_structure_template_   cost_structure_tab.template%TYPE;

   CURSOR get_rec IS
      SELECT rowstate, template
      FROM   cost_structure_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;
   
BEGIN
   OPEN  get_rec;
   FETCH get_rec INTO cost_structure_rowstate_, cost_structure_template_;
   CLOSE get_rec;
   --template CBS not allowed
   IF (cost_structure_template_ = 'TRUE') THEN
      Error_SYS.Record_General(lu_name_, 'CBSTEMPLATE: It is not possible to connect cost/revenue breakdown structure :P1 as it is a Template.', cost_structure_id_);
   END IF;
   IF (cost_structure_rowstate_ != 'Active') THEN
      Error_SYS.Record_General(lu_name_, 'CBSINVALIDSTATE: It is not possible to connect cost/revenue breakdown structure :P1 as it is not in Active status.', cost_structure_id_);
   END IF;
END Validate_Project_Connection;


PROCEDURE Validate_Cost_Elements (
   company_             IN VARCHAR2,
   cost_structure_id_   IN VARCHAR2,
   project_id_          IN VARCHAR2 )
IS
   dummy_                  NUMBER;
   CURSOR record_exist IS
      SELECT 1
      FROM   cost_structure_item_tab pcsi, cost_structure_tab pcs
      WHERE  pcsi.company                    = pcs.company
      AND    pcsi.cost_structure_id          = pcs.cost_structure_id 
      AND    pcsi.cost_struct_item_type = 'COST_ELEMENT'
$IF (Component_Projbf_SYS.INSTALLED) $THEN
      AND    pcsi.name_value                 NOT IN (SELECT project_cost_element
                                                     FROM   proj_cost_el_code_p_dem_tab
                                                     WHERE  company    = company_
                                                     AND    project_id = project_id_)
$END
      AND    pcs.company                     = company_
      AND    pcs.cost_structure_id           = cost_structure_id_;
BEGIN
   OPEN  record_exist;
   FETCH record_exist INTO dummy_;
   IF (record_exist%FOUND) THEN
      CLOSE record_exist;
      Error_SYS.Record_general(lu_name_, 'CENOTDEFINEDPROJECT: Cost/Revenue Breakdown Structure :P1 consist of Cost Elements not defined in PCE Code Part Info for project :P2.', cost_structure_id_, project_id_);
   END IF;
   CLOSE record_exist;
END Validate_Cost_Elements;

@UncheckedAccess
FUNCTION Get_Project_Id (
   company_ IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   
   FUNCTION Base (
      company_ IN VARCHAR2,
      cost_structure_id_ IN VARCHAR2 ) RETURN VARCHAR2
   IS
      temp_ VARCHAR2(10);
   BEGIN
      IF (company_ IS NULL OR cost_structure_id_ IS NULL) THEN
         RETURN NULL;
      END IF;
      $IF Component_Proj_SYS.INSTALLED $THEN
         SELECT project_id
            INTO  temp_
            FROM  project_tab
            WHERE company = company_
            AND   cost_structure_id = cost_structure_id_;
         RETURN temp_;
      $ELSE
         RETURN NULL;
      $END
   EXCEPTION
      WHEN no_data_found THEN
         RETURN NULL;
      WHEN too_many_rows THEN
         Raise_Too_Many_Rows___(company_, cost_structure_id_, 'Get_Project_Id');
   END Base;

BEGIN
   RETURN Base(company_, cost_structure_id_);
END Get_Project_Id;

@UncheckedAccess 
FUNCTION Is_Valid_CBS (
   company_ IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   single_project_ IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   $IF Component_Proj_SYS.INSTALLED $THEN
      IF (
         (Project_API.Get_Proj_Count_to_CBS(company_, cost_structure_id_) = 1) AND 
         (Project_API.Is_Structure_Connected(company_, cost_structure_id_) = 'TRUE') 
         AND single_project_ = 'TRUE') THEN
            RETURN 'FALSE';
      ELSE
         RETURN 'TRUE';
      END IF;
   $ELSE
      RETURN 'TRUE';
   $END
END Is_Valid_CBS;


PROCEDURE Create_New_Structure(
   newrec_  IN OUT cost_structure_tab%ROWTYPE )
IS
BEGIN
   New___(newrec_);
END Create_New_Structure; 