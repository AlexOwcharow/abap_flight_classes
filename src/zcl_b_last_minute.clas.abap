CLASS zcl_b_last_minute DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_b_last_minute IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Define the flight structure type
    TYPES: BEGIN OF ty_flight,
             flight_date     TYPE /dmo/flight_date,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             flight_price    TYPE /dmo/flight_price,
             currency_code   TYPE /dmo/currency_code,
             seats_available TYPE i,
             airport_to      TYPE /dmo/airport_id,
             airport_from    TYPE /dmo/airport_id,
             departure_time  TYPE /dmo/flight_departure_time,
             arrival_time    TYPE /dmo/flight_arrival_time,
           END OF ty_flight.

    DATA lt_flights     TYPE TABLE OF ty_flight.
    DATA lv_date_today  TYPE d.
    DATA lv_future_date TYPE d.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA lv_time_today  TYPE t.

    " Get the current system date using modern method call syntax
*    lv_date_today = cl_abap_context_info=>get_system_date( ).
    lv_date_today = '20250901'.
    lv_time_today = cl_abap_context_info=>get_system_time( ).

    " Calculate a future date (14 days later)
    lv_future_date = lv_date_today + 14.

    " Define the SQL query with the join and conditions
    SELECT f~flight_date,
           f~carrier_id,
           f~connection_id,
           f~price,
           f~currency_code,
           ( f~seats_max - f~seats_occupied ) AS seats_available,
           c~airport_to_id,
           c~airport_from_id,
           c~departure_time,
           c~arrival_time

      FROM /dmo/flight AS f

             INNER JOIN
               /dmo/connection AS c ON f~connection_id = c~connection_id
      WHERE ( f~seats_max - f~seats_occupied )  > 0
        AND f~flight_date <= @lv_future_date
        AND f~flight_date >= @lv_date_today
*         OR     c~departure_time                   <= @lv_time_today
*            AND f~flight_date = @lv_date_today
      INTO TABLE @lt_flights.

    SORT lt_flights BY flight_date ASCENDING.

    IF lt_flights IS INITIAL.
      out->write( 'Keine verfügbaren Flüge in den nächsten 14 Tagen' ).
      out->write( lv_date_today ).
      RETURN.
    ENDIF.

    DELETE lt_flights WHERE airport_from <> 'FRA'.

    DATA lv_max_price_length    TYPE i.
    DATA lv_price_length        TYPE i.
    DATA lv_max_currency_length TYPE i.
    DATA lv_currency_length     TYPE i.

    lv_max_price_length = 0.
    lv_max_currency_length = 0.

    " Calculate the maximum width of the price column
    LOOP AT lt_flights INTO DATA(ls_flight).
      lv_price_length = strlen( |{ ls_flight-flight_price }| ).
      lv_currency_length = strlen( |{ ls_flight-currency_code }| ).
      IF lv_price_length > lv_max_price_length.
        lv_max_price_length = lv_price_length.
      ENDIF.
      IF lv_currency_length > lv_max_currency_length.
        lv_max_currency_length = lv_currency_length.
      ENDIF.

      IF ls_flight-currency_code = 'USD'.
        out->write( 'blob' ).
        DATA A TYPE P decimals 2.
        A = '0.96'.
        ls_flight-flight_price = ls_flight-flight_price * A.
        ls_flight-currency_code = 'EUR'.
      ELSEIF ls_flight-currency_code = 'JPY'.
        DATA B TYPE P decimals 4.
        B = '0.0061'.
        ls_flight-flight_price = ls_flight-flight_price * B.
        ls_flight-currency_code = 'EUR'.
       ENDIF.
      MODIFY lt_flights FROM ls_flight.
      ENDLOOP.

    " Define a header line
    DATA(lv_header) = |{ 'Flugdatum' WIDTH = 10 }| &&
                      | { 'Fluggesellschaft' WIDTH = 16 }| &&
                      | { 'Verbindung' WIDTH = 10 }| &&
                      | { 'Flugpreis' WIDTH = lv_max_price_length + lv_max_currency_length + 2 }| &&
                      | { 'Sitze verfügbar' WIDTH = 15 }| &&
                      | { 'Abflugort' WIDTH = 8 }| &&
                      | { 'Ziel' WIDTH = 4 }| &&
                      | { 'Abflugszeit' WIDTH = 12 }| &&
                      | { 'Ankunftszeit' WIDTH = 16 }|.

    " Output the header
    out->write( lv_header ).

    " Loop through the data and output each row in a formatted way
    LOOP AT lt_flights INTO ls_flight.
      DATA(lv_row) = |{ ls_flight-flight_date DATE = ISO WIDTH = 10 }| &&
                     | { ls_flight-carrier_id WIDTH = 16 }| &&
                     | { ls_flight-connection_id WIDTH = 10 }| &&
                     | { ls_flight-flight_price WIDTH = lv_max_price_length } { ls_flight-currency_code WIDTH = lv_max_currency_length + 1 }| &&
                     | { ls_flight-seats_available WIDTH = 15 }| &&
                     | { ls_flight-airport_from WIDTH = 9 }| &&
                     | { ls_flight-airport_to WIDTH = 4 }| &&
                     | { ls_flight-departure_time TIME = ISO WIDTH = 12 }| &&
                     | { ls_flight-arrival_time TIME = ISO WIDTH = 16 }|.

      " Write the formatted row
      out->write( lv_row ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
