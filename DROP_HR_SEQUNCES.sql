CREATE OR REPLACE PROCEDURE DROP_HR_SEQUENCES
IS 
   CURSOR cur2
   IS
      SELECT sequence_name FROM user_sequences;
BEGIN
   FOR rec2 IN cur2
   LOOP
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec2.sequence_name; 
   END LOOP;
END;
