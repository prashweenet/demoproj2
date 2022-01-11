-----------------------------------------------------------------------------
--
--  Filename      : Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql
--
--  Module        : ACCRUL
--
--  Purpose       : Move data from tax_item_tab to source_tax_item_tab.
--
--
--
--  Date           Sign    History
--  ------------   ------  --------------------------------------------------
--  160810         Rafase  Created.
--  160810         Samwlk  Modify Insert statment using BULLK COLLECT.
--  160826         Hiralk  Added tempory tables creations for existing data and
--                         added part to copy data from tax_item_template_tab.
--  ------------   ------  --------------------------------------------------

SET SERVEROUTPUT ON

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Timestamp_1');
PROMPT Create a copy of tax_item_tab and tax_item_template_tab
DECLARE
   stmt_     VARCHAR2(32000);
BEGIN
   IF (Database_SYS.Table_Active('TAX_ITEM_TAB') AND NOT Database_SYS.Table_Exist('TAX_ITEM_TAB_TMP_1000')) THEN
      stmt_ := 'CREATE TABLE tax_item_tab_tmp_1000 AS
                   SELECT company, invoice_id, item_id, tax_id, identity, party_type, tax_percentage, tax_curr_amount, tax_dom_amount, tax_parallel_amount,
                          standard_tax_curr_amount, standard_tax_dom_amount, standard_tax_parallel_amt, fee_code, manually_updated, transferred, irs1099_type_id,
                          parent_fee_code, minimum_tax, order_no, line_no, release_no, sequence_no, base_curr_amount, base_dom_amount, sub_con_no, valuation_no,
                          modified_from_po, base_parallel_amount, non_deduct_tax_curr_amount, non_deduct_tax_dom_amount, non_ded_tax_parallel_amt, deductible
                   FROM   tax_item_tab';
      EXECUTE IMMEDIATE stmt_;
   END IF;
   IF (Database_SYS.Table_Active('TAX_ITEM_TEMPLATE_TAB') AND NOT Database_SYS.Table_Exist('TAX_ITEM_TEMPLATE_TAB_TMP_1000')) THEN
      stmt_ := 'CREATE TABLE tax_item_template_tab_tmp_1000 AS
                   SELECT company, identity, party_type, invoice_template_no, item_id, tax_id, tax_percentage, tax_curr_amount, fee_code, manually_updated,
                          standard_tax_curr_amount, int_irs1099_type_id, non_deduct_tax_curr_amount, deductible
                   FROM   tax_item_template_tab';
      EXECUTE IMMEDIATE stmt_;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Timestamp_2');
PROMPT Move data from tax_item_tab to source_tax_item_tab
DECLARE
   stmt_     VARCHAR2(32000);
BEGIN
   IF Database_SYS.Table_Active('TAX_ITEM_TAB') THEN
      stmt_ := 'INSERT INTO source_tax_item_tab(company,                                                                         '||
               '                                source_ref_type,                                                                 '||
               '                                source_ref1,                                                                     '||
               '                                source_ref2,                                                                     '||
               '                                source_ref3,                                                                     '||
               '                                source_ref4,                                                                     '||
               '                                source_ref5,                                                                     '||
               '                                tax_item_id,                                                                     '||
               '                                tax_code,                                                                        '||
               '                                tax_percentage,                                                                  '||
               '                                tax_curr_amount,                                                                 '||
               '                                tax_dom_amount,                                                                  '||
               '                                tax_parallel_amount,                                                             '||
               '                                tax_base_curr_amount,                                                            '||
               '                                tax_base_dom_amount,                                                             '||
               '                                tax_base_parallel_amount,                                                        '||
               '                                non_ded_tax_curr_amount,                                                         '||
               '                                non_ded_tax_dom_amount,                                                          '||
               '                                non_ded_tax_parallel_amount,                                                     '||
               '                                transferred,                                                                     '||
               '                                rowversion,                                                                      '||
               '                                rowtype,                                                                         '||
               '                                rowkey)                                                                          '||
               '                               (SELECT t.company,                                                                '||
               '                                       ''INVOICE'',                                                              '||
               '                                       TO_CHAR(t.invoice_id),                                                    '||
               '                                       TO_CHAR(t.item_id),                                                       '||
               '                                       ''*'',                                                                    '||
               '                                       ''*'',                                                                    '||
               '                                       ''*'',                                                                    '||
               '                                       tax_id,                                                                   '||
               '                                       t.fee_code,                                                               '||
               '                                       t.tax_percentage,                                                         '||
               '                                       tax_curr_amount,                                                          '||
               '                                       tax_dom_amount,                                                           '||
               '                                       tax_parallel_amount,                                                      '||
               '                                       CASE transferred                                                          '||
               '                                          WHEN ''TRUE'' THEN NVL(base_curr_amount, net_curr_amount)              '||
               '                                          ELSE NVL(actual_net_curr_amount, net_curr_amount)                      '||
               '                                       END,                                                                      '||
               '                                       CASE transferred                                                          '||
               '                                          WHEN ''TRUE'' THEN NVL(base_dom_amount, net_dom_amount)                '||
               '                                          ELSE NVL(actual_net_dom_amount, net_dom_amount)                        '||
               '                                       END,                                                                      '||
               '                                       CASE transferred                                                          '||
               '                                          WHEN ''TRUE'' THEN NVL(base_parallel_amount, net_parallel_amount)      '||
               '                                          ELSE NVL(actual_net_parallel_amount, net_parallel_amount)              '||
               '                                       END,                                                                      '||
               '                                       t.non_deduct_tax_curr_amount,                                             '||
               '                                       t.non_deduct_tax_dom_amount,                                              '||
               '                                       t.non_ded_tax_parallel_amt,                                               '||
               '                                       transferred,                                                              '||
               '                                       SYSDATE,                                                                  '||
               '                                       ''SourceTaxItemInvoic'',                                                  '||
               '                                       sys_guid()                                                                '||
               '                                 FROM  tax_item_tab t, invoice_item_tab i, statutory_fee_tab s                   '||
               '                                 WHERE t.company    = i.company                                                  '||
               '                                 AND   t.invoice_id = i.invoice_id                                               '||
               '                                 AND   t.item_id    = i.item_id                                                  '||
               '                                 AND   t.company    = s.company                                                  '||
               '                                 AND   t.fee_code   = s.fee_code                                                 '||
               '                                 AND   s.fee_type  != ''IRS1099TX''                                              '||
               '                                 AND   NOT EXISTS (SELECT 1                                                      '||
               '                                                   FROM  source_tax_item_tab sti                                 '||
               '                                                   WHERE sti.company         = t.company                         '||
               '                                                   AND   sti.source_ref_type = ''INVOICE''                       '||
               '                                                   AND   sti.source_ref1     = TO_CHAR(t.invoice_id)             '||
               '                                                   AND   sti.source_ref2     = TO_CHAR(t.item_id)                '||
               '                                                   AND   sti.source_ref3     = ''*''                             '||
               '                                                   AND   sti.source_ref4     = ''*''                             '||
               '                                                   AND   sti.source_ref5     = ''*''                             '||
               '                                                   AND   sti.tax_item_id     = t.tax_id))';
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Timestamp_3');
PROMPT Delete moved data from tax_item_tab
DECLARE
   stmt_     VARCHAR2(32000);
BEGIN
   IF Database_SYS.Table_Active('TAX_ITEM_TAB') THEN
      stmt_ := 'DELETE FROM tax_item_tab t                                          '||
               'WHERE  EXISTS (SELECT  1                                            '||
               '               FROM  statutory_fee_tab s                            '||
               '               WHERE s.company    = t.company                       '||
               '               AND   s.fee_code   = t.fee_code                      '||
               '               AND   s.fee_type  != ''IRS1099TX'')                  '||
               'AND    EXISTS (SELECT 1                                             '||
               '               FROM  source_tax_item_tab sti                        '||
               '               WHERE sti.company         = t.company                '||
               '               AND   sti.source_ref_type = ''INVOICE''              '||
               '               AND   sti.source_ref1     = TO_CHAR(t.invoice_id)    '||
               '               AND   sti.source_ref2     = TO_CHAR(t.item_id)       '||
               '               AND   sti.source_ref3     = ''*''                    '||
               '               AND   sti.source_ref4     = ''*''                    '||
               '               AND   sti.source_ref5     = ''*''                    '||
               '               AND   sti.tax_item_id     = t.tax_id)';
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Timestamp_4');
PROMPT Move data from tax_item_template_tab to source_tax_item_tab
DECLARE
   stmt_     VARCHAR2(32000);
BEGIN
   IF Database_SYS.Table_Active('TAX_ITEM_TEMPLATE_TAB') THEN
      stmt_ := 'INSERT INTO source_tax_item_tab(company,                                                                         '||
               '                                source_ref_type,                                                                 '||
               '                                source_ref1,                                                                     '||
               '                                source_ref2,                                                                     '||
               '                                source_ref3,                                                                     '||
               '                                source_ref4,                                                                     '||
               '                                source_ref5,                                                                     '||
               '                                tax_item_id,                                                                     '||
               '                                tax_code,                                                                        '||
               '                                tax_percentage,                                                                  '||
               '                                tax_curr_amount,                                                                 '||
               '                                tax_dom_amount,                                                                  '||
               '                                tax_parallel_amount,                                                             '||
               '                                tax_base_curr_amount,                                                            '||
               '                                tax_base_dom_amount,                                                             '||
               '                                tax_base_parallel_amount,                                                        '||
               '                                non_ded_tax_curr_amount,                                                         '||
               '                                non_ded_tax_dom_amount,                                                          '||
               '                                non_ded_tax_parallel_amount,                                                     '||
               '                                transferred,                                                                     '||
               '                                rowversion,                                                                      '||
               '                                rowtype,                                                                         '||
               '                                rowkey)                                                                          '||
               '                               (SELECT t.company,                                                                '||
               '                                       ''INVOICE_TEMPLATE'',                                                     '||
               '                                       t.identity,                                                               '||
               '                                       t.party_type,                                                             '||
               '                                       t.invoice_template_no,                                                    '||
               '                                       TO_CHAR(t.item_id),                                                       '||
               '                                       ''*'',                                                                    '||
               '                                       tax_id,                                                                   '||
               '                                       t.fee_code,                                                               '||
               '                                       t.tax_percentage,                                                         '||
               '                                       t.tax_curr_amount,                                                        '||
               '                                       0,                                                                        '||
               '                                       0,                                                                        '||
               '                                       i.net_curr_amount,                                                        '||
               '                                       0,                                                                        '||
               '                                       0,                                                                        '||
               '                                       t.non_deduct_tax_curr_amount,                                             '||
               '                                       0,                                                                        '||
               '                                       0,                                                                        '||
               '                                       ''FALSE'',                                                                '||
               '                                       SYSDATE,                                                                  '||
               '                                       ''SourceTaxItemInvoic'',                                                  '||
               '                                       sys_guid()                                                                '||
               '                                 FROM  tax_item_template_tab t, invoice_item_tmpl_tab i, statutory_fee_tab s     '||
               '                                 WHERE t.company             = i.company                                         '||
               '                                 AND   t.identity            = i.identity                                        '||
               '                                 AND   t.party_type          = i.party_type                                      '||
               '                                 AND   t.invoice_template_no = i.invoice_template_no                             '||
               '                                 AND   t.item_id             = i.item_id                                         '||
               '                                 AND   t.company             = s.company                                         '||
               '                                 AND   t.fee_code            = s.fee_code                                        '||
               '                                 AND   s.fee_type           != ''IRS1099TX''                                     '||
               '                                 AND   NOT EXISTS (SELECT 1                                                      '||
               '                                                   FROM  source_tax_item_tab sti                                 '||
               '                                                   WHERE sti.company         = t.company                         '||
               '                                                   AND   sti.source_ref_type = ''INVOICE_TEMPLATE''              '||
               '                                                   AND   sti.source_ref1     = t.identity                        '||
               '                                                   AND   sti.source_ref2     = t.party_type                      '||
               '                                                   AND   sti.source_ref3     = t.invoice_template_no             '||
               '                                                   AND   sti.source_ref4     = TO_CHAR(t.item_id)                '||
               '                                                   AND   sti.source_ref5     = ''*''                             '||
               '                                                   AND   sti.tax_item_id     = t.tax_id))';
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Timestamp_5');
PROMPT Delete moved data from tax_item_template_tab
DECLARE
   stmt_     VARCHAR2(32000);
BEGIN
   IF Database_SYS.Table_Active('TAX_ITEM_TEMPLATE_TAB') THEN
      stmt_ := 'DELETE FROM tax_item_template_tab t                                 '||
               'WHERE  EXISTS (SELECT 1                                             '||
               '               FROM   Statutory_fee_tab s                           '||
               '               WHERE  s.company    = t.company                      '||
               '               AND    s.fee_code   = t.fee_code                     '||
               '               AND    s.fee_type  != ''IRS1099TX'')                 '||
               'AND    EXISTS (SELECT 1                                             '||
               '               FROM   source_tax_item_tab sti                       '||
               '               WHERE  sti.company         = t.company               '||
               '               AND    sti.source_ref_type = ''INVOICE_TEMPLATE''    '||
               '               AND    sti.source_ref1     = t.identity              '||
               '               AND    sti.source_ref2     = t.party_type            '||
               '               AND    sti.source_ref3     = t.invoice_template_no   '||
               '               AND    sti.source_ref4     = TO_CHAR(t.item_id)      '||
               '               AND    sti.source_ref5     = ''*''                   '||
               '               AND    sti.tax_item_id     = t.tax_id)';
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/

exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Timestamp_6');
PROMPT Create tax data in source_tax_item_tab using mixed_payment_man_posting_tab
DECLARE
   stmt_     VARCHAR2(32000);
BEGIN
   IF Database_SYS.Table_Active('MIXED_PAYMENT_MAN_POSTING_TAB') THEN
      stmt_ := 'INSERT INTO source_tax_item_tab(company,                                                                         '||
               '                                source_ref_type,                                                                 '||
               '                                source_ref1,                                                                     '||
               '                                source_ref2,                                                                     '||
               '                                source_ref3,                                                                     '||
               '                                source_ref4,                                                                     '||
               '                                source_ref5,                                                                     '||
               '                                tax_item_id,                                                                     '||
               '                                tax_code,                                                                        '||
               '                                tax_percentage,                                                                  '||
               '                                tax_curr_amount,                                                                 '||
               '                                tax_dom_amount,                                                                  '||
               '                                tax_parallel_amount,                                                             '||
               '                                tax_base_curr_amount,                                                            '||
               '                                tax_base_dom_amount,                                                             '||
               '                                tax_base_parallel_amount,                                                        '||
               '                                non_ded_tax_curr_amount,                                                         '||
               '                                non_ded_tax_dom_amount,                                                          '||
               '                                non_ded_tax_parallel_amount,                                                     '||
               '                                tax_limit_curr_amount,                                                           '||
               '                                transferred,                                                                     '||
               '                                rowversion,                                                                      '||
               '                                rowtype,                                                                         '||
               '                                rowkey)                                                                          '||
               '                               (SELECT t.company,                                                                '||
               '                                       ''DIRECT_CASH_PAYMENT'',                                                  '||
               '                                       TO_CHAR(t.mixed_payment_id),                                              '||
               '                                       TO_CHAR(t.lump_sum_trans_id),                                             '||
               '                                       TO_CHAR(t.manual_posting_id),                                             '||
               '                                       TO_CHAR(t.child_company),                                                 '||
               '                                       ''*'',                                                                    '||
               '                                       1,                                                                        '||
               '                                       t.optional_code,                                                          '||
               '                                       sf.fee_rate,                                                              '||
               '                                       NVL(t.tax_curr_amount, 0),                                                '||
               '                                       NVL(t.tax_dom_amount, 0),                                                 '||
               '                                       t.tax_parallel_amount,                                                    '||
               '                                       NVL(DECODE(sf.deductible, 100, t.curr_amount,          ROUND(((t.curr_amount + t.tax_curr_amount)/(1+ sf.fee_rate/100)), Currency_Code_API.Get_currency_rounding(t.child_company, ls.currency))), 0)                                 tax_base_curr_amount,         '||
               '                                       NVL(DECODE(sf.deductible, 100, t.dom_amount,           ROUND(((t.dom_amount + t.tax_dom_amount)/(1+ sf.fee_rate/100)), Currency_Code_API.Get_currency_rounding(t.child_company, c.currency_code))), 0)                               tax_base_dom_amount,          '||
               '                                       DECODE(sf.deductible, 100, t.amount_in_third_curr, ROUND(((t.amount_in_third_curr + t.tax_parallel_amount)/(1+ sf.fee_rate/100)), Currency_Code_API.Get_currency_rounding(t.child_company, c.parallel_acc_currency)))                tax_base_parallel_amount,     '||
               '                                       DECODE(sf.deductible, 100, 0,                      ROUND(((t.curr_amount*sf.fee_rate - 100*t.tax_curr_amount)/(100 + sf.fee_rate)), Currency_Code_API.Get_currency_rounding(t.child_company, ls.currency)))                          non_ded_tax_curr_amount ,     '||
               '                                       DECODE(sf.deductible, 100, 0,                      ROUND(((t.dom_amount*sf.fee_rate - 100*t.tax_dom_amount)/(100 + sf.fee_rate)), Currency_Code_API.Get_currency_rounding(t.child_company, c.currency_code)))                        non_ded_tax_dom_amount,       '||
               '                                       DECODE(sf.deductible, 100, 0,                      ROUND(((t.amount_in_third_curr*sf.fee_rate - 100*t.tax_parallel_amount)/(100 + sf.fee_rate)), Currency_Code_API.Get_currency_rounding(t.child_company, c.parallel_acc_currency))) non_ded_tax_parallel_amount , '||
               '                                       0,                                                                        '||
               '                                       ''FALSE'',                                                                '||
               '                                       SYSDATE,                                                                  '||
               '                                       ''SourceTaxItemPayled'',                                                  '||
               '                                       sys_guid()                                                                '||
               '                                FROM mixed_payment_man_posting_tab t, statutory_fee_tab sf, mixed_payment_lump_sum_tab ls, company_finance_tab c  '||
               '                                WHERE t.child_company  = sf.company                                              '||
               '                                AND   t.optional_code  = sf.fee_code                                             '||
               '                                AND   t.child_company      = ls.company                                          '||
               '                                AND   t.mixed_payment_id   = ls.mixed_payment_id                                 '||
               '                                AND   t.lump_sum_trans_id  = ls.lump_sum_trans_id                                '||
               '                                AND   t.child_company      = c.company                                           '||
               '                                AND   (posting_type IS NULL  OR  posting_type NOT IN (''PP44'', ''PP45'', ''PP46'', ''PP47''))' ||
               '                                AND NOT EXISTS (SELECT 1                                                         '||
               '                                                FROM source_tax_item_tab s                                       '||
               '                                                WHERE s.company         = t.company                              '||
               '                                                AND   s.source_ref_type = ''DIRECT_CASH_PAYMENT''                '||
               '                                                AND   s.source_ref1     = TO_CHAR(t.mixed_payment_id)            '||
               '                                                AND   s.source_ref2     = TO_CHAR(t.lump_sum_trans_id)           '||
               '                                                AND   s.source_ref3     = TO_CHAR(t.manual_posting_id)           '||
               '                                                AND   s.source_ref4     = t.child_company                        '||
               '                                                AND   s.source_ref5     = ''*''                                  '||
               '                                                AND   s.tax_item_id     = 1))';
      EXECUTE IMMEDIATE stmt_;
      COMMIT;
   END IF;
END;
/
exec Database_SYS.Log_Detail_Time_Stamp('ACCRUL','Post_Accrul_MoveTaxDataToSourceTaxItemTab.sql','Done');
