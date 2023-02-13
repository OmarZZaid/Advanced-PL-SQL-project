CREATE OR REPLACE PROCEDURE  insert_installments (x2 NUMBER, y NUMBER, z NUMBER, date_counter DATE, x3 NUMBER,  counter INTEGER)
IS
x4 DATE;
x5 NUMBER;
BEGIN 
x4:= date_counter;
x5:= counter;
    FOR i IN 1 .. y LOOP 
        INSERT INTO installments_paid (installment_id, contract_id, installment_date, installment_amount, paid) 
        VALUES (x5, x3, x4, z, 0);

        x5 := x5 + 1; 
        x4 := ADD_MONTHS (x4, x2); 
    END LOOP;
END insert_installments; 


 