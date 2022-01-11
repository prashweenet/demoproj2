-----------------------------------------------------------------------------
--
--  Logical unit: VoucherRow
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  960416  xxxx   Base Table to Logical Unit Generator 1.0A
--  990710  Dhar   New version.
--  990927  Uma    Fixed Bug 11716
--  991103  SaCh   Fixed Bug # 67469
--  000229  Ruwan  Bug #32739 fixed.
--  000309  Uma    Closed dynamic cursors in Exceptions.
--  000313  Upul   Fixed Bug # 36028
--  000315  Uma    Added dynamic cursor in procedure Check_Project___.
--  000322  HiMu   Bug # 37332 fixed 
--  000414  SaCh   Added RACreate_Multi_Company_VoucherISE to exceptions.
--  000529  Uma    Fixed Bug Id #41419.
--  000531  Uma    Fixed Bug Id #41865.
--  000707  BmEk   A527: Added columns in VOUCHER_ROW and added call to
--                 Account_Tax_Code_API.Check_Tax_Code in Unpack_Check_Insert___
--                 and Unpack_Check_Update___
--  000712  AsWi   Added procedures Internal_Manual_Postings___, Delete_Internal_Rows___
--                 to handle Internal manual postings.
--  000724  Uma    A536: Journal Code.
--  000808  Uma    Fixed Bug Id #16905
--  000811  BmEk   A527: Modified view Voucher_Row
--  000829  BmEk   A527: Replaced tax_method_manual with tax_direction
--  000904  BmEk   A527: Added columns in Vocher_Row. Also added Create_Tax_Transaction___,
--                 Check_Overwriting_Level___, Delete_Tax_Transaction___ and
--                 Calculate_Net_From_Gross.
--  000906  BmEk   A527: Added tax_base_amount and currency_tax_base_amount in
--                 Voucher_Row
--  000908  BmEk   A527: Added auto_tax_vou_entry in VOUCHER_ROW_QRY
--  000912  BmEk   A527: Added check on function_group in Unpack_Check_Insert and
--                 Unpack_Check_Update.
--  000918  Uma    Corrected Bug ID #48556/48558 - Added function_group to Insert_Row__.
--  000920  BmEk   A527: Modifed Modify__ (moved call to Delete_Tax_Transaction___).
--  000918  Uma    Corrected Bug ID #48556/48558 - Added function_group to Add_New_Row_.
--  000926  BmEk   A520: Added Tax_Code_In_Voucher_Row
--  001004  BmEk   A527: Added Get_Correction_All__, Prepare_Tax_Transaction___ and
--                 Counter_Tax_Transaction___
--  001013  prtilk BUG # 15677  Checked General_SYS.Init_Method
--  001017  BmEk   A807: Added check if tax code is mandatory in Voucher Entry.
--  001019  Chjalk Bug # 50240 (Foreign call id 16974) Fixed.
--  001020  BmEk   A527: Modifed Counter_Tax_Transaction___.
--  001026  Uma    Did Changes regarding function_group - uu.
--  001026  Uma    Corrected  Bug #51069.
--  001027  LaLi   Modified Check_Acquisition___ and Check_Code_String_Fa___
--  001030  BmEk   A527: Modifed Counter_Tax_Transaction___.
--  001030  BmEk   Call #51423. Added check on simulation voucher.
--  001219  Chajlk Call Id 18577 Corrected.
--  010115  Camk   Bug #19040 Corrected
--  010118         Bug #19146 Corrected.
--  010221  ToOs   Bug # 20177 Added Global Lu constants for check for transaction_sys calls
--  010226  ToOs   Bug # 20254 Added a check IF intled is installed
--  010425  DIFELK Bug # 21452 corrected. Deleted unused cursor(get_manual_count)
--                 and a variable(manual_count_) in procedure Create_Int_Manual_Postings__.
--  010427  JeGu   Bug #21600 Performance, Some Code Cleanup
--  010508  JeGu   Bug #21705 Implementation New Dummyinterface
--                 Changed Insert__ RETURNING rowid INTO objid_
--  010608  JeGu   Bug #22421 Added columns year_period_key and posting_combination_id
--                 to views and inserts.
--                 New view (VIEW3) VOUCHER_ROW_QRY_FINREP created
--                 New view (VIEW4) VOUCHER_ROW_QRY_PID_FINREP created
--  010704  JeGu   Bug #23059, Modified view VOUCHER_ROW_QRY
--  010712  Lali   Bug #23212 - Bad integration Accrul-FIxass
--  010713  LaLi   Bug #23251 - Integration Accrul-Genled-Fixass
--  010719  SUMALK Bug #22932 Fixed.Removed Dynamic Sql and added Execute Immediate.
--  010815  JeGu   Bug #23726 New columns object_id and voucher_date handled.
--                 Other changes for performance.
--                 Voucher_date taken from voucher_row_tab instead of voucher_tab etc
--                 Removed unused procedure Check_Methods
--  010830  GAWILK Bug #22967 fixed. Added checks for the project activity id in Check_Project___
--  010904  JeGu   Bug #24125 Some minor changes
--  010907  Thsrlk Bug #24054 corrected
--  010913  JeGu   Bug #24054 Recorrection
--  010917  JeGu   Bug #24449 Modified call to Create_Pa_Internal_Row
--  010925  JeGu   Fix third_currency_code in add_new_row_
--  011024  ovjose Bug #25777. Removed Bug correction 18577
--  020109  LiSv   IID 10001. Added new procedure Ncf_Create_Postings___. NOTE This is only used by companies in Norway.
--  020115  Thsrlk Bug# 21029 - corrections.
--  020123  UPULP  IID 10114 Job Costing
--  020131  rakolk Corrected Bug# 27384.
--  020314  Uma    Corrected Bug# 28316.
--  020517  Hecolk Bug# 27778 Merged. Add coding to get project code part when GENLED is not installed.
--  020521  rakolk Bug# 29705 Corrected.
--  020522  difelk Bug # 29704 corrected. When entering tax code with 0% it used to take the
--                 norwegian investment tax amount for AP6 and AP7. Now it takes the base amount.
--  020607  Hecolk Bug 28405, Corrected. In PROCEDURE Check_Project___
--  020613  Uma    Corrected Bug# 29291
--  020619  Uma    Corected Bug# 30153. Changed newrec_ to voucher_row_rec_.
--  020627  MACHLK Bug# 30116 Fixed. Called Internal_Manual_Postings___ for tax lines.
--  020708  Hecolk Bug 28405, Re-Corrected. Modified some error messages In PROCEDURE Check_Project___.
--  020708  Hecolk Bug 28405, Modified the condition to properly validate Activity Seq of Project Ids where the origin is 'PROJECT'
--  020724  RAKOLK Corrected Bug# 31775.
--  020801  DIFELK Bug # 31874 corrected. Modified error message.
--  020824  Hadilk Corrected bug 30853
--  020827  Uma    Corrected Bug# 32195. Handled deleting of tax lines in internal ledger.
--  021002  Nimalk   Removed usage of the view Company_Finance_Auth in VOUCHER_ROW view
--                   and replaced by view Company_Finance_Auth1 using EXISTS caluse instead of joins
--  021017  SAMBLK Increased the length of the voucher_group_ in Unpack_Check_Insert___ & Unpack_Check_Update___
--  030102  DAGALK Merge SP3 bugs exept external file transaction part.
--  030131  mgutse IID ITFI127N. New attribute reference_version added.
--  030221  RAFA   IID RDFI151N, added party_type to tavle and all views.
--  030327  Bmekse IID ITFI127N Added tax_item_id to table and view.
--  030801  Nimalk SP4 Merge
--  030825  Bmekse DEFI160N Modified view VOUCHER_ROW and VOUCHER_ROW_QRY
--  030909  Nimalk Changed Add_New_Row_()
--  030915  Brwelk Patch Merge.LCS Bug 38419,Modified coding as to apply the modified voucher date.
--  030915  Dagalk Patch Merge.LCS Bug 37743,comment code taxrec_.project_activity_id.
--  030923  Brenda Added Check_Project_Used for Rollback Project Completion.
--  030926  Thsrlk DEFI159N - Changed Check_Codestring___ to support PCA Budget code parts
--  031010  Gawilk LCS bug 38708 merged. Made the project_id NULL when modifiying
--  031010         a project code part in Update___.
--  040326  Gepelk 2004 SP1 Merge
--  040608  Hecolk IID FIPR228, Added Procedures Calculate_Cost_And_Progress and Get_Activity_Info
--  040611  Hecolk IID FIPR228, Added Procedures Create_Object_Connection___ & Remove_Object_Connection___
--                 Added related code in Procedures Insert___, Update___ & Delete___   
--  040615  Hecolk IID FIPR228, Added Procedure  Create_Object_Connection
--  040709  Hecolk IID FIPR228, Added Procedure Remove_Object_Connection
--  040716  Hecolk LCS Merge - Bug Id 44537
--  040722  Hecolk IID FIPR228, Set object_status_ in Calculate_Cost_And_Progress & Create_Object_Connection___
--  040826  Hecolk Added Call to Check_Exist___ in Remove_Object_Connection___
--  040916  nsillk LCs Merge - Bug Id 45926 A completed Financial or Job project can be used in creating voucher
--  040916  nsillk LCS Merge - Bug Id 46526     
--  040920  reanpl FIJP344 Japanese Tax Rounding, use Round_Amount to calculate taxes
--  041025  gawilk FIPR307. Added column inv_acc_row_id.
--  041103  gawilk FIPR307. Added function Fetch_Vou_Row_Id.
--  050104  Kagalk LCS Merge (47692, 47874)
--  050316  Saahlk LCS Merge (49494)
--  050321  viselk LCS Bug 44049 Merged.
--  050408  viselk LCS Bug 50119 Merged.
--  050408  NiFelk B121223, Added methods Check_Int_Vou_Row___, Get_Row and Internal_Manual_Postings.
--  050321  Nsillk LCS Merge(49506).Added the view ACCRUL_VOUCHER_ROW_QRY.
--  050518  Chprlk LCS Merge(51232). Validates Activity Seq No based on PCA(Percoss) setting.
--  050805  Umdolk LCS Merge(52175).
--  050915  Chajlk LCS Merge(33986). 
--  051104  ShFrlk LCS Bug 53684, Merged.
--  051114  THPELK FIAD377 - Added Rollback_Voucher_ parameter for Reverse_Voucher_Rows__().
--  051118  WAPELK Merged the Bug 52783. Correct the user group variable's width.
--  051202  GADALK Bug 128864 - Code string validations for Clear Rev/Cost vouchers.
--  051213  THPELK Call Id 129888. - Corrected in Add_New_Row_(). 
--  051214  VOHELK Call Id 129879. - Corrected in Insert___().
--  051221  THPELK Call Id 129888. - Corrected in Add_New_Row_().
--  060106  VOHELK Call Id 130531  - Changed : Check_Codestring___() added codestring_rec_.text 
--  060110  Gawilk Added function Get_Pca_Ext_Project.
--  060227  Rufelk LCS-55722 Merge. Modified the Interim_Voucher() Procedure.
--  060323  Miablk B136698 - Added PRJT3 to Get_Activity_Info() method. 
--  060427  DIFELK Bug 56983 corrected. Added new method Not_Updated_Code_Part_Exist.
--  060802  Kagalk LCS Merge - Bug 57046, Modified method Check_Codestring___.
--  060802         Removed the validation for process code when function group is P.
--  060802  Kagalk LCS Merge - Bug 57182.
--  061113  GaDaLK FIPL604A; Changes to reference_serie and reference_number
--  061115  GaDaLK FIPL604A; Changes in Create_Tax_Transaction___
--  061116  GaDaLK FIPL604A; Added Set_Row_Reference_Data()
--  061127  Thaylk LCS Merge 61693, corrected. Modifications made to add PRJT3 and PRJT4 for function group T.
--  070124  Shsalk LCS Merge 61873.Modified the Code_Part_Exist function so that it wont use decode,
--                 and added NOCHECK for code parts in view VOUCHER_ROW.
--  070124  Thpelk FIPL644A - Added modifiecations to Reverse_Voucher_Rows__() to get the new 
--                 Reversal voucher posting method when creating reversal vouchers. 
--  070126  Kagalk LCS Merge 62086, Modifications done to update costs for E vouchers.
--  070207  Kagalk LCS Merge 63090, Multiplication by -1 added when calculating rowrec_.currency_tax_amount
--  070207         and multiplication by -1 removed for rowrec_.tax_amount             
--  070222  GaDaLK FIPL633A, added row_group_id
--  070223  ShSaLK LCS Merge 63510 - Changes to the meathod Reverse_Voucher_Rows__.
--  070223  GaDaLK FIPL633A; Changed Set_Row_Reference_Data() to Set_Row_Data__() with row_group_id
--  070306  Paralk FIPL638A, Added Is_Voucher_Exist()
--  070307  GaDaLK FIPL633A; Changes in Create_Tax_Transaction___ added row_group_id
--  070212  ShSaLK LCS Merge 62772 corrected. Removed the project activity sequence validation for function group A.
--  070314  GaDalk FIPL633A: When row group validation: null value for row_group_id blocked, statistical accounts blocked
--  070315  GaDalk FIPL633A: Modified Add_New_Row_
--  070424  ShSalk LCS Merge 64874 corrected. Added Voucher group W to create object connection.
--  070509  Surmlk Added 'Set_Row_Data__' after the END of the procedure Set_Row_Data__
--  070514  Chsalk LCS Merge 64448;Added conversion factor to VOUCHER_ROW_QRY.
--  070516  Chhulk B142136 Modified Unpack_Check_Insert___() and Unpack_Check_Update___()
--  070522  Chsalk LCS Merge 64981; Added voucher group D to create object connection.
--  070530  Maselk B142976, Added Update_Row_No().
--  070608  Surmlk Corrected the method name in General_SYS.Init_Method of method Update_Row_No
--  070705  Hawalk Merged Bug 65797, Modification, inside Insert___(), made to voucher group D for invoices in object connections.
--  070814  Bmekse Merged Bug 66483. Changed Create_Object_Connection___ and Calculate_Cost_And_Progress.
--  071030  DIFELK Bug 67307 corrected. Modification made to check budget accounts when voucher rows are inserted and updated.
--  071106  DIFELK Bug 68932 corrected. Added voucher group K to create object connection.
--  071127  PRDILK Bug 69077 corrected, Added Corrected_Voucher_API.Exist_Db to check DB values
--  071128  cldase Bug 67432 Added entry_date in Select statement and Comment on Column to VOUCHER_ROW_QRY  
--  071201  Jeguse Bug 69803 Corrected.
--  080312  Nsillk Bug 72235 Corrected.Modified method Update_Row_No
--  080317  NUGALK Bug 69894 Corrected. Added Obj_Conn_Refresh_Req___
--  080317         since further checks are needed before calling the method Calculate_Cost_And_Progress in method Update___
--  080327  NiFelk Bug 69891, Corrected.
--  080413  cldase Bug 70198, Introduced global LU constant Avail_Mtd_IsActPostble_ instead of check with cursor
--  080428  JARALK Bug 73185, Merged Peak 75 code.
--  080502  MAKRLK Bug 69890 Corrected. 
--  080506  JARALK Bug 73185, re added the correction of the bug 73222.
--                 ( DIFELK Bug 73222 corrected. Declared new method Create_Object_Connection and
--                   Modifications made to create object connections for already saved vouchers.)
--  080524  AsHelk Bug 74066, Corrected
--  080610  Maaylk Bug 74514, Updated the reference row no values in voucher_row_tab and internal_hold_voucher_row_tab when row no values are updated
--  080619  Nirplk Bug 74252, Corrected. Igonore the validation for function group 'H' in Check_Project___().
--  080619  RUFELK Bug 74540, Corrected. Changed the Voucher Group Row ID for Calculated VAT Tax lines.
--  080627  NUGALK Bug 72589, Corrected. Modified view comments of VOUCHER_ROW_QRY, to be consistent witht the filed key types. 
--  080709  AsHelk Bug 74637, Corrected.
--  081027  MAWELK Bug 74222, Added a comment over the method Calculate_Cost_And_Progress() and Get_Activity_Info().
--  090102  Ersruk Validations added using exclude_proj_followup.
--  090122  Ersruk Added new function  All_Postings_Transferred_Acc.
--  090225  Makrlk Added new function  Check_Exist_Vourow_with_Pfe()
--  090303  Ersruk Added the validation right at the top to avoid unnecessary method calls.
--  090304  Thpelk Bug 80830, Corrected in VOUCHER_ROW View.
--  090406  Marulk Bug 81398, Added "ifs assert safe" annotation to the dynamic call in method Get_Subcon_Total_Used_Cost. 
--  090505  Nirplk Bug 79803, Corrected. checked for blocked code parts in Unpack_Check_Update___
--  090605  THPELK Bug 82609 - Added UNDEFINE section and the missing statements for VIEW5.
--  090317  Makrlk Modified the methods Create_Object_Connection_() Create_Object_Connection___() 
--                 and Calculate_Cost_And_Progress() to handle any code part value
--  00318   Ersruk Validations added in Check_Project___.      
--  090818  JARALK Bug 84633, Added new overloaded method Get_Currency_Rate() with trans_code as a parameter instead of row_id.
--  090915  Thpelk Bug 85766, Corrected in Sum_Currency_Amount and Sum_Amount()..
--  090917  Nirplk Bug 85764, Corrected in Unpack_Check_Insert__() and Unpack_Check_Update_()
--  090924  JOFISE Bug 85810, Added amount and quantity control in Unpack_Check_Insert___.
--  090929  RUFELK Bug 84652, Corrected. Modified in Handle_Object_Conns___() method.
--  090330  Makrlk Modified the methods Create_Object_Connection()
--  090730  Makrlk Added new function Get_Activity_Info().
--  090909  Ersruk Modified Get_Subcon_Total_Used_Cost() to fetch cost element from cord parts.
--  090925  Janslk Made changes in calls to Project_Connection_Util_API.Create_Connection and
--                 Project_Connection_Util_API.Refresh_Activity_Info according to the interface changes.
--  091014  THPELK Bug 76117, PRE Merge - Changed the parameters of project connection calls to use Attributes_Type variable instead of attribute string.
--                            Added Get_Codestring__() to retrive all the codeparts as a single string.
--  091208  MAZPSE ME3040, Eagle project, Modified SUB_CON_AFP_INVOICE_TAB to SUBVAL_INVOICE_TAB.
--  091216  Mawelk Bug 87869  Fixed.
--  100120  Makrlk  TWIN PEAKS Merge.             
--  100223  Maaylk Bug 88901, Removed a block of code that seemed to be obsolete.
--  100308  MAZPSE ME3040, Eagle project, Changed check against SUBCON to SUBVAL in Get_Subcon_Total_Used_Cost. 
--  100319  CLSTLK Bug 89485, Corrected. Modified Prepare_Tax_Transaction___(). Tax amount is multiplied by -1 when creating tax transaction.                                     
--  100422  THPELK Bug 90201, Corrected in Check_Project___().           
--  100701  Jaralk Bug 91425, Corrected in check_project__()  
--  100716  Umdolk  EANE-2936, Reverse engineering - Corrected reference in base view.
--  101027  WAPELK Bug 93703, Remove saving null currency types as default currency types.
--  101101  Elarse, RAVEN-985, Added Create_Cancel_Row_().
--  100608 Ersruk  Removed old Get_Activity_Info(). Added new method Get_Activity_Info(). Modified the methods Create_Object_Connection_() Create_Object_Connection___() 
--                 and Calculate_Cost_And_Progress() to add transaction values and currency code.
--  100616 Ersruk  Modified Get_Subcon_Total_Used_Cost to return used_cost and used_transacion cost.
--  100917 Insalk  Added PRJT5 and PRJT6 to Get_Activity_Info().
--  101018 Janslk  Added Calculate_Cost_And_Progress method with OUT parameters.
--  101021 Janslk  Changed Create_Object_Connection___ to have meaningful names for variables.
--  110112 Janslk  Changed Create_Object_Connection___ and Calculate_Cost_And_Progress to set base value 
--                 as the transaction value when transaction value is zero and base is non-zero.
--  110302 Makrlk  Modified Check_Exist_Vourow_with_Pfe()
--  110302 AsHelk  RAVEN-1877, Fixing problems in Project_id and Object_id columns.
--  110329 DIFELK  RAVEN-1437, modifications done in Create_Cancel_Row___. Called Internal_Manual_Postings___ to create IL voucher rows.
--  110330 DIFELK  RAVEN-1671 modified Create_Cancel_Row___. Validations removed for AP1-AP4.
--  110314 Ersruk  Voucher date added in Obj_Conn_Refresh_Req___().
--  110405 Ersruk  Added Refresh_Connection_Header(). It is called from Handle_Object_Conns___ if voucher dates are changed.
--  110105 SJayLK  EASTONE-19636, Merged Bug 94795, Added voucher_type_reference,voucher_no_reference and accounting_year_reference to VOUCHER_ROW_QRY view.  
--  110701 Sacalk  FIDEAGLE-931, Merged Bug 97430, Corrected in Remove().
--  110721 Sacalk  FIDEAGLE-317, Merged Bug 96287, Unpack_Check_Update___() and Unpack_Check_Insert___().
---------------------SIZZLER-------------------------------------------------
--  110810 Ersruk  Added new column activate_code.
--  111104 Ersruk  Removed function group 'P' from creating object connections.
--  110721 Shdilk  FIDEAGLE-1061, Merged bug 97579, Corrected in Insert___() - re-added the currency type since it is not completly handled.
--  110812 Mohrlk  FFIDEAGLE-211, Modified method Refresh_Connection_Header().
--  111018 Swralk  SFI-128, Added conditional compilation for the places that had called package FIXASS_CONNECTION_V871_API.
--  111020 Swralk  SFI-143, Added conditional compilation for the places that had called package INTLED_CONNECTION_V101_API,INTLED_CONNECTION_V130_API and INTLED_CONNECTION_V140SP3_API. 
--  111102 Maaylk  SFI-266, LCS bug 98908, Added method Get_Internal_Code_Parts()
--  111213 Clstlk  SFI-784, LCS bug 99676, Added method Create_Object_Connection().
--  120206 Swralk  SFI-1357, Merged correction done for SIZ-817.
--  120229 Umdolk  SFI-2389, Corrected in Calculate_Cost_And_Progress.
-----------------------------------------------------------------------------
--  120419 AmThLK  EASTRTM-9789, modified Check_Project_Used()
--  120518 Swralk  OCT-60, Corrected sub project completion.
--  120530 Umdolk  Bug 102875, Merged flexcap bugs.    
--  120618 NUVELK  Modified Refresh_Connection_Header to pass correct values when calling Project_Connection_Util_API.Refresh_Header_And_Dates.
--  120625 AmThLK  Bug 102875,  modified Check_Project_Used()
--  120627 THPELK  Bug 97225, Corrected in Unpack_Check_Insert___() and Unpack_Check_Update___().
--  120631 Janblk  EDEL-871, Modified the logic of Check_Code_String_Fa___ to allow multiple code string         
--  120812 THPELK  Bug 104100, Merged. Corrected the Performance improvement in fetching voucher row number.
--  120817 Umdolk  EDEL-1324, Modified Complete_Voucher__ method to update add_investment_info records when completing the voucher. 
--  120823 Umdolk  EDEL-1506, Corrected in Create_Add_Investment_Info___  and Re_Create_Mod_Add_Inv_Info___.
--  120824 AmGalk  Bug 104365,Added extra check for function_group 'E' to Insert_Row__.
--  120828 MAAYLK  Bug 101320, Removed Internal_Manual_Postings_ () 
--  120912 Umdolk  EDEL-1646, Modified Check_Code_Str_Fa method to suppport multiple code strings.
--  120918 Janblk  EDEL-1708, Modified Check_Code_Str_Fa__
--  120921 Umdolk  EDEL-1814, Modified Check_Code_Str_Fa__ to correct fresh installation error.
--  120925 Umdolk  EDEL-1708, rollbacked the correction.
--  120920  THPELK  Bug 103538, Corrected in Get_Subcon_Total_Used_Cost().
--  120926  chanlk  Bug 105181, Modified Check_Codestring___.
--  121123  Thpelk  Bug 106680 - Modified Conditional compilation to use single component package.
--  121210  Maaylk  PEPA-183, Removed global variables
--  121130  Nirplk  Bug 107103, Corrected in Create_Object_Connection().
--  121211  Mawelk  Bug 106183 Fixed
--  121214  Clstlk  Bug 106800, Added columns entered_by_user_group,userid,approved_by_user_group,approved_by_userid in view2.
--  130308  CLSTLK  Bug 108417, Modified Interim_Voucher().   
--  130318  Maaylk  Bug 108608, Added Row_Group_id to VOUCHER_ROW_QRY_FINREP
--  130818  THPELK  Bug 108987, Corrected in Unpack_Check_Insert___() and Unpack_Check_Update___(). 
--  130419  AmGalk  Bug 109491, Rollback the bug correction 104365.
--  121123  Janblk  DANU-122, Parallel currency implementation  
--  130531  NILILK  DANU-1230, Modified procedure Interim_Voucher. 
--  130717  CPriLK  BRZ-3774, Added function group 'MPR' for required locations.
--  130801  THPELK  Bug 111757, Corrected in Create_Add_Investment_Info___() and Re_Create_Mod_Add_Inv_Info___().
--  130605  SALIDE  EDEL-2187, Modified Create_Add_Investment_Info___() and Insert_Row() to handle FA Cash Discount.
--  130823  Shedlk  Bug 111220, Corrected END statements to match the corresponding procedure name
--  130902  MAWELK  Bug 111219 Fixed. 
--  130924  Mawelk  Bug 112628 Fixed
--  140206  Charlk  Set the context of Fa_Message_API.key_  in Check_Insert__ method.
--  140207  Charlk  Modified Check_Insert__ method.
--  140303  Mawelk  PBFI-5118 (Lcs Bug Id 114911)
--  140313  THPELK  PBFI-4122 - LCS Merge ( Bug 113054).
--  140313  CPriLK  PBPJ-2620, Added MCPR cost posting types to Get_Activity_Info().
--  140425  PRatlk  PBFI-6887, Sent third currency information to add investment info table.
--  140430  Nirylk  PBFI-5614, Added deliv_type_id column, Modified Create_Tax_Transaction___(),Add_New_Row_(), Interim_Voucher() and Create_Cancel_Row_()
--                             Added new procedure Validate_Delivery_Type_Id__ and function Get_Delivery_Type_Description
--  140612  Jeguse  PRPJ-534, Modified Create_Object_Connection___, Calculate_Cost_Progress and added Refresh_Connection
--  141115  Chgulk  PRFI-3337, Merged LCS patch 119340.
--  140328  THPELK  PRFI-3705, LCS Merg(Bug 115796) Corrected.
--  150128  AjPelk  PRFI-4489, Lcs merge Bug 120401, Added the new field CURRENCY_RATE_TYPinsert
--  150309  CPriLK  ANPJ-22, Removed the object_staus from project_connection_util_api related method calls.
--  150526  CPriLK  ANPJ-522, Added PRJT12, PRJT13, PRJC15, PRJC16 to Get_Activity_Info().
--  150618  THPELK  FISU-248 - Correccted in Create_Cancel_Row___() TO Allow cancel Manual GL functionality for row connected with Projects. 
--  150603  Raablk  Bug 121642, Modified PROCEDURE Reverse_Voucher_Rows__ to pass mpccom accounting id.
--  150707  Kanslk  Bug 123433, Removed code introduced on PRFI-5158
--  150820  AmThLK Bug 123956, Modified Get_Delivery_Type_Description -- changed the description field size to 2000  
--  150820  THPELK  FISU-275, Corrected.
--  150918  CPriLK  AFT-5492, Remove PRJC15,PRJC16 postings to delimit XPR cost reporting.
--  151117  Bhhilk  STRFI-12, Removed annotation from public get methords.
--  151118  Bhhilk  STRFI-39, Modified CorrectedVoucher enumeration to FinanceYesNo.
--  151127  Bhhilk  STRFI-523, Modified Create_Int_Manual_Postings__() to create entries even when it had the same codestring.
--  160203  Chwilk  STRFI-1151, Modified Insert_Row__.
--  160516  Chwtlk  STRFI-1625, Modified Create_Tax_Transaction___.
--  161230  Maaylk  STRFI-4030, (Bug 131605) For direct cash payment (voucher_type= N OR CB) connections should be done only if trans_code is 'MANUAL'
--  170321  Chwtlk  STRFI-4483, Merged LCS Bug 133262, Modified Insert___. Modification done so that Period Allocations will not happen to Voucher Rows with Currency Amounts Zero.
--  180508  Chwtlk  Bug 141214, Modified Check_Project___.
--  181031  Bhhilk  Bug 145032, Addded new method Get_Inv_Id_From_Inv_Acc_Row.
--  191619  Ispalk  Bug 149020, Corrected in Get_Activity_Info on how to report cost for trans_code 'M278' .
--  191031  Kagalk  GESPRING20-1261, Added changes for tax_book_and_numbering.
--  200526  Ketklk  Bug 154126, Modified Get_Activity_Info to remove the correction from Bug 149020.
--  200902  ALWOLK FISPRING20-6943, Removed a Condition in Validate_Reverse_Vou_Row___() which does not allow to Execute a PCA Step from Bug 155274.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------

PROCEDURE Validate_Budget_Code_Parts___ (
   voucher_rec_     IN  VOUCHER_ROW_TAB%ROWTYPE)
IS
   code_part_  VARCHAR2(10);
   code_value_ VARCHAR2(20);
BEGIN
   FOR count_ IN 1..10 LOOP   
      code_part_ := 'CODE_' || chr( 64 + count_);
      IF (code_part_ ='A') THEN
         code_value_ := voucher_rec_.account;
      ELSIF (code_part_ ='B') THEN
         code_value_ := voucher_rec_.code_b;
      ELSIF (code_part_ ='C') THEN
         code_value_ := voucher_rec_.code_c;
      ELSIF (code_part_ ='D') THEN
         code_value_ := voucher_rec_.code_d;
      ELSIF (code_part_ ='E') THEN
         code_value_ := voucher_rec_.code_e;
      ELSIF (code_part_ ='F') THEN
         code_value_ := voucher_rec_.code_f;
      ELSIF (code_part_ ='G') THEN
         code_value_ := voucher_rec_.code_g;
      ELSIF (code_part_ ='H') THEN
         code_value_ := voucher_rec_.code_h;
      ELSIF (code_part_ ='I') THEN
         code_value_ := voucher_rec_.code_i;
      ELSIF (code_part_ = 'J') THEN
         code_value_ := voucher_rec_.code_j;
      END IF;
           
      IF Accounting_Code_Part_Value_API.Is_Budget_Code_Part(voucher_rec_.company, code_part_, code_value_) THEN
         IF (code_part_ = 'A') THEN
            Error_SYS.Record_General(lu_name_, 'BUDACCONLY: Account :P1 is only allowed for budget.', voucher_rec_.account);
         ELSE
            Error_SYS.Record_General(lu_name_, 'BUDCODEPARTONLY: Code part value :P2 of code part :P1 is only allowed for budget.', code_part_, code_value_);
         END IF;
      END IF;
   END LOOP;
END Validate_Budget_Code_Parts___;

PROCEDURE Handle_Object_Conns___ (
   newrec_               IN VOUCHER_ROW_TAB%ROWTYPE,
   oldrec_               IN VOUCHER_ROW_TAB%ROWTYPE,
   from_insert_          IN BOOLEAN,
   create_project_conn_  IN VARCHAR2 ) 
IS
   function_group_          VARCHAR2(30);
   old_excl_proj_flwup_     VARCHAR2(5);
   new_excl_proj_flwup_     VARCHAR2(5);   
   function_group_rec_      Function_Group_API.Public_Rec;
BEGIN
   IF (from_insert_) THEN
      -- comming from insert___
      IF (create_project_conn_ = 'TRUE') THEN
         UPDATE voucher_tab
         SET proj_conn_created = 'TRUE'	          
         WHERE company         = newrec_.company
         AND   accounting_year = newrec_.accounting_year
         AND   voucher_type    = newrec_.voucher_type
         AND   voucher_no      = newrec_.voucher_no;
           
         IF (newrec_.project_id IS NOT NULL) AND ((NVL(newrec_.project_activity_id,0) != 0) AND (newrec_.project_activity_id != -123456)) THEN
            function_group_ := Voucher_API.Get_Function_Group(newrec_.company,
                                                              newrec_.accounting_year,
                                                              newrec_.voucher_type,
                                                              newrec_.voucher_no); 
            function_group_rec_ := Function_Group_API.Get(function_group_);                                                               
            IF (NOT (function_group_ = 'D' AND newrec_.inv_acc_row_id IS NOT NULL))
               AND 
               (NOT (function_group_ = 'K' AND (newrec_.party_type = 'CUSTOMER' OR newrec_.party_type = 'SUPPLIER') 
                                        AND newrec_.party_type IS NOT NULL))THEN
               -- These belong to manual vouchers and object connections cannot be created at this
               -- point until the final voucher number is known                  
               IF (function_group_rec_.proj_conn_vou_row_support = 'TRUE') THEN   
                  IF (function_group_rec_.manual = 'TRUE') THEN   
                     -- This voucher row belongs to a manual voucher, therefore special handling
                     IF (newrec_.voucher_no > 0) THEN
                        -- This means that proper voucher number has been assigned  
                        -- for automatically alloting vouchers, the number would be negative until final voucher number is assigned
                        -- So this means that the voucher is either finalized or manually alloting.
                        -- Therefore need to create object connection here
                        Create_Object_Connection___(newrec_);
                     END IF;
                  ELSE
                     Create_Object_Connection___(newrec_);
                  END IF;
               END IF;                     
            END IF;      
         END IF;
      END IF;
   ELSE
      -- coming from update___
      function_group_ := Voucher_API.Get_Function_Group(newrec_.company,
                                                        newrec_.accounting_year,
                                                        newrec_.voucher_type,
                                                        newrec_.voucher_no);
      function_group_rec_ := Function_Group_API.Get(function_group_);                                                 
      IF (function_group_rec_.manual = 'TRUE') THEN      
         IF (newrec_.project_id IS NOT NULL) AND (NVL(newrec_.project_activity_id,0) != 0)  THEN
            IF (NVL(oldrec_.project_activity_id,0) != 0) THEN
               IF (newrec_.project_activity_id != oldrec_.project_activity_id) THEN
                  -- Remove old Object Connection and Cost Info
                  Remove_Object_Connection___(oldrec_);
                  -- Create new Object Connection and Cost Info
                  Create_Object_Connection___(newrec_);
               ELSE                  
                  old_excl_proj_flwup_ := nvl(Account_API.Get_Exclude_Proj_Followup(oldrec_.company, oldrec_.account), 'FALSE');
                  new_excl_proj_flwup_ := nvl(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE');
                  IF (old_excl_proj_flwup_='TRUE' AND new_excl_proj_flwup_='FALSE') THEN
                     --create connection
                     Create_Object_Connection___(newrec_);
                  END IF;
                  IF (old_excl_proj_flwup_='FALSE' AND new_excl_proj_flwup_ = 'TRUE') THEN
                     --remove connection
                     Remove_Object_Connection___(oldrec_);
                  END IF; 
                 
                  IF (oldrec_.voucher_date != newrec_.voucher_date) THEN
                     Refresh_Connection_Header ( newrec_.company,
                                                 newrec_.voucher_type,
                                                 newrec_.accounting_year,
                                                 newrec_.voucher_no,
                                                 newrec_.row_no );
                  END IF;

                  IF (Obj_Conn_Refresh_Req___(oldrec_,newrec_)) THEN
                     -- Refresh Object Connection and Cost Info  
                     Calculate_Cost_And_Progress (newrec_.company,
                                                  newrec_.voucher_type,
                                                  newrec_.accounting_year,
                                                  newrec_.voucher_no,
                                                  newrec_.row_no);
                  END IF;
               END IF;
            ELSE
               -- Create new Object Connection and Cost Info
               Create_Object_Connection___(newrec_);
            END IF;
         ELSE
            IF (NVL(oldrec_.project_activity_id,0) != 0) THEN
               -- Remove old Object Connection and Cost Info
               Remove_Object_Connection___(oldrec_);
            END IF;
         END IF;
      END IF;
   END IF;     
END Handle_Object_Conns___;


PROCEDURE Check_Acquisition___ (
   newrec_           IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   function_groupx_  IN     VARCHAR2,
   fa_code_partx_    IN     VARCHAR2 )
IS
   fa_code_part_           VARCHAR2(10);
   object_id_              VARCHAR2(20);
   account_                VARCHAR2(20);
   fa_codestring_rec_      Accounting_codestr_API.CodestrRec;
   is_acq_account_         BOOLEAN;
   function_group_         VARCHAR2(10);
   $IF Component_Fixass_SYS.INSTALLED $THEN
      object_acq_rec_         Fa_Object_API.Public_Object_Acq_Rec;
   $END
   no_action   EXCEPTION;
BEGIN
   -- Find out if FIXASS is installed
   $IF Component_Fixass_SYS.INSTALLED $THEN
      newrec_.object_id := NULL;
      -- Get function group. IF A and Q, skip
      function_group_ := function_groupx_;
      IF (function_group_ IS NULL) THEN
         function_group_ := Voucher_Type_Detail_API.Get_Function_Group( newrec_.company, newrec_.voucher_type );
      END IF;
      IF (function_group_ IN ( 'A', 'Q' ) ) THEN
         RAISE no_action;
      END IF;
      -- Get FA code part
      fa_code_part_ := fa_code_partx_;
      IF (fa_code_part_ IS NULL) THEN
         fa_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(newrec_.company,'FAACC');
      END IF;
      account_ := newrec_.account;
      IF ( account_ IS NULL ) THEN
         RAISE no_action;
      END IF; 
      is_acq_account_ := Acquisition_Account_API.Is_Acquisition_Account (newrec_.company, account_);
      IF (is_acq_account_) THEN
         fa_codestring_rec_.code_a := newrec_.account;
         fa_codestring_rec_.code_b := newrec_.code_b;
         fa_codestring_rec_.code_c := newrec_.code_c;
         fa_codestring_rec_.code_d := newrec_.code_d;
         fa_codestring_rec_.code_e := newrec_.code_e;
         fa_codestring_rec_.code_f := newrec_.code_f;
         fa_codestring_rec_.code_g := newrec_.code_g;
         fa_codestring_rec_.code_h := newrec_.code_h;
         fa_codestring_rec_.code_i := newrec_.code_i;
         fa_codestring_rec_.code_j := newrec_.code_j;
         IF (upper(fa_code_part_) = 'B') THEN
            object_id_ := newrec_.code_b;
         ELSIF (upper(fa_code_part_) = 'C') THEN
            object_id_ := newrec_.code_c;
         ELSIF (upper(fa_code_part_) = 'D') THEN
            object_id_ := newrec_.code_d;
         ELSIF (upper(fa_code_part_) = 'E') THEN
            object_id_ := newrec_.code_e;
         ELSIF (upper(fa_code_part_) = 'F') THEN
            object_id_ := newrec_.code_f;
         ELSIF (upper(fa_code_part_) = 'G') THEN
            object_id_ := newrec_.code_g;
         ELSIF (upper(fa_code_part_) = 'H') THEN
            object_id_ := newrec_.code_h;
         ELSIF (upper(fa_code_part_) = 'I') THEN
            object_id_ := newrec_.code_i;
         ELSIF (upper(fa_code_part_) = 'J') THEN
            object_id_ := newrec_.code_j;
         END IF;
         newrec_.object_id := object_id_;
         --  Check Fa vouchers for the current object in the hold table
         IF ( object_id_ IS  NOT NULL) THEN
            Check_Code_String_Fa___ (newrec_.company,
                                     object_id_,
                                     fa_codestring_rec_,
                                     newrec_.voucher_type);
         END IF;
         --
         object_acq_rec_.company         := newrec_.company;
         object_acq_rec_.object_id       := object_id_;
         object_acq_rec_.account         := newrec_.account;
         object_acq_rec_.code_b          := newrec_.code_b;
         object_acq_rec_.code_c          := newrec_.code_c;
         object_acq_rec_.code_d          := newrec_.code_d;
         object_acq_rec_.code_e          := newrec_.code_e;
         object_acq_rec_.code_f          := newrec_.code_f;
         object_acq_rec_.code_g          := newrec_.code_g;
         object_acq_rec_.code_h          := newrec_.code_h;
         object_acq_rec_.code_i          := newrec_.code_i;
         object_acq_rec_.code_j          := newrec_.code_j;
         object_acq_rec_.voucher_type    := newrec_.voucher_type;
         object_acq_rec_.voucher_number  := newrec_.voucher_no;
         object_acq_rec_.accounting_year := newrec_.accounting_year;
         object_acq_rec_.function_group  := function_group_;
         object_acq_rec_.fa_code_part    := fa_code_part_;
         Fa_Object_API.Check_Acquisition ( object_acq_rec_ );
      END IF;
   $ELSE
      NULL;
   $END
EXCEPTION
  WHEN no_action THEN
     NULL;
END Check_Acquisition___;


PROCEDURE Check_Period_Allocation___ (
   newrec_ IN VOUCHER_ROW_TAB%ROWTYPE )
IS
   allocated_        VARCHAR2(1);
   voucher_date_     DATE;
   function_group_   voucher_type_detail_tab.function_group%TYPE;
BEGIN
   allocated_ := Period_Allocation_API.Any_Allocation( newrec_.company,
                                                       newrec_.voucher_type,
                                                       newrec_.voucher_no,
                                                       newrec_.row_no,
                                                       newrec_.accounting_year);
   IF (allocated_ = 'Y') THEN
      Error_SYS.Record_General(lu_name_, 'EXISTINPERALLOC: Can not change Voucher row that exists in Period Allocation');
   END IF;
   IF (newrec_.voucher_date IS NOT NULL) THEN
      voucher_date_ := newrec_.voucher_date;
   ELSE
      voucher_date_ := Voucher_API.Get_Voucher_Date (newrec_.company,
                                                     newrec_.accounting_year,
                                                     newrec_.voucher_type,
                                                     newrec_.voucher_no);
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      function_group_ := Voucher_Type_API.Get_Voucher_Group(newrec_.company, newrec_.voucher_type);
      IF (((upper(newrec_.trans_code) != 'MANUAL') AND (NOT((upper(newrec_.trans_code) = 'EXTERNAL') AND function_group_ = 'D'))) 
      AND NOT ((Voucher_Type_API.Get_Use_Manual(newrec_.company,
                                                newrec_.voucher_type) = 'TRUE') AND
           (Internal_Voucher_Util_Pub_API.Check_If_Manual(newrec_.company,
                                                          newrec_.account,
                                                          voucher_date_) IS NOT NULL))) THEN
         IF (upper(newrec_.trans_code) = 'INTERIM') THEN
            Error_SYS.Record_General(lu_name_, 'NOINTERIM: The voucher is connected to an interim voucher and cannot be changed');
         ELSE
            Error_SYS.Record_General(lu_name_, 'NOMANUAL: The voucher row is automatically created and cannot be changed');
         END IF;
      END IF;
   $END
END Check_Period_Allocation___;


PROCEDURE Check_Codestring___ (
   newrec_                    IN VOUCHER_ROW_TAB%ROWTYPE,
   user_groupx_               IN VARCHAR2,
   check_codeparts_           BOOLEAN DEFAULT TRUE,
   check_demands_codeparts_   BOOLEAN DEFAULT TRUE,
   check_demands_quantity_    BOOLEAN DEFAULT TRUE,
   check_demands_process_     BOOLEAN DEFAULT TRUE,
   check_demands_text_        BOOLEAN DEFAULT TRUE)
IS
   codestring_rec_         Accounting_codestr_API.CodestrRec;
   head_                   Voucher_API.Public_Rec;
   user_group_             user_group_member_finance_tab.user_group%TYPE;
   budget_account_         BOOLEAN;
BEGIN
   IF (user_groupx_ IS NULL) THEN
      head_ := Voucher_API.Get( newrec_.company,
                                newrec_.accounting_year,
                                newrec_.voucher_type,
                                newrec_.voucher_no );
      user_group_   := head_.user_group;
   ELSE
      user_group_   := user_groupx_;
   END IF;
   codestring_rec_.code_a       := newrec_.account;
   codestring_rec_.code_b       := newrec_.code_b;
   codestring_rec_.code_c       := newrec_.code_c;
   codestring_rec_.code_d       := newrec_.code_d;
   codestring_rec_.code_e       := newrec_.code_e;
   codestring_rec_.code_f       := newrec_.code_f;
   codestring_rec_.code_g       := newrec_.code_g;
   codestring_rec_.code_h       := newrec_.code_h;
   codestring_rec_.code_i       := newrec_.code_i;
   codestring_rec_.code_j       := newrec_.code_j;
   codestring_rec_.process_code := newrec_.process_code;
   codestring_rec_.quantity     := newrec_.quantity;
   codestring_rec_.text         := newrec_.text;
   codestring_rec_.function_group := Voucher_Type_Api.Get_Voucher_Group(newrec_.company, newrec_.voucher_type);
   budget_account_              := Account_API.Is_Budget_Account(newrec_.company, codestring_rec_.code_a);
   IF (budget_account_) THEN
      Error_SYS.Record_General(lu_name_, 'BUDACCONLY: Account :P1 is only allowed for budget.', newrec_.account);
   END IF;
    
   Accounting_Codestr_API.Validate_Codestring(codestring_rec_,
                                              newrec_.company,
                                              newrec_.voucher_date,
                                              user_group_,
                                              check_codeparts_,
                                              check_demands_codeparts_,
                                              check_demands_quantity_,
                                              check_demands_process_,
                                              check_demands_text_);

END Check_Codestring___;


PROCEDURE Check_Project___ (
   newrec_            IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   function_group_    IN     VARCHAR2 )
IS
   project_origin_         VARCHAR2(30);
   dummy_codepart_value_   VARCHAR2(20);
   dummy_project_id_       VARCHAR2(20);
   ext_val_                VARCHAR2(5);
   is_project_code_part_   VARCHAR2(1); 
    
   multi_company_id_        voucher_tab.multi_company_id%TYPE;
   voucher_type_ref_        voucher_tab.voucher_type_reference%TYPE; 
   accounting_year_ref_     voucher_tab.accounting_year_reference%TYPE;
   voucher_no_ref_          voucher_tab.voucher_no_reference%TYPE;
   
BEGIN   
   is_project_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(newrec_.company, 'PRACC');
   
   IF (is_project_code_part_ = 'B') THEN
      dummy_codepart_value_ := newrec_.code_b;
   ELSIF (is_project_code_part_ = 'C') THEN
      dummy_codepart_value_ := newrec_.code_c;
   ELSIF (is_project_code_part_ = 'D') THEN
      dummy_codepart_value_ := newrec_.code_d;
   ELSIF (is_project_code_part_ = 'E') THEN
      dummy_codepart_value_ := newrec_.code_e;
   ELSIF (is_project_code_part_ = 'F') THEN
      dummy_codepart_value_ := newrec_.code_f;
   ELSIF (is_project_code_part_ = 'G') THEN
      dummy_codepart_value_ := newrec_.code_g;
   ELSIF (is_project_code_part_ = 'H') THEN
      dummy_codepart_value_ := newrec_.code_h;
   ELSIF (is_project_code_part_ = 'I') THEN
      dummy_codepart_value_ := newrec_.code_i;
   ELSIF (is_project_code_part_ = 'J') THEN
      dummy_codepart_value_ := newrec_.code_j;
   END IF;
   dummy_project_id_ := dummy_codepart_value_;
   --  removed check on project status    
      
   IF NOT (newrec_.project_activity_id = -123456 ) THEN
      IF NOT(newrec_.trans_code = 'External') THEN
         IF (newrec_.project_activity_id IS NOT NULL AND 
             dummy_codepart_value_ IS NULL) THEN
            Error_SYS.Appl_General(lu_name_, 'NOPROJSPECIFIED: A Project must be specified in order for Activity Sequence No to have a value');
         END IF;
      END IF;
   END IF;
   -- since there is a possibility to run this( ACCRULL ) without GENLED accr to spec
   IF (dummy_codepart_value_ IS NOT NULL) THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         project_origin_:= Accounting_Project_API.Get_Project_Origin_Db( newrec_.company , dummy_codepart_value_ );
      $ELSE
         project_origin_:= NULL;
      $END
   END IF;  
    
   IF project_origin_ = 'PROJECT' AND
      (newrec_.project_activity_id IS NOT NULL) AND
      (newrec_.project_activity_id > 0 ) AND
      NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'TRUE' THEN
         Error_SYS.Record_General(lu_name_, 'PROJACTINOTNULL: Account :P1 is marked for Exclude Project Follow Up and it is not allowed to post to a project activity. Remove the activity sequence before continuing.', newrec_.account);
   END IF;   
   IF (project_origin_ = 'PROJECT') AND 
      (newrec_.project_activity_id IS NULL) THEN
      IF (function_group_ != 'Z') AND 
         (function_group_ != 'A') AND
         (function_group_ != 'H') AND
         (function_group_ != 'CA') AND
         (function_group_ != 'PPC') THEN         
         
         IF(function_group_ = 'D') THEN 
            Voucher_API.Get_Reference_Info(multi_company_id_,voucher_type_ref_ , accounting_year_ref_ , voucher_no_ref_  ,
                                          newrec_.company ,newrec_.voucher_type, newrec_.accounting_year , newrec_.voucher_no );
            IF(Voucher_Type_Detail_API.Get_Function_Group(newrec_.company, voucher_type_ref_) != 'CA') THEN
               IF NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'FALSE' THEN
                   Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Activity Sequence No must have a value for Project :P1', dummy_codepart_value_);
               END IF;  
            END IF;
         ELSE 
            IF NVL(Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account), 'FALSE') = 'FALSE' THEN
               Error_SYS.Record_General(lu_name_, 'PROJACTIMANDATORY: Activity Sequence No must have a value for Project :P1', dummy_codepart_value_);
            END IF; 
         END IF;                 

      ELSIF  (function_group_ = 'Z') THEN
         $IF Component_Percos_SYS.INSTALLED $THEN
            ext_val_ := Get_Pca_Ext_Project(newrec_.company);

            IF (ext_val_ = 'FALSE') THEN
               Error_SYS.Record_General(lu_name_,'NOTALLWDFOREXTPROJS: It is not allowed to create transactions for projects created in IFS/Project.');
            END IF;
         $ELSE
            NULL;
         $END
      ELSE
         IF (function_group_ NOT IN ('M', 'K', 'Q')) THEN
            newrec_.project_activity_id := NULL;
         END IF;
      END IF;
   ELSIF (project_origin_ = 'JOB') THEN
      IF (function_group_ NOT IN ('M', 'K', 'Q','A','P','R','Z','D', 'PPC')) THEN
         IF (newrec_.project_activity_id <> 0) THEN
            Error_SYS.Record_General(lu_name_, 'ACTSEQNOMUSTBEZERO: Activity Sequence No must be zero for Project :P1', dummy_codepart_value_);
         END IF;
      ELSE
         newrec_.project_activity_id := 0;
      END IF;
   ELSIF (newrec_.project_activity_id = -123456) THEN
      IF (function_group_ NOT IN ('M', 'K', 'Q')) THEN
         newrec_.project_activity_id := NULL;
      END IF;
   END IF;
   IF (project_origin_ = 'PROJECT') THEN
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF (function_group_ NOT IN ( 'P') ) THEN
            IF (newrec_.project_activity_id IS NOT NULL) THEN
               IF (Activity_API.Is_Activity_Valid_For_Project(dummy_codepart_value_, newrec_.project_activity_id) = 0) THEN
                  Error_SYS.Record_General(lu_name_,'ACTIVITYINVALID: Activity sequence no :P1 is not connected to project :P2', newrec_.project_activity_id, dummy_codepart_value_);
               END IF;   
               IF (Activity_API.Is_Activity_Postable(dummy_codepart_value_, newrec_.project_activity_id) = 0) THEN
                  Error_SYS.Record_General(lu_name_,'ACTIDNOTPOSTABLE: In Project :P1 , Activity Sequence No :P2 is Planned, Closed or Cancelled. This operation is not allowed on Planned, Closed or Cancelled activities.',dummy_codepart_value_,newrec_.project_activity_id);
               END IF;
            END IF;
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
   IF (function_group_ NOT IN ( 'P', 'PPC') AND project_origin_ IN ('FINPROJECT','JOB','PROJECT')) THEN
      $IF Component_Genled_SYS.INSTALLED $THEN
         IF ( Accounting_Project_API.Get_Project_Db_Status(newrec_.company,dummy_codepart_value_) = 'C' ) THEN
            Error_SYS.Record_General(lu_name_,'COMPLETEDFINPROJ: This operation is not allowed on Completed Project :P1.',dummy_codepart_value_);
         END IF;
      $ELSE
         NULL;
      $END
   END IF;   
END Check_Project___;


PROCEDURE Internal_Manual_Postings___ (
   newrec_               IN VOUCHER_ROW_TAB%ROWTYPE,
   is_insert_            IN BOOLEAN,   
   base_curr_rounding_   IN NUMBER,   
   trans_curr_rounding_  IN NUMBER,
   third_curr_rounding_  IN NUMBER,
   compfin_rec_          IN Company_Finance_API.Public_Rec,
   from_pa_              IN BOOLEAN DEFAULT FALSE   )
IS
   voucher_date_            DATE;
   CURSOR get_manual_rows IS
      SELECT *
      FROM   INTERNAL_POSTINGS_ACCRUL_TAB
      WHERE  company             = newrec_.company
      AND    internal_seq_number = newrec_.internal_seq_number
      FOR UPDATE;
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF (Voucher_Type_API.Is_Vou_Type_All_Ledger(newrec_.company, newrec_.voucher_type) = 'TRUE') THEN
         IF (NOT from_pa_) THEN
            IF (NOT is_insert_) THEN
               Internal_Voucher_Util_Pub_API.Delete_Internal_Rows (newrec_.company,
                                                                   newrec_.voucher_type,
                                                                   newrec_.accounting_year,
                                                                   newrec_.voucher_no,
                                                                   newrec_.account,
                                                                   newrec_.row_no);
            ELSE
               FOR rec_ IN get_manual_rows LOOP
                  UPDATE INTERNAL_POSTINGS_ACCRUL_TAB
                  SET   voucher_no   = newrec_.voucher_no,
                        voucher_type = newrec_.voucher_type,
                        ref_row_no   = newrec_.row_no
                  WHERE CURRENT OF get_manual_rows;
               END LOOP;
            END IF;
         END IF;
         
         IF (newrec_.voucher_date IS NOT NULL) THEN
            voucher_date_ := newrec_.voucher_date;
         ELSE
            voucher_date_ := Voucher_API.Get_Voucher_Date (newrec_.company,
                                                           newrec_.accounting_year,
                                                           newrec_.voucher_type,
                                                           newrec_.voucher_no);
         END IF;
         IF ((Internal_Voucher_Util_Pub_API.Check_If_Manual (newrec_.company,
                                                             newrec_.account,
                                                             voucher_date_) IS NOT NULL) AND
            Voucher_Type_API.Get_Use_Manual(newrec_.company,
                                              newrec_.voucher_type) = 'TRUE') THEN
            Create_Int_Manual_Postings__ (newrec_.company,
                                          newrec_.voucher_type,
                                          newrec_.accounting_year,
                                          newrec_.voucher_no,
                                          newrec_.row_no,
                                          compfin_rec_,
                                          from_pa_);
         END IF;
         IF (from_pa_) THEN
            Internal_Voucher_Util_Pub_API.Create_Pa_Internal_Row (newrec_,
                                                                  NULL,
                                                                  base_curr_rounding_,   
                                                                  trans_curr_rounding_,  
                                                                  third_curr_rounding_); 
         ELSE
            Internal_Voucher_Util_Pub_API.Create_Internal_Row ( newrec_,
                                                             base_curr_rounding_,
                                                             trans_curr_rounding_,
                                                             third_curr_rounding_ );
         END IF;
      END IF;
   $ELSE
      NULL;
   $END
END Internal_Manual_Postings___;


PROCEDURE Internal_Manual_Postings___ (
   newrec_         IN VOUCHER_ROW_TAB%ROWTYPE,
   is_insert_      IN BOOLEAN DEFAULT FALSE,
   from_pa_        IN BOOLEAN DEFAULT FALSE   )
IS  
   base_curr_rounding_         NUMBER;
   trans_curr_rounding_        NUMBER;  
   third_curr_rounding_        NUMBER;
   company_rec_                Company_Finance_API.Public_Rec;   
   voucher_date_               DATE;
  
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF (newrec_.voucher_date IS NOT NULL) THEN
         voucher_date_ := newrec_.voucher_date;
      ELSE
         voucher_date_ := Voucher_API.Get_Voucher_Date (newrec_.company,
                                                        newrec_.accounting_year,
                                                        newrec_.voucher_type,
                                                        newrec_.voucher_no);
      END IF;
      company_rec_ := Company_Finance_API.Get(newrec_.company);      
      base_curr_rounding_  := Currency_Code_API.Get_currency_rounding (newrec_.company,
                                                                       company_rec_.currency_code);     
      IF (newrec_.currency_code = company_rec_.currency_code) THEN
         trans_curr_rounding_ := base_curr_rounding_;
      ELSE
         trans_curr_rounding_ := Currency_Code_API.Get_currency_rounding (newrec_.company,
                                                                          newrec_.currency_code);
      END IF;
      IF (company_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF (company_rec_.parallel_acc_currency = company_rec_.currency_code) THEN
            third_curr_rounding_ := base_curr_rounding_;
         ELSIF (company_rec_.parallel_acc_currency = newrec_.currency_code) THEN
            third_curr_rounding_ := trans_curr_rounding_;
         ELSE
            third_curr_rounding_  := Currency_Code_API.Get_currency_rounding (newrec_.company,
                                                                              company_rec_.parallel_acc_currency);
         END IF;
      END IF;
      Internal_Manual_Postings___ ( newrec_,
                                    is_insert_,
                                    base_curr_rounding_,
                                    trans_curr_rounding_,
                                    third_curr_rounding_,
                                    company_rec_,
                                    from_pa_ );
   $ELSE
      NULL;
   $END
END Internal_Manual_Postings___;


PROCEDURE Check_And_Set_Amounts___ (
   newrec_            IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   currency_amount_   IN     VOUCHER_ROW.currency_amount%TYPE,
   amount_            IN     VOUCHER_ROW.amount%TYPE,
   correction_        IN     VOUCHER_ROW.correction%TYPE)
IS
BEGIN
   IF ( NVL(newrec_.debet_amount,0) = 0 AND NVL(newrec_.credit_amount,0) = 0 ) THEN
      IF ( (amount_ > 0 AND correction_ = 'N') OR
           (amount_ < 0 AND correction_ = 'Y') ) THEN
         newrec_.debet_amount := amount_;
      ELSIF (amount_ = 0) THEN
         IF (newrec_.debet_amount = 0) THEN
            newrec_.debet_amount := 0;
            newrec_.credit_amount := NULL;
         ELSIF (newrec_.credit_amount = 0) THEN
            newrec_.credit_amount := 0;
            newrec_.debet_amount := NULL;
         ELSE
            newrec_.debet_amount := 0;
            newrec_.credit_amount := NULL;
         END IF;
      ELSE
         newrec_.credit_amount := -amount_;
      END IF;
   END IF;
   IF ( NVL(newrec_.currency_debet_amount,0) = 0 AND NVL(newrec_.currency_credit_amount,0) = 0 ) THEN
      IF ( (currency_amount_ > 0 AND correction_ = 'N') OR
           (currency_amount_ < 0 AND correction_ = 'Y') ) THEN
         newrec_.currency_debet_amount := currency_amount_;
         newrec_.currency_credit_amount := NULL;
      ELSIF (currency_amount_ = 0) THEN
         IF (amount_ <> 0) THEN
            IF (newrec_.debet_amount IS NOT NULL ) THEN
               newrec_.currency_debet_amount  := 0;
               newrec_.currency_credit_amount := NULL;
            ELSE
               newrec_.currency_debet_amount  := NULL;
               newrec_.currency_credit_amount := 0;
            END IF;
         ELSE
            IF newrec_.debet_amount = 0 THEN
                newrec_.currency_debet_amount  := 0;
                newrec_.currency_credit_amount := NULL;
            ELSIF newrec_.credit_amount = 0 THEN
                newrec_.currency_credit_amount := 0;
                newrec_.currency_debet_amount := NULL;
            ELSE
                newrec_.currency_debet_amount  := 0;
                newrec_.currency_credit_amount := NULL;
            END IF;
         END IF;
      ELSE
         newrec_.currency_credit_amount := -currency_amount_;
         newrec_.currency_debet_amount  := NULL;
      END IF;
   END IF;
END Check_And_Set_Amounts___;


PROCEDURE Check_Code_String_Fa___ (
   company_        IN VARCHAR2,
   object_id_      IN VARCHAR2,
   codestring_rec_ IN Accounting_codestr_API.CodestrRec,
   voucher_type_   IN VARCHAR2   )
IS
   TYPE FaCodestrRec IS RECORD (
      code_a        VARCHAR2(20),
      code_b        VARCHAR2(20),
      code_c        VARCHAR2(20),
      code_d        VARCHAR2(20),
      code_e        VARCHAR2(20),
      code_f        VARCHAR2(20),
      code_g        VARCHAR2(20),
      code_h        VARCHAR2(20),
      code_i        VARCHAR2(20),
      code_j        VARCHAR2(20));
   fa_codestring_rec_          FaCodestrRec;
   account_                    VOUCHER_ROW_TAB.ACCOUNT%TYPE;
   no_action                   EXCEPTION;
   ill_code_string_Fa          EXCEPTION;
   multiple_code_string_       VARCHAR2(5) := 'FALSE';

-- Authorization is not done for company because this is an
-- implementation procedure and that company should already been checked.
--
   CURSOR fa_codepart_ IS
      SELECT account code_a,
             code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j
      FROM   voucher_row_tab
      WHERE  company       = company_
      AND    account       = account_
      AND    object_id     = object_id_
      AND    object_id     IS NOT NULL;
BEGIN
   IF (object_id_ IS NULL ) THEN
      RAISE no_action;
   END IF;
--
-- Get previous used code strings for current object for given
-- code part. Only necessary to fetch one row.
--
   account_   := codestring_rec_.code_a;
   OPEN fa_codepart_;
   FETCH fa_codepart_ INTO fa_codestring_rec_;
   IF (fa_codepart_%NOTFOUND) THEN
      CLOSE fa_codepart_;
      RAISE no_action;
   ELSE
      CLOSE fa_codepart_;
   END IF;

   IF Voucher_Type_API.Get_Voucher_Group(company_,voucher_type_) = 'A' THEN
      multiple_code_string_ := 'TRUE';
   ELSE
      $IF Component_Fixass_SYS.INSTALLED $THEN
         multiple_code_string_ := Fa_Company_API.Get_Multiple_Code_String_Db(company_);   
      $ELSE
         NULL;
      $END
   END IF;
--
-- Now check the code string
--

   IF ( object_id_ IS NOT NULL ) THEN
      IF ( codestring_rec_.code_a <> fa_codestring_rec_.code_a )  AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_b,' ') <> NVL(fa_codestring_rec_.code_b,' ') )  AND  multiple_code_string_ = 'FALSE' THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_c,' ') <> NVL(fa_codestring_rec_.code_c,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_d,' ') <> NVL(fa_codestring_rec_.code_d,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_e,' ') <> NVL(fa_codestring_rec_.code_e,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_f,' ') <> NVL(fa_codestring_rec_.code_f,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_g,' ') <> NVL(fa_codestring_rec_.code_g,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_h,' ') <> NVL(fa_codestring_rec_.code_h,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_i,' ') <> NVL(fa_codestring_rec_.code_i,' ') ) AND  multiple_code_string_ = 'FALSE'  THEN
         RAISE ill_code_string_FA;
      END IF;
      IF ( NVL(codestring_rec_.code_j,' ') <> NVL(fa_codestring_rec_.code_j,' ') )  AND  multiple_code_string_ = 'FALSE' THEN
         RAISE ill_code_string_FA;
      END IF;
   END IF;
EXCEPTION
  WHEN no_action THEN
     NULL;
  WHEN ill_code_string_Fa THEN
     Error_SYS.Appl_General(lu_name_,
        'ILLFACODESTRING: Object :P1 has existing voucher rows (in the hold table)with a code string that differs from the voucher row to be created',
        object_id_ );
END Check_Code_String_Fa___;


PROCEDURE Check_Overwriting_Level___(
   newrec_           IN VOUCHER_ROW_TAB%ROWTYPE,
   attr_             IN VARCHAR2)
IS
   voucher_date_      DATE;
   amount_            NUMBER;
   deductible_factor_ NUMBER;
   tax_percentage_    NUMBER;
   amount_method_     VARCHAR2(200);
   tax_rec_           Statutory_Fee_API.Public_Rec;

   CURSOR vou_head_info IS
      SELECT amount_method,
             voucher_date
      FROM   voucher_tab
      WHERE  company         = newrec_.company
      AND    accounting_year = newrec_.accounting_year
      AND    voucher_no      = newrec_.voucher_no
      AND    voucher_type    = newrec_.voucher_type;
BEGIN
   IF (newrec_.optional_code IS NOT NULL AND newrec_.tax_amount IS NOT NULL) THEN
      OPEN vou_head_info;
      FETCH vou_head_info INTO amount_method_,
                               voucher_date_;
      CLOSE vou_head_info;
      
      IF (Client_SYS.Item_Exist('TAX_BASE_AMOUNT_TMP', attr_)) THEN
         IF (amount_method_ IN ('GROSS')) THEN
            amount_ := abs(nvl(newrec_.debet_amount, newrec_.credit_amount)) + abs(newrec_.tax_amount);
         ELSE
            amount_ := Client_SYS.Get_Item_Value('TAX_BASE_AMOUNT_TMP', attr_);
         END IF;
      ELSIF (newrec_.tax_base_amount IS NOT NULL) THEN
         amount_ := newrec_.tax_base_amount;
      ELSE
         IF (amount_method_ IN ('GROSS')) THEN
            amount_ := abs(nvl(newrec_.debet_amount, newrec_.credit_amount)) + abs(newrec_.tax_amount);
         ELSIF (amount_method_ IN ('NET')) THEN
            amount_ := abs(nvl(newrec_.debet_amount, newrec_.credit_amount));
         END IF;
      END IF;
      IF (Client_SYS.Item_Exist('TAX_PERCENTAGE', attr_)) THEN
         tax_percentage_ := Client_SYS.Get_Item_Value('TAX_PERCENTAGE', attr_);
      END IF;
      tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(newrec_.company, newrec_.optional_code, voucher_date_, 'FALSE', 'TRUE', 'FETCH_IF_VALID');      
      IF (tax_rec_.fee_type <> Fee_Type_API.DB_NO_TAX) THEN
         IF (newrec_.tax_direction = 'TAXDISBURSED') THEN
            deductible_factor_ := 1;
         ELSE
            deductible_factor_ := tax_rec_.deductible / 100;
         END IF;
         tax_percentage_ := NVL(tax_percentage_, Source_Tax_Item_API.Get_Tax_Code_Percentage(newrec_.company,
                                                                                             Tax_Source_API.DB_MANUAL_VOUCHER,
                                                                                             TO_CHAR(newrec_.accounting_year),
                                                                                             newrec_.voucher_type,
                                                                                             TO_CHAR(newrec_.voucher_no),
                                                                                             TO_CHAR(newrec_.row_no),
                                                                                             '*',
                                                                                             newrec_.optional_code));
         Tax_Handling_Accrul_Util_API.Check_Max_Overwrite_Level(newrec_.company,
                                                                newrec_.currency_code,
                                                                newrec_.optional_code,
                                                                tax_percentage_,
                                                                amount_method_,
                                                                amount_,
                                                                newrec_.tax_amount,
                                                                deductible_factor_,
                                                                tax_rec_,                                                                
                                                                voucher_date_);         
      END IF;
   END IF;
END Check_Overwriting_Level___;


PROCEDURE Delete_Internal_Rows___ (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   account_         IN VARCHAR2,
   ref_row_no_      IN NUMBER )
IS
BEGIN
   $IF Component_Intled_SYS.INSTALLED $THEN
      DELETE
      FROM  Internal_Postings_Accrul_Tab
      WHERE company           = company_
      AND   voucher_type      = voucher_type_
      AND   accounting_year   = accounting_year_
      AND   voucher_no        = voucher_no_
      AND   account           = account_
      AND   ref_row_no        = ref_row_no_;
      Internal_Voucher_Util_Pub_API.Delete_Internal_Rows (company_,
                                                          voucher_type_,
                                                          accounting_year_,
                                                          voucher_no_,
                                                          account_,
                                                          ref_row_no_);
   $ELSE
      NULL;
   $END
END Delete_Internal_Rows___;


PROCEDURE Prepare_Tax_Transaction___ (
   newrec_               IN VOUCHER_ROW_TAB%ROWTYPE,
   tax_percentage_       IN NUMBER)
IS
   rowrec_               VOUCHER_ROW_TAB%ROWTYPE;
   taxrec_               VOUCHER_ROW_TAB%ROWTYPE;
   voucher_date_         DATE;
   trans_code_           VARCHAR2(100);
   next_row_group_id_    NUMBER;
   tax_rec_              Statutory_Fee_API.Public_Rec;
   comp_fin_rec_         Company_Finance_API.Public_Rec;
   CURSOR get_next_row_group_id IS
      SELECT MAX(row_group_id) + 1
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = rowrec_.company
      AND    voucher_type    = rowrec_.voucher_type
      AND    accounting_year = rowrec_.accounting_year
      AND    voucher_no      = rowrec_.voucher_no;
BEGIN
   rowrec_ := newrec_;
   IF (rowrec_.optional_code IS NOT NULL AND 
       (rowrec_.tax_amount IS NOT NULL OR rowrec_.parallel_curr_tax_amount IS NOT NULL)   AND
       Voucher_Type_API.Get_Voucher_Group(rowrec_.company, rowrec_.voucher_type) != 'Q') THEN
      IF (rowrec_.voucher_date IS NOT NULL) THEN
         voucher_date_ := rowrec_.voucher_date;
      ELSE
         voucher_date_ := Voucher_API.Get_Voucher_Date (rowrec_.company,
                                                        rowrec_.accounting_year,
                                                        rowrec_.voucher_type,
                                                        rowrec_.voucher_no);
      END IF;
      tax_rec_ := Statutory_Fee_API.Fetch_Validate_Tax_Code_Rec(rowrec_.company,
                                                                rowrec_.optional_code,
                                                                voucher_date_,
                                                                'TRUE',
                                                                'FALSE',
                                                                'FETCH_AND_VALIDATE');

      IF (tax_rec_.fee_type != Fee_Type_API.DB_NO_TAX) THEN
         comp_fin_rec_  := Company_Finance_API.Get(rowrec_.company);
         IF (tax_rec_.fee_type IN (Fee_Type_API.DB_TAX)) THEN
            IF (rowrec_.tax_direction IN ('TAXRECEIVED')) THEN
               trans_code_ := 'AP1';
               Create_Tax_Transaction___(taxrec_,
                                         rowrec_,
                                         trans_code_,
                                         voucher_date_,
                                         comp_fin_rec_,
                                         tax_percentage_);
            ELSIF (rowrec_.tax_direction IN ('TAXDISBURSED')) THEN
               trans_code_ := 'AP2';
               Create_Tax_Transaction___(taxrec_,
                                         rowrec_,
                                         trans_code_,
                                         voucher_date_,
                                         comp_fin_rec_,
                                         tax_percentage_);
            END IF;
         ELSIF (tax_rec_.fee_type IN (Fee_Type_API.DB_CALCULATED_TAX)) THEN
            IF (rowrec_.tax_direction IN ('TAXRECEIVED')) THEN
               -- Calculate the tax amounts for the caluculated tax
               Tax_Handling_Accrul_Util_API.Calculate_Calc_Tax_Amounts(rowrec_.currency_tax_amount,
                                                                       rowrec_.tax_amount,
                                                                       rowrec_.parallel_curr_tax_amount,
                                                                       rowrec_.currency_credit_amount,
                                                                       rowrec_.currency_debet_amount,
                                                                       rowrec_.credit_amount,
                                                                       rowrec_.debet_amount,
                                                                       NULL,
                                                                       NULL,
                                                                       rowrec_.company,
                                                                       rowrec_.currency_code,
                                                                       rowrec_.optional_code,
                                                                       'FALSE',
                                                                       tax_rec_.fee_rate,
                                                                       voucher_date_);
               trans_code_ := 'AP3';
               OPEN get_next_row_group_id;
               FETCH get_next_row_group_id INTO next_row_group_id_;
               CLOSE get_next_row_group_id;

               rowrec_.row_group_id := next_row_group_id_;
               Create_Tax_Transaction___(taxrec_,
                                         rowrec_,
                                         trans_code_,
                                         voucher_date_,
                                         comp_fin_rec_,
                                         NULL);
               -- Create the counter posting for AP3
               taxrec_.trans_code := 'AP4';
               Counter_Tax_Transaction___(taxrec_, voucher_date_,rowrec_, comp_fin_rec_);
            ELSIF (rowrec_.tax_direction IN ('TAXDISBURSED')) THEN
               -- The tax transaction for CALCTAX and TAXDISBURSED should use AP2 as trans code.
               -- One transaction with 0 in amounts should be created.
               trans_code_ := 'AP2';
               Create_Tax_Transaction___(taxrec_,
                                         rowrec_,
                                         trans_code_,
                                         voucher_date_,
                                         comp_fin_rec_,
                                         NULL);
            END IF;
         END IF;
      END IF;
      
   END IF;
END Prepare_Tax_Transaction___;


PROCEDURE Create_Tax_Transaction___ (
   taxrec_               OUT VOUCHER_ROW_TAB%ROWTYPE,
   rowrec_               IN  VOUCHER_ROW_TAB%ROWTYPE,
   trans_code_           IN  VARCHAR2,
   voucher_date_         IN  DATE,
   company_rec_          IN  Company_Finance_API.Public_Rec,
   tax_percentage_       IN  NUMBER)
IS
   control_value_attr_   VARCHAR2(2000);
   codestring_rec_       Accounting_Codestr_API.CodestrRec;  
   is_base_emu_          VARCHAR2(5);
   is_third_emu_         VARCHAR2(5);
   objid_                VARCHAR2(2000);
   objversion_           VARCHAR2(2000);
   attr_                 VARCHAR2(2000);   
   -- gelr:tax_book_and_numbering, begin
   tmp_function_grp_     VARCHAR2(3);
   tax_direction_        VARCHAR2(20);
   tax_book_id_          VARCHAR2(10);
   tax_series_id_        VARCHAR2(20);
   tax_series_no_        NUMBER;
   ip10_tax_book_id_     VARCHAR2(10);
   ip10_tax_series_id_   VARCHAR2(20);
   ip10_tax_series_no_   NUMBER;
   used_tax_book_id_     VARCHAR2(20);

   CURSOR get_vou_row_tax_book_id IS
      SELECT tax_book_id, tax_series_id, tax_series_no
      FROM   voucher_row_tab
      WHERE  company         = rowrec_.company
      AND    accounting_year = rowrec_.accounting_year
      AND    voucher_type    = rowrec_.voucher_type
      AND    voucher_no      = rowrec_.voucher_no
      AND    tax_book_id     = used_tax_book_id_
      AND    tax_series_no   IS NOT NULL;
   -- gelr:tax_book_and_numbering, end   
BEGIN
   taxrec_.trans_code      := trans_code_;
   taxrec_.company         := rowrec_.company;
   taxrec_.accounting_year := rowrec_.accounting_year;
   taxrec_.voucher_no      := rowrec_.voucher_no;
   taxrec_.voucher_type    := rowrec_.voucher_type;
        
   Client_SYS.Clear_Attr(control_value_attr_);
   Client_SYS.Add_To_Attr( 'AC1', '*', control_value_attr_);
   Client_SYS.Add_To_Attr( 'AC7', rowrec_.optional_code, control_value_attr_);
   Client_SYS.Add_To_Attr( 'AC10', '*', control_value_attr_);
   Posting_Ctrl_API.Posting_Event ( codestring_rec_,
                                    rowrec_.company,
                                    taxrec_.trans_code,
                                    voucher_date_,
                                    control_value_attr_ );
                                    
   Add_Preaccounting___(codestring_rec_, rowrec_);
   
   taxrec_.row_group_id := rowrec_.row_group_id;
   taxrec_.account      := codestring_rec_.code_a;
   taxrec_.code_b       := codestring_rec_.code_b;
   taxrec_.code_c       := codestring_rec_.code_c;
   taxrec_.code_d       := codestring_rec_.code_d;
   taxrec_.code_e       := codestring_rec_.code_e;
   taxrec_.code_f       := codestring_rec_.code_f;
   taxrec_.code_g       := codestring_rec_.code_g;
   taxrec_.code_h       := codestring_rec_.code_h;
   taxrec_.code_i       := codestring_rec_.code_i;
   taxrec_.code_j       := codestring_rec_.code_j;
   taxrec_.deliv_type_id:= rowrec_.deliv_type_id; 
   IF (rowrec_.tax_amount > 0) THEN
      IF (rowrec_.debet_amount IS NOT NULL) THEN
         taxrec_.currency_debet_amount  := ABS(rowrec_.currency_tax_amount);
         taxrec_.currency_credit_amount := NULL;
         taxrec_.debet_amount           := ABS(rowrec_.tax_amount);
         taxrec_.credit_amount := NULL;
      ELSIF (rowrec_.credit_amount IS NOT NULL) THEN   -- The correction flag in the client is checked
         taxrec_.currency_credit_amount := rowrec_.currency_tax_amount * -1;
         taxrec_.currency_debet_amount  := NULL;
         taxrec_.credit_amount          := rowrec_.tax_amount * -1;
         taxrec_.debet_amount           := NULL;
      END IF;
   ELSIF (rowrec_.tax_amount < 0) THEN
      IF (rowrec_.credit_amount IS NOT NULL) THEN
         taxrec_.currency_credit_amount := ABS(rowrec_.currency_tax_amount);
         taxrec_.currency_debet_amount  := NULL;
         taxrec_.credit_amount          := ABS(rowrec_.tax_amount);
         taxrec_.debet_amount           := NULL;
      ELSIF (rowrec_.debet_amount IS NOT NULL) THEN   -- The correction flag in the client is checked
         taxrec_.currency_debet_amount  := rowrec_.currency_tax_amount;
         taxrec_.currency_credit_amount := NULL;
         taxrec_.debet_amount           := rowrec_.tax_amount;
         taxrec_.credit_amount          := NULL;
      END IF;
   ELSIF (rowrec_.tax_amount = 0) THEN                -- IF tax amount is 0 (for tax code '0' and 'E0')
      IF (rowrec_.debet_amount IS NOT NULL) THEN
         taxrec_.currency_debet_amount  := rowrec_.currency_tax_amount;
         taxrec_.currency_credit_amount := NULL;
         taxrec_.debet_amount           := rowrec_.tax_amount;
         taxrec_.credit_amount          := NULL;
         taxrec_.third_currency_debit_amount           := rowrec_.parallel_curr_tax_amount;
         taxrec_.third_currency_credit_amount          := NULL;
      ELSIF (rowrec_.credit_amount IS NOT NULL) THEN
         taxrec_.currency_credit_amount := rowrec_.currency_tax_amount;
         taxrec_.currency_debet_amount  := NULL;
         taxrec_.credit_amount          := rowrec_.tax_amount;
         taxrec_.debet_amount           := NULL;
         taxrec_.third_currency_credit_amount        := rowrec_.parallel_curr_tax_amount;
         taxrec_.third_currency_debit_amount         := NULL;
      END IF;
   END IF;

   IF (rowrec_.tax_amount IS NULL AND rowrec_.parallel_curr_tax_amount IS NOT NULL) THEN
      IF (rowrec_.parallel_curr_tax_amount > 0) THEN
         taxrec_.third_currency_debit_amount  := ABS(rowrec_.parallel_curr_tax_amount);
         taxrec_.third_currency_credit_amount := NULL;
      ELSIF (rowrec_.parallel_curr_tax_amount < 0) THEN
         taxrec_.third_currency_credit_amount := ABS(rowrec_.parallel_curr_tax_amount);
         taxrec_.third_currency_debit_amount  := NULL;      
      END IF;  
   END IF;

   taxrec_.currency_tax_amount          := NULL;
   taxrec_.tax_amount                   := NULL;
   taxrec_.currency_gross_amount        := NULL;
   taxrec_.gross_amount                 := NULL;
   taxrec_.optional_code                := rowrec_.optional_code; 
   IF (rowrec_.tax_base_amount IS NOT NULL AND rowrec_.currency_tax_base_amount IS NOT NULL) THEN
      taxrec_.tax_base_amount          := rowrec_.tax_base_amount;
      taxrec_.currency_tax_base_amount := rowrec_.currency_tax_base_amount;
   ELSE
      IF (rowrec_.tax_amount > 0) THEN
         IF (rowrec_.debet_amount IS NOT NULL) THEN
            taxrec_.tax_base_amount          := rowrec_.debet_amount;
            taxrec_.currency_tax_base_amount := rowrec_.currency_debet_amount;
         ELSIF (rowrec_.credit_amount IS NOT NULL) THEN   -- The correction flag in the client is checked
            taxrec_.tax_base_amount          := -rowrec_.credit_amount;
            taxrec_.currency_tax_base_amount := -rowrec_.currency_credit_amount;
         END IF;
      ELSIF (rowrec_.tax_amount < 0) THEN
         IF (rowrec_.credit_amount IS NOT NULL) THEN
            taxrec_.tax_base_amount          := -rowrec_.credit_amount;
            taxrec_.currency_tax_base_amount := -rowrec_.currency_credit_amount;
         ELSIF (rowrec_.debet_amount IS NOT NULL) THEN   -- The correction flag in the client is checked
            taxrec_.tax_base_amount          := rowrec_.debet_amount;
            taxrec_.currency_tax_base_amount := rowrec_.currency_debet_amount;
         END IF;
      ELSIF (rowrec_.tax_amount = 0) THEN                -- IF tax amount is 0 (for tax code '0' and 'E0')
         taxrec_.tax_base_amount          := nvl(rowrec_.debet_amount, -rowrec_.credit_amount);
         taxrec_.currency_tax_base_amount := nvl(rowrec_.currency_debet_amount, -rowrec_.currency_credit_amount);
      END IF;
   END IF;   
  
   IF (company_rec_.parallel_acc_currency IS NOT NULL) THEN      
      is_base_emu_  := Currency_Code_API.Get_Valid_Emu (rowrec_.company,
                                                        company_rec_.currency_code,
                                                        voucher_date_);
      is_third_emu_ := Currency_Code_API.Get_Valid_Emu (rowrec_.company,
                                                        company_rec_.parallel_acc_currency,
                                                        voucher_date_);      

      IF (rowrec_.parallel_curr_tax_amount IS NULL) THEN
         IF (taxrec_.debet_amount IS NOT NULL) THEN
            taxrec_.third_currency_debit_amount := Currency_Amount_API.Calculate_Parallel_Curr_Amount( rowrec_.company,
                                                             voucher_date_, 
                                                             taxrec_.debet_amount,
                                                             taxrec_.currency_debet_amount,
                                                             company_rec_.currency_code,
                                                             rowrec_.currency_code,
                                                             rowrec_.parallel_curr_rate_type,
                                                             company_rec_.parallel_acc_currency,
                                                             company_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
         END IF;
         IF (taxrec_.credit_amount IS NOT NULL) THEN
            taxrec_.third_currency_credit_amount := Currency_Amount_API.Calculate_Parallel_Curr_Amount(rowrec_.company,
                                                             voucher_date_,
                                                             taxrec_.credit_amount,
                                                             taxrec_.currency_credit_amount,
                                                             company_rec_.currency_code,
                                                             rowrec_.currency_code,                                                          
                                                             rowrec_.parallel_curr_rate_type,
                                                             company_rec_.parallel_acc_currency,
                                                             company_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
         END IF;
      ELSE
         IF (rowrec_.tax_amount > 0) THEN
            IF (rowrec_.debet_amount IS NOT NULL) THEN
               taxrec_.third_currency_debit_amount  := ABS(rowrec_.parallel_curr_tax_amount);
               taxrec_.third_currency_credit_amount := NULL;
            ELSIF (rowrec_.credit_amount IS NOT NULL) THEN
               taxrec_.third_currency_credit_amount := -rowrec_.parallel_curr_tax_amount;
               taxrec_.third_currency_debit_amount  := NULL;
            END IF;
         ELSIF (rowrec_.tax_amount < 0) THEN
            IF (rowrec_.credit_amount IS NOT NULL) THEN
               taxrec_.third_currency_credit_amount := ABS(rowrec_.parallel_curr_tax_amount);
               taxrec_.third_currency_debit_amount  := NULL;
            ELSIF (rowrec_.debet_amount IS NOT NULL) THEN
               taxrec_.third_currency_debit_amount  := rowrec_.parallel_curr_tax_amount;
               taxrec_.third_currency_credit_amount := NULL;
            END IF;  
         
         END IF;
      END IF;
      
      IF (rowrec_.parallel_curr_tax_base_amount IS NOT NULL) THEN
         taxrec_.parallel_curr_tax_base_amount := rowrec_.parallel_curr_tax_base_amount;
      ELSE
         IF (rowrec_.tax_amount > 0) THEN
            IF (rowrec_.third_currency_debit_amount IS NOT NULL) THEN
               taxrec_.parallel_curr_tax_base_amount := rowrec_.third_currency_debit_amount;
            ELSIF (rowrec_.third_currency_credit_amount IS NOT NULL) THEN   -- The correction flag in the client is checked
               taxrec_.parallel_curr_tax_base_amount := -rowrec_.third_currency_credit_amount;
            END IF;
         ELSIF (rowrec_.tax_amount < 0) THEN
            IF (rowrec_.third_currency_credit_amount IS NOT NULL) THEN
               taxrec_.parallel_curr_tax_base_amount := -rowrec_.third_currency_credit_amount;
            ELSIF (rowrec_.third_currency_debit_amount IS NOT NULL) THEN   -- The correction flag in the client is checked
               taxrec_.parallel_curr_tax_base_amount := rowrec_.third_currency_debit_amount;
            END IF;
         ELSIF (rowrec_.tax_amount = 0) THEN                -- IF tax amount is 0 (for tax code '0' and 'E0')
            taxrec_.parallel_curr_tax_base_amount := nvl(rowrec_.third_currency_debit_amount, -rowrec_.third_currency_credit_amount);
         END IF;
      END IF;   
      taxrec_.parallel_currency_rate     := rowrec_.parallel_currency_rate;
      taxrec_.parallel_conversion_factor := rowrec_.parallel_conversion_factor;
      taxrec_.parallel_curr_rate_type    := rowrec_.parallel_curr_rate_type;
   END IF;

   taxrec_.accounting_period   := rowrec_.accounting_period;
   taxrec_.currency_code       := rowrec_.currency_code;
   taxrec_.currency_rate       := rowrec_.currency_rate;
   taxrec_.conversion_factor   := rowrec_.conversion_factor;
   taxrec_.text                := rowrec_.text;
   taxrec_.corrected           := rowrec_.corrected;
   taxrec_.tax_direction       := rowrec_.tax_direction;
   taxrec_.auto_tax_vou_entry  := 'TRUE';
   taxrec_.reference_row_no    := rowrec_.row_no;
   taxrec_.reference_serie     := rowrec_.reference_serie;
   taxrec_.reference_number    := rowrec_.reference_number;
   taxrec_.transfer_id         := rowrec_.transfer_id;   
   taxrec_.multi_company_acc_year   := rowrec_.multi_company_acc_year;
   taxrec_.multi_company_id   := rowrec_.multi_company_id;
   taxrec_.multi_company_voucher_type   := rowrec_.multi_company_voucher_type;
   taxrec_.multi_company_voucher_No   := rowrec_.multi_company_voucher_No;
   
   IF ( taxrec_.multi_company_voucher_No IS NOT NULL ) THEN
      taxrec_.multi_company_row_no := Voucher_API.Get_Next_Mc_Current_Row_Number(taxrec_.multi_company_id, taxrec_.multi_company_acc_year, taxrec_.multi_company_voucher_type, taxrec_.multi_company_voucher_no );
   END IF;
   Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', taxrec_.company);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_YEAR', taxrec_.accounting_year);
   Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_TYPE', taxrec_.voucher_type);
   Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_NO', taxrec_.voucher_no);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', taxrec_.account);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_PERIOD', taxrec_.accounting_period);
   taxrec_.rowkey := NULL;
   
   -- gelr:tax_book_and_numbering, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(rowrec_.company, 'TAX_BOOK_AND_NUMBERING') = Fnd_Boolean_API.DB_TRUE) THEN
      $IF Component_Taxled_SYS.INSTALLED $THEN
         IF (Tax_Ledger_Parameter_API.Get_Allocate_Tax_Book_On_Fe_Db(rowrec_.company) = Fnd_Boolean_API.DB_FALSE) THEN                                         
            tmp_function_grp_ := Voucher_Type_Detail_API.Get_Function_Group(rowrec_.company, rowrec_.voucher_type);
            IF (tmp_function_grp_ IN ('M','N','CB') OR (tmp_function_grp_ = 'K' AND trans_code_ IN ('AP1','AP2','AP3','AP4'))) THEN
               IF (rowrec_.tax_direction = Tax_Direction_API.DB_TAX_RECEIVED) THEN
                  tax_direction_ := Tax_Direction_Sp_API.DB_RECEIVED;
               ELSE
                  tax_direction_ := Tax_Direction_Sp_API.DB_DISBURSED;
               END IF;
               used_tax_book_id_ := Tax_Code_Per_Tax_Book_API.Get_Tax_Book_By_Direction(rowrec_.company, rowrec_.optional_code, tax_direction_);
               OPEN  get_vou_row_tax_book_id;
               FETCH get_vou_row_tax_book_id INTO tax_book_id_, tax_series_id_, tax_series_no_;
               CLOSE get_vou_row_tax_book_id;

               IF (tax_series_no_ IS NULL) THEN
                  -- the logic only need to run for the first line, thereafter the same tax book info will be copied to other items
                  Tax_Book_API.Get_Tax_Book_Info(tax_book_id_,
                                                 tax_series_id_,
                                                 tax_series_no_,
                                                 ip10_tax_book_id_,
                                                 ip10_tax_series_id_,
                                                 ip10_tax_series_no_,
                                                 rowrec_.company,
                                                 rowrec_.optional_code,
                                                 voucher_date_,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 tax_direction_);
               END IF;
               taxrec_.tax_book_id   := tax_book_id_;
               taxrec_.tax_series_id := tax_series_id_;
               taxrec_.tax_series_no := tax_series_no_;               
               $IF Component_Genled_SYS.INSTALLED $THEN
                  Gen_Led_Voucher_Row_API.Validate_Liability_Date_Vou(rowrec_.company, voucher_date_, tax_series_id_);
               $END   
            END IF;
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
   -- gelr:tax_book_and_numbering, end   
   
   Tax_Handling_Accrul_Util_API.Create_Source_Tax_Item(taxrec_.company,
                                                       Tax_Source_API.DB_MANUAL_VOUCHER,
                                                       TO_CHAR(rowrec_.accounting_year),
                                                       rowrec_.voucher_type,
                                                       TO_CHAR(rowrec_.voucher_no),
                                                       TO_CHAR(rowrec_.row_no),
                                                       '*',
                                                       taxrec_.optional_code,
                                                       taxrec_.currency_code,
                                                       rowrec_.currency_tax_amount,
                                                       tax_percentage_,
                                                       rowrec_.tax_amount,
                                                       rowrec_.parallel_curr_tax_amount,
                                                       taxrec_.currency_tax_base_amount,
                                                       taxrec_.tax_base_amount,
                                                       taxrec_.parallel_curr_tax_base_amount,
                                                       voucher_date_);
      
   Check_Vou_Row_Amounts___(taxrec_, company_rec_);
   Insert___(objid_, objversion_, taxrec_, attr_);
   Internal_Manual_Postings___(taxrec_, TRUE);
   
END Create_Tax_Transaction___;
                             
                                  
PROCEDURE Counter_Tax_Transaction___ (
   taxrec_               IN OUT  VOUCHER_ROW_TAB%ROWTYPE,
   voucher_date_         IN      DATE,
   rowrec_               IN      VOUCHER_ROW_TAB%ROWTYPE,
   compfin_rec_          IN      Company_Finance_API.Public_Rec)
IS
   control_value_attr_   VARCHAR2(2000);
   codestring_rec_       Accounting_Codestr_API.CodestrRec;
   objid_                VARCHAR2(2000);
   objversion_           VARCHAR2(2000);
   attr_                 VARCHAR2(2000);   
BEGIN   
   Client_SYS.Clear_Attr(control_value_attr_);
   Client_SYS.Add_To_Attr( 'AC1', '*', control_value_attr_);
   Client_SYS.Add_To_Attr( 'AC7', taxrec_.optional_code, control_value_attr_);
   Client_SYS.Add_To_Attr( 'AC10', '*', control_value_attr_);
   Posting_Ctrl_API.Posting_Event ( codestring_rec_,
                                    taxrec_.company,
                                    taxrec_.trans_code,
                                    voucher_date_,
                                    control_value_attr_ );
                                    
   Add_Preaccounting___(codestring_rec_, rowrec_);
   
   taxrec_.account := codestring_rec_.code_a;
   taxrec_.code_b  := codestring_rec_.code_b;
   taxrec_.code_c  := codestring_rec_.code_c;
   taxrec_.code_d  := codestring_rec_.code_d;
   taxrec_.code_e  := codestring_rec_.code_e;
   taxrec_.code_f  := codestring_rec_.code_f;
   taxrec_.code_g  := codestring_rec_.code_g;
   taxrec_.code_h  := codestring_rec_.code_h;
   taxrec_.code_i  := codestring_rec_.code_i;
   taxrec_.code_j  := codestring_rec_.code_j;
   IF (taxrec_.debet_amount IS NOT NULL) THEN
      taxrec_.currency_credit_amount       := taxrec_.currency_debet_amount;
      taxrec_.currency_debet_amount        := NULL;
      taxrec_.credit_amount                := taxrec_.debet_amount;
      taxrec_.debet_amount                 := NULL;
      taxrec_.third_currency_credit_amount := taxrec_.third_currency_debit_amount;
      taxrec_.third_currency_debit_amount  := NULL;
   ELSIF (taxrec_.credit_amount IS NOT NULL) THEN
      taxrec_.currency_debet_amount        := taxrec_.currency_credit_amount;
      taxrec_.currency_credit_amount       := NULL;
      taxrec_.debet_amount                 := taxrec_.credit_amount;
      taxrec_.credit_amount                := NULL;
      taxrec_.third_currency_debit_amount  := taxrec_.third_currency_credit_amount;
      taxrec_.third_currency_credit_amount := NULL;
   END IF;
   taxrec_.tax_base_amount                 := taxrec_.tax_base_amount * -1;
   taxrec_.currency_tax_base_amount        := taxrec_.currency_tax_base_amount * -1;
   taxrec_.parallel_curr_tax_base_amount   := taxrec_.parallel_curr_tax_base_amount * -1;
   taxrec_.tax_direction                   := 'TAXDISBURSED';
   taxrec_.multi_company_acc_year   := rowrec_.multi_company_acc_year;
   taxrec_.multi_company_id   := rowrec_.multi_company_id;
   taxrec_.multi_company_voucher_type   := rowrec_.multi_company_voucher_type;
   taxrec_.multi_company_voucher_No   := rowrec_.multi_company_voucher_No;
                 
   IF ( taxrec_.multi_company_voucher_No IS NOT NULL ) THEN
      taxrec_.multi_company_row_no := Voucher_API.Get_Next_Mc_Current_Row_Number(taxrec_.multi_company_id, taxrec_.multi_company_acc_year, taxrec_.multi_company_voucher_type, taxrec_.multi_company_voucher_no );
   END IF;
         
   Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', taxrec_.company);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_YEAR', taxrec_.accounting_year);
   Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_TYPE', taxrec_.voucher_type);
   Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_NO', taxrec_.voucher_no);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', taxrec_.account);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_PERIOD', taxrec_.accounting_period);
   taxrec_.rowkey := NULL;
   Check_Vou_Row_Amounts___(taxrec_, compfin_rec_);
   Insert___(objid_, objversion_, taxrec_, attr_);
   Internal_Manual_Postings___(taxrec_, TRUE);
END Counter_Tax_Transaction___;


PROCEDURE Delete_Tax_Transaction___ (
   remrec_   IN VOUCHER_ROW_TAB%ROWTYPE )
IS
   CURSOR get_data IS
      SELECT account, row_no
      FROM VOUCHER_ROW_TAB
      WHERE company           = remrec_.company
      AND   voucher_type      = remrec_.voucher_type
      AND   accounting_year   = remrec_.accounting_year
      AND   voucher_no        = remrec_.voucher_no
      AND   reference_row_no  = remrec_.row_no;

BEGIN
   IF (remrec_.optional_code IS NOT NULL AND remrec_.tax_amount IS NOT NULL) THEN
      FOR rec_ IN get_data LOOP
         Delete_Internal_Rows___(remrec_.company, remrec_.voucher_type, remrec_.accounting_year, remrec_.voucher_no, rec_.account, rec_.row_no);
      END LOOP;
      DELETE
      FROM  VOUCHER_ROW_TAB
      WHERE company           = remrec_.company
      AND   voucher_type      = remrec_.voucher_type
      AND   accounting_year   = remrec_.accounting_year
      AND   voucher_no        = remrec_.voucher_no
      AND   reference_row_no  = remrec_.row_no;
      
      Source_Tax_Item_Accrul_API.Remove_Tax_Items(remrec_.company,
                                                  Tax_Source_API.DB_MANUAL_VOUCHER,
                                                  TO_CHAR(remrec_.accounting_year),
                                                  remrec_.voucher_type,
                                                  TO_CHAR(remrec_.voucher_no),
                                                  TO_CHAR(remrec_.row_no),
                                                  '*');
   END IF;
END Delete_Tax_Transaction___;


PROCEDURE Create_Object_Connection___ (
   newrec_ IN voucher_row_tab%ROWTYPE )
IS
   project_cost_element_            VARCHAR2(100);
   code_string_                     VARCHAR2(2000); 
   exclude_proj_followup_           VARCHAR2(5);
   followup_element_type_           VARCHAR2(20);
   used_amount_                     NUMBER;
   used_cost_amount_                NUMBER;
   posted_revenue_amount_           NUMBER;
   used_transaction_amount_         NUMBER;
   used_cost_transaction_amount_    NUMBER;
   posted_rev_transaction_amount_   NUMBER;
   transaction_currency_code_       VARCHAR2(3);
   activity_info_tab_               Public_Declarations_API.PROJ_Project_Conn_Cost_Tab;
   activity_revenue_info_tab_       Public_Declarations_API.PROJ_Project_Conn_Revenue_Tab;
   count_                           NUMBER;
   attributes_                      Public_Declarations_API.PROJ_Project_Conn_Attr_Type;
BEGIN
   $IF Component_Proj_SYS.INSTALLED $THEN
      exclude_proj_followup_               := Account_API.Get_Exclude_Proj_Followup(newrec_.company, newrec_.account);
      IF (NVL(exclude_proj_followup_, 'FALSE') = 'FALSE') THEN      
         Get_Activity_Info (used_amount_, used_transaction_amount_, newrec_ );
         transaction_currency_code_        := newrec_.currency_code;
         --if transaction amount is zero replace it with base amount
         IF (used_transaction_amount_ = 0 AND used_amount_ != 0) THEN
            used_transaction_amount_       := used_amount_;  
            transaction_currency_code_     := Company_Finance_API.Get_Currency_Code(newrec_.company);
         END IF;
         -- Here we send client value of Voucher State as it does in other object connections
         -- eventhough it is not a good practice since decoding of server value is not supported
         -- by the PROJECT_CONNECTIONS_SUMMARY View in PROJ due to performance reasons.
         project_cost_element_             := Cost_Element_To_Account_API.Get_Project_Follow_Up_Element (newrec_.company, newrec_.account, newrec_.code_b, newrec_.code_c, newrec_.code_d,
                                                                                                         newrec_.code_e, newrec_.code_f, newrec_.code_g, newrec_.code_h, newrec_.code_i,
                                                                                                         newrec_.code_j, newrec_.voucher_date, 'TRUE',
                                                                                                         default_element_type_ => 'BOTH');
         followup_element_type_            := Project_Cost_Element_API.Get_Element_Type_Db (newrec_.company,project_cost_element_);
         
         IF (followup_element_type_ = 'COST') THEN
            used_cost_amount_              := used_amount_;
            used_cost_transaction_amount_  := used_transaction_amount_;
         ELSE
            posted_revenue_amount_         := -used_amount_;
            posted_rev_transaction_amount_ := -used_transaction_amount_;
         END IF;      
         code_string_                      := Get_Codestring__(newrec_.company, newrec_.voucher_type, newrec_.accounting_year, newrec_.voucher_no, newrec_.row_no);
            
         count_                                                       := activity_info_tab_.COUNT;
     
         IF ((NVL(used_cost_transaction_amount_, 0) != 0) OR (NVL(used_cost_amount_, 0) != 0)) THEN
            activity_info_tab_(count_).control_category                  := project_cost_element_;
            activity_info_tab_(count_).used                              := used_cost_amount_;
            activity_info_tab_(count_).used_transaction                  := used_cost_transaction_amount_;
            activity_info_tab_(count_).transaction_currency_code         := transaction_currency_code_;
         END IF;
         IF ((NVL(posted_revenue_amount_, 0) != 0) OR (NVL(posted_rev_transaction_amount_, 0) != 0)) THEN
            activity_revenue_info_tab_(count_).control_category          := project_cost_element_;
            activity_revenue_info_tab_(count_).posted_revenue            := posted_revenue_amount_;
            activity_revenue_info_tab_(count_).posted_transaction        := posted_rev_transaction_amount_;
            activity_revenue_info_tab_(count_).transaction_currency_code := transaction_currency_code_;
         END IF; 
         
         count_                                                       := count_ + 1;
         attributes_.codestring                                       := code_string_;
         attributes_.last_transaction_date                            := newrec_.voucher_date;

         Project_Connection_Util_API.Create_Connection (proj_lu_name_              => 'VR',
                                                        activity_seq_              => newrec_.project_activity_id,
                                                        system_ctrl_conn_          => 'TRUE',
                                                        keyref1_                   => newrec_.company,
                                                        keyref2_                   => newrec_.voucher_type,
                                                        keyref3_                   => newrec_.accounting_year,
                                                        keyref4_                   => newrec_.voucher_no,
                                                        keyref5_                   => newrec_.row_no,
                                                        keyref6_                   => '*',
                                                        object_description_        => 'VoucherRow',
                                                        activity_info_tab_         => activity_info_tab_,
                                                        activity_revenue_info_tab_ => activity_revenue_info_tab_,
                                                        attributes_                => attributes_);
      END IF;
   $ELSE
      NULL;
   $END
END Create_Object_Connection___;


PROCEDURE Remove_Object_Connection___ (
   remrec_              IN voucher_row_tab%ROWTYPE )
IS
   vourow_exists_          BOOLEAN         := FALSE;
   exclude_proj_followup_  VARCHAR2(5);  
   vourowrec_              voucher_row_tab%ROWTYPE;   
BEGIN
   IF (remrec_.account IS NULL) THEN
      vourowrec_          := Get_Object_By_Keys___ (remrec_.company,remrec_.voucher_type,remrec_.accounting_year,remrec_.voucher_no,remrec_.row_no);
   ELSE
      vourowrec_.account  := remrec_.account;
   END IF;   
   vourow_exists_         := Check_Exist___ (remrec_.company, remrec_.voucher_type, remrec_.accounting_year, remrec_.voucher_no, remrec_.row_no );
   exclude_proj_followup_ := NVL(Account_API.Get_Exclude_Proj_Followup(remrec_.company, vourowrec_.account), 'FALSE');   
   $IF (Component_Proj_SYS.INSTALLED) $THEN
      IF (vourow_exists_ AND exclude_proj_followup_= 'FALSE') THEN  
         Project_Connection_Util_API.Remove_Connection (proj_lu_name_     => 'VR',
                                                        activity_seq_     => remrec_.project_activity_id,
                                                        keyref1_          => remrec_.company,
                                                        keyref2_          => remrec_.voucher_type,
                                                        keyref3_          => remrec_.accounting_year,
                                                        keyref4_          => remrec_.voucher_no,
                                                        keyref5_          => remrec_.row_no,
                                                        keyref6_          => '*');
      END IF;
   $END
END Remove_Object_Connection___;

   
FUNCTION Check_Int_Vou_Row___ (
   rec_  IN Internal_Postings_Accrul_Tab%ROWTYPE) RETURN BOOLEAN
IS
   posting_combination_id_ NUMBER;
   exist_                  VARCHAR2(5);
BEGIN
   $IF Component_Genled_SYS.INSTALLED $THEN
      Posting_Combination_API.Get_Combination(posting_combination_id_,
                                              rec_.account,
                                              rec_.code_b,
                                              rec_.code_c,
                                              rec_.code_d,
                                              rec_.code_e,
                                              rec_.code_f,
                                              rec_.code_g,
                                              rec_.code_h,
                                              rec_.code_i,
                                              rec_.code_j); 
   $END
   $IF Component_Intled_SYS.INSTALLED $THEN
      exist_ := Internal_Hold_Voucher_Row_API.Check_Combination(rec_.company,
                                                                rec_.ledger_id,                 
                                                                rec_.voucher_type,
                                                                rec_.accounting_year,
                                                                rec_.voucher_no,
                                                                rec_.ref_row_no,
                                                                posting_combination_id_);                                         
   $ELSE
      exist_ := NULL;
   $END

   IF (exist_ = 'TRUE') THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;                                                              
END Check_Int_Vou_Row___;


FUNCTION Obj_Conn_Refresh_Req___ (
   oldrec_     IN VOUCHER_ROW_TAB%ROWTYPE,
   newrec_     IN VOUCHER_ROW_TAB%ROWTYPE) RETURN BOOLEAN
IS
BEGIN
   IF ( ( NVL(oldrec_.debet_amount,0) != NVL(newrec_.debet_amount,0) ) OR ( NVL(oldrec_.credit_amount,0) != NVL(newrec_.credit_amount,0) ) OR ( oldrec_.account != newrec_.account ) 
     OR ( NVL(oldrec_.code_b,CHR(0)) != NVL(newrec_.code_b,CHR(0))) 
     OR ( NVL(oldrec_.code_c,CHR(0)) != NVL(newrec_.code_c,CHR(0))) OR (NVL(oldrec_.code_d,CHR(0)) != NVL(newrec_.code_d,CHR(0))) 
     OR ( NVL(oldrec_.code_e,CHR(0)) != NVL(newrec_.code_e,CHR(0))) OR (NVL(oldrec_.code_f,CHR(0)) != NVL(newrec_.code_f,CHR(0)))
     OR ( NVL(oldrec_.code_g,CHR(0)) != NVL(newrec_.code_g,CHR(0))) OR (NVL(oldrec_.code_h,CHR(0)) != NVL(newrec_.code_h,CHR(0))) 
     OR ( NVL(oldrec_.code_i,CHR(0)) != NVL(newrec_.code_i,CHR(0))) OR (NVL(oldrec_.code_j,CHR(0)) != NVL(newrec_.code_j,CHR(0)))
     OR ( oldrec_.voucher_date != newrec_.voucher_date) ) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END Obj_Conn_Refresh_Req___;


PROCEDURE Create_Cancel_Row___ (
   row_rec_     IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   compfin_rec_ IN Company_Finance_API.Public_Rec)
IS
   
   objid_      voucher_row.objid%TYPE;
   objversion_ voucher_row.objversion%TYPE;
   attr_       VARCHAR2(2000);
   indrec_     Indicator_Rec;
   validate_   BOOLEAN := FALSE;   
   -- gelr:tax_book_and_numbering, begin
   tmp_function_grp_     VARCHAR2(3);
   tax_direction_        VARCHAR2(20);
   tax_book_id_          VARCHAR2(10);
   tax_series_id_        VARCHAR2(20);
   tax_series_no_        NUMBER;
   ip10_tax_book_id_     VARCHAR2(10);
   ip10_tax_series_id_   VARCHAR2(20);
   ip10_tax_series_no_   NUMBER;
   used_tax_book_id_     VARCHAR2(20);
   tax_type_             VARCHAR2(200);
   trans_code_           VARCHAR2(100);
   voucher_date_         DATE;
   
   CURSOR get_vou_row_tax_book_id IS
      SELECT tax_book_id, tax_series_id, tax_series_no
      FROM   voucher_row_tab
      WHERE  company         = row_rec_.company
      AND    accounting_year = row_rec_.accounting_year
      AND    voucher_type    = row_rec_.voucher_type
      AND    voucher_no      = row_rec_.voucher_no
      AND    tax_book_id     = used_tax_book_id_
      AND    tax_series_no   IS NOT NULL;
   -- gelr:tax_book_and_numbering, end   
BEGIN  
   -- gelr:tax_book_and_numbering, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(row_rec_.company, 'TAX_BOOK_AND_NUMBERING') = Fnd_Boolean_API.DB_TRUE) THEN
      $IF Component_Taxled_SYS.INSTALLED $THEN
         IF (Tax_Ledger_Parameter_API.Get_Allocate_Tax_Book_On_Fe_Db(row_rec_.company) = Fnd_Boolean_API.DB_FALSE) THEN
            IF (row_rec_.tax_direction IN ('TAXRECEIVED', 'TAXDISBURSED')) THEN
               tax_type_ := Statutory_Fee_API.Get_Fee_Type(row_rec_.company, row_rec_.optional_code);
               IF (tax_type_ = 'TAX') THEN
                  IF (row_rec_.tax_direction = 'TAXRECEIVED') THEN
                     trans_code_ := 'AP1';
                  ELSIF (row_rec_.tax_direction = 'TAXDISBURSED') THEN
                     trans_code_ := 'AP2';
                  END IF;
               ELSIF (tax_type_ = 'CALCTAX') THEN
                  IF (row_rec_.tax_direction = 'TAXRECEIVED') THEN
                     trans_code_ := 'AP3';
                  ELSIF (row_rec_.tax_direction = 'TAXDISBURSED') THEN
                     trans_code_ := 'AP4';
                  END IF;
               END IF;

               tmp_function_grp_ := Voucher_Type_Detail_API.Get_Function_Group(row_rec_.company, row_rec_.voucher_type);
               IF (tmp_function_grp_ IN ('M','N','CB') OR (tmp_function_grp_ = 'K' AND trans_code_ IN ('AP1', 'AP2', 'AP3', 'AP4'))) THEN
                  IF (row_rec_.tax_direction = Tax_Direction_API.DB_TAX_RECEIVED) THEN
                     tax_direction_ := Tax_Direction_Sp_API.DB_RECEIVED;
                  ELSIF (row_rec_.tax_direction = Tax_Direction_API.DB_TAX_DISBURSED) THEN
                     tax_direction_ := Tax_Direction_Sp_API.DB_DISBURSED;
                  END IF;

                  IF (tax_direction_ IS NOT NULL) THEN
                     voucher_date_     := NVL(row_rec_.voucher_date, Voucher_API.Get_Voucher_Date(row_rec_.company, row_rec_.accounting_year, row_rec_.voucher_type, row_rec_.voucher_no));                     
                     used_tax_book_id_ := Tax_Code_Per_Tax_Book_API.Get_Tax_Book_By_Direction(row_rec_.company, row_rec_.optional_code, tax_direction_);
                     
                     OPEN  get_vou_row_tax_book_id;
                     FETCH get_vou_row_tax_book_id INTO tax_book_id_, tax_series_id_, tax_series_no_;
                     CLOSE get_vou_row_tax_book_id;
                     IF (tax_series_no_ IS NULL) THEN
                        Tax_Book_API.Get_Tax_Book_Info(tax_book_id_,
                                                       tax_series_id_,
                                                       tax_series_no_,
                                                       ip10_tax_book_id_,
                                                       ip10_tax_series_id_,
                                                       ip10_tax_series_no_,
                                                       row_rec_.company,
                                                       row_rec_.optional_code,
                                                       voucher_date_,
                                                       NULL,
                                                       NULL,
                                                       NULL,
                                                       tax_direction_);
                     END IF;
                     row_rec_.tax_book_id   := tax_book_id_;
                     row_rec_.tax_series_id := tax_series_id_;
                     row_rec_.tax_series_no := tax_series_no_;                     
                     $IF Component_Genled_SYS.INSTALLED $THEN
                        Gen_Led_Voucher_Row_API.Validate_Liability_Date_Vou(row_rec_.company, voucher_date_, tax_series_id_);
                     $END
                  END IF;
               END IF;
            END IF;
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
   -- gelr:tax_book_and_numbering, end
   
   IF (row_rec_.trans_code NOT IN ('CANCELLATION-AP1','CANCELLATION-AP2','CANCELLATION-AP3','CANCELLATION-AP4','CANCELLATION-GP3', 'CANCELLATION-GP4', 'CANCELLATION-GP5','CANCELLATION-Project')) THEN
      indrec_ := Get_Indicator_Rec___(row_rec_);
      Check_Insert___(row_rec_, indrec_, attr_);
      validate_ := TRUE;
   END IF;   
   row_rec_.rowkey := NULL;
   IF NOT validate_ THEN      
      Check_Vou_Row_Amounts___(row_rec_, compfin_rec_);
   END IF;
   Insert___(objid_, objversion_, row_rec_, attr_);   
   IF NOT (row_rec_.trans_code IN ('CANCELLATION-GP2','CANCELLATION-AUTOMATIC','CANCELLATION-GP3', 'CANCELLATION-GP4', 'CANCELLATION-GP5','CANCELLATION-Project')) THEN
      IF ( row_rec_.trans_code LIKE '%AUTOMATIC RULE%') THEN      
         Internal_Manual_Postings___(row_rec_, from_pa_=> TRUE);   
      ELSE
         Internal_Manual_Postings___(row_rec_);
      END IF;
   
   END IF;
END Create_Cancel_Row___;


FUNCTION Get_Codestring___ (
   voucher_row_        IN VOUCHER_ROW_TAB%ROWTYPE) RETURN VARCHAR2
IS
   codestring_     VARCHAR2(2000);
   tmp_codestring_ VARCHAR2(2000);
   proj_code_part_ VARCHAR2(10);
BEGIN
   proj_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function_Db(voucher_row_.company, 'PRACC');
   
   Client_SYS.Add_To_Attr('ACCOUNT', voucher_row_.account,  tmp_codestring_);

   IF proj_code_part_ = 'B' THEN
      Client_SYS.Add_To_Attr('CODE_B', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_B', voucher_row_.code_b, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'C' THEN
      Client_SYS.Add_To_Attr('CODE_C', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_C', voucher_row_.code_c, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'D' THEN
      Client_SYS.Add_To_Attr('CODE_D', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_D', voucher_row_.code_d, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'E' THEN
      Client_SYS.Add_To_Attr('CODE_E', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_E', voucher_row_.code_e, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'F' THEN
      Client_SYS.Add_To_Attr('CODE_F', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_F', voucher_row_.code_f, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'G' THEN
      Client_SYS.Add_To_Attr('CODE_G', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_G', voucher_row_.code_g, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'H' THEN
      Client_SYS.Add_To_Attr('CODE_H', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_H', voucher_row_.code_h, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'I' THEN
      Client_SYS.Add_To_Attr('CODE_I', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_I', voucher_row_.code_i, tmp_codestring_);
   END IF;

   IF proj_code_part_ = 'J' THEN
      Client_SYS.Add_To_Attr('CODE_J', '',      tmp_codestring_);
   ELSE
      Client_SYS.Add_To_Attr('CODE_J', voucher_row_.code_j, tmp_codestring_);
   END IF;

   codestring_ := tmp_codestring_;
   
   RETURN codestring_;
END Get_Codestring___;

   
PROCEDURE Add_Preaccounting___ (
   codestring_rec_            IN OUT NOCOPY Accounting_Codestr_API.CodestrRec,
   vourow_codestr_rec_        IN            VOUCHER_ROW_TAB%ROWTYPE)
IS
BEGIN   
   IF codestring_rec_.code_b = CHR(0) THEN
      codestring_rec_.code_b := vourow_codestr_rec_.code_b;
   END IF;
   IF codestring_rec_.code_c = CHR(0) THEN
      codestring_rec_.code_c := vourow_codestr_rec_.code_c;
   END IF;
   IF codestring_rec_.code_d = CHR(0) THEN
      codestring_rec_.code_d := vourow_codestr_rec_.code_d;
   END IF;
   IF codestring_rec_.code_e = CHR(0) THEN
      codestring_rec_.code_e := vourow_codestr_rec_.code_e;
   END IF;
   IF codestring_rec_.code_f = CHR(0) THEN
      codestring_rec_.code_f := vourow_codestr_rec_.code_f;
   END IF;
   IF codestring_rec_.code_g = CHR(0) THEN
      codestring_rec_.code_g := vourow_codestr_rec_.code_g;
   END IF;
   IF codestring_rec_.code_h = CHR(0) THEN
      codestring_rec_.code_h := vourow_codestr_rec_.code_h;
   END IF;
   IF codestring_rec_.code_i = CHR(0) THEN
      codestring_rec_.code_i := vourow_codestr_rec_.code_i;
   END IF;
   IF codestring_rec_.code_j = CHR(0) THEN
      codestring_rec_.code_j := vourow_codestr_rec_.code_j;
   END IF;
END Add_Preaccounting___;


PROCEDURE Create_Add_Investment_Info___ (
  newrec_        IN   VOUCHER_ROW_TAB%ROWTYPE)
IS 
  transaction_reason_  VARCHAR2(20);
  voucher_rec_         Voucher_API.Public_Rec;
BEGIN
   $IF Component_Fixass_SYS.INSTALLED $THEN
      voucher_rec_ := Voucher_API.Get( newrec_.company, 
                                       newrec_.accounting_year, 
                                       newrec_.voucher_type, 
                                       newrec_.voucher_no );         
      IF (newrec_.trans_code = 'FA CASH DISCOUNT') THEN
         transaction_reason_ := Fa_Company_API.Get_Transaction_Reason(newrec_.company);
         IF (transaction_reason_ IS NULL) THEN
            Error_SYS.Record_General(lu_name_, 'NOFATRANSRSN: Transaction Reason for Cash Discount is not defined in company :P1', newrec_.company);
         END IF;         
      END IF;
      Create_Add_Investment_Info__(newrec_, voucher_rec_, transaction_reason_);    
  $ELSE
     NULL;
  $END
END Create_Add_Investment_Info___;

PROCEDURE Create_Add_Investment_Info__ (
  newrec_               IN   VOUCHER_ROW_TAB%ROWTYPE,
  head_rec_             IN   Voucher_API.Public_Rec,
  transaction_reason_   IN   VARCHAR2)
IS 
  add_investment_attr_ VARCHAR2(3000);
  amount_              NUMBER;
  third_amount_        NUMBER;
  
BEGIN 
   $IF Component_Fixass_SYS.INSTALLED $THEN
      IF ( head_rec_.function_group != 'Q' )THEN   
         IF (ABS(newrec_.debet_amount)>0) THEN
            amount_         := newrec_.debet_amount;
            third_amount_   := newrec_.third_currency_debit_amount;
         ELSE
            amount_         := -(newrec_.credit_amount);
            third_amount_   := -(newrec_.third_currency_credit_amount);
         END IF;
         Client_SYS.Clear_Attr(add_investment_attr_);
         Client_SYS.Add_To_Attr( 'COMPANY', newrec_.company, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'SOURCE_REF', 'VOUCHER', add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF1', newrec_.voucher_no, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF2', newrec_.voucher_type, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF3', newrec_.accounting_year, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF4', newrec_.row_no, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF5', '*', add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'OBJECT_ID', newrec_.object_id, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'EVENT_DATE', head_rec_.voucher_date, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'RETROACTIVE_DATE', head_rec_.voucher_date, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'ACQ_ACCOUNT', newrec_.account, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'AMOUNT', amount_, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'THIRD_AMOUNT', third_amount_, add_investment_attr_ );
         IF (newrec_.trans_code = 'FA CASH DISCOUNT') THEN            
            IF (transaction_reason_ IS NULL) THEN
               Error_SYS.Record_General(lu_name_, 'NOFATRANSRSN: Transaction Reason for Cash Discount is not defined in company :P1', newrec_.company);
            END IF;
            Client_SYS.Add_To_Attr( 'ACQUISITION_REASON', transaction_reason_, add_investment_attr_ );
         END IF;
         Add_Investment_Info_API.New_Item(add_investment_attr_, 'DO');
      END IF;
   $ELSE
      NULL;
   $END
END Create_Add_Investment_Info__;


PROCEDURE Re_Create_Mod_Add_Inv_Info___ (
  newrec_          IN     VOUCHER_ROW_TAB%ROWTYPE)
IS
  curr_object_id_      VARCHAR2(10);
  add_investment_attr_ VARCHAR2(3000);
  amount_              NUMBER;
  third_amount_        NUMBER;
  voucher_rec_         Voucher_API.Public_Rec;
BEGIN
   $IF Component_Fixass_SYS.INSTALLED $THEN
      voucher_rec_ := Voucher_API.Get( newrec_.company, 
                                       newrec_.accounting_year, 
                                       newrec_.voucher_type, 
                                       newrec_.voucher_no );
                                       
      IF ( voucher_rec_.function_group != 'Q' )THEN
         
         Client_SYS.Clear_Attr(add_investment_attr_);
         Client_SYS.Add_To_Attr( 'SOURCE_REF', 'VOUCHER', add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'COMPANY', newrec_.company, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF1', newrec_.voucher_no, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF2', newrec_.voucher_type, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF3', newrec_.accounting_year, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF4', newrec_.row_no, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'KEYREF5', '*', add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'ACQ_ACCOUNT', newrec_.account, add_investment_attr_ );
         Client_SYS.Add_To_Attr( 'OBJECT_ID', newrec_.object_id, add_investment_attr_ );
         curr_object_id_ := Add_Investment_Info_API.Get_Object_Id('VOUCHER',
                                                                   newrec_.company,
                                                                   newrec_.voucher_no, 
                                                                   newrec_.voucher_type, 
                                                                   newrec_.accounting_year,
                                                                   newrec_.row_no,
                                                                   '*');
         IF (ABS(newrec_.debet_amount)>0) THEN
            amount_         := newrec_.debet_amount;
            third_amount_   := newrec_.third_currency_debit_amount;
         ELSE
            amount_         := -(newrec_.credit_amount);
            third_amount_   := -(newrec_.third_currency_credit_amount);
         END IF;

         --If the FA Object connected to the posting line has been changed, remove and re-create add investment information 
         IF ((newrec_.object_id IS NOT NULL AND curr_object_id_ IS NULL) OR (curr_object_id_ != newrec_.object_id)) THEN
           IF curr_object_id_ IS NOT NULL THEN
              Client_Sys.Set_Item_Value( 'OBJECT_ID', curr_object_id_, add_investment_attr_ );
              Add_Investment_Info_API.Remove_Item(add_investment_attr_, 'DO');
           END IF;
           Client_Sys.Set_Item_Value( 'OBJECT_ID', newrec_.object_id, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'EVENT_DATE', voucher_rec_.voucher_date, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'RETROACTIVE_DATE', voucher_rec_.voucher_date, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'ACQ_ACCOUNT', newrec_.account, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'AMOUNT', amount_, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'THIRD_AMOUNT', third_amount_, add_investment_attr_ );
           Add_Investment_Info_API.New_Item(add_investment_attr_,'DO');
         ELSE
           --FA Object connected to the  line has not been changed, just update the amount for the existing object
           Client_Sys.Add_To_Attr( 'EVENT_DATE', voucher_rec_.voucher_date, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'RETROACTIVE_DATE', voucher_rec_.voucher_date, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'AMOUNT', amount_, add_investment_attr_ );
           Client_Sys.Add_To_Attr( 'THIRD_AMOUNT', third_amount_, add_investment_attr_ );
           Add_Investment_Info_API.Modify_Item(add_investment_attr_, 'DO'); 
         END IF;
      END IF;
   $ELSE
      NULL;
   $END
END Re_Create_Mod_Add_Inv_Info___;


PROCEDURE Remove_Add_Investment_Info___ (
   remrec_          IN     VOUCHER_ROW_TAB%ROWTYPE)
IS 
   add_investment_attr_ VARCHAR2(3000);
BEGIN
   $IF Component_Fixass_SYS.INSTALLED $THEN
      Client_SYS.Add_To_Attr( 'SOURCE_REF', 'VOUCHER', add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'COMPANY', remrec_.company, add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'KEYREF1', remrec_.voucher_no, add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'KEYREF2', remrec_.voucher_type, add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'KEYREF3', remrec_.accounting_year, add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'KEYREF4', remrec_.row_no, add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'KEYREF5', '*', add_investment_attr_ );
      Client_SYS.Add_To_Attr( 'OBJECT_ID', remrec_.object_id, add_investment_attr_ );

      Add_Investment_Info_API.Remove_Item(add_investment_attr_, 'DO');
   $ELSE
      NULL;
   $END
END Remove_Add_Investment_Info___;


-- Check_Add_Par_Curr_Data___
--   Method that check that parallel currency fields are set (amount, rate and conversion factor).
--   If not set it will be set in the method.
PROCEDURE Check_Add_Par_Curr_Data___(
   newrec_        IN OUT NOCOPY VOUCHER_ROW_TAB%ROWTYPE,
   compfin_rec_   IN OUT NOCOPY Company_Finance_API.Public_Rec)
IS
   inverted_rate_                VARCHAR2(5);
   amount_                       NUMBER;
   currency_amount_              NUMBER;
   parallel_curr_amount_         NUMBER;
   is_debit_amount_              BOOLEAN := FALSE;
BEGIN
   IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
      IF (newrec_.parallel_curr_rate_type IS NULL) THEN
         newrec_.parallel_curr_rate_type := compfin_rec_.parallel_rate_type;
      END IF;
      -- set some temporary amount variables 
      IF (newrec_.debet_amount IS NOT NULL) THEN
         amount_ := newrec_.debet_amount;
      ELSE
         amount_ := newrec_.credit_amount;
      END IF;

      IF (newrec_.currency_debet_amount IS NOT NULL) THEN
         currency_amount_ := newrec_.currency_debet_amount;
         is_debit_amount_ := TRUE;
      ELSE
         currency_amount_ := newrec_.currency_credit_amount;
         is_debit_amount_ := FALSE;
      END IF;

      IF ((newrec_.third_currency_debit_amount IS NULL) AND (newrec_.third_currency_credit_amount IS NULL)) THEN
         -- parallel currency amount is not given then assume that rate and conversion factor is not given either. Then fetch rate and 
         -- conversion factor and calculate parallel amount
         Currency_Rate_API.Get_Parallel_Currency_Rate(newrec_.parallel_currency_rate,
                                                      newrec_.parallel_conversion_factor,
                                                      inverted_rate_,
                                                      newrec_.company,
                                                      newrec_.currency_code,
                                                      newrec_.voucher_date,
                                                      newrec_.parallel_curr_rate_type,
                                                      compfin_rec_.parallel_base,
                                                      compfin_rec_.currency_code,
                                                      compfin_rec_.parallel_acc_currency,
                                                      NULL,
                                                      NULL); 

         parallel_curr_amount_ := Currency_Amount_API.Calc_Parallel_Curr_Amt_Round(newrec_.company,
                                                                                   newrec_.voucher_date,
                                                                                   amount_,
                                                                                   currency_amount_,
                                                                                   compfin_rec_.currency_code,
                                                                                   newrec_.currency_code,
                                                                                   newrec_.parallel_curr_rate_type,
                                                                                   compfin_rec_.parallel_acc_currency,
                                                                                   compfin_rec_.parallel_base,
                                                                                   NULL,
                                                                                   NULL);
         IF (is_debit_amount_) THEN
            newrec_.third_currency_debit_amount := parallel_curr_amount_;
         ELSE
            newrec_.third_currency_credit_amount := parallel_curr_amount_;
         END IF;
      ELSE
         -- IF rate if null then assume that conversion factor is also null. Then calculate rate and fetch conversion factor.
         IF (newrec_.parallel_currency_rate IS NULL) THEN
            IF (is_debit_amount_) THEN
               parallel_curr_amount_ := newrec_.third_currency_debit_amount;
            ELSE
               parallel_curr_amount_ := newrec_.third_currency_credit_amount;
            END IF;
            newrec_.parallel_currency_rate := Currency_Amount_API.Calculate_Parallel_Curr_Rate(newrec_.company,
                                                                                               newrec_.voucher_date,
                                                                                               amount_,
                                                                                               currency_amount_,
                                                                                               parallel_curr_amount_,
                                                                                               compfin_rec_.currency_code,
                                                                                               newrec_.currency_code,
                                                                                               compfin_rec_.parallel_acc_currency,
                                                                                               compfin_rec_.parallel_base,
                                                                                               newrec_.parallel_curr_rate_type);
         END IF;
         IF (newrec_.parallel_conversion_factor IS NULL) THEN
            newrec_.parallel_conversion_factor := Currency_Rate_API.Get_Par_Curr_Rate_Conv_Factor(newrec_.company,
                                                                                                  newrec_.currency_code,
                                                                                                  newrec_.voucher_date,
                                                                                                  compfin_rec_.currency_code,
                                                                                                  compfin_rec_.parallel_acc_currency,
                                                                                                  compfin_rec_.parallel_base,
                                                                                                  newrec_.parallel_curr_rate_type);
         END IF;
      END IF;
   ELSE
      -- if parallel currency is not used then set amounts to null
      newrec_.third_currency_debit_amount := NULL;
      newrec_.third_currency_credit_amount := NULL;
   END IF;
END Check_Add_Par_Curr_Data___;

FUNCTION Is_Ext_Voucher_With_Tax (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2, 
   accounting_year_ IN NUMBER,
   voucher_number_  IN NUMBER) RETURN VARCHAR2
IS
   is_tax_lines_   VARCHAR2(5) := 'FALSE';
   dummy_          NUMBER;
   CURSOR get_vou_row_recs IS
      SELECT 1
      FROM   Voucher_Row_Tab
       WHERE  company          = company_
         AND  voucher_type     = voucher_type_
         AND  accounting_year  = accounting_year_
         AND  voucher_no       = voucher_number_
         AND  trans_code IN ('AP1', 'AP2', 'AP3', 'AP4', 'AP5')
         AND  (trans_code != 'MANUAL' AND optional_code IS NOT NULL); 
BEGIN
   OPEN  get_vou_row_recs;
   FETCH get_vou_row_recs INTO dummy_;
   IF get_vou_row_recs%FOUND THEN
      CLOSE get_vou_row_recs;
        is_tax_lines_ := 'TRUE';
      RETURN is_tax_lines_;
   END IF;
   CLOSE get_vou_row_recs;
   RETURN is_tax_lines_;
END Is_Ext_Voucher_With_Tax;

@Override
PROCEDURE Prepare_Insert___ (
   attr_  IN OUT VARCHAR2 )
IS   
   company_                voucher_row_tab.company%TYPE; 
   voucher_date_           voucher_row_tab.voucher_date%TYPE;   
   company_currency_rec_   Currency_Amount_API.CompanyCurrencyRec;
   conversion_factor_      voucher_row_tab.conversion_factor%TYPE;
   currency_rate_          voucher_row_tab.currency_rate%TYPE;
   manual_voucher_         VARCHAR2(20);   
   currency_inverted_      VARCHAR2(5);   
   decimals_in_rate_       NUMBER;
   company_finance_rec_    Company_Finance_API.Public_Rec;
BEGIN
   manual_voucher_ := NVL(Client_SYS.Get_Item_Value('MANUAL_VOUCHER', attr_), 'FALSE');
   company_      := Client_SYS.Get_Item_Value('COMPANY', attr_);
   voucher_date_ := Client_SYS.Get_Item_Value_To_Date('VOUCHER_DATE', attr_, lu_name_);                                                              
   super(attr_);   
   Client_SYS.Add_To_Attr('TRANS_CODE', 'MANUAL', attr_);      
   IF (manual_voucher_ = 'TRUE') THEN
      company_currency_rec_ := Currency_Amount_API.Get_Currency_Rec(company_);         
      Client_SYS.Add_To_Attr('CURRENCY_TYPE', Currency_Type_API.Get_Default_Type(company_), attr_);
      Currency_Rate_API.Fetch_Currency_Rate_Base(  conversion_factor_ , 
                                                currency_rate_, 
                                                currency_inverted_, 
                                                company_, 
                                                company_currency_rec_.accounting_currency, 
                                                company_currency_rec_.accounting_currency,
                                                Currency_Type_API.Get_Default_Type(company_), 
                                                voucher_date_, 
                                                'DUMMY' );
      Currency_Code_API.Get_No_Of_Decimals_In_Rate_(decimals_in_rate_, company_, company_currency_rec_.accounting_currency);

     -- Client_SYS.Add_To_Attr('ACCOUNTING_PERIOD', accounting_period_, attr_);      
      Client_SYS.Add_To_Attr('CURRENCY_RATE', ROUND(currency_rate_, decimals_in_rate_), attr_);
      Client_SYS.Add_To_Attr('AMOUNT', 0, attr_);   --
      Client_SYS.Add_To_Attr('CURRENCY_AMOUNT', 0, attr_);   --
      Client_SYS.Add_To_Attr('CURRENCY_CODE', company_currency_rec_.accounting_currency, attr_);      
      Client_SYS.Add_To_Attr('CONVERSION_FACTOR', conversion_factor_, attr_);
      Client_SYS.Add_To_Attr('AUTO_TAX_VOU_ENTRY', 'FALSE', attr_);            

      IF (company_currency_rec_.parallel_currency IS NOT NULL) THEN
         company_finance_rec_ := Company_Finance_API.Get(company_);
         Client_SYS.Add_To_Attr('PARALLEL_CURRENCY', company_currency_rec_.parallel_currency, attr_);   
         Client_SYS.Add_To_Attr('PARALLEL_CURR_RATE_TYPE', company_finance_rec_.parallel_rate_type, attr_);   

         Currency_Rate_API.Get_Parallel_Currency_Rate( currency_rate_, 
                                                      conversion_factor_,
                                                      currency_inverted_,
                                                      company_,
                                                      company_currency_rec_.accounting_currency,
                                                      voucher_date_,
                                                      company_finance_rec_.parallel_rate_type,
                                                      company_currency_rec_.parallel_base,
                                                      company_currency_rec_.accounting_currency,
                                                      company_currency_rec_.parallel_currency,
                                                      NULL,
                                                      NULL );      

         Currency_Code_API.Get_No_Of_Decimals_In_Rate_(decimals_in_rate_, company_, company_currency_rec_.parallel_currency); 
         Client_SYS.Add_To_Attr('PARALLEL_CURRENCY_RATE', ROUND(currency_rate_,decimals_in_rate_), attr_);
         Client_SYS.Add_To_Attr('PARALLEL_CONVERSION_FACTOR', conversion_factor_, attr_);      
         Client_SYS.Add_To_Attr('THIRD_CURRENCY_AMOUNT', 0, attr_);
      END IF;    
   END IF;
END Prepare_Insert___;

@Override
PROCEDURE Check_Common___ (
   oldrec_ IN     voucher_row_tab%ROWTYPE,
   newrec_ IN OUT voucher_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   state_               VARCHAR2(100);
   user_group_          VARCHAR2(30);
   authorize_level_     VARCHAR2(20);
   voucher_public_rec_  Voucher_API.Public_Rec;
   fee_type_            Statutory_Fee_Tab.fee_type%TYPE;
   company_rec_         Company_Finance_API.Public_Rec;
   conversion_factor_   NUMBER;
   currency_rate_       NUMBER;
   inverted_            VARCHAR2(5);
BEGIN   
   super(oldrec_, newrec_, indrec_, attr_);   
   company_rec_ := Company_Finance_API.Get(newrec_.company);
   voucher_public_rec_ := Voucher_API.Get(newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.voucher_no);
   user_group_       := voucher_public_rec_.user_group;
   authorize_level_  := Voucher_Type_User_Group_API.Get_Authorize_Level_Db(newrec_.company,
                                                                           newrec_.accounting_year,
                                                                           user_group_,
                                                                           newrec_.voucher_type);
   IF (authorize_level_ = 'ApproveOnly') THEN
      Error_SYS.Appl_General(lu_name_, 'APPROVEONLYCANNOTMODIFYVOUROW: Users included in a user group with :P1 authorization level are not allowed to enter or modify voucher rows', Authorize_Level_API.Decode('ApproveOnly'));
   END IF;


   -- THPELK To DO we need to valdiate thte function grooup
   IF (voucher_public_rec_.amount_method IS NULL ) THEN
      Error_SYS.Record_General(lu_name_, 'AUTOMATICVOUCHER: Vouchers created automatically cannot be modified.');
   END IF;
   IF (NVL(newrec_.trans_code,'MANUAL') ='MANUAL') THEN
      IF (voucher_public_rec_.amount_method IS NOT NULL ) THEN

         IF ((newrec_.debet_amount IS NOT NULL AND newrec_.credit_amount IS NOT NULL) OR
            (newrec_.debet_amount IS NOT NULL AND (newrec_.currency_credit_amount IS NOT NULL OR newrec_.third_currency_credit_amount IS NOT NULL)) OR
            (newrec_.credit_amount IS NOT NULL AND (newrec_.currency_debet_amount IS NOT NULL OR newrec_.third_currency_debit_amount IS NOT NULL ))) THEN
              Error_SYS.Record_General(lu_name_, 'INCORRECTAMOUNTS: Both Debit and Credit amount fields cannot have values in Accounting, Transaction or Parallel Currency.');
         NULL;
         END IF;
         IF (newrec_.process_code IS NOT NULL) THEN
            Validate_Process_Code__(newrec_.company, newrec_.process_code, voucher_public_rec_.voucher_date);
         END IF;
         IF (newrec_.deliv_type_id IS NOT NULL) THEN
            Validate_Delivery_Type_Id__(newrec_.company, newrec_.deliv_type_id);
         END IF;

         IF (newrec_.optional_code IS NOT NULL) THEN
            IF (newrec_.tax_direction IS NULL ) THEN
               Error_SYS.Record_General(lu_name_, 'NOTAXDIRECTION: Tax Direction must have a value.');
            ELSE
               fee_type_ := Statutory_Fee_API.Get_Fee_Type_Db(newrec_.company, newrec_.optional_code);

               IF (fee_type_ = Fee_Type_API.DB_NO_TAX AND newrec_.tax_direction != Tax_Direction_API.DB_NO_TAX) THEN
                  Error_SYS.Record_General(lu_name_, 'NOTAXWRONGDIRECTION: Tax direction should be No Tax.');
               ELSIF (fee_type_ != Fee_Type_API.DB_NO_TAX AND newrec_.tax_direction NOT IN ( Tax_Direction_API.DB_TAX_DISBURSED, Tax_Direction_API.DB_TAX_RECEIVED)) THEN
                  Error_SYS.Record_General(lu_name_, 'NOTAXWRONGDIRECTION2: Invalid tax direction.');
               END IF;
               IF (fee_type_ != Fee_Type_API.DB_NO_TAX ) THEN
                  IF (((NVL(newrec_.currency_debet_amount,0) - NVL(newrec_.currency_credit_amount,0) < 0) AND newrec_.currency_tax_amount > 0) OR 
                     ((NVL(newrec_.currency_debet_amount,0) - NVL(newrec_.currency_credit_amount,0) > 0) AND newrec_.currency_tax_amount < 0)) THEN

                     Error_SYS.Record_General(lu_name_, 'DIFFTAXAMOUNTSIGN: Different sign in Currency Tax Amount');
                  END IF;
                  
                  IF (((NVL(newrec_.debet_amount,0) - NVL(newrec_.credit_amount,0) < 0) AND NVL(newrec_.tax_amount,0) > 0) OR 
                     ((NVL(newrec_.debet_amount,0) - NVL(newrec_.credit_amount,0) > 0) AND NVL(newrec_.tax_amount,0) < 0)) THEN
                     Error_SYS.Record_General(lu_name_, 'DIFFACCTAXAMOUNTSIGN: Different sign in Tax Amount');
                  END IF;
                  
                  IF (((NVL(newrec_.third_currency_debit_amount,0) - NVL(newrec_.third_currency_credit_amount,0) < 0) AND NVL(newrec_.parallel_curr_tax_amount,0) > 0) OR 
                     ((NVL(newrec_.third_currency_debit_amount,0) - NVL(newrec_.third_currency_credit_amount,0) > 0) AND NVL(newrec_.parallel_curr_tax_amount,0) < 0)) THEN
                     Error_SYS.Record_General(lu_name_, 'DIFFPARRTAXAMOUNTSIGN: Different sign in Parallel Currency Tax Amount');
                  END IF;
                  IF (newrec_.tax_amount IS NULL ) THEN
                    Error_SYS.Record_General(lu_name_, 'TAXAMOUNTNULL: Tax Amount must have a value.');
                  END IF;


               END IF;
            END IF;
         END IF;
         IF (indrec_.currency_code ) THEN
           Currency_Rate_API.Fetch_Currency_Rate_Base( conversion_factor_, currency_rate_, inverted_,  newrec_.company, newrec_.currency_code, company_rec_.currency_code , newrec_.currency_type, SYSDATE, 'DUMMY' );
         END IF;               

         IF (newrec_.currency_rate IS NOT NULL AND newrec_.currency_rate <= 0) THEN 
            Error_SYS.Record_General(lu_name_, 'NEGATIVECURRRATE: Currency Rate cannot be zero or negative.');
         END IF;
      END IF;
      IF (voucher_public_rec_.rowstate = voucher_status_API.DB_CANCELLED) THEN
         Error_SYS.Record_General(lu_name_, 'CANCELLEDVOU: Voucher in cancelled state cannot be modified.');
      END IF;
      IF (newrec_.optional_code IS NOT NULL ) THEN            
         IF ( indrec_.optional_code) THEN
            IF (voucher_public_rec_.function_group = 'Q') THEN
               Client_SYS.Add_Info(lu_name_, 'NOTAXTRANS: No automatic tax transaction will be created on a voucher of function group Q');
            END IF;
         END IF;
         IF (newrec_.currency_tax_amount IS NULL AND newrec_.parallel_curr_tax_amount IS NULL ) THEN               
            Error_SYS.Appl_General(lu_name_, 'CURRTAXAMPTY: Currency Tax Amount must be entered.');         
         END IF;
      END IF;
      IF (newrec_.optional_code IS NULL AND (newrec_.tax_direction IS NOT NULL OR            
         NVL(newrec_.currency_tax_amount,0) != 0 OR
         NVL(newrec_.tax_amount,0) != 0 OR
         NVL(newrec_.parallel_curr_tax_amount,0) !=0 )) THEN
         Error_SYS.Appl_General(lu_name_, 'TAXCODENULL: Cannot have tax values when tax code does not have a value.');            
      END IF;
      IF (newrec_.currency_type IS NULL ) THEN
         Error_SYS.Record_General(lu_name_, 'RATETYPENULL: A Currency Rate Type must be specified in the voucher postings line.');                  
      END IF;  
      IF (newrec_.parallel_curr_rate_type IS NULL AND company_rec_.parallel_base IS NOT NULL ) THEN
         Error_SYS.Record_General(lu_name_, 'PARALLELRATETYPENULL: A Parallel Currency Rate Type must be specified in the voucher postings line.');                  
      END IF;   

      IF (newrec_.currency_rate IS NOT NULL AND newrec_.currency_rate <= 0) THEN 
         Error_SYS.Record_General(lu_name_, 'NEGATIVECURRRATE: Currency Rate cannot be zero or negative.');         
      END IF;
      IF (indrec_.currency_rate AND newrec_.currency_code = company_rec_.currency_code AND newrec_.currency_rate IS NOT NULL AND (newrec_.currency_rate NOT IN (1, 100))) THEN
         Error_SYS.Record_General(lu_name_, 'BASECURRSAME: Currency rate should be 1 when currency code is equal to accounting currency code.');
      END IF;

      IF (voucher_public_rec_.function_group = 'Z') THEN
         IF (Voucher_Row_API.Get_Pca_Ext_Project(newrec_.company) = 'FALSE' AND newrec_.project_activity_id IS NOT NULL ) THEN
            Error_SYS.Record_General(lu_name_, 'PCANOEXTPROJ: PCA not allowed for External Projects in Company :P1', newrec_.company);
         END IF;
      END IF;

      IF ((NVL(newrec_.currency_debet_amount,0) - NVL(newrec_.currency_credit_amount,0) != 0) AND company_rec_.parallel_base IS NOT NULL AND (NVL(newrec_.third_currency_debit_amount,0)-NVL(newrec_.third_currency_credit_amount,0) = 0) ) THEN
         Error_SYS.Record_General(lu_name_, 'NOPARALLELFORCURR: Amount in parallel currency cannot be zero/null when there is a value in the Currency Amount field.');

      END IF;
      Validate_Int_Manual(newrec_.company, 
                           newrec_.voucher_type, 
                           voucher_public_rec_.voucher_date, 
                           newrec_.internal_seq_number, 
                           newrec_.account, 
                           (nvl(newrec_.debet_amount,-newrec_.credit_amount)),
                           (nvl(newrec_.currency_debet_amount, -newrec_.currency_credit_amount)));
   END IF; 
   Check_Vou_Row_Amounts___(newrec_, company_rec_);
   IF (newrec_.parallel_curr_rate_type IS NOT NULL) THEN
      Currency_Rate_API.Check_If_Curr_Code_Exists( newrec_.company, newrec_.parallel_curr_rate_type, newrec_.currency_code);
   END IF;
   Validate_Budget_Code_Parts___(newrec_);   
   IF (Voucher_Candidate_Approver_API.Get_Approver_Count__( newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.voucher_no)> 0) THEN
      state_ := Voucher_API.Get_Objstate(newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.voucher_no);      
      IF (state_ IN ('PartiallyApproved','Confirmed')) THEN
         Error_SYS.Appl_General(lu_name_, 'CANTMODIFYAPPROVED: Cannot modify the voucher which has been Approved or Partially Approved using Voucher Approval Workflow. Cancel the approval and proceed with the modification.');
      ELSIF (state_  = 'Error') THEN
         Error_SYS.Appl_General(lu_name_, 'CANTMODIFYAPPROVEDINERR: Cannot modify the voucher in status error as voucher type :P1 is selected with Voucher Approval Workflow. Change the voucher status to Awaiting Approval and proceed with the modification.', newrec_.voucher_type);
      END IF;
   END IF;
END Check_Common___;

@Override
PROCEDURE Insert___ (
   objid_                OUT    VARCHAR2,
   objversion_           OUT    VARCHAR2,
   newrec_               IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   attr_                 IN OUT VARCHAR2 )
IS
   create_project_conn_          VARCHAR2(5); 
   rounded_                      VARCHAR2(5);
   voucher_date_                 DATE;
   base_curr_rounding_           NUMBER;
   trans_curr_rounding_          NUMBER;
   third_curr_rounding_          NUMBER;
   codestring_rec_               Accounting_codestr_API.CodestrRec;
   project_code_part_            VARCHAR2(1);
   object_code_part_             VARCHAR2(1);
   amount_to_allocate_           NUMBER;
   allocation_error_             VARCHAR2(2000);
   compfin_rec_                  Company_Finance_API.Public_Rec;
 
BEGIN
   create_project_conn_ := NVL(Client_SYS.Get_Item_Value('CREATE_PROJ_CONN', attr_), 'TRUE');
   
   newrec_.row_no := Voucher_API.Get_Next_Row_Number(newrec_.company,
                                                     newrec_.voucher_type,
                                                     newrec_.accounting_year,
                                                     newrec_.voucher_no );
   
   compfin_rec_ := Company_Finance_API.Get(newrec_.company);   
   -- Removed gets of curr_rounding (only performed when rounded != TRUE)
   rounded_ := Client_SYS.Get_Item_Value ( 'ROUNDED', attr_ );
   IF (nvl(rounded_,'FALSE') != 'TRUE') THEN
      IF (newrec_.voucher_date IS NOT NULL) THEN
         voucher_date_        := newrec_.voucher_date;
      ELSE
         voucher_date_        := Voucher_API.Get_Voucher_Date (newrec_.company,
                                                               newrec_.accounting_year,
                                                               newrec_.voucher_type,
                                                               newrec_.voucher_no);
         newrec_.voucher_date := voucher_date_;
      END IF;
    
      base_curr_rounding_  := Currency_Code_API.Get_Currency_Rounding (newrec_.company, compfin_rec_.currency_code);
      IF (newrec_.currency_code = compfin_rec_.currency_code) THEN
         trans_curr_rounding_ := base_curr_rounding_;
      ELSE
         trans_curr_rounding_ := Currency_Code_API.Get_Currency_Rounding (newrec_.company, newrec_.currency_code);
      END IF;
      IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF (compfin_rec_.parallel_acc_currency = compfin_rec_.currency_code) THEN
            third_curr_rounding_ := base_curr_rounding_;
         ELSIF (compfin_rec_.parallel_acc_currency = newrec_.currency_code) THEN
            third_curr_rounding_ := trans_curr_rounding_;
         ELSE
            third_curr_rounding_ := Currency_Code_API.Get_Currency_Rounding (newrec_.company, compfin_rec_.parallel_acc_currency);
         END IF;
      END IF;
      newrec_.credit_amount                := ROUND(newrec_.credit_amount, base_curr_rounding_);
      newrec_.debet_amount                 := ROUND(newrec_.debet_amount, base_curr_rounding_);
      newrec_.currency_credit_amount       := ROUND(newrec_.currency_credit_amount, trans_curr_rounding_);
      newrec_.currency_debet_amount        := ROUND(newrec_.currency_debet_amount, trans_curr_rounding_);
      IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF (newrec_.third_currency_debit_amount <> 0) THEN
            newrec_.third_currency_debit_amount  := ROUND(newrec_.third_currency_debit_amount, third_curr_rounding_);
         END IF;
         IF (newrec_.third_currency_credit_amount <> 0) THEN
            newrec_.third_currency_credit_amount := ROUND(newrec_.third_currency_credit_amount, third_curr_rounding_);
         END IF;
      ELSE
         -- if parallel currency is not used then set amounts to null
         newrec_.third_currency_debit_amount := NULL;
         newrec_.third_currency_credit_amount := NULL;
      END IF;
      newrec_.tax_amount                   := ROUND(newrec_.tax_amount, base_curr_rounding_);
      newrec_.currency_tax_amount          := ROUND(newrec_.currency_tax_amount, trans_curr_rounding_);
      newrec_.gross_amount                 := ROUND(newrec_.gross_amount, base_curr_rounding_);
      newrec_.currency_gross_amount        := ROUND(newrec_.currency_gross_amount, trans_curr_rounding_);
      newrec_.tax_base_amount              := ROUND(newrec_.tax_base_amount, base_curr_rounding_);
      newrec_.currency_tax_base_amount     := ROUND(newrec_.currency_tax_base_amount, trans_curr_rounding_);
   END IF;
   newrec_.year_period_key := newrec_.accounting_year*100 + newrec_.accounting_period;
   codestring_rec_.code_a  := newrec_.account;
   codestring_rec_.code_b  := newrec_.code_b;
   codestring_rec_.code_c  := newrec_.code_c;
   codestring_rec_.code_d  := newrec_.code_d;
   codestring_rec_.code_e  := newrec_.code_e;
   codestring_rec_.code_f  := newrec_.code_f;
   codestring_rec_.code_g  := newrec_.code_g;
   codestring_rec_.code_h  := newrec_.code_h;
   codestring_rec_.code_i  := newrec_.code_i;
   codestring_rec_.code_j  := newrec_.code_j;
   Codestring_Comb_API.Get_Combination (newrec_.posting_combination_id, codestring_rec_);
   newrec_.curr_balance    := Account_API.Get_Currency_Balance (newrec_.company, newrec_.account);
   project_code_part_      := Accounting_Code_Parts_API.Get_Codepart_Function ( newrec_.company, 'PRACC');
   object_code_part_       := Accounting_Code_Parts_API.Get_Codepart_Function ( newrec_.company, 'FAACC');
  
   Accounting_Codestr_API.Get_Prj_And_Obj_Code_P_Values(newrec_.project_id,
                                                        newrec_.object_id,
                                                        codestring_rec_,
                                                        project_code_part_,
                                                        object_code_part_);
                                                        
   
    
   
   IF (newrec_.currency_type IS NULL) THEN
      newrec_.currency_type := Currency_Type_API.Get_Default_Type(newrec_.company);
   END IF;
   -- Note- When conversion factor is NULL fetch it from the currency code.
   IF (newrec_.conversion_factor IS NULL) THEN
      newrec_.conversion_factor := Currency_Code_API.Get_Conversion_Factor(newrec_.company, newrec_.currency_code);
   END IF;   

   -- Check that parallel currency fields are set (amount, rate and conversion factor). IF not set it will be set in the method.
   Check_Add_Par_Curr_Data___(newrec_,
                              compfin_rec_); 
   
   IF (newrec_.allocation_id IS NOT NULL AND NVL(newrec_.currency_credit_amount, 0) = 0 AND NVL(newrec_.currency_debet_amount, 0) = 0 
   AND NVL(newrec_.credit_amount, 0) = 0 AND NVL(newrec_.debet_amount, 0) = 0 ) THEN
      newrec_.allocation_id := NULL;
   END IF;
   
   super(objid_, objversion_, newrec_, attr_);
   
   
   IF (newrec_.allocation_id IS NOT NULL) THEN
      IF (NVL(newrec_.currency_credit_amount,0) != 0) THEN
         amount_to_allocate_ := newrec_.currency_credit_amount * -1;
      ELSE
         amount_to_allocate_ := newrec_.currency_debet_amount;
      END IF;
      Period_Allocation_Rule_API.Create_Period_Allocations (allocation_error_,
                                                            newrec_.company,
                                                            newrec_.voucher_type,
                                                            newrec_.voucher_no,
                                                            newrec_.row_no,
                                                            newrec_.account,
                                                            newrec_.accounting_year,
                                                            newrec_.accounting_period,
                                                            newrec_.allocation_id,
                                                            newrec_.parent_allocation_id,
                                                            amount_to_allocate_);
      IF (allocation_error_ IS NOT NULL) THEN
         newrec_.update_error := allocation_error_;
      END IF;
   END IF;
   -- gelr:tax_book_and_numbering, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'TAX_BOOK_AND_NUMBERING')= Fnd_Boolean_API.DB_TRUE) THEN      
      Validate_Tax_Type___(newrec_.company, newrec_.voucher_type, newrec_.accounting_year, newrec_.voucher_no);
   END IF;
   -- gelr:tax_book_and_numbering, end      
   Client_SYS.Add_To_Attr('ROW_NO', newrec_.row_no, attr_ );  
   
   -- Creating Object Connection and Cost Info
   
   Handle_Object_Conns___ (newrec_, NULL, TRUE, create_project_conn_);
   
EXCEPTION
   WHEN dup_val_on_index THEN
        Error_SYS.Record_Exist(lu_name_);
END Insert___;

PROCEDURE Create_Multi_Company_Voucher(
   head_                    IN OUT VOUCHER_API.Public_Rec,
   newrec_                  IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   is_mc_voucher_finalized_ IN VARCHAR2,
   mc_vou_status_not_approved_   IN VARCHAR2)
   
IS   
   voucher_id_             VARCHAR2(300);
   corrected_              VARCHAR2(5);   
   create_voucher_head_    BOOLEAN := FALSE;
   
   -- Parent variables
   parent_company_  VOUCHER_ROW_TAB.company%TYPE;
   parent_accounting_year_ VOUCHER_ROW_TAB.accounting_year%TYPE;
   parent_voucher_type_ VOUCHER_ROW_TAB.voucher_type%TYPE;
   parent_voucher_no_ VOUCHER_ROW_TAB.voucher_no%TYPE;
   
   -- child variables
   child_company_  VOUCHER_ROW_TAB.company%TYPE;
   child_company_accounting_year_ VOUCHER_ROW_TAB.accounting_year%TYPE;
   child_company_voucher_type_ VOUCHER_ROW_TAB.voucher_type%TYPE;
   child_company_voucher_no_ VOUCHER_ROW_TAB.voucher_no%TYPE;
   child_company_acc_period_ VOUCHER_ROW_TAB.accounting_period%TYPE;
   parent_rec_ Voucher_api.Public_Rec;
  -- mc_vou_row_rec_ Multi_Company_Voucher_row_Tab%ROWTYPE;
   voucher_text_ voucher_tab.voucher_text2%TYPE; 
   child_user_group_ Voucher_Tab.user_group%TYPE; 
   
   CURSOR get_header_rec IS
      SELECT t.company, t.voucher_type, t.accounting_year,t.voucher_no, t.accounting_period
      FROM voucher_tab t
      WHERE t.multi_company_id IS NOT NULL 
      and t.company                    = newrec_.company
      AND t.voucher_no_reference       = parent_voucher_no_
      AND t.accounting_year_reference  = parent_accounting_year_
      AND t.voucher_type_reference     = parent_voucher_type_
      AND t.multi_company_id           = parent_company_;      
      
   CURSOR get_text_ IS
      SELECT voucher_text2  
      FROM voucher_tab
      WHERE company         = newrec_.company 
      AND   accounting_year = newrec_.accounting_year
      AND   voucher_type    = newrec_.voucher_type
      AND   voucher_no      = newrec_.voucher_no;
         
BEGIN        
   -- get parent information
   parent_voucher_type_      := newrec_.multi_company_voucher_type;
   parent_voucher_no_        := newrec_.multi_company_voucher_no;
   parent_accounting_year_   := newrec_.multi_company_acc_year;
   parent_company_           := newrec_.multi_company_id;                                                  

   -- Check Any MC voucher Row exists in GL
   
   $IF Component_Genled_SYS.INSTALLED $THEN
      IF (parent_voucher_no_ >0 AND Voucher_API.Get_Manual_Balance_Db(parent_company_, parent_accounting_year_, parent_voucher_type_, parent_voucher_no_)= 'FALSE') THEN
         IF (Gen_Led_Voucher_Row_API.Multi_company_Voucher_Exists(parent_company_, parent_accounting_year_, parent_voucher_type_, parent_voucher_no_) = 'TRUE' ) THEN
            Error_SYS.Record_General(lu_name_, 'MCUPDATEDTOGL2: A new voucher line cannot be entered as one or more multi company vouchers have been updated to the General Ledger.');
         END IF;
      END IF;
   $END
      
   -- check voucher head already exists         
   OPEN get_header_rec;
   FETCH get_header_rec INTO child_company_, child_company_voucher_type_, child_company_accounting_year_, child_company_voucher_no_, child_company_acc_period_;
   CLOSE get_header_rec;
   -- Check Original Voucher exists
   IF (newrec_.multi_company_voucher_no >0) THEN
      Voucher_API.Exist(newrec_.multi_company_id, newrec_.multi_company_acc_year, newrec_.multi_company_voucher_type, newrec_.multi_company_voucher_no);
   END IF;
   -- Multi_company_header already exists
   IF ( child_company_ IS NOT NULL) THEN 
      newrec_.voucher_type := child_company_voucher_type_;
      newrec_.voucher_no := child_company_voucher_no_;
      newrec_.accounting_year := child_company_accounting_year_;
      newrec_.accounting_period := child_company_acc_period_;
      newrec_.transfer_id := 0;
      --newrec_.company := child_company_; 
   ELSE
      -- multi_company voucher header not exists need to create a new one
      -- but can have the reference information on the header    
      create_voucher_head_ := TRUE;
      parent_rec_             := Voucher_API.Get(parent_company_, parent_accounting_year_, parent_voucher_type_, parent_voucher_no_);
      newrec_.voucher_date := parent_rec_.voucher_date;

      OPEN get_text_;
      FETCH get_text_ INTO voucher_text_;
      CLOSE get_text_;

      newrec_.transfer_id := NULL;
      newrec_.voucher_no := 0 ;           
   END IF;    
      
   IF ( create_voucher_head_) THEN
      child_user_group_ := User_Group_Member_Finance_API.Get_Default_Group(newrec_.company,Fnd_Session_API.Get_Fnd_User);
      User_Group_Period_API.get_period( newrec_.Accounting_year, 
                                        newrec_.accounting_period,
                                        newrec_.company,
                                        child_user_group_,
                                        newrec_.voucher_date );
      Voucher_Type_User_Group_API.Get_Default_Voucher_Type( child_company_voucher_type_,
                                                            newrec_.company,
                                                            child_user_group_,
                                                            newrec_.accounting_year,
                                                            'D');
      -- find the matching multi_company header exists
      -- need to change the header of the multi company voucher header if header infromation is changed. need to do this in voucher header as well.
      corrected_   := 'N';
      IF (is_mc_voucher_finalized_ = 'FALSE' AND mc_vou_status_not_approved_ = 'TRUE') THEN         
         App_Context_SYS.Set_Value('IS_MULTI_COMPANY_MANUAL', TRUE);     
      END IF;
      newrec_.voucher_no := 0;
      Voucher_API.New_Voucher (child_company_voucher_type_ ,child_company_voucher_no_,voucher_id_,child_company_accounting_year_,
                              newrec_.accounting_period, newrec_.company , NULL,
                              newrec_.voucher_date , 'D',child_user_group_ , corrected_, parent_voucher_type_,
                              parent_accounting_year_ ,parent_voucher_no_ , parent_company_, '', voucher_text_ , amount_method_ => parent_rec_.amount_method);

      newrec_.voucher_type := child_company_voucher_type_;
      newrec_.voucher_no := child_company_voucher_no_;
      newrec_.accounting_year := child_company_accounting_year_;
      App_Context_SYS.Set_Value('IS_MULTI_COMPANY_MANUAL', FALSE);
   END IF;
   
   newrec_.multi_company_row_no := Voucher_API.Get_Next_Mc_Current_Row_Number(newrec_.multi_company_id, newrec_.multi_company_acc_year, newrec_.multi_company_voucher_type, newrec_.multi_company_voucher_no );
   head_ := Voucher_API.Get(newrec_.company,
                            newrec_.accounting_year,
                            newrec_.voucher_type,
                            newrec_.voucher_no );
   newrec_.transfer_id := head_.transfer_id;                            
END Create_Multi_Company_Voucher;
   

@Override
PROCEDURE Update___ (
   objid_      IN     VARCHAR2,
   oldrec_     IN     VOUCHER_ROW_TAB%ROWTYPE,
   newrec_     IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   attr_       IN OUT VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   by_keys_    IN     BOOLEAN DEFAULT FALSE )
IS   
   voucher_date_                 DATE;
   base_curr_rounding_           NUMBER;
   trans_curr_rounding_          NUMBER;
   third_curr_rounding_          NUMBER;
   tax_base_amount_              NUMBER;
   curr_tax_base_amount_         NUMBER;
   para_curr_tax_base_amount_    NUMBER;
   tax_percentage_               NUMBER;
   codestring_rec_               Accounting_codestr_API.CodestrRec;
   project_code_part_            VARCHAR2(1);
   object_code_part_             VARCHAR2(1);
   compfin_rec_                  Company_Finance_API.Public_Rec;
BEGIN
   compfin_rec_ := Company_Finance_API.Get(newrec_.company);   
   -- Only perform roundings when any amount is changed  
   IF (newrec_.credit_amount                 = oldrec_.credit_amount                AND
       newrec_.debet_amount                  = oldrec_.debet_amount                 AND
       newrec_.currency_credit_amount        = oldrec_.currency_credit_amount       AND
       newrec_.currency_debet_amount         = oldrec_.currency_debet_amount        AND
       newrec_.third_currency_debit_amount   = oldrec_.third_currency_debit_amount  AND
       newrec_.third_currency_credit_amount  = oldrec_.third_currency_credit_amount AND
       newrec_.tax_amount                    = oldrec_.tax_amount                   AND
       newrec_.currency_tax_amount           = oldrec_.currency_tax_amount          AND
       newrec_.parallel_curr_tax_amount      = oldrec_.parallel_curr_tax_amount     AND
       newrec_.gross_amount                  = oldrec_.gross_amount                 AND
       newrec_.currency_gross_amount         = oldrec_.currency_gross_amount        AND
       newrec_.tax_base_amount               = oldrec_.tax_base_amount              AND       
       newrec_.currency_tax_base_amount      = oldrec_.currency_tax_base_amount     AND
       newrec_.parallel_curr_tax_base_amount = oldrec_.parallel_curr_tax_base_amount) THEN
      NULL;
   ELSE
      IF (newrec_.voucher_date IS NOT NULL) THEN
         voucher_date_        := newrec_.voucher_date;
      ELSE
         voucher_date_        := Voucher_API.Get_Voucher_Date (newrec_.company,
                                                               newrec_.accounting_year,
                                                               newrec_.voucher_type,
                                                               newrec_.voucher_no);
         newrec_.voucher_date := voucher_date_;
      END IF;     
      base_curr_rounding_  := Currency_Code_API.Get_currency_rounding (newrec_.company, compfin_rec_.currency_code);
      IF (newrec_.currency_code = compfin_rec_.currency_code) THEN
         trans_curr_rounding_ := base_curr_rounding_;
      ELSE
         trans_curr_rounding_ := Currency_Code_API.Get_currency_rounding (newrec_.company, newrec_.currency_code);
      END IF;
      IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF (compfin_rec_.parallel_acc_currency = compfin_rec_.currency_code) THEN
            third_curr_rounding_ := base_curr_rounding_;
         ELSIF (compfin_rec_.parallel_acc_currency = newrec_.currency_code) THEN
            third_curr_rounding_ := trans_curr_rounding_;
         ELSE
            third_curr_rounding_  := Currency_Code_API.Get_currency_rounding (newrec_.company, compfin_rec_.parallel_acc_currency);
         END IF;
      END IF;
      newrec_.credit_amount                 := ROUND(newrec_.credit_amount, base_curr_rounding_);
      newrec_.debet_amount                  := ROUND(newrec_.debet_amount, base_curr_rounding_);
      newrec_.currency_credit_amount        := ROUND(newrec_.currency_credit_amount, trans_curr_rounding_);
      newrec_.currency_debet_amount         := ROUND(newrec_.currency_debet_amount, trans_curr_rounding_);
      newrec_.third_currency_debit_amount   := ROUND(newrec_.third_currency_debit_amount, third_curr_rounding_);
      newrec_.third_currency_credit_amount  := ROUND(newrec_.third_currency_credit_amount, third_curr_rounding_);
      newrec_.tax_amount                    := ROUND(newrec_.tax_amount, base_curr_rounding_);
      newrec_.currency_tax_amount           := ROUND(newrec_.currency_tax_amount, trans_curr_rounding_);
      newrec_.parallel_curr_tax_amount      := ROUND(newrec_.parallel_curr_tax_amount, third_curr_rounding_);
      newrec_.gross_amount                  := ROUND(newrec_.gross_amount, base_curr_rounding_);
      newrec_.currency_gross_amount         := ROUND(newrec_.currency_gross_amount, trans_curr_rounding_);
      newrec_.tax_base_amount               := ROUND(newrec_.tax_base_amount, base_curr_rounding_);
      newrec_.currency_tax_base_amount      := ROUND(newrec_.currency_tax_base_amount, trans_curr_rounding_);
      newrec_.parallel_curr_tax_base_amount := ROUND(newrec_.currency_tax_base_amount, third_curr_rounding_);
   END IF;
   newrec_.year_period_key := newrec_.accounting_year*100 + newrec_.accounting_period;
   IF (newrec_.account = oldrec_.account AND
       newrec_.code_b  = oldrec_.code_b  AND
       newrec_.code_c  = oldrec_.code_c  AND
       newrec_.code_d  = oldrec_.code_d  AND
       newrec_.code_e  = oldrec_.code_e  AND
       newrec_.code_f  = oldrec_.code_f  AND
       newrec_.code_g  = oldrec_.code_g  AND
       newrec_.code_h  = oldrec_.code_h  AND
       newrec_.code_i  = oldrec_.code_i  AND
       newrec_.code_j  = oldrec_.code_j) THEN
      NULL;
   ELSE
      codestring_rec_.code_a  := newrec_.account;
      codestring_rec_.code_b  := newrec_.code_b;
      codestring_rec_.code_c  := newrec_.code_c;
      codestring_rec_.code_d  := newrec_.code_d;
      codestring_rec_.code_e  := newrec_.code_e;
      codestring_rec_.code_f  := newrec_.code_f;
      codestring_rec_.code_g  := newrec_.code_g;
      codestring_rec_.code_h  := newrec_.code_h;
      codestring_rec_.code_i  := newrec_.code_i;
      codestring_rec_.code_j  := newrec_.code_j;
      Codestring_Comb_API.Get_Combination (newrec_.posting_combination_id, codestring_rec_);
      project_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function(newrec_.company, 'PRACC');
      object_code_part_  := Accounting_Code_Parts_API.Get_Codepart_Function(newrec_.company, 'FAACC');
      Accounting_Codestr_API.Get_Prj_And_Obj_Code_P_Values(newrec_.project_id,
                                                           newrec_.object_id,
                                                           codestring_rec_,
                                                           project_code_part_,
                                                           object_code_part_);
   END IF;
   -- Note- When conversion factor is NULL fetch it from the currency code.
   IF (newrec_.conversion_factor IS NULL) THEN
      newrec_.conversion_factor := Currency_Code_API.Get_Conversion_Factor(newrec_.company, newrec_.currency_code);
   END IF;

   -- Check that parallel currency fields are set (amount, rate and conversion factor). IF not set it will be set in the method.
   Check_Add_Par_Curr_Data___(newrec_, compfin_rec_);
   Delete_Tax_Transaction___(oldrec_);
   
   IF (newrec_.tax_base_amount IS NOT NULL OR newrec_.currency_tax_base_amount IS NOT NULL OR newrec_.parallel_curr_tax_base_amount IS NOT NULL) THEN
      tax_base_amount_ := newrec_.tax_base_amount;
      newrec_.tax_base_amount := NULL;
      curr_tax_base_amount_ := newrec_.currency_tax_base_amount;
      newrec_.currency_tax_base_amount := NULL;
      para_curr_tax_base_amount_ := newrec_.parallel_curr_tax_base_amount;
      newrec_.parallel_curr_tax_base_amount := NULL;
   END IF;
  
   super(objid_, oldrec_, newrec_, attr_, objversion_, by_keys_);

   -- Handling Object Connection and Cost Info
   Handle_Object_Conns___ (newrec_, oldrec_, FALSE, 'FALSE');

   Internal_Manual_Postings___(newrec_);
   IF (tax_base_amount_ IS NOT NULL) THEN
      newrec_.tax_base_amount := tax_base_amount_;
   END IF;
   IF (curr_tax_base_amount_ IS NOT NULL) THEN
      newrec_.currency_tax_base_amount := curr_tax_base_amount_;
   END IF;
   IF (para_curr_tax_base_amount_ IS NOT NULL) THEN
      newrec_.parallel_curr_tax_base_amount := para_curr_tax_base_amount_;
   END IF;
   IF (Client_SYS.Item_Exist('TAX_PERCENTAGE', attr_)) THEN
      tax_percentage_ := Client_SYS.Get_Item_Value('TAX_PERCENTAGE', attr_);
   END IF;
   Prepare_Tax_Transaction___(newrec_, tax_percentage_);
   $IF Component_Fixass_SYS.INSTALLED $THEN
      Re_Create_Mod_Add_Inv_Info___(newrec_);
   $END
   -- gelr:tax_book_and_numbering, begin
   IF (Company_Localization_Info_API.Get_Parameter_Value_Db(newrec_.company, 'TAX_BOOK_AND_NUMBERING')= Fnd_Boolean_API.DB_TRUE) THEN      
      Validate_Tax_Type___(newrec_.company, newrec_.voucher_type, newrec_.accounting_year, newrec_.voucher_no);
   END IF;
   -- gelr:tax_book_and_numbering, end      
EXCEPTION
   WHEN dup_val_on_index THEN
      Error_SYS.Record_Exist(lu_name_);
END Update___;


@Override
PROCEDURE Check_Delete___ (
   remrec_ IN VOUCHER_ROW_TAB%ROWTYPE )
IS
   simulation_voucher_  VARCHAR2(5);
   allocated_           VARCHAR2(1);
   head_rec_            Voucher_API.Public_Rec;
BEGIN
   IF (remrec_.trans_code = 'MANUAL') THEN
      head_rec_ := Voucher_API.Get(remrec_.company, remrec_.accounting_year, remrec_.voucher_type, remrec_.voucher_no);
      IF (head_rec_.amount_method IS NOT NULL ) THEN
         IF (head_rec_.rowstate = Voucher_Status_API.DB_ERROR) THEN
            Error_SYS.Record_General(lu_name_, 'VOUINERRORSTATE: It is not possible to delete a voucher row for a voucher in Status Error.');         
         END if;
         IF (Voucher_Type_User_Group_API.Get_Authorize_Level_Db(remrec_.company, remrec_.accounting_year, head_rec_.user_group, remrec_.voucher_type ) = Authorize_Level_API.DB_APPROVE_ONLY) THEN
            Error_SYS.Appl_General(lu_name_, 'APPROVEONLYCANNOTREMOVE: Users included in a user group with :P1 authorization level are not allowed to remove voucher rows', Authorize_Level_API.Decode(Authorize_Level_API.DB_APPROVE_ONLY));
         END IF;
      END IF;
   END IF;
   IF (upper(remrec_.trans_code) != 'MANUAL') THEN
      simulation_voucher_ := Voucher_Type_API.Get_Simulation_Voucher ( remrec_.company, remrec_.voucher_type);
      IF (simulation_voucher_ = 'FALSE') THEN
         Error_SYS.Record_General(lu_name_, 'NODELMANUAL: The voucher row is automatically created and cannot be deleted');
      END IF;
   END IF;
   allocated_ := Period_Allocation_API.Any_Allocation( remrec_.company,
                                                       remrec_.voucher_type,
                                                       remrec_.voucher_no,
                                                       remrec_.row_no,
                                                       remrec_.accounting_year);
   IF (allocated_ = 'Y') THEN
      Error_SYS.Record_General(lu_name_, 'EXISTINPERALLOC: Can not change Voucher row that exists in Period Allocation');
   END IF;   
   -- you cannot remove a MC voucher row which is created by Automatic Due/To From
   IF (remrec_.multi_company_acc_year IS NOT NULL AND 
       remrec_.row_group_id IS NOT NULL AND 
       Voucher_API.Is_Auto_Due_To_From_Created(remrec_.company,
                                               remrec_.voucher_type,
                                               remrec_.accounting_year,
                                               remrec_.voucher_no)= 'TRUE') THEN    
      Error_SYS.Record_General(lu_name_, 'EXISTMCROW: Can not change Voucher row that exists in Multi Company Voucher.');
   END IF;   
   
   super(remrec_);
END Check_Delete___;


@Override
PROCEDURE Delete___ (
   objid_  IN VARCHAR2,
   remrec_ IN VOUCHER_ROW_TAB%ROWTYPE )
IS
BEGIN
   -- Removing Object Connection and Cost Info
   IF (NVL(remrec_.project_activity_id,0) != 0) THEN
      Remove_Object_Connection___(remrec_);   
   END IF;
--   IF (remrec_.multi_company_acc_year IS NOT NULL) THEN 
--      Multi_Company_Voucher_Row_API.Remove_Item(remrec_.multi_company_id, remrec_.multi_company_voucher_type, remrec_.multi_company_voucher_no, remrec_.multi_company_acc_year, remrec_.multi_company_row_no);   
--   END IF;
   
   Delete_Tax_Transaction___(remrec_);
   super(objid_, remrec_);
   Delete_Internal_Rows___ (remrec_.company,
                            remrec_.voucher_type,
                            remrec_.accounting_year,
                            remrec_.voucher_no,
                            remrec_.account,
                            remrec_.row_no);
   
   $IF Component_Fixass_SYS.INSTALLED $THEN
      Remove_Add_Investment_Info___(remrec_);
   $END
   
   -- Delete the entire voucher head if all the voucher rows are deleted of an MC Not Approved Voucher
   IF (remrec_.multi_company_row_no IS NOT NULL AND remrec_.voucher_no<0) THEN
      Remove_Mc_Head(remrec_.company, remrec_.accounting_year, remrec_.voucher_type,remrec_.voucher_no);
   END IF;
END Delete___;

PROCEDURE Remove_Mc_Head(
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN NUMBER)
IS   
   CURSOR exists_any_row IS
      SELECT 1
      FROM voucher_Row_Tab
      WHERE company        = company_
      AND accounting_year  = accounting_year_
      AND voucher_type     = voucher_type_
      AND voucher_no       = voucher_no_;
   count_                  NUMBER;
BEGIN
   OPEN exists_any_row;
   FETCH exists_any_row INTO count_;
   IF (exists_any_row%NOTFOUND) THEN
      CLOSE exists_any_row;
      -- Remove IL Vouchers   
      $IF Component_Intled_SYS.INSTALLED $THEN
      Internal_Voucher_Util_Pub_API.Remove_Connected_Il_Vouchers(company_, voucher_type_, accounting_year_, voucher_no_);
      $END
      -- remove Hold Table header
      Voucher_API.Remove_By_Keys_(company_, voucher_type_, accounting_year_, voucher_no_);
      
   ELSE      
      CLOSE exists_any_row;
   END IF;
   
END Remove_Mc_Head;

FUNCTION Check_If_Code_Part_Used___(
   company_   IN VARCHAR2,
   code_part_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_ NUMBER;
   CURSOR is_used_ IS
      SELECT 1
      FROM   voucher_row_tab
      WHERE  company = company_
      AND    DECODE(code_part_,'A',account,
                               'B',code_b,
                               'C',code_c,
                               'D',code_d,
                               'E',code_e,
                               'F',code_f,
                               'G',code_g,
                               'H',code_h,
                               'I',code_i,
                               'J',code_j) IS NOT NULL;
BEGIN
  OPEN  is_used_;
  FETCH is_used_ INTO dummy_;
  IF (is_used_%NOTFOUND) THEN
     CLOSE is_used_;
     RETURN FALSE;
  END IF;
  CLOSE is_used_;
  RETURN TRUE;
END Check_If_Code_Part_Used___;


@Override
PROCEDURE Check_Insert___ (
   newrec_ IN OUT voucher_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                     VARCHAR2(30);
   value_                    VARCHAR2(4000);
   head_                     Voucher_API.Public_Rec;
   ledger_account_           BOOLEAN;
   function_group_           VARCHAR2(20);
   simulation_voucher_       VARCHAR2(20);
   user_group_               user_group_member_finance_tab.user_group%type;
   amount_method_            VARCHAR2(200);
   interim_tax_ledger_accnt_ VARCHAR2(5):= 'FALSE';
   is_mc_voucher_finalized_  VARCHAR2(5);
   tax_types_event_          VARCHAR2(10) := 'RESTRICTED';
   mc_vou_status_not_approved_   VARCHAR2(5);
   
   parent_objkey_            VARCHAR2(2000);

BEGIN
   IF (Client_SYS.Item_Exist('CODE_DEMAND',attr_)) THEN
      Error_SYS.Item_Insert(lu_name_, 'CODE_DEMAND');   
   END IF;
   IF (Client_SYS.Item_Exist('CODE_PART',attr_)) THEN
      Error_SYS.Item_Insert(lu_name_, 'CODE_PART');   
   END IF;
   IF (Client_SYS.Item_Exist('PERIOD_ALLOCATION', attr_)) THEN
      Error_SYS.Item_Insert(lu_name_, 'PERIOD_ALLOCATION');
   END IF;  
   
   IF ( newrec_.multi_company_voucher_type IS NOT NULL AND newrec_.company <> newrec_.multi_company_id AND newrec_.trans_code = 'MANUAL') THEN
      -- Only MC Manual D voucher will have multi_Company_Voucher_type fields not null. other MC vouchers will have empty columns for these Multi_Company_Voucher_type column.
      is_mc_voucher_finalized_ := Voucher_API.Is_Multi_Company_Vou_Finalized(newrec_.multi_company_id, newrec_.multi_company_acc_year, newrec_.multi_company_voucher_type, newrec_.multi_company_voucher_no);
      mc_vou_status_not_approved_ := NVL(Client_SYS.Get_Item_Value('MC_STATUS_NOT_APPROVED', attr_), 'FALSE');
      Create_Multi_Company_Voucher(head_, newrec_, is_mc_voucher_finalized_, mc_vou_status_not_approved_);
      IF (head_.rowstate = 'Confirmed') THEN
         Error_SYS.Record_General('VoucherRow', 'MCVOUROWNOTALLOWED: Voucher type :P1 in company :P2 is in :P3 status, it is not allowed to enter voucher rows to an automatically created voucher in :P3 status.', head_.voucher_type, head_.company, Voucher_Status_API.Decode(head_.rowstate));
      END IF;
      -- This is a Not Approved D voucher with the temporary voucher no, Therefore,
      -- No Project Accounting
      -- No Fa related Tx should get created
      -- They will get created only finalizing the voucher
      IF ( newrec_.voucher_no < 0 AND mc_vou_status_not_approved_ = 'TRUE' ) THEN
         Client_SYS.Add_To_Attr('CREATE_PROJ_CONN', 'FALSE', attr_);
         Client_SYS.Add_To_Attr('CREATE_FA_TX', 'FALSE', attr_);
      END IF;
      
   ELSE 
      -- Create Multi Company M voucher Rows
      IF (newrec_.multi_company_voucher_type IS NOT NULL) THEN
         newrec_.multi_company_row_no := Voucher_API.Get_Next_Mc_Current_Row_Number(newrec_.multi_company_id, newrec_.multi_company_acc_year, newrec_.multi_company_voucher_type, newrec_.multi_company_voucher_no );
      END IF;
      head_ := Voucher_API.Get( newrec_.company,
                                newrec_.accounting_year,
                                newrec_.voucher_type,
                                newrec_.voucher_no );
      
      IF (newrec_.multi_company_voucher_type IS NOT NULL AND newrec_.company = newrec_.multi_company_id ) THEN
         newrec_.accounting_period := head_.accounting_period;
      END IF;      
   END IF;   
   
   $IF Component_Proj_SYS.INSTALLED $THEN
      IF (newrec_.project_activity_id IS NOT NULL) AND (newrec_.project_activity_id = 0) THEN
         indrec_.project_activity_id := FALSE;
      END IF;
   $END

   super(newrec_, indrec_, attr_);
   
   interim_tax_ledger_accnt_ := NVL(Client_SYS.Cut_Item_Value('INTERIM_TAX_LEDGER_ACCNT', attr_), 'FALSE');
         
   IF (newrec_.currency_code IS NULL) THEN
      Error_SYS.Record_General('VoucherRow', 'CURCODENULL: Voucher row should have a currency code');
   END IF;

   IF (newrec_.debet_amount IS NULL AND newrec_.credit_amount IS NULL AND (newrec_.third_currency_debit_amount IS NOT NULL OR newrec_.third_currency_credit_amount IS NOT NULL)) THEN
      IF (newrec_.third_currency_debit_amount IS NOT NULL) THEN
         newrec_.debet_amount := 0;
      ELSIF (newrec_.third_currency_credit_amount IS NOT NULL) THEN
         newrec_.credit_amount := 0;
      END IF;
   END IF;

   newrec_.corrected := NVL( newrec_.corrected, 'N' );                               
   function_group_     := head_.function_group;
   simulation_voucher_ := head_.simulation_voucher;
   user_group_         := head_.user_group;
   amount_method_      := head_.amount_method;
   
   IF (newrec_.voucher_date IS NULL) THEN
      newrec_.voucher_date := head_.voucher_date;
   END IF;

   IF (head_.interim_voucher = 'Y' AND UPPER( newrec_.trans_code) != 'INTERIM') THEN
      Error_SYS.Record_General(lu_name_, 'NOINTERIM: The voucher is connected to an interim voucher and cannot be changed');
   END IF;
   IF (newrec_.accounting_period IS NULL) THEN
      newrec_.accounting_period := head_.accounting_period;
   END IF;
   Calculate_Net_From_Gross (newrec_, amount_method_);
   
   IF (function_group_ IN ('M', 'K', 'Q') AND newrec_.trans_code = 'MANUAL') OR (function_group_ = 'D' AND newrec_.trans_code = 'MANUAL' AND newrec_.multi_company_id IS NOT NULL) THEN
      IF (Company_Finance_API.Get_Parallel_Base_Db(newrec_.company) IN ('TRANSACTION_CURRENCY','ACCOUNTING_CURRENCY')) THEN
         IF ((NVL(newrec_.debet_amount,0) = 0) AND (NVL(newrec_.credit_amount,0) = 0) AND 
             (NVL(newrec_.third_currency_debit_amount,0) = 0) AND (NVL(newrec_.third_currency_credit_amount,0) = 0) AND
             (NVL(newrec_.currency_debet_amount,0) = 0) AND (NVL(newrec_.currency_credit_amount,0) = 0) AND 
             (NVL(newrec_.quantity,0) = 0)) THEN
               Error_SYS.Record_General(lu_name_,'NOAMOUNT: Amount or Quantity must have a value.');
         END IF;
      ELSE  
         IF ((NVL(newrec_.debet_amount,0) = 0) AND (NVL(newrec_.credit_amount,0) = 0) AND 
             (NVL(newrec_.currency_debet_amount,0) = 0) AND (NVL(newrec_.currency_credit_amount,0) = 0) AND 
             (NVL(newrec_.quantity,0) = 0)) THEN
               Error_SYS.Record_General(lu_name_,'NOAMOUNT: Amount or Quantity must have a value.');
         END IF;
      END IF;
   END IF;
   Error_SYS.Check_Not_Null(lu_name_, 'CURRENCY_RATE', newrec_.currency_rate);
   
   
   
   IF (Voucher_Type_API.Is_Row_Group_Validated(newrec_.company,newrec_.voucher_type)='Y') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'ROW_GROUP_ID', newrec_.row_group_id);
      IF Account_API.Is_Stat_Account (newrec_.company, newrec_.account) = 'TRUE' THEN
         Error_SYS.Record_General('VoucherRow', 'DBLENTRYVALSTATAC: Statistical account :P1 excluded from voucher balance is not allowed with row group validation.',newrec_.account);
      END IF;
   ELSE
      -- If this is a MC voucher then Row Group Id May be created by Create Due to Due from , so check that code
      IF (newrec_.multi_company_voucher_no IS NULL) THEN
         newrec_.row_group_id := NULL;
      END IF;
   END IF;
   IF ((Voucher_Type_API.Is_Reference_Mandatory(newrec_.company,newrec_.voucher_type)= 'Y') AND 
        Voucher_API.Get_Objstate(newrec_.company,newrec_.accounting_year,newrec_.voucher_type, newrec_.voucher_no ) = 'Confirmed' ) THEN
      IF ( newrec_.reference_serie IS NULL AND newrec_.reference_number IS NULL) THEN
         Error_SYS.Record_General('VoucherRow', 'REFSERNUMNOTNULL: Reference Series and Reference Number cannot be null when Reference Mandatory is checked for Voucher Type :P1', newrec_.voucher_type );
      END IF;
   END IF;
   Check_Acquisition___(newrec_,
                        function_group_,
                        NULL);           -- fa_code_part
   ledger_account_ := Account_API.Is_Ledger_Account (newrec_.company, newrec_.account);
   IF (interim_tax_ledger_accnt_ = 'FALSE') THEN
      IF ((ledger_account_) AND (function_group_ NOT IN ('R','Q')) AND (newrec_.trans_code NOT IN ('AP10', 'AP11'))) THEN
         Error_SYS.Record_General('VoucherRow', 'VOUISLEDGER: Ledger Account :P1 is not permitted for Manual Vouchers',newrec_.account);
      END IF;
   END IF;
   Check_Project___ (newrec_, function_group_ );
   Check_Codestring___ (newrec_, user_group_);
   IF (newrec_.optional_code IS NOT NULL) THEN
      IF (simulation_voucher_ = 'TRUE') THEN
         Error_SYS.Record_General('VoucherRow', 'SIMNOTAXCODE: It is not allowed to enter a Tax Code when using a Voucher Type defined as Simulation Voucher.');
      END IF;
   END IF;
   IF (simulation_voucher_ = 'FALSE') THEN
      IF (function_group_ IN ('M', 'Q')) THEN
         IF (newrec_.optional_code IS NULL) THEN
            Tax_Handling_Util_API.Validate_Tax_Code_Manda_On_Acc(newrec_.company, newrec_.account);            
         END IF;
      END IF;
   END IF;
   IF (function_group_ IN ('Q')) THEN
      newrec_.tax_base_amount := 0;
      newrec_.currency_tax_base_amount := 0;
   END IF;
   IF ( newrec_.optional_code IS NOT NULL AND function_group_ IN ('M', 'K','Q')) THEN
      Tax_Handling_Util_API.Validate_Tax_On_Trans(newrec_.company,
                                                  tax_types_event_,
                                                  newrec_.optional_code,
                                                  'TRUE',
                                                  newrec_.account,
                                                  newrec_.voucher_date);      
   END IF;
   Check_Overwriting_Level___ (newrec_, attr_);
   IF (newrec_.currency_type IS NOT NULL) THEN
      Currency_Type_API.Curr_Type_Exist_Parallel(newrec_.company, newrec_.currency_type);
   END IF;
   
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Insert___;


@Override
PROCEDURE Unpack___ (
   newrec_   IN OUT NOCOPY voucher_row_tab%ROWTYPE,
   indrec_   IN OUT NOCOPY Indicator_Rec,
   attr_     IN OUT NOCOPY VARCHAR2 )
IS
BEGIN
   --added pre-unpack
   IF (newrec_.accounting_year IS NOT NULL) THEN
      IF (Client_SYS.Item_Exist('ACCOUNTING_YEAR', attr_)) THEN
         newrec_.accounting_year := Client_SYS.Cut_Item_Value('ACCOUNTING_YEAR', attr_);
      END IF;   
   END IF;   
   super(newrec_, indrec_, attr_);
END Unpack___;

@Override
PROCEDURE Check_Update___ (
   oldrec_ IN     voucher_row_tab%ROWTYPE,
   newrec_ IN OUT voucher_row_tab%ROWTYPE,
   indrec_ IN OUT Indicator_Rec,
   attr_   IN OUT VARCHAR2 )
IS
   name_                VARCHAR2(30);
   value_               VARCHAR2(4000);
   genled_update_       VARCHAR2(20);
   ledger_account_      BOOLEAN;
   function_group_      VARCHAR2(20);
   simulation_voucher_  VARCHAR2(20);
   user_group_          user_group_member_finance_tab.user_group%type;
   amount_method_       VARCHAR2(200);
   head_                Voucher_Api.Public_Rec;
   req_rec_             Accounting_Codestr_API.CodestrRec;
   tax_types_event_     VARCHAR2(10) := 'RESTRICTED';
   
BEGIN
   IF (Client_SYS.Item_Exist('CODE_DEMAND',attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'CODE_DEMAND');  
   END IF;
   
   IF (oldrec_.multi_company_id IS NOT NULL AND ( Voucher_API.Is_Multi_Company_Vou_Finalized(oldrec_.company,
                                                   oldrec_.accounting_year,
                                                   oldrec_.voucher_type,
                                                   oldrec_.voucher_no) = 'TRUE')) THEN
      Error_SYS.Record_General(lu_name_, 'MCVOUFINALIZED: Can not modify a finalized multi company voucher.');                                                   
   END IF; 
   
   -- pre check_update
   IF (Client_SYS.Item_Exist('PERIOD_ALLOCATION', attr_)) THEN
      Error_SYS.Item_Update(lu_name_, 'PERIOD_ALLOCATION');
   END IF;   
   super(oldrec_, newrec_, indrec_, attr_);
   
   IF (newrec_.currency_code IS NULL) THEN
      Error_sys.Record_General('VoucherRow', 'CURCODENULL: Voucher row should have a currency code');
   END IF;
   req_rec_ := Account_API.Get_Required_Code_Parts(newrec_.company, newrec_.account);
   IF req_rec_.code_b = 'S' THEN
      newrec_.code_b := NULL;
      Client_SYS.Set_Item_Value( 'CODE_B','', attr_ );
   END IF;
   IF req_rec_.code_c = 'S' THEN
      newrec_.code_c := NULL;
      Client_SYS.Set_Item_Value( 'CODE_C','', attr_ );
   END IF;
   IF req_rec_.code_d = 'S' THEN
      newrec_.code_d := NULL;
      Client_SYS.Set_Item_Value( 'CODE_D','', attr_ );
   END IF;
   IF req_rec_.code_e = 'S' THEN
      newrec_.code_e := NULL;
      Client_SYS.Set_Item_Value( 'CODE_E','', attr_ );
   END IF;
   IF req_rec_.code_f = 'S' THEN
      newrec_.code_f := NULL;
      Client_SYS.Set_Item_Value( 'CODE_F','', attr_ );
   END IF;
   IF req_rec_.code_g = 'S' THEN
      newrec_.code_g := NULL;
      Client_SYS.Set_Item_Value( 'CODE_G','', attr_ );
   END IF;
   IF req_rec_.code_h = 'S' THEN
      newrec_.code_h := NULL;
      Client_SYS.Set_Item_Value( 'CODE_H','', attr_ );
   END IF;
   IF req_rec_.code_i = 'S' THEN
      newrec_.code_i := NULL;
      Client_SYS.Set_Item_Value( 'CODE_I','', attr_ );
   END IF;
   IF req_rec_.code_j = 'S' THEN
      newrec_.code_j := NULL;
      Client_SYS.Set_Item_Value( 'CODE_J','', attr_ );   
   END IF;
   
   newrec_.corrected := 'Y';
   head_ := Voucher_API.Get( newrec_.company,
                             newrec_.accounting_year,
                             newrec_.voucher_type,
                             newrec_.voucher_no );
   function_group_     := head_.function_group;
   simulation_voucher_ := head_.simulation_voucher;
   user_group_         := head_.user_group;
   amount_method_      := head_.amount_method;
   IF (newrec_.voucher_date IS NULL) THEN
      newrec_.voucher_date := head_.voucher_date;
   END IF;
   IF (newrec_.voucher_date IS NULL) OR (newrec_.voucher_date != head_.voucher_date) THEN
      newrec_.voucher_date := head_.voucher_date;
   END IF;

   IF (head_.interim_voucher = 'Y') THEN
      Error_SYS.Record_General(lu_name_, 'NOINTERIM: The voucher is connected to an interim voucher and cannot be changed');
   END IF;

   Calculate_Net_From_Gross (newrec_, amount_method_);

   IF (function_group_ IN ('M', 'K', 'Q') AND newrec_.trans_code = 'MANUAL') THEN
      IF (Company_Finance_API.Get_Parallel_Base_Db(newrec_.company) IN ('TRANSACTION_CURRENCY','ACCOUNTING_CURRENCY')) THEN
         IF ((NVL(newrec_.debet_amount,0) = 0) AND (NVL(newrec_.credit_amount,0) = 0) AND
             (NVL(newrec_.third_currency_debit_amount,0) = 0) AND (NVL(newrec_.third_currency_credit_amount,0) = 0) AND
             (NVL(newrec_.currency_debet_amount,0) = 0) AND (NVL(newrec_.currency_credit_amount,0) = 0) AND 
             (NVL(newrec_.quantity,0) = 0)) THEN
               Error_SYS.Record_General(lu_name_,'NOAMOUNT: Amount or Quantity must have a value.');
         END IF;
      ELSE  
         IF ((NVL(newrec_.debet_amount,0) = 0) AND (NVL(newrec_.credit_amount,0) = 0) AND 
             (NVL(newrec_.currency_debet_amount,0) = 0) AND (NVL(newrec_.currency_credit_amount,0) = 0) AND 
             (NVL(newrec_.quantity,0) = 0)) THEN
            Error_SYS.Record_General(lu_name_,'NOAMOUNT: Amount or Quantity must have a value.');
         END IF; 
     END IF;
   END IF;
   Error_SYS.Check_Not_Null(lu_name_, 'CURRENCY_RATE', newrec_.currency_rate);
   IF (Voucher_Type_API.Is_Row_Group_Validated(newrec_.company,newrec_.voucher_type)='Y') THEN
      Error_SYS.Check_Not_Null(lu_name_, 'ROW_GROUP_ID', newrec_.row_group_id);
      IF Account_API.Is_Stat_Account (newrec_.company, newrec_.account) = 'TRUE' THEN
         Error_SYS.Record_General('VoucherRow', 'DBLENTRYVALSTATAC: Statistical account :P1 excluded from voucher balance is not allowed with row group validation.',newrec_.account);
      END IF;
   ELSE
      IF ( newrec_.multi_company_voucher_no IS NULL ) THEN
        newrec_.row_group_id := NULL;
      END IF;         
      IF (newrec_.row_group_id IS NULL AND newrec_.multi_company_id IS NOT NULL AND Voucher_API.Get_Manual_Balance_Db(newrec_.multi_company_id, newrec_.multi_company_acc_year, newrec_.multi_company_voucher_type, newrec_.multi_company_voucher_no) = 'FALSE') THEN
         Error_SYS.Record_General('VoucherRow', 'ROWGROUPIDMISSING: Row Group Id must have a value.');      
      END IF;
   END IF;
  
   genled_update_ := NVL(Client_SYS.Get_Item_Value('GENLED_UPDATE', attr_), 'FALSE');
   IF (genled_update_ != 'TRUE') THEN
      Check_Period_Allocation___(newrec_);
   END IF;
   
   ledger_account_ := Account_API.Is_Ledger_Account (newrec_.company, newrec_.account);
   IF ((ledger_account_) AND (function_group_ != 'Q') AND (newrec_.trans_code NOT IN ('AP10', 'AP11'))) THEN
      Error_SYS.Record_General('VoucherRow', 'VOUISLEDGER: Ledger Account :P1 is not permitted for Manual Vouchers',newrec_.account);
   END IF;
   IF (head_.rowstate = 'Confirmed' AND (Voucher_Type_API.Is_Reference_Mandatory(newrec_.company,newrec_.voucher_type)='Y')) THEN
      IF (newrec_.reference_serie IS NULL AND newrec_.reference_number IS NULL) THEN
         Error_SYS.Record_General('VoucherRow', 'REFSERNUMNOTNULL: Reference Series and Reference Number cannot be null when Reference Mandatory is checked for Voucher Type :P1', newrec_.voucher_type );
      END IF;
   END IF;
   Check_Acquisition___(newrec_,
                        function_group_,
                        NULL);           -- fa_code_part
   Check_Codestring___ (newrec_, user_group_);
   Check_Project___ (newrec_, function_group_ );
   IF (newrec_.optional_code IS NOT NULL) THEN
      IF (simulation_voucher_ = 'TRUE') THEN
         Error_SYS.Record_General('VoucherRow', 'SIMNOTAXCODE: It is not allowed to enter a Tax Code when using a Voucher Type defined as Simulation Voucher.');
      END IF;
   END IF;
   IF (simulation_voucher_ = 'FALSE') THEN
      IF (function_group_ IN ('M', 'Q')) THEN
         IF (newrec_.optional_code IS NULL) THEN
            Tax_Handling_Util_API.Validate_Tax_Code_Manda_On_Acc(newrec_.company, newrec_.account);   
         END IF;
      END IF;
   END IF;
   IF (function_group_ IN ('Q')) THEN
      newrec_.tax_base_amount := 0;
      newrec_.currency_tax_base_amount := 0;
   END IF;
   
   IF (newrec_.optional_code IS NOT NULL) THEN
      Tax_Handling_Util_API.Validate_Tax_On_Trans(newrec_.company,
                                                  tax_types_event_,
                                                  newrec_.optional_code,
                                                  'TRUE',
                                                  newrec_.account,
                                                  newrec_.voucher_date);
   END IF;
   
   Check_Overwriting_Level___ (newrec_, attr_);
   IF (oldrec_.account != newrec_.account) THEN
      Delete_Internal_Rows___ (newrec_.company,
                               newrec_.voucher_type,
                               newrec_.accounting_year,
                               newrec_.voucher_no,
                               oldrec_.account,
                               newrec_.row_no);
   END IF;
   IF ((indrec_.currency_type) AND (newrec_.currency_type IS NOT NULL)) THEN
      Currency_Type_API.Curr_Type_Exist_Parallel(newrec_.company, newrec_.currency_type);
   END IF;
EXCEPTION
   WHEN value_error THEN
      Error_SYS.Item_Format(lu_name_, name_, value_);
END Check_Update___;

-- Note: This method checks the validity of voucher row amounts before saving.
PROCEDURE Check_Vou_Row_Amounts___(
   rec_           IN OUT Voucher_Row_Tab%ROWTYPE,
   company_rec_   IN     Company_Finance_API.Public_Rec)
IS   
BEGIN   
   Validate_Vou_Row_Amounts___(rec_, company_rec_);
   Validate_Reverse_Vou_Row___(rec_, company_rec_);
END Check_Vou_Row_Amounts___;

-- Note: Check the validity of amounts in voucher row.
PROCEDURE Validate_Vou_Row_Amounts___(
   rec_          IN Voucher_Row_Tab%ROWTYPE,
   company_rec_  IN Company_Finance_API.Public_Rec)
IS   
BEGIN
   IF rec_.currency_credit_amount IS NULL AND 
      rec_.currency_debet_amount IS NULL AND 
      rec_.credit_amount IS NULL AND
      rec_.debet_amount IS NULL AND
      rec_.third_currency_credit_amount IS NULL AND
      rec_.third_currency_debit_amount IS NULL AND
      rec_.quantity IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'VOUROWAMTERRALLNULL: Amount or quantity must have a value.');            
   ELSIF rec_.currency_credit_amount IS NOT NULL AND rec_.credit_amount IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'VOUROWCREDITAMTERR: Credit amount must have a value when currency credit amount is entered.');      
   ELSIF rec_.currency_debet_amount IS NOT NULL AND rec_.debet_amount IS NULL THEN
      Error_SYS.Record_General(lu_name_, 'VOUROWDEBDITAMTERR: Debit amount must have a value when currency debit amount is entered.');      
   ELSE      
      IF company_rec_.parallel_acc_currency IS NOT NULL THEN
         IF rec_.currency_credit_amount IS NOT NULL AND rec_.third_currency_credit_amount IS NULL THEN
            Error_SYS.Record_General(lu_name_, 'VOUROWTHIRDCREDITAMTERR: Parallel currency credit amount must have a value.');      
         ELSIF rec_.currency_debet_amount IS NOT NULL AND rec_.third_currency_debit_amount IS NULL THEN
            Error_SYS.Record_General(lu_name_, 'VOUROWTHIRDDEBITAMTERR: Parallel currency debit amount must have a value.');      
         END IF;
      END IF;
   END IF;
   
END Validate_Vou_Row_Amounts___;

-- Note: Check the validity of the reversal or correction voucher rows.   
PROCEDURE Validate_Reverse_Vou_Row___(
   rec_           IN OUT Voucher_Row_Tab%ROWTYPE,
   company_rec_   IN     Company_Finance_API.Public_Rec)
IS
   function_group_            Voucher_Tab.function_group%TYPE;
   check_correction_exist_    BOOLEAN := FALSE;
   repost_method_payled_      VARCHAR2(20);
BEGIN
   function_group_   := Voucher_API.Get_Function_Group(rec_.company, rec_.accounting_year, rec_.voucher_type, rec_.voucher_no);
   
   IF function_group_ = 'B' THEN
      $IF (Component_Payled_SYS.INSTALLED) $THEN
         repost_method_payled_ := Company_Pay_Info_API.Get_Reposting_Method_Type_Db( rec_.company ); 
      $ELSE
         repost_method_payled_ := NULL;
      $END
   END IF;
   
   CASE
      -- Check is not required for Manual vouchers.
      WHEN function_group_ IN ('M', 'K', 'Q', 'R', 'D') THEN
         check_correction_exist_ := FALSE;
      -- Currency Revaluation, Parallel Currency Revaluation , Revenue Recognition, Interim Posting of Outstanding Sales.
      WHEN function_group_ IN ('H', 'LI', 'P') AND NVL(company_rec_.reverse_vou_corr_type, ' ') = 'REVERSE' AND NVL(company_rec_.correction_type, ' ') = 'REVERSE' THEN
         check_correction_exist_ := TRUE;
      WHEN function_group_ IN ('H', 'LI', 'P') THEN
         check_correction_exist_ := FALSE;
      -- PCA Voucher
      WHEN function_group_ = 'Z' THEN
         check_correction_exist_ := FALSE;
      -- Skip check for Repost and bad debt transfer.
      $IF (Component_Payled_SYS.INSTALLED) $THEN
      WHEN function_group_ = 'B' AND NVL(repost_method_payled_, ' ') = 'CORRECTION' THEN
         check_correction_exist_ := FALSE;
      $END
      WHEN NVL(company_rec_.correction_type, ' ') = 'REVERSE' THEN
         check_correction_exist_ := TRUE;
      ELSE
         check_correction_exist_ := FALSE;
   END CASE;
   
   IF check_correction_exist_ THEN
      Validate_Correction_Row___(rec_, function_group_);
   END IF;  
END Validate_Reverse_Vou_Row___;

-- Note: Creation of correction type voucher rows is not allowed when company parameter is Reverse.
PROCEDURE Validate_Correction_Row___(
   rec_              IN Voucher_Row_Tab%ROWTYPE,
   function_group_   IN VARCHAR2)
IS
BEGIN    
   IF Get_Correction_All__(rec_.company, 
                           rec_.voucher_type, 
                           rec_.accounting_year, 
                           rec_.voucher_no,
                           rec_.reference_row_no, 
                           NVL(rec_.debet_amount,rec_.credit_amount), 
                           rec_.auto_tax_vou_entry,
                           NVL(rec_.third_currency_debit_amount,rec_.third_currency_credit_amount)) = 'Y' THEN
      
      CASE function_group_
         WHEN 'B' THEN
            Error_SYS.Record_General(lu_name_, 'VOUROWCORRNOTALLOWEDPAY: Cancel/Rollback Posting or Reposting Method is set to Reverse in Company :P1. Therefore, it is not allowed to create a voucher with correction row(s).', rec_.company); 
         ELSE         
            Error_SYS.Record_General(lu_name_, 'VOUROWCORRNOTALLOWED: Cancel/Rollback Posting method is set to Reverse in Company :P1. Therefore, it is not allowed to create a voucher with correction row(s).', rec_.company); 
      END CASE;
   END IF;
END Validate_Correction_Row___;

PROCEDURE Check_Voucher_No_Ref___ (
   newrec_ IN OUT NOCOPY voucher_row_tab%ROWTYPE )
IS
BEGIN   
   Voucher_API.Exist(newrec_.company, newrec_.accounting_year, newrec_.voucher_type, newrec_.voucher_no);

END Check_Voucher_No_Ref___;



PROCEDURE Check_Lease_Recog_Vou___(
   found_                        OUT BOOLEAN,
   company_                   IN     VARCHAR2,
   accounting_year_           IN     NUMBER,
   voucher_type_              IN     VARCHAR2, 
   voucher_no_                IN     NUMBER,
   lease_contract_connected_  IN     VARCHAR2)
IS      
   lease_recognition_vou_     BOOLEAN := FALSE;
BEGIN
   found_ := TRUE;
   IF (lease_contract_connected_ = 'TRUE') THEN
      $IF Component_Fixass_SYS.INSTALLED $THEN
         lease_recognition_vou_ := Lease_Voucher_Information_API.Is_Lease_Recognition_Voucher__(company_, accounting_year_, voucher_type_, voucher_no_);
      $END
      IF (lease_recognition_vou_) THEN
         found_ := FALSE;
      END IF;
   END IF;
END Check_Lease_Recog_Vou___;

-- gelr:tax_book_and_numbering, begin
-- Throws error if type of tax_code_ (TAX, NOTAX) differs from type of (others then row_no_) rows in the same voucher
PROCEDURE Validate_Tax_Type___ (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER ) 
IS   
   tax_type_count_     NUMBER;
   
   CURSOR get_tax_type_count IS
      SELECT COUNT(DISTINCT CASE (s.fee_type) WHEN 'NOTAX' THEN 'NOTAX' ELSE 'TAX' END)                            
      FROM   voucher_row_tab v, statutory_fee_tab s
      WHERE  v.company         = s.company
      AND    v.optional_code   = s.fee_code
      AND    v.company         = company_
      AND    v.voucher_type    = voucher_type_
      AND    v.accounting_year = accounting_year_
      AND    v.voucher_no      = voucher_no_      
      AND    v.optional_code IS NOT NULL;   
BEGIN   
   OPEN  get_tax_type_count;
   FETCH get_tax_type_count INTO tax_type_count_;
   CLOSE get_tax_type_count;

   IF (tax_type_count_ = 2) THEN -- Two tax types: "No tax" mixed with other tax types on the same voucher      
      Error_SYS.Appl_General(lu_name_, 'NOTAXMIXEDWITHOTHERTAXTYPES: Tax type "No Tax" cannot be used together with other tax types.');
   END IF;
END Validate_Tax_Type___;
-- gelr:tax_book_and_numbering, end

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

PROCEDURE Create_Due_To_From_Vou_Rows__(
   new_row_          IN OUT Voucher_Row_Tab%ROWTYPE,
   source_row_rec_   IN     Voucher_Row_Tab%ROWTYPE,
   codestring_rec_   IN     Accounting_Codestr_API.CodestrRec )
IS
BEGIN
   -- new_row_ is already assigned with Debet/Credit amount, Currency_Debet/Credit amounts and parallel amounts.   
   new_row_.row_group_id                  := source_row_rec_.row_group_id;
   new_row_.account                       := codestring_rec_.code_a;
   new_row_.code_b                        := codestring_rec_.code_b;
   new_row_.code_c                        := codestring_rec_.code_c;
   new_row_.code_d                        := codestring_rec_.code_d;
   new_row_.code_e                        := codestring_rec_.code_e;
   new_row_.code_f                        := codestring_rec_.code_f;
   new_row_.code_g                        := codestring_rec_.code_g;
   new_row_.code_h                        := codestring_rec_.code_h;
   new_row_.code_i                        := codestring_rec_.code_i;
   new_row_.code_j                        := codestring_rec_.code_j;               
   new_row_.company                       := source_row_rec_.company;                                      
   new_row_.accounting_year               := source_row_rec_.accounting_year;
   new_row_.voucher_type                  := source_row_rec_.voucher_type;
   new_row_.voucher_no                    := source_row_rec_.voucher_no;
   new_row_.multi_company_id              := source_row_rec_.multi_company_id;
   new_row_.multi_company_acc_year        := source_row_rec_.multi_company_acc_year;
   new_row_.multi_company_voucher_type    := source_row_rec_.multi_company_voucher_type;
   new_row_.multi_company_voucher_no      := source_row_rec_.multi_company_voucher_no;
   new_row_.currency_code                 := source_row_rec_.currency_code;      
   new_row_.accounting_period             := source_row_rec_.accounting_period;  
   new_row_.currency_rate                 := source_row_rec_.currency_rate;  
   new_row_.conversion_factor             := source_row_rec_.conversion_factor;  
   new_row_.year_period_key               := source_row_rec_.year_period_key;  
   new_row_.voucher_date                  := source_row_rec_.voucher_date;  
   new_row_.currency_type                 := source_row_rec_.currency_type;  
   new_row_.parallel_curr_rate_type       := source_row_rec_.parallel_curr_rate_type;  
   new_row_.parallel_currency_rate        := source_row_rec_.parallel_currency_rate;  
   new_row_.parallel_conversion_factor    := source_row_rec_.parallel_conversion_factor;
   new_row_.currency_rate_type            := source_row_rec_.currency_rate_type;
   new_row_.transfer_id                   := source_row_rec_.transfer_id;
   new_row_.row_group_id                  := source_row_rec_.row_group_id;
   new_row_.reference_serie               := source_row_rec_.reference_serie;
   new_row_.reference_number              := source_row_rec_.reference_number;          
   new_row_.text                          := source_row_rec_.text;
   Voucher_Row_API.Create_New_Row__(new_row_);
   Voucher_Row_API.Internal_Manual_Postings(new_row_, TRUE);

END Create_Due_To_From_Vou_Rows__;

@Override
PROCEDURE New__ (
   info_       OUT    VARCHAR2,
   objid_      OUT    VARCHAR2,
   objversion_ OUT    VARCHAR2,
   attr_       IN OUT VARCHAR2,
   action_     IN     VARCHAR2 )
IS
   newrec_                    VOUCHER_ROW_TAB%ROWTYPE;
   tax_base_amount_           NUMBER;
   curr_tax_base_amount_      NUMBER;
   para_curr_tax_base_amount_ NUMBER;
   tax_percentage_            NUMBER;
   trans_code_                VOUCHER_ROW_TAB.trans_code%TYPE;
BEGIN
   IF (action_ = 'DO') THEN
      trans_code_ := Client_Sys.Get_Item_Value('TRANS_CODE', attr_);
      IF (NVL(trans_code_, ' ') != 'INTERIM') THEN
         -- Client will send the tax base amount. But it is storing only for the tax postings.
         -- Therefore tax base amounts will cut from the attr and it will pass later for tax transactions.
         -- But for interim voucher rows it should transfer to the interim lines.
         tax_base_amount_ := Client_SYS.Cut_Item_Value('TAX_BASE_AMOUNT', attr_);
         curr_tax_base_amount_ := Client_SYS.Cut_Item_Value('CURRENCY_TAX_BASE_AMOUNT', attr_);
         para_curr_tax_base_amount_ := Client_SYS.Cut_Item_Value('PARALLEL_CURR_TAX_BASE_AMOUNT', attr_);
         Client_SYS.Add_To_Attr('TAX_BASE_AMOUNT_TMP', TO_CHAR(tax_base_amount_), attr_);
      END IF;
   END IF;
   
   super(info_, objid_, objversion_, attr_, action_);
   IF (action_ = 'DO') THEN
      
      newrec_ := Get_Object_By_Id___(objid_);     
      Internal_Manual_Postings___(newrec_, TRUE);
      
      IF (tax_base_amount_ IS NOT NULL) THEN
         newrec_.tax_base_amount := tax_base_amount_;
      END IF;
      IF (curr_tax_base_amount_ IS NOT NULL) THEN
         newrec_.currency_tax_base_amount := curr_tax_base_amount_;
      END IF;
      IF (para_curr_tax_base_amount_ IS NOT NULL) THEN
         newrec_.parallel_curr_tax_base_amount := para_curr_tax_base_amount_;
      END IF;
      IF (Client_SYS.Item_Exist('TAX_PERCENTAGE', attr_)) THEN
         tax_percentage_ := Client_SYS.Get_Item_Value('TAX_PERCENTAGE', attr_);
      END IF;
      Prepare_Tax_Transaction___(newrec_, tax_percentage_);
      
      $IF Component_Fixass_SYS.INSTALLED $THEN
         IF (NVL(Client_SYS.Get_Item_Value('CREATE_FA_TX', attr_),'TRUE')= 'TRUE') THEN 
            Create_Add_Investment_Info___(newrec_);
         END IF;
      $END      
   END IF;
END New__;

PROCEDURE Modify_Row__ (
   newrec_         IN OUT NOCOPY voucher_row_tab%ROWTYPE)
IS
BEGIN
   Modify___ (newrec_);
END Modify_Row__;
   
@UncheckedAccess
FUNCTION Calculate_Rate__ (
   company_            IN VARCHAR2,
   base_currency_code_ IN VARCHAR2,
   amount_             IN NUMBER,
   currency_amount_    IN NUMBER,
   conv_factor_        IN NUMBER,
   currency_code_      IN VARCHAR2 ) RETURN NUMBER
IS
BEGIN
   IF (nvl(currency_amount_, 0) = 0) OR (nvl(amount_, 0) = 0) THEN
      RETURN(0);
   END IF;
   IF (Currency_Code_API.Get_Inverted(company_, base_currency_code_) = 'TRUE') THEN
       RETURN(abs(round((currency_amount_/amount_) * conv_factor_, nvl(Currency_Code_API.Get_No_Of_Decimals_In_Rate(company_,currency_code_ ),0))));
   ELSE
       RETURN(abs(round((amount_/currency_amount_) * conv_factor_, nvl(Currency_Code_API.Get_No_Of_Decimals_In_Rate(company_,currency_code_ ),0))));
   END IF;
END Calculate_Rate__;


PROCEDURE Validate_Process_Code__ (
   company_           IN VARCHAR2,
   process_code_      IN VARCHAR2,
   voucher_date_      IN DATE )
IS
   result_               VARCHAR2(5);
BEGIN
   Account_Process_Code_API.Exist(company_, process_code_);
   Account_Process_Code_API.Validate_Process_Code(result_,
                                                  company_,
                                                  process_code_,
                                                  voucher_date_);
END Validate_Process_Code__;


PROCEDURE Reverse_Voucher_Rows__(
   company_               IN VARCHAR2,
   voucher_no_            IN NUMBER,
   accounting_year_       IN NUMBER,
   voucher_type_          IN VARCHAR2,
   reversal_voucher_no_   IN NUMBER,
   reversal_acc_year_     IN NUMBER,
   reversal_voucher_type_ IN VARCHAR2,
   rollback_voucher_      IN VARCHAR2 DEFAULT NULL )
IS
   CURSOR get_voucher_row IS
      SELECT   *
      FROM     voucher_row_tab
      WHERE    company         = company_
      AND      voucher_type    = voucher_type_
      AND      voucher_no      = voucher_no_
      AND      accounting_year = accounting_year_
      ORDER BY row_no;
   comp_fin_rec_                 Company_Finance_API.Public_Rec;
   head_                         Voucher_API.Public_Rec;
   reversal_rec_                 VOUCHER_ROW_TAB%ROWTYPE;
   emp_reversal_rec_             VOUCHER_ROW_TAB%ROWTYPE;
   voucher_date_                 DATE; 
   is_base_emu_                  VARCHAR2(5);
   is_third_emu_                 VARCHAR2(5);
   attr_                         VARCHAR2(32000);
   objid_                        VARCHAR2(2000);
   objversion_                   VARCHAR2(2000);
   function_group_               VARCHAR2(20);
   simulation_voucher_           VARCHAR2(20);
   user_group_                   VARCHAR2(30);
   amount_method_                VARCHAR2(200);
   third_currency_debit_amount_  NUMBER;
   third_currency_credit_amount_ NUMBER;
   correction_type_              company_finance_tab.correction_type%TYPE;

BEGIN
   voucher_date_        := Voucher_API.Get_Voucher_Date(company_,
                                                        reversal_acc_year_,
                                                        reversal_voucher_type_,
                                                        reversal_voucher_no_);
   comp_fin_rec_        := Company_Finance_API.Get(company_);  
   is_base_emu_         := Currency_Code_API.Get_Valid_Emu (company_,
                                                            comp_fin_rec_.currency_code,
                                                            voucher_date_);
   IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
      is_third_emu_     := Currency_Code_API.Get_Valid_Emu (company_,
                                                            comp_fin_rec_.parallel_acc_currency,
                                                            voucher_date_);
   ELSE
      is_third_emu_     := 'FALSE';
   END IF; 
   --rollback_voucher_ = 'TRUE' if method is called to cancel the voucher ( CORRECTION_TYPE )
   --else it is called to create the reversal voucher ( REVERSAL_VOU_CORR_TYPE )
   IF ( rollback_voucher_ IS NOT NULL AND rollback_voucher_ = 'TRUE' ) THEN -- Cancellation voucher
      correction_type_ := comp_fin_rec_.correction_type;
   ELSE  -- Reversal voucher
      correction_type_ := comp_fin_rec_.reverse_vou_corr_type;
   END IF;
   FOR get_voucher_row_ IN get_voucher_row LOOP
      Client_SYS.Clear_Attr(attr_);
      reversal_rec_                     := emp_reversal_rec_;
      reversal_rec_.company             := company_;
      reversal_rec_.voucher_type        := reversal_voucher_type_; 
      reversal_rec_.accounting_year     := reversal_acc_year_;
      reversal_rec_.voucher_no          := reversal_voucher_no_; 
      reversal_rec_.voucher_date        := voucher_date_;
      reversal_rec_.row_no              := get_voucher_row_.row_no; 
      reversal_rec_.account             := get_voucher_row_.account; 
      reversal_rec_.code_b              := get_voucher_row_.code_b; 
      reversal_rec_.code_c              := get_voucher_row_.code_c; 
      reversal_rec_.code_d              := get_voucher_row_.code_d; 
      reversal_rec_.code_e              := get_voucher_row_.code_e; 
      reversal_rec_.code_f              := get_voucher_row_.code_f; 
      reversal_rec_.code_g              := get_voucher_row_.code_g; 
      reversal_rec_.code_h              := get_voucher_row_.code_h; 
      reversal_rec_.code_i              := get_voucher_row_.code_i; 
      reversal_rec_.code_j              := get_voucher_row_.code_j; 
      reversal_rec_.internal_seq_number := get_voucher_row_.internal_seq_number; 
      IF (correction_type_ = 'REVERSE') THEN
         reversal_rec_.currency_debet_amount        := get_voucher_row_.currency_credit_amount;
         reversal_rec_.currency_credit_amount       := get_voucher_row_.currency_debet_amount;
         reversal_rec_.debet_amount                 := get_voucher_row_.credit_amount;
         reversal_rec_.credit_amount                := get_voucher_row_.debet_amount;
         reversal_rec_.third_currency_debit_amount  := get_voucher_row_.third_currency_credit_amount;
         reversal_rec_.third_currency_credit_amount := get_voucher_row_.third_currency_debit_amount;
      ELSE
         reversal_rec_.currency_debet_amount        := - get_voucher_row_.currency_debet_amount;
         reversal_rec_.currency_credit_amount       := - get_voucher_row_.currency_credit_amount;
         reversal_rec_.debet_amount                 := - get_voucher_row_.debet_amount;
         reversal_rec_.credit_amount                := - get_voucher_row_.credit_amount;
         reversal_rec_.third_currency_debit_amount  := - get_voucher_row_.third_currency_debit_amount;
         reversal_rec_.third_currency_credit_amount := - get_voucher_row_.third_currency_credit_amount;
      END IF;
      reversal_rec_.tax_base_amount           := - get_voucher_row_.tax_base_amount;
      reversal_rec_.currency_tax_base_amount  := - get_voucher_row_.currency_tax_base_amount;
      reversal_rec_.tax_direction             := Tax_Direction_API.Decode(get_voucher_row_.tax_direction);
      reversal_rec_.currency_code             := get_voucher_row_.currency_code;
      reversal_rec_.quantity                  := - get_voucher_row_.quantity;
      reversal_rec_.process_code              := get_voucher_row_.process_code;
      reversal_rec_.optional_code             := get_voucher_row_.optional_code;
      reversal_rec_.project_activity_id       := get_voucher_row_.project_activity_id;
      reversal_rec_.text                      := get_voucher_row_.text;
      reversal_rec_.party_type_id             := get_voucher_row_.party_type_id;
      reversal_rec_.reference_serie           := get_voucher_row_.reference_serie;
      reversal_rec_.reference_number          := get_voucher_row_.reference_number;
      reversal_rec_.reference_version         := get_voucher_row_.reference_version;
      reversal_rec_.party_type                := get_voucher_row_.party_type;
      reversal_rec_.transfer_id               := get_voucher_row_.transfer_id;
      reversal_rec_.currency_rate             := get_voucher_row_.currency_rate;
      reversal_rec_.conversion_factor         := get_voucher_row_.conversion_factor;
      reversal_rec_.activate_code             := get_voucher_row_.activate_code;
      reversal_rec_.mpccom_accounting_id      := get_voucher_row_.mpccom_accounting_id;
      reversal_rec_.parallel_currency_rate       := get_voucher_row_.parallel_currency_rate;
      reversal_rec_.parallel_conversion_factor   := get_voucher_row_.parallel_conversion_factor;
      reversal_rec_.parallel_curr_tax_amount     := - get_voucher_row_.parallel_curr_tax_amount;
      reversal_rec_.parallel_curr_gross_amount   := - get_voucher_row_.parallel_curr_gross_amount;
      reversal_rec_.parallel_curr_tax_base_amount:= - get_voucher_row_.parallel_curr_tax_base_amount;
      reversal_rec_.parallel_curr_rate_type      := get_voucher_row_.parallel_curr_rate_type;
      reversal_rec_.matching_info                := get_voucher_row_.matching_info;
      reversal_rec_.tax_clearance_connection     := get_voucher_row_.tax_clearance_connection;               
      
      IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF ((get_voucher_row_.debet_amount IS NOT NULL) AND
             (get_voucher_row_.third_currency_debit_amount IS NULL)) THEN
            third_currency_debit_amount_ := Currency_Amount_API.Calculate_Parallel_Curr_Amount(company_,
                                                             voucher_date_,
                                                             get_voucher_row_.debet_amount,
                                                             get_voucher_row_.currency_debet_amount,
                                                             comp_fin_rec_.currency_code, 
                                                             get_voucher_row_.currency_code, 
                                                             get_voucher_row_.parallel_curr_rate_type, 
                                                             comp_fin_rec_.parallel_acc_currency,
                                                             comp_fin_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
            third_currency_debit_amount_              := NVL(-third_currency_debit_amount_,0);
            reversal_rec_.third_currency_debit_amount := third_currency_debit_amount_;
         END IF;
         IF ((get_voucher_row_.credit_amount IS NOT NULL) AND
             (get_voucher_row_.third_currency_credit_amount IS NULL)) THEN
            third_currency_credit_amount_ := Currency_Amount_API.Calculate_Parallel_Curr_Amount(company_,
                                                             voucher_date_,
                                                             get_voucher_row_.credit_amount,
                                                             get_voucher_row_.currency_credit_amount,
                                                             comp_fin_rec_.currency_code, 
                                                             get_voucher_row_.currency_code, 
                                                             get_voucher_row_.parallel_curr_rate_type, 
                                                             comp_fin_rec_.parallel_acc_currency,
                                                             comp_fin_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
            third_currency_credit_amount_ := NVL(-third_currency_credit_amount_,0);
            reversal_rec_.third_currency_credit_amount := third_currency_credit_amount_;
         END IF; 
      END IF;
      Voucher_API.Exist (reversal_rec_.company,
                         reversal_rec_.voucher_type,
                         reversal_rec_.accounting_year,
                         reversal_rec_.voucher_no);
      IF (reversal_rec_.currency_code IS NOT NULL) THEN
         Currency_Code_API.Exist(reversal_rec_.company, reversal_rec_.currency_code);
      ELSE
         Error_SYS.Record_General('VoucherRow', 'CURCODENULL: Voucher row should have a currency code');
      END IF;
      IF (reversal_rec_.process_code IS NOT NULL) THEN
         Account_Process_Code_API.Exist(reversal_rec_.company, reversal_rec_.process_code);
      END IF;
      IF (reversal_rec_.optional_code IS NOT NULL) THEN
         Statutory_Fee_API.Exist(reversal_rec_.company, reversal_rec_.optional_code);
      END IF;
      IF (reversal_rec_.corrected IS NOT NULL) THEN
         Finance_Yes_No_API.Exist_Db(reversal_rec_.corrected);
      END IF;
      IF (reversal_rec_.tax_direction IS NOT NULL) THEN
         Tax_Direction_API.Exist_Db(reversal_rec_.tax_direction);
      END IF;
      reversal_rec_.corrected := NVL( reversal_rec_.corrected, 'N' );
      head_ := Voucher_API.Get( reversal_rec_.company,
                                reversal_rec_.accounting_year,
                                reversal_rec_.voucher_type,
                                reversal_rec_.voucher_no );
      function_group_     := head_.function_group;
      simulation_voucher_ := head_.simulation_voucher;
      user_group_         := head_.user_group;
      amount_method_      := head_.amount_method;
      reversal_rec_.accounting_period   := head_.accounting_period;  
      IF (rollback_voucher_ IS NULL) THEN
         reversal_rec_.trans_code          := 'REVERSAL-'||get_voucher_row_.trans_code;
      ELSIF (rollback_voucher_ = 'TRUE') THEN
         reversal_rec_.trans_code          := get_voucher_row_.trans_code;
      END IF;
      Calculate_Net_From_Gross (reversal_rec_, amount_method_);
      Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', reversal_rec_.company);
      Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_TYPE', reversal_rec_.voucher_type);
      Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_YEAR', reversal_rec_.accounting_year);
      Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_NO', reversal_rec_.voucher_no);
      Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', reversal_rec_.account);
      Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_PERIOD', reversal_rec_.accounting_period);
      Check_Acquisition___(reversal_rec_,
                           function_group_,
                           NULL);
      IF (function_group_ != 'P') THEN
         Check_Project___ (reversal_rec_, function_group_);
      END IF;
      Check_Codestring___ (reversal_rec_, user_group_);
      IF (reversal_rec_.optional_code IS NOT NULL) THEN
         IF (simulation_voucher_ = 'TRUE') THEN
            Error_SYS.Record_General('VoucherRow', 'SIMNOTAXCODE: It is not allowed to enter a Tax Code when using a Voucher Type defined as Simulation Voucher.');
         END IF;
      END IF;
      IF (simulation_voucher_ = 'FALSE') THEN
         IF (function_group_ IN ('M', 'Q')) THEN
            IF (reversal_rec_.optional_code IS NULL) THEN
               Tax_Handling_Util_API.Validate_Tax_Code_Manda_On_Acc(reversal_rec_.company, reversal_rec_.account);               
            END IF;
         END IF;
      END IF;
      IF (function_group_ IN ('Q')) THEN
         reversal_rec_.tax_base_amount := 0;
         reversal_rec_.currency_tax_base_amount := 0;
      END IF;
      reversal_rec_.rowkey := NULL;
      Check_Vou_Row_Amounts___(reversal_rec_, comp_fin_rec_);
      Insert___(objid_,
                objversion_,
                reversal_rec_,
                attr_);
      Internal_Manual_Postings___(reversal_rec_, TRUE);
      Prepare_Tax_Transaction___(reversal_rec_, NULL);
   END LOOP;
END Reverse_Voucher_Rows__;

PROCEDURE Create_New_Row__(
   new_row_  IN OUT VOUCHER_ROW_TAB%ROWTYPE  )
IS   
BEGIN
   New___(new_row_);
END Create_New_Row__;

   
@UncheckedAccess
FUNCTION Get_Codestring__ (
   company_              IN VARCHAR2,
   voucher_type_         IN VARCHAR2,
   accounting_year_      IN NUMBER,
   voucher_no_           IN NUMBER,
   row_no_               IN NUMBER ) RETURN VARCHAR2
IS 
   voucher_row_    VOUCHER_ROW_TAB%ROWTYPE;   
BEGIN
   voucher_row_ := Get_Row(company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   RETURN Get_Codestring___(voucher_row_);
END Get_Codestring__;


PROCEDURE Insert_Row__ (
   newrec_              IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   create_project_conn_ IN      BOOLEAN DEFAULT TRUE)
IS
   attr_                      VARCHAR2(2000);
   objversion_                VARCHAR2(2000);
   objid_                     VARCHAR2(100);
   head_                      Voucher_Api.Public_Rec;
   function_group_            VARCHAR2(20);            
   user_group_                user_group_member_finance_tab.user_group%TYPE;
   create_project_conn_str_   VARCHAR2(5);
   tax_types_event_           VARCHAR2(10) := 'RESTRICTED';
   compfin_rec_               Company_Finance_API.Public_Rec;
BEGIN
   compfin_rec_ := Company_Finance_API.Get(newrec_.company);
   head_ := Voucher_API.Get( newrec_.company,
                             newrec_.accounting_year,
                             newrec_.voucher_type,
                             newrec_.voucher_no );
   function_group_     := head_.function_group;
   user_group_         := head_.user_group;
   IF (newrec_.voucher_date IS NULL) THEN
      newrec_.voucher_date := head_.voucher_date;
   END IF;
   Check_Codestring___ (newrec_,
                        user_group_);
   Check_Acquisition___(newrec_,
                        function_group_,
                        NULL);           -- fa_code_part
   Check_Project___ (newrec_,
                     function_group_ );
   IF ((newrec_.optional_code  IS NOT NULL) AND 
      (upper(newrec_.trans_code) = 'EXTERNAL') AND
      (function_group_ IN ('I', 'J' ,'F'))) THEN
      Tax_Handling_Util_API.Validate_Tax_On_Trans(newrec_.company,
                                                  tax_types_event_,
                                                  newrec_.optional_code,
                                                  'TRUE',
                                                  newrec_.account,
                                                  newrec_.voucher_date);      
   END IF;
   
   IF (head_.simulation_voucher = 'FALSE') THEN
      IF (function_group_ IN ('M', 'Q')) THEN
         IF (newrec_.optional_code IS NULL) THEN
            Tax_Handling_Util_API.Validate_Tax_Code_Manda_On_Acc(newrec_.company, newrec_.account);           
         END IF;
      END IF;
   END IF;
   IF (create_project_conn_) THEN
      create_project_conn_str_ := 'TRUE';
   ELSE
      create_project_conn_str_ := 'FALSE';
   END IF;   
   Client_SYS.Add_To_Attr('CREATE_PROJ_CONN', create_project_conn_str_, attr_);
   newrec_.rowkey := NULL;
   Check_Vou_Row_Amounts___(newrec_, compfin_rec_);
   Insert___(objid_,
             objversion_,
             newrec_,
             attr_);
$IF Component_Fixass_SYS.INSTALLED $THEN
   IF (newrec_.trans_code = 'FA CASH DISCOUNT' OR function_group_ = 'N') THEN
      Create_Add_Investment_Info___(newrec_);
   END IF;
$END
END Insert_Row__;


@UncheckedAccess
FUNCTION Get_Correction__ (
   amount_ IN NUMBER ) RETURN VARCHAR2
IS
BEGIN
   IF (amount_ >= 0) THEN
      RETURN('N');
   ELSE
      RETURN('Y');
   END IF;
END Get_Correction__;


@UncheckedAccess
FUNCTION Get_Correction_All__ (
   company_            IN VARCHAR2,
   voucher_type_       IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_no_         IN NUMBER,
   reference_row_no_   IN NUMBER,
   amount_             IN NUMBER,
   auto_tax_vou_entry_ IN VARCHAR2,
   parallel_amount_    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
IS
   correction_ref_no_  VARCHAR2(10);
   CURSOR get_correction IS
      SELECT correction
      FROM   VOUCHER_ROW
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    accounting_year  = accounting_year_
      AND    voucher_no       = voucher_no_
      AND    row_no           = reference_row_no_;
BEGIN
   IF amount_ IS NULL THEN
      RETURN('N');
   ELSIF (amount_ >= 0) THEN
      IF (amount_ = 0) THEN
         IF (auto_tax_vou_entry_ = 'TRUE') THEN
            -- Fetch correction for the referenced row no
            OPEN get_correction;
            FETCH get_correction INTO correction_ref_no_;
            CLOSE get_correction;
            IF (correction_ref_no_ = 'Y') THEN
               -- IF the referenced row no is a correction, the tax transaction
               -- connected to it also should be a correction.
               RETURN('Y');
            END IF;
         END IF;
         IF (NVL(parallel_amount_, 0) >= 0) THEN
            RETURN('N');
         ELSE
            RETURN('Y');
         END IF;
      END IF;
      RETURN('N');
   ELSE
      RETURN('Y');
   END IF;
END Get_Correction_All__;


PROCEDURE Create_Int_Manual_Postings__ (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   comp_fin_rec_    IN Company_Finance_API.Public_Rec,
   from_pa_         IN BOOLEAN DEFAULT FALSE )
IS
   tmp_codestr_                  Accounting_codestr_API.CodestrRec;
   row_rec_                      VOUCHER_ROW_TAB%ROWTYPE;
   currency_amount_              VOUCHER_ROW.currency_amount%TYPE;
   amount_                       VOUCHER_ROW.amount%TYPE;
   voucher_rec_                  Voucher_API.Public_Rec;
   is_base_emu_                  VARCHAR2(5);
   is_third_emu_                 VARCHAR2(5);  
   voucher_date_                 DATE;
   temp_curr_tax_amount_         NUMBER;
   temp_tax_amount_              NUMBER;
   temp_amount_                  NUMBER;
   temp_currency_amount_         NUMBER;
   currency_debet_amount_        NUMBER;
   currency_credit_amount_       NUMBER;
   debet_amount_                 NUMBER;
   credit_amount_                NUMBER;
   third_currency_debit_amount_  NUMBER;
   third_currency_credit_amount_ NUMBER;
   currency_debet_amount_tot_    NUMBER;
   currency_credit_amount_tot_   NUMBER;
   debet_amount_tot_             NUMBER;
   credit_amount_tot_            NUMBER;
   third_curr_debit_amount_tot_  NUMBER;
   third_curr_credit_amount_tot_ NUMBER;
   count_                        NUMBER;
   base_curr_rounding_           NUMBER;
   trans_curr_rounding_          NUMBER;
   third_curr_rounding_          NUMBER;   

   CURSOR get_manual_rows IS
      SELECT *
      FROM   INTERNAL_POSTINGS_ACCRUL_TAB
      WHERE  company             = company_
      AND    internal_seq_number = row_rec_.internal_seq_number    
      ORDER BY row_no;

   CURSOR get_vou_row IS
      SELECT *
      FROM   VOUCHER_ROW_TAB
      WHERE  company          = company_
      AND    voucher_type     = voucher_type_
      AND    accounting_year  = accounting_year_
      AND    voucher_no       = voucher_no_
      AND    row_no           = row_no_
      ORDER BY row_no;

  -- comp_fin_rec_                 company_finance_API.Public_Rec;
   
BEGIN
   OPEN  get_vou_row;
   FETCH get_vou_row INTO row_rec_;
   CLOSE get_vou_row;
   
   voucher_rec_ := Voucher_API.Get( company_,
                                    accounting_year_,
                                    voucher_type_,
                                    voucher_no_);
                                    
   IF (row_rec_.voucher_date IS NOT NULL) THEN
      voucher_date_ := row_rec_.voucher_date;
   ELSE
      voucher_date_ := voucher_rec_.voucher_date;
   END IF;
   -- comp_fin_rec_ := Company_Finance_API.Get(row_rec_.company);                                                    
   
   tmp_codestr_.code_b           := row_rec_.code_b;
   tmp_codestr_.code_c           := row_rec_.code_c;
   tmp_codestr_.code_d           := row_rec_.code_d;
   tmp_codestr_.code_e           := row_rec_.code_e;
   tmp_codestr_.code_f           := row_rec_.code_f;
   tmp_codestr_.code_g           := row_rec_.code_g;
   tmp_codestr_.code_h           := row_rec_.code_h;
   tmp_codestr_.code_i           := row_rec_.code_i;
   tmp_codestr_.code_j           := row_rec_.code_j;
   temp_curr_tax_amount_         := row_rec_.currency_tax_amount;
   temp_tax_amount_              := row_rec_.tax_amount;
   temp_amount_                  := row_rec_.gross_amount;
   temp_currency_amount_         := row_rec_.currency_gross_amount;
   currency_debet_amount_        := row_rec_.currency_debet_amount;
   currency_credit_amount_       := row_rec_.currency_credit_amount;
   debet_amount_                 := row_rec_.debet_amount;
   credit_amount_                := row_rec_.credit_amount;
   third_currency_debit_amount_  := row_rec_.third_currency_debit_amount;
   third_currency_credit_amount_ := row_rec_.third_currency_credit_amount;
   count_                        := 0;
   currency_debet_amount_tot_    := 0;
   currency_credit_amount_tot_   := 0;
   debet_amount_tot_             := 0;
   credit_amount_tot_            := 0;
   third_curr_debit_amount_tot_  := 0;
   third_curr_credit_amount_tot_ := 0;
 
   base_curr_rounding_           := Currency_Code_API.Get_currency_rounding(company_, comp_fin_rec_.currency_code);
   is_base_emu_                  := Currency_Code_API.Get_Valid_Emu (company_,
                                                                     comp_fin_rec_.currency_code,
                                                                     voucher_date_);                                                        
   IF (row_rec_.currency_code = comp_fin_rec_.currency_code) THEN
      trans_curr_rounding_       := base_curr_rounding_;
   ELSE
      trans_curr_rounding_       := Currency_Code_API.Get_currency_rounding (company_, row_rec_.currency_code);
   END IF;
   IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
      third_curr_rounding_       := Currency_Code_API.Get_currency_rounding (company_, comp_fin_rec_.parallel_acc_currency);
      is_third_emu_              := Currency_Code_API.Get_Valid_Emu (company_,
                                                                     comp_fin_rec_.parallel_acc_currency,
                                                                     voucher_date_);
   ELSE
      is_third_emu_              := 'FALSE';
   END IF;

   FOR rec_ IN get_manual_rows LOOP
      count_ := count_ + 1;
      row_rec_.account := rec_.account;
      row_rec_.code_b  := NVL(rec_.code_b, tmp_codestr_.code_b);
      row_rec_.code_c  := NVL(rec_.code_c, tmp_codestr_.code_c);
      row_rec_.code_d  := NVL(rec_.code_d, tmp_codestr_.code_d);
      row_rec_.code_e  := NVL(rec_.code_e, tmp_codestr_.code_e);
      row_rec_.code_f  := NVL(rec_.code_f, tmp_codestr_.code_f);
      row_rec_.code_g  := NVL(rec_.code_g, tmp_codestr_.code_g);
      row_rec_.code_h  := NVL(rec_.code_h, tmp_codestr_.code_h);
      row_rec_.code_i  := NVL(rec_.code_i, tmp_codestr_.code_i);
      row_rec_.code_j  := NVL(rec_.code_j, tmp_codestr_.code_j);
      IF (rec_.text IS NOT NULL) THEN
         row_rec_.text := rec_.text;
      END IF;
      amount_                          := nvl(rec_.debit_amount,-rec_.credit_amount);
      currency_amount_                 := nvl(rec_.currency_debit_amount,-rec_.currency_credit_amount);
      row_rec_.debet_amount            := rec_.debit_amount;
      row_rec_.credit_amount           := rec_.credit_amount;
      row_rec_.currency_debet_amount   := rec_.currency_debit_amount;
      row_rec_.currency_credit_amount  := rec_.currency_credit_amount;
      row_rec_.currency_tax_amount     := ROUND((temp_curr_tax_amount_*ROUND((currency_amount_/temp_currency_amount_),trans_curr_rounding_)),trans_curr_rounding_);
      row_rec_.tax_amount              := ROUND((temp_tax_amount_*ROUND((amount_/temp_amount_),base_curr_rounding_)),base_curr_rounding_);


      IF (row_rec_.conversion_factor IS NULL) THEN
         row_rec_.conversion_factor := Currency_Code_API.Get_Conversion_Factor(rec_.company, row_rec_.currency_code);
      END IF;
      IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF (rec_.debit_amount IS NOT NULL) THEN
            row_rec_.third_currency_debit_amount := Currency_Amount_API.Calculate_Parallel_Curr_Amount(row_rec_.company,
                                                             voucher_date_,
                                                             rec_.debit_amount,
                                                             row_rec_.currency_debet_amount, 
                                                             comp_fin_rec_.currency_code,
                                                             row_rec_.currency_code,
                                                             row_rec_.parallel_curr_rate_type,
                                                             comp_fin_rec_.parallel_acc_currency,
                                                             comp_fin_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
         END IF;
         IF (rec_.credit_amount IS NOT NULL) THEN
             row_rec_.third_currency_credit_amount := Currency_Amount_API.Calculate_Parallel_Curr_Amount(row_rec_.company,
                                                             voucher_date_, 
                                                             rec_.credit_amount,
                                                             row_rec_.currency_credit_amount,
                                                             comp_fin_rec_.currency_code, 
                                                             row_rec_.currency_code,
                                                             row_rec_.parallel_curr_rate_type,
                                                             comp_fin_rec_.parallel_acc_currency,
                                                             comp_fin_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
         END IF;
      END IF;
      currency_debet_amount_tot_    := currency_debet_amount_tot_ + ROUND(row_rec_.currency_debet_amount,trans_curr_rounding_);
      currency_credit_amount_tot_   := currency_credit_amount_tot_ + ROUND(row_rec_.currency_credit_amount,trans_curr_rounding_);
      debet_amount_tot_             := debet_amount_tot_ + ROUND(row_rec_.debet_amount,base_curr_rounding_);
      credit_amount_tot_            := credit_amount_tot_ + ROUND(row_rec_.credit_amount,base_curr_rounding_);
      third_curr_debit_amount_tot_  := third_curr_debit_amount_tot_ + ROUND(row_rec_.third_currency_debit_amount,third_curr_rounding_);
      third_curr_credit_amount_tot_ := third_curr_credit_amount_tot_ + ROUND(row_rec_.third_currency_credit_amount,third_curr_rounding_);
      Calculate_Net_From_Gross (row_rec_,
                                voucher_rec_.amount_method,
                                comp_fin_rec_.parallel_acc_currency,
                                is_third_emu_,        
                                comp_fin_rec_.currency_code,  
                                is_base_emu_);        
      Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', row_rec_.company);
      Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_TYPE', row_rec_.voucher_type);
      Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_YEAR', row_rec_.accounting_year);
      Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_NO', row_rec_.voucher_no);
      Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', row_rec_.account);
      Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_PERIOD', row_rec_.accounting_period);
      IF (from_pa_) THEN
         $IF Component_Intled_SYS.INSTALLED $THEN
            Internal_Voucher_Util_Pub_API.Create_Pa_Internal_Row (row_rec_,
                                                                  rec_.ledger_id,
                                                                  base_curr_rounding_,   
                                                                  trans_curr_rounding_,  
                                                                  third_curr_rounding_); 
         $ELSE
            NULL;
         $END
      ELSE
         IF (Voucher_Type_Detail_API.Get_Function_Group(rec_.company, rec_.voucher_type) = 'R') THEN            
            IF (comp_fin_rec_.correction_type = 'REVERSE') THEN
               currency_debet_amount_                 := row_rec_.currency_debet_amount;
               currency_credit_amount_                := row_rec_.currency_credit_amount;
               debet_amount_                          := row_rec_.debet_amount;
               credit_amount_                         := row_rec_.credit_amount;
               IF (currency_credit_amount_ IS NULL) THEN
                  third_currency_credit_amount_ := NULL;
                  third_currency_debit_amount_  := row_rec_.third_currency_debit_amount;
               ELSE
                  third_currency_credit_amount_ := row_rec_.third_currency_credit_amount;
                  third_currency_debit_amount_  := NULL;
               END IF;
               row_rec_.currency_debet_amount         := currency_credit_amount_;
               row_rec_.currency_credit_amount        := currency_debet_amount_;
               row_rec_.debet_amount                  := credit_amount_;
               row_rec_.credit_amount                 := debet_amount_;
               row_rec_.third_currency_debit_amount   := third_currency_credit_amount_;
               row_rec_.third_currency_credit_amount  := third_currency_debit_amount_;
            ELSE
               row_rec_.currency_debet_amount         := -row_rec_.currency_debet_amount;
               row_rec_.currency_credit_amount        := -row_rec_.currency_credit_amount;
               row_rec_.debet_amount                  := -row_rec_.debet_amount;
               row_rec_.credit_amount                 := -row_rec_.credit_amount;
               row_rec_.third_currency_debit_amount   := -row_rec_.third_currency_debit_amount;
               row_rec_.third_currency_credit_amount  := -row_rec_.third_currency_credit_amount;
            END IF;
         END IF;
         $IF Component_Intled_SYS.INSTALLED $THEN
            Internal_Voucher_Util_Pub_API.Create_Internal_Row (rec_.ledger_id,
                                                               row_rec_,
                                                               base_curr_rounding_,
                                                               trans_curr_rounding_,
                                                               third_curr_rounding_);
         $END
      END IF;
   END LOOP;
END Create_Int_Manual_Postings__;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Set_Row_Data__(
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   voucher_no_       IN NUMBER,
   accounting_year_  IN NUMBER,
   row_no_           IN NUMBER,
   reference_serie_  IN VARCHAR2,
   reference_number_ IN VARCHAR2,
   row_group_id_     IN NUMBER)
IS
BEGIN
   UPDATE VOUCHER_ROW_TAB
   SET    reference_serie  = reference_serie_,
          reference_number = reference_number_,
          row_group_id     = row_group_id_
   WHERE  company         = company_
   AND    voucher_type    = voucher_type_
   AND    voucher_no      = voucher_no_
   AND    accounting_year = accounting_year_
   AND    row_no          = row_no_;
END Set_Row_Data__;

PROCEDURE Update_Vou_Row_Acc_Period__( 
   company_          IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_no_       IN NUMBER,
   voucher_type_     IN VARCHAR2,
   new_acc_period_   IN NUMBER)  
IS   
BEGIN
   IF new_acc_period_ IS NOT NULL THEN
      UPDATE voucher_row_tab
      SET accounting_period = new_acc_period_
      WHERE company         = company_
      AND accounting_year   = accounting_year_
      AND voucher_no        = voucher_no_
      AND voucher_type      = voucher_type_
      AND accounting_period != new_acc_period_;
   END IF;
END Update_Vou_Row_Acc_Period__;

PROCEDURE Get_Id_Version_By_Keys__ (
   objid_           IN OUT VARCHAR2,
   objversion_      IN OUT VARCHAR2,
   company_         IN     VARCHAR2,
   voucher_type_    IN     VARCHAR2,
   accounting_year_ IN     NUMBER,
   voucher_no_      IN     NUMBER,
   row_no_          IN     NUMBER )
IS
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
END Get_Id_Version_By_Keys__;

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Create_Object_Connection_(
   company_              IN VARCHAR2,
   voucher_type_         IN VARCHAR2,
   accounting_year_      IN NUMBER,
   voucher_no_           IN NUMBER,
   row_no_               IN NUMBER,
   account_              IN VARCHAR2,
   debet_amount_         IN NUMBER,
   credit_amount_        IN NUMBER,
   text_                 IN VARCHAR2,
   trans_code_           IN VARCHAR2,
   project_activity_id_  IN NUMBER,
   voucher_date_         IN DATE DEFAULT NULL,
   code_b_               IN VARCHAR2 DEFAULT NULL,
   code_c_               IN VARCHAR2 DEFAULT NULL,
   code_d_               IN VARCHAR2 DEFAULT NULL,
   code_e_               IN VARCHAR2 DEFAULT NULL,
   code_f_               IN VARCHAR2 DEFAULT NULL,   
   code_g_               IN VARCHAR2 DEFAULT NULL,            
   code_h_               IN VARCHAR2 DEFAULT NULL,
   code_i_               IN VARCHAR2 DEFAULT NULL,
   code_j_               IN VARCHAR2 DEFAULT NULL,
   currency_code_          IN VARCHAR2 DEFAULT NULL,
   currency_debet_amount_  IN NUMBER   DEFAULT NULL,
   currency_credit_amount_ IN NUMBER   DEFAULT NULL)
IS
   vourow_rec_      voucher_row_tab%ROWTYPE;
BEGIN
   
   vourow_rec_.company             := company_;
   vourow_rec_.voucher_type        := voucher_type_;
   vourow_rec_.accounting_year     := accounting_year_;
   vourow_rec_.voucher_no          := voucher_no_;
   vourow_rec_.row_no              := row_no_;
   vourow_rec_.account             := account_;
   vourow_rec_.debet_amount        := debet_amount_;
   vourow_rec_.credit_amount       := credit_amount_;
   vourow_rec_.text                := text_;
   vourow_rec_.trans_code          := trans_code_;
   vourow_rec_.project_activity_id := project_activity_id_;   
   vourow_rec_.voucher_date        := voucher_date_;
   vourow_rec_.code_b              := code_b_;
   vourow_rec_.code_c              := code_c_;
   vourow_rec_.code_d              := code_d_;
   vourow_rec_.code_e              := code_e_;
   vourow_rec_.code_f              := code_f_;
   vourow_rec_.code_g              := code_g_;
   vourow_rec_.code_h              := code_h_;
   vourow_rec_.code_i              := code_i_;
   vourow_rec_.code_j              := code_j_;   
   vourow_rec_.currency_code           := currency_code_;
   vourow_rec_.currency_debet_amount   := currency_debet_amount_;
   vourow_rec_.currency_credit_amount  := currency_credit_amount_;

   Create_Object_Connection___(vourow_rec_);
END Create_Object_Connection_;

PROCEDURE Add_New_Row_ (
   voucher_row_rec_     IN OUT Voucher_API.VoucherRowRecType,
   vou_row_attr_        OUT    VARCHAR2,
   base_currency_code_  IN     VARCHAR2,
   base_curr_rounding_  IN     NUMBER,
   is_base_emu_         IN     VARCHAR2,
   trans_curr_rounding_ IN     NUMBER,
   third_curr_rounding_ IN     NUMBER,
   is_third_emu_        IN     VARCHAR2,
   fa_code_part_        IN     VARCHAR2,
   project_code_part_   IN     VARCHAR2,
   create_project_conn_ IN     BOOLEAN DEFAULT TRUE )
IS
   newrec_                       VOUCHER_ROW_TAB%ROWTYPE;
   attr_                         VARCHAR2(2000);
   objversion_                   VARCHAR2(2000);
   objid_                        VARCHAR2(100);
   user_group_                   user_group_member_finance_tab.user_group%TYPE;
  -- third_currency_codex_         VARCHAR2(3);  
   is_third_emux_                VARCHAR2(5);  
   third_currency_debit_amount_  NUMBER;
   third_currency_credit_amount_ NUMBER;
   currency_amount_              VOUCHER_ROW.currency_amount%TYPE;
   amount_                       VOUCHER_ROW.amount%TYPE;
   correction_                   VOUCHER_ROW.correction%TYPE;
   function_group_               VARCHAR2(10);
   head_                         Voucher_Api.Public_Rec;
   curr_balance_                 VARCHAR2(1);
   inverted_rate_                VARCHAR2(5);
   parallel_amount_              NUMBER;
   acc_amount_                   NUMBER;
   trans_amount_                 NUMBER;
   compfin_rec_                  Company_Finance_API.Public_Rec;
   create_project_conn_str_ VARCHAR2(5);
BEGIN
   head_ := Voucher_API.Get( voucher_row_rec_.company,
                             voucher_row_rec_.accounting_year,
                             voucher_row_rec_.voucher_type,
                             voucher_row_rec_.voucher_no );
   function_group_     := head_.function_group;
   user_group_         := head_.user_group;
   IF (voucher_row_rec_.voucher_date IS NULL) THEN
      voucher_row_rec_.voucher_date := head_.voucher_date;
   END IF;
   newrec_.company                      := voucher_row_rec_.company;
   newrec_.voucher_type                 := voucher_row_rec_.voucher_type;
   newrec_.accounting_year              := voucher_row_rec_.accounting_year;
   newrec_.accounting_period            := voucher_row_rec_.accounting_period;
   newrec_.voucher_no                   := voucher_row_rec_.voucher_no;
   newrec_.voucher_date                 := voucher_row_rec_.voucher_date;
   newrec_.row_no                       := voucher_row_rec_.row_no;
   newrec_.row_group_id                 := voucher_row_rec_.row_group_id;
   newrec_.account                      := voucher_row_rec_.codestring_rec.code_a;
   newrec_.code_b                       := voucher_row_rec_.codestring_rec.code_b;
   newrec_.code_c                       := voucher_row_rec_.codestring_rec.code_c;
   newrec_.code_d                       := voucher_row_rec_.codestring_rec.code_d;
   newrec_.code_e                       := voucher_row_rec_.codestring_rec.code_e;
   newrec_.code_f                       := voucher_row_rec_.codestring_rec.code_f;
   newrec_.code_g                       := voucher_row_rec_.codestring_rec.code_g;
   newrec_.code_h                       := voucher_row_rec_.codestring_rec.code_h;
   newrec_.code_i                       := voucher_row_rec_.codestring_rec.code_i;
   newrec_.code_j                       := voucher_row_rec_.codestring_rec.code_j;
   newrec_.internal_seq_number          := voucher_row_rec_.internal_seq_number;
   newrec_.currency_debet_amount        := voucher_row_rec_.currency_debet_amount;
   newrec_.currency_credit_amount       := voucher_row_rec_.currency_credit_amount;
   newrec_.debet_amount                 := voucher_row_rec_.debet_amount;
   newrec_.credit_amount                := voucher_row_rec_.credit_amount;
   newrec_.currency_code                := voucher_row_rec_.currency_code;
   newrec_.quantity                     := voucher_row_rec_.quantity;
   newrec_.process_code                 := voucher_row_rec_.process_code;
   newrec_.optional_code                := voucher_row_rec_.optional_code;
   newrec_.project_activity_id          := voucher_row_rec_.project_activity_id;
   newrec_.text                         := voucher_row_rec_.text;
   newrec_.party_type_id                := voucher_row_rec_.party_type_id;
   newrec_.reference_serie              := voucher_row_rec_.reference_serie;
   newrec_.reference_number             := voucher_row_rec_.reference_number;
   newrec_.trans_code                   := voucher_row_rec_.trans_code;
   newrec_.update_error                 := voucher_row_rec_.update_error;
   newrec_.transfer_id                  := voucher_row_rec_.transfer_id;
   newrec_.corrected                    := NVL( voucher_row_rec_.corrected, 'N' );
   newrec_.third_currency_debit_amount  := voucher_row_rec_.third_currency_debit_amount;
   newrec_.third_currency_credit_amount := voucher_row_rec_.third_currency_credit_amount;
   newrec_.currency_rate                := voucher_row_rec_.currency_rate;
   amount_                              := voucher_row_rec_.amount;
   currency_amount_                     := voucher_row_rec_.currency_amount;
   correction_                          := voucher_row_rec_.correction;
   newrec_.auto_tax_vou_entry           := voucher_row_rec_.auto_tax_vou_entry;
   newrec_.tax_direction                := voucher_row_rec_.tax_direction;
   newrec_.tax_base_amount              := voucher_row_rec_.tax_base_amount;
   newrec_.currency_tax_base_amount     := voucher_row_rec_.currency_tax_base_amount;
   newrec_.reference_version            := voucher_row_rec_.reference_version;
   newrec_.party_type                   := voucher_row_rec_.party_type;
   newrec_.mpccom_accounting_id         := voucher_row_rec_.mpccom_accounting_id;
   newrec_.currency_type                := voucher_row_rec_.currency_type; 
   newrec_.activate_code                := voucher_row_rec_.activate_code;
   newrec_.parallel_currency_rate       := voucher_row_rec_.parallel_currency_rate;
   newrec_.parallel_conversion_factor   := voucher_row_rec_.parallel_curr_conv_fac;
   newrec_.parallel_curr_rate_type      := voucher_row_rec_.parallel_curr_rate_type;
   newrec_.deliv_type_id                := voucher_row_rec_.deliv_type_id;
   newrec_.matching_info                := voucher_row_rec_.matching_info;
   
   IF (newrec_.currency_debet_amount IS NULL) THEN
      newrec_.currency_debet_amount := newrec_.debet_amount;
   END IF;
   IF (newrec_.currency_credit_amount IS NULL) THEN
      newrec_.currency_credit_amount := newrec_.credit_amount;
   END IF;
   Accounting_Code_Part_A_API.Get_Curr_Balance(curr_balance_,
                                               voucher_row_rec_.company,
                                               voucher_row_rec_.codestring_rec.code_a );
   IF (nvl(amount_, 0) = 0) THEN
      amount_ := nvl(newrec_.debet_amount, 0) - nvl(newrec_.credit_amount,0);
   END IF;
   IF currency_amount_ IS NULL THEN
      currency_amount_ := nvl(newrec_.currency_debet_amount, 0) - nvl(newrec_.currency_credit_amount,0);
   END IF;
   IF ( newrec_.currency_rate IS NULL) THEN
      Currency_Amount_API.Calc_Currency_Rate (newrec_.currency_rate,
                                              voucher_row_rec_.company,
                                              voucher_row_rec_.currency_code,
                                              amount_,
                                              currency_amount_,
                                              base_currency_code_ );
   END IF;
   newrec_.conversion_factor     := Currency_Code_API.Get_Conversion_Factor (voucher_row_rec_.company, voucher_row_rec_.currency_code);
   newrec_.multi_company_id      := voucher_row_rec_.multi_company_id;

   IF (NVL(correction_,'N') != 'Y') THEN
      correction_ := 'N';
   ELSE
      correction_ := 'Y';
   END IF;
   Check_And_Set_Amounts___ (newrec_,
                             currency_amount_,
                             amount_,
                             correction_);

   -- Parallel Currency handling   
   compfin_rec_ := Company_Finance_API.Get(newrec_.company);   
   IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
      IF (is_third_emu_ IS NULL) THEN
         is_third_emux_ := Currency_Code_API.Get_Valid_Emu(newrec_.company,
                                                           compfin_rec_.parallel_acc_currency,
                                                           newrec_.voucher_date);
      ELSE
         is_third_emux_ := is_third_emu_;
      END IF;

      third_currency_debit_amount_  := newrec_.third_currency_debit_amount;
      third_currency_credit_amount_ := newrec_.third_currency_credit_amount;

      -- IF the parallel currency amounts are not given then fetch the rate, conversion factor and rate type from basic data. Amounts will be calculated further down.
      -- IF the parallel currency amounts are given but not rate and conversion factor then calculate that data (although it should have been supplied by the calling method)
      IF (newrec_.third_currency_debit_amount IS NULL AND newrec_.third_currency_credit_amount IS NULL) THEN
         newrec_.parallel_curr_rate_type := compfin_rec_.parallel_rate_type;
         Currency_Rate_API.Get_Parallel_Currency_Rate(newrec_.parallel_currency_rate,
                                                      newrec_.parallel_conversion_factor,
                                                      inverted_rate_,
                                                      newrec_.company,
                                                      newrec_.currency_code,
                                                      newrec_.voucher_date,
                                                      newrec_.parallel_curr_rate_type,
                                                      compfin_rec_.parallel_base,
                                                      base_currency_code_,
                                                      compfin_rec_.parallel_acc_currency,
                                                      is_base_emu_,
                                                      is_third_emux_);
      ELSE
         -- if rate is null then fetch conversion factor and inverted flag then calculate the rate. IF rate is not null then 
         -- assume that factor and rate type is given as well.
         IF (newrec_.parallel_currency_rate IS NULL) THEN
            newrec_.parallel_curr_rate_type := compfin_rec_.parallel_rate_type;
            IF (newrec_.third_currency_debit_amount IS NOT NULL) THEN
               parallel_amount_ := newrec_.third_currency_debit_amount;
               acc_amount_      := newrec_.debet_amount;
               trans_amount_    := newrec_.currency_debet_amount;
            ELSE
               parallel_amount_ := newrec_.third_currency_credit_amount;
               acc_amount_      := newrec_.credit_amount;
               trans_amount_    := newrec_.currency_credit_amount;
            END IF;
            newrec_.parallel_currency_rate := Currency_Amount_API.Calculate_Parallel_Curr_Rate(newrec_.company,
                                                                                               newrec_.voucher_date,
                                                                                               acc_amount_,
                                                                                               trans_amount_,
                                                                                               parallel_amount_,
                                                                                               compfin_rec_.currency_code,
                                                                                               newrec_.currency_code,
                                                                                               compfin_rec_.parallel_acc_currency,
                                                                                               compfin_rec_.parallel_base,
                                                                                               newrec_.parallel_curr_rate_type);

            newrec_.parallel_conversion_factor := Currency_Rate_API.Get_Par_Curr_Rate_Conv_Factor(newrec_.company,
                                                                                                  newrec_.currency_code,
                                                                                                  newrec_.voucher_date,
                                                                                                  compfin_rec_.currency_code,
                                                                                                  compfin_rec_.parallel_acc_currency,
                                                                                                  compfin_rec_.parallel_base,
                                                                                                  newrec_.parallel_curr_rate_type);
         ELSE
            -- Make sure that rate type is set
            IF (newrec_.parallel_curr_rate_type IS NULL) THEN
               newrec_.parallel_curr_rate_type := compfin_rec_.parallel_rate_type;
            END IF;
         END IF;
      END IF;

      newrec_.parallel_curr_tax_amount     := voucher_row_rec_.parallel_curr_tax_amt;
      newrec_.parallel_curr_gross_amount   := voucher_row_rec_.parallel_curr_gross_amt;
      newrec_.parallel_curr_tax_base_amount:= voucher_row_rec_.parallel_curr_tax_base_amt;

      IF ((newrec_.debet_amount IS NOT NULL) AND
          (newrec_.third_currency_debit_amount IS NULL)) THEN

         third_currency_debit_amount_ := Currency_Amount_API.Calculate_Parallel_Curr_Amount(newrec_.company,
                                                                                            newrec_.voucher_date,
                                                                                            newrec_.debet_amount,
                                                                                            newrec_.currency_debet_amount,
                                                                                            compfin_rec_.currency_code,
                                                                                            newrec_.currency_code, 
                                                                                            newrec_.parallel_curr_rate_type,
                                                                                            compfin_rec_.parallel_acc_currency,
                                                                                            compfin_rec_.parallel_base,
                                                                                            is_base_emu_,
                                                                                            is_third_emux_);
   
         newrec_.third_currency_debit_amount := NVL(third_currency_debit_amount_,0);
      END IF;
      IF ((newrec_.credit_amount IS NOT NULL) AND
          (newrec_.third_currency_credit_amount IS NULL)) THEN

         third_currency_credit_amount_ := Currency_Amount_API.Calculate_Parallel_Curr_Amount(newrec_.company,
                                                                                             newrec_.voucher_date,
                                                                                             newrec_.credit_amount,
                                                                                             newrec_.currency_credit_amount,
                                                                                             compfin_rec_.currency_code,
                                                                                             newrec_.currency_code, 
                                                                                             newrec_.parallel_curr_rate_type,
                                                                                             compfin_rec_.parallel_acc_currency,
                                                                                             compfin_rec_.parallel_base,
                                                                                             is_base_emu_,
                                                                                             is_third_emux_);
   
         newrec_.third_currency_credit_amount := NVL(third_currency_credit_amount_,0);
      END IF;
   ELSE
      -- if parallel currency is not used then set amounts to null
      newrec_.third_currency_debit_amount := NULL;
      newrec_.third_currency_credit_amount := NULL;
   END IF;
   
   Error_SYS.Check_Not_Null(lu_name_, 'COMPANY', newrec_.company);
   Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_TYPE', newrec_.voucher_type);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_YEAR', newrec_.accounting_year);
   Error_SYS.Check_Not_Null(lu_name_, 'VOUCHER_NO', newrec_.voucher_no);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNT', newrec_.account);
   Error_SYS.Check_Not_Null(lu_name_, 'ACCOUNTING_PERIOD', newrec_.accounting_period);

   IF (NVL(voucher_row_rec_.ext_validate_codestr,'X') != 'E') THEN
      IF (voucher_row_rec_.revenue_cost_clear_voucher = 'TRUE') THEN
         Check_Codestring___ (newrec_                  => newrec_,
                              user_groupx_             => user_group_,
                              check_codeparts_         => TRUE,
                              check_demands_codeparts_ => FALSE,
                              check_demands_quantity_  => FALSE,
                              check_demands_process_   => FALSE,
                              check_demands_text_      => FALSE);
      ELSIF (function_group_ != 'YE') THEN
         Check_Codestring___ (newrec_,
                              user_group_);
      END IF;                       
   END IF;
   IF (function_group_ NOT IN ( 'A', 'Q', 'YE' )) THEN
      Check_Acquisition___(newrec_,
                           function_group_,
                           fa_code_part_);
   END IF;
   IF (function_group_ NOT IN ('YE', 'P', 'PPC'))THEN
      Check_Project___ (newrec_, function_group_ );
   END IF;
   -- Execute check_project__() for Project completion and avoid executing for revenue recognition vouchers.
   IF (function_group_ IN ('P', 'PPC') AND newrec_.project_activity_id = -123456) THEN
      Check_Project___ (newrec_, function_group_ );
   END IF;                                  
   newrec_.currency_debet_amount        := ROUND(newrec_.currency_debet_amount, trans_curr_rounding_);
   newrec_.currency_credit_amount       := ROUND(newrec_.currency_credit_amount, trans_curr_rounding_);
   newrec_.debet_amount                 := ROUND(newrec_.debet_amount, base_curr_rounding_);
   newrec_.credit_amount                := ROUND(newrec_.credit_amount, base_curr_rounding_);

   IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
      IF (newrec_.third_currency_debit_amount <> 0) THEN
         newrec_.third_currency_debit_amount  := ROUND(newrec_.third_currency_debit_amount, third_curr_rounding_);
      END IF;
      IF (newrec_.third_currency_credit_amount <> 0) THEN
         newrec_.third_currency_credit_amount := ROUND(newrec_.third_currency_credit_amount, third_curr_rounding_);
      END IF;
   END IF;
   -- these values never seems to be assigned to the newrec record, should they be removed or assign from record? 2012-12-14
   newrec_.tax_amount                   := ROUND(newrec_.tax_amount, base_curr_rounding_);
   newrec_.currency_tax_amount          := ROUND(newrec_.currency_tax_amount, trans_curr_rounding_);
   newrec_.gross_amount                 := ROUND(newrec_.gross_amount, base_curr_rounding_);
   newrec_.currency_gross_amount        := ROUND(newrec_.currency_gross_amount, trans_curr_rounding_);
   newrec_.tax_base_amount              := ROUND(newrec_.tax_base_amount, base_curr_rounding_);
   newrec_.currency_tax_base_amount     := ROUND(newrec_.currency_tax_base_amount, trans_curr_rounding_);
   -- Send ROUNDED,TRUE to tell Insert___ the amounts are already rounded
   Client_SYS.Clear_Attr(attr_);
   Client_SYS.Add_To_Attr( 'ROUNDED','TRUE',  attr_);
   IF (create_project_conn_) THEN
      create_project_conn_str_ := 'TRUE';
   ELSE
      create_project_conn_str_ := 'FALSE';
   END IF;     
   Client_SYS.Add_To_Attr('CREATE_PROJ_CONN', create_project_conn_str_, attr_);
   newrec_.rowkey := NULL;
   Check_Vou_Row_Amounts___(newrec_, compfin_rec_);
   Insert___ (objid_,
              objversion_,
              newrec_,
              attr_);
   voucher_row_rec_.row_no := newrec_.row_no;
   Internal_Manual_Postings___ ( newrec_,
                                 TRUE,
                                 base_curr_rounding_,
                                 trans_curr_rounding_,
                                 third_curr_rounding_,
                                 compfin_rec_); 
$IF Component_Fixass_SYS.INSTALLED $THEN
   IF (function_group_ NOT IN ( 'A', 'Q', 'YE' )) THEN
      Create_Add_Investment_Info___(newrec_);
   END IF;
$END
END Add_New_Row_;


PROCEDURE Add_New_Row_ (
   voucher_row_rec_     IN OUT Voucher_API.VoucherRowRecType,
   vou_row_attr_        OUT    VARCHAR2,
   create_project_conn_ IN     BOOLEAN DEFAULT TRUE )
IS
   project_code_part_          VARCHAR2(1);
   fa_code_part_               VARCHAR2(1);
   is_base_emu_                VARCHAR2(5);
   is_third_emu_               VARCHAR2(5);
   voucher_date_               DATE;
   base_curr_rounding_         NUMBER;
   trans_curr_rounding_        NUMBER;
   third_curr_rounding_        NUMBER;
   compfin_rec_                Company_Finance_API.Public_Rec;
BEGIN
   IF (voucher_row_rec_.voucher_date IS NOT NULL) THEN
      voucher_date_ := voucher_row_rec_.voucher_date;
   ELSE
      Voucher_API.Get_Voucher_Date ( voucher_date_,
                                     voucher_row_rec_.company,
                                     voucher_row_rec_.voucher_type,
                                     voucher_row_rec_.accounting_year,
                                     voucher_row_rec_.voucher_no);
   END IF;
   project_code_part_ := Accounting_Code_Parts_API.Get_Codepart_Function (voucher_row_rec_.company, 'PRACC');
   fa_code_part_      := Accounting_Code_Parts_API.Get_Codepart_Function (voucher_row_rec_.company, 'FAACC');
   
   compfin_rec_       := Company_Finance_API.Get(voucher_row_rec_.company);

   is_base_emu_ := Currency_Code_API.Get_Valid_Emu (voucher_row_rec_.company,
                                                    compfin_rec_.currency_code,
                                                    voucher_date_);
   base_curr_rounding_  := Currency_Code_API.Get_currency_rounding (voucher_row_rec_.company, compfin_rec_.currency_code);
 
   IF (voucher_row_rec_.currency_code = compfin_rec_.currency_code) THEN
      trans_curr_rounding_ := base_curr_rounding_;
   ELSE
      trans_curr_rounding_ := Currency_Code_API.Get_currency_rounding (voucher_row_rec_.company, voucher_row_rec_.currency_code);
   END IF;
   IF (compfin_rec_.parallel_acc_currency IS NOT NULL) THEN
      IF (compfin_rec_.parallel_acc_currency = compfin_rec_.currency_code) THEN
         third_curr_rounding_ := base_curr_rounding_;
      ELSIF (compfin_rec_.parallel_acc_currency = voucher_row_rec_.currency_code) THEN
         third_curr_rounding_ := trans_curr_rounding_;
      ELSE
         third_curr_rounding_ := Currency_Code_API.Get_currency_rounding (voucher_row_rec_.company, compfin_rec_.parallel_acc_currency);
      END IF;
      is_third_emu_           := Currency_Code_API.Get_Valid_Emu (voucher_row_rec_.company,
                                                                  compfin_rec_.parallel_acc_currency,
                                                                  voucher_date_);
   ELSE
      is_third_emu_           := 'FALSE';
   END IF;
   Add_New_Row_ ( voucher_row_rec_,
                  vou_row_attr_,
                  compfin_rec_.currency_code,
                  base_curr_rounding_,
                  is_base_emu_,
                  trans_curr_rounding_,  -- Misc performance
                  third_curr_rounding_,  
                  is_third_emu_,         
                  fa_code_part_,
                  project_code_part_,
                  create_project_conn_ ); 
END Add_New_Row_;


PROCEDURE Modify_Row_ (
   info_       OUT    VARCHAR2,
   objversion_ IN OUT VARCHAR2,
   attr_       IN OUT VARCHAR2,
   objid_      IN     VARCHAR2,
   action_     IN     VARCHAR2 )
IS
BEGIN
   Modify__ ( info_, objid_, objversion_, attr_, 'DO');
END Modify_Row_;


PROCEDURE Create_Cancel_Row_ (
   voucher_row_rec_     IN OUT Voucher_API.VoucherRowRecType,
   compfin_rec_         IN     Company_Finance_API.Public_Rec)
IS
   row_rec_     VOUCHER_ROW_TAB%ROWTYPE;
BEGIN

   row_rec_.accounting_period            := voucher_row_rec_.accounting_period;
   row_rec_.company                      := voucher_row_rec_.company;
   row_rec_.voucher_type                 := voucher_row_rec_.voucher_type;
   row_rec_.accounting_year              := voucher_row_rec_.accounting_year;
   row_rec_.voucher_no                   := voucher_row_rec_.voucher_no;
   row_rec_.account                      := voucher_row_rec_.codestring_rec.code_a;
   row_rec_.code_b                       := voucher_row_rec_.codestring_rec.code_b;
   row_rec_.code_c                       := voucher_row_rec_.codestring_rec.code_c;
   row_rec_.code_d                       := voucher_row_rec_.codestring_rec.code_d;
   row_rec_.code_e                       := voucher_row_rec_.codestring_rec.code_e;
   row_rec_.code_f                       := voucher_row_rec_.codestring_rec.code_f;
   row_rec_.code_g                       := voucher_row_rec_.codestring_rec.code_g;
   row_rec_.code_h                       := voucher_row_rec_.codestring_rec.code_h;
   row_rec_.code_i                       := voucher_row_rec_.codestring_rec.code_i;
   row_rec_.code_j                       := voucher_row_rec_.codestring_rec.code_j;
   row_rec_.currency_debet_amount        := voucher_row_rec_.currency_debet_amount;
   row_rec_.currency_credit_amount       := voucher_row_rec_.currency_credit_amount;
   row_rec_.debet_amount                 := voucher_row_rec_.debet_amount;
   row_rec_.credit_amount                := voucher_row_rec_.credit_amount;
   row_rec_.third_currency_debit_amount  := voucher_row_rec_.third_currency_debit_amount;
   row_rec_.third_currency_credit_amount := voucher_row_rec_.third_currency_credit_amount;
   row_rec_.currency_code                := voucher_row_rec_.currency_code;
   row_rec_.quantity                     := voucher_row_rec_.quantity;
   row_rec_.process_code                 := voucher_row_rec_.process_code;
   row_rec_.optional_code                := voucher_row_rec_.optional_code;
   row_rec_.project_activity_id          := voucher_row_rec_.project_activity_id;
   row_rec_.text                         := voucher_row_rec_.text;
   row_rec_.party_type                   := voucher_row_rec_.party_type;
   row_rec_.party_type_id                := voucher_row_rec_.party_type_id;
   row_rec_.reference_number             := voucher_row_rec_.reference_number;
   row_rec_.reference_serie              := voucher_row_rec_.reference_serie;
   row_rec_.trans_code                   := voucher_row_rec_.trans_code;
   row_rec_.transfer_id                  := voucher_row_rec_.transfer_id;
   row_rec_.corrected                    := voucher_row_rec_.corrected;
   row_rec_.tax_direction                := voucher_row_rec_.tax_direction;
   row_rec_.tax_amount                   := voucher_row_rec_.tax_amount;
   row_rec_.currency_tax_amount          := voucher_row_rec_.currency_tax_amount;
   row_rec_.tax_base_amount              := voucher_row_rec_.tax_base_amount;
   row_rec_.currency_tax_base_amount     := voucher_row_rec_.currency_tax_base_amount;
   row_rec_.currency_rate                := voucher_row_rec_.currency_rate;
   row_rec_.reference_row_no             := voucher_row_rec_.reference_row_no;
   row_rec_.row_group_id                 := voucher_row_rec_.row_group_id;
   row_rec_.parallel_currency_rate       := voucher_row_rec_.parallel_currency_rate;
   row_rec_.parallel_conversion_factor   := voucher_row_rec_.parallel_curr_conv_fac;
   row_rec_.parallel_curr_rate_type      := voucher_row_rec_.parallel_curr_rate_type;
   row_rec_.parallel_curr_tax_amount     := voucher_row_rec_.parallel_curr_tax_amt;
   row_rec_.parallel_curr_tax_base_amount:= voucher_row_rec_.parallel_curr_tax_base_amt;
   row_rec_.parallel_curr_gross_amount   := voucher_row_rec_.parallel_curr_gross_amt;
   row_rec_.deliv_type_id                := voucher_row_rec_.deliv_type_id;
   row_rec_.activate_code                := voucher_row_rec_.activate_code;
   row_rec_.matching_info                := voucher_row_rec_.matching_info;
   
   Create_Cancel_Row___(row_rec_, compfin_rec_);
END Create_Cancel_Row_;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Ready_To_Update_ (
   company_             IN     VARCHAR2,
   voucher_type_        IN     VARCHAR2,
   accounting_year_     IN     NUMBER,
   voucher_no_          IN     NUMBER )
IS
   dummy_      NUMBER;
   CURSOR row_exist IS
      SELECT 1
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_;
BEGIN
   OPEN row_exist;
   FETCH row_exist INTO dummy_;
   IF (row_exist%FOUND) THEN
      UPDATE voucher_row_tab
      SET    update_error = ''
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_;
   END IF;
   CLOSE row_exist;
END Ready_To_Update_;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Drop_Voucher_Rows_ (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER )
IS
BEGIN
   DELETE
   FROM voucher_row_tab
   WHERE company         = company_
   AND   voucher_type    = voucher_type_
   AND   accounting_year = accounting_year_
   AND   voucher_no      = voucher_no_;
   DELETE
   FROM  Internal_Postings_Accrul_Tab
   WHERE company           = company_
   AND   voucher_type      = voucher_type_
   AND   accounting_year   = accounting_year_
   AND   voucher_no        = voucher_no_;
END Drop_Voucher_Rows_;


@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Set_Accounting_Period_ (
   company_           IN VARCHAR2,
   accounting_year_   IN NUMBER,
   voucher_type_      IN VARCHAR2,
   voucher_no_        IN NUMBER,
   accounting_period_ IN NUMBER )
IS
BEGIN
   UPDATE Voucher_Row_Tab
   SET    accounting_period = accounting_period_
   WHERE  company         = company_
   AND    accounting_year = accounting_year_
   AND    voucher_type    = voucher_type_
   AND    voucher_no      = voucher_no_ ;
END Set_Accounting_Period_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------
FUNCTION Account_Curr_Bal_In_Hold (
   company_   IN VARCHAR2,
   account_   IN VARCHAR2) RETURN BOOLEAN
IS
   dummy_           NUMBER;
   curr_codepart_   VARCHAR2(1);
   stmt_            VARCHAR2(2000);
   codepart_column_ VARCHAR2(6);
   TYPE recordType  IS REF CURSOR;
   rec_             recordType;
BEGIN
   curr_codepart_ := Accounting_Code_Parts_API.Get_Codepart_Function (company_, 'CURR');
   IF(curr_codepart_ IS NOT NULL) THEN
      codepart_column_ := 'CODE_' || curr_codepart_;
      stmt_ := 'SELECT 1 
                FROM  Voucher_Row_Tab
                WHERE company = :company
                AND   account = :account
                AND ' || codepart_column_  || ' IS NOT NULL ';

      @ApproveDynamicStatement(2018-02-22,pratlk)
      OPEN rec_ FOR stmt_ USING company_,
                                account_;
      FETCH rec_ INTO dummy_;
      IF ( rec_%NOTFOUND ) THEN
         CLOSE rec_;
         RETURN FALSE;
      ELSE
         CLOSE rec_;
         RETURN TRUE;
      END IF;
   END IF;
   RETURN FALSE;
END Account_Curr_Bal_In_Hold;

@UncheckedAccess
FUNCTION Code_Part_Exist (
   company_   IN VARCHAR2,
   code_part_ IN VARCHAR2,
   codevalue_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   dummy_          NUMBER;
   stmt_           VARCHAR2(2000);
   codepart_       VARCHAR2(20);
   TYPE recordType IS REF CURSOR;
   rec_            recordType;
BEGIN
   IF (code_part_ = 'A') THEN
      codepart_ := 'account';
   ELSIF (code_part_ = 'B') THEN
      codepart_ := 'code_b';
   ELSIF (code_part_ = 'C') THEN
      codepart_ := 'code_c';
   ELSIF (code_part_ = 'D') THEN
      codepart_ := 'code_d';
   ELSIF (code_part_ = 'E') THEN
      codepart_ := 'code_e';
   ELSIF (code_part_ = 'F') THEN
      codepart_ := 'code_f';
   ELSIF (code_part_ = 'G') THEN
      codepart_ := 'code_g';
   ELSIF (code_part_ = 'H') THEN
      codepart_ := 'code_h';
   ELSIF (code_part_ = 'I') THEN
      codepart_ := 'code_i';
   ELSIF (code_part_ = 'J') THEN
      codepart_ := 'code_j';
   END IF;
   stmt_ := '   SELECT 1                                                    '||
            '     FROM Voucher_Row_Tab v, codestring_combination c          '||
            '    WHERE v.posting_combination_id = c.posting_combination_id  '||
            '      AND v.company                = :company_                 '||
            '      AND c.'||    codepart_    ||'= :codevalue_               ';
   @ApproveDynamicStatement(2007-01-24,shsalk)
   OPEN rec_ FOR stmt_ USING company_,
                             codevalue_;
   FETCH rec_ INTO dummy_;
   IF ( rec_%NOTFOUND ) THEN
      CLOSE rec_;
      RETURN FALSE;
   ELSE
      CLOSE rec_;
      RETURN TRUE;
   END IF;
END Code_Part_Exist;


PROCEDURE Project_Delete_Allowed (
   company_            IN VARCHAR2,
   project_id_         IN VARCHAR2 )
IS
   codepart_ VARCHAR2(1);
   exist     EXCEPTION;
BEGIN
   codepart_ := Accounting_Code_parts_API.Get_Codepart_Function ( company_, 'PRACC');
   IF Code_Part_Exist( company_ ,codepart_, project_id_ ) THEN
      RAISE exist;
   END IF;
EXCEPTION
   WHEN exist THEN
      Error_SYS.Appl_General(lu_name_, 'PROJEXIST: Delete is not allowed. Project id :P1 exists in Voucher', project_id_);
END Project_Delete_Allowed;

@SecurityCheck Company.UserAuthorized(company_)
PROCEDURE Drop_Voucher_Row (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER )
IS
BEGIN
   DELETE
   FROM  VOUCHER_ROW_TAB
   WHERE company         = company_
   AND   voucher_type    = voucher_type_
   AND   accounting_year = accounting_year_
   AND   voucher_no      = voucher_no_
   AND   row_no          = row_no_;
END Drop_Voucher_Row;

PROCEDURE Update_Multi_Company_Info (
   company_                      IN VARCHAR2,
   accounting_year_              IN NUMBER,
   voucher_type_                 IN VARCHAR2,
   voucher_no_                   IN NUMBER,
   multi_company_id_             IN VARCHAR2,
   multi_company_acc_year_       IN NUMBER,
   multi_company_voucher_type_   IN VARCHAR2,
   multi_company_voucher_no_     IN NUMBER)
IS
   
BEGIN
   UPDATE Voucher_Row_Tab
      SET multi_company_id           = multi_company_id_,
          multi_company_acc_year     = multi_company_acc_year_,
          multi_company_voucher_type = multi_company_voucher_type_,
          multi_company_voucher_no   = multi_company_voucher_no_      
   WHERE company       = company_
   AND accounting_year = accounting_year_
   AND voucher_type    = voucher_type_
   AND voucher_no      = voucher_no_;  
   
END Update_Multi_Company_Info;

PROCEDURE Interim_Voucher (
   voucher_type_        IN     VARCHAR2,
   voucher_no_          IN     NUMBER,
   accounting_year_     IN     NUMBER,
   company_             IN     VARCHAR2,
   voucher_type_ref_    IN     VARCHAR2,
   voucher_no_ref_      IN     VARCHAR2,
   accounting_year_ref_ IN     NUMBER,
   transfer_id_         IN     VARCHAR2 DEFAULT NULL )
IS
   lu_rec_                       VOUCHER_ROW_TAB%ROWTYPE;
   attr_                         VARCHAR2(2000);
   info_                         VARCHAR2(2000);
   objversion_                   VARCHAR2(2000);
   objid_                        VARCHAR2(100);
   voucher_date_                 DATE; 
   is_base_emu_                  VARCHAR2(5);
   is_third_emu_                 VARCHAR2(5);
   third_currency_debit_amount_  NUMBER;
   third_currency_credit_amount_ NUMBER;
   interim_period_               NUMBER;
   comp_fin_rec_                 COMPANY_FINANCE_API.Public_Rec; 
   
   CURSOR vou_head_info IS
      SELECT accounting_period,
             voucher_date
      FROM   voucher_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_ref_
      AND    accounting_year = accounting_year_ref_
      AND    voucher_no      = voucher_no_ref_
      AND    transfer_id     = transfer_id_;

   CURSOR fetch_info IS
      SELECT *
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_ ;     
      
BEGIN
   OPEN vou_head_info;
   FETCH vou_head_info INTO interim_period_,
                            voucher_date_;
   CLOSE vou_head_info;
   comp_fin_rec_        := Company_Finance_API.Get (company_);                                                 
   is_base_emu_         := Currency_Code_API.Get_Valid_Emu (company_,
                                                            comp_fin_rec_.currency_code,
                                                            voucher_date_);
   IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
      is_third_emu_     := Currency_Code_API.Get_Valid_Emu (company_,
                                                            comp_fin_rec_.parallel_acc_currency,
                                                            voucher_date_);
   ELSE
      is_third_emu_     := 'FALSE';
   END IF;
   OPEN  fetch_info;
   WHILE (TRUE) LOOP
      FETCH fetch_info INTO lu_rec_ ;
      EXIT WHEN fetch_info%NOTFOUND;
      -- new setting for the interim voucher
      lu_rec_.voucher_type    := voucher_type_ref_;
      lu_rec_.voucher_no      := voucher_no_ref_;
      lu_rec_.accounting_year := accounting_year_ref_;      
      lu_rec_.transfer_id     := transfer_id_;
      
      Client_SYS.Clear_Attr(attr_);
      Client_SYS.Add_To_Attr( 'COMPANY', lu_rec_.company, attr_);
      Client_SYS.Add_To_Attr( 'VOUCHER_TYPE',  lu_rec_.voucher_type, attr_);
      Client_SYS.Add_To_Attr( 'ACCOUNTING_YEAR', lu_rec_.accounting_year, attr_);
      Client_SYS.Add_To_Attr( 'ACCOUNTING_PERIOD', interim_period_, attr_);
      Client_SYS.Add_To_Attr( 'VOUCHER_NO', lu_rec_.voucher_no, attr_);
      Client_SYS.Add_To_Attr( 'ROW_NO', lu_rec_.row_no, attr_);
      Client_SYS.Add_To_Attr( 'ACCOUNT', lu_rec_.account, attr_);
      Client_SYS.Add_To_Attr( 'CODE_B', lu_rec_.code_b, attr_);
      Client_SYS.Add_To_Attr( 'CODE_C', lu_rec_.code_c, attr_);
      Client_SYS.Add_To_Attr( 'CODE_D', lu_rec_.code_d, attr_);
      Client_SYS.Add_To_Attr( 'CODE_E', lu_rec_.code_e, attr_);
      Client_SYS.Add_To_Attr( 'CODE_F', lu_rec_.code_f, attr_);
      Client_SYS.Add_To_Attr( 'CODE_G', lu_rec_.code_g, attr_);
      Client_SYS.Add_To_Attr( 'CODE_H', lu_rec_.code_h, attr_);
      Client_SYS.Add_To_Attr( 'CODE_I', lu_rec_.code_i, attr_);
      Client_SYS.Add_To_Attr( 'CODE_J', lu_rec_.code_j, attr_);
      Client_SYS.Add_To_Attr( 'INTERNAL_SEQ_NUMBER', lu_rec_.internal_seq_number, attr_);
      IF (comp_fin_rec_.correction_type = 'REVERSE') THEN
         Client_SYS.Add_To_Attr( 'CURRENCY_DEBET_AMOUNT', lu_rec_.currency_credit_amount, attr_);
         Client_SYS.Add_To_Attr( 'CURRENCY_CREDIT_AMOUNT', lu_rec_.currency_debet_amount, attr_);
         Client_SYS.Add_To_Attr( 'DEBET_AMOUNT', lu_rec_.credit_amount, attr_);
         Client_SYS.Add_To_Attr( 'CREDIT_AMOUNT', lu_rec_.debet_amount, attr_);
         Client_SYS.Add_To_Attr( 'THIRD_CURRENCY_DEBIT_AMOUNT', lu_rec_.third_currency_credit_amount, attr_);
         Client_SYS.Add_To_Attr( 'THIRD_CURRENCY_CREDIT_AMOUNT', lu_rec_.third_currency_debit_amount, attr_);
      ELSE
         Client_SYS.Add_To_Attr( 'CURRENCY_DEBET_AMOUNT', -lu_rec_.currency_debet_amount, attr_);
         Client_SYS.Add_To_Attr( 'CURRENCY_CREDIT_AMOUNT', -lu_rec_.currency_credit_amount, attr_);
         Client_SYS.Add_To_Attr( 'DEBET_AMOUNT', -lu_rec_.debet_amount, attr_);
         Client_SYS.Add_To_Attr( 'CREDIT_AMOUNT', -lu_rec_.credit_amount, attr_);
         Client_SYS.Add_To_Attr( 'THIRD_CURRENCY_DEBIT_AMOUNT', -lu_rec_.third_currency_debit_amount, attr_);
         Client_SYS.Add_To_Attr( 'THIRD_CURRENCY_CREDIT_AMOUNT', -lu_rec_.third_currency_credit_amount, attr_);
      END IF;
      Client_SYS.Add_To_Attr( 'TAX_BASE_AMOUNT', -lu_rec_.tax_base_amount, attr_);
      Client_SYS.Add_To_Attr( 'CURRENCY_TAX_BASE_AMOUNT', -lu_rec_.currency_tax_base_amount, attr_);
      Client_SYS.Add_To_Attr( 'PARALLEL_CURR_TAX_BASE_AMOUNT', -lu_rec_.parallel_curr_tax_base_amount , attr_);
      Client_SYS.Add_To_Attr( 'TAX_DIRECTION_DB', lu_rec_.tax_direction, attr_);
      Client_SYS.Add_To_Attr( 'CURRENCY_CODE', lu_rec_.currency_code, attr_);
      Client_SYS.Add_To_Attr( 'QUANTITY', -lu_rec_.quantity, attr_);
      Client_SYS.Add_To_Attr( 'PROCESS_CODE', lu_rec_.process_code, attr_);
      Client_SYS.Add_To_Attr( 'OPTIONAL_CODE', lu_rec_.optional_code, attr_);
      Client_SYS.Add_To_Attr( 'PROJECT_ACTIVITY_ID', lu_rec_.project_activity_id, attr_);
      Client_SYS.Add_To_Attr( 'TEXT', lu_rec_.text, attr_);
      Client_SYS.Add_To_Attr( 'PARTY_TYPE_ID', lu_rec_.party_type_id, attr_);
      Client_SYS.Add_To_Attr( 'REFERENCE_SERIE', lu_rec_.reference_serie, attr_);
      Client_SYS.Add_To_Attr( 'REFERENCE_NUMBER', lu_rec_.reference_number, attr_);
      Client_SYS.Add_To_Attr( 'REFERENCE_VERSION', lu_rec_.reference_version , attr_);
      Client_SYS.Add_To_Attr( 'PARTY_TYPE', lu_rec_.party_type, attr_);
      Client_SYS.Add_To_Attr( 'TRANS_CODE', 'INTERIM', attr_);
      Client_SYS.Add_To_Attr( 'TRANSFER_ID', lu_rec_.transfer_id , attr_);
      Client_SYS.Add_To_Attr( 'CURRENCY_RATE', lu_rec_.currency_rate , attr_);
      Client_SYS.Add_To_Attr( 'CONVERSION_FACTOR', lu_rec_.conversion_factor , attr_);
      Client_SYS.Add_To_Attr( 'PARALLEL_CURR_RATE_TYPE', lu_rec_.parallel_curr_rate_type , attr_);
      Client_SYS.Add_To_Attr( 'PARALLEL_CURRENCY_RATE', lu_rec_.parallel_currency_rate , attr_);
      Client_SYS.Add_To_Attr( 'PARALLEL_CONVERSION_FACTOR', lu_rec_.parallel_conversion_factor , attr_);
      Client_SYS.Add_To_Attr( 'PARALLEL_CURR_GROSS_AMOUNT', lu_rec_.parallel_curr_gross_amount , attr_);      
      Client_SYS.Add_To_Attr( 'DELIV_TYPE_ID', lu_rec_.deliv_type_id , attr_);
      Client_SYS.Add_To_Attr( 'MATCHING_INFO', lu_rec_.matching_info , attr_);
      IF (Account_API.Is_Ledger_Account (lu_rec_.company,lu_rec_.account) AND lu_rec_.auto_tax_vou_entry = 'TRUE') THEN
         Client_SYS.Add_To_Attr( 'INTERIM_TAX_LEDGER_ACCNT', 'TRUE' , attr_);
      END IF;
      Client_SYS.Add_To_Attr( 'MULTI_COMPANY_ROW_NO', lu_rec_.multi_company_row_no , attr_);
      -- Handling Third currency amount in Interim Voucher. Calculation is done only
      -- if third currency amount is NULL.
      IF (comp_fin_rec_.parallel_acc_currency IS NOT NULL) THEN
         IF ((lu_rec_.debet_amount IS NOT NULL) AND
             (lu_rec_.third_currency_debit_amount IS NULL)) THEN
            third_currency_debit_amount_ := Currency_Amount_API.Calculate_Parallel_Curr_Amount(lu_rec_.company,
                                                             voucher_date_,
                                                             lu_rec_.debet_amount,
                                                             lu_rec_.currency_debet_amount,
                                                             comp_fin_rec_.currency_code,
                                                             lu_rec_.currency_code,
                                                             lu_rec_.parallel_curr_rate_type,
                                                             comp_fin_rec_.parallel_acc_currency,
                                                             comp_fin_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
            third_currency_debit_amount_ := NVL(-third_currency_debit_amount_,0);
            Client_SYS.Add_To_Attr( 'THIRD_CURRENCY_DEBIT_AMOUNT', third_currency_debit_amount_, attr_);
         END IF;
         IF ((lu_rec_.credit_amount IS NOT NULL) AND
             (lu_rec_.third_currency_credit_amount IS NULL)) THEN
            third_currency_credit_amount_ := Currency_Amount_API.Calculate_Parallel_Curr_Amount(lu_rec_.company,
                                                             voucher_date_,
                                                             lu_rec_.credit_amount,
                                                             lu_rec_.currency_credit_amount,
                                                             comp_fin_rec_.currency_code,
                                                             lu_rec_.currency_code,
                                                             lu_rec_.parallel_curr_rate_type,
                                                             comp_fin_rec_.parallel_acc_currency,
                                                             comp_fin_rec_.parallel_base,
                                                             is_base_emu_,
                                                             is_third_emu_);
            third_currency_credit_amount_ := NVL(-third_currency_credit_amount_,0);
            Client_SYS.Add_To_Attr( 'THIRD_CURRENCY_CREDIT_AMOUNT', third_currency_credit_amount_, attr_);
         END IF;
      END IF;
      New__ (info_,
             objid_,
             objversion_,
             attr_,
             'DO');
             
      
      IF (lu_rec_.optional_code IS NOT NULL AND lu_rec_.trans_code NOT IN ('AP1','AP2','AP3','AP4')) THEN
         IF (Statutory_Fee_API.Get_Fee_Type_Db(lu_rec_.company ,lu_rec_.optional_code) != Fee_Type_API.DB_NO_TAX) THEN
      -- Create Tax Items
      
         Tax_Handling_Accrul_Util_API.Reverse_Tax_Item(company_,
                                                        Tax_Source_API.DB_MANUAL_VOUCHER,
                                                        TO_CHAR(accounting_year_),
                                                        voucher_type_,
                                                        TO_CHAR(voucher_no_),
                                                        TO_CHAR(lu_rec_.row_no),
                                                        '*',
                                                        lu_rec_.company,
                                                        Tax_Source_API.DB_MANUAL_VOUCHER,
                                                        TO_CHAR(accounting_year_ref_),
                                                        voucher_type_ref_,
                                                        voucher_no_ref_,
                                                        TO_CHAR(lu_rec_.row_no),
                                                        '*');
      END IF;
      END IF;
            
      -- update reference column of the original voucher ROW and the client have to be refreshed again --
      UPDATE voucher_row_tab
         SET trans_code = 'INTERIM',
             rowversion = SYSDATE
      WHERE  company = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    accounting_year = accounting_year_
      AND    row_no          = lu_rec_.row_no;
   END LOOP;   
   CLOSE fetch_info;
END Interim_Voucher;


PROCEDURE Postings_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2,
   account_    IN    VARCHAR2 )
IS
   postings_   NUMBER;
   CURSOR check_postings IS
      SELECT 1
      FROM   voucher_row_tab
      WHERE  company = company_
      AND    account = account_;
BEGIN
   OPEN check_postings;
   FETCH check_postings INTO postings_;
   IF (check_postings%FOUND) THEN
      result_ := 'TRUE';
   ELSE
      result_ := 'FALSE';
   END IF;
   CLOSE check_postings;
END Postings_In_Voucher_Row;


PROCEDURE Postings_A_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'A' );
END Postings_A_In_Voucher_Row;


PROCEDURE Postings_B_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'B' );
END Postings_B_In_Voucher_Row;


PROCEDURE Postings_C_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'C' );
END Postings_C_In_Voucher_Row;


PROCEDURE Postings_D_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'D' );
END Postings_D_In_Voucher_Row;


PROCEDURE Postings_E_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'E' );
END Postings_E_In_Voucher_Row;


PROCEDURE Postings_F_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'F' );
END Postings_F_In_Voucher_Row;


PROCEDURE Postings_G_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'G' );
END Postings_G_In_Voucher_Row;


PROCEDURE Postings_H_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'H' );
END Postings_H_In_Voucher_Row;


PROCEDURE Postings_I_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'I' );
END Postings_I_In_Voucher_Row;


PROCEDURE Postings_J_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2 )
IS
BEGIN
   Postings_X_In_Voucher_Row (result_, company_, 'J' );
END Postings_J_In_Voucher_Row;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Sum_Currency_Amount (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_type_       IN VARCHAR2,
   voucher_no_         IN NUMBER,
   function_group_     IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER
IS
   sum_amount_          NUMBER;
   CURSOR sum_currency_amount IS
      SELECT SUM(NVL(currency_debet_amount,0) - NVL(currency_credit_amount,0) )
      FROM   accounting_code_part_value_tab a,
             voucher_row_tab v
      WHERE  v.company         = company_
      AND    v.voucher_type    = voucher_type_
      AND    v.accounting_year = accounting_year_
      AND    v.voucher_no      = voucher_no_
      AND    a.company         = v.company
      AND    a.code_part       = 'A'
      AND    a.code_part_value = v.account
      AND    a.stat_account    = 'N';

   CURSOR sum_currency_amount_yr_end IS
      SELECT SUM(NVL(currency_debet_amount,0) - NVL(currency_credit_amount,0) )
      FROM   accounting_code_part_value_tab a,
             voucher_row_tab v
      WHERE  v.company               = company_
      AND    v.voucher_type          = voucher_type_
      AND    v.accounting_year       = accounting_year_
      AND    v.voucher_no            = voucher_no_
      AND    a.company               = v.company
      AND    a.code_part             = 'A'
      AND    a.code_part_value       = v.account
      AND    a.stat_account          = 'N'
      AND    a.logical_account_type != 'O';   

BEGIN
   IF (function_group_ IS NOT NULL AND function_group_ = 'YE') THEN
      OPEN  sum_currency_amount_yr_end;
      FETCH sum_currency_amount_yr_end INTO sum_amount_;
      CLOSE sum_currency_amount_yr_end;
   ELSE
      OPEN  sum_currency_amount;
      FETCH sum_currency_amount INTO sum_amount_;
      CLOSE sum_currency_amount;
   END IF;
   RETURN sum_amount_;
END Sum_Currency_Amount;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Sum_Amount (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_type_       IN VARCHAR2,
   voucher_no_         IN NUMBER,
   function_group_     IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER
IS
   sum_amount_            NUMBER;
   CURSOR get_sum_amount_ IS
      SELECT SUM(NVL(debet_amount,-credit_amount))
      FROM   VOUCHER_ROW_TAB V,
             accounting_code_part_value_tab A
      WHERE  A.company         = V.company
      AND    A.code_part_value = V.account
      AND    V.company         = company_
      AND    V.accounting_year = accounting_year_
      AND    V.voucher_type    = voucher_type_
      AND    V.voucher_no      = voucher_no_
      AND    A.code_part       = 'A'
      AND    A.stat_account    = 'N';

   CURSOR get_sum_amount_yr_end IS
      SELECT SUM(NVL(debet_amount,-credit_amount))
      FROM   VOUCHER_ROW_TAB V,
             accounting_code_part_value_tab A
      WHERE  A.company               = V.company
      AND    A.code_part_value       = V.account
      AND    V.company               = company_
      AND    V.accounting_year       = accounting_year_
      AND    V.voucher_type          = voucher_type_
      AND    V.voucher_no            = voucher_no_
      AND    A.code_part             = 'A'
      AND    A.stat_account          = 'N'
      AND    a.logical_account_type != 'O';
BEGIN
   IF ( function_group_ IS NOT NULL AND function_group_ = 'YE') THEN
      OPEN  get_sum_amount_yr_end;
      FETCH get_sum_amount_yr_end INTO sum_amount_;
      CLOSE get_sum_amount_yr_end;
   ELSE
      OPEN  get_sum_amount_;
      FETCH get_sum_amount_ INTO sum_amount_;
      CLOSE get_sum_amount_;
   END IF;
   RETURN sum_amount_;
END Sum_Amount;


PROCEDURE Validate_Currency_Code (
   currency_rate_       OUT NUMBER,
   decimals_in_amount_  OUT NUMBER,
   decimals_in_rate_    OUT NUMBER,
   conv_factor_         OUT NUMBER,
   company_             IN  VARCHAR2,
   currency_type_       IN  VARCHAR2,
   currency_code_       IN  VARCHAR2,
   voucher_date_        IN  DATE )
IS
   base_curr_code_   VOUCHER_ROW_TAB.currency_code%TYPE;
   base_curr_emu_    VARCHAR2(5);
   inverted_         VARCHAR2(5);
BEGIN
   base_curr_code_ := Company_Finance_API.Get_Currency_Code (company_);
   base_curr_emu_  := Currency_Code_API.Get_Valid_Emu (company_,
                                                       base_curr_code_,
                                                       voucher_date_);
   Currency_Rate_API.Fetch_Currency_Rate_Base(conv_factor_,
                                              currency_rate_,
                                              inverted_,
                                              company_,
                                              currency_code_,
                                              base_curr_code_,
                                              currency_type_,
                                              voucher_date_,
                                              base_curr_emu_);

   decimals_in_amount_ := NVL(Currency_Code_API.Get_Currency_Rounding(company_, currency_code_), 0);
   decimals_in_rate_   := NVL(Currency_Code_API.Get_No_Of_Decimals_In_Rate(company_, currency_code_), 0);
END Validate_Currency_Code;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Max_Row_No (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_type_       IN VARCHAR2,
   voucher_no_         IN NUMBER ) RETURN NUMBER
IS
   row_no_                NUMBER;
   CURSOR get_max_row_no_ IS
      SELECT MAX(row_no)
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_;
BEGIN
   OPEN get_max_row_no_;
   FETCH get_max_row_no_ INTO row_no_;
   IF (get_max_row_no_%FOUND) THEN
      CLOSE get_max_row_no_;
      RETURN(row_no_);
   ELSE
      CLOSE get_max_row_no_;
      RETURN(0);
   END IF;
END Get_Max_Row_No;


--FUNCTION Get_Max_Multi_Company_Row_No (
--   multi_company_id_                 IN VARCHAR2,
--   multi_company_acc_year_    IN NUMBER,
--   multi_company_voucher_type_       IN VARCHAR2,
--   multi_company_voucher_no_         IN NUMBER ) RETURN NUMBER
--IS
--   row_no_                NUMBER;
--   CURSOR get_max_row_no_ IS
--      SELECT NVL(MAX(multi_company_row_no),0)
----      FROM   VOUCHER_ROW_TAB
----      WHERE  multi_company_id              = multi_company_id_
--      AND    multi_company_acc_year        = multi_company_acc_year_
--      AND    multi_company_voucher_type    = multi_company_voucher_type_
--      AND    multi_company_voucher_no      = multi_company_voucher_no_--;
--BEGIN
--   OPEN get_max_row_no_;
--   FETCH get_max_row_no_ INTO row_no_;
--   IF (get_max_row_no_%FOUND) THEN
--      CLOSE get_max_row_no_;
--      RETURN(row_no_);
--   ELSE
--      CLOSE get_max_row_no_;
--      RETURN(0);
--   END IF;
--END Get_Max_Multi_Company_Row_No;

@UncheckedAccess
FUNCTION Check_Trans_Code (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_type_       IN VARCHAR2,
   voucher_no_         IN NUMBER ) RETURN VARCHAR2
IS
   trans_code_ VARCHAR2(100) := 'MANUAL';
   CURSOR get_trans_code IS
      SELECT trans_code
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    trans_code      != 'MANUAL';
BEGIN
   OPEN get_trans_code;
   FETCH get_trans_code INTO trans_code_;
   IF get_trans_code%FOUND THEN
      CLOSE get_trans_code;
      RETURN(trans_code_);
   ELSE
      CLOSE get_trans_code;
      RETURN('MANUAL');
   END IF;
END Check_Trans_Code;


@UncheckedAccess
FUNCTION Is_Code_Part_Value_Used (
   company_                IN VARCHAR2,
   code_part_              IN VARCHAR2,
   code_part_value_        IN VARCHAR2 ) RETURN VARCHAR2
IS
BEGIN
   IF (Code_Part_Exist (company_,
                        code_part_,
                        code_part_value_)) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Is_Code_Part_Value_Used;

@UncheckedAccess
FUNCTION Check_Rows_Exist (
   company_ IN VARCHAR2,
   voucher_type_ IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_ IN NUMBER) RETURN BOOLEAN
IS
   CURSOR get_record IS
      SELECT 1
      FROM  voucher_row_tab
      WHERE company = company_
      AND   voucher_type = voucher_type_
      AND   accounting_year = accounting_year_
      AND   voucher_no = voucher_no_;
   dummy_  NUMBER;
BEGIN
      
   OPEN get_record;
   FETCH get_record INTO dummy_;
   IF get_record%FOUND THEN
      CLOSE get_record;
      RETURN TRUE;
   ELSE
      CLOSE get_record;
      RETURN FALSE;
   END IF;
END Check_Rows_Exist;


PROCEDURE Account_Exist (
  company_          IN    VARCHAR2,
  account_          IN    VARCHAR2 )
IS
BEGIN
   IF (Code_Part_Exist (company_,
                        'A',
                        account_)) THEN
      Error_SYS.Record_General('VoucherRow', 'ACCNTEXISTS: The account :P1 exists in Holding Table', account_);
   END IF;
END Account_Exist;


FUNCTION Fa_Related_Vou_In_Hold (
   company_             IN VARCHAR2,
   code_part_           IN VARCHAR2,
   code_part_value_     IN VARCHAR2,
   acquisition_account_ IN VARCHAR2 ) RETURN BOOLEAN
IS

   voucher_type_ VARCHAR2(30);
BEGIN
   RETURN Fa_Related_Vou_In_Hold(company_,
                                 code_part_,
                                 code_part_value_,
                                 acquisition_account_,
                                 voucher_type_);
END Fa_Related_Vou_In_Hold;

FUNCTION Fa_Related_Vou_In_Hold (
   company_             IN     VARCHAR2,
   code_part_           IN     VARCHAR2,
   code_part_value_     IN     VARCHAR2,
   acquisition_account_ IN     VARCHAR2,
   voucher_type_           OUT VARCHAR2) RETURN BOOLEAN
IS
   lease_contract_connected_  VARCHAR2(5);
   found_           BOOLEAN := FALSE;
   store_original_  VARCHAR2(1);
   CURSOR find_ver IS
      SELECT voucher_no, voucher_type, accounting_year
      FROM VOUCHER_ROW_TAB
      WHERE company   = company_
      AND   account   = acquisition_account_
      AND   DECODE ( code_part_, 'B', code_b,
                                 'C', code_c,
                                 'D', code_d,
                                 'E', code_e,
                                 'F', code_f,
                                 'G', code_g,
                                 'H', code_h,
                                 'I', code_i,
                                 'J', code_j ) = code_part_value_;
   CURSOR store_org (vou_type_ VARCHAR2)IS
      SELECT store_original
      FROM   voucher_type_detail_tab
      WHERE  company      = company_
      AND    voucher_type = vou_type_;
BEGIN
   FOR vou_row_rec_ IN find_ver LOOP
      -- Check whether the voucher is updated  or not.
      IF (Voucher_API.Get_Voucher_Updated_Db (company_ ,
                                              vou_row_rec_.accounting_year,
                                              vou_row_rec_.voucher_type,
                                              vou_row_rec_.voucher_no)='N') THEN
         found_ := TRUE;
         voucher_type_ := vou_row_rec_.voucher_type;
      ELSE
         -- Voucher is Updated but still in hold table
         -- Check for Store Original
         OPEN  store_org (vou_row_rec_.voucher_type);
         FETCH store_org into store_original_;
         CLOSE store_org;
         voucher_type_ := vou_row_rec_.voucher_type;
         IF (store_original_ ='N') THEN
            found_ := TRUE;
         END IF;
      END IF;
      IF (found_) THEN
         IF (lease_contract_connected_ IS NULL) THEN
            $IF Component_Fixass_SYS.INSTALLED $THEN
               lease_contract_connected_  := Leasing_Contract_Info_API.Is_Contract_Connected(company_,code_part_value_);
            $ELSE
               lease_contract_connected_ := 'FALSE';
            $END
         END IF;
         Check_Lease_Recog_Vou___(found_, company_, vou_row_rec_.accounting_year, vou_row_rec_.voucher_type, vou_row_rec_.voucher_no, lease_contract_connected_);
      END IF;
      EXIT WHEN found_ ;
   END LOOP;
   RETURN found_;
END Fa_Related_Vou_In_Hold;


PROCEDURE Validate_Currency_Code_Base (
   currency_rate_      OUT NUMBER,
   decimals_in_amount_ OUT NUMBER,
   decimals_in_rate_   OUT NUMBER,
   conv_factor_        OUT NUMBER,
   company_            IN  VARCHAR2,
   currency_type_      IN  VARCHAR2,
   currency_code_      IN  VARCHAR2,
   voucher_date_       IN  DATE,
   base_currency_code_ IN  VARCHAR2,
   is_base_emu_        IN  VARCHAR2 )
IS
   inverted_         VARCHAR2(5);
BEGIN
   Currency_Rate_API.Fetch_Currency_Rate_Base(conv_factor_,
                                              currency_rate_,
                                              inverted_,
                                              company_,
                                              currency_code_,
                                              base_currency_code_,
                                              currency_type_,
                                              voucher_date_,
                                              is_base_emu_);

   decimals_in_amount_ := NVL(Currency_Code_API.Get_Currency_Rounding (company_, currency_code_), 0);
   decimals_in_rate_   := NVL(Currency_Code_API.Get_No_Of_Decimals_In_Rate (company_, currency_code_), 0);
END Validate_Currency_Code_Base;


@UncheckedAccess
FUNCTION Is_Manual_Added (
   company_             IN VARCHAR2,
   internal_seq_number_ IN NUMBER,
   account_             IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_      VARCHAR2(5);
   CURSOR get_int_manual IS
      SELECT 'TRUE'
      FROM   INTERNAL_POSTINGS_ACCRUL_TAB
      WHERE  company             = company_
      AND    internal_seq_number = internal_seq_number_
      AND    account             = account_;
BEGIN
   OPEN  get_int_manual;
   FETCH get_int_manual INTO dummy_;
   CLOSE get_int_manual;
   RETURN NVL(dummy_,'FALSE');
END Is_Manual_Added;


@UncheckedAccess
FUNCTION Is_Add_Internal (
   company_             IN VARCHAR2,
   internal_seq_number_ IN NUMBER,
   account_             IN VARCHAR2,
   voucher_type_        IN VARCHAR2,
   voucher_no_          IN NUMBER,
   accounting_year_     IN NUMBER ) RETURN VARCHAR2
IS
   CURSOR get_trans_code IS
      SELECT trans_code,
             voucher_date
      FROM   voucher_row_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    accounting_year = accounting_year_
      AND    account         = account_;
   trans_code_    VARCHAR2(100);
   voucher_date_  DATE;
BEGIN
   OPEN get_trans_code;
   FETCH get_trans_code INTO trans_code_,
                             voucher_date_;
   CLOSE get_trans_code;
   IF (trans_code_ = 'PP12' OR trans_code_ = 'PP13') THEN
      RETURN 'FALSE';
   END IF;
   IF (voucher_date_ IS NULL) THEN
      voucher_date_ := Voucher_API.Get_Voucher_Date (company_,
                                                     accounting_year_,
                                                     voucher_type_,
                                                     voucher_no_);
   END IF;
   $IF Component_Intled_SYS.INSTALLED $THEN
      IF ((Is_Manual_Added (company_,
                            internal_seq_number_,
                            account_) = 'FALSE') AND
          (Voucher_Type_API.Get_Use_Manual (company_,
                                            voucher_type_) = 'TRUE') AND
          (Internal_Voucher_Util_Pub_API.Check_If_Manual (company_,
                                                          account_,
                                                          voucher_date_) IS NOT NULL)) THEN
         RETURN 'TRUE';
      END IF;
   $END
   RETURN 'FALSE';
END Is_Add_Internal;


PROCEDURE Tax_Code_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2,
   tax_code_   IN    VARCHAR2 )
IS
   postings_   NUMBER;
   CURSOR check_postings IS
      SELECT 1
      FROM   voucher_row_tab
      WHERE  company       = company_
      AND    optional_code = tax_code_;
BEGIN
   OPEN  check_postings;
   FETCH check_postings INTO postings_;
   IF (check_postings%FOUND) THEN
      result_ := 'TRUE';
   ELSE
      result_ := 'FALSE';
   END IF;
   CLOSE check_postings;
END Tax_Code_In_Voucher_Row;


PROCEDURE Calculate_Net_From_Gross (
   rowrec_               IN OUT VOUCHER_ROW_TAB%ROWTYPE,
   amount_methodx_       IN     VARCHAR2,
   third_currency_codex_ IN     VARCHAR2 DEFAULT NULL,
   is_third_emux_        IN     VARCHAR2 DEFAULT 'FALSE',
   base_currency_codex_  IN     VARCHAR2 DEFAULT NULL,
   is_base_emux_         IN     VARCHAR2 DEFAULT 'FALSE' )
IS
   voucher_date_         DATE;
   amount_method_        VARCHAR2(200);
   base_currency_code_   VARCHAR2(50);
   third_currency_code_  VARCHAR2(50);
   is_base_emu_          VARCHAR2(5);
   is_third_emu_         VARCHAR2(5);   
   comp_fin_rec_         Company_Finance_API.Public_Rec;
   CURSOR vou_head_info IS
      SELECT voucher_date, amount_method
      FROM   voucher_tab
      WHERE  company         = rowrec_.company
      AND    accounting_year = rowrec_.accounting_year
      AND    voucher_no      = rowrec_.voucher_no
      AND    voucher_type    = rowrec_.voucher_type ;
BEGIN
   IF (amount_methodx_ IS NULL OR
       rowrec_.voucher_date IS NULL) THEN
      OPEN  vou_head_info;
      FETCH vou_head_info INTO voucher_date_,
                               amount_method_;
      CLOSE vou_head_info;
   ELSE
      voucher_date_  := rowrec_.voucher_date;
      amount_method_ := amount_methodx_;
   END IF;
   IF (amount_method_ IN ('GROSS')) THEN
      IF (rowrec_.optional_code IS NOT NULL AND (rowrec_.tax_amount IS NOT NULL OR rowrec_.parallel_curr_tax_amount IS NOT NULL)) THEN
         rowrec_.currency_gross_amount     := nvl(rowrec_.currency_debet_amount,-rowrec_.currency_credit_amount);
         rowrec_.gross_amount              := nvl(rowrec_.debet_amount,-rowrec_.credit_amount);
         rowrec_.parallel_curr_gross_amount := nvl(rowrec_.third_currency_debit_amount,-rowrec_.third_currency_credit_amount);
         IF ((rowrec_.debet_amount IS NOT NULL) OR (rowrec_.third_currency_debit_amount IS NOT NULL)) THEN
            rowrec_.currency_debet_amount  := rowrec_.currency_debet_amount - rowrec_.currency_tax_amount;
            rowrec_.debet_amount           := rowrec_.debet_amount - rowrec_.tax_amount;
            rowrec_.third_currency_debit_amount   := rowrec_.third_currency_debit_amount - rowrec_.parallel_curr_tax_amount;
         ELSIF ((rowrec_.credit_amount IS NOT NULL) OR (rowrec_.third_currency_credit_amount IS NOT NULL) ) THEN
            rowrec_.currency_credit_amount := rowrec_.currency_credit_amount - (rowrec_.currency_tax_amount * -1);
            rowrec_.credit_amount          := rowrec_.credit_amount - (rowrec_.tax_amount * -1);
            rowrec_.third_currency_credit_amount  := rowrec_.third_currency_credit_amount - (rowrec_.parallel_curr_tax_amount * -1);
         END IF;
         comp_fin_rec_ := Company_Finance_API.Get(rowrec_.company);
         IF (third_currency_codex_ IS NOT NULL) THEN
            third_currency_code_ := third_currency_codex_;    
            is_third_emu_        := is_third_emux_;           
         ELSE                                                 
            third_currency_code_ := comp_fin_rec_.parallel_acc_currency; 
         END IF;
        
         IF (third_currency_code_ IS NOT NULL) THEN
            IF (base_currency_codex_ IS NOT NULL) THEN
               base_currency_code_ := base_currency_codex_;   
               is_base_emu_        := is_base_emux_;          
            ELSE                                              
               base_currency_code_ := comp_fin_rec_.currency_code;
               is_base_emu_        := Currency_Code_API.Get_Valid_Emu (rowrec_.company,
                                                                       base_currency_code_,
                                                                       voucher_date_);
            END IF;
            IF (third_currency_codex_ IS NULL) THEN           
               is_third_emu_       := Currency_Code_API.Get_Valid_Emu (rowrec_.company,
                                                                       third_currency_code_,
                                                                       voucher_date_);
            END IF;
            IF ((rowrec_.debet_amount IS NOT NULL) AND (rowrec_.third_currency_debit_amount IS NULL)) THEN
               rowrec_.third_currency_debit_amount := Currency_Amount_API.Calculate_Parallel_Curr_Amount(rowrec_.company,
                                                                voucher_date_,
                                                                rowrec_.debet_amount,
                                                                rowrec_.currency_debet_amount,
                                                                base_currency_code_,
                                                                rowrec_.currency_code,
                                                                rowrec_.parallel_curr_rate_type,                                                                
                                                                third_currency_code_,
                                                                comp_fin_rec_.parallel_base,
                                                                is_base_emu_,
                                                                is_third_emu_);                                                                
            END IF;

            IF ((rowrec_.credit_amount IS NOT NULL) AND (rowrec_.third_currency_credit_amount IS NULL)) THEN
               rowrec_.third_currency_credit_amount := Currency_Amount_API.Calculate_Parallel_Curr_Amount(rowrec_.company,
                                                                voucher_date_,
                                                                rowrec_.credit_amount,
                                                                rowrec_.currency_credit_amount,
                                                                base_currency_code_,
                                                                rowrec_.currency_code,
                                                                rowrec_.parallel_curr_rate_type,                                                                
                                                                third_currency_code_,
                                                                comp_fin_rec_.parallel_base,
                                                                is_base_emu_,
                                                                is_third_emu_);
            END IF;
         END IF;
      END IF;
   END IF;
END Calculate_Net_From_Gross;


PROCEDURE Calculate_Net_From_Gross (
   rowrec_         IN OUT VOUCHER_ROW_TAB%ROWTYPE )
IS
   amount_method_        VARCHAR2(200);
BEGIN
   amount_method_ := Voucher_API.Get_Amount_Method_Db(rowrec_.company,
                                                      rowrec_.accounting_year,
                                                      rowrec_.voucher_type,
                                                      rowrec_.voucher_no);
   Calculate_Net_From_Gross(rowrec_,
                            amount_method_ );
END Calculate_Net_From_Gross;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Is_Multi_Company_Voucher_Row(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER ) RETURN VARCHAR2
IS
   temp_ VOUCHER_ROW_TAB.multi_company_id%TYPE;
   CURSOR get_attr IS
      SELECT multi_company_id
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    row_no          = row_no_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   IF (temp_ IS NOT NULL) THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;
END Is_Multi_Company_Voucher_Row;


PROCEDURE Modify_Row (
   attr_            IN OUT VARCHAR2,
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER )
IS
   info_               VARCHAR2(2000);
   objid_              voucher_row.objid%TYPE;
   objversion_         voucher_row.objversion%TYPE;
BEGIN
   Get_Id_Version_By_Keys___(objid_, objversion_, company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   IF (objid_ IS NOT NULL AND objversion_ IS NOT NULL) THEN
      Modify__( info_, objid_, objversion_, attr_, 'DO');
   END IF;
END Modify_Row;


PROCEDURE New_Row (
   attr_ IN OUT VARCHAR2 )
IS
   info_       VARCHAR2(2000);
   objid_      voucher_row.objid%TYPE;
   objversion_ voucher_row.objversion%TYPE;
BEGIN
   New__( info_, objid_, objversion_, attr_, 'DO');
END New_Row;


PROCEDURE Remove_Row(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   remove_all_      IN VARCHAR2 DEFAULT 'FALSE' )
IS
   voucher_rec_     VOUCHER_ROW_TAB%ROWTYPE;
   allocated_       VARCHAR2(1);
   CURSOR get_rec_ IS 
      SELECT *
      FROM VOUCHER_ROW_TAB
      WHERE company       = company_
      AND voucher_type    = voucher_type_
      AND accounting_year = accounting_year_
      AND voucher_no      = voucher_no_
      AND row_no          = row_no_;
BEGIN
   IF (remove_all_ = 'TRUE') THEN
      OPEN  get_rec_;
      FETCH get_rec_ INTO voucher_rec_;
      CLOSE get_rec_;

      -- Removing Object Connection and Cost Info
      IF (NVL(voucher_rec_.project_activity_id,0) != 0) THEN
         Remove_Object_Connection___(voucher_rec_);
      END IF;

      -- check for any period allocation
      allocated_ := Period_Allocation_API.Any_Allocation( voucher_rec_.company,
                                                    	    voucher_rec_.voucher_type,
                                                    	    voucher_rec_.voucher_no,
                                                    	    voucher_rec_.row_no,
                                                    	    voucher_rec_.accounting_year);
      IF (allocated_ = 'Y') THEN
         Error_SYS.Record_General(lu_name_, 'EXISTINPERALLOC: Can not change Voucher row that exists in Period Allocation');
      END IF;
      -- Remove Tax Transactions
      Delete_Tax_Transaction___(voucher_rec_);

      -- Remove internal manual postings and internal voucher rows.
      Delete_Internal_Rows___ (voucher_rec_.company,
                              voucher_rec_.voucher_type,
                              voucher_rec_.accounting_year,
                              voucher_rec_.voucher_no,
                              voucher_rec_.account,
                              voucher_rec_.row_no);  
   END IF;
   Drop_Voucher_Row (company_,
                     voucher_type_,
                     accounting_year_,
                     voucher_no_,
                     row_no_);
END Remove_Row;


@UncheckedAccess
FUNCTION Is_Voucher_Exist (
   company_    IN VARCHAR2,
   code_part_  IN VARCHAR2,
   code_value_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   CURSOR get_voucher IS
       SELECT 1
       FROM voucher_row_tab
       WHERE company = company_
       AND DECODE (code_part_, 'A' , account,
                               'B' , code_b,
                               'C' , code_c,
                               'D' , code_d,
                               'E' , code_e,
                               'F' , code_f,
                               'G' , code_g,
                               'H' , code_h,
                               'I' , code_i,
                               'J' , code_j  ) = code_value_;
   vou_rec_   get_voucher%ROWTYPE;
BEGIN
   OPEN get_voucher ;
   FETCH get_voucher INTO vou_rec_;
   IF (get_voucher%FOUND) THEN
      CLOSE get_voucher;
      RETURN 'TRUE';
   ELSE
      CLOSE get_voucher;
      RETURN 'FALSE';
   END IF;
END Is_Voucher_Exist;


PROCEDURE Check_Code_Str_Fa (
   company_        IN VARCHAR2,
   object_id_      IN VARCHAR2,
   fa_code_part_   IN VARCHAR2,
   codestring_rec_ IN Accounting_Codestr_API.CodestrRec)
IS
   TYPE FaCodestrRec IS RECORD (
      code_a        VARCHAR2(20),
      code_b        VARCHAR2(20),
      code_c        VARCHAR2(20),
      code_d        VARCHAR2(20),
      code_e        VARCHAR2(20),
      code_f        VARCHAR2(20),
      code_g        VARCHAR2(20),
      code_h        VARCHAR2(20),
      code_i        VARCHAR2(20),
      code_j        VARCHAR2(20));
   fa_codestring_rec_      FaCodestrRec;
   account_                VARCHAR2(20);
   multiple_code_string_   VARCHAR2(5);
   ill_code_str_           BOOLEAN := FALSE;
   CURSOR fa_codepart IS
      SELECT account code_a,
             code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j
      FROM   voucher_row_tab
      WHERE  company       = company_
      AND    account       = account_
      AND    object_id     = object_id_
      AND    object_id     IS NOT NULL;
BEGIN
   account_   := codestring_rec_.code_a; 
   multiple_code_string_ := 'FALSE';
   $IF Component_Fixass_SYS.INSTALLED $THEN
      multiple_code_string_ := Fa_Company_API.Get_Multiple_Code_String_Db(company_);   
   $END                                  
   OPEN fa_codepart;
   FETCH fa_codepart INTO fa_codestring_rec_;
   IF fa_codepart%FOUND THEN
      IF ( codestring_rec_.code_a <> fa_codestring_rec_.code_a ) THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_b,' ') <> NVL(fa_codestring_rec_.code_b,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_c,' ') <> NVL(fa_codestring_rec_.code_c,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_d,' ') <> NVL(fa_codestring_rec_.code_d,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_e,' ') <> NVL(fa_codestring_rec_.code_e,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_f,' ') <> NVL(fa_codestring_rec_.code_f,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_g,' ') <> NVL(fa_codestring_rec_.code_g,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_h,' ') <> NVL(fa_codestring_rec_.code_h,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_i,' ') <> NVL(fa_codestring_rec_.code_i,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      ELSIF ( NVL(codestring_rec_.code_j,' ') <> NVL(fa_codestring_rec_.code_j,' ') ) AND  multiple_code_string_ = 'FALSE' THEN
         ill_code_str_ := TRUE;
      END IF;
   END IF;
   CLOSE fa_codepart;
   IF (ill_code_str_) THEN
      Error_SYS.Appl_General(lu_name_,
       'ILLFACODESTR2: Object :P1 has existing voucher rows (in the hold table)with a code string that differs from the code string specified',
       object_id_ );
   END IF;
END Check_Code_Str_Fa;


PROCEDURE Check_Project_Used (
   company_                IN VARCHAR2,
   code_part_              IN VARCHAR2,
   code_part_value_        IN VARCHAR2,
   is_rollback_            IN VARCHAR2 DEFAULT NULL)
IS
   code_part2_ VARCHAR2(10);
   CURSOR chk_prj_exist IS
      SELECT 1
      FROM   voucher_tab v, voucher_row_tab vr
      WHERE  v.company           = company_
      AND    v.company           = vr.company
      AND    v.accounting_year   = vr.accounting_year
      AND    v.accounting_period = vr.accounting_period
      AND    v.voucher_no        = vr.voucher_no
      AND    v.voucher_type      = vr.voucher_type
      AND    v.voucher_updated   = 'N'
      AND    DECODE (code_part2_, 'A' , account,
                                 'B' , code_b,
                                 'C' , code_c,
                                 'D' , code_d,
                                 'E' , code_e,
                                 'F' , code_f,
                                 'G' , code_g,
                                 'H' , code_h,
                                 'I' , code_i,
                                 'J' , code_j ) = code_part_value_;
   dummy_   NUMBER;
BEGIN
   IF (code_part_ IS NULL) THEN
      code_part2_ := Accounting_Code_Parts_API.Get_Codepart_Function(company_,'PRACC');
   ELSE
      code_part2_ := code_part_;
   END IF;
   
   OPEN chk_prj_exist;
   FETCH chk_prj_exist INTO dummy_;
   IF (chk_prj_exist%FOUND) THEN
      CLOSE chk_prj_exist;
      IF (is_rollback_ = 'rollback') THEN 
         Error_SYS.Record_General('VoucherRow', 'PRJINHOLDTABRB: There are vouchers in the hold table related to this project. Update General Ledger before rollback operation.');
      ELSE
         Error_SYS.Record_General('VoucherRow', 'PRJINHOLDTAB: There are vouchers in the hold table related to this project. Update General Ledger before completing the project.');
      END IF;
   END IF;
   CLOSE chk_prj_exist;
END Check_Project_Used;


PROCEDURE Check_Sub_Project_Used (
   company_                IN VARCHAR2,
   code_part_              IN VARCHAR2,
   code_part_value_        IN VARCHAR2,
   sub_project_id_         IN VARCHAR2,
   is_rollback_            IN VARCHAR2 DEFAULT NULL)
IS
   $IF Component_Proj_SYS.INSTALLED $THEN 
      CURSOR chk_prj_exist IS
         SELECT 1
         FROM   voucher_tab v, voucher_row_tab vr
         WHERE  v.company           = company_
         AND    v.company           = vr.company
         AND    v.accounting_year   = vr.accounting_year
         AND    v.voucher_no        = vr.voucher_no
         AND    v.voucher_type      = vr.voucher_type
         AND    v.voucher_updated   = 'N'
         AND    DECODE (code_part_, 'A' , account,
                                    'B' , code_b,
                                    'C' , code_c,
                                    'D' , code_d,
                                    'E' , code_e,
                                    'F' , code_f,
                                    'G' , code_g,
                                    'H' , code_h,
                                    'I' , code_i,
                                    'J' , code_j ) = code_part_value_
         AND    vr.project_activity_id IN (SELECT  a.activity_seq
                                   FROM     ACTIVITY_TAB a
                                   WHERE    a.project_id = code_part_value_
                                   AND sub_project_id IN (SELECT s.sub_project_id 
                                                          FROM sub_project_tab s
                                                          START WITH s.sub_project_id = sub_project_id_ AND s.project_id = code_part_value_
                                                          CONNECT BY s.parent_sub_project_id = PRIOR s.sub_project_id AND s.project_id = code_part_value_));
      dummy_   NUMBER;
   $END
BEGIN
   $IF Component_Proj_SYS.INSTALLED $THEN 
      OPEN chk_prj_exist;
      FETCH chk_prj_exist INTO dummy_;
      IF (chk_prj_exist%FOUND) THEN
         CLOSE chk_prj_exist;
         IF (is_rollback_ = 'rollback') THEN 
            Error_SYS.Record_General('VoucherRow', 'SUBPRJINHOLDTABRB: There are vouchers in the GL hold table related to this project. Update General Ledger before rollback operation.');
         ELSE
            Error_SYS.Record_General('VoucherRow', 'SUBPRJINHOLDTAB: There are vouchers in the GL hold table related to this project. Update General Ledger before completing the sub project');
         END IF;
      END IF;
      CLOSE chk_prj_exist;
   $ELSE 
      NULL;
   $END
END Check_Sub_Project_Used;


PROCEDURE Calculate_Cost_And_Progress (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER )
IS
   activity_info_tab_         Public_Declarations_API.PROJ_Project_Conn_Cost_Tab;
   activity_revenue_info_tab_ Public_Declarations_API.PROJ_Project_Conn_Revenue_Tab;
   attributes_                Public_Declarations_API.PROJ_Project_Conn_Attr_Type;
BEGIN
   $IF (Component_Proj_SYS.INSTALLED) $THEN
   Refresh_Project_Connection (activity_info_tab_         => activity_info_tab_,
                               activity_revenue_info_tab_ => activity_revenue_info_tab_,
                               attributes_                => attributes_,
                               activity_seq_              => NULL,
                               keyref1_                   => company_,
                               keyref2_                   => voucher_type_,
                               keyref3_                   => TO_CHAR(accounting_year_),
                               keyref4_                   => TO_CHAR(voucher_no_),
                               keyref5_                   => TO_CHAR(row_no_),
                               keyref6_                   => '*',
                               refresh_old_data_          => 'FALSE');
   $ELSE 
      NULL;
   $END
END Calculate_Cost_And_Progress;

   
--------------------------------------------------------------------------------------
--Note: Refresh_Project_Connection
--Note: Note that this method is directly called from Project_Conn_Refresh_Util_API.Refresh_Project_Connection___ method in PROJ. 
--Note: In all other places the method Refresh_Project_Connection is called from Calculate_Cost_And_Progress 
--Note: Refresh_Project_Connection is called to report cost to the project side.
--------------------------------------------------------------------------------------
PROCEDURE Refresh_Project_Connection (
   activity_info_tab_          IN OUT NOCOPY Public_Declarations_API.PROJ_Project_Conn_Cost_Tab,
   activity_revenue_info_tab_  IN OUT NOCOPY Public_Declarations_API.PROJ_Project_Conn_Revenue_Tab,
   attributes_                 IN OUT NOCOPY Public_Declarations_API.PROJ_Project_Conn_Attr_Type,
   activity_seq_               IN     NUMBER,
   keyref1_                    IN     VARCHAR2,
   keyref2_                    IN     VARCHAR2,
   keyref3_                    IN     VARCHAR2,
   keyref4_                    IN     VARCHAR2,
   keyref5_                    IN     VARCHAR2,
   keyref6_                    IN     VARCHAR2,
   refresh_old_data_           IN     VARCHAR2 DEFAULT 'FALSE' )
IS
   company_                           VARCHAR2(20) := keyref1_;
   voucher_type_                      VARCHAR2(20) := keyref2_;
   accounting_year_                   NUMBER       := TO_NUMBER(keyref3_);
   voucher_no_                        NUMBER       := TO_NUMBER(keyref4_);
   row_no_                            NUMBER       := TO_NUMBER(keyref5_);
   count_                             PLS_INTEGER;
   countr_                            PLS_INTEGER;
   rec_                               voucher_row_tab%ROWTYPE;
   project_cost_element_              VARCHAR2(100);
   code_string_                       VARCHAR2(2000);    
   exclude_proj_followup_             VARCHAR2(5);   
   followup_element_type_             VARCHAR2(20);
   used_cost_amount_                  NUMBER;
   posted_revenue_amount_             NUMBER;
   used_transaction_amount_           NUMBER;
   used_cost_transaction_amount_      NUMBER;
   posted_rev_transaction_amount_     NUMBER;
   transaction_currency_code_         VARCHAR2(3);
   used_cost_amount_temp_             NUMBER;
BEGIN
   rec_                    := Get_Object_By_Keys___(company_, voucher_type_, accounting_year_, voucher_no_, row_no_);
   exclude_proj_followup_  := NVL(Account_API.Get_Exclude_Proj_Followup (company_, rec_.account),'FALSE');
   IF (exclude_proj_followup_ = 'FALSE') THEN      
      Get_Activity_Info (used_cost_amount_temp_, used_transaction_amount_, rec_ );
      transaction_currency_code_                                    := rec_.currency_code;
      --if transaction amount is zero replace it with base amount
      IF (used_transaction_amount_ = 0 AND used_cost_amount_temp_ != 0) THEN
         used_transaction_amount_                                   := used_cost_amount_temp_;  
         transaction_currency_code_                                 := Company_Finance_API.Get_Currency_Code (company_);
      END IF;
      -- Here we send client value of Voucher State as it does in other object connections
      -- eventhough it is not a good practice since decoding of server value is not supported
      -- by the PROJECT_CONNECTIONS_SUMMARY View in PROJ due to performance reasons.
      project_cost_element_                                         := Cost_Element_To_Account_API.Get_Project_Follow_Up_Element (company_, 
                                                                                                                                  rec_.account, rec_.code_b, rec_.code_c, rec_.code_d,
                                                                                                                                  rec_.code_e,  rec_.code_f, rec_.code_g, rec_.code_h, 
                                                                                                                                  rec_.code_i, rec_.code_j, 
                                                                                                                                  rec_.voucher_date, 'TRUE', 
                                                                                                                                  default_element_type_ => 'BOTH');
      followup_element_type_                                        := Project_Cost_Element_API.Get_Element_Type_Db (company_, project_cost_element_);
      IF (followup_element_type_ = 'COST') THEN
         used_cost_transaction_amount_                              := used_transaction_amount_;
         used_cost_amount_                                          := used_cost_amount_temp_;
      ELSE
         posted_revenue_amount_                                     := - used_cost_amount_temp_;
         posted_rev_transaction_amount_                             := - used_transaction_amount_;
      END IF;      

      code_string_                                                  := Get_Codestring___ (rec_);
      count_                                                        := activity_info_tab_.COUNT;
      countr_                                                       := activity_revenue_info_tab_.COUNT;
      IF ((NVL(used_cost_transaction_amount_, 0) != 0) OR (NVL(used_cost_amount_, 0) != 0)) THEN
      activity_info_tab_(count_).control_category                   := project_cost_element_;
      activity_info_tab_(count_).used                               := used_cost_amount_;
      activity_info_tab_(count_).used_transaction                   := used_cost_transaction_amount_;
      activity_info_tab_(count_).transaction_currency_code          := transaction_currency_code_;
      END IF;
      IF ((NVL(posted_revenue_amount_, 0) != 0) OR (NVL(posted_rev_transaction_amount_, 0) != 0)) THEN
      activity_revenue_info_tab_(countr_).control_category          := project_cost_element_;
      activity_revenue_info_tab_(countr_).posted_revenue            := posted_revenue_amount_;
      activity_revenue_info_tab_(countr_).posted_transaction        := posted_rev_transaction_amount_;
      activity_revenue_info_tab_(countr_).transaction_currency_code := transaction_currency_code_;
      END IF; 
      attributes_.codestring                                        := code_string_;
      attributes_.last_transaction_date                             := rec_.voucher_date;

      IF (refresh_old_data_ = 'FALSE') THEN
         $IF Component_Proj_SYS.INSTALLED $THEN
         Project_Connection_Util_API.Refresh_Connection (proj_lu_name_              => 'VR',
                                                         activity_seq_              => rec_.project_activity_id,
                                                         keyref1_                   => keyref1_,
                                                         keyref2_                   => keyref2_,
                                                         keyref3_                   => keyref3_,
                                                         keyref4_                   => keyref4_,
                                                         keyref5_                   => keyref5_,
                                                         keyref6_                   => keyref6_,
                                                         object_description_        => 'VoucherRow',
                                                         activity_info_tab_         => activity_info_tab_,
                                                         activity_revenue_info_tab_ => activity_revenue_info_tab_,
                                                         attributes_                => attributes_);
         $ELSE
         NULL;
         $END         

      END IF;
   END IF;   
END Refresh_Project_Connection;


PROCEDURE Create_Object_Connection (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER )
IS   
   CURSOR getvourow IS
      SELECT *
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    project_id      IS NOT NULL
      AND    NVL(project_activity_id,0) != 0;
 
   function_group_   Voucher_Tab.function_group%TYPE;
BEGIN
   function_group_ := Voucher_API.Get_Function_Group(company_,accounting_year_,voucher_type_,voucher_no_);
   FOR row_ IN getvourow LOOP
      -- For N and CB vouchers connections should be done if trans_code is 'MANUAL'. 
      -- i.e. When it's a direct cash payment. Otherwise ignore it.
      IF (function_group_ NOT IN ('N','CB') OR (function_group_ IN ('N','CB')AND row_.trans_code = 'MANUAL')) THEN         
         Create_Object_Connection___(row_);
      END IF;
   END LOOP;    
END Create_Object_Connection;


PROCEDURE Create_Object_Connection (
   err_msg_             OUT VARCHAR2,
   project_activity_id_ OUT NUMBER,
   company_             IN  VARCHAR2,
   voucher_type_        IN  VARCHAR2,
   accounting_year_     IN  NUMBER,
   voucher_no_          IN  NUMBER )
IS
   CURSOR getvourow IS
      SELECT *
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    project_id      IS NOT NULL
      AND    NVL(project_activity_id,0) != 0;
   
   vourow_rec_       voucher_row_tab%ROWTYPE;
   function_group_   Voucher_Tab.function_group%TYPE;
BEGIN
   function_group_ := Voucher_API.Get_Function_Group(company_,accounting_year_,voucher_type_,voucher_no_);
   FOR row_ IN getvourow LOOP
      -- For N and CB vouchers connections should be done if trans_code is 'MANUAL'. 
      -- i.e. When it's a direct cash payment. Otherwise ignore it.
      IF (function_group_ NOT IN ('N','CB') OR (function_group_ IN ('N','CB')AND row_.trans_code = 'MANUAL')) THEN 
         Create_Object_Connection___(row_);
      END IF;      
   END LOOP;
EXCEPTION
   WHEN OTHERS THEN     
      project_activity_id_ := vourow_rec_.project_activity_id;
      err_msg_             := SQLERRM;     
     
END Create_Object_Connection; 


PROCEDURE Create_Object_Connection(
   company_              IN VARCHAR2,
   voucher_type_         IN VARCHAR2,
   accounting_year_      IN NUMBER,
   voucher_no_           IN NUMBER,
   row_no_               IN NUMBER,
   account_              IN VARCHAR2,
   debet_amount_         IN NUMBER,
   credit_amount_        IN NUMBER,
   text_                 IN VARCHAR2,
   trans_code_           IN VARCHAR2,
   project_activity_id_  IN NUMBER )
IS
BEGIN
   Create_Object_Connection_(company_,
                             voucher_type_,
                             accounting_year_,
                             voucher_no_,
                             row_no_,
                             account_,
                             debet_amount_,
                             credit_amount_,
                             text_,
                             trans_code_,
                             project_activity_id_);
END Create_Object_Connection;


PROCEDURE Remove_Object_Connection (
   company_             IN VARCHAR2,
   voucher_type_        IN VARCHAR2,
   accounting_year_     IN NUMBER,
   voucher_no_          IN NUMBER,
   row_no_              IN NUMBER,
   project_activity_id_ IN NUMBER )
IS
   remrec_ VOUCHER_ROW_TAB%ROWTYPE;
BEGIN
   remrec_.company             := company_;
   remrec_.voucher_type        := voucher_type_;
   remrec_.accounting_year     := accounting_year_;
   remrec_.voucher_no          := voucher_no_;
   remrec_.row_no              := row_no_;
   remrec_.project_activity_id := project_activity_id_;
   Remove_Object_Connection___(remrec_);
END Remove_Object_Connection;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Amount_For_Account (
   company_              IN VARCHAR2,
   internal_seq_number_  IN NUMBER,
   account_              IN VARCHAR2 ) RETURN NUMBER
IS
   amount_                  NUMBER;
   CURSOR get_vou_amount IS
      SELECT NVL(debet_amount, credit_amount ) amount
      FROM   Voucher_Row_Tab
      WHERE  company              = company_
      AND    internal_seq_number  = internal_seq_number_
      AND    account              = account_;
BEGIN
   OPEN  get_vou_amount;
   FETCH get_vou_amount INTO amount_;
   CLOSE get_vou_amount;
   RETURN NVL(amount_, 0);
END Get_Amount_For_Account;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Fetch_Vou_Row_Id (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   accounting_year_ IN NUMBER,
   invoice_id_      IN NUMBER,
   inv_item_id_     IN NUMBER,
   inv_row_id_      IN NUMBER ) RETURN NUMBER
IS
   CURSOR get_inv_row_info IS
      SELECT row_no, inv_acc_row_id
      FROM   Voucher_Row_Tab
      WHERE  company         = company_
      AND    voucher_no      = voucher_no_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_;

   temp_invoice_id_ NUMBER;
   temp_item_id_    NUMBER;
   temp_row_id_     NUMBER;
BEGIN
   FOR rec_ IN get_inv_row_info LOOP
      temp_invoice_id_ := Client_SYS.Get_Item_Value_To_Number('INVOICE_ID', rec_.inv_acc_row_id, lu_name_);
      temp_item_id_    := Client_SYS.Get_Item_Value_To_Number('ITEM_ID', rec_.inv_acc_row_id, lu_name_);
      temp_row_id_     := Client_SYS.Get_Item_Value_To_Number('ROW_ID', rec_.inv_acc_row_id, lu_name_);
      IF (temp_invoice_id_ = invoice_id_ AND 
         temp_item_id_    = inv_item_id_ AND
         temp_row_id_     = inv_row_id_) THEN
         RETURN rec_.row_no;
      END IF;
   END LOOP;
   RETURN 0;
END Fetch_Vou_Row_Id;

FUNCTION Get_Inv_Id_From_Inv_Acc_Row (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   accounting_year_ IN NUMBER,
   row_no_          IN NUMBER
   ) RETURN NUMBER
IS
   CURSOR get_inv_row_info IS
      SELECT inv_acc_row_id
      FROM   voucher_row_tab
      WHERE  company         = company_
      AND    voucher_no      = voucher_no_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    row_no          = row_no_
      AND    inv_acc_row_id IS NOT NULL;

   invoice_id_      NUMBER;
   inv_acc_row_id_  voucher_row_tab.inv_acc_row_id%TYPE;
BEGIN
   OPEN get_inv_row_info;
   FETCH get_inv_row_info INTO inv_acc_row_id_;
   IF (get_inv_row_info%FOUND) THEN
      invoice_id_ := Client_SYS.Get_Item_Value_To_Number('INVOICE_ID', inv_acc_row_id_, lu_name_);
   END IF;
   CLOSE get_inv_row_info;
   RETURN invoice_id_;
END Get_Inv_Id_From_Inv_Acc_Row;

@UncheckedAccess
FUNCTION Get_Row (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER ) RETURN VOUCHER_ROW_TAB%ROWTYPE
IS
   rec_   VOUCHER_ROW_TAB%ROWTYPE;          
BEGIN
   IF (Company_Finance_API.Is_User_Authorized(company_)) THEN
      rec_ := Get_Object_By_Keys___(company_,
                                    voucher_type_,
                                    accounting_year_,
                                    voucher_no_,
                                    row_no_);
   END IF;
   RETURN rec_;                              
END Get_Row;   


PROCEDURE Internal_Manual_Postings (
   newrec_         IN VOUCHER_ROW_TAB%ROWTYPE,
   is_insert_      IN BOOLEAN DEFAULT FALSE,
   from_pa_        IN BOOLEAN DEFAULT FALSE   )
IS
BEGIN
   Internal_Manual_Postings___(newrec_, is_insert_, from_pa_);
END Internal_Manual_Postings;   


@UncheckedAccess
FUNCTION Get_Pca_Ext_Project (
   company_        IN VARCHAR2) RETURN VARCHAR2
IS
   ext_proj_       VARCHAR2(5) := 'FALSE';
BEGIN
   $IF Component_Percos_SYS.INSTALLED $THEN
      ext_proj_ := Company_Cost_Alloc_Info_API.Get_Pca_Ext_Project(company_); 
   $END
   RETURN ext_proj_;
END Get_Pca_Ext_Project;


@UncheckedAccess
FUNCTION Not_Updated_Code_Part_Exist (
   company_        IN VARCHAR2,
   code_part_      IN VARCHAR2,
   codevalue_      IN VARCHAR2 ) RETURN VARCHAR2
IS
   dummy_          NUMBER;
   CURSOR Code_Control IS
      SELECT 1
      FROM   voucher_tab v, voucher_row_tab vr
      WHERE  v.company           = vr.company
      AND    v.accounting_year   = vr.accounting_year
      AND    v.voucher_no        = vr.voucher_no
      AND    v.voucher_type      = vr.voucher_type
      AND    v.company           = company_
      AND    v.voucher_updated   = 'N'
      AND    DECODE (code_part_, 'A' , account,
                                 'B' , code_b,
                                 'C' , code_c,
                                 'D' , code_d,
                                 'E' , code_e,
                                 'F' , code_f,
                                 'G' , code_g,
                                 'H' , code_h,
                                 'I' , code_i,
                                 'J' , code_j  ) = codevalue_;
BEGIN
   OPEN Code_Control;
   FETCH Code_Control INTO dummy_;
   IF (Code_Control%NOTFOUND) THEN
      CLOSE Code_Control;
      RETURN 'FALSE';
   ELSE
      CLOSE Code_Control;
      RETURN 'TRUE';
   END IF;
END Not_Updated_Code_Part_Exist;


PROCEDURE Update_Row_No(
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN VARCHAR2,
   accounting_year_ IN NUMBER)
IS
   bulk_limit_  CONSTANT NUMBER := 1000;
   count_                NUMBER := 1;
   
   CURSOR get_data IS 
      SELECT row_no,project_activity_id 
      FROM   voucher_row_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    accounting_year = accounting_year_
      ORDER BY row_no
      FOR UPDATE;
      
   CURSOR get_voucher_data IS 
      SELECT rowid, row_no, 0 new_row_no 
      FROM   voucher_row_tab
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    accounting_year = accounting_year_
      ORDER BY row_no
      FOR UPDATE;

   TYPE get_voucher_data_table_ IS TABLE OF  get_voucher_data%ROWTYPE
        INDEX BY BINARY_INTEGER;
   ref_get_voucher_data_table_               get_voucher_data_table_;
$IF Component_Intled_SYS.INSTALLED $THEN
   update_row_ref_arr_                       Internal_Hold_voucher_Row_API.Update_Row_Ref_Arr; 
$END 
BEGIN
   FOR rec_ IN get_data LOOP
      IF (rec_.project_activity_id IS NOT NULL) THEN
         Remove_Object_Connection(company_,
                                  voucher_type_,
                                  accounting_year_,
                                  voucher_no_,
                                  rec_.row_no,
                                  rec_.project_activity_id);
      END IF;
   END LOOP;
   
   OPEN get_voucher_data;
   LOOP
      FETCH get_voucher_data BULK COLLECT INTO ref_get_voucher_data_table_ LIMIT bulk_limit_;
      FOR i_ IN 1..ref_get_voucher_data_table_.count LOOP
         ref_get_voucher_data_table_(i_).new_row_no := count_;
$IF Component_Intled_SYS.INSTALLED $THEN
         update_row_ref_arr_(i_).new_row_ref     := count_;
         update_row_ref_arr_(i_).company         := company_;
         update_row_ref_arr_(i_).voucher_type    := voucher_type_;
         update_row_ref_arr_(i_).accounting_year := accounting_year_;
         update_row_ref_arr_(i_).voucher_no      := voucher_no_;
         update_row_ref_arr_(i_).old_row_ref     := ref_get_voucher_data_table_(i_).row_no;
$END
         count_ := count_ + 1;    
      END LOOP;

      Voucher_API.Update_Current_Row_Num(company_,voucher_type_,accounting_year_,voucher_no_,count_ - 1);
      
      FORALL j_ IN 1..ref_get_voucher_data_table_.count
         UPDATE voucher_row_tab
         SET row_no  = ref_get_voucher_data_table_(j_).new_row_no
         WHERE rowid = ref_get_voucher_data_table_(j_).rowid;

      FORALL k_ IN 1..ref_get_voucher_data_table_.count
         UPDATE voucher_row_tab
         SET reference_row_no   = ref_get_voucher_data_table_(k_).new_row_no
         WHERE company          = company_
         AND   voucher_type     = voucher_type_
         AND   voucher_no       = voucher_no_
         AND   accounting_year  = accounting_year_
         AND   reference_row_no = ref_get_voucher_data_table_(k_).row_no;

      FORALL m_ IN 1..ref_get_voucher_data_table_.count
         UPDATE period_allocation_tab
         SET   row_no          = ref_get_voucher_data_table_(m_).new_row_no
         WHERE company         = company_
         AND   voucher_type    = voucher_type_
         AND   accounting_year = accounting_year_
         AND   voucher_no      = voucher_no_
         AND   row_no          = ref_get_voucher_data_table_(m_).row_no;

      -- Update MC voucher Row
--      FORALL vr_ IN 1..ref_get_voucher_data_table_.count
--         UPDATE Multi_Company_Voucher_Row_Tab
     --    SET   row_no_ref          = ref_get_voucher_data_table_(vr_).new_row_no
     --    WHERE voucher_company     = company_
     --    AND   voucher_type_ref    = voucher_type_
     --    AND   accounting_year_ref = accounting_year_
     --    AND   voucher_no_ref      = voucher_no_
     --    AND   row_no_ref          = ref_get_voucher_data_table_(vr_).row_no--;

$IF Component_Intled_SYS.INSTALLED $THEN
         Internal_Hold_voucher_Row_API.Update_Multi_Row_Ref(update_row_ref_arr_);
         FOR u_ IN 1..ref_get_voucher_data_table_.count LOOP
            update_row_ref_arr_(u_).new_row_ref            := NULL;
            update_row_ref_arr_(u_).company                := NULL;
            update_row_ref_arr_(u_).voucher_type           := NULL;
            update_row_ref_arr_(u_).accounting_year        := NULL;
            update_row_ref_arr_(u_).voucher_no             := NULL;
            update_row_ref_arr_(u_).old_row_ref            := NULL;
         END LOOP;
$END

      EXIT WHEN get_voucher_data%NOTFOUND;
   END LOOP;
   Create_Object_Connection(company_,
                            voucher_type_,
                            accounting_year_,
                            voucher_no_);   
END Update_Row_No;


@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Subcon_Used_Cost (
   company_      IN VARCHAR2,
   sub_con_no_   IN VARCHAR2,
   activity_seq_ IN NUMBER,
   account_      IN VARCHAR2 ) RETURN NUMBER
IS
   used_value_            NUMBER;
   used_transaction_      NUMBER;
   t_misc_used_           NUMBER;

   CURSOR get_voucher_row IS
      SELECT *
      FROM   voucher_row_tab t
      WHERE  company               = company_
      AND    t.reference_serie     = sub_con_no_
      AND    t.trans_code          IN ('SCV1', 'SCV2', 'SCV3', 'SCV4', 'SCV6', 'SCV10', 'SCV13', 'SCV15')
      AND    t.project_activity_id = activity_seq_
      AND    t.account             = account_;
BEGIN
   t_misc_used_ := 0;
   FOR voucher_row_rec_ IN get_voucher_row LOOP
      Get_Activity_Info(used_value_,
                        used_transaction_,
                        voucher_row_rec_ );
      t_misc_used_ := t_misc_used_ + nvl(used_value_, 0);
   END LOOP;
   RETURN t_misc_used_;
END Get_Subcon_Used_Cost;


PROCEDURE Get_Subcon_Total_Used_Cost (
   used_cost_        OUT NUMBER,
   used_transaction_ OUT NUMBER,
   company_          IN VARCHAR2,
   sub_con_no_       IN VARCHAR2,
   activity_seq_     IN NUMBER,
   cost_element_     IN VARCHAR2,
   currency_code_    IN VARCHAR2 )
IS
   $IF Component_Subval_SYS.INSTALLED $THEN
      result_              NUMBER;
      result_transaction_  NUMBER;
      used_value_          NUMBER;
     
      CURSOR get_voucher_row IS
               SELECT t.*
                 FROM voucher_row_tab t
                WHERE t.company = company_
                  AND t.reference_serie = sub_con_no_
                  AND t.currency_code = currency_code_
                  AND t.trans_code LIKE ('SCV%')
                  AND t.project_activity_id = activity_seq_
                  AND cost_element_ = Cost_Element_To_Account_API.Get_Project_Follow_Up_Element( t.company,t.account,t.code_b,t.code_c,
                                                                              t.code_d,t.code_e,t.code_f,t.code_g,t.code_h,t.code_i,
                                                                              t.code_j,TRUNC(SYSDATE),'TRUE',t.trans_code)
                UNION
               SELECT v.* 
                 FROM subval_invoice t, invoice i, voucher_row_tab v, cost_element_to_account_tab c 
                WHERE t.invoice_id = i.Invoice_Id
                  AND i.series_id = v.Reference_Serie
                  AND i.invoice_no = v.reference_number
                  AND i.company = v.company
                  AND i.party_type_db = v.party_type
                  AND i.identity = v.party_type_id
                  AND v.company = company_
                  AND t.sub_con_no = sub_con_no_
                  AND v.currency_code = currency_code_
                  AND v.trans_code LIKE ('SCV%')
                  AND v.project_activity_id = activity_seq_
                  AND cost_element_ = Cost_Element_To_Account_API.Get_Project_Follow_Up_Element( v.company,v.account,v.code_b,v.code_c,
                                                                              v.code_d,v.code_e,v.code_f,v.code_g,v.code_h,v.code_i,
                                                                              v.code_j,TRUNC(SYSDATE),'TRUE',v.trans_code);
   $END
BEGIN
   $IF Component_Subval_SYS.INSTALLED $THEN      
      IF (Company_Finance_API.Is_User_Authorized(company_)) THEN
         result_              := 0;
         result_transaction_  := 0;

         FOR voucher_rec_ IN get_voucher_row LOOP
            Voucher_Row_API.Get_Activity_Info(used_value_,
                                              used_transaction_,
                                              voucher_rec_ );
            result_              := result_              + nvl(used_value_, 0);
            result_transaction_  := result_transaction_  + nvl(used_transaction_, 0);
         END LOOP;
         used_cost_          := result_;
         used_transaction_   := result_transaction_;
      END IF;
   $END
   used_cost_          := nvl(used_cost_, 0);
   used_transaction_   := nvl(used_transaction_, 0);
END Get_Subcon_Total_Used_Cost;


PROCEDURE Update_Allocation_Id (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   row_no_          IN NUMBER,
   allocation_id_   IN NUMBER )
IS
BEGIN
   UPDATE VOUCHER_ROW_TAB 
      SET allocation_id = allocation_id_
   WHERE  company         = company_
   AND    voucher_type    = voucher_type_
   AND    accounting_year = accounting_year_
   AND    voucher_no      = voucher_no_
   AND    row_no          = row_no_;
END Update_Allocation_Id;


@UncheckedAccess
FUNCTION Check_Exist_Alloc_Id (
   allocation_id_ IN NUMBER ) RETURN VARCHAR2
IS
   dummy_ NUMBER;
   CURSOR exist_control IS
      SELECT 1
      FROM   VOUCHER_ROW_TAB
      WHERE  allocation_id = allocation_id_;
BEGIN
   OPEN  exist_control;
   FETCH exist_control INTO dummy_;
   IF (exist_control%FOUND) THEN
      CLOSE exist_control;
      RETURN 'TRUE';
   END IF;
   CLOSE exist_control;
   RETURN 'FALSE';
END Check_Exist_Alloc_Id;


PROCEDURE Get_Internal_Code_Parts(
   code_b_              IN OUT VARCHAR2,
   code_c_              IN OUT VARCHAR2,
   code_d_              IN OUT VARCHAR2,
   code_e_              IN OUT VARCHAR2,
   code_f_              IN OUT VARCHAR2,
   code_g_              IN OUT VARCHAR2,
   code_h_              IN OUT VARCHAR2,
   code_i_              IN OUT VARCHAR2,
   code_j_              IN OUT VARCHAR2,
   company_             IN     VARCHAR2,
   accounting_year_     IN     NUMBER,
   voucher_type_        IN     VARCHAR2,
   voucher_no_          IN     NUMBER,
   row_no_              IN     NUMBER,
   internal_code_part_  IN     VARCHAR2)
IS
   code_b_tmp_         VARCHAR2(20);
   code_c_tmp_         VARCHAR2(20);
   code_d_tmp_         VARCHAR2(20);
   code_e_tmp_         VARCHAR2(20);
   code_f_tmp_         VARCHAR2(20);
   code_g_tmp_         VARCHAR2(20);
   code_h_tmp_         VARCHAR2(20);
   code_i_tmp_         VARCHAR2(20);
   code_j_tmp_         VARCHAR2(20);
   
   CURSOR get_code_parts IS
      SELECT code_b,
             code_c,
             code_d,
             code_e,
             code_f,
             code_g,
             code_h,
             code_i,
             code_j
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    accounting_year = accounting_year_
      AND    voucher_type    = voucher_type_
      AND    voucher_no      = voucher_no_
      AND    row_no          = row_no_;
BEGIN
   OPEN get_code_parts;
   FETCH get_code_parts INTO code_b_tmp_,
                             code_c_tmp_,
                             code_d_tmp_,
                             code_e_tmp_,
                             code_f_tmp_,
                             code_g_tmp_,
                             code_h_tmp_,
                             code_i_tmp_,
                             code_j_tmp_;
   CLOSE get_code_parts;

   IF INSTR(internal_code_part_,'B') >0 THEN
      code_b_ := code_b_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'C') >0 THEN
      code_c_ := code_c_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'D') >0 THEN
      code_d_ := code_d_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'E') >0 THEN
      code_e_ := code_e_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'F') >0 THEN
      code_f_ := code_f_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'G') >0 THEN
      code_g_ := code_g_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'H') >0 THEN
      code_h_ := code_h_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'I') >0 THEN
      code_i_ := code_i_tmp_;
   END IF;
   IF INSTR(internal_code_part_,'J') >0 THEN
      code_j_ := code_j_tmp_;
   END IF;
END Get_Internal_Code_Parts;


-- All_Postings_Transferred_Acc
--   Check if all postings for the specified account and company
--   have been transferred to GL.
--   Should be called from ACCOUNT_API when inert/update exclude_proj_followup.
--   The return value will be the string 'TRUE' if all postings have been
--   transferred, 'FALSE' if not.
@UncheckedAccess
FUNCTION All_Postings_Transferred_Acc (
   company_    IN VARCHAR2,
   account_    IN VARCHAR2) RETURN VARCHAR2

IS
   CURSOR get_non_transferred IS
      SELECT 1
      FROM   voucher_tab v, voucher_row_tab vr
      WHERE  v.company           = company_
      AND    v.company           = vr.company
      AND    v.accounting_year   = vr.accounting_year
      AND    v.accounting_period = vr.accounting_period
      AND    v.voucher_no        = vr.voucher_no
      AND    v.voucher_type      = vr.voucher_type
      AND    v.voucher_updated   = 'N'
      AND    vr.account          = account_;

   dummy_                NUMBER;
   postings_transferred_ VARCHAR2(5);

BEGIN
   OPEN get_non_transferred;
   FETCH get_non_transferred INTO dummy_;
   IF (get_non_transferred%FOUND) THEN
      postings_transferred_ := 'FALSE';
   ELSE
      postings_transferred_ := 'TRUE';
   END IF;
   CLOSE get_non_transferred;

   RETURN postings_transferred_;
END All_Postings_Transferred_Acc;


@UncheckedAccess
FUNCTION Check_Exist_Vourow_with_Pfe (
   company_ IN VARCHAR2 ) RETURN BOOLEAN
IS
   CURSOR get_acc_with_prjacc IS
      SELECT vr.account
      FROM   VOUCHER_TAB v, VOUCHER_ROW_TAB vr
      WHERE  v.company              = vr.company
      AND    v.accounting_year      = vr.accounting_year
      AND    v.voucher_no           = vr.voucher_no
      AND    v.voucher_type         = vr.voucher_type
      AND    v.voucher_updated      = 'N' 
      AND    vr.company             = company_
      AND    vr.project_activity_id IS NOT NULL
      AND   NOT (v.function_group = 'D' AND v.voucher_no <0);
BEGIN
   FOR acc_rec_ IN get_acc_with_prjacc LOOP
      IF (NVL(Account_API.Get_Exclude_Proj_Followup(company_, acc_rec_.account),'FALSE') = 'FALSE') THEN
         RETURN TRUE;
      END IF;
   END LOOP;
   RETURN FALSE;
END Check_Exist_Vourow_with_Pfe;

@UncheckedAccess
PROCEDURE Get_Voucher_Info_For_Mc_Vou(
   company_                      OUT VARCHAR2, 
   accounting_year_              OUT NUMBER, 
   voucher_type_                 OUT VARCHAR2, 
   voucher_no_                   OUT NUMBER, 
   row_no_                       OUT NUMBER,   
   multi_company_id_             IN VARCHAR2,
   multi_company_acc_year_       IN NUMBER,
   multi_company_voucher_type_   IN VARCHAR2,
   multi_company_voucher_no_     IN NUMBER,
   multi_company_row_no_         IN NUMBER )
IS
   CURSOR get_voucher_info IS
   SELECT company, 
         accounting_year, 
         voucher_type, 
         voucher_no, 
         row_no
   FROM voucher_row_tab
   WHERE multi_company_id         = multi_company_id_
   AND multi_company_acc_year_    = multi_company_acc_year
   AND multi_company_voucher_type = multi_company_voucher_type_
   AND multi_company_voucher_no   = multi_company_voucher_no_
   AND multi_company_row_no_      = multi_company_row_no;
   
BEGIN
   OPEN get_voucher_info;
   FETCH get_voucher_info INTO company_, 
                              accounting_year_, 
                              voucher_type_, 
                              voucher_no_, 
                              row_no_;
   CLOSE get_voucher_info;
END Get_Voucher_Info_For_Mc_Vou;


PROCEDURE Get_Activity_Info (
   used_value_       OUT NUMBER,
   used_trans_value_ OUT NUMBER,
   newrec_           IN  VOUCHER_ROW_TAB%ROWTYPE )
IS
   vou_group_            VARCHAR2(10);
   acc_type_             VARCHAR2(1);
   amount_              NUMBER;
   transaction_amount_  NUMBER;
BEGIN
   acc_type_            := Account_API.Get_Logical_Account_Type_Db(newrec_.company, newrec_.account);
   amount_              := NVL(newrec_.debet_amount,0) - NVL(newrec_.credit_amount,0);
   transaction_amount_  := NVL(newrec_.currency_debet_amount,0) - NVL(newrec_.currency_credit_amount,0);
   IF (acc_type_ != 'R') THEN
      vou_group_ := substr(Voucher_Type_API.Get_Voucher_Group(newrec_.company, newrec_.voucher_type), 1, 2);
      IF (vou_group_ = 'T') THEN
         IF (newrec_.trans_code IN ('PRJT1', 'PRJT2', 'PRJT3', 'PRJT4', 'PRJT5', 'PRJT6', 'PRJT7', 'PRJT8', 'PRJT12', 'PRJT13','T1' , 'PRJC1', 'PRJC2', 'PRJC3', 'PRJC4', 'PRJC5', 'PRJC6', 'PRJC9', 'PRJC10')) THEN
            used_value_       := amount_;
            used_trans_value_ := transaction_amount_;
         END IF;
      ELSIF (vou_group_ = 'E') THEN
         IF (newrec_.trans_code IN ('TX1', 'TX4', 'TX6')) THEN
            used_value_       := amount_;
            used_trans_value_ := transaction_amount_;
         END IF;  
      ELSE
         used_value_       := amount_;
         used_trans_value_ := transaction_amount_;
      END IF;
   ELSE
      used_value_       := amount_;
      used_trans_value_ := transaction_amount_;
   END IF;
END Get_Activity_Info;


PROCEDURE Refresh_Connection_Header (
   company_                    IN  VARCHAR2,
   voucher_type_               IN  VARCHAR2,
   accounting_year_            IN  NUMBER,
   voucher_no_                 IN  NUMBER,
   row_no_                     IN  NUMBER )
IS
   rec_                       VOUCHER_ROW_TAB%ROWTYPE;
   dummy_                     VARCHAR2(10);
   
BEGIN   
   $IF Component_Proj_SYS.INSTALLED $THEN
      rec_ := Get_Object_By_Keys___(company_, 
                                    voucher_type_, 
                                    accounting_year_, 
                                    voucher_no_, 
                                    row_no_);
      -- Here we send client value of Voucher State as it does in other object connections         
      -- eventhough it is not a good practice since decoding of server value is not supported
      -- by the PROJECT_CONNECTIONS_SUMMARY View in PROJ due to performance reasons.      
      Project_Connection_Util_API.Refresh_Header_And_Dates( rec_.project_activity_id,
                                                            company_,
                                                            voucher_type_,
                                                            accounting_year_,
                                                            voucher_no_,
                                                            row_no_,
                                                            dummy_,
                                                            'VR',
                                                            'VoucherRow',
                                                            rec_.voucher_date); 
   $ELSE
      NULL;  
   $END
END Refresh_Connection_Header;


@UncheckedAccess
FUNCTION Fetch_Exclude_Periodical_Cap(
   company_              IN VARCHAR2,
   account_              IN VARCHAR2,
   project_activity_id_  IN NUMBER ) RETURN VARCHAR2
IS
   act_excl_per_db_ VARCHAR2(5);
BEGIN
   IF Account_API.Get_Exclude_Periodical_Cap_Db(company_, account_) IN ('EXCLUDE_IN_ALL', 'EXCLUDE_IN_GL') THEN
      RETURN 'TRUE';
   ELSE
      $IF Component_Proj_SYS.INSTALLED $THEN
         IF (project_activity_id_ IS NOT NULL) THEN 
            act_excl_per_db_ := Activity_API.Get_Exclude_Periodical_Cap_Db(project_activity_id_);
         END IF;
         IF act_excl_per_db_ IN ('EXCLUDE_IN_ALL', 'EXCLUDE_IN_GL') THEN
            RETURN 'TRUE';
         END IF;
      $ELSE
         NULL;
      $END
   END IF;
   RETURN 'FALSE';
END;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Parallel_Curr_Tax_Base_Amt (
   company_          IN VARCHAR2,
   voucher_type_     IN VARCHAR2,
   accounting_year_  IN NUMBER,
   voucher_no_       IN NUMBER,
   row_no_           IN NUMBER ) RETURN NUMBER
IS
   temp_                voucher_row_tab.parallel_curr_tax_base_amount%TYPE;
   
   CURSOR get_attr IS
      SELECT parallel_curr_tax_base_amount
      FROM   voucher_row_tab
      WHERE  company         = company_
       AND   voucher_type    = voucher_type_
       AND   accounting_year = accounting_year_
       AND   voucher_no      = voucher_no_
       AND   row_no          = row_no_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Parallel_Curr_Tax_Base_Amt;

@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Sum_Parallel_Tax_Amount (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_type_       IN VARCHAR2,
   voucher_no_         IN NUMBER,
   function_group_     IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER
IS
   tax_sum_amount_          NUMBER;
   CURSOR tax_sum_currency_amount IS
      SELECT SUM(NVL(parallel_curr_tax_amount,0) )
      FROM   accounting_code_part_value_tab a,
             voucher_row_tab v
      WHERE  v.company         = company_
      AND    v.voucher_type    = voucher_type_
      AND    v.accounting_year = accounting_year_
      AND    v.voucher_no      = voucher_no_
      AND    a.company         = v.company
      AND    a.code_part       = 'A'
      AND    a.code_part_value = v.account
      AND    a.stat_account    = 'N';

   CURSOR tax_sum_currency_amount_yr_end IS
      SELECT SUM(NVL(parallel_curr_tax_amount,0) )
      FROM   accounting_code_part_value_tab a,
             voucher_row_tab v
      WHERE  v.company               = company_
      AND    v.voucher_type          = voucher_type_
      AND    v.accounting_year       = accounting_year_
      AND    v.voucher_no            = voucher_no_
      AND    a.company               = v.company
      AND    a.code_part             = 'A'
      AND    a.code_part_value       = v.account
      AND    a.stat_account          = 'N'
      AND    a.logical_account_type != 'O';
BEGIN  
   IF (function_group_ IS NOT NULL AND function_group_ = 'YE') THEN
      OPEN  tax_sum_currency_amount_yr_end;
      FETCH tax_sum_currency_amount_yr_end INTO tax_sum_amount_;
      CLOSE tax_sum_currency_amount_yr_end;
   ELSE
      OPEN  tax_sum_currency_amount;
      FETCH tax_sum_currency_amount INTO tax_sum_amount_;
      CLOSE tax_sum_currency_amount;
   END IF;
   RETURN tax_sum_amount_; 
END Sum_Parallel_Tax_Amount;

@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Sum_Parallel_Currency_Amount (
   company_            IN VARCHAR2,
   accounting_year_    IN NUMBER,
   voucher_type_       IN VARCHAR2,
   voucher_no_         IN NUMBER,
   function_group_     IN VARCHAR2 DEFAULT NULL ) RETURN NUMBER
IS
   sum_amount_          NUMBER;
   CURSOR sum_currency_amount IS
      SELECT SUM(NVL(third_currency_debit_amount,0) - NVL(third_currency_credit_amount,0) )
      FROM   accounting_code_part_value_tab a,
             voucher_row_tab v
      WHERE  v.company         = company_
      AND    v.voucher_type    = voucher_type_
      AND    v.accounting_year = accounting_year_
      AND    v.voucher_no      = voucher_no_
      AND    a.company         = v.company
      AND    a.code_part       = 'A'
      AND    a.code_part_value = v.account
      AND    a.stat_account    = 'N';

   CURSOR sum_currency_amount_yr_end IS
      SELECT SUM(NVL(third_currency_debit_amount,0) - NVL(third_currency_credit_amount,0) )
      FROM   accounting_code_part_value_tab a,
             voucher_row_tab v
      WHERE  v.company               = company_
      AND    v.voucher_type          = voucher_type_
      AND    v.accounting_year       = accounting_year_
      AND    v.voucher_no            = voucher_no_
      AND    a.company               = v.company
      AND    a.code_part             = 'A'
      AND    a.code_part_value       = v.account
      AND    a.stat_account          = 'N'
      AND    a.logical_account_type != 'O';

BEGIN
   IF (function_group_ IS NOT NULL AND function_group_ = 'YE') THEN
      OPEN  sum_currency_amount_yr_end;
      FETCH sum_currency_amount_yr_end INTO sum_amount_;
      CLOSE sum_currency_amount_yr_end;
   ELSE
      OPEN  sum_currency_amount;
      FETCH sum_currency_amount INTO sum_amount_;
      CLOSE sum_currency_amount;
   END IF;
   RETURN sum_amount_;
END Sum_Parallel_Currency_Amount;


PROCEDURE Postings_X_In_Voucher_Row (
   result_     OUT   VARCHAR2,
   company_    IN    VARCHAR2,
   code_part_  IN    VARCHAR2 )
IS
BEGIN
   IF (Check_If_Code_Part_Used___(company_, code_part_)) THEN
      result_ := 'TRUE';
   ELSE
      result_ := 'FALSE';
   END IF;
END Postings_X_In_Voucher_Row;


@UncheckedAccess
@SecurityCheck Company.UserAuthorized(company_)
FUNCTION Get_Currency_Rate (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER,
   trans_code_      IN VARCHAR2 ) RETURN NUMBER
IS
   temp_ VOUCHER_ROW_TAB.currency_rate%TYPE;
   CURSOR get_attr IS
      SELECT currency_rate
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    trans_code      = trans_code_;
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Currency_Rate;

PROCEDURE Validate_Delivery_Type_Id__ (
   company_           IN VARCHAR2,
   delivery_type_id_      IN VARCHAR2)
IS
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      Delivery_Type_API.Exist(company_, delivery_type_id_);
   $ELSE 
      NULL;
   $END 
END Validate_Delivery_Type_Id__;

@UncheckedAccess
FUNCTION Get_Delivery_Type_Description(
   company_ IN VARCHAR2,
   deliv_type_id_ IN VARCHAR2 ) RETURN VARCHAR2
IS 
   ret_ VARCHAR2(2000);
BEGIN
   $IF Component_Invoic_SYS.INSTALLED $THEN
      ret_ := Delivery_Type_API.Get_Description(company_,deliv_type_id_);
   $END                                           
   RETURN ret_;
END Get_Delivery_Type_Description;


PROCEDURE Create_Row (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   voucher_no_      IN NUMBER,
   accounting_year_ IN NUMBER,
   row_ref_         IN NUMBER)     
IS
   newrec_          Voucher_Row_Tab%ROWTYPE;   
BEGIN
   newrec_ := Get_Row(company_,
                      voucher_type_,
                      accounting_year_,
                      voucher_no_,
                      row_ref_);

   Internal_Manual_Postings(newrec_,
                            TRUE);
END Create_Row;

PROCEDURE Get_Voucher_Amount_Info (
   company_         IN     VARCHAR2,
   voucher_type_    IN     VARCHAR2,
   voucher_no_      IN     NUMBER,
   accounting_year_ IN     NUMBER,
   amount_             OUT NUMBER,
   currency_amount_    OUT NUMBER,
   parallel_amount_    OUT NUMBER,
   currency_rate_      OUT NUMBER,
   paralllel_currency_rate_ OUT NUMBER)     
IS
   CURSOR get_info IS
      SELECT NVL(currency_debet_amount, 0) - NVL(currency_credit_amount, 0),
             NVL(debet_amount, 0) - NVL(credit_amount, 0),
             NVL(third_currency_debit_amount, 0) - NVL(third_currency_credit_amount, 0),
             currency_rate,
             parallel_currency_rate
      FROM voucher_row_tab t
      WHERE company = company_
      AND accounting_year = accounting_year_
      AND voucher_type = voucher_type_
      AND voucher_no = voucher_no_ 
      AND t.trans_code = 'FAP74';   
BEGIN
   OPEN get_info;
   FETCH get_info INTO currency_amount_, amount_, parallel_amount_, currency_rate_, paralllel_currency_rate_;
   CLOSE get_info;
END Get_Voucher_Amount_Info;
FUNCTION Is_All_Rows_Auto_Tax_Vou_Entry (
   company_         IN VARCHAR2,
   voucher_type_    IN VARCHAR2,
   accounting_year_ IN NUMBER,
   voucher_no_      IN NUMBER) RETURN BOOLEAN
IS
   dummy_    NUMBER;
   CURSOR get_record IS
      SELECT 1
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_;
      
    CURSOR get_auto_tax_vou_entry_false IS
      SELECT 1
      FROM   VOUCHER_ROW_TAB
      WHERE  company         = company_
      AND    voucher_type    = voucher_type_
      AND    accounting_year = accounting_year_
      AND    voucher_no      = voucher_no_
      AND    auto_tax_vou_entry = 'FALSE'
      AND    multi_company_id IS NULL;

BEGIN
   OPEN get_auto_tax_vou_entry_false;
   FETCH get_auto_tax_vou_entry_false INTO dummy_; 
   IF (get_auto_tax_vou_entry_false%FOUND) THEN
      CLOSE get_auto_tax_vou_entry_false;
      RETURN FALSE;
      -- records exists with auto_tax_vou_entry = 'FALSE'. Then return FALSE;
   ELSE
      CLOSE get_auto_tax_vou_entry_false;
      OPEN get_record;
      FETCH get_record INTO dummy_;
      IF (get_record%FOUND)THEN
         CLOSE get_record;
         RETURN TRUE;
         -- no records exists with auto_tax_vou_entry = 'FALSE' but other records exists
         -- i.e. all records are auto_tax_vou_entry != 'FALSE'. Then return TRUE;
      ELSE
         -- No records exists in Voucher_row. Then return FALSE;
         CLOSE get_record;
         RETURN FALSE;
      END IF;
   END IF;
END Is_All_Rows_Auto_Tax_Vou_Entry;

PROCEDURE Validate_Int_Manual (company_ IN VARCHAR2,
                                  voucher_type_ IN VARCHAR2,
                                  voucher_date_ IN DATE,
                                  internal_seq_number_ IN NUMBER,
                                  account_  IN VARCHAR2,
                                  amount_ IN NUMBER,
                                  curr_amount_ IN NUMBER)
IS
   ledger_ids_ VARCHAR2(2000);
   ledger_id_  VARCHAR2(10);
   balance_    NUMBER;
   curr_balance_ NUMBER;
BEGIN
$IF Component_Intled_SYS.INSTALLED $THEN
   IF (Voucher_Type_API.Get_Use_Manual (company_,
                                        voucher_type_) = 'TRUE') THEN
      ledger_ids_ := Internal_Voucher_Util_Pub_API.Check_If_Manual (company_,
                                                       account_,
                                                       voucher_date_);
      IF (ledger_ids_ IS NOT NULL) THEN
         WHILE (INSTR(ledger_ids_, '|') > 0) LOOP         
            ledger_id_  := SUBSTR(ledger_ids_, 0, INSTR(ledger_ids_, '|') -1);
            ledger_ids_ := SUBSTR(ledger_ids_, INSTR(ledger_ids_, '|')+1);
            Internal_Postings_Accrul_API.Get_Amounts(curr_balance_, balance_, company_, ledger_id_, internal_seq_number_, account_);
            IF (curr_balance_ IS NULL OR balance_ IS NULL OR curr_balance_ != curr_amount_ OR balance_ != amount_) THEN
               Error_SYS.Record_General(lu_name_, 'NOINTMANPOSTINGS: Internal Manual Postings are missing!');
            END IF;
         END LOOP;
      END IF;
   END IF;
$ELSE
   NULL;
$END
END Validate_Int_Manual;


PROCEDURE Validate_Manual_Voucher_Rows__ (
   rec_               IN voucher_row_tab%ROWTYPE,
   voucher_entry_rec_ IN voucher_tab%ROWTYPE)
IS
   company_rec_      Company_Finance_API.Public_Rec;
   attr_             VARCHAR2(2000);
   function_group_   Voucher_Tab.function_group%TYPE;
   tax_types_event_  VARCHAR2(10) := 'RESTRICTED';  
   newrec_           voucher_row_tab%ROWTYPE;
   user_group_       Voucher_Tab.user_group%TYPE;
BEGIN
   newrec_ := rec_;
   function_group_ := Voucher_Type_Detail_API.Get_Function_Group(newrec_.company, newrec_.voucher_type);
   company_rec_ := Company_Finance_API.Get(newrec_.Company);
   user_group_  := voucher_entry_rec_.user_group;
  IF (function_group_ IN ('M', 'K', 'Q') AND newrec_.trans_code = 'MANUAL') 
         OR (function_group_ = 'D' AND newrec_.trans_code = 'MANUAL' AND newrec_.trans_code IS NOT NULL) THEN
      IF (Company_Finance_API.Get_Parallel_Base_Db(newrec_.company) IN ('TRANSACTION_CURRENCY','ACCOUNTING_CURRENCY')) THEN
         IF ((NVL(newrec_.debet_amount,0) = 0) AND (NVL(newrec_.credit_amount,0) = 0) AND 
             (NVL(newrec_.third_currency_debit_amount,0) = 0) AND (NVL(newrec_.third_currency_credit_amount,0) = 0) AND
             (NVL(newrec_.currency_debet_amount,0) = 0) AND (NVL(newrec_.currency_credit_amount,0) = 0) AND 
             (NVL(newrec_.quantity,0) = 0)) THEN
               Error_SYS.Record_General(lu_name_,'NOAMOUNT: Amount or Quantity must have a value.');
         END IF;
      ELSE  
         IF ((NVL(newrec_.debet_amount,0) = 0) AND (NVL(newrec_.credit_amount,0) = 0) AND 
             (NVL(newrec_.currency_debet_amount,0) = 0) AND (NVL(newrec_.currency_credit_amount,0) = 0) AND 
             (NVL(newrec_.quantity,0) = 0)) THEN
               Error_SYS.Record_General(lu_name_,'NOAMOUNT: Amount or Quantity must have a value.');
         END IF;
      END IF;
   END IF;
   IF ( newrec_.currency_rate IS NOT NULL AND newrec_.currency_rate <= 0) THEN 
      Error_SYS.Record_General(lu_name_, 'NEGATIVECURRRATE: Currency Rate cannot be zero or negative.');
   END IF;
   Validate_Budget_Code_Parts___(newrec_); -- done
   Validate_Vou_Row_Amounts___(newrec_, company_rec_);
   Check_Acquisition___(newrec_, function_group_, NULL); -- done
   Check_Codestring___ (newrec_, user_group_); -- done
   
   -- Check_Overwriting_Level___(newrec_, attr_); -- issue fetched header info will not be added
   Check_Project___(newrec_, function_group_); -- done with comments - issues is not an issue as the D voucher will not be created from the voucher entry client.
   
   IF ( newrec_.optional_code IS NOT NULL AND function_group_ IN ('M', 'K','Q')) THEN
      Tax_Handling_Util_API.Validate_Tax_On_Trans(newrec_.company,
                                                  tax_types_event_,
                                                  newrec_.optional_code,
                                                  'TRUE',
                                                  newrec_.account,
                                                  voucher_entry_rec_.voucher_date);      
   END IF;
   
END Validate_Manual_Voucher_Rows__;



PROCEDURE Update_Child_Vou_Rows__ (
   company_ VARCHAR2, 
  accounting_year_ NUMBER, 
   voucher_type_ VARCHAR2,
   voucher_no_ NUMBER,
   accounting_period_ NUMBER )
IS
   CURSOR get_child_vouchers IS
      SELECT row_no
      FROM voucher_row_tab
      WHERE company = company_
      AND accounting_year = accounting_year_
      AND voucher_type = voucher_type_
      AND voucher_no = voucher_no_;
      
      oldrec_ voucher_row_tab%ROWTYPE;
  newrec_ voucher_row_tab%ROWTYPE;
BEGIN
   FOR rec_ IN get_child_vouchers LOOP
      
      oldrec_ := Get_Object_By_Keys___(company_, 
                                    voucher_type_, 
                                    accounting_year_, 
                                    voucher_no_, rec_.row_no);
      newrec_ := oldrec_;
      
      newrec_.accounting_year := accounting_year_;
      newrec_.accounting_period := accounting_period_;
    
      
      Voucher_Row_API.Modify_Row__(newrec_);
       
   END LOOP;
   
END Update_Child_Vou_Rows__;
