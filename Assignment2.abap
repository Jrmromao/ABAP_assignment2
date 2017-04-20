************************************************************************
* Program Title: Assignment two                                        *
* Program : ztest_joao                                                 *
* Created By : Joao Filipe Romao                                       *
* Create Date : 10/04/17                                               *
* Description : Abap training - fetch data fron the a database         *
*               and present the data in a ALV grid                     *
* CPR No. :                                                            *
************************************************************************
* Modification history:                                                *
************************************************************************
* Date:    Programmer:     CPR # Defect# Reviewer        Review Date   *
* -------- --------------- ----- ------- --------------- -----------   *
* DD/MM/YY                                               DD/MM/YY      *
*                                                                      *
* ->Description:                                                       *
*----------------------------------------------------------------------*
REPORT  ZTEST_JOAO.

TYPE-POOLS: SLIS.

*----------------------------------------------------------------------*
*   declare the types that will hold the values received               *
*   when joining the two table, EKKO and EKPO                          *                                   *
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_ekko_ekpo,
    lv_com_code TYPE ekko-BUKRS,
    lv_doc_num TYPE EKPO-EBELN,
    lv_pur_document TYPE ekko-BSART,
    lv_vendor_acc TYPE ekko-LIFNR,
    lv_plant TYPE ekpo-WERKS,
    lv_pur_order_qty type ekpo-MENGE,
    lv_net_price_doc type ekpo-NETPR,
    lv_deleted_rec TYPE EKPO-LOEKZ,
    lv_total_sales TYPE p DECIMALS 2,
  END OF ty_ekko_ekpo.



*----------------------------------------------------------------------*
*           if an error is thrown,  Ref variabel to outpuT the error   *
*           message being caught                                       *
*----------------------------------------------------------------------*
DATA: oref   TYPE REF TO cx_root,
           text   TYPE string,
           numIndex TYPE i,
           num2 TYPE i.

*----------------------------------------------------------------------*
*           declare the internal table and variables                   *                                                      *
*----------------------------------------------------------------------*

DATA: it_joinned_table TYPE TABLE OF ty_ekko_ekpo,
      p_comp_code TYPE ekko-BUKRS,
      p_creation_date TYPE ekpo-AEDAT,
      p_plant TYPE ekpo-WERKS.

*----------------------------------------------------------------------*
*     *select option to grabe the user input                           *
*----------------------------------------------------------------------*

DATA: it_field TYPE SLIS_T_FIELDCAT_ALV,
      wa_field TYPE SLIS_FIELDCAT_ALV.

*---------------------------------------------------------------------*
*        FIELD-SYMBOLS <fs_ekko_ekpo> TYPE ty_ekko_ekpo               *
*---------------------------------------------------------------------*
FIELD-SYMBOLS: <fs_ekko_ekpo> TYPE ty_ekko_ekpo.

SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-001.


SELECT-OPTIONS: ls_cCode FOR p_comp_code OBLIGATORY.
SELECT-OPTIONS: ls_cDate FOR p_creation_date.
SELECT-OPTIONS: ls_plant FOR p_plant.

*----------------------------------------------------------------------*
* Checkbox - if this checkbox is selected, the system will             *
*            fetch the deleted records from the database, else do not  *
*            do not get show the deleted records                       *
*----------------------------------------------------------------------*
PARAMETERS:lc_drec AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK frame1.
*----------------------------------------------------------------------*
*       select query to join two tables                                *
*       if checkbox is checked, perform the first select               *
*       quesry that will fetch the deleted records                     *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  TRY .
      SELECT EKKO~BUKRS " company code
             EKPO~EBELN " document number
             EKKO~BSART " purchase doc
             EKKO~LIFNR " vendor
             EKPO~WERKS " plant
             EKPO~MENGE " order qty
             EKPO~NETPR " price doc
             EKPO~LOEKZ " deleted doc
             FROM EKKO
             JOIN EKPO
             ON EKKO~EBELN EQ EKPO~EBELN
             INTO TABLE it_joinned_table WHERE EKKO~BUKRS IN ls_cCode AND EKPO~AEDAT in ls_cDate AND EKPO~WERKS in ls_plant.

*----------------------------------------------------------------------*
*     if interior table is empty, output a message to the screen       *
*----------------------------------------------------------------------*
      IF it_joinned_table[] IS INITIAL.
        WRITE: /'|     NO RECORDS TO SHOW!   |'.
      ELSE.
        LOOP AT it_joinned_table ASSIGNING <fs_ekko_ekpo>.
          IF lc_drec <> 'X'.
            DELETE it_joinned_table WHERE lv_deleted_rec = 'L'. " if the does not tick the "show deleted records" option
                                                                " the system will deleted the deeted records from the iterior table.
          ENDIF.

          <fs_ekko_ekpo>-lv_total_sales = <fs_ekko_ekpo>-lv_net_price_doc * <fs_ekko_ekpo>-lv_pur_order_qty.   " calculate Total sales
        ENDLOOP.

        wa_field-fieldname  = 'LV_COM_CODE'.
        wa_field-col_pos    = 1.
        wa_field-seltext_m  = 'Company Code'(002).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_DOC_NUM'.
        wa_field-col_pos    = 2.
        wa_field-seltext_m  = 'Document Number'(012).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_PUR_DOCUMENT'.
        wa_field-col_pos    = 3.
        wa_field-seltext_m  = 'Purchasing Document Type'(003).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_VENDOR_ACC'.
        wa_field-col_pos    = 4.
        wa_field-seltext_m  = 'Prod Vendor'(004).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_PLANT'.
        wa_field-col_pos    = 5.
        wa_field-seltext_m  = 'Plant'(005).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_NET_PRICE_DOC'.
        wa_field-col_pos    = 6.
        wa_field-seltext_m  = 'Net Price in Purchasing Document'(006).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_PUR_ORDER_QTY'.
        wa_field-col_pos    = 7.
        wa_field-seltext_m  = 'Order Qty'(007).
        APPEND wa_field to it_field.

        wa_field-fieldname  = 'LV_TOTAL_SALES'.
        wa_field-col_pos    = 8.
        wa_field-seltext_m  = 'Total Sale'(008).
        APPEND wa_field to it_field.
*----------------------------------------------------------------------*
*      show deleted records column if the checkbox is selected         *
*----------------------------------------------------------------------*
     IF lc_drec = 'X'.
        wa_field-fieldname  = 'LV_DELETED_REC'.
        wa_field-col_pos    = 9.
        wa_field-seltext_m  = 'Delete Records'(011).
        APPEND wa_field to it_field.
     ENDIF.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            IT_FIELDCAT = it_field
          TABLES
            T_OUTTAB    = it_joinned_table.
      ENDIF.
*----------------------------------------------------------------------*
*   if aan error is generated, catch the error and                     *
*   output this error to the screen                                    *
*----------------------------------------------------------------------*
    CATCH cx_root INTO oref.
      text = oref->get_text( ).
      WRITE: 'ERROR: ', text.
  ENDTRY.

end-OF-SELECTION.
