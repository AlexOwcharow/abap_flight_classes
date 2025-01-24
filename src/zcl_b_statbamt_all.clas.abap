CLASS zcl_b_statbamt_all DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_b_statbamt_all IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Define types
    TYPES: BEGIN OF ty_flight,
             flight_date   TYPE /dmo/flight_date,
             carrier_id    TYPE /dmo/carrier_id,
             connection_id TYPE /dmo/connection_id,
             airport_to    TYPE /dmo/airport_id,
             airport_from  TYPE /dmo/airport_id,
             name          TYPE /dmo/airport_name,
             city          TYPE /dmo/city,
             country       TYPE land1,
           END OF ty_flight.

    DATA lt_flights TYPE TABLE OF ty_flight.

    " Fetch flight data
    SELECT f~flight_date,
           f~carrier_id,
           f~connection_id,
           c~airport_to_id,
           c~airport_from_id,
           a~name,
           a~city,
           a~country
      FROM /dmo/flight AS f
             INNER JOIN
               /dmo/connection AS c ON f~connection_id = c~connection_id
                 INNER JOIN
                   /dmo/airport AS a ON c~airport_from_id = a~airport_id
                     INNER JOIN
                       /dmo/airport AS ai ON c~airport_to_id = ai~airport_id
      INTO TABLE @lt_flights.

    TYPES: BEGIN OF ty_country_from_count,
             country_from TYPE land1,
             flight_count TYPE i,
           END OF ty_country_from_count.
    TYPES: BEGIN OF ty_country_to_count,
             country_to   TYPE land1,
             flight_count TYPE i,
           END OF ty_country_to_count.

    TYPES: BEGIN OF ty_city_from_count,
             city_from    TYPE /dmo/city,
             flight_count TYPE i,
           END OF ty_city_from_count.
    TYPES: BEGIN OF ty_city_to_count,
             city_to      TYPE /dmo/city,
             flight_count TYPE i,
           END OF ty_city_to_count.

    TYPES: BEGIN OF ty_airport_from_count,
             airport_from TYPE /dmo/airport_id,
             flight_count TYPE i,
           END OF ty_airport_from_count.
    TYPES: BEGIN OF ty_airport_to_count,
             airport_to   TYPE /dmo/airport_id,
             flight_count TYPE i,
           END OF ty_airport_to_count.

    DATA lt_country_from_count TYPE TABLE OF ty_country_from_count.
    DATA lt_country_to_count   TYPE TABLE OF ty_country_to_count.
    DATA lt_city_from_count    TYPE TABLE OF ty_city_from_count.
    DATA lt_city_to_count      TYPE TABLE OF ty_city_to_count.
    DATA lt_airport_from_count TYPE TABLE OF ty_airport_from_count.
    DATA lt_airport_to_count   TYPE TABLE OF ty_airport_to_count.

    FIELD-SYMBOLS <fs_country_from_count> LIKE LINE OF lt_country_from_count.
    FIELD-SYMBOLS <fs_city_from_count>    LIKE LINE OF lt_city_from_count.
    FIELD-SYMBOLS <fs_airport_from_count> LIKE LINE OF lt_airport_from_count.
    FIELD-SYMBOLS <fs_country_to_count>   LIKE LINE OF lt_country_to_count.
    FIELD-SYMBOLS <fs_city_to_count>      LIKE LINE OF lt_city_to_count.
    FIELD-SYMBOLS <fs_airport_to_count>   LIKE LINE OF lt_airport_to_count.



    " Calculate airport FROM counts
    LOOP AT lt_flights INTO DATA(ls_flight).
      " Airport FROM counts
      LOOP AT lt_airport_from_count ASSIGNING <fs_airport_from_count>
           WHERE airport_from = ls_flight-airport_from.
        <fs_airport_from_count>-flight_count += 1.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        APPEND VALUE #( airport_from = ls_flight-airport_from
                        flight_count = 1 ) TO lt_airport_from_count.
      ENDIF.

      " Airport TO counts
      LOOP AT lt_airport_to_count ASSIGNING <fs_airport_to_count>
           WHERE airport_to = ls_flight-airport_to.
        <fs_airport_to_count>-flight_count += 1.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        APPEND VALUE #( airport_to   = ls_flight-airport_to
                        flight_count = 1 ) TO lt_airport_to_count.
      ENDIF.

      " City FROM counts
      LOOP AT lt_city_from_count ASSIGNING <fs_city_from_count>
           WHERE city_from = ls_flight-city.
        <fs_city_from_count>-flight_count += 1.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        APPEND VALUE #( city_from    = ls_flight-city
                        flight_count = 1 ) TO lt_city_from_count.
      ENDIF.

      " City TO counts
      LOOP AT lt_city_to_count ASSIGNING <fs_city_to_count>
           WHERE city_to = ls_flight-city.
        <fs_city_to_count>-flight_count += 1.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        APPEND VALUE #( city_to      = ls_flight-city
                        flight_count = 1 ) TO lt_city_to_count.
      ENDIF.

      " Country FROM counts
      LOOP AT lt_country_from_count ASSIGNING <fs_country_from_count>
           WHERE country_from = ls_flight-country.
        <fs_country_from_count>-flight_count += 1.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        APPEND VALUE #( country_from = ls_flight-country
                        flight_count = 1 ) TO lt_country_from_count.
      ENDIF.

      " Country TO counts
      LOOP AT lt_country_to_count ASSIGNING <fs_country_to_count>
           WHERE country_to = ls_flight-country.
        <fs_country_to_count>-flight_count += 1.
        EXIT.
      ENDLOOP.

      IF sy-subrc <> 0.
        APPEND VALUE #( country_to   = ls_flight-country
                        flight_count = 1 ) TO lt_country_to_count.
      ENDIF.
    ENDLOOP.
    " Output the results

    " ========================= Airport FROM Counts =========================
    DATA(lv_airport_from_header) = |{ 'Airport From' WIDTH = 13 }| &&
                                   |{ 'Flight Count' WIDTH = 15 }|.

    out->write( lv_airport_from_header ).

    LOOP AT lt_airport_from_count INTO DATA(ls_airport_from_count).
      DATA(lv_airport_from_row) = |{ ls_airport_from_count-airport_from WIDTH = 13 }| &&
                                  |{ ls_airport_from_count-flight_count WIDTH = 15 }|.
      out->write( lv_airport_from_row ).
    ENDLOOP.

    " Spacer row
    out->write( |----------------------| ).

    " ========================= Airport TO Counts =========================
    DATA(lv_airport_to_header) = |{ 'Airport To' WIDTH = 11 }| &&
                                 |{ 'Flight Count' WIDTH = 15 }|.

    out->write( lv_airport_to_header ).

    LOOP AT lt_airport_to_count INTO DATA(ls_airport_to_count).
      DATA(lv_airport_to_row) = |{ ls_airport_to_count-airport_to WIDTH = 11 }| &&
                                |{ ls_airport_to_count-flight_count WIDTH = 15 }|.
      out->write( lv_airport_to_row ).
    ENDLOOP.

    " Spacer row
    out->write( |----------------------| ).

    " ========================= City FROM Counts =========================
    DATA(lv_city_from_header) = |{ 'City From' WIDTH = 26 }| &&
                                |{ 'Flight Count' WIDTH = 15 }|.

    out->write( lv_city_from_header ).

    LOOP AT lt_city_from_count INTO DATA(ls_city_from_count).
      DATA(lv_city_from_row) = |{ ls_city_from_count-city_from WIDTH = 26 }| &&
                               |{ ls_city_from_count-flight_count WIDTH = 15 }|.
      out->write( lv_city_from_row ).
    ENDLOOP.

    " Spacer row
    out->write( |----------------------| ).

    " ========================= City TO Counts =========================
    DATA(lv_city_to_header) = |{ 'City To' WIDTH = 26 }| &&
                              |{ 'Flight Count' WIDTH = 15 }|.

    out->write( lv_city_to_header ).

    LOOP AT lt_city_to_count INTO DATA(ls_city_to_count).
      DATA(lv_city_to_row) = |{ ls_city_to_count-city_to WIDTH = 26 }| &&
                             |{ ls_city_to_count-flight_count WIDTH = 15 }|.
      out->write( lv_city_to_row ).
    ENDLOOP.

    " Spacer row
    out->write( |----------------------| ).

    " ========================= Country FROM Counts =========================
    DATA(lv_country_from_header) = |{ 'Country From' WIDTH = 13 }| &&
                                   |{ 'Flight Count' WIDTH = 15 }|.

    out->write( lv_country_from_header ).

    LOOP AT lt_country_from_count INTO DATA(ls_country_from_count).
      DATA(lv_country_from_row) = |{ ls_country_from_count-country_from WIDTH = 13 }| &&
                                  |{ ls_country_from_count-flight_count WIDTH = 15 }|.
      out->write( lv_country_from_row ).
    ENDLOOP.

    " Spacer row
    out->write( |----------------------| ).

    " ========================= Country TO Counts =========================
    DATA(lv_country_to_header) = |{ 'Country To' WIDTH = 11 }| &&
                                 |{ 'Flight Count' WIDTH = 15 }|.

    out->write( lv_country_to_header ).

    LOOP AT lt_country_to_count INTO DATA(ls_country_to_count).
      DATA(lv_country_to_row) = |{ ls_country_to_count-country_to WIDTH = 11 }| &&
                                |{ ls_country_to_count-flight_count WIDTH = 15 }|.
      out->write( lv_country_to_row ).
    ENDLOOP.

    " Spacer row
    out->write( |----------------------| ).
  ENDMETHOD.
ENDCLASS.
