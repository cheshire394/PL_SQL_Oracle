



--1. Suponiendo creada la siguiente tabla: 


/*Se desea crear un disparador en PL/SQL llamado TRG_SUPERPOBLACION, que 
se active a nivel de registro, tras cada operación DML sobre la tabla PAIS, con el 
siguiente comportamiento: 
a) Si se realizó una inserción en la tabla PAIS, deberá insertar un registro idéntico en la 
tabla PAISES_SUPERPOBLADOS si y sólo si la población del país insertado supere 
los 90 millones de habitantes. Si el país ya existiese en la tabla 
PAISES_SUPERPOBLADOS, levantaría una excepción indicando el mensaje de 
error (Esta excepción es dup_val_on_index). 
b) Si se realizó un borrado en la tabla PAIS, deberá borrarse el registro 
correspondiente de la tabla PAISES_SUPERPOBLADOS, en el caso de exista dicho 
registro. 
c) Si se realizó una actualización en la tabla PAIS: 
a. Si ya existe el país en la tabla PAISES_SUPERPOBLADOS y la nueva 
población es inferior a 90 millones de habitantes, deberá eliminarse el 
registro correspondiente de la tabla PAISES_SUPERPOBLADOS. Si la 
nueva población es igual o superior a 90 millones, se actualizarán todos los 
campos de la tabla PAISES_SUPERPOBLADOS a los valores del registro 
actualizado de la tabla PAIS. 
b. Si no existe el país en la tabla PAISES_SUPERPOBLADOS y la nueva 
población es superior o igual a 90 millones, se añadirá el registro a la tabla 
PAISES_SUPERPOBLADOS.*/


CREATE TABLE PAISES_SUPERPOBLADOS (
  cod_pais number(4) PRIMARY KEY, -- Mismo tipo y precisión, añadido como clave primaria
  nombre varchar2(30), -- Ajustado para coincidir con el tamaño de la tabla 'pais'
  num_hab number(10), -- Añadido el tamaño como en la tabla 'pais'
  extension number(10) -- Añadido el tamaño como en la tabla 'pais'
);

CREATE OR REPLACE TRIGGER TRG_SUPERPOBLADOS AFTER INSERT OR DELETE OR UPDATE OF NUM_HAB ON PAIS
FOR EACH ROW
DECLARE
    V_EXISTE_PAIS INT;
 
BEGIN

       
    IF INSERTING THEN
    
             -- Intentamos encontrar el país en la tabla PAISES_SUPERPOBLADOS
            SELECT COUNT(*) INTO V_EXISTE_PAIS FROM PAISES_SUPERPOBLADOS WHERE COD_PAIS = :NEW.COD_PAIS;
            -- Si no existe y la población supera los 90 millones, lo insertamos
            IF V_EXISTE_PAIS = 0 AND :NEW.NUM_HAB >= 90000000 THEN
                INSERT INTO PAISES_SUPERPOBLADOS (COD_PAIS, NOMBRE, NUM_HAB, EXTENSION)
                VALUES (:NEW.COD_PAIS, :NEW.NOMBRE, :NEW.NUM_HAB, :NEW.EXTENSION);
            ELSIF V_EXISTE_PAIS > 0 THEN
                -- Si ya existe, lanzamos una excepción
                RAISE_APPLICATION_ERROR(-20001, 'El país ya está registrado en la tabla de países superpoblados');
            END IF;
            
    ELSIF UPDATING('NUM_HAB') THEN 
           -- Intentamos encontrar el país en la tabla PAISES_SUPERPOBLADOS
            SELECT COUNT(*) INTO V_EXISTE_PAIS FROM PAISES_SUPERPOBLADOS WHERE COD_PAIS = :NEW.COD_PAIS;
        
        IF V_EXISTE_PAIS > 0 THEN  
                --SI SE MODIFICA UN PAIS QUE YA ESTABA REGISTRADO EN SUPERPOBLADOS
                IF :NEW.NUM_HAB >= 90000000 THEN 
                        UPDATE PAISES_SUPERPOBLADOS SET NUM_HAB = :NEW.NUM_HAB WHERE COD_PAIS = :NEW.COD_PAIS;
                ELSE
                        DELETE PAISES_SUPERPOBLADOS WHERE COD_PAIS = :OLD.COD_PAIS;
                END IF;
                
        ELSE --EL PAIS NO EXISTE EN SUPERPOBLADOS
                IF :OLD.NUM_HAB >= 90000000 THEN
                     INSERT INTO PAISES_SUPERPOBLADOS (COD_PAIS, NOMBRE, NUM_HAB, EXTENSION)
                    VALUES (:NEW.COD_PAIS, :NEW.NOMBRE, :NEW.NUM_HAB, :NEW.EXTENSION);
                 END IF; 
        END IF;
        
    ELSE --SI NO ES UPDATING , NI INSERTING ENTONCES DELETING 
        -- Intentamos encontrar el país en la tabla PAISES_SUPERPOBLADOS
            SELECT COUNT(*) INTO V_EXISTE_PAIS FROM PAISES_SUPERPOBLADOS WHERE COD_PAIS = :OLD.COD_PAIS;
        IF V_EXISTE_PAIS > 0 THEN 
             DELETE PAISES_SUPERPOBLADOS WHERE COD_PAIS = :OLD.COD_PAIS; 
        END IF;        
        
    END IF; 

END;



--PRUEBAS: 

-- **** PRUEBAS DE INSERTING***
INSERT INTO PAIS (COD_PAIS, NOMBRE, NUM_HAB)VALUES (169, 'PAIS MUCHOS HAB ', 90500000); --PAIS CON POCOS HABITANTES. --> CORRECTO DISPARA EL TRIGGER.
INSERT INTO PAIS (COD_PAIS, NOMBRE, NUM_HAB)VALUES (170, 'PAIS POCOS HAB', 50000); --PAIS CON POCOS HABITANTES. --> NO DISPARA EL TRIGGER (CORRECTO PORQUE NO CUMPLE CON LOS HABITANTES)

--NO COPROBAMOS LEVNATAMIENTO DE EXCEPCION PORQUE LA PK DE PAIS NO ME PERMITE INTRODUCIR DOS PAISES IGUALES.

--PRUBAS DE UPDATING ***************
--MODIFICAMOS EL PIS QUE ESTABA EN SUPERPOBLADOS Y LE REDUCIMOS LOS HABITANTES
UPDATE PAIS SET NUM_HAB = 500 WHERE COD_PAIS = 169; --PAIS MUCHOS HAB (CORRECTO, SE ELIMNINA)
--MODIFICAMOS UN PAIS QUE NO ESTABA EN EN PSUPERPOBLADOS
UPDATE PAIS SET NUM_HAB = 90800000 WHERE COD_PAIS = 170; --POCOS HABITANTES AHORA SON MUCHOS(CORRECTO AHORA LO INCORPORA)

--MODIFICAMOS A ESPAÑA QUE NUNCA ESTUBO EN LA TABLA PAISES SUPERPOBLADOS
UPDATE PAIS SET NUM_HAB = 98000000 WHERE COD_PAIS = 1; --CORRECTO AHORA ESPAÑA ESTA EN SPOBLADOS

--- PRUEBAS DELETING*****************************
DELETE PAIS WHERE COD_PAIS = 170; --CORRECTO LO ELIMINA









