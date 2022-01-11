-----------------------------------------------------------------------------
--
--  Logical unit: CostStructureUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Insert_Det___ (
   newrec_     IN OUT Cost_Structure_Det_Tab%ROWTYPE)
IS
   dummy_             NUMBER;
   CURSOR check_exist IS
      SELECT 1
      FROM   cost_structure_det_tab
      WHERE  company              = newrec_.company
      AND    cost_structure_id    = newrec_.cost_structure_id
      AND    level_id             = newrec_.level_id
      AND    structure_node       = newrec_.structure_node
      AND    project_cost_element = newrec_.project_cost_element;
BEGIN
   OPEN  check_exist;
   FETCH check_exist INTO dummy_;
   IF (check_exist%FOUND) THEN
      CLOSE check_exist;
   ELSE
      CLOSE check_exist;
      newrec_.rowversion := SYSDATE;
      INSERT INTO cost_structure_det_tab (
         company,
         cost_structure_id,
         level_id,
         level_id_desc,
         structure_node,
         structure_node_desc,
         item_below,
         item_below_desc,
         item_below_type,
         project_cost_element,
         item_above,
         level_seq,
         rowversion)
      VALUES (
         newrec_.company,
         newrec_.cost_structure_id,
         newrec_.level_id,
         newrec_.level_id_desc,
         newrec_.structure_node,
         newrec_.structure_node_desc,
         newrec_.item_below,
         newrec_.item_below_desc,
         newrec_.item_below_type,
         newrec_.project_cost_element,
         newrec_.item_above,
         newrec_.level_seq,
         newrec_.rowversion);
   END IF;
END Insert_Det___;


PROCEDURE Refresh_Structure_Cache___ (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
BEGIN
   DELETE 
   FROM   Analytic_Struct_Cache_Tab
   WHERE  company           = company_
   AND    cost_structure_id = cost_structure_id_;
   --
   INSERT INTO analytic_struct_cache_tab (
      company,
      cost_structure_id,
      project_cost_element,
      structure_node,
      structure_node_desc,
      level_id,
      level_id_desc,
      rowversion)
   SELECT a.company,
          a.cost_structure_id,
          a.project_cost_element,
          a.structure_node,
          a.structure_node_desc,
          a.level_id,
          a.level_id_desc,
          SYSDATE
   FROM   cost_structure_det_tab a
   WHERE  a.company           = company_
   AND    a.cost_structure_id = cost_structure_id_;
END Refresh_Structure_Cache___;


PROCEDURE Refresh_Comp_Struct_Cache___(
   company_       IN VARCHAR2)
IS
   CURSOR get_structures IS
      SELECT cost_structure_id
      FROM   Cost_Structure_tab
      WHERE   company = company_;
BEGIN
   FOR rec_ IN get_structures LOOP
      Refresh_Structure_Cache (company_, rec_.cost_structure_id, 'FALSE');
   END LOOP;

   DELETE 
   FROM   analytic_struct_cache_tab
   WHERE  company = company_;

   INSERT INTO analytic_struct_cache_tab (
      company,
      cost_structure_id,
      project_cost_element,
      structure_node,
      structure_node_desc,
      level_id,
      level_id_desc, 
      rowversion)
   SELECT a.company,
          a.cost_structure_id,
          a.project_cost_element,
          a.structure_node,
          a.structure_node_desc,
          a.level_id,
          a.level_id_desc,
          SYSDATE
   FROM   cost_structure_det_tab a
   WHERE  a.company = company_;

END Refresh_Comp_Struct_Cache___;


-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Refresh_All_Details__
IS
   company_           VARCHAR2(20);
   cost_structure_id_ VARCHAR2(20);
   prev_company_      VARCHAR2(20);
   CURSOR get_all IS
      SELECT c.company, cost_structure_id
      FROM   company_finance_auth1 c LEFT JOIN Cost_Structure s
      ON     c.company = s.company
      ORDER BY company, cost_structure_id;
BEGIN
   OPEN  get_all;
   FETCH get_all INTO company_, cost_structure_id_;
   prev_company_ := company_;
   WHILE get_all%FOUND LOOP
      Refresh_Structure_Cache (company_, cost_structure_id_, 'FALSE');
      company_ := NULL;
      FETCH get_all INTO company_, cost_structure_id_;
      -- only update the complete cache tables one time per company
      IF Nvl(company_,'####$$$$###') != prev_company_ THEN
         Refresh_Comp_Struct_Cache___ (prev_company_);
         prev_company_ := company_;
      END IF;
   END LOOP;
   CLOSE get_all; 
END Refresh_All_Details__;


PROCEDURE Refresh_Comp_Struct_Cache__ (
   company_       IN VARCHAR2)
IS
BEGIN
   Refresh_Comp_Struct_Cache___ (company_);
END Refresh_Comp_Struct_Cache__;


PROCEDURE Cascade_Company_Finance__ (
   company_       IN VARCHAR2 )
IS
BEGIN
   DELETE 
   FROM   cost_structure_det_tab
   WHERE  company = company_;
END Cascade_Company_Finance__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Refresh_Structure_Cache (
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2,
   refresh_company_   IN VARCHAR2 DEFAULT 'TRUE')
IS
   level_id_            VARCHAR2(200);
   structure_node_desc_ VARCHAR2(200);
   structure_node_      VARCHAR2(200);
   item_above_          VARCHAR2(200);
   item_below_          VARCHAR2(200);
   empty_detrec_        cost_structure_det_tab%ROWTYPE;
   detrec_              cost_structure_det_tab%ROWTYPE;
   level_id_desc_       VARCHAR2(200);
   level_seq_           NUMBER;
   
   CURSOR get_items IS
      SELECT l.level_id,
             l.description level_desc,
             i.name_value structure_node,
             i.description,
             i.name_value project_cost_element,
             i.item_above,
             l.level_no
      FROM   cost_structure_item_tab i, cost_structure_level_tab l
      WHERE  i.company                    = company_
      AND    i.cost_structure_id          = cost_structure_id_
      AND    i.cost_struct_item_type = 'COST_ELEMENT'
      AND    i.level_no                   = l.level_no
      AND    i.company                    = l.company
      AND    i.cost_structure_id          = l.cost_structure_id;

BEGIN

   DELETE 
   FROM   cost_structure_det_tab
   WHERE  company           = company_
   AND    cost_structure_id = cost_structure_id_;

   -- Start by fetching all leafs (code part values) and then traverse up the structure
   FOR recb_ IN get_items LOOP
      level_id_desc_                  := Cost_Structure_Level_API.Get_Description (company_, cost_structure_id_, recb_.level_id);
      structure_node_desc_            := Cost_Structure_Item_API.Get_Description_Db (company_, cost_structure_id_, recb_.item_above, 'NODE');
      detrec_.company                 := company_; 
      detrec_.cost_structure_id       := cost_structure_id_; 
      detrec_.level_id                := recb_.level_id;
      detrec_.level_id_desc           := level_id_desc_;
      detrec_.structure_node_desc     := structure_node_desc_;
      detrec_.structure_node          := recb_.item_above;
      detrec_.item_below              := recb_.project_cost_element;
      detrec_.item_below_desc         := Project_Cost_Element_API.Get_Description (company_, recb_.project_cost_element);
      detrec_.item_below_type         := 'COST_ELEMENT';  
      detrec_.project_cost_element    := recb_.project_cost_element;
      level_seq_                      := recb_.level_no;
      detrec_.level_seq               := level_seq_;

      -- Get the parent (node) to the current leaf (code part value)
      detrec_.item_above              := Cost_Structure_Item_API.Get_Item_Above (company_, cost_structure_id_, recb_.item_above, Cost_Struct_Item_Type_API.Decode('NODE'));
      Insert_Det___ (detrec_);

      detrec_                         := empty_detrec_;
      item_above_                     := recb_.item_above;
      structure_node_                 := item_above_;
      item_below_                     := structure_node_;
       -- Setting next structure_node_, based on the parent node of the current node
      structure_node_                 := Cost_Structure_Item_API.Get_Item_Above (company_, cost_structure_id_, structure_node_, Cost_Struct_Item_Type_API.Decode('NODE'));
      -- Start loop to traverse upwards in the structure, the currenct node is kept in structure_node_ variable. 
      -- item_below_ holds the node below the current node.
      -- item_above_ holds the node above the current node.

      LOOP
         -- Get the level_seq (level_no) using a method to handle asymetric structures
         level_seq_                   := Cost_Structure_Item_API.Get_Level_No__ (company_, cost_structure_id_, structure_node_);
         level_id_                    := Cost_Structure_Item_API.Get_Level_No (company_, cost_structure_id_, structure_node_, Cost_Struct_Item_Type_API.Decode('NODE'));
         level_id_desc_               := Cost_Structure_Level_API.Get_Description (company_, cost_structure_id_, level_id_);
         detrec_.item_below_desc      := structure_node_desc_;
         structure_node_desc_         := Cost_Structure_Item_API.Get_Description_Db (company_, cost_structure_id_, structure_node_, 'NODE');
         detrec_.company              := company_; 
         detrec_.cost_structure_id    := cost_structure_id_; 
         detrec_.level_id             := level_id_;
         detrec_.level_id_desc        := level_id_desc_;
         detrec_.structure_node       := structure_node_;
         detrec_.structure_node_desc  := structure_node_desc_;
         detrec_.item_below           := item_below_;
         detrec_.item_below_type      := 'NODE';  -- Structure Node
         detrec_.project_cost_element := recb_.project_cost_element;
         detrec_.level_seq            := level_seq_;

         -- Get the parent node (the node above) of the current node
         item_above_                  := Cost_Structure_Item_API.Get_Item_Above (company_, cost_structure_id_, detrec_.structure_node, Cost_Struct_Item_Type_API.Decode('NODE') );
         detrec_.item_above           := item_above_;
         -- store the current node as item below when moving up (using the loop) in the structure 
         item_below_                  := detrec_.structure_node;
         IF (detrec_.structure_node IS NOT NULL) THEN
            Insert_Det___ (detrec_);
            detrec_                   := empty_detrec_;
         END IF;
         -- If item_above is null then we have reached the top of the structure and can exit the inner loop
         IF (NVL(item_above_,' ') = ' ') THEN
            EXIT;
         ELSE
            -- Setting the current item above as next structure node when moving up (using the loop) in the structure.
            structure_node_           := item_above_;
         END IF;
      END LOOP;
   END LOOP;
   -- Update Analytic_Proj_Struct_Cache_Tab
   IF (refresh_company_ = 'TRUE') THEN
      Refresh_Structure_Cache___ (company_, cost_structure_id_); 

   END IF;
END Refresh_Structure_Cache;      


@UncheckedAccess
FUNCTION Get_Last_Refresh_Cache_Date (
   company_  IN VARCHAR2) RETURN DATE
IS
   temp_       DATE;
   CURSOR get_date IS
      SELECT MAX(rowversion)
      FROM   analytic_struct_cache_tab
      WHERE  company = company_;
BEGIN
   OPEN  get_date;
   FETCH get_date INTO temp_;
   CLOSE get_date;
   RETURN temp_;
END Get_Last_Refresh_Cache_Date;


PROCEDURE Remove_Structure_Cache(
   company_           IN VARCHAR2,
   cost_structure_id_ IN VARCHAR2)
IS
   
BEGIN
   DELETE 
   FROM   Cost_Structure_Det_Tab
   WHERE  company           = company_ 
   AND    cost_structure_id = cost_structure_id_; 
END Remove_Structure_Cache;

