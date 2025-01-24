CLASS zcl_b_statbamt2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_b_statbamt2 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA lv_flight_cnt TYPE i.
    DATA lv_flight_cnto TYPE i.               " Anzahl der Flüge
    TYPES: BEGIN OF ty_flight,
             country TYPE land1,
             name    TYPE /dmo/airport_name,
             city    TYPE /dmo/city,
           END OF ty_flight.

    DATA lt_flights     TYPE TABLE OF ty_flight.

    TYPES: BEGIN OF ty_land,
             land       TYPE string, " Land
             flight_cnt TYPE i,     " Anzahl der Flüge
           END OF ty_land.

    DATA lv_land    TYPE string.            " Einzelnes Land
    DATA lv_lando    TYPE string.            " Einzelnes Land


    DATA tl_country TYPE TABLE OF ty_land.
    DATA in_airport_name TYPE /dmo/airport_name.
    DATA in_city TYPE /dmo/city.
    DATA in_country TYPE land1.

    DATA lv_pick TYPE i VALUE 2.

    IF lv_pick = 0.
      in_airport_name = 'Frankfurt Airport'.
    ELSEIF lv_pick = 1.
      in_city = 'Frankfurt/Main'.
    ELSE.
      in_country = 'US'.
    ENDIF.

    DATA counterArr TYPE i VALUE 0.
    DATA counterDep TYPE i VALUE 0.

    DATA lv_name TYPE /dmo/airport_name.

    DATA lt_laender TYPE TABLE OF ty_land.   " Tabelle für Länder und Fluganzahlen
    DATA lt_laender2 TYPE TABLE OF ty_land.   " Tabelle für Länder und Fluganzahlen


    IF in_airport_name IS NOT INITIAL.
      SELECT
      a~name,
      a~city,
      a~country
        FROM /dmo/flight AS f
      INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
      INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id
      INNER JOIN /dmo/airport AS ai ON c~airport_to_id = ai~airport_id
      WHERE @in_airport_name = a~name OR @in_airport_name = ai~name
            INTO TABLE @lt_flights.




    ELSEIF in_city IS NOT INITIAL.
     SELECT DISTINCT a~city
         FROM /dmo/flight AS f
       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id

             INTO TABLE @lt_flights.


      out->write( 'rein:' ).

      LOOP AT lt_flights INTO lv_lando.


        SELECT COUNT( * )
        FROM /dmo/flight AS f

       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_to_id = a~airport_id

       WHERE
        a~city = @lv_lando


       INTO @lv_flight_cnt.
        APPEND VALUE #( land = lv_lando flight_cnt = lv_flight_cnto ) TO lt_laender.
      ENDLOOP.

      LOOP AT lt_laender INTO DATA(ls_lando).

        out->write( | City:  { ls_lando-land } Anzahl der Flüge: { ls_lando-flight_cnt } | ).

      ENDLOOP.

      out->write( 'raus:' ).

      LOOP AT lt_flights INTO lv_land.

        SELECT COUNT( * )
        FROM /dmo/flight AS f

       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id

       WHERE a~city = @lv_land
*       OR ai~country = @lv_land

       INTO @lv_flight_cnt.
        APPEND VALUE #( land = lv_land flight_cnt = lv_flight_cnt ) TO lt_laender2.
      ENDLOOP.

      LOOP AT lt_laender2 INTO DATA(ls_land).

        out->write( | City:  { ls_land-land } Anzahl der Flüge: { ls_land-flight_cnt } | ).
      ENDLOOP.





    ELSE.

      out->write( 'Land' ).
      SELECT DISTINCT a~country
         FROM /dmo/flight AS f
       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id

             INTO TABLE @lt_flights.


      out->write( 'rein:' ).

      LOOP AT lt_flights INTO lv_lando.


        SELECT COUNT( * )
        FROM /dmo/flight AS f

       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_to_id = a~airport_id

       WHERE
        a~country = @lv_lando


       INTO @lv_flight_cnto.
        APPEND VALUE #( land = lv_lando flight_cnt = lv_flight_cnto ) TO lt_laender.
      ENDLOOP.

      LOOP AT lt_laender INTO ls_lando.

        out->write( | Land:  { ls_lando-land } Anzahl der Flüge: { ls_lando-flight_cnt } | ).

      ENDLOOP.

      out->write( 'raus:' ).

      LOOP AT lt_flights INTO lv_land.

        SELECT COUNT( * )
        FROM /dmo/flight AS f

       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id

       WHERE a~country = @lv_land
*       OR ai~country = @lv_land

       INTO @lv_flight_cnt.
        APPEND VALUE #( land = lv_land flight_cnt = lv_flight_cnt ) TO lt_laender2.
      ENDLOOP.

      LOOP AT lt_laender2 INTO ls_land.

        out->write( | Land:  { ls_land-land } Anzahl der Flüge: { ls_land-flight_cnt } | ).
      ENDLOOP.



    ENDIF.



*
*    DATA(lv_header) = |{ 'Airport Name' WIDTH = 30 }| &&
*                  | { 'Stadt' WIDTH = 15 }| &&
*                  | { 'Land' WIDTH = 5 }|.
*
*    " Output the header
*    out->write( lv_header ).
*
*    " Loop through the data and output each row in a formatted way
*    LOOP AT lt_flights INTO DATA(ls_flight).
*
*      DATA(lv_row) =
*                     | { ls_flight-name WIDTH = 30 }| &&
*                     | { ls_flight-city WIDTH = 15 }| &&
*                     | { ls_flight-country WIDTH = 5 }|.
*      IF lv_pick = 0.
*        IF ls_flight-name = in_airport_name.
*          counterDep = counterDep + 1.
*        ELSE.
*          counterArr = counterArr + 1.
*        ENDIF.
*      ELSEIF lv_pick = 1.
*        IF ls_flight-city = in_city.
*          counterDep = counterDep + 1.
*        ELSE.
*          counterArr = counterArr + 1.
*        ENDIF.
*      ELSE.
*        IF ls_flight-country = in_country.
*          counterDep = counterDep + 1.
*        ELSE.
*          counterArr = counterArr + 1.
*        ENDIF.
*      ENDIF.
*
*      out->write( lv_row ).
*    ENDLOOP.
*
*    IF lv_pick = 0.
*      out->write( | Es gibt { counterDep } Flüge von { in_airport_name } | ).
*      out->write( | Es gibt { counterArr } Flüge nach { in_airport_name } | ).
*
*    ELSEIF lv_pick = 1.
*      out->write( | Es gibt { counterDep } Flüge von { in_city } | ).
*      out->write( | Es gibt { counterArr } Flüge nach { in_city } | ).
*    ELSE.
*      out->write( | Es gibt { counterDep } Flüge von { in_country } | ).
*      out->write( | Es gibt { counterArr } Flüge nach { in_country } | ).
*    ENDIF.




  ENDMETHOD.
ENDCLASS.
