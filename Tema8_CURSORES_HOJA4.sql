
--CURSORES DE ACTUALIZACION


--1. Actualizar en la tabla emple los salarios de los empleados del departamento que se pasar�  como par�metro. Tambi�n se pasar� el porcentaje de subida del salario. Real�zalo de las dos 
--formas posibles vistas en clase. 


--CON FOR
CREATE OR REPLACE PROCEDURE ACTUALIZAR_SALARIOS (PDEPT_NO DEPART.DEPT_NO%TYPE, PORCENTAJE NUMBER)
IS

    AUMENTO EMPLE.SALARIO%TYPE; 
    CONTADOR_EMPLEADOS INT := 0; 
    
    --CURSOR DE ACTUALIZACION
    CURSOR C1 IS SELECT SALARIO, EMP_NO FROM EMPLE WHERE DEPT_NO = PDEPT_NO FOR UPDATE; 
    
    
    --EXCEPCIONES
    PORCENTAJE_NO_VALIDO EXCEPTION; 
    DEPART_NO_VALIDO EXCEPTION; 
BEGIN
    
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN
        RAISE PORCENTAJE_NO_VALIDO;
    END IF; 
    
    FOR V1 IN C1 LOOP
        AUMENTO := V1.SALARIO + (V1.SALARIO * PORCENTAJE/100); 
        

        CONTADOR_EMPLEADOS := CONTADOR_EMPLEADOS + 1; 
        
     /*   WHERE CURRENT OF C1;: Este comando actualiza el registro actual al que el cursor C1 est� apuntando. No necesitas especificar 
        WHERE EMP_NO = V1.EMP_NO porque el cursor ya est� posicionado en el registro espec�fico que quieres actualizar, y la cl�usula
        FOR UPDATE ya ha bloqueado ese registro espec�fico para cambios.*/
        
        UPDATE EMPLE SET SALARIO = AUMENTO  WHERE CURRENT OF C1; 
        
        DBMS_OUTPUT.PUT_LINE('*************** SALARIO ACTUALIZADO *************'); 
        DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V1.EMP_NO || ' SALARIO = ' || V1.SALARIO|| ' SALARIO ACTUALIZADO = ' ||AUMENTO);  
    
    END LOOP; 

    DBMS_OUTPUT.PUT_LINE('LA CANTDIDAD DE EMPLEADOS EN EL DEPARTAMENTO ES: ' || CONTADOR_EMPLEADOS);
        EXCEPTION
            
            WHEN PORCENTAJE_NO_VALIDO THEN
                DBMS_OUTPUT.PUT_LINE('EL PROCENTAJE INTRODUCIDO DEBE COMPRENDER ENTRE 1 Y 100');
            
END ACTUALIZAR_SALARIOS; 

--PRUEBAS
EXECUTE ACTUALIZAR_SALARIOS(10, 101); --EXCEPCION POR PORCENTAJE
EXECUTE ACTUALIZAR_SALARIOS(10, 20); -- EJECUCION VALIDA


--DO- WHILE

CREATE OR REPLACE PROCEDURE ACTUALIZAR_SALARIOS (PDEPT_NO DEPART.DEPT_NO%TYPE, PORCENTAJE NUMBER)
IS
    --CURSOR DE ACTUALIZACION
    CURSOR C1 IS SELECT SALARIO, EMP_NO FROM EMPLE WHERE DEPT_NO = PDEPT_NO FOR UPDATE; 
    
    --VARIABLES CURSOR
    V_SALARIO NUMBER; 
    V_EMP_NO NUMBER; 
    ACTUALIZA NUMBER;
    
    --CONTADOR
    SUMA_TOTAL NUMBER := 0; 
    TOTAL_EMPLEADOS NUMBER := 0; 
    
    --EXCEPCIONES
    PORCENTAJE_NO_VALIDO EXCEPTION; 
BEGIN
    
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN
        RAISE PORCENTAJE_NO_VALIDO; 
    END IF; 
    
    OPEN C1; 
    
    LOOP
    FETCH C1 INTO V_SALARIO, V_EMP_NO; 
    EXIT WHEN C1%NOTFOUND;

        ACTUALIZA := V_SALARIO +(V_SALARIO * PORCENTAJE/100); 
        UPDATE EMPLE SET SALARIO = ACTUALIZA WHERE CURRENT OF C1; 
        TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
     
       SUMA_TOTAL := SUMA_TOTAL +(ACTUALIZA - SALARIO);
    DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO DEPUES DE UPDATE = ' || ACTUALIZA || ' SALARIO ANTES DE UPDATE = ' || V_SALARIO);  

    END LOOP;
    DBMS_OUTPUT.PUT_LINE('EL TOTAL DE SALARIOS ACTUALIZADOS ES DE' ||TOTAL_EMPLEADOS); 
      DBMS_OUTPUT.PUT_LINE('EL TOTAL DE INCREMENTO EN ESTE DEPARTAMENTO ES DE' ||SUMA_TOTAL); 
    CLOSE C1; 
    
        EXCEPTION
            WHEN PORCENTAJE_NO_VALIDO THEN
                DBMS_OUTPUT.PUT_LINE('EL PROCENTAJE INTRODUCIDO DEBE COMPRENDER ENTRE 1 Y 100');
END ACTUALIZAR_SALARIOS; 


BEGIN
    ACTUALIZAR_SALARIOS(10, 20); -- Llamada al procedimiento con par�metros v�lidos.
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

ROLLBACK; 


--CON WHILE*****************************************************************

CREATE OR REPLACE PROCEDURE ACTUALIZAR_SALARIOS (PDEPT_NO DEPART.DEPT_NO%TYPE, PORCENTAJE NUMBER)
IS
    --CURSOR DE ACTUALIZACION
    CURSOR C1 IS SELECT SALARIO, EMP_NO FROM EMPLE WHERE DEPT_NO = PDEPT_NO FOR UPDATE; 
    
    --CREAMOS LAS VARIABLES
    V_SALARIO NUMBER;
    V_EMP_NO NUMBER;
    ACTUALIZA NUMBER;
    --CONTADORES
    TOTAL_EMPLEADOS NUMBER;
    SUMA_TOTAL NUMBER; --PARA CALCULAR EL GASTO TOTAL INCREMENTADO EN EL DEPARTAMENTO
    
    --EXCEPCIONES
    PORCENTAJE_NO_VALIDO EXCEPTION; 
BEGIN
    
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN
        RAISE PORCENTAJE_NO_VALIDO; 
    END IF; 
    
    OPEN C1;
    FETCH C1 INTO V_SALARIO, V_EMP_NO; 
    
    WHILE C1%FOUND LOOP
        
        ACTUALIZA := V_SALARIO + ((V_SALARIO * PORCENTAJE/100));
        
        UPDATE EMPLE SET SALARIO = ACTUALIZA WHERE CURRENT OF C1;
         DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO DEPUES DE UPDATE = ' || ACTUALIZA || ' SALARIO ANTES DE UPDATE = ' || V_SALARIO);  
    
        --CONTADORES
            TOTAL_EMPLEADOS := TOTAL_EMPLEADOS+1;
            SUMA_TOTAL := SUMA_TOTAL +(ACTUALIZA - SALARIO);
        

      FETCH C1 INTO V_SALARIO, V_EMP_NO; 
    END LOOP;
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE SALARIOS ACTUALIZADOS ES DE' ||TOTAL_EMPLEADOS); 
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE INCREMENTO EN ESTE DEPARTAMENTO ES DE' ||SUMA_TOTAL); 
    
 
    CLOSE C1; 
   
        EXCEPTION
            WHEN PORCENTAJE_NO_VALIDO THEN
                DBMS_OUTPUT.PUT_LINE('EL PROCENTAJE INTRODUCIDO DEBE COMPRENDER ENTRE 1 Y 100');
END ACTUALIZAR_SALARIOS; 

EXECUTE ACTUALIZAR_SALARIOS(20,32);


--2. Codifica un procedimiento que reciba como par�metros un n�mero de departamento, un  importe y un porcentaje y que suba el salario a todos los empleados del departamento 
--indicado en la llamada. La subida ser� el porcentaje o el importe que se indica en la llamada  (el que sea m�s beneficioso para el empleado en cada caso). Indicar al finalizar el n�mero de  filas actualizadas. 

--CON FOR**************************
CREATE OR REPLACE PROCEDURE SUBIR_SALARIOS (PDEPT_NO NUMBER, PORCENTAJE NUMBER, IMPORTE NUMBER)
IS
    CURSOR C1 IS SELECT SALARIO, EMP_NO FROM EMPLE WHERE DEPT_NO = PDEPT_NO FOR UPDATE; 
    
    --VARIABLES
    V_DEPT_NO NUMBER;
    ACTUALIZA NUMBER; 
    
    --CONTADORES
    TOTAL_EMPLEADOS NUMBER := 0;
    SUMA_TOTAL NUMBER := 0; 
    
    --EXCEPCIONES PERSONALIZADAS
    E_PORCENTAJE EXCEPTION;

BEGIN
    
    
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN
        RAISE E_PORCENTAJE;
    END IF;
    
    FOR V1 IN C1 LOOP
        ACTUALIZA := V1.SALARIO + (V1.SALARIO * PORCENTAJE/100);
        
        IF ACTUALIZA > IMPORTE THEN
            
            UPDATE EMPLE SET SALARIO = ACTUALIZA WHERE CURRENT OF C1;
             DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V1.EMP_NO || ' SALARIO = ' || V1.SALARIO|| ' SALARIO ACTUALIZADO = ' ||ACTUALIZA);  
             
            TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
            SUMA_TOTAL := SUMA_TOTAL + (ACTUALIZA - V1.SALARIO);

        
        ELSE --SI IMPORTE ES MAYOR QUE ACTUALIZA
             UPDATE EMPLE SET SALARIO = IMPORTE WHERE CURRENT OF C1;
             DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V1.EMP_NO || ' SALARIO = ' || V1.SALARIO|| ' SALARIO ACTUALIZADO = ' ||IMPORTE);  
             TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
            SUMA_TOTAL := SUMA_TOTAL + (IMPORTE - V1.SALARIO);

        END IF;
    
    END LOOP;
         DBMS_OUTPUT.PUT_LINE('EL TOTAL DE SALARIOS ACTUALIZADOS ES DE ' ||TOTAL_EMPLEADOS); 
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE INCREMENTO EN ESTE DEPARTAMENTO ES DE ' ||SUMA_TOTAL); 
  
    EXCEPTION
       
        WHEN E_PORCENTAJE THEN
            DBMS_OUTPUT.PUT_LINE('EL PORCENTAJE  INTRODUCIDO NO SE ENCUENTRA ENTRE EL 1 Y 100'); 
    
END SUBIR_SALARIOS; 

EXECUTE SUBIR_SALARIOS (20, 20, 300); 
EXECUTE SUBIR_SALARIOS (20, 101, 300); --ERROR DE PORCENTAJE


--CON DO_WHILE*******************************************

CREATE OR REPLACE PROCEDURE SUBIR_SALARIOS (PDEPT_NO NUMBER, PORCENTAJE NUMBER, IMPORTE NUMBER)
IS
    CURSOR C1 IS SELECT SALARIO, EMP_NO FROM EMPLE WHERE DEPT_NO = PDEPT_NO FOR UPDATE; 
    
    --VARIABLES

    ACTUALIZA NUMBER; 
    
    --VARIABELES FETCH
    V_SALARIO NUMBER;
    V_EMP_NO NUMBER;
    
    --CONTADORES
    TOTAL_EMPLEADOS NUMBER := 0;
    SUMA_TOTAL NUMBER := 0; 
    
    --EXCEPCIONES PERSONALIZADAS
    E_PORCENTAJE EXCEPTION;

BEGIN
    
    
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN
        RAISE E_PORCENTAJE;
    END IF;
    
    OPEN C1;
    LOOP
        
        FETCH C1 INTO V_SALARIO, V_EMP_NO;
        EXIT WHEN C1%NOTFOUND; 
    
        ACTUALIZA := V_SALARIO + (V_SALARIO * PORCENTAJE/100);
        
        IF ACTUALIZA > IMPORTE THEN 
            UPDATE EMPLE SET SALARIO = ACTUALIZA WHERE CURRENT OF C1; 
              DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO = ' || V_SALARIO|| ' SALARIO ACTUALIZADO = ' ||ACTUALIZA);  
              TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
                SUMA_TOTAL := SUMA_TOTAL + (ACTUALIZA - V_SALARIO); 
        ELSE --SI IMPORTE ES MAYOR QUE ACTUALIZA
             UPDATE EMPLE SET SALARIO = IMPORTE WHERE CURRENT OF C1; 
               DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO = ' || V_SALARIO|| ' SALARIO ACTUALIZADO = ' ||IMPORTE);  
               TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
             SUMA_TOTAL := SUMA_TOTAL + (IMPORTE - V_SALARIO);
        END IF; 
    
    END LOOP;
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE SALARIOS ACTUALIZADOS ES DE ' ||TOTAL_EMPLEADOS); 
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE INCREMENTO EN ESTE DEPARTAMENTO ES DE ' ||SUMA_TOTAL); 
    CLOSE C1;
    

    EXCEPTION
       
        WHEN E_PORCENTAJE THEN
            DBMS_OUTPUT.PUT_LINE('EL PORCENTAJE  INTRODUCIDO NO SE ENCUENTRA ENTRE EL 1 Y 100'); 
    
END SUBIR_SALARIOS; 

EXECUTE SUBIR_SALARIOS (20, 20, 300); 
EXECUTE SUBIR_SALARIOS (20, 101, 300); --ERROR DE PORCENTAJE

--CON WHILE

CREATE OR REPLACE PROCEDURE SUBIR_SALARIOS (PDEPT_NO NUMBER, PORCENTAJE NUMBER, IMPORTE NUMBER)
IS
    CURSOR C1 IS SELECT SALARIO, EMP_NO FROM EMPLE WHERE DEPT_NO = PDEPT_NO FOR UPDATE; 
    
    --VARIABLES

    ACTUALIZA NUMBER; 
    
    --VARIABELES FETCH
    V_SALARIO NUMBER;
    V_EMP_NO NUMBER;
    
    --CONTADORES
    TOTAL_EMPLEADOS NUMBER := 0;
    SUMA_TOTAL NUMBER := 0; 
    
    --EXCEPCIONES PERSONALIZADAS
    E_PORCENTAJE EXCEPTION;

BEGIN
    
    
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN
        RAISE E_PORCENTAJE;
    END IF;
    
    OPEN C1;
    
        FETCH C1 INTO V_SALARIO, V_EMP_NO;
        
    WHILE C1%FOUND LOOP

        ACTUALIZA := V_SALARIO + (V_SALARIO * PORCENTAJE/100);
        
        IF ACTUALIZA > IMPORTE THEN 
                    UPDATE EMPLE SET SALARIO = ACTUALIZA WHERE CURRENT OF C1; 
                    DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO = ' || V_SALARIO|| ' SALARIO ACTUALIZADO = ' ||ACTUALIZA);  
                    TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
                    SUMA_TOTAL := SUMA_TOTAL + (ACTUALIZA - V_SALARIO); 
        ELSE --SI IMPORTE ES MAYOR QUE ACTUALIZA
                    UPDATE EMPLE SET SALARIO = IMPORTE WHERE CURRENT OF C1; 
                    DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO = ' || V_SALARIO|| ' SALARIO ACTUALIZADO = ' ||IMPORTE);  
                    TOTAL_EMPLEADOS := TOTAL_EMPLEADOS +1;
                    SUMA_TOTAL := SUMA_TOTAL + (IMPORTE - V_SALARIO);
        END IF; 
    
         FETCH C1 INTO V_SALARIO, V_EMP_NO;
    END LOOP;
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE SALARIOS ACTUALIZADOS ES DE ' ||TOTAL_EMPLEADOS); 
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE INCREMENTO EN ESTE DEPARTAMENTO ES DE ' ||SUMA_TOTAL); 
    CLOSE C1;
    

    EXCEPTION
       
        WHEN E_PORCENTAJE THEN
            DBMS_OUTPUT.PUT_LINE('EL PORCENTAJE  INTRODUCIDO NO SE ENCUENTRA ENTRE EL 1 Y 100'); 
    
END SUBIR_SALARIOS; 


EXECUTE SUBIR_SALARIOS (20, 20, 300); 
EXECUTE SUBIR_SALARIOS (20, 101, 300); --ERROR DE PORCENTAJE


--3. Escribe un procedimiento que suba el sueldo de todos los empleados que ganen menos que  el salario medio de su oficio. La subida ser� el 50 por 100 de la diferencia entre el salario del 
--empleado y la media de su oficio. Indicar al final el n�mero de filas actualizadas. 

--ESTE EJERCICIO NO LO PODEMOS RESOLVER PORQUE EN TEORIA LA CONSULTA QUE SACA EL CURSOR ES DE TIPO CORRELACIONADA, PREGUNTAR EN CLASE 
--YO LO VOY A HACER SIN TENER EN CUENTA EL OFICIO PARA EVITAR LA CORRELACIONADA

-- DE ESTA HOJA ESTE ES EL QUE MAS CONVIENE REPASAR PARA EL EXAMEN

    SELECT EMP_NO, SALARIO,OFICIO 
    FROM EMPLE
    WHERE  SALARIO < (SELECT AVG(SALARIO) FROM EMPLE GROUP BY OFICIO);
  

-- CON FOR *******************************************************************
CREATE OR REPLACE PROCEDURE INCREMENTAR_SUELDO (POFICIO VARCHAR2)
IS

    --CONTADOR
    CONTADOR NUMBER := 0; 
    
    --VARIABLES
    DIFERENCIA NUMBER;
    ACTUALIZAR NUMBER; 
    MEDIA_OFICIO NUMBER; 
    --CURSOR
     CURSOR C1 IS SELECT EMP_NO, SALARIO FROM EMPLE WHERE SALARIO < (SELECT AVG(SALARIO) FROM EMPLE WHERE UPPER(OFICIO) = POFICIO) FOR UPDATE; --EVITO LA CORRELACIONADA CON PARAMETROS
     
     --EXCEPCIONES
    OFICIO_NO_VALIDO EXCEPTION; 
BEGIN 
    --CALCULAMOS LA MEDIA DEL  OFICIO INTRODUCIDO, ES MEJOR HACER ESTE CALCULO FUERA DEL CURSOR PARA QUE NO SE EJECUTE EN CASA ITERACION
    SELECT AVG(SALARIO) INTO MEDIA_OFICIO FROM EMPLE WHERE UPPER(OFICIO) = UPPER(POFICIO); 
    
    IF MEDIA_OFICIO IS NULL THEN 
        RAISE OFICIO_NO_VALIDO;
    END IF; 
    
    FOR V1 IN C1 LOOP
        -- SACAMOS la diferencia entre el salario del  empleado y la media de su oficio.
          DIFERENCIA := MEDIA_OFICIO - V1.SALARIO;
          
          ACTUALIZAR := V1.SALARIO + (DIFERENCIA * 50/100); 
          
          UPDATE EMPLE SET SALARIO = ACTUALIZAR WHERE CURRENT OF C1; 
           DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V1.EMP_NO || ' SALARIO = ' || V1.SALARIO|| ' SALARIO ACTUALIZADO = ' ||ACTUALIZAR); 
           CONTADOR := CONTADOR +1; 
        
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('EL TOTAL DE FILAS ACTUALIZADAS ES '|| CONTADOR); 
    
    DBMS_OUTPUT.PUT_LINE('EL TOTAL DE FILAS ACTUALIZADAS ES '|| MEDIA_OFICIO); 
    
    EXCEPTION 
        WHEN OFICIO_NO_VALIDO THEN
            DBMS_OUTPUT.PUT_LINE('EL OFICIO INTRODUCIDO NO EXISTE EN LA BBDD'); 
    
END INCREMENTAR_SUELDO; 

--PRUEBAS
EXECUTE INCREMENTAR_SUELDO('VENDEDOR');
EXECUTE INCREMENTAR_SUELDO('FRFHRFHRF'); -- CONTROL DE EXCEPCIONES

ROLLBACK; 

--CON DO-WHILE ************************************************************
CREATE OR REPLACE PROCEDURE INCREMENTAR_SUELDO (POFICIO VARCHAR2)
IS

    --CONTADOR
    CONTADOR NUMBER := 0; 
    
    --VARIABLES
    DIFERENCIA NUMBER;
    ACTUALIZAR NUMBER; 
    MEDIA_OFICIO NUMBER; 
    --CURSOR
     CURSOR C1 IS SELECT EMP_NO, SALARIO FROM EMPLE WHERE SALARIO < (SELECT AVG(SALARIO) FROM EMPLE WHERE UPPER(OFICIO) = POFICIO) FOR UPDATE; --EVITO LA CORRELACIONADA CON PARAMETROS
     
     --VARIABLES PARA CURSOR
     V_EMP_NO NUMBER;
     V_SALARIO NUMBER;
     
     --EXCEPCIONES
    OFICIO_NO_VALIDO EXCEPTION; 
BEGIN 
    --CALCULAMOS LA MEDIA DEL  OFICIO INTRODUCIDO, ES MEJOR HACER ESTE CALCULO FUERA DEL CURSOR PARA QUE NO SE EJECUTE EN CASA ITERACION
    SELECT AVG(SALARIO) INTO MEDIA_OFICIO FROM EMPLE WHERE UPPER(OFICIO) = UPPER(POFICIO); 
    
    IF MEDIA_OFICIO IS NULL THEN 
        RAISE OFICIO_NO_VALIDO;
    END IF; 
    
   OPEN C1;
   
   LOOP
   FETCH C1 INTO V_EMP_NO, V_SALARIO;
   EXIT WHEN C1%NOTFOUND;
        
        DIFERENCIA := MEDIA_OFICIO - V_SALARIO;
        ACTUALIZAR := V_SALARIO + (DIFERENCIA * 50/100); 
        
         UPDATE EMPLE SET SALARIO = ACTUALIZAR WHERE CURRENT OF C1; 
        DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO = ' || V_SALARIO|| ' SALARIO ACTUALIZADO = ' ||ACTUALIZAR); 
        CONTADOR := CONTADOR +1; 
   END LOOP;
    DBMS_OUTPUT.PUT_LINE('LA CANTIDAD DE SALARIOS ACTUALIZADOS ES: ' || CONTADOR); 
   
   CLOSE C1; 
 
    EXCEPTION 
        WHEN OFICIO_NO_VALIDO THEN
            DBMS_OUTPUT.PUT_LINE('EL OFICIO INTRODUCIDO NO EXISTE EN LA BBDD'); 
    
END INCREMENTAR_SUELDO; 

EXECUTE INCREMENTAR_SUELDO('VENDEDOR');
EXECUTE INCREMENTAR_SUELDO('FRFHRFHRF'); -- CONTROL DE EXCEPCIONES

ROLLBACK; 

-- CON WHILE
CREATE OR REPLACE PROCEDURE INCREMENTAR_SUELDO (POFICIO VARCHAR2)
IS

    --CONTADOR
    CONTADOR NUMBER := 0; 
    
    --VARIABLES
    DIFERENCIA NUMBER;
    ACTUALIZAR NUMBER; 
    MEDIA_OFICIO NUMBER; 
    --CURSOR
     CURSOR C1 IS SELECT EMP_NO, SALARIO FROM EMPLE WHERE SALARIO < (SELECT AVG(SALARIO) FROM EMPLE WHERE UPPER(OFICIO) = POFICIO) FOR UPDATE; --EVITO LA CORRELACIONADA CON PARAMETROS
     
     --VARIABLES PARA CURSOR
     V_EMP_NO NUMBER;
     V_SALARIO NUMBER;
     
     --EXCEPCIONES
    OFICIO_NO_VALIDO EXCEPTION; 
BEGIN 
    --CALCULAMOS LA MEDIA DEL  OFICIO INTRODUCIDO, ES MEJOR HACER ESTE CALCULO FUERA DEL CURSOR PARA QUE NO SE EJECUTE EN CASA ITERACION
    SELECT AVG(SALARIO) INTO MEDIA_OFICIO FROM EMPLE WHERE UPPER(OFICIO) = UPPER(POFICIO); 
    
    IF MEDIA_OFICIO IS NULL THEN 
        RAISE OFICIO_NO_VALIDO;
    END IF; 
    
    OPEN C1;
    FETCH C1 INTO V_EMP_NO, V_SALARIO;
    WHILE C1%FOUND LOOP
        
        DIFERENCIA := MEDIA_OFICIO - V_SALARIO;
        ACTUALIZAR := V_SALARIO + (DIFERENCIA * 50/100);
        
        UPDATE EMPLE SET SALARIO = ACTUALIZAR WHERE CURRENT OF C1; 
         DBMS_OUTPUT.PUT_LINE('EMPLEADO --> ' || V_EMP_NO || ' SALARIO = ' || V_SALARIO|| ' SALARIO ACTUALIZADO = ' ||ACTUALIZAR); 
        CONTADOR := CONTADOR +1; 
    FETCH  C1 INTO V_EMP_NO, V_SALARIO;
    END LOOP;
         DBMS_OUTPUT.PUT_LINE('LA CANTIDAD DE SALARIOS ACTUALIZADOS ES: ' || CONTADOR); 
    CLOSE C1;
 
    EXCEPTION 
        WHEN OFICIO_NO_VALIDO THEN
            DBMS_OUTPUT.PUT_LINE('EL OFICIO INTRODUCIDO NO EXISTE EN LA BBDD'); 
    
END INCREMENTAR_SUELDO; 

EXECUTE INCREMENTAR_SUELDO('VENDEDOR');
EXECUTE INCREMENTAR_SUELDO('FRFHRFHRF'); -- CONTROL DE EXCEPCIONES

ROLLBACK; 






