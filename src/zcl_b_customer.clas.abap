CLASS zcl_b_customer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_b_customer IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TYPES: BEGIN OF ty_booking,
             booking_id      TYPE /dmo/booking_id,
             customer_id     TYPE /dmo/customer_id,
             flight_date     TYPE /dmo/flight_date,
             flight_price    TYPE /dmo/flight_price,
             currency_code   TYPE /dmo/currency_code,
             booking_date    TYPE /dmo/booking_date,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             airport_from_id TYPE /dmo/airport_id,            " Ensure correct type
             airport_to_id   TYPE /dmo/airport_id,            " Ensure correct type
             departure_time  TYPE /dmo/flight_departure_time, " Ensure correct type
             arrival_time    TYPE /dmo/flight_arrival_time,   " Ensure correct type
             distance        TYPE /dmo/flight_distance,       " Ensure correct type
             distance_unit   TYPE msehi,                      " Ensure correct type
             plane_type_id   TYPE /dmo/plane_type_id,
             latest_check_in TYPE t,
             boarding_time   TYPE t,
           END OF ty_booking.

    DATA lv_current_date TYPE sy-datum.
    DATA lv_current_time TYPE sy-uzeit.
    DATA lt_bookings     TYPE TABLE OF ty_booking.                     " Interne Tabelle für die Abfrage
    DATA lv_customer_id  TYPE /dmo/customer_id. " Beispielhafte Customer-ID
*    DATA lv_line         TYPE string.           " String für formatierten Output

    " Beispielhafte Customer-ID (hart codiert)
    lv_customer_id = '000001'.
    " Get the current date and time
    lv_current_date = sy-datum.
    lv_current_time = sy-uzeit.

    " Join /DMO/BOOKING and /DMO/CONNECTION based on carrier_id and connection_id
    SELECT DISTINCT b~booking_id,
                    b~customer_id,
                    b~flight_date,
                    b~flight_price,
                    b~currency_code,
                    b~booking_date,
                    c~carrier_id,
                    c~connection_id,
                    c~airport_from_id,
                    c~airport_to_id,
                    c~departure_time,
                    c~arrival_time,
                    c~distance,
                    c~distance_unit,
                    f~plane_type_id
      FROM /dmo/booking AS b
             INNER JOIN
               /dmo/connection AS c ON  b~carrier_id    = c~carrier_id
                                    AND b~connection_id = c~connection_id
                 INNER JOIN
                   /dmo/flight AS f ON  c~carrier_id    = f~carrier_id
                                    AND c~connection_id = f~connection_id
                                    AND b~flight_date   = f~flight_date
                     INNER JOIN
                       /dmo/customer AS cu ON b~customer_id = cu~customer_id
*    INNER JOIN /dmo/airport AS a
*    ON c~airport_to_id = a~airport_id
*    AND c~airport_to_id = a~airport_id
      WHERE b~customer_id = @lv_customer_id
      INTO TABLE @lt_bookings.

    " Prüfen, ob Daten vorhanden sind
    IF lt_bookings IS INITIAL.
      out->write( |Keine Buchungen für Customer ID:{ lv_customer_id }'| ).
      RETURN.
    ENDIF.

    DELETE lt_bookings WHERE    flight_date < lv_current_date
                             OR (     flight_date    = lv_current_date
                                  AND departure_time > lv_current_time ).

    LOOP AT lt_bookings INTO DATA(ls_booking).
      IF ls_booking-distance < 1000.
        ls_booking-latest_check_in = ls_booking-departure_time - '3600'.
        ls_booking-boarding_time   = ls_booking-departure_time - '900'.
      ELSEIF ls_booking-distance < 3000.
        ls_booking-latest_check_in = ls_booking-departure_time - '5400'.
        ls_booking-boarding_time   = ls_booking-departure_time - '1200'.
      ELSE.
        ls_booking-latest_check_in = ls_booking-departure_time - '7200'.
        ls_booking-boarding_time   = ls_booking-departure_time - '1800'.
      ENDIF.

      " Update the internal table
      MODIFY lt_bookings FROM ls_booking.
    ENDLOOP.

    SORT lt_bookings BY flight_date ASCENDING.

    DATA lv_max_price_length    TYPE i.
    DATA lv_price_length        TYPE i.
    DATA lv_max_currency_length TYPE i.
    DATA lv_currency_length     TYPE i.
    DATA lv_max_distance_length TYPE i.
    DATA lv_distance_length     TYPE i.

    lv_max_price_length = 0.
    lv_max_currency_length = 0.
    lv_max_distance_length = 0.

    " Calculate the maximum width of the price column
    LOOP AT lt_bookings INTO ls_booking.
      lv_price_length = strlen( |{ ls_booking-flight_price }| ).
      lv_currency_length = strlen( |{ ls_booking-currency_code }| ).
      lv_distance_length = strlen( |{ ls_booking-distance }| ).
      IF lv_price_length > lv_max_price_length.
        lv_max_price_length = lv_price_length.
      ENDIF.
      IF lv_currency_length > lv_max_currency_length.
        lv_max_currency_length = lv_currency_length.
      ENDIF.
      IF lv_distance_length > lv_max_distance_length.
        lv_max_distance_length = lv_distance_length.
      ENDIF.
    ENDLOOP.

    " Define a header line
    DATA(lv_header) = |{ 'Buchungsdatum' WIDTH = 13 }| &&
                      | { 'Flugdatum' WIDTH = 12 }| &&
                      | { 'Flugpreis' WIDTH = lv_max_price_length + lv_max_currency_length + 2 }| &&
                      | { 'Startflughafen' WIDTH = 13 }| &&
                      | { 'Zielflughafen' WIDTH = 13 }| &&
                      | { 'Abflugzeit' WIDTH = 10 }| &&
                      | { 'spätester Check-In' WIDTH = 15 }| &&
                      | { 'Boarding' WIDTH = 9 }| &&
                      | { 'Entfernung' WIDTH = lv_max_distance_length + 2 }| &&
                      | { 'Flugzeugtyp' WIDTH = 15 }|.

    " Output the header
    out->write( lv_header ).

    " Loop through the data and output each row in a formatted way
    LOOP AT lt_bookings INTO ls_booking.
      DATA(lv_row) = |{ ls_booking-booking_date DATE = ISO WIDTH = 13 }| &&
                     | { ls_booking-flight_date DATE = ISO WIDTH = 12 }| &&
                     | { ls_booking-flight_price WIDTH = lv_max_price_length } { ls_booking-currency_code WIDTH = lv_max_currency_length + 1 }| &&
                     | { ls_booking-airport_from_id WIDTH = 14 }| &&
                     | { ls_booking-airport_to_id WIDTH = 13 }| &&
                     | { ls_booking-departure_time TIME = ISO WIDTH = 10 }| &&
                     | { ls_booking-latest_check_in TIME = ISO WIDTH = 18 }| &&
                     | { ls_booking-boarding_time TIME = ISO WIDTH = 9 }| &&
                     | { ls_booking-distance WIDTH = lv_max_distance_length } { ls_booking-distance_unit WIDTH = 4 }| &&
                     | { ls_booking-plane_type_id WIDTH = 15 }|.

      " Write the formatted row
      out->write( lv_row ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
