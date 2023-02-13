--drop all user sequences first (why else would you create sequences?)
DECLARE
   CURSOR cur2
   IS
      SELECT sequence_name FROM user_sequences;
BEGIN
   FOR rec2 IN cur2
   LOOP
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec2.sequence_name; 
   END LOOP;
END;
--end of block one 
--block two
DECLARE
   not_number_exception   EXCEPTION; --using DBMS_OUTPUT.PUT_LINE(sqlcode); I got the exception number
   PRAGMA EXCEPTION_INIT (not_number_exception, -1722);

   CURSOR c1
   IS --This select statement could be optimized. it outputs the tables present only once in the table and has a p (primary key) constraint.
   --It is also not complete because some of the returned records contain tables with not a number data types. I worked around that by raising an exception
      SELECT TABLE_NAME, COLUMN_NAME
        FROM user_cons_columns NATURAL JOIN user_constraints
       WHERE constraint_type = 'P'
             AND table_name IN (  SELECT TABLE_NAME
                                    FROM (SELECT CONSTRAINT_NAME,
                                                 TABLE_NAME,
                                                 POSITION,
                                                 COLUMN_NAME
                                            FROM    user_cons_columns
                                                 NATURAL JOIN
                                                    user_constraints
                                           WHERE constraint_type = 'P')
                                GROUP BY (TABLE_NAME)
                                  HAVING COUNT (TABLE_NAME) = 1);

   n1                     NUMBER;
   n2                     NUMBER;
BEGIN
   FOR r1 IN c1
   LOOP
      BEGIN
         EXECUTE IMMEDIATE   'SELECT MAX ('      --After tons of error messages I discovered I can't put SELECT MAX(r1.COLUMN_NAME) this is not python, so I worked around it.
                          || r1.COLUMN_NAME
                          || ')
        FROM '
                          || r1.TABLE_NAME
            INTO n1;
         n2 := n1 + 1;   --ironically n1+1 in the equation raised an error, I had to define another variable

         --Creating the SEQUENCES here
         EXECUTE IMMEDIATE   'CREATE SEQUENCE '
                          || r1.TABLE_NAME
                          || '_seq'
                          || ' START WITH '
                          || n2
                          || ' MAXVALUE 99999 INCREMENT BY 1';

         --Creating the TRIGGERS here

         EXECUTE IMMEDIATE   'CREATE OR REPLACE TRIGGER '
                          || r1.TABLE_NAME
                          || '_TRG'
                          || ' BEFORE INSERT ON '
                          || r1.TABLE_NAME
                          || ' REFERENCING NEW AS New OLD AS Old FOR EACH ROW BEGIN :new.'
                          || r1.COLUMN_NAME
                          || ' := '
                          || r1.TABLE_NAME
                          || '_seq.NEXTVAL; END;';
      EXCEPTION
         WHEN not_number_exception
         THEN
            CONTINUE;  -- I just needed the program to continue after encountring a table with not a number data type.
      END;
   END LOOP;
END;