

Ejercicios Triggers Hoja 1 - DML
1. Escribe un disparador que inserte en la tabla auditaremple(col1
(VARCHAR2(200)) cualquier cambio que supere el 5% del salario del empleado
indicando la fecha y hora, el empleado, y el salario anterior y posterior.

CREATE TABLE AUDITAREMPLE (
    COLL VARCHAR2(200)
    
    );
 
 CREATE OR REPLACE TRIGGER T1
 BEFORE UPDATE ON EMPLE FOR EACH ROW
 
 BEGIN 
    IF :OLD.SALARIO * 1.05 > :NEW.SALARIO THEN
        INSERT INTO AUDITAREMPLE(COLL)
        VALUES ('SALARIO ANTIGUO ' || :OLD.SALARIO || 'NUEVO SALARIO ' || :NEW.SALARIO || ' FECHA HORA ' || SYSDATE || 'EMPLEADO ' || :OLD.APELLIDO);
        END IF; 
END; 
    
2. Escribe un disparador que permita auditar las operaciones de inserción o
borrado de datos que se realicen en la tabla EMPLE, de tal forma que, cuando
se produzca cualquier manipulación, se insertará una fila en dicha tabla que
contendrá: fecha y hora, número de empleado, apellido y el tipo de operación:
INSERCIÓN o BORRADO. Habrá que crearse previamente la tabla con los
campos indicados

DROP TABLE TRIGGER2; 

CREATE TABLE TRIGGER2 (
    FECHA_HORA TIMESTAMP,
    ID_EMPLE NUMBER,
    APELLIDO VARCHAR2(100),
    TIPO_OPERACION VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER T2
AFTER INSERT OR DELETE ON EMPLE
FOR EACH ROW
DECLARE
    operacion VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        operacion := 'INSERCIÓN';
    ELSE
        operacion := 'BORRADO';
    END IF;
    
    INSERT INTO TRIGGER2(FECHA_HORA, ID_EMPLE, APELLIDO, TIPO_OPERACION)
    VALUES (SYSTIMESTAMP, :OLD.EMP_NO, :OLD.APELLIDO, operacion);
END;
/

INSERT INTO EMPLE VALUES (8000, 'DEL SAZ', 'HIGIENISTA', NULL, SYSDATE,1124,  NULL, 10); 
DELETE EMPLE WHERE UPPER(APELLIDO) = 'DEL SAZ'; 
ROLLBACK; 

/*Con las tablas de hr
3. Impide que un empleado pueda reducir su salario emitiendo un mensaje de
error.
4. Audita cualquier modificación que se produzca en la tabla DEPARTMENTS.
Almacena el nombre de usuario, operación (alta, baja o modificación) y la fecha
en que se produce. Para ello creo primero la tabla AUDITADEPARMENTS que
tendrá los tres campos indicados.
5. Añade la columna n_empleados a la tabla DEPARTMENTS y haz un
procedimiento que la rellene con el número de empleados que hay en cada
departamento (utilizar cursores de actualización). A continuación, escribe un
disparador que la mantenga actualizada frente a las actualizaciones que se
hagan en la tabla EMPLOYEES.*/

Con las tablas de pub
--6. Añade la columna EJEMPLARES_VENDIDOS a la tabla PUBLISHER. 
--Haz un procedimiento que rellene dicha columna con el resultado de sumar las  unidades vendidas de todos sus libros (ytd_sale).
SET SERVEROUTPUT ON; 
--7. Escribe un disparador que mantenga actualizada la columna del ejercicio anterior.


EXECUTE VENTAS_POR_EDITORIA; 

ROLLBACK; 

--CORREGIDO EN CLASE, NO TE SALIA. 
ALTER TABLE PUBLISHER MODIFY EJEMPLARES_VENDIDOS NUMBER(5);

create or replace PROCEDURE CONTAR_EJEMPLARES 
IS
    CURSOR C1 IS SELECT PUB_ID FROM PUBLISHER FOR UPDATE; 
BEGIN
    FOR V1 IN C1 LOOP
        UPDATE PUBLISHER SET EJEMPLARES_VENDIDOS = (SELECT SUM(YTD_SALE) FROM TITLE WHERE PUB_ID = V1.PUB_ID)
        WHERE CURRENT OF C1;
    END LOOP;
END;

BEGIN
 CONTAR_EJEMPLARES; 
END; 


CREATE OR REPLACE TRIGGER  ACTUALIZAR_CONTAR_EJEMPLARES AFTER UPDATE OR INSERT OR DELETE OF YTD_SALE ON TITLE
FOR EACH ROW
BEGIN

    IF INSERTING THEN
        UPDATE PUBLISHER SET EJEMPLARES_VENDIDOS = EJEMPLARES_VENDIDOS + :NEW.YTD_SALE WHERE PUB_ID = :NEW.PUB_ID; 
    
    ELSIF DELETING THEN 
        UPDATE PUBLISHER SET EJEMPLARES_VENDIDOS = EJEMPLARES_VENDIDOS + :OLD.YTD_SALE WHERE PUB_ID = :OLD.PUB_ID; 
    
    
    ELSIF UPDATING('YTD_SALE') THEN
         UPDATE PUBLISHER SET EJEMPLARES_VENDIDOS = EJEMPLARES_VENDIDOS + :OLD.YTD_SALE WHERE PUB_ID = :OLD.PUB_ID; 
 
    END IF;
 
END;

--PRUEBAS
INSERT INTO TITLE (TITLE_ID, TITLE, YTD_SALE, PUB_ID) VALUES ('AA7899', 'PRUEBANDO', 100, 1389); 

DELETE  TITLE WHERE TITLE_ID ='AA7898';

UPDATE TITLE SET YTD_SALE = YTD_SALE - 100 WHERE TITLE = 'Secrets of Silicon Valley';




--7. Escribe un disparador que mantenga actualizada la columna del ejercicio anterior.



8. Añade a la tabla TITLE la columna LAST_UPDATE. Haz un procedimiento que
rellene dicha columna con la fecha de hoy para todos los títulos

--CORRECTO COMPILAN
ALTER TABLE TITLE ADD LAST_UPDATE DATE; 


CREATE OR REPLACE PROCEDURE FECHA_LAST_UPDATE 
IS
BEGIN
    -- Actualizar la columna LAST_UPDATE a SYSDATE para todos los registros en TITLE
    UPDATE TITLE 
    SET LAST_UPDATE = SYSDATE;

    -- Omitir el uso de un cursor, ya que la operación puede realizarse en una sola sentencia SQL
END FECHA_LAST_UPDATE;

--COMPILA COMPROBADO
EXECUTE FECHA_LAST_UPDATE; 

--TRIGGER 9. Escribe un disparador que modifique el valor de LAST_UPDATE cada vez que se
--produzca una modificación de la información de libros.
--CORRECTO COMPILA, ESTE EJERCICIO LO ENTENDISTE MAL


CREATE OR REPLACE TRIGGER ACTUALIZA_LAST_UPDATE BEFORE UPDATE  ON TITLE --SI PONEMOS AFTER NO COMPILA
FOR EACH ROW 
BEGIN 
--SI SE PRODUCE CUALQUIER ACTUALIZACION EN CUALQUIER COLUMNA DE LA TABLA TITLE QUE NO SE LAST_UPDATE, ENTONCES DISPARAMOS ESTA ACTUALIZADCION
 IF NOT (UPDATING('LAST_UPDATE')) THEN
        :NEW.LAST_UPDATE := SYSDATE;
    END IF;
END;


--10. En la tabla EMPLOYEEPUB el valor de la columna JOB_LVL debe estar comprendida siempre entre los valores min_lvl y max_lvl establecidos para el
--job_id correspondiente. Emite un error en caso de que se pretenda establecer un valor incoherente.
--CORRECTO COMPROBADO

CREATE OR REPLACE TRIGGER VALORES_JOB BEFORE UPDATE OF JOB_LVL ON EMPLOYEEPUB
FOR EACH ROW
DECLARE 
     V_MAX NUMBER;
    V_MIN NUMBER;
    
BEGIN

      SELECT MIN_LVL, MAX_LVL INTO V_MIN, V_MAX FROM JOB WHERE JOB_ID = :NEW.JOB_ID;
      
    IF :NEW.JOB_LVL NOT BETWEEN V_MIN AND V_MAX THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR JOB_LVL DEBE DE ESTAR COMPRENDIDO ENTRE' || V_MIN || ' AND ' || V_MAX); 
    END IF; 
        
END; 

--CORRECTO NO EJECUTA EL PROGRAMA.
UPDATE EMPLOYEEPUB SET JOB_LVL = (SELECT MAX_LVL + 1 FROM JOB WHERE JOB_ID = 2)
WHERE JOB_ID = 2; 

ROLLBACK;

--11. En la tabla TITLE, el título de un libro se puede repetir siempre y cuando se publique en una editorial distinta. Escribe un disparador que emita un error
-- un título de libro se pretenda duplicar de forma errónea.

--COMPRUEBO SI EL LIBRO YA EXISTE PERO NO TENGO EN CUENTA LA EDITORIAL. POR QUE NO SE QUE COLUMNA ES.

CREATE OR REPLACE TRIGGER TITULO_DUPLICADO BEFORE UPDATE OR INSERT OF TITLE ON TITLE
FOR EACH ROW 
DECLARE
    CONTADOR_LIBROS INT := 0; 
BEGIN
    
    --CALCULAMOS LOS LIBROS QUE EXISTE CON ESA PUB_ID Y ESE TITULOS COINCIDENTES
    SELECT COUNT(*) INTO CONTADOR_LIBROS FROM TITLE WHERE TITLE = :NEW.TITLE AND PUB_ID = :NEW.PUB_ID; 
    
    IF CONTADOR_LIBROS > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR YA EXISTE UN LIBRO CON ESE TTTULO Y PUB_ID EN LA BBDD'); 
    END IF; 

END; 


--CORRECTO RESULTADO COMPROBADOS
INSERT INTO TITLE (TITLE_ID , TITLE, PUB_ID) 
VALUES ('PC8899', 'Secrets of Silicon Valley',1389);

ROLLBACK; 















