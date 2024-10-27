


/*Con las tablas EMPLE y DEPART: 
1. Crea una vista llamada DEPARTAM que muestre para cada departamento: el número 
de departamento, su nombre, la localidad y el número total de empleados que tiene. 
Aquellos departamentos que no tengan empleados también deberán mostrarse. 


A continuación, construye un trigger que permita realizar actualizaciones en la tabla 
DEPART a partir de la vista DEPARTAM, de forma que:
• Si se produce una inserción, se insertará el departamento en la tabla 
DEPART. 
• Si se produce un borrado, se borrará el departamento de la tabla 
DEPART. 
• Si se produce una actualización del campo localidad, se actualizará dicho 
campo en la tabla DEPART. 
• El resto de operaciones no estarán permitidas por lo que se deberá 
levantar una excepción. */

--VISTA
CREATE OR REPLACE VIEW DEPARTAM 
AS
SELECT D.DEPT_NO, DNOMBRE, LOC, COUNT(EMP_NO) AS EMPLEADOS
FROM DEPART D 
LEFT JOIN EMPLE E ON E.DEPT_NO = D.DEPT_NO
GROUP BY DNOMBRE, D.DEPT_NO, LOC WITH CHECK OPTION; 

--TRIGGER

CREATE OR REPLACE TRIGGER VISTA_DEPARTAM
INSTEAD OF INSERT OR DELETE OR UPDATE ON DEPARTAM
FOR EACH ROW
DECLARE
    MODIFICACION_NO_PERMITIDA EXCEPTION;
BEGIN
    IF UPDATING THEN
        IF NOT UPDATING('LOC') THEN 
            RAISE MODIFICACION_NO_PERMITIDA;
        END IF;
        UPDATE DEPART SET LOC = :NEW.LOC WHERE DEPT_NO = :OLD.DEPT_NO;
    ELSIF INSERTING THEN
        INSERT INTO DEPART (DEPT_NO, DNOMBRE, LOC) VALUES (:NEW.DEPT_NO, :NEW.DNOMBRE, :NEW.LOC);
    ELSIF DELETING THEN
        DELETE FROM DEPART WHERE DEPT_NO = :OLD.DEPT_NO;
    END IF;

EXCEPTION
    WHEN MODIFICACION_NO_PERMITIDA THEN
        DBMS_OUTPUT.PUT_LINE('MODIFICACION NO PERMITIDA');
END;


--PRUEBAS

SET SERVEROUTPUT ON; 

INSERT INTO DEPARTAM (DEPT_NO, DNOMBRE, LOC) VALUES(96, 'PRUEBA 2','MI CASA'); --CORRECTO, DEPART RECIBE LA INSERCCION A TRAVES DE LA VISTA

UPDATE DEPARTAM SET LOC = 'CAMBIO LOC' WHERE DNOMBRE = 'PRUEBA 2';--SI SE EJECUTA PORQUE ES UN UPDATE QUE ACTUA SOBRE LOC
UPDATE DEPARTAM SET DEPT_NO = 98 WHERE DNOMBRE = 'PRUEBA 2'; --NO SE EJERCURA POR QUE ES UN UPDATE QUE NO ES SOBRE LOC

DELETE DEPARTAM WHERE DNOMBRE = 'PRUEBA 2'; --CORRECTO ELIMINA A TRAVES DE LA VISTA


--EJERCICIO 2
CREATE OR REPLACE VIEW paises_europa_vista 
AS
SELECT cod_pais, nombre, capital, num_hab/extension densidad, 
 (SELECT nombre FROM ciudad 
 WHERE cod_pais=pais.cod_pais 
 AND habitantes=(SELECT MAX(habitantes) 
 FROM ciudad 
 WHERE cod_pais=pais.cod_pais)) ciudadmaspoblada, 
 (SELECT habitantes FROM ciudad 
 WHERE cod_pais=pais.cod_pais 
 AND habitantes=(SELECT MAX(habitantes) FROM ciudad 
 WHERE cod_pais=pais.cod_pais)) habciudadmaspoblada 
FROM pais 
WHERE continente='Europa' 
ORDER BY densidad DESC
WITH CHECK OPTION; 

/*Se desea crear un disparador en PL/SQL llamado TRG_PAISES_EUROPA, que se active a 
nivel de registro, tras cada operación DML sobre la vista anteriormente definida, con el 
siguiente comportamiento: 
• Si se realiza una inserción sobre la vista, deberá insertar el código, nombre, 
capital del país y continente (tomará como valor Europa) en la tabla PAIS, y la 
ciudad más poblada y su número de habitantes en la tabla CIUDAD. 

• Si se realiza un borrado, deberán eliminarse todas las ciudades de la tabla 
CIUDAD del país eliminado, para posteriormente eliminar el país de la tabla 
PAIS. 

• Si se realizó una actualización, esta deberá propagarse a los campos de las 
tablas PAIS y CIUDAD, de manera análoga que si fuese una inserción*/



--SOLUCIONES DE CLASE, NO TE SALIO.....

CREATE OR REPLACE TRIGGER TRG_PAISES_EUROPA
INSTEAD OF INSERT OR DELETE OR UPDATE
ON PAISES_EUROPA_VISTA
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO PAIS (COD_PAIS, NOMBRE, CAPITAL, CONTINENTE) VALUES (:NEW.COD_PAIS, :NEW.NOMBRE, :NEW.CAPITAL, 'EUROPA');
        INSERT INTO CIUDAD (COD_PAIS, NOMBRE, HABITANTES) VALUES (:NEW.COD_PAIS, :NEW.CIUDADMASPOBLADA, :NEW.HABCIUDADMASPOBLADA);
    ELSIF DELETING THEN
        DELETE FROM CIUDAD WHERE COD_PAIS = :OLD.COD_PAIS;
        DELETE FROM PAIS WHERE COD_PAIS = :OLD.COD_PAIS;
    ELSE
        UPDATE CIUDAD SET COD_PAIS = :NEW.COD_PAIS, NOMBRE = :NEW.CIUDADMASPOBLADA, HABITANTES = :NEW.HABCIUDADMASPOBLADA
        WHERE COD_PAIS = :OLD.COD_PAIS AND NOMBRE = :OLD.CIUDADMASPOBLADA;     
        UPDATE PAIS SET COD_PAIS = :NEW.COD_PAIS, NOMBRE = :NEW.NOMBRE, CAPITAL = :NEW.CAPITAL
        WHERE COD_PAIS = :OLD.COD_PAIS;
    END IF;
END;








