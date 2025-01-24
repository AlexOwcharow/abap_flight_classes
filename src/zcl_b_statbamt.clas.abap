CLASS zcl_b_statbamt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_b_statbamt IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
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

    DATA lt_flights     TYPE TABLE OF ty_flight.



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

    IF in_airport_name IS NOT INITIAL.
      SELECT f~flight_date,
      f~carrier_id,
      f~connection_id,
      c~airport_to_id,
      c~airport_from_id,
      a~name,
      a~city,
      a~country
        FROM /dmo/flight AS f
      INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
      INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id
      WHERE @in_airport_name = a~name "OR @in_airport_name = ai~name
            INTO TABLE @lt_flights.

    ELSEIF in_city IS NOT INITIAL.
      SELECT f~flight_date,
     f~carrier_id,
     f~connection_id,
     c~airport_to_id,
     c~airport_from_id,
     a~name,
     a~city,
     a~country
       FROM /dmo/flight AS f
     INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
     INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id
     INNER JOIN /dmo/airport as ai ON c~airport_to_id = ai~airport_id
     WHERE @in_city = a~city OR @in_city = ai~city
           INTO TABLE @lt_flights.
    ELSE.
      SELECT f~flight_date,
       f~carrier_id,
       f~connection_id,
       c~airport_to_id,
       c~airport_from_id,
       a~name,
       a~city,
       a~country
         FROM /dmo/flight AS f
       INNER JOIN /dmo/connection AS c ON f~connection_id = c~connection_id
       INNER JOIN /dmo/airport AS a ON c~airport_from_id = a~airport_id
       INNER JOIN /dmo/airport as ai ON c~airport_to_id = ai~airport_id

       WHERE @in_country = a~country
       OR @in_country = ai~country
             INTO TABLE @lt_flights.
    ENDIF.

    DATA(lv_header) = |{ 'Flugdatum' WIDTH = 10 }| &&
                  | { 'Fluggesellschaft' WIDTH = 16 }| &&
                  | { 'Verbindung' WIDTH = 10 }| &&
                  | { 'Abflugort' WIDTH = 8 }| &&
                  | { 'Ziel' WIDTH = 4 }| &&
                  | { 'Airport Name' WIDTH = 30 }| &&
                  | { 'Stadt' WIDTH = 15 }| &&
                  | { 'Land' WIDTH = 5 }|.

    " Output the header
    out->write( lv_header ).

    " Loop through the data and output each row in a formatted way
    LOOP AT lt_flights INTO DATA(ls_flight).

      DATA(lv_row) = |{ ls_flight-flight_date DATE = ISO WIDTH = 10 }| &&
                     | { ls_flight-carrier_id WIDTH = 16 }| &&
                     | { ls_flight-connection_id WIDTH = 10 }| &&
                     | { ls_flight-airport_from WIDTH = 9 }| &&
                     | { ls_flight-airport_to WIDTH = 4 }| &&
                     | { ls_flight-name WIDTH = 30 }| &&
                     | { ls_flight-city WIDTH = 15 }| &&
                     | { ls_flight-country WIDTH = 5 }|.
      IF lv_pick = 0.
        IF ls_flight-name = in_airport_name.
        counterDep = counterDep + 1.
        ELSE.
          counterArr = counterArr + 1.
        ENDIF.
      ELSEIF lv_pick = 1.
        IF ls_flight-city = in_city.
        counterDep = counterDep + 1.
        ELSE.
          counterArr = counterArr + 1.
        ENDIF.
      ELSE.
      IF ls_flight-country = in_country.
        counterDep = counterDep + 1.
        ELSE.
          counterArr = counterArr + 1.
        ENDIF.
        ENDIF.

      out->write( lv_row ).
    ENDLOOP.

    IF lv_pick = 0.
      out->write( | Es gibt { counterDep } Flüge von { in_airport_name } | ).
      out->write( | Es gibt { counterArr } Flüge nach { in_airport_name } | ).

    ELSEIF lv_pick = 1.
      out->write( | Es gibt { counterDep } Flüge von { in_city } | ).
      out->write( | Es gibt { counterArr } Flüge nach { in_city } | ).
    ELSE.
      out->write( | Es gibt { counterDep } Flüge von { in_country } | ).
      out->write( | Es gibt { counterArr } Flüge nach { in_country } | ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
