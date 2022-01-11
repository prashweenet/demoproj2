-------------------------------------------------------------------------------
--
--  Filename      : Post_Accrul_CopyDataToNewCostStructureTables.sql
--
--  Module        : ACCRUL
--
--  Purpose       : This script will insert data from the tables related to Cost Breakdown Structures in the PROJ component to ACCRUL
--
--
--  Date    Sign    History
--  ------  ------  -------------------------------------------------------------
--  160518  kgamlk  Created
--
---------------------------------------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_1');
PROMPT Post_Accrul_CopyDataToNewCostStructureTables.SQL

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_2');
PROMPT Copy data from PROJ_COST_STRUCTURE_300 to Cost_Structure_tab

DECLARE
   table_name_     VARCHAR2(30) := 'PROJ_COST_STRUCTURE_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'INSERT INTO Cost_Structure_tab
               (  company ,
                  cost_structure_id ,
                  description ,
                  template ,
                  copied_from ,
                  note,
                  rowstate ,
                  rowversion ,
                  rowkey )
               (SELECT
                  company ,
                  cost_structure_id ,
                  description ,
                  template ,
                  copied_from ,
                  note ,
                  rowstate ,
                  rowversion ,
                  rowkey
               FROM proj_cost_structure_300 pt
               WHERE NOT EXISTS (SELECT 1
                                 FROM  Cost_Structure_tab
                                 WHERE company           = pt.company
                                 AND   cost_structure_id = pt.cost_structure_id
                    ))';
   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_ ;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_3');
PROMPT Copy data from PROJ_COST_STRUCTURE_LEVEL_300 to COST_STRUCTURE_LEVEL_TAB

DECLARE
   table_name_     VARCHAR2(30) := 'PROJ_COST_STRUCTURE_LEVEL_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'INSERT INTO COST_STRUCTURE_LEVEL_TAB
               (  company ,
                  cost_structure_id  ,
                  level_no  ,
                  description  ,
                  level_id  ,
                  bottom_level  ,
                  level_above  ,
                  rowversion  ,
                  rowkey)
               (SELECT
                  company ,
                  cost_structure_id  ,
                  level_no  ,
                  description  ,
                  level_id  ,
                  bottom_level  ,
                  level_above  ,
                  rowversion  ,
                  rowkey
               FROM PROJ_COST_STRUCTURE_LEVEL_300 pl
               WHERE NOT EXISTS( SELECT 1
                                 FROM  COST_STRUCTURE_LEVEL_TAB
                                 WHERE company           = pl.company
                                 AND   cost_structure_id = pl.cost_structure_id
                                 AND   level_no          = pl.level_no))';
   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_ ;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_4');
PROMPT Copy data from PROJ_COST_STRUCTURE_ITEM_300 to COST_STRUCTURE_ITEM_TAB

DECLARE
   table_name_     VARCHAR2(30) := 'PROJ_COST_STRUCTURE_ITEM_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'INSERT INTO COST_STRUCTURE_ITEM_TAB
               (  company ,
                  cost_structure_id  ,
                  name_value   ,
                  cost_struct_item_type    ,
                  description   ,
                  level_no   ,
                  level_id   ,
                  item_above   ,
                  rowversion ,
                  rowkey ,
                  element_type )
               (SELECT
                  company ,
                  cost_structure_id  ,
                  name_value   ,
                  proj_cost_struct_item_type   ,
                  description   ,
                  level_no   ,
                  level_id   ,
                  item_above   ,
                  rowversion ,
                  rowkey ,
                  element_type
               FROM PROJ_COST_STRUCTURE_ITEM_300 pi
               WHERE NOT EXISTS( SELECT 1
                                 FROM COST_STRUCTURE_ITEM_TAB
                                 WHERE company                 = pi.company
                                 AND   cost_structure_id       = pi.cost_structure_id
                                 AND   name_value              = pi.name_value
                                 AND   cost_struct_item_type   = pi.proj_cost_struct_item_type))';
   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_ ;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_5');
PROMPT Copy data from ANALYTIC_PROJ_STRUCT_CACHE_300 to ANALYTIC_STRUCT_CACHE_TAB

DECLARE
   table_name_     VARCHAR2(30) := 'ANALYTIC_PROJ_STRUCT_CACHE_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'INSERT INTO ANALYTIC_STRUCT_CACHE_TAB
               (  company ,
                  cost_structure_id ,
                  project_cost_element ,
                  structure_node    ,
                  level_id ,
                  rowversion ,
                  structure_node_desc ,
                  level_id_desc )
               (SELECT
                  company ,
                  cost_structure_id ,
                  project_cost_element ,
                  structure_node    ,
                  level_id ,
                  rowversion ,
                  structure_node_desc ,
                  level_id_desc
          FROM ANALYTIC_PROJ_STRUCT_CACHE_300 ac
          WHERE NOT EXISTS(   SELECT 1
                              FROM ANALYTIC_STRUCT_CACHE_TAB
                              WHERE company              = ac.company
                              AND   cost_structure_id    = ac.cost_structure_id
                              AND   project_cost_element = ac.project_cost_element
                              AND   structure_node       = ac.structure_node
                              AND   level_id             = ac.level_id))';
   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_ ;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_6');
PROMPT Copy data from PROJ_COST_STRUCTURE_DET_300 to COST_STRUCTURE_DET_TAB

DECLARE
   table_name_     VARCHAR2(30) := 'PROJ_COST_STRUCTURE_DET_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'INSERT INTO COST_STRUCTURE_DET_TAB
               (  company ,
                  cost_structure_id ,
                  level_id  ,
                  structure_node  ,
                  project_cost_element   ,
                  level_id_desc  ,
                  structure_node_desc  ,
                  item_above  ,
                  item_below ,
                  item_below_desc ,
                  item_below_type ,
                  level_seq ,
                  rowversion )
               (SELECT
                  company ,
                  cost_structure_id ,
                  level_id  ,
                  structure_node  ,
                  project_cost_element     ,
                  level_id_desc  ,
                  structure_node_desc  ,
                  item_above  ,
                  item_below ,
                  item_below_desc ,
                  item_below_type ,
                  level_seq ,
                  rowversion
          FROM PROJ_COST_STRUCTURE_DET_300 ps
          WHERE NOT EXISTS(   SELECT 1
                              FROM COST_STRUCTURE_DET_TAB
                              WHERE company              = ps.company
                              AND   cost_structure_id    = ps.cost_structure_id
                              AND   project_cost_element = ps.project_cost_element
                              AND   structure_node       = ps.structure_node
                              AND   level_id             = ps.level_id))';
   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_ ;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_7');
PROMPT SET single_project TO TRUE IN cost_structure_tab
DECLARE
   table_name_     VARCHAR2(30) := 'PROJ_COST_STRUCTURE_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'UPDATE cost_structure_tab c
            SET c.single_project = ''TRUE''
            WHERE EXISTS (SELECT 1
                           FROM proj_cost_structure_300 pc
                	         WHERE c.company  = pc.company
                           AND c.cost_structure_id = pc.cost_structure_id
                           AND pc.project_id IS NOT NULL
                           AND pc.multiple_projects  = ''FALSE'')';

   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Timestamp_8');
PROMPT SET single_project TO FALSE IN cost_structure_tab
DECLARE
   table_name_     VARCHAR2(30) := 'PROJ_COST_STRUCTURE_300';
   stmt_           VARCHAR2(3000);
BEGIN
   stmt_ := 'UPDATE cost_structure_tab c
            SET c.single_project = ''FALSE''
            WHERE EXISTS (SELECT 1
                           FROM proj_cost_structure_300 pc
                  	      WHERE c.company  = pc.company
                           AND c.cost_structure_id = pc.cost_structure_id
                           AND pc.multiple_projects  = ''TRUE'')';

   IF (Database_SYS.Table_Exist(table_name_)) THEN
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_CopyDataToNewCostStructureTables.sql','Done');
