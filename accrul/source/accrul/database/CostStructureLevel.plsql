-----------------------------------------------------------------------------
--
--  Logical unit: CostStructureLevel
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  160620  KGAMLK  FINLIFE-45, Moved ProjCostStructureLevel to ACCRUL as CostStructureLevel, Changes in plsql logic.
--  141118  NIPJLK  PRPJ-3427, Added the annotation @UncheckedAccess to the method Get_Level_Info__.
--  110221  THTHLK  HIGHPK-6967, Called Update_Level_Id() in structure item in Update___.
--  101118  Vwloza  HIGHPK-3382, technical correction.
--  100825  Ersruk   Added Exist_Level_Id().
--  100719  Ersruk   Added Check_Level_Id_Exist() and Get_Level_No().
--  100714  Ersruk   Added Level_Id_Exist___().
--  100712  Janslk   Changed Unpack_Check_Insert___ to not set a level_above if the level_no is 1.
--  100624  Janslk   Added validations for level_above.
--  100623  Janslk   Added levl column to PROJ_COST_STRUCTURE_LEVEL view. Also added 
--                   a connect by prior statement to the same view. Added method 
--                   a connect by prior statement to the same view. Added method Validate_Record_
--                   and called it from unpack_check methods.__
--  100518  Ersruk   Renamed STRUCTURE_ID to COST_STRUCTURE_ID
--  100505  Ersruk   Created
--  230918  Jadulk   Added procedure Get_Level_Id_Verison
--  270918  Jadulk   FIUXX-1687 Added Modify_Structure_Level
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Record___ (
   newrec_ IN cost_structure_level_tab%ROWTYPE)
IS
   temp_      NUMBER;
   CURSOR check_level_above IS
      SELECT 1 
      FROM   cost_structure_level_tab
      WHERE  company           = newrec_.company
      AND    cost_structure_id = newrec_.cost_structure_id
      AND    level_above       = newrec_.level_above
      AND    level_no         != newrec_.level_no;
BEGIN
   --if level_above is a level_above of some other level give an error message
   OPEN  check_level_above;
   FETCH check_level_above INTO temp_;
   CLOSE check_level_above;
   IF (temp_ = 1) THEN
      Error_SYS.Record_general( lu_name_, 'LEVELABOVEEXIST: Parent Level of this level is already a parent of another level.');
   END IF;
END Validate_Record___;


@Override
PROCEDURE Insert___ (
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   newrec_     IN OUT cost_structure_level_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2 )
IS
BEGIN
   super(objid_, objversion_, newrec_, attr_);
   BEGIN
      UPDATE cost_structure_level_tab
      SET    level_above             = newrec_.level_id
      WHERE  company                 = newrec_.company
      AND    cost_structure_id       = newrec_.cost_structure_id
      AND    NVL(level_above,chr(0)) = NVL(newrec_.level_above,chr(0))
      AND    level_no               != newrec_.level_no;
   EXCEPTION 
      WHEN OTHERS THEN NULL;
   END;
   Client_SYS.Add_To_Attr('LEVEL_NO',     newrec_.level_no,    attr_);
   Client_SYS.Add_To_Attr('LEVEL_ABOVE',  newrec_.level_above, attr_);
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Insert___;


@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     cost_structure_level_tab%ROWTYPE,
   newrec_     IN OUT cost_structure_level_tab%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS
   old_level_id_      VARCHAR2(200);
   level_id_          VARCHAR2(200);
   move_level_        BOOLEAN := FALSE;
BEGIN
   IF (Validate_SYS.Is_Changed(oldrec_.level_id, newrec_.level_id)) THEN
      move_level_  := TRUE;
   END IF;   
   
   old_level_id_   := oldrec_.level_id;
   IF by_keys_ THEN
      IF move_level_ THEN
         level_id_ := oldrec_.level_id;
      ELSE
         level_id_ := newrec_.level_id;
      END IF;
   END IF;

   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);

   IF (move_level_) THEN
      UPDATE cost_structure_level_tab
         SET level_above = newrec_.level_id
      WHERE  company           = newrec_.company
      AND    cost_structure_id = newrec_.cost_structure_id
      AND    level_above       = old_level_id_;
   END IF;
   IF (newrec_.level_id != oldrec_.level_id) THEN
      --update structure item(exist checks in structutre item)
      Cost_Structure_Item_API.Update_Level_Id (newrec_.company, newrec_.cost_structure_id, oldrec_.level_id, newrec_.level_id);
   END IF;

EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN cost_structure_level_tab%ROWTYPE )
IS
BEGIN
   IF (Cost_Structure_Item_API.Is_Level_Exist(remrec_.company, remrec_.cost_structure_id, remrec_.level_no) = 'TRUE') THEN
      Error_Sys.Appl_General(lu_name_, 'LEVELUSED: Level :P1 is used within the structure :P2',remrec_.level_no, remrec_.cost_structure_id  );
   END IF;   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT cost_structure_level_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   next_level_    NUMBER;   
   CURSOR next_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_level_tab
      WHERE  company           = newrec_.company
      AND    cost_structure_id = newrec_.cost_structure_id;
BEGIN
   IF (newrec_.level_no IS NULL) OR (newrec_.level_above IS NULL) THEN
      OPEN  next_level_no;
      FETCH next_level_no INTO next_level_;
      CLOSE next_level_no;
      --Set Level No-increment max by 1
      IF (newrec_.level_no IS NULL) THEN
         IF (next_level_ IS NULL) THEN
            newrec_.level_no := 1;
         ELSE
            newrec_.level_no := next_level_+1;
         END IF;
      END IF;
      --Set level above-to max level no if not the top node
      IF (newrec_.level_above IS NULL AND newrec_.level_no != 1) THEN
         IF (next_level_ IS NULL) THEN
            newrec_.level_above := NULL;
         ELSE
            newrec_.level_above := Get_Level_Id(newrec_.company, newrec_.cost_structure_id, next_level_);
         END IF;
      END IF;
   END IF;
   --Set Level Id
   IF (newrec_.level_id IS NULL) THEN
      newrec_.level_id := newrec_.level_no;
   END IF;
   --Set Level Desc
   IF (newrec_.description IS NULL) THEN
      newrec_.description := '<' || newrec_.level_id || '>';
   END IF;
   --Level_Id should act as key
   IF ( Check_Level_Id_Exist(newrec_.company, newrec_.cost_structure_id, newrec_.level_id)= 'TRUE') THEN
      Error_SYS.Record_general( lu_name_, 'LEVELIDEXIST: Level ID :P1 already exist.', newrec_.level_id);
   END IF; 

   super(newrec_, indrec_, attr_);

   IF (indrec_.level_above AND newrec_.level_above IS NOT NULL) THEN
      IF (Check_Level_Id_Exist(newrec_.company, newrec_.cost_structure_id, newrec_.level_above)= 'FALSE') THEN
         Error_SYS.Record_Not_Exist(lu_name_);
      END IF;
   END IF; 
   Validate_Record___( newrec_ );
END Check_Insert___;


@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     cost_structure_level_tab%ROWTYPE,
   newrec_ IN OUT cost_structure_level_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   dummy_         NUMBER;
   old_level_id_  cost_structure_level_tab.level_id%TYPE;
   CURSOR check_level_id IS
      SELECT 1
      FROM   cost_structure_level_tab
      WHERE  company           = newrec_.company
      AND    cost_structure_id = newrec_.cost_structure_id
      AND    level_id          = newrec_.level_id
      AND    level_no         != newrec_.level_no;
BEGIN
   super(oldrec_, newrec_, indrec_, attr_);
   
      OPEN  check_level_id;
      FETCH check_level_id INTO dummy_;
      IF (check_level_id%FOUND) THEN
         CLOSE check_level_id;
         Error_SYS.Record_general( lu_name_, 'LEVELIDEXIST: Level ID :P1 already exist.', newrec_.level_id);
      END IF;
      CLOSE check_level_id;
   
      IF (indrec_.level_above AND newrec_.level_above IS NOT NULL) THEN
      IF (Check_Level_Id_Exist(newrec_.company, newrec_.cost_structure_id, newrec_.level_above)= 'FALSE') THEN
         Error_SYS.Record_Not_Exist(lu_name_);
      END IF;
   END IF;   
   --Level_Id should act as key
   IF (old_level_id_ != newrec_.level_id) AND ( Check_Level_Id_Exist(newrec_.company, newrec_.cost_structure_id, newrec_.level_id)= 'TRUE') THEN
      Error_SYS.Record_Exist(lu_name_);
   END IF;
   Validate_Record___(newrec_);
END Check_Update___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Level__(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
   attr_                 VARCHAR2(4000);
   objid_                cost_structure_level.objid%TYPE;
   objversion_           cost_structure_level.objversion%TYPE;
   newrec_               cost_structure_level_tab%ROWTYPE;
   indrec_               Indicator_Rec;
   next_level_           NUMBER;
   level_above_rec_      cost_structure_level_tab%ROWTYPE;
   level_above_          VARCHAR2(20);
   CURSOR max_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;
BEGIN
   OPEN  max_level_no;
   FETCH max_level_no INTO next_level_;
   CLOSE max_level_no;
   IF next_level_ IS NULL THEN
      next_level_  := 1;
      level_above_ := NULL;
   ELSE
      level_above_rec_ := Lock_By_Keys___(company_,
      cost_structure_id_,
      next_level_);
      level_above_     := level_above_rec_.level_id;
      UPDATE cost_structure_level_tab
         SET bottom_level = NULL
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_no          = next_level_;
      next_level_ := next_level_+1;
   END IF;
   IF NOT (Check_Exist___(company_, cost_structure_id_, next_level_)) THEN
      Client_SYS.Clear_Attr( attr_);
      Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
      Client_SYS.Add_To_Attr( 'COST_STRUCTURE_ID', cost_structure_id_, attr_);
      Client_SYS.Add_To_Attr( 'LEVEL_ID', next_level_, attr_);
      Client_SYS.Add_To_Attr( 'DESCRIPTION', '<' || next_level_ || '>', attr_);
      Client_SYS.Add_To_Attr( 'LEVEL_ABOVE', level_above_, attr_);
      Client_SYS.Add_To_Attr( 'BOTTOM_LEVEL', 'TRUE', attr_);
      Client_SYS.Add_To_Attr( 'LEVEL_NO', next_level_, attr_);
      Unpack___(newrec_, indrec_, attr_);
      Check_Insert___(newrec_, indrec_, attr_);
      Insert___(objid_, objversion_, newrec_, attr_);
   END IF;
END Insert_Level__;


@UncheckedAccess
PROCEDURE Get_Level_Info__(
   level_id_          OUT VARCHAR2,
   description_       OUT VARCHAR2,
   objid_             OUT VARCHAR2,
   objversion_        OUT VARCHAR2,
   company_           IN  VARCHAR2,
   cost_structure_id_ IN  VARCHAR2,
   level_no_          IN  NUMBER )
IS
   CURSOR get_level_info IS
      SELECT level_id, description, rowid, to_char(rowversion,'YYYYMMDDHH24MISS')
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_no          = level_no_;
BEGIN
   OPEN  get_level_info;
   FETCH get_level_info INTO level_id_, description_, objid_, objversion_;
   CLOSE get_level_info;
END Get_Level_Info__;


PROCEDURE Delete_Unused_Levels__(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
   level_no_             NUMBER;
   CURSOR max_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_item_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;
BEGIN
   OPEN  max_level_no;
   FETCH max_level_no INTO level_no_;
   CLOSE max_level_no;

   DELETE
   FROM   cost_structure_level_tab a
   WHERE  company           = company_
   AND    cost_structure_id = cost_structure_id_
   AND    level_no          > level_no_;

   OPEN  max_level_no;
   FETCH max_level_no INTO level_no_;
   CLOSE max_level_no;

   UPDATE cost_structure_level_tab
      SET bottom_level = 'TRUE'
   WHERE  company           = company_
   AND    cost_structure_id = cost_structure_id_
   AND    level_no          = level_no_;
END Delete_Unused_Levels__;


PROCEDURE New_Top_Level__(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
   attr_                 VARCHAR2(4000);
   objid_                cost_structure_level.objid%TYPE;
   objversion_           cost_structure_level.objversion%TYPE;
   newrec_               cost_structure_level_tab%ROWTYPE;
   next_level_           NUMBER;
   indrec_               Indicator_Rec;
   CURSOR max_level_no IS
      SELECT MAX(level_no)
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_;
BEGIN
   OPEN  max_level_no;
   FETCH max_level_no INTO next_level_;
   CLOSE max_level_no;

   next_level_ := next_level_+1;
   UPDATE cost_structure_level_tab
      SET level_above = next_level_
   WHERE  company           =  company_
   AND    cost_structure_id = cost_structure_id_
   AND    level_above       = NULL;
   
   UPDATE cost_structure_level_tab
      SET level_no = level_no+1
   WHERE  company           =  company_
   AND    cost_structure_id = cost_structure_id_;
   Client_SYS.Clear_Attr( attr_);

   Client_SYS.Add_To_Attr( 'COMPANY', company_, attr_);
   Client_SYS.Add_To_Attr( 'COST_STRUCTURE_ID', cost_structure_id_, attr_);
   Client_SYS.Add_To_Attr( 'LEVEL_ID', next_level_, attr_);
   Client_SYS.Add_To_Attr( 'DESCRIPTION', '<' || next_level_ || '>', attr_);
   Client_SYS.Add_To_Attr( 'LEVEL_ABOVE', '', attr_);
   Client_SYS.Add_To_Attr( 'BOTTOM_LEVEL', '', attr_);
   Client_SYS.Add_To_Attr( 'LEVEL_NO', '1', attr_);
   Unpack___(newrec_, indrec_, attr_);
   Check_Insert___(newrec_, indrec_, attr_);
   Insert___(objid_, objversion_, newrec_, attr_);
END New_Top_Level__;


PROCEDURE Copy__ (
   company_               IN VARCHAR2,
   cost_structure_id_     IN VARCHAR2,
   new_cost_structure_id_ IN VARCHAR2 )
IS
   rec2_                     cost_structure_level_tab%ROWTYPE;
   rec3_                     cost_structure_level_tab%ROWTYPE;
   attr_                     VARCHAR2(4000);
   objid_                    cost_structure_level.objid%TYPE;
   objversion_               cost_structure_level.objversion%TYPE;
   indrec_                   Indicator_Rec;
   CURSOR get_cost_structure_level IS
      SELECT *
      FROM   cost_structure_level_tab
      WHERE  company = company_
      AND    cost_structure_id = cost_structure_id_
      ORDER BY level_no ASC;
BEGIN
   Cost_Structure_API.Exist(company_, cost_structure_id_);
   Cost_Structure_API.Exist(company_, new_cost_structure_id_);
   FOR rec_ IN get_cost_structure_level LOOP
      Client_SYS.Clear_Attr( attr_);
      IF rec_.bottom_level IS NULL THEN
         Client_SYS.Add_To_Attr('COMPANY', company_, attr_);
         Client_SYS.Add_To_Attr('COST_STRUCTURE_ID', new_cost_structure_id_, attr_);
         Client_SYS.Add_To_Attr('LEVEL_NO', rec_.level_no, attr_);
         Client_SYS.Add_To_Attr('LEVEL_ID', rec_.level_id, attr_);
         Client_SYS.Add_To_Attr('DESCRIPTION', rec_.description, attr_);
         Client_SYS.Add_To_Attr('BOTTOM_LEVEL', rec_.bottom_level, attr_);
         Client_SYS.Add_To_Attr('LEVEL_ABOVE', rec_.level_above, attr_);
         rec2_.company           := rec_.company;
         rec2_.cost_structure_id := rec_.cost_structure_id;
         rec2_.level_no          := rec_.level_no;
         rec2_.level_id          := rec_.level_id;
         rec2_.description       := rec_.description;
         rec2_.bottom_level      := rec_.bottom_level;
         rec2_.level_above       := rec_.level_above;
         Unpack___(rec2_, indrec_, attr_);
         Check_Insert___(rec2_, indrec_, attr_);
         Insert___(objid_, objversion_, rec2_, attr_);
      ELSE
         Get_Id_Version_By_Keys___( objid_, objversion_, company_, new_cost_structure_id_, rec_.level_no);
         Client_SYS.Add_To_Attr( 'DESCRIPTION', rec_.description, attr_);
         rec2_.company           := rec_.company;
         rec2_.cost_structure_id := new_cost_structure_id_;
         rec2_.level_no          := rec_.level_no;
         rec2_.level_id          := rec_.level_id;
         rec2_.description       := rec_.description;
         rec2_.bottom_level      := rec_.bottom_level;
         rec2_.level_above       := rec_.level_above;
         rec3_                   := Get_Object_By_Keys___( company_, rec_.cost_structure_id, rec_.level_no);
         rec2_.description       := rec3_.description;
         rec2_.bottom_level      := rec3_.bottom_level;
         rec2_.level_above       := rec3_.level_above;
         Unpack___(rec2_, indrec_, attr_);
         Check_Insert___(rec2_, indrec_, attr_);
         Insert___( objid_, objversion_, rec2_, attr_);
      END IF;
   END LOOP;
END Copy__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Exist_Level_Id (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_id_          IN VARCHAR2)
IS
BEGIN
   IF (Check_Level_Id_Exist(company_, cost_structure_id_, level_id_)='FALSE') THEN
      Error_SYS.Record_Not_Exist(lu_name_);
   END IF;
END Exist_Level_Id;

@UncheckedAccess
FUNCTION Get_Level_Position (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_id_          IN VARCHAR2) RETURN NUMBER
IS
   level_    NUMBER;
   CURSOR get_level IS
      SELECT level
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_id          = level_id_
      START WITH level_above   IS NULL
      CONNECT BY company       = PRIOR company
      AND        cost_structure_id = PRIOR cost_structure_id
      AND        level_above   = PRIOR level_id;
BEGIN
   OPEN  get_level;
   FETCH get_level INTO level_;
   IF get_level%NOTFOUND THEN
      level_ := NULL;
   END IF;
   CLOSE get_level;
   RETURN level_;
END Get_Level_Position;

@UncheckedAccess
FUNCTION Check_Level_Id_Exist (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_id_          IN VARCHAR2) RETURN VARCHAR2
IS
   dummy_   NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_id          = level_id_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Level_Id_Exist;

@UncheckedAccess
FUNCTION Get_Level_No (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_id_          IN VARCHAR2 ) RETURN NUMBER
IS
   temp_   cost_structure_level_tab.level_no%TYPE;
   CURSOR get_attr IS
      SELECT level_no
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_id          = level_id_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Level_No;

@UncheckedAccess
FUNCTION Get_Description (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_id_          IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_                 cost_structure_level_tab.description%TYPE;
   CURSOR get_attr IS
      SELECT description
      FROM   cost_structure_level_tab
      WHERE  company           = company_
      AND    cost_structure_id = cost_structure_id_
      AND    level_id          = level_id_;
BEGIN
   OPEN  get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Description;

PROCEDURE Get_Level_Id_Verison (
   objid_             IN OUT VARCHAR2,
   objversion_        IN OUT VARCHAR2,
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   level_no_          IN NUMBER)
IS
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_, company_, cost_structure_id_, level_no_);   
END Get_Level_Id_Verison;   

PROCEDURE Modify_Structure_Level(
   level_rec_    IN OUT  cost_structure_level_tab%ROWTYPE)
IS
BEGIN
   Modify___(level_rec_, TRUE);
END Modify_Structure_Level;   


