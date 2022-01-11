-----------------------------------------------------------------------------
--
--  Logical unit: ExtFileServerUtil
--  Component:    ACCRUL
--
--  IFS Developer Studio Template Version 3.0
--
--  Date    Sign    History
--  ------  ------  ---------------------------------------------------------
--  021031  PPerse   Created
--  040928  ovjose   Added support for writing files with Utl_File with different character set
--  060120  shsalk   Corrected translation problem.
--  060524  Jeguse  Bug 58274, Corrected
--  061016  Kagalk  LCS Merge 57354, Increased length of file_line_ and max_linesize for Utl_File.Fopen
--  061016          Added Check for file line length
--  060726  AmNilk  Merged the LCS Bug 58891, Added code to remove the original file when file read is done.    
--  061208  Kagalk  LCS Merge 60487
--  070711  Hawalk  Merged Bug 66081, Added OUT parameter backup_file_path_ to Copy_Server_File_().
--  090116  Jeguse  Bug 79498, Increased length of file_name
--  100920  AjPelk  Bug 91106  Replaced '\' with a server_path_separator_
--  131114  Charlk  PBFI-2045,Change method In_Ext_File_Template_Dir_API.Get_Character_Set to  Get_Character_Set_D
--  190515  Nudilk  Bug 148286, Added Remove_Invalid_Char_Server_File___.
-----------------------------------------------------------------------------

layer Core;

-------------------- PUBLIC DECLARATIONS ------------------------------------


-------------------- PRIVATE DECLARATIONS -----------------------------------


-------------------- LU SPECIFIC IMPLEMENTATION METHODS ---------------------
FUNCTION Remove_Invalid_Char_Server_File___(
   file_line_  IN VARCHAR2) RETURN VARCHAR2
IS
   ret_file_line_ VARCHAR2(32000);
BEGIN
   ret_file_line_ := file_line_;
   -- Remove BOM charactor all occurences.
   ret_file_line_ := REPLACE(ret_file_line_, CHR(15711167));
   -- Remove last CHR(13) charactor.
   IF (SUBSTR(ret_file_line_,-1) = CHR(13)) THEN
      ret_file_line_ := SUBSTR(ret_file_line_, 0, LENGTH(ret_file_line_) - 1);
   END IF;
   RETURN ret_file_line_;
END Remove_Invalid_Char_Server_File___;

-------------------- LU SPECIFIC PRIVATE METHODS ----------------------------

-------------------- LU SPECIFIC PROTECTED METHODS --------------------------

PROCEDURE Check_Server_File_ (
   info_      IN OUT VARCHAR2,
   file_name_ IN     VARCHAR2 )
IS
   file_namex_       VARCHAR2(2000);
   file_handle_      Utl_File.File_Type;
   error_text_       VARCHAR2(2000)       := NULL;
   dir_found_        VARCHAR2(5)          := 'FALSE';
   end_of_file_      VARCHAR2(5)          := 'FALSE';
   open_type_        VARCHAR2(1)          := 'R';
   file_line_        Ext_File_Trans_TAB.File_Line%TYPE;
   record_count_     NUMBER               := 0;
   error_type_       NUMBER               := 0;
BEGIN
   file_namex_ := file_name_;
   Ext_File_Server_Util_API.Open_External_File ( file_handle_,
                                                 error_text_,
                                                 dir_found_,
                                                 file_namex_,
                                                 open_type_ );
   IF (dir_found_ = 'FALSE') THEN
      error_type_ := 1;
      -- File not found
   ELSE
      Ext_File_Server_Util_API.Get_Line_External_File ( error_text_,
                                                        file_line_,
                                                        end_of_file_,
                                                        record_count_,
                                                        file_namex_,
                                                        file_handle_ );
      IF (end_of_file_ = 'TRUE') THEN
         error_type_ := 2;
         -- File is empty
      END IF;
      IF (error_text_ IS NOT NULL) AND (file_line_ IS NULL) THEN
         error_type_ := 3;
      END IF;      
   END IF;
   Ext_File_Server_Util_API.Close_External_File ( file_handle_ );
   IF (error_type_ = 1) THEN
      info_ := Language_SYS.Translate_Constant(lu_name_, 'FILENOTEXIST: File :P1 not exist', NULL, file_namex_);
   ELSIF (error_type_ = 2) THEN
      info_ := Language_SYS.Translate_Constant(lu_name_, 'FILEEMPTY: File :P1 is empty', NULL, file_namex_);
   ELSIF (error_type_ = 3) THEN
      info_ := error_text_;
   ELSE
      info_ := NULL;
   END IF;
END Check_Server_File_;


PROCEDURE Load_Server_File_ (
   load_file_id_     IN OUT NUMBER,
   file_template_id_ IN     VARCHAR2,
   file_type_        IN     VARCHAR2,
   file_name_        IN OUT VARCHAR2,
   company_          IN     VARCHAR2 )
IS
   file_namex_              VARCHAR2(2000);   
   file_handle_             Utl_File.File_Type;
   error_text_              VARCHAR2(2000)       := NULL;
   dir_found_               VARCHAR2(5)          := 'FALSE';
   end_of_file_             VARCHAR2(5)          := 'FALSE';
   open_type_               VARCHAR2(1)          := 'R';
   file_line_               Ext_File_Trans_TAB.File_Line%TYPE;
   file_linex_              Ext_File_Trans_TAB.File_Line%TYPE;
   record_count_            NUMBER               := 0;
   row_no_                  NUMBER;
   in_file_character_set_   VARCHAR2(64) := In_Ext_File_Template_Dir_API.Get_Character_Set_Db(file_template_id_,'1');
   first_line_              VARCHAR2(5)          := 'TRUE';
   
BEGIN
   file_namex_ := file_name_;
   Ext_File_Server_Util_API.Open_External_File ( file_handle_,
                                                 error_text_,
                                                 dir_found_,
                                                 file_namex_,
                                                 open_type_ );
   IF (dir_found_ = 'TRUE') THEN
      -- Set character set to convert from
      IF in_file_character_set_ IS NOT NULL THEN
         Database_SYS.Set_File_Encoding(in_file_character_set_);
      END IF;
      
      Ext_File_Server_Util_API.Get_Line_External_File ( error_text_,
                                                        file_linex_,
                                                        end_of_file_,
                                                        record_count_,
                                                        file_name_,
                                                        file_handle_ );
      file_line_ := Database_SYS.File_To_Db_Encoding(file_linex_);
      file_line_ := Remove_Invalid_Char_Server_File___(file_line_);
      IF (NVL(load_file_id_,0) = 0) THEN
         load_file_id_ := External_File_Utility_API.Get_Next_Seq;
      END IF;
      row_no_ := Ext_File_Trans_API.Get_Max_Row_No ( load_file_id_ );
      
      WHILE (end_of_file_ = 'FALSE') LOOP
         
         IF (first_line_ = 'TRUE') THEN
            first_line_ := 'FALSE';
            --row_no_ := Ext_File_Trans_API.Get_Max_Row_No ( load_file_id_ );
            IF (NOT Ext_File_Load_API.Check_Exist_File_Load ( load_file_id_ ) ) THEN
               Ext_File_Load_API.Insert_File_Load ( load_file_id_,
                                                    file_template_id_,
                                                    '1',
                                                    file_type_,
                                                    company_,
                                                    file_namex_ );
            END IF;
         END IF;
         
         Ext_File_Trans_API.Insert_File_Trans ( load_file_id_,
                                                row_no_,
                                                file_line_ );
         Ext_File_Server_Util_API.Get_Line_External_File ( error_text_,
                                                           file_linex_,
                                                           end_of_file_,
                                                           record_count_,
                                                           file_namex_,
                                                           file_handle_ );
         file_line_ := Database_SYS.File_To_Db_Encoding(file_linex_);
         file_line_ := Remove_Invalid_Char_Server_File___(file_line_);
         row_no_ := row_no_ + 1;
         
      END LOOP;
      Ext_File_Load_API.Update_State (load_file_id_,
                                      '2');
   END IF;
   Ext_File_Server_Util_API.Close_External_File ( file_handle_ );
   file_name_ := file_namex_;
   --Set the file encoding back to default
   Database_SYS.Set_Default_File_Encoding;
END Load_Server_File_;


PROCEDURE Copy_Server_File_ (
   backup_file_path_    OUT VARCHAR2,
   load_file_id_     IN OUT NUMBER,
   file_name_        IN OUT VARCHAR2,
   file_char_set_    IN     VARCHAR2 DEFAULT NULL)
IS
   odir_             VARCHAR2(2000);
   ofile_            VARCHAR2(2000);
   backup_file_name_ VARCHAR2(2000);
   bdir_             VARCHAR2(2000);
   bfile_            VARCHAR2(2000);
   attr_dir_         VARCHAR2(500);
   last_slash_       NUMBER;

   server_path_separator_ VARCHAR2(1);

BEGIN
   -- Open backup file for write
   backup_file_name_ := Ext_File_Template_API.Get_Backup_File_Name ( load_file_id_,
                                                                     'S' );
   backup_file_path_ := backup_file_name_;

   server_path_separator_ := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');
   
   IF (backup_file_name_ IS NOT NULL) THEN
      last_slash_ := INSTR(backup_file_name_ ,server_path_separator_ ,-1);

      IF (last_slash_ = 0) THEN
         bdir_       := NULL;
         bfile_      := backup_file_name_;   
      ELSE
         bdir_       := SUBSTR(backup_file_name_,1,last_slash_);
         IF (SUBSTR(bdir_,LENGTH(bdir_),1) = server_path_separator_ ) THEN
            bdir_    := SUBSTR(bdir_,1,LENGTH(bdir_)-1);
         END IF;
            bfile_      := SUBSTR(backup_file_name_,last_slash_+1);   
      END IF;
      
      -- Note: get original file path
      last_slash_ := INSTR(file_name_ ,server_path_separator_ ,-1);

      IF (last_slash_ = 0) THEN
         -- Note: Full path is not available in file_name_. Try to get original file path from ACCRUL attributes.
         attr_dir_   := Accrul_Attribute_API.Get_Attribute_Value('SERVER_DIRECTORY');
         
         IF ( attr_dir_ IS NOT NULL ) THEN
            odir_       := attr_dir_;
         ELSE
            odir_       := NULL;
         END IF;
         
         ofile_      := file_name_;   
      ELSE
         odir_       := SUBSTR(file_name_,1,last_slash_);
         IF (SUBSTR(odir_,LENGTH(odir_),1) = server_path_separator_ ) THEN
            odir_    := SUBSTR(odir_,1,LENGTH(odir_)-1);
         END IF;
         ofile_      := SUBSTR(file_name_,last_slash_+1);   
      END IF;
      
      Utl_File.Fcopy( odir_ , ofile_, bdir_, bfile_ );
      Utl_File.Fremove( odir_ , ofile_ );
      --Set the file encoding back to default
      Database_SYS.Set_Default_File_Encoding;
   END IF;
END Copy_Server_File_;


PROCEDURE Write_Server_File_ (
   load_file_id_           IN OUT NUMBER,
   file_name_              IN OUT VARCHAR2,
   file_template_char_set_ IN VARCHAR2 DEFAULT NULL)
IS
   file_handle_               Utl_File.File_Type;
   last_slash_                NUMBER;
   dir_                       VARCHAR2(100);
   file_                      VARCHAR2(100);
   open_type_                 VARCHAR2(1) := 'W';
   server_path_separator_     VARCHAR2(1);

   CURSOR file_trans IS
      SELECT row_no, 
             file_line
      FROM   Ext_File_Trans_Tab
      WHERE  load_file_id = load_file_id_
      AND    Row_state    = '7'
      ORDER BY row_no;
BEGIN
   server_path_separator_ := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');
   last_slash_ := INSTR(file_name_ ,server_path_separator_ ,-1);

   
   IF (last_slash_ = 0) THEN
      dir_    := NULL;
      file_   := file_name_;   
   ELSE
      dir_    := SUBSTR(file_name_,1,last_slash_);
      IF (SUBSTR(dir_,LENGTH(dir_),1) = server_path_separator_ ) THEN
         dir_ := SUBSTR(dir_,1,LENGTH(dir_)-1);
      END IF;
      file_   := SUBSTR(file_name_,last_slash_+1);   
   END IF;
   Ext_File_Server_Util_API.Open_External_File2 ( file_handle_,dir_,file_,open_type_ );
   --Set the file encoding for the file
   IF file_template_char_set_ IS NOT NULL THEN
      Database_SYS.Set_File_Encoding(file_template_char_set_);
   END IF;
   FOR rec_ IN file_trans LOOP
      Ext_File_Server_Util_API.Put_Line_External_File (rec_.file_line,
                                                       file_handle_);
   END LOOP;
   Ext_File_Server_Util_API.Close_External_File ( file_handle_ );
   --Set the file encoding back to default
   Database_SYS.Set_Default_File_Encoding;
END Write_Server_File_;


-------------------- LU SPECIFIC PUBLIC METHODS -----------------------------

PROCEDURE Close_External_File (
   file_handle_   IN OUT Utl_File.File_Type )
IS
BEGIN
   IF (Utl_File.Is_Open (file_handle_)) THEN
      Utl_File.Fclose(file_handle_);
   END IF;
END Close_External_File;


PROCEDURE Open_External_File (
   file_handle_ IN OUT Utl_File.File_Type,
   error_text_  IN OUT VARCHAR2,
   dir_found_   IN OUT VARCHAR2,
   file_name_   IN OUT VARCHAR2,
   open_type_   IN     VARCHAR2 DEFAULT 'R' )
IS
   path_               VARCHAR2(2000);
   attr_dir_           VARCHAR2(500);
   file_               VARCHAR2(500);   
   dir_                VARCHAR2(500);
   pos_                NUMBER;
   dir_separator_      VARCHAR2(1) := ';';
   last_slash_         NUMBER; 
   server_path_separator_ VARCHAR2(1);
BEGIN
   attr_dir_   := Accrul_Attribute_API.Get_Attribute_Value('SERVER_DIRECTORY');
   Trace_SYS.Message ('Open_External_File attr_dir_ : '||attr_dir_);
   error_text_ := NULL;

   server_path_separator_ := NVL(Accrul_Attribute_API.Get_Attribute_Value ('SERVER_PATH_SEPARATOR'),'\');

   -- Get the correct file path and the file name
   dir_found_  := 'FALSE';

   last_slash_ := INSTR(file_name_, server_path_separator_ ,-1);
   IF (last_slash_ = 0) THEN
      dir_        := NULL;
      file_       := file_name_;   
   ELSE
      dir_        := SUBSTR(file_name_,1,last_slash_);
      IF (SUBSTR(dir_,LENGTH(dir_),1) = server_path_separator_ ) THEN
         dir_     := SUBSTR(dir_,1,LENGTH(dir_)-1);
      END IF;
      file_       := SUBSTR(file_name_,last_slash_+1);   
      BEGIN
         -- Try to open the file when input file_name contains a path
         file_handle_ := Utl_File.Fopen (dir_,file_,open_type_,6000);
         dir_found_   := 'TRUE';
         
         file_name_   := dir_ || server_path_separator_ || file_;
      EXCEPTION
         WHEN Utl_File.Invalid_Path THEN
            Ext_File_Server_Util_API.Close_External_File (file_handle_);
         WHEN Utl_File.Read_Error THEN
            Ext_File_Server_Util_API.Close_External_File (file_handle_);
         WHEN OTHERS THEN
            Ext_File_Server_Util_API.Close_External_File (file_handle_);
      END;
   END IF;
   IF (dir_found_ = 'FALSE') THEN
      IF (NVL(attr_dir_,'NULL') <> 'NULL') THEN
         IF (SUBSTR(attr_dir_,LENGTH(attr_dir_),1) != dir_separator_) THEN
            attr_dir_ := attr_dir_ || dir_separator_;
         END IF;
         path_        := attr_dir_;
         LOOP
            pos_    := NVL(INSTR(path_, dir_separator_, 1, 1),0);
            IF ( pos_ = 0 ) THEN
               EXIT;
            END IF;
            dir_       := RTRIM(SUBSTR(path_, 1, pos_ - 1));
            path_      := SUBSTR(path_, pos_ + 1);
            BEGIN
               -- Try to open the file
               file_handle_ := Utl_File.Fopen (dir_,file_,open_type_,6000);
               dir_found_   := 'TRUE';
               file_name_   := dir_ || server_path_separator_ || file_;

               EXIT;
            EXCEPTION
               WHEN Utl_File.Invalid_Path THEN
                  Ext_File_Server_Util_API.Close_External_File (file_handle_);
               WHEN Utl_File.Read_Error THEN
                  Ext_File_Server_Util_API.Close_External_File (file_handle_);
               WHEN OTHERS THEN
                  Ext_File_Server_Util_API.Close_External_File (file_handle_);
            END;
         END LOOP;
      ELSE
         error_text_ := Language_SYS.Translate_Constant ('EXT_FILE_SERVER_UTIL_API', 'UTLMISSATT: Attribute value for SERVER_DIRECTORY is missing');
         dir_found_ := 'FALSE';
      END IF;
   END IF;
   IF (dir_found_ = 'FALSE') THEN
      error_text_ := Language_SYS.Translate_Constant ('EXT_FILE_SERVER_UTIL_API', 'UTLINVPATH: Invalid File Path (:P1) or file name (:P2) ',NULL,dir_,file_name_);
   END IF;
END Open_External_File;


PROCEDURE Open_External_File2 (
   file_handle_ IN OUT Utl_File.File_Type,
   dir_         IN     VARCHAR2,
   file_        IN     VARCHAR2,
   open_type_   IN     VARCHAR2 DEFAULT 'R' )
IS
BEGIN
   file_handle_ := Utl_File.Fopen (dir_,file_,open_type_,6000);
EXCEPTION
   WHEN OTHERS THEN
      Error_SYS.Appl_General( lu_name_, 'UTLINVPATH: Invalid File Path (:P1) or file name (:P2) ',dir_,file_);
      Ext_File_Server_Util_API.Close_External_File (file_handle_);
END Open_External_File2;


PROCEDURE Get_Line_External_File (
   error_text_   IN OUT VARCHAR2,
   buffer_       IN OUT VARCHAR2,
   end_of_file_  IN OUT VARCHAR2,
   record_count_ IN OUT NUMBER,
   file_name_    IN     VARCHAR2,
   file_handle_  IN     Utl_File.File_Type )
IS
   buffer2_      VARCHAR2(6000);
BEGIN
   Utl_File.Get_Line (file_handle_, buffer2_);                          
   IF length(buffer2_) > 4000 THEN
      error_text_  := Language_SYS.Translate_Constant(lu_name_, 'UTLLINE2LONG: Maximum length allowed for a File Line is 4000 characters.');
      buffer_ := NULL;
   ELSE
      buffer_ := buffer2_;   
   END IF;
   record_count_ := record_count_ + 1;
EXCEPTION
   WHEN Utl_File.Invalid_Filehandle THEN
      error_text_  := Language_SYS.Translate_Constant ('EXT_FILE_SERVER_UTIL_API', 'UTLINVFIH: Invalid File Handle - :P1 ',file_name_);
      end_of_file_ := 'TRUE';
   WHEN Utl_File.Read_Error THEN
      error_text_  := Language_SYS.Translate_Constant ('EXT_FILE_SERVER_UTIL_API', 'UTLREAERR: Read Error in File - :P1 ',file_name_);
      end_of_file_ := 'TRUE';
   WHEN NO_DATA_FOUND THEN
      end_of_file_ := 'TRUE';
      IF (record_count_ = 0) THEN
         error_text_ := Language_SYS.Translate_Constant ('EXT_FILE_SERVER_UTIL_API', 'UTLNODATA: No Data Found in File - :P1 ',file_name_);
      END IF;
END Get_Line_External_File;


PROCEDURE Put_Line_External_File (
   buffer_      IN     VARCHAR2,   
   file_handle_ IN OUT Utl_File.File_Type )
IS
BEGIN
   Utl_File.Put_Line (file_handle_, Database_SYS.Db_To_File_Encoding(buffer_));  
EXCEPTION
   WHEN Utl_File.Invalid_Filehandle THEN
      Error_SYS.Appl_General( lu_name_, 'UTLINVFILH: Invalid File Handle');
      Close_External_File (file_handle_);
   WHEN OTHERS THEN
      Error_SYS.Appl_General( lu_name_, 'UTLWRERROR: Write Error');
      Close_External_File (file_handle_);
END Put_Line_External_File;



