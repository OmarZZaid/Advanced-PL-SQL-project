/* Formatted on 1/5/2023 9:10:17 AM (QP5 v5.139.911.3011) */
DECLARE
   CURSOR cur3
   IS
      SELECT CLIENT_ID,
             CONTRACT_ID,
             TRUNC ( (CONTRACT_ENDDATE - CONTRACT_STARTDATE) / 365 * 12)
                AS Number_of_months,
             CONTRACT_STARTDATE,
             CONTRACT_ENDDATE,
             CONTRACT_TOTAL_FEES-CONTRACT_DEPOSIT_FEES as CONTRACT_TOTAL_FEES,
             CONTRACT_PAYMENT_TYPE
        FROM CONTRACTS NATURAL JOIN CLIENT;

   x              CONTRACTS.CONTRACT_PAYMENT_TYPE%TYPE; --case 
   x2            NUMBER(2);  --case number of months for incrementing
   x3 NUMBER(4); --contract ID
   y              NUMBER (3);                             --number of payments
   z              NUMBER (10, 4);                          --amount of payment
   counter        NUMBER (6) := 1;                                   --counter for ID
   date_counter   CONTRACTS.CONTRACT_STARTDATE%TYPE;  --counter for value of date insert
BEGIN
   FOR rec3 IN cur3
   LOOP
      x := rec3.CONTRACT_PAYMENT_TYPE;
      x3:= rec3.CONTRACT_ID;

      CASE x
         WHEN 'ANNUAL'
         THEN
         x2:= 12;
            y := rec3.NUMBER_OF_MONTHS / x2;  --number of payments
            z := (rec3.CONTRACT_TOTAL_FEES) / y; --amount of single payment
            date_counter := rec3.CONTRACT_STARTDATE; --date insert

            insert_installments (x2 , y , z , date_counter , x3 ,  counter );
            counter:= counter+y;
         WHEN 'QUARTER'
         THEN
                  x2:= 3;
            y := rec3.NUMBER_OF_MONTHS / x2;
            z := rec3.CONTRACT_TOTAL_FEES / y;
            date_counter := rec3.CONTRACT_STARTDATE;

                        insert_installments (x2 , y , z , date_counter , x3 ,  counter );
            counter:= counter+y;
         WHEN 'HALF_ANNUAL'
         THEN
         x2 := 6;
            y := rec3.NUMBER_OF_MONTHS / x2;
            z := rec3.CONTRACT_TOTAL_FEES / y;
            date_counter := rec3.CONTRACT_STARTDATE;

                       insert_installments (x2 , y , z , date_counter , x3 ,  counter );
            counter:= counter+y;
         WHEN 'MONTHLY'
         THEN
                  x2 := 1;
            y := rec3.NUMBER_OF_MONTHS;
            z := rec3.CONTRACT_TOTAL_FEES / y;
            date_counter := rec3.CONTRACT_STARTDATE;

                       insert_installments (x2 , y , z , date_counter , x3 ,  counter );
            counter:= counter+y;
      END CASE;
   END LOOP;
END;