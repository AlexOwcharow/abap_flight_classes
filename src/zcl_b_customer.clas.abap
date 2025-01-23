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
    TYPES: BEGIN OF ty2_booking,
             booking_id      TYPE /dmo/booking_id,
             customer_id     TYPE /dmo/customer_id,
             flight_date     TYPE /dmo/flight_date,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             airport_from_id TYPE /dmo/airport_id,            " Ensure correct type
             airport_to_id   TYPE /dmo/airport_id,            " Ensure correct type
             departure_time  TYPE /dmo/flight_departure_time, " Ensure correct type
             arrival_time    TYPE /dmo/flight_arrival_time,   " Ensure correct type
             plane_type_id   TYPE /dmo/plane_type_id,
             distance        TYPE /dmo/flight_distance,
             latest_check_in TYPE t,
             boarding_time   TYPE t,
             terminal        TYPE i,
           END OF ty2_booking.

    TYPES: BEGIN OF ty_booking,
             booking_id      TYPE /dmo/booking_id,
             customer_id     TYPE /dmo/customer_id,
             flight_date     TYPE /dmo/flight_date,
             booking_date    TYPE /dmo/booking_date,
             carrier_id      TYPE /dmo/carrier_id,
             connection_id   TYPE /dmo/connection_id,
             airport_from_id TYPE /dmo/airport_id,            " Ensure correct type
             airport_to_id   TYPE /dmo/airport_id,            " Ensure correct type
             departure_time  TYPE /dmo/flight_departure_time, " Ensure correct type
             arrival_time    TYPE /dmo/flight_arrival_time,   " Ensure correct type
             plane_type_id   TYPE /dmo/plane_type_id,
             distance        TYPE /dmo/flight_distance,
             latest_check_in TYPE t,
             boarding_time   TYPE t,
             terminal        TYPE i,
           END OF ty_booking.

*    DATA lv_start        TYPE c LENGTH 3 VALUE 'FRA'.
    DATA lv_start        TYPE /dmo/airport_id.

    DATA lv_current_date TYPE sy-datum.
    DATA lv_current_time TYPE sy-uzeit.

    DATA lt_booking      TYPE TABLE OF ty_booking.
    DATA lt2_booking     TYPE TABLE OF ty2_booking.

    DATA lv_customer_id  TYPE /dmo/customer_id.

    DATA lv_first_name   TYPE /dmo/first_name.
    DATA lv_last_name    TYPE /dmo/last_name.
    DATA lv_phone_number TYPE /dmo/phone_number.
    DATA lv_customer_idn TYPE /dmo/customer_id.

    " Beispielhafte Customer-ID (hart codiert)
    lv_customer_id = '000001'.
    " Get the current date and time
    lv_current_date = sy-datum.
    lv_current_time = sy-uzeit.

    lv_first_name = 'Theresia'.
    lv_last_name = 'Buchholm'.
    lv_phone_number = '+49-341-184709'.

    SELECT SINGLE customer_id FROM /dmo/customer AS c
      WHERE @lv_first_name   = c~first_name
        AND @lv_last_name    = c~last_name
        AND @lv_phone_number = c~phone_number
      INTO @lv_customer_idn.

    IF lv_start = 'FRA'.
      SELECT DISTINCT b~booking_id,
                      b~customer_id,
                      b~flight_date,
                      c~carrier_id,
                      c~connection_id,
                      c~airport_from_id,
                      c~airport_to_id,
                      c~departure_time,
                      c~arrival_time,
                      f~plane_type_id,
                      c~distance
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
        WHERE c~airport_from_id = @lv_start
        INTO TABLE @lt2_booking.

    ELSEIF lv_customer_id IS INITIAL.
      SELECT DISTINCT b~booking_id,
                      b~customer_id,
                      b~flight_date,
                      b~booking_date,
                      c~carrier_id,
                      c~connection_id,
                      c~airport_from_id,
                      c~airport_to_id,
                      c~departure_time,
                      c~arrival_time,
                      f~plane_type_id,
                      c~distance
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
        WHERE b~customer_id = @lv_customer_idn "" _id with id; _idn with name and phone number
        INTO TABLE @lt_booking.

    ELSE.
      SELECT DISTINCT b~booking_id,
                      b~customer_id,
                      b~flight_date,
                      b~booking_date,
                      c~carrier_id,
                      c~connection_id,
                      c~airport_from_id,
                      c~airport_to_id,
                      c~departure_time,
                      c~arrival_time,
                      f~plane_type_id,
                      c~distance
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
        WHERE b~customer_id = @lv_customer_id "" _id with id; _idn with name and phone number
        INTO TABLE @lt_booking.
    ENDIF.

    IF lt_booking IS INITIAL AND lt2_booking IS INITIAL.
      out->write( |Keine Buchungen für Customer ID:{ lv_customer_id }'| ).
      RETURN.
    ENDIF.

    DELETE lt_booking WHERE    flight_date < lv_current_date
                            OR (     flight_date    = lv_current_date
                                 AND departure_time > lv_current_time ).
    DELETE lt2_booking WHERE    flight_date < lv_current_date
                             OR (     flight_date    = lv_current_date
                                  AND departure_time > lv_current_time ).

    SORT lt2_booking BY airport_to_id ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt2_booking COMPARING airport_to_id.

    IF lv_start = 'FRA'.
      LOOP AT lt2_booking INTO DATA(ls2_booking).
        IF ls2_booking-distance < 1000.
          ls2_booking-latest_check_in = ls2_booking-departure_time - '3600'.
          ls2_booking-boarding_time   = ls2_booking-departure_time - '900'.
          ls2_booking-terminal        = 2.

        ELSEIF ls2_booking-distance < 3000.
          ls2_booking-latest_check_in = ls2_booking-departure_time - '5400'.
          ls2_booking-boarding_time   = ls2_booking-departure_time - '1200'.
          ls2_booking-terminal        = 2.
        ELSE.
          ls2_booking-latest_check_in = ls2_booking-departure_time - '7200'.
          ls2_booking-boarding_time   = ls2_booking-departure_time - '1800'.
          ls2_booking-terminal        = 1.
        ENDIF.

        " Update the internal table
        MODIFY lt2_booking FROM ls2_booking.
      ENDLOOP.

      SORT lt2_booking BY flight_date ASCENDING.

      " Define a header line
      DATA(lv2_header) = |{ 'Flugdatum' WIDTH = 12 }| &&
                        | { 'Gesellschaft' WIDTH = 12 }| &&
                        | { 'Startflughafen' WIDTH = 13 }| &&
                        | { 'Zielflughafen' WIDTH = 13 }| &&
                        | { 'Abflugzeit' WIDTH = 10 }| &&
                        | { 'spätester Check-In' WIDTH = 15 }| &&
                        | { 'Boarding' WIDTH = 8 }| &&
                        | { 'Terminal' WIDTH = 8 }| &&
                        | { 'Flugzeugtyp' WIDTH = 15 }|.

      " Output the header
      out->write( lv2_header ).
      " Loop through the data and output each row in a formatted way
      LOOP AT lt2_booking INTO ls2_booking.
*      DATA(lv_random_number) = cl_abap_random_int=>create( min = 1
*                                                           max = 50 ).

        DATA(lv2_row) = |{ ls2_booking-flight_date DATE = ISO WIDTH = 12 }| &&
                       | { ls2_booking-carrier_id WIDTH = 12 }| &&
                       | { ls2_booking-airport_from_id WIDTH = 14 }| &&
                       | { ls2_booking-airport_to_id WIDTH = 13 }| &&
                       | { ls2_booking-departure_time TIME = ISO WIDTH = 10 }| &&
                       | { ls2_booking-latest_check_in TIME = ISO WIDTH = 18 }| &&
                       | { ls2_booking-boarding_time TIME = ISO WIDTH = 8 }| &&
                       | { ls2_booking-terminal WIDTH = 8 }| &&
                       | { ls2_booking-plane_type_id WIDTH = 15 }|.

        " Write the formatted row
        out->write( lv2_row ).
      ENDLOOP.
    ELSE.

      LOOP AT lt_booking INTO DATA(ls_booking).
        IF ls_booking-distance < 1000.
          ls_booking-latest_check_in = ls_booking-departure_time - '3600'.
          ls_booking-boarding_time   = ls_booking-departure_time - '900'.
          ls_booking-terminal        = 2.

        ELSEIF ls_booking-distance < 3000.
          ls_booking-latest_check_in = ls_booking-departure_time - '5400'.
          ls_booking-boarding_time   = ls_booking-departure_time - '1200'.
          ls_booking-terminal        = 2.
        ELSE.
          ls_booking-latest_check_in = ls_booking-departure_time - '7200'.
          ls_booking-boarding_time   = ls_booking-departure_time - '1800'.
          ls_booking-terminal        = 1.
        ENDIF.
        " Update the internal table
        MODIFY lt_booking FROM ls_booking.
      ENDLOOP.

      SORT lt_booking BY flight_date ASCENDING.

      " Define a header line
      DATA(lv_header) = |{ 'Buchungsdatum' WIDTH = 13 }| &&
                        | { 'Flugdatum' WIDTH = 12 }| &&
                        | { 'Gesellschaft' WIDTH = 12 }| &&
                        | { 'Startflughafen' WIDTH = 13 }| &&
                        | { 'Zielflughafen' WIDTH = 13 }| &&
                        | { 'Abflugzeit' WIDTH = 10 }| &&
                        | { 'spätester Check-In' WIDTH = 15 }| &&
                        | { 'Boarding' WIDTH = 8 }| &&
                        | { 'Terminal' WIDTH = 8 }| &&
                        | { 'Flugzeugtyp' WIDTH = 15 }|.

      " Output the header
      out->write( lv_header ).
      " Loop through the data and output each row in a formatted way
      LOOP AT lt_booking INTO ls_booking.
*      DATA(lv_random_number) = cl_abap_random_int=>create( min = 1
*                                                           max = 50 ).

        DATA(lv_row) = |{ ls_booking-booking_date DATE = ISO WIDTH = 13 }| &&
                       | { ls_booking-flight_date DATE = ISO WIDTH = 12 }| &&
                       | { ls_booking-carrier_id WIDTH = 12 }| &&
                       | { ls_booking-airport_from_id WIDTH = 14 }| &&
                       | { ls_booking-airport_to_id WIDTH = 13 }| &&
                       | { ls_booking-departure_time TIME = ISO WIDTH = 10 }| &&
                       | { ls_booking-latest_check_in TIME = ISO WIDTH = 18 }| &&
                       | { ls_booking-boarding_time TIME = ISO WIDTH = 8 }| &&
                       | { ls_booking-terminal WIDTH = 8 }| &&
                       | { ls_booking-plane_type_id WIDTH = 15 }|.

        " Write the formatted row
        out->write( lv_row ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
