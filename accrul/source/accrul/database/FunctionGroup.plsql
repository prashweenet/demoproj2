-----------------------------------------------------------------------------
--
--  Logical unit: FunctionGroup
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  000606  Uma   Created
--  000807  Uma   Added VIEW1.
--  000912  HiMu  Added General_SYS.Init_Method
--  001018  Uma   Removed encode and decode functions and row_no in view FUNCTION_GROUP.
--  001113  ANDJ  Mod. to patch in insert_function_group.
--  001113  ANDJ  Bug# 18299, interface Voucher_Group_API.Insert_Voucher_Group
--  050624  Thpelk Call Id 125167 Added View View1
--  090605  THPELK Bug 82609 - Added missing UNDEFINE statements for VIEW1 
------------SIZZLER----------------------------------------------------------
--  110901  Ersruk Added PC in where statement in view FUNCTION_GROUP_INT.
--  -------------------------------------------------------------------------
--  131101  PRatlk PBFI-2043, Refactored according to the new template
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Insert_Lu_Data_Rec__ (
   in_newrec_ IN FUNCTION_GROUP_TAB%ROWTYPE )
IS
   newrec_     FUNCTION_GROUP_TAB%ROWTYPE := in_newrec_;
BEGIN
   --
   Basic_Data_Translation_API.Insert_Prog_Translation(
      'ACCRUL',
      lu_name_,
      newrec_.function_group,
      newrec_.description);
   --
   -- proj_conn_vou_row_support can only be FALSE if project_conn_supported is FALSE
   IF newrec_.project_conn_supported = 'FALSE' THEN
      newrec_.proj_conn_vou_row_support := 'FALSE';
   END IF;
   
   UPDATE FUNCTION_GROUP_TAB
      SET description = newrec_.description,
          par_amount_balanced_in_src = newrec_.par_amount_balanced_in_src,
          automatic_allotment_req = newrec_.automatic_allotment_req,
          store_original_mandatory = newrec_.store_original_mandatory,
          store_original_allowed = newrec_.store_original_allowed,
          single_function_required = newrec_.single_function_required,
          conn_func_group_allowed = newrec_.conn_func_group_allowed,
          simulation_voucher_allowed = newrec_.simulation_voucher_allowed,
          internal_ledger_allowed = newrec_.internal_ledger_allowed,  
          automatic_voucher_balance = newrec_.automatic_voucher_balance,
          vou_row_grp_val_allowed = newrec_.vou_row_grp_val_allowed,
          ref_mandatory_allowed = newrec_.ref_mandatory_allowed,
          sep_user_approval_allowed = newrec_.sep_user_approval_allowed,
          project_conn_supported = newrec_.project_conn_supported,          
          proj_conn_vou_row_support = newrec_.proj_conn_vou_row_support,          
          manual = newrec_.manual,             
          rowversion = newrec_.rowversion
   WHERE function_group = newrec_.function_group;
   IF (SQL%NOTFOUND) THEN
      INSERT INTO FUNCTION_GROUP_TAB(
         function_group,
         description,
         par_amount_balanced_in_src,
         automatic_allotment_req,
         store_original_mandatory,
         store_original_allowed,
         single_function_required,
         conn_func_group_allowed,
         simulation_voucher_allowed,
         internal_ledger_allowed,
         automatic_voucher_balance,
         vou_row_grp_val_allowed,
         ref_mandatory_allowed,
         sep_user_approval_allowed,
         project_conn_supported,
         proj_conn_vou_row_support,
         manual,
         rowversion )
      VALUES (
         newrec_.function_group,
         newrec_.description,
         newrec_.par_amount_balanced_in_src,
         newrec_.automatic_allotment_req,
         newrec_.store_original_mandatory,
         newrec_.store_original_allowed,
         newrec_.single_function_required,
         newrec_.conn_func_group_allowed,
         newrec_.simulation_voucher_allowed,
         newrec_.internal_ledger_allowed,
         newrec_.automatic_voucher_balance,
         newrec_.vou_row_grp_val_allowed,
         newrec_.ref_mandatory_allowed,
         newrec_.sep_user_approval_allowed,
         newrec_.project_conn_supported,
         newrec_.proj_conn_vou_row_support,
         newrec_.manual,
         newrec_.rowversion );
   END IF;
   --
END Insert_Lu_Data_Rec__;


-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
@UncheckedAccess
FUNCTION Get_Basic_Data_Info_Text RETURN VARCHAR2
IS
   fgroup_basic_data_txt_  VARCHAR2(200);
BEGIN
   fgroup_basic_data_txt_ := Language_SYS.Translate_Constant(lu_name_, 'FUNCGROUPWIN: See Function Group basic data for available options.');
   RETURN fgroup_basic_data_txt_;
END Get_Basic_Data_Info_Text;

@UncheckedAccess
PROCEDURE Get_Function_Group_Msg (
   msg_        OUT   VARCHAR2)
IS
   --msg_           VARCHAR2(32000);
   row_msg_       VARCHAR2(2000);   
   i_             PLS_INTEGER := 1;   
   count_         PLS_INTEGER := 0;
   
   CURSOR get_function_groups IS
      SELECT *
      FROM   function_group_tab
      ORDER BY function_group;   
BEGIN
   msg_ := Message_SYS.Construct('FUNCTION_GROUP_DATA');   
   FOR rec_ IN get_function_groups LOOP
      row_msg_ := NULL;
      row_msg_ := Message_SYS.Construct('ROW_DATA');
      count_ := count_ + 1;
      Message_SYS.Add_Attribute(row_msg_, 'PAR_AMOUNT_BALANCED_IN_SRC', rec_.par_amount_balanced_in_src);
      Message_SYS.Add_Attribute(row_msg_, 'AUTOMATIC_ALLOTMENT_REQ', rec_.automatic_allotment_req);
      Message_SYS.Add_Attribute(row_msg_, 'STORE_ORIGINAL_MANDATORY', rec_.store_original_mandatory);   
      Message_SYS.Add_Attribute(row_msg_, 'STORE_ORIGINAL_ALLOWED', rec_.store_original_allowed);      
      
      Message_SYS.Add_Attribute(row_msg_, 'SINGLE_FUNCTION_REQUIRED', rec_.single_function_required);
      Message_SYS.Add_Attribute(row_msg_, 'CONN_FUNC_GROUP_ALLOWED', rec_.conn_func_group_allowed);
      Message_SYS.Add_Attribute(row_msg_, 'SIMULATION_VOUCHER_ALLOWED', rec_.simulation_voucher_allowed);   
      Message_SYS.Add_Attribute(row_msg_, 'INTERNAL_LEDGER_ALLOWED', rec_.internal_ledger_allowed);      
      
      Message_SYS.Add_Attribute(row_msg_, 'AUTOMATIC_VOUCHER_BALANCE', rec_.automatic_voucher_balance);
      Message_SYS.Add_Attribute(row_msg_, 'VOU_ROW_GRP_VAL_ALLOWED', rec_.vou_row_grp_val_allowed);
      Message_SYS.Add_Attribute(row_msg_, 'REF_MANDATORY_ALLOWED', rec_.ref_mandatory_allowed);   
      Message_SYS.Add_Attribute(row_msg_, 'SEP_USER_APPROVAL_ALLOWED', rec_.sep_user_approval_allowed);            
      Message_SYS.Add_Attribute(row_msg_, 'PROJECT_CONN_SUPPORTED', rec_.project_conn_supported);            

      Message_SYS.Add_Attribute(row_msg_, 'DESCRIPTION', substr(nvl(Basic_Data_Translation_API.Get_Basic_Data_Translation('ACCRUL', 'FunctionGroup', rec_.function_group), rec_.description), 1, 100));                  
      Message_SYS.Add_Attribute(msg_, rec_.function_group, row_msg_);      
      --Message_SYS.Add_Attribute(msg, TO_CHAR(i_), row_msg_);      
      i_ := i_ + 1;
   END LOOP;
   IF (count_ = 0) THEN
      msg_ := NULL;
   END IF;
   
END Get_Function_Group_Msg;