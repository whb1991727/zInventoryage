CLASS zcl_material_stock_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MATERIAL_STOCK_AGE IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      TYPES BEGIN OF ty_value.
      TYPES: quantity TYPE i_stockquantitycurrentvalue_2-matlwrhsstkqtyinmatlbaseunit,
             value    TYPE i_stockquantitycurrentvalue_2-stockvalueindisplaycurrency.
      TYPES END OF ty_value.

      TYPES:
        BEGIN OF ty_range_option,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    TYPE string,
          high   TYPE string,
        END OF ty_range_option.


      DATA: lt_response        TYPE TABLE OF z_material_stock_age,
            ls_response        LIKE LINE OF lt_response,
            lt_responseout     LIKE lt_response,
            ls_responseout     LIKE LINE OF lt_responseout,
            lt_response_period TYPE TABLE OF z_material_stock_age,
            ls_response_period LIKE LINE OF lt_response_period,
            lt_value           TYPE TABLE OF ty_value,
            ls_value           TYPE ty_value,
            lv_price           TYPE p DECIMALS 2,
            lt_configr         TYPE TABLE OF ty_range_option,
            ls_configr         LIKE LINE OF lt_configr.


      DATA(lv_top)           = io_request->get_paging( )->get_page_size( ).
      DATA(lv_skip)          = io_request->get_paging( )->get_offset( ).
      DATA(lv_max_rows) = COND #( WHEN lv_top = if_rap_query_paging=>page_size_unlimited THEN 0
                                  ELSE lv_top ).

      DATA(lt_clause)        = io_request->get_filter( )->get_as_ranges( ).
      DATA(lt_parameter)     = io_request->get_parameters( ).
      DATA(lt_fields)        = io_request->get_requested_elements( ).
      DATA(lt_sort)          = io_request->get_sort_elements( ).

      TRY.
          DATA(lt_filter_cond) = io_request->get_filter( )->get_as_ranges( ).
        CATCH cx_rap_query_filter_no_range INTO DATA(lx_no_sel_option).
      ENDTRY.

****************************Data selection and business logics goes here*********************************
      LOOP AT lt_parameter ASSIGNING FIELD-SYMBOL(<fs_p>).
        CASE <fs_p>-parameter_name.
          WHEN 'P_KEYDATE'.   DATA(p_keydate) = <fs_p>-value.
        ENDCASE.
      ENDLOOP.

      LOOP AT lt_filter_cond INTO DATA(ls_filter_cond).
        IF ls_filter_cond-name = 'STROAGELOCATION'.
          DATA(lt_storagelocation) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'MATERIAL'.
          DATA(lt_material) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'PLANT'.
          DATA(lt_plant) = ls_filter_cond-range[].
        ELSEIF  ls_filter_cond-name = 'COMPANYCODE'.
          DATA(lt_bukrs) = ls_filter_cond-range[].
        ENDIF.
      ENDLOOP.

*get configuration data
      SELECT * FROM zmovementtype WHERE bukrs IN @lt_bukrs
                                  AND inuse = @abap_true
                                  INTO TABLE @DATA(lt_config).

      LOOP AT lt_config INTO DATA(ls_config).
        ls_configr-sign = 'I'.
        ls_configr-option = 'EQ'.
        ls_configr-low = ls_config-movementtype.
        APPEND ls_configr TO lt_configr.
        CLEAR ls_configr.
      ENDLOOP.

*get inventory information based on date
      SELECT *
      FROM i_materialstock_2
      WHERE storagelocation IN @lt_storagelocation
      AND material IN @lt_material
      AND matldoclatestpostgdate <= @p_keydate
      AND plant IN @lt_plant
      AND companycode IN  @lt_bukrs
      INTO TABLE @DATA(lt_stock).

      LOOP AT lt_stock INTO DATA(ls_stock).
        ls_response-companycode = ls_stock-companycode.
        ls_response-plant = ls_stock-plant.
        ls_response-material = ls_stock-material.
        ls_response-stroagelocation = ls_stock-storagelocation.
        ls_response-currentstock = ls_stock-matlwrhsstkqtyinmatlbaseunit.
        COLLECT ls_response INTO lt_response.
      ENDLOOP.

*period start date calculation
      DATA lv_30 TYPE d.
      DATA lv_60 TYPE d.
      DATA cd TYPE d.
      cd = p_keydate.
      lv_30 = cd - 30.
      lv_60 = cd - 60.

*get material movement history
      SELECT *
      FROM i_materialdocumentitem_2
      FOR ALL ENTRIES IN @lt_response
      WHERE storagelocation = @lt_response-stroagelocation
      AND postingdate <= @p_keydate
      AND plant IN @lt_plant
      AND companycode IN @lt_bukrs
      AND material = @lt_response-material
      AND goodsmovementtype in @lt_configr
      AND goodsmovementiscancelled IS INITIAL
      INTO TABLE @DATA(lt_movement).

      DATA(lt_movement_reverse) = lt_movement[].

      LOOP AT lt_movement INTO DATA(ls_movement).
        READ TABLE lt_movement_reverse WITH KEY  reversedmaterialdocumentyear = ls_movement-materialdocumentyear
                                                 reversedmaterialdocument = ls_movement-materialdocument
                                       TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          DELETE lt_movement FROM ls_movement.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_movement INTO ls_movement WHERE reversedmaterialdocument IS INITIAL.
        ls_response_period-companycode = ls_movement-companycode.
        ls_response_period-plant = ls_movement-plant.
        ls_response_period-material = ls_movement-material.
        ls_response_period-stroagelocation = ls_movement-storagelocation.
        ls_response_period-meins = ls_movement-materialbaseunit.
        ls_response_period-waers = ls_movement-companycodecurrency.

        IF ls_movement-postingdate > lv_30 AND ls_movement-postingdate <= cd.
          ls_response_period-period1 = ls_movement-quantityinbaseunit.
        ELSEIF ls_movement-postingdate > lv_60 AND ls_movement-postingdate <= lv_30.
          ls_response_period-period2 = ls_movement-quantityinbaseunit.
        ELSEIF ls_movement-postingdate <= lv_60.
          ls_response_period-period3 = ls_movement-quantityinbaseunit.
        ENDIF.

        COLLECT ls_response_period INTO lt_response_period.
        CLEAR ls_response_period.
      ENDLOOP.

      LOOP AT lt_response INTO ls_response.
        READ TABLE lt_response_period WITH KEY companycode = ls_response-companycode
                                               plant = ls_response-plant
                                               material = ls_response-material
                                               stroagelocation = ls_response-stroagelocation
                                      INTO ls_response_period.

*        ls_response-meins = ls_response_period-meins.
*        ls_response-waers = ls_response_period-waers.

        IF sy-subrc = 0.
* period 1 calculation with 30 days.
          IF ls_response-currentstock < ls_response_period-period1 AND ls_response_period-period1 > 0.
            ls_response-period1 = ls_response-currentstock.
          ELSE.
            ls_response-period1 = ls_response_period-period1.
          ENDIF.
* period 2 calculation between 30 days to 60 days.
          IF ( ls_response-currentstock - ls_response_period-period1 )  < 0.
            ls_response-period2 = 0.
          ELSEIF ( ls_response-currentstock - ls_response_period-period1 ) < ls_response_period-period2 AND ls_response_period-period2 > 0.
            ls_response-period2 = ls_response-currentstock - ls_response_period-period1.
          ELSEIF ( ls_response-currentstock - ls_response_period-period1 ) >= ls_response_period-period2.
            ls_response-period2 = ls_response_period-period2.
          ENDIF.
* period 3 calculation more than 60 days
          IF ( ls_response-currentstock - ls_response_period-period1 - ls_response_period-period2 )  < 0.
            ls_response-period3 = 0.
          ELSEIF ( ls_response-currentstock - ls_response_period-period1 - ls_response_period-period2 ) < ls_response_period-period3 AND ls_response_period-period3 > 0.
            ls_response-period3 = ls_response-currentstock - ls_response_period-period1 - ls_response_period-period2.
          ELSEIF ( ls_response-currentstock - ls_response_period-period1 - ls_response_period-period2 ) >= ls_response_period-period3.
            ls_response-period3 = ls_response_period-period3.
          ENDIF.

        ELSEIF sy-subrc > 0 AND ls_response-currentstock > 0.
          ls_response-period3 = ls_response-currentstock.
        ENDIF.

* getting price information
        SELECT SUM( matlwrhsstkqtyinmatlbaseunit ) AS quantity,
               SUM( stockvalueincccrcy ) AS value
               FROM i_stockquantitycurrentvalue_2( p_displaycurrency = 'CNY' )
               WHERE product = @ls_response-material
               AND plant = @ls_response-plant
               AND storagelocation = @ls_response-stroagelocation
               AND valuationareatype = 1
               GROUP BY product,plant,storagelocation
               INTO TABLE @lt_value.

        IF sy-subrc = 0.
          CLEAR: ls_value,
                 lv_price.
          READ TABLE lt_value INTO ls_value INDEX 1.
          IF ls_value-quantity NE 0.
            lv_price = ls_value-value / ls_value-quantity.
          ENDIF.
        ENDIF.

* calculate value information
        ls_response-currentvalue = ls_response-currentstock * lv_price.
        ls_response-period1_v = ls_response-period1 * lv_price.
        ls_response-period2_v = ls_response-period2 * lv_price.
        ls_response-period3_v = ls_response-period3 * lv_price.

        MODIFY lt_response FROM ls_response.
        CLEAR ls_response.
      ENDLOOP.

*paging way to return huge amount of data
      SORT lt_response BY stroagelocation material.
      lv_max_rows = lv_skip + lv_top.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      CLEAR lt_responseout.
      LOOP AT lt_response ASSIGNING FIELD-SYMBOL(<lfs_out_line_item>) FROM lv_skip TO lv_max_rows.
        ls_responseout = <lfs_out_line_item>.
        APPEND ls_responseout TO lt_responseout.
      ENDLOOP.

      io_response->set_total_number_of_records( lines( lt_response ) ).
      io_response->set_data( lt_responseout ).

    ENDIF.
  ENDMETHOD.
ENDCLASS.
