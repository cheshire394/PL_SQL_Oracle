Supóngase creada la siguiente tabla:
CREATE TABLE superpotencias AS
SELECT *
FROM pais
WHERE ((pib*1000000)/num_hab) >= 40000
ORDER BY pib/num_hab DESC;
A partir del supuesto anterior se desea diseñar un disparador llamado
TRG_SUPERPOTENCIAS, que se active a nivel de registro, tras cada operación DML
sobre la tabla PAIS, con el siguiente comportamiento:
a) Si se realizó una inserción en la tabla PAIS, deberá insertar un registro idéntico en la
tabla SUPERPOTENCIAS si y sólo si el PIB per cápita (recuérdese que el campo PIB
viene expresado en millones de dólares americanos) del país insertado supere los
40.000 dólares americanos. Si el país ya existiese en la tabla SUPERPOTENCIAS,
levantaría una excepción indicando el mensaje de error.
b) Si se realizó una actualización en la tabla PAIS:
a. Si ya existe el país en la tabla SUPERPOTENCIAS y el nuevo PIB per cápita es
inferior a 40.000 deberá eliminarse el registro correspondiente de la tabla
SUPERPOTENCIAS. Si el nuevo PIB per cápita es superior o igual a 40.000, se
actualizarán todos los campos de la tabla SUPERPOTENCIAS a los valores del
registro actualizado de la tabla PAIS.
b. Si no existe el país en la tabla SUPERPOTENCIAS y el nuevo PIB per cápita es
superior o igual a 40.000, se añadirá el registro a la tabla SUPERPOTENCIAS.
c) Si se realizó un borrado en la tabla PAIS, deberá borrarse el registro correspondiente
de la tabla SUPERPOTENCIAS, en el caso de exista dicho registro.

CREATE OR REPLACE TRIGGER SP_SUPERPOTENCIAS AFTER INSERT OR UPDATE OR DELETE OF PIB ON PAIS
FOR EACH ROW 
DECLARE
   EXISTE INT;  --VARIABLE QUE ALMACENA LA EXISTENCIA DE EL PAIS EN S.P
    
BEGIN
   
    
    IF INSERTING THEN
             SELECT COUNT(*) INTO EXISTE FROM SUPERPOTENCIAS WHERE COD_PAIS = :NEW.COD_PAIS;
             
             IF EXISTE > 0 THEN --SI EL PAIS YA EXISTE EN SP, LANZA UN ERROR POR DUPLICACION DE DATOS
                RAISE_APPLICATION_ERROR(-20001, 'ERROR: EL PAIS QUE SE ESTA INSERTANDO YA EXISTE EN LA BBDD'); 
            
            ELSIF EXISTE = 0 AND  :NEW.PIB >= 40000 THEN --SI NO EXISTE Y ADEMAS SU PIB ES 40000 ENTONCES INSERTA
                INSERT INTO SUPERPOTENCIAS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
                VALUES (:NEW.COD_PAIS, :NEW.NOMBRE, :NEW.CAPITAL, :NEW.EXTENSION, :NEW.MONEDA, :NEW.NUM_HAB, :NEW.PIB, :NEW.CONTINENTE);
                
            END IF;
            
    ELSIF UPDATING('PIB') THEN
            SELECT COUNT(*) INTO EXISTE FROM SUPERPOTENCIAS WHERE COD_PAIS = :NEW.COD_PAIS;
            
        IF EXISTE > 0 THEN --SI EL PAIS EXISTE EN SP
                    IF :NEW.PIB < 40000 THEN --PERO EN LA ACTUALIZACION DEL PIB HA BAJADO, ELIMINAMOS
                        DELETE SUPERPOTENCIAS WHERE COD_PAIS = :OLD.COD_PAIS; 
                    
                    ELSE --SI EL PAIS EXISTE PERO SI PIB NO HA BAJADO DEL 40000 ENTONCES ACTUALIZAMOS DATOS
                        UPDATE SUPERPOTENCIAS SET PIB = :NEW.PIB WHERE COD_PAIS = :OLD.COD_PAIS; 
                    END IF;
        
        ELSE --SI EL PAIS NO EXISTIA EN SP Y ADEMAS SU PIB A AUMENTADO A 40000 INSERTAMOS
                    IF :NEW.PIB >= 40000 THEN 
                         INSERT INTO SUPERPOTENCIAS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
                        VALUES (:NEW.COD_PAIS, :NEW.NOMBRE, :NEW.CAPITAL, :NEW.EXTENSION, :NEW.MONEDA, :NEW.NUM_HAB, :NEW.PIB, :NEW.CONTINENTE);
                    END IF; 
        END IF;
    
    ELSE --DELETE 
             SELECT COUNT(*) INTO EXISTE FROM SUPERPOTENCIAS WHERE COD_PAIS = :OLD.COD_PAIS;
             
             IF EXISTE > 0 THEN  --SI EL PAIS EXISTE EN SP
                    DELETE SUPERPOTENCIAS WHERE COD_PAIS = :OLD.COD_PAIS; 
             END IF;
    
    END IF; 

END; 


--PRUEBAS

--INSERCCION
INSERT INTO PAIS(COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
VALUES (6, 'SUIZA', 'VERNA',NULL, NULL, 45000,68000,'EUROPA'); --FALLA POR VIOLACION DE PK EN PAISES, PERO NO POR TRIGGER

INSERT INTO PAIS(COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
VALUES (170, 'PRUEBA NO SUPEPOTENCIA', 'VERNA',NULL, NULL, 45000,5000,'EUROPA'); --SE INSERTA EN PAISE Y NO SP POR NO CUMPLIR LOS REQUISITOS (CORRECTO):

INSERT INTO PAIS(COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
VALUES (171, 'PRUEBA SUPEPOTENCIA', 'VERNA',NULL, NULL, 45000,50000,'EUROPA'); --CORRECTO SE INSERTA EN SP.

--UPDATE

UPDATE PAIS SET PIB = 1000 WHERE NOMBRE = 'PRUEBA SUPEPOTENCIA'; --CORRECTO SI BAJAMOS EL PIB LO ELIMINA DE SP

UPDATE  PAIS SET PIB = 50000 WHERE NOMBRE = 'PRUEBA SUPEPOTENCIA';--CORRECTO SI LO AUMENTAMOS LO VUELVE A INTRODUCIR EN SP

--DELETE
DELETE PAIS WHERE COD_PAIS = 171; --CORRECTO LO ELIMINA DE SUPEPOTENCIA


2. Suponiendo creada la siguiente tabla:
CREATE TABLE top_10_potencias_por_pib AS
SELECT cod_pais, nombre, pib, capital
FROM (SELECT cod_pais, nombre, pib, capital
FROM pais
WHERE pib IS NOT NULL
ORDER BY pib DESC)
WHERE ROWNUM<=10
ORDER BY ROWNUM DESC;


Se desea crear un disparador en PL/SQL llamado TRG_PAIS_1, que se active a nivel de
registro, tras cada operación INSERT o DELETE sobre la tabla PAIS, con el siguiente
comportamiento:
a) Si se realizó una inserción en la tabla PAIS, deberá comprobar si el nuevo país tiene
un PIB lo suficientemente grande como para pertenecer a la tabla
TOP_10_POTENCIAS_POR_PIB, en cuyo caso eliminará de dicha tabla el país de
menor PIB y añadirá el nuevo país insertado.
b) Si se realizó un borrado en la tabla PAIS, deberá comprobar si el país eliminado es
uno de los países de la tabla TOP_10_POTENCIAS_POR_PIB, en cuyo caso insertará
el décimo país de mayor PIB de la tabla PAÍS en la tabla
TOP_10_POTENCIAS_POR_PIB.


CREATE OR REPLACE TRIGGER TRG_PAIS_10_SUPEPORTENCIAS AFTER DELETE OR INSERT ON PAIS
FOR EACH ROW
DECLARE
    PIB_MIN SUPERPOTENCIAS.PIB%TYPE; --ALMACENA EL PIB MINIMO DE LA TABLA SP (VARIABLE PARA LOS INSERT)
    
    --VARIABLES PARA DELETE
    EXISTE INT; --VARIABLE PARA DELETE, SOLO COMPRUEBA SI EL PAIS EXISTE EN SP PARA DESPUES ELIMINARLO
    
     --VARIABLES QUE ALMACENA EL CODIGO DEL PAIS QUE MAS POTENCIAS TIENE, PERO QUE NO ESTA EN SP
    V_COD_PAIS PAIS.COD_PAIS%TYPE;
    V_PIB_MAX PAIS.PIB%TYPE;
    V_NOMBRE PAIS.NOMBRE%TYPE;
    V_CAPITAL PAIS.CAPITAL%TYPE;
    V_EXTENSION PAIS.EXTENSION%TYPE;
    V_MONEDA PAIS.MONEDA%TYPE;
    V_NUM_HAB PAIS.NUM_HAB%TYPE;
    V_CONTINENTE PAIS.CONTINENTE%TYPE;

    
BEGIN
        IF INSERTING THEN 
                SELECT MIN(PIB) INTO PIB_MIN  FROM SUPERPOTENCIAS;
                
                IF PIB_MIN < :NEW.PIB THEN  --  SI EL PIB MAS BAJO DE LA TABLA SP ES MENOR QUE EL QUE ESTAMOS INSERTANDO, ENTONCES ELIMINAMOS ESE PAIS E INSERTAMOS EL NUEVO PAIS EN SP.
                        DELETE SUPERPOTENCIAS WHERE PIB = PIB_MIN; --SI ALGO FALLA VA A SER AQUI 
                        INSERT INTO SUPERPOTENCIAS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
                        VALUES (:NEW.COD_PAIS, :NEW.NOMBRE, :NEW.CAPITAL, :NEW.EXTENSION, :NEW.MONEDA, :NEW.NUM_HAB, :NEW.PIB, :NEW.CONTINENTE);
                END IF;
            
        ELSE --SI DELETING
            SELECT COUNT(*) INTO EXISTE FROM SUPERPOTENCIAS WHERE COD_PAIS = :OLD.COD_PAIS;
            
            IF EXISTE > 0 THEN --SI ES MAYOR A 0 ENTONCES ES QUE EXISTE EN SP Y HAY QUE ELIMINARLO
                    --PRIMERO ELIMINAMOS EL PAIS DE SP
                    DELETE SUPERPOTENCIAS WHERE COD_PAIS = :OLD.COD_PAIS; 
                    
                    --DESPUES BUSCAMOS CUAL ES EL PIB MAS BAJO DE SP(ACTUALEMENTE) 
                     SELECT MIN(PIB) INTO PIB_MIN  FROM SUPERPOTENCIAS;
                    
                    --INSERTAMOS EL PAIS QUE MAS PIB TIENE Y QUE NO ESTA EN SUPEPOTENCIAS 
                    SELECT COD_PAIS, PIB, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, CONTINENTE 
                        INTO V_COD_PAIS, V_PIB_MAX, V_NOMBRE, V_CAPITAL, V_EXTENSION, V_MONEDA, V_NUM_HAB, V_CONTINENTE
                        FROM PAIS
                        WHERE PIB = (SELECT MAX(PIB) FROM PAIS WHERE COD_PAIS NOT IN (SELECT COD_PAIS FROM SUPERPOTENCIAS))
                          AND COD_PAIS NOT IN (SELECT COD_PAIS FROM SUPERPOTENCIAS);

            INSERT INTO SUPERPOTENCIAS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, MONEDA, NUM_HAB, PIB, CONTINENTE) 
            VALUES (V_COD_PAIS, V_NOMBRE, V_CAPITAL, V_EXTENSION, V_MONEDA, V_NUM_HAB, V_PIB_MAX, V_CONTINENTE);
    
            END IF;
        
        END IF;

END;





3. Supóngase que se modifica la tabla PAIS con la siguiente orden:
ALTER TABLE pais ADD numciudades INTEGER DEFAULT 0;
UPDATE PAIS SET numciudades = (SELECT COUNT(*)
FROM ciudad
WHERE cod_pais=pais.cod_pais AND
habitantes>=1000000);

Se desea crear un disparador en PL/SQL llamado
TRG_ACTUALIZA_NUMCIUDADES, que se active tras cada operación INSERT o
DELETE sobre la tabla CIUDAD, de tal forma que si añade un registro (o más) a esta
tabla, incremente el valor del campo numciudades en la cantidad correspondiente. De
la misma forma deberá actualizar dicho campo en caso de borrados de la tabla
CIUDAD. Sólo se tendrán en cuenta las inserciones y borrados de ciudades de más
de 1.000.000 de habitantes

--PREGUNTAR COMO RESOLVER LOS PRIBLEMAS DE TABLA MUTANTE 

CREATE OR REPLACE TRIGGER TRG_ACTUALIZA_NUMCIUDADES AFTER INSERT OR DELETE ON CIUDAD
FOR EACH ROW 
DECLARE
    CANTIDAD CIUDAD.HABITANTES%TYPE; 
BEGIN
    

            
        
    IF INSERTING AND :NEW.HABITANTES > 1000000  THEN
            
            SELECT COUNT(COD_PAIS) INTO CANTIDAD FROM CIUDAD WHERE COD_PAIS = :NEW.COD_PAIS; 
            
            UPDATE PAIS SET NUMCIUDADES = CANTIDAD WHERE COD_PAIS = :NEW.COD_PAIS; 
            
            
    ELSIF DELETING AND :OLD.HABITANTES > 1000000 THEN
             SELECT COUNT(COD_PAIS) INTO CANTIDAD FROM CIUDAD WHERE COD_PAIS = :OLD.COD_PAIS; 
            UPDATE PAIS SET NUMCIUDADES = CANTIDAD WHERE COD_PAIS = :OLD.COD_PAIS;       
    END IF;
    
     

END; 

INSERT INTO CIUDAD VALUES (1,'VALENCIA', 1000001);


4. Suponiendo creada la siguiente tabla:
CREATE TABLE continente_summary AS
SELECT continente,
(SELECT nombre FROM pais p
WHERE p.continente=pais.continente AND
p.extension>=ALL(SELECT extension FROM pais p2
WHERE p2.continente=pais.continente)) paisMasGrande,
(SELECT extension FROM pais p
WHERE p.continente=pais.continente AND
p.extension>=ALL(SELECT extension FROM pais p2
WHERE p2.continente=pais.continente)) extPaisGrande,
(SELECT nombre FROM pais p
WHERE p.continente=pais.continente AND
p.num_hab>=ALL(SELECT num_hab FROM pais p2
WHERE p2.continente=pais.continente)) paisMasPoblado,
(SELECT num_hab FROM pais p
WHERE p.continente=pais.continente And
p.num_hab>=ALL(SELECT num_hab FROM pais p2
WHERE p2.continente=pais.continente)) pobPaisMasPoblado
FROM pais
GROUP BY continente;
Se desea crear un disparador en PL/SQL llamado TRG_CONTINENTES, que se active
tras cada operación DML sobre la tabla PAIS, con el siguiente comportamiento:
a) Si se produce una inserción en la tabla PAIS, se comprobará si es el país más poblado
y/o más extenso del continente en cuyo caso se procederá a la actualización del
registro correspondiente de la tabla CONTINENTE_SUMMARY.
b) Si se produce una actualización en la tabla PAIS de los campos extensión o num_hab,
habrá que hacer todas las comprobaciones que sean oportunas para actualizar lo que
corresponda en la tabla CONTINENTE_SUMMARY.
c) Si se produce un borrado en la tabla PAIS, se comprobará si es el país más poblado
y/o más extenso del continente en cuyo caso se procederá a su borrado y se deberá
actualizar lo que corresponda en la tabla CONTINENTE_SUMMARY


CREATE OR REPLACE TRIGGER TRG_CONTINENTES AFTER INSERT OR UPDATE OF EXTENSION, NUM_HAB OR DELETE ON PAIS
FOR EACH ROW WHEN (OLD.CONTINENTE IS NOT NULL OR NEW.CONTINENTE IS NOT NULL)

DECLARE

   --VARIABLES 
   V_NOMBRE VARCHAR2(100); 
   
   V_EXT NUMBER; 
   V_POB NUMBER; 
   


BEGIN
    
    IF INSERTING THEN 
            
            SELECT EXTPAISGRANDE, POBPAISMASPOBLADO INTO V_EXT, V_POB FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :NEW.CONTINENTE;
                        
                    IF V_EXT < :NEW.EXTENSION THEN 
                            
                            UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = :NEW.NOMBRE, EXTPAISGRANDE = :NEW.EXTENSION WHERE CONTINENTE = :NEW.CONTINENTE;   
                    
                    END IF;
                    
                    IF V_POB < :NEW.NUM_HAB THEN 
                            
                             UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = :NEW.NOMBRE, POBPAISMASPOBLADO= :NEW.EXTENSION WHERE CONTINENTE = :NEW.CONTINENTE;   
                        
                    END IF;
     
        
    ELSIF UPDATING ('NUM_HAB') OR UPDATING ('EXTENSION') THEN  --DE ESTA FORMA ACTUALIZAMOS LA TABLA SUMMARY TANTO SI MODIFICA SOLO UNA COLUMNA DE LAS DOS, YA QUE LOS IF 
                                                            --   SON INDEPENDIENTES Y PUEDE ENTRAR EN LOS DOS CAMINOS SI SE MODIFICAN LAS DOS.. 
                    
                    IF UPDATING('NUM_HAB') THEN
                            
                            SELECT  POBPAISMASPOBLADO INTO  V_POB FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :OLD.CONTINENTE;
                            
                            IF :NEW.NUM_HAB > V_POB THEN --SI LA NUEVA POBLACION ES MAYOR QUE LA QUE HAY EN LA TABLA SUMMARY PARA ESE CONTINENTE ENTONCES MODIFICALA
                                
                                        UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = :NEW.NOMBRE , POBPAISMASPOBLADO = :NEW.NUM_HAB WHERE CONTINENTE = :NEW.CONTINENTE; 
                            
                            END IF;    
                    END IF;
                    
                    
                    IF UPDATING('EXTENSION') THEN
                            
                             SELECT  EXTPAISGRANDE INTO  V_EXT FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :OLD.CONTINENTE;
                            
                            IF :NEW.EXTENSION > V_EXT THEN --SI LA NUEVA POBLACION ES MAYOR QUE LA QUE HAY EN LA TABLA SUMMARY PARA ESE CONTINENTE ENTONCES MODIFICALA
                                
                                        UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = :NEW.NOMBRE , EXTPAISGRANDE = :NEW.EXTENSION  WHERE CONTINENTE = :NEW.CONTINENTE; 
                            
                            END IF;    
                        
                    END IF; 

            
    ELSE --DELETING
    
             SELECT EXTPAISGRANDE, POBPAISMASPOBLADO INTO V_EXT, V_POB FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :OLD.CONTINENTE;
             
             --SI LA EXTENSIO y/O POBLACION SON LAS MISMA QUE TENEMOS EN SUMMARY QUIERE DECIR QUE ESE PAIS YA NO EXISTE Y  TENEMOS QUE ACTUALIZAR LOS VALORES DE LA TABLA SUMMARY 
             --A LOS DEL PAIS QUE SI QUE TENGAN LA MAYOR POBLACION Y/OEXTENSION ACTUALMENTE.
             
             IF :OLD.EXTENSION = V_EXT THEN
             
                        SELECT NOMBRE, MAX(EXTENSION) INTO V_NOMBRE, V_EXT FROM PAIS WHERE CONTINENTE = :OLD.CONTINENTE; 
                        
                        UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = V_NOMBRE, EXTPAISGRANDE = V_EXT  WHERE CONTINENTE = :OLD.CONTINENTE; 
             
             END IF;
             
             
             IF :OLD.NUM_HAB = V_POB THEN
                    
                        SELECT NOMBRE, MAX(NUM_HAB) INTO V_NOMBRE, V_POB FROM PAIS WHERE CONTINENTE = :OLD.CONTINENTE; 
                        UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = V_NOMBRE, POBPAISMASPOBLADO = V_POB  WHERE CONTINENTE = :OLD.CONTINENTE; 
             
             
             END IF;

    
    END IF; 


END;
\


INSERT INTO PAIS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, NUM_HAB, CONTINENTE) VALUES 
(171, 'Narnia', 'Cair Paravel', 15000, 1200000, 'Fantasia');

INSERT INTO PAIS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, NUM_HAB, CONTINENTE) VALUES 
(172, 'Gondor', 'Minas Tirith', 30000, 2500000, 'Tierra Media');

INSERT INTO PAIS (COD_PAIS, NOMBRE, CAPITAL, EXTENSION, NUM_HAB, CONTINENTE) VALUES 
(173, 'Westeros', 'King's Landing', 45000, 5000000, 'Siete Reinos');




--SOLUCCION DE ANA
CREATE OR REPLACE TRIGGER TRG_CONTINENTES
AFTER INSERT OR UPDATE OF NUM_HAB, EXTENSION OR DELETE
ON PAIS
FOR EACH ROW
WHEN (OLD.CONTINENTE IS NOT NULL OR NEW.CONTINENTE IS NOT NULL)
DECLARE
    V_NUM_HAB PAIS.NUM_HAB%TYPE;
    V_EXTENSION PAIS.EXTENSION%TYPE;
    V_NUEVA_EXTENSION PAIS.EXTENSION%TYPE;
    V_NOMBRE PAIS.NOMBRE%TYPE;
    V_NUEVA_HAB PAIS.NUM_HAB%TYPE;
BEGIN
    IF INSERTING THEN
        SELECT POBPAISMASPOBLADO, EXTPAISGRANDE INTO V_NUM_HAB, V_EXTENSION 
        FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :NEW.CONTINENTE;  
        IF :NEW.EXTENSION > V_EXTENSION THEN
            UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = :NEW.NOMBRE, EXTPAISGRANDE = :NEW.EXTENSION
            WHERE CONTINENTE = :NEW.CONTINENTE;
        END IF;
        IF :NEW.NUM_HAB > V_NUM_HAB THEN
            UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = :NEW.NOMBRE, POBPAISMASPOBLADO = :NEW.NUM_HAB
            WHERE CONTINENTE = :NEW.CONTINENTE;
        END IF;
    ELSIF UPDATING('EXTENSION') THEN
        SELECT EXTPAISGRANDE INTO V_EXTENSION 
        FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :NEW.CONTINENTE;  
        IF :OLD.EXTENSION = V_EXTENSION THEN
            IF :NEW.EXTENSION < V_EXTENSION THEN
                SELECT NOMBRE, EXTENSION INTO V_NOMBRE, V_NUEVA_EXTENSION FROM PAIS 
                WHERE EXTENSION = (SELECT MAX(EXTENSION) FROM PAIS WHERE CONTINENTE = :OLD.CONTINENTE)
                AND CONTINENTE = :OLD.CONTINENTE;
                UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = V_NOMBRE, EXTPAISGRANDE = V_NUEVA_EXTENSION
                WHERE CONTINENTE = :NEW.CONTINENTE;
            ELSEIF :NEW.EXTENSION > V_EXTENSION THEN
                UPDATE CONTINENTE_SUMMARY SET EXTPAISGRANDE = :NEW.EXTENSION;
            END IF;
        END IF;
        ELSEIF :NEW.EXTENSION > V_EXTENSION THEN
            UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = :NEW.NOMBRE, EXTPAISGRANDE = :NEW.EXTENSION
            WHERE CONTINENTE = :NEW.CONTINENTE;
        END IF;
    ELSIF UPDATING('NUM_HAB') THEN
        SELECT POBPAISMASPOBLADO, EXTPAISGRANDE INTO V_NUM_HAB, V_EXTENSION 
        FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :NEW.CONTINENTE;  
        IF :OLD.NUM_HAB = V_NUM_HAB THEN
            IF :NEW.NUM_HAB < V_NUM_HAB THEN
                SELECT NOMBRE, NUM_HAB INTO V_NOMBRE, V_NUEVA_HAB FROM PAIS 
                WHERE NUM_HAB = (SELECT MAX(NUM_HAB) FROM PAIS WHERE CONTINENTE = :OLD.CONTINENTE)
                AND CONTINENTE = :OLD.CONTINENTE;
                UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = V_NOMBRE, POBPAISMASPOBLADO = V_NUEVA_HAB
                WHERE CONTINENTE = :NEW.CONTINENTE;
            ELSEIF :NEW.NUM_HAB > V_NUM_HAB THEN
                UPDATE CONTINENTE_SUMMARY SET POBPAISMASPOBLADO = :NEW.NUM_HAB;
            END IF;
        END IF;
        ELSEIF :NEW.NUM_HAB > V_NUM_HAB THEN
            UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = :NEW.NOMBRE, POBPAISMASPOBLADO = :NEW.NUM_HAB
            WHERE CONTINENTE = :NEW.CONTINENTE;
        END IF;
    ELSE
        SELECT POBPAISMASPOBLADO, EXTPAISGRANDE INTO V_NUM_HAB, V_EXTENSION 
        FROM CONTINENTE_SUMMARY WHERE CONTINENTE = :OLD.CONTINENTE;  
        IF :OLD.EXTENSION = V_EXTENSION THEN
            SELECT NOMBRE, EXTENSION INTO V_NOMBRE, V_NUEVA_EXTENSION FROM PAIS 
            WHERE EXTENSION = (SELECT MAX(EXTENSION) FROM PAIS WHERE CONTINENTE = :OLD.CONTINENTE)
            AND CONTINENTE = :OLD.CONTINENTE;
            UPDATE CONTINENTE_SUMMARY SET PAISMASGRANDE = V_NOMBRE, EXTPAISGRANDE = V_NUEVA_EXTENSION
            WHERE CONTINENTE = :NEW.CONTINENTE;
        END IF;
        IF :OLD.NUM_HAB = V_NUM_HAB THEN
            SELECT NOMBRE, NUM_HAB INTO V_NOMBRE, V_NUEVA_HAB FROM PAIS 
            WHERE NUM_HAB = (SELECT MAX(NUM_HAB) FROM PAIS WHERE CONTINENTE = :OLD.CONTINENTE)
            AND CONTINENTE = :OLD.CONTINENTE;
            UPDATE CONTINENTE_SUMMARY SET PAISMASPOBLADO = V_NOMBRE, POBPAISMASPOBLADO = V_NUEVA_HAB
            WHERE CONTINENTE = :NEW.CONTINENTE;
        END IF;
    END IF;
END IF;
END IF;
END;










