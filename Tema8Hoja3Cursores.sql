

--1. Procedimiento que recibe un c�digo de departamento y muestra el apellido, salario  y oficio de los empleados de ese departamento. Al finalizar muestra cuantos 
--empleados hay y la suma de sus salarios. 

SET SERVEROUTPUT ON; 

CREATE OR REPLACE PROCEDURE EMPLEADOS (P_DEPT_NO EMPLE.DEPT_NO%TYPE)
IS
    CURSOR C_EMPLEADOS 
    IS
    SELECT APELLIDO, SALARIO, OFICIO FROM EMPLE WHERE DEPT_NO = P_DEPT_NO;
   
BEGIN
    
    FOR VAR_EMPLEADO IN C_EMPLEADOS LOOP
    
    DBMS_OUTPUT.PUT_LINE('APELLIDO= ' || VAR_EMPLEADO.APELLIDO ||' SALARIO= ' || VAR_EMPLEADO.SALARIO || ' OFICIO= ' || VAR_EMPLEADO.OFICIO);
    END LOOP; 
  
END EMPLEADOS; 

EXECUTE EMPLEADOS(10);


--2. Procedimiento que recibe un oficio y un porcentaje. Validar que ambos par�metros  est�n rellenos.  
--Mostrar todos los empleados con el oficio recibido por par�metro. Sacar el apellido,  el salario y como quedar�a el salario con la subida de ese porcentaje. 


CREATE OR REPLACE PROCEDURE EJ2 (P_OFICIO EMPLE.OFICIO%TYPE, P_PORCENTAJE NUMBER)
IS
CURSOR C_EMP IS
    SELECT APELLIDO, SALARIO FROM EMPLE WHERE UPPER(OFICIO) = UPPER(P_OFICIO); 
    SALARIO_ACTUALIZADO EMPLE.SALARIO%TYPE; --HAY QUE INICIALIZAR LA VARIABLE PARA QUE COMPILE
    
--EXCEPTION
PARAMETROS_NULL EXCEPTION; 
PORCENTAJE_NO_VALID EXCEPTION;
BEGIN
    
    --PRIMERO CONTROLAMOS LA EXCEPCIONES
    IF P_PORCENTAJE NOT BETWEEN 1 AND 100 THEN 
        RAISE PORCENTAJE_NO_VALID; 
    ELSIF P_PORCENTAJE IS NULL OR P_OFICIO IS NULL THEN
        RAISE PARAMETROS_NULL;
    END IF;

    -- RECORREMOS EL CURSOR CON FOR
     FOR V_EMP IN C_EMP LOOP
     
        SALARIO_ACTUALIZADO := V_EMP.SALARIO + (V_EMP.SALARIO * P_PORCENTAJE/100); 
        DBMS_OUTPUT.PUT_LINE('APELLIDO = ' || V_EMP.APELLIDO ||' SALARIO= ' || V_EMP.SALARIO || 'SALARIO ACTUALIZADO= ' || SALARIO_ACTUALIZADO); -- VARIABLE LOCAL, NO DEBE DE LLAMAR A LA TABLA
    END LOOP; 
   

EXCEPTION
    WHEN PORCENTAJE_NO_VALID THEN
        DBMS_OUTPUT.PUT_LINE('EL PORCENTAJE INTRODUCIDO NO ESTA COMPRENDIO ENTRE 1 Y 100'); 
        
    WHEN PARAMETROS_NULL THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ALG�N PARAMETRO INTRODUCIDO ES NULL'); 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('EL OFICIO INTRODUCIDO NO SE ENCUENTRA EN LA BBDD'); 

END EJ2; 

EXECUTE EJ2 ('VENDEDOR', 10); 
--PRUEBA DE EXCEPCIONES

EXECUTE EJ2 ('VENDEDOR', 101); 
EXECUTE EJ2 ('VENDEDOR', NULL); 



--3. Procedimiento que recibe dos a�os por par�metro. Validar que el 1� sea menor que  el 2� y el 2� a lo sumo el a�o de la fecha del sistemas. Por cada uno de los a�os 
--comprendidos entre uno y otro mostrar el apellido y salario de los empleados que  entraron en ese a�o en la empresa. 

CREATE OR REPLACE PROCEDURE ALTA_EMPLE (P_ANIO_1 INT, P_ANIO_2 INT)
IS

CURSOR C_EMP IS SELECT APELLIDO, SALARIO FROM EMPLE WHERE TO_NUMBER(TO_CHAR(FECHA_ALT, 'YYYY')) BETWEEN P_ANIO_1 AND P_ANIO_2; 

-- A�ADIMOS CONTADOR
    CONT INT := 0; 
--VARIABLES DE EXCEPTION
ERROR_ANIO_FORMATO EXCEPTION;
ERROR_ANIO_MAYOR EXCEPTION; 
BEGIN
    --LEVANTAMOS EXCEPCIONES
    IF P_ANIO_1 NOT BETWEEN 1900 AND TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) THEN
        RAISE ERROR_ANIO_FORMATO;
    END IF; 
    
    IF P_ANIO_2 < P_ANIO_1 OR P_ANIO_2 >  TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY')) THEN
        RAISE ERROR_ANIO_MAYOR; 
    END IF; 
    
    --UNA VEZ CONTROLADAS LAS EXCEPCIONES, INCIAMOS EL BUCLE FOR
    FOR V_EMP IN C_EMP LOOP
        DBMS_OUTPUT.PUT_LINE('APELLIDO = ' || V_EMP.APELLIDO || ' SALARIO = ' || V_EMP.SALARIO);
        CONT := CONT + 1; 
    END LOOP; 
    
        DBMS_OUTPUT.PUT_LINE('LA CANTIDAD DE ALTAS REGISTRADAS EN ESE PERIODO SON ' || CONT); 
  
        
        EXCEPTION
            WHEN ERROR_ANIO_FORMATO THEN 
              DBMS_OUTPUT.PUT_LINE('EL A�O DEBE DE TENER 4 DIGITOS COMPRENDIDOS ENTRE 1900 Y EL A�O ACTUAL'); 
            WHEN ERROR_ANIO_MAYOR THEN
                DBMS_OUTPUT.PUT_LINE('EL SEGUNDO A�O INTRODUCIDO DEBE DE SER MAYOR QUE EL PRIMERO, Y NO MAYOR DEL A�O ACTUAL'); 
             WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('NO SE ENCONTRARON LOS DATOS INTRODUCIDOS');
    

END ALTA_EMPLE; 

EXECUTE ALTA_EMPLE(2005, 2007); 
--PROBAMOS EXCEPCIONES
EXECUTE ALTA_EMPLE(2007,2005); 
EXECUTE ALTA_EMPLE(2007,2024); --EJECUTA CORRECTAMENTE, PORQUE PERMITE INTRODUCIR EL ACTUAL
EXECUTE ALTA_EMPLE(2007,2025); 
EXECUTE ALTA_EMPLE(07 , 2025); 
EXECUTE ALTA_EMPLE(1900,1901); -- LA INTENCION ERA QUE SALTARA LA EXCEPCION NO_DATA_FOUND, PERO BUENO ES LO UNICO QUE COJEA EN ESTE PROCEDIMIENTO


--4. Procedimiento que recibe un n�mero n y muestra los apellidos y salarios de los n  empleados que mejores salarios tienen. Validar que n sea un n�mero entre 1 y el 
--n�mero de empleados que hay en emple. Si es menor que 1 error mediante una  excepci�n que muestra el mensaje adecuado. Si es mayor que el n�mero de  empleados levantar otra excepci�n con otro mensaje.

-- CON WHILE
CREATE OR REPLACE PROCEDURE LOSBETTER (N NUMBER)
IS

    --CONTADOR
    TOTAL_EMPLE INT := 0;
    POSICION INT := 0;
    
    --VARIABLES
    V_APELLIDO VARCHAR2(50); 
    V_SALARIO NUMBER; 
    
    
    --CURSOR
     CURSOR C1 IS SELECT  APELLIDO, SALARIO  FROM EMPLE ORDER BY SALARIO DESC; 
    
    
    --EXCEPCIONES
    N_MAYOR EXCEPTION;
    N_MENOR EXCEPTION;
    
BEGIN
    
    SELECT COUNT(*) INTO TOTAL_EMPLE FROM EMPLE;
    
    IF N > TOTAL_EMPLE THEN
        RAISE N_MAYOR; 
    ELSIF N < 1 THEN 
        RAISE N_MENOR; 
    END IF;
    
    
    OPEN C1;
    FETCH C1 INTO V_APELLIDO, V_SALARIO;
    
   WHILE POSICION < N AND C1%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(V_APELLIDO || V_SALARIO);
    POSICION := POSICION + 1;
   
        FETCH C1 INTO V_APELLIDO, V_SALARIO;

    END LOOP;

    CLOSE C1; 
          
    EXCEPTION
        WHEN N_MAYOR THEN 
            DBMS_OUTPUT.PUT_LINE('EL NUMERO INTRODUCIDO SUPERA AL NUMERO DE EMPLEADOS'); 
        WHEN N_MENOR THEN 
            DBMS_OUTPUT.PUT_LINE('EL NUMERO INTRODUCIDO ES INFERIOR A 1');

END LOSBETTER; 


BEGIN
    LOSBETTER(0); 
END;


SET SERVEROUTPUT ON;

--************************************************************************************************************************************************************************+
--
--CON DO-WHILE

CREATE OR REPLACE PROCEDURE MEJORES_SALARIOS ( P_CANTIDAD INT )
IS

    CURSOR MEJORES_SALARIOS IS SELECT  APELLIDO, SALARIO  FROM EMPLE ORDER BY SALARIO DESC; 
    
    CONT_EMPLE INT := 0;
    CONT_MEJORES_SALARIOS INT := -1; --INICIALIZAMOS EN -1 PORQUE EL PRIMER FETCH QUE REALIZA NO LO CUENTA 
    
    V_APELLIDO EMPLE.APELLIDO%TYPE; 
    V_SALARIO EMPLE.SALARIO%TYPE; 
    
--VARIABLES DE EXCEPTION
    CANTIDAD_NO_VALIDA EXCEPTION;

BEGIN

--CONOCER EL NUMERO DE EMPLEADOS QUE TIENE LA TABLA EMPLE
    SELECT COUNT(EMP_NO) INTO CONT_EMPLE FROM EMPLE;

--CONTROL DE EXCEPCIONES
    IF P_CANTIDAD NOT BETWEEN 1 AND CONT_EMPLE THEN
        RAISE CANTIDAD_NO_VALIDA;
    END IF; 

--RECORREMOS CURSOR CON DO-WHILE
    OPEN MEJORES_SALARIOS;
    
    LOOP 
        FETCH MEJORES_SALARIOS INTO V_APELLIDO, V_SALARIO;
        CONT_MEJORES_SALARIOS := CONT_MEJORES_SALARIOS + 1; 
        EXIT WHEN CONT_MEJORES_SALARIOS = P_CANTIDAD; --SALIMOS CUANDO EL CONTADOR LLEGUE A LA CANTIDAD DE MEJORES SALARIOS PASADA POR PARAMETRO 
    DBMS_OUTPUT.PUT_LINE('APELLIDO = ' || V_APELLIDO || ', SALARIO = ' || V_SALARIO);
    END LOOP;
    --VER COMO METER AQUI %ROWTYPE
    CLOSE MEJORES_SALARIOS; 
  
    EXCEPTION
        WHEN CANTIDAD_NO_VALIDA THEN
            DBMS_OUTPUT.PUT_LINE('LA CANTIDAD PASADA POR PARAMETRO TIENE QUE ESTAR COMPRENDIDA ENTRE 1 Y '|| CONT_EMPLE);

END MEJORES_SALARIOS; 

EXECUTE MEJORES_SALARIOS(5);
--PROBAMOS EXCEPCIONES
EXECUTE MEJORES_SALARIOS(20); 

--5. Procedimiento que muestra para cada departamento su nombre y mejor y peor  salario y n�mero de empleados que tiene. 

--SET SERVEROUTPUT ON; 


--CON FOR
CREATE OR REPLACE PROCEDURE CONFOR
IS
    CONTADOR INT := 0; 
    CURSOR C1 IS SELECT MAX(SALARIO) AS MAXI, MIN(SALARIO) AS MINI, COUNT(*) AS EMPLEADO, DEPT_NO FROM EMPLE GROUP BY DEPT_NO;
BEGIN
    
    FOR V1 IN C1 LOOP
        DBMS_OUTPUT.PUT_LINE(V1.MAXI ||' ' || V1.MINI || ' ' ||  V1.EMPLEADO || ' '|| V1.DEPT_NO); 
        
        CONTADOR := CONTADOR +1; 
    END LOOP;
     DBMS_OUTPUT.PUT_LINE(CONTADOR);
END CONFOR;

EXECUTE CONFOR;


--CON WHILE

CREATE OR REPLACE PROCEDURE CONWHILE
IS
    --VARIABLES
    V_MAX NUMBER;
    V_MIN NUMBER;
    V_CONT_EMPLE INT := 0; 
    V_DEPT_NO NUMBER; 
    
    --CURSOR
     CURSOR C1 IS SELECT MAX(SALARIO) , MIN(SALARIO), COUNT(*), DEPT_NO FROM EMPLE GROUP BY DEPT_NO;
    
BEGIN
    OPEN C1;
    
    FETCH C1 INTO V_MAX, V_MIN, V_CONT_EMPLE, V_DEPT_NO; 
    
    WHILE C1%FOUND LOOP
     DBMS_OUTPUT.PUT_LINE(V_MAX ||' ' || V_MIN || ' ' ||  V_CONT_EMPLE || ' '|| V_DEPT_NO); 
    FETCH C1 INTO V_MAX, V_MIN, V_CONT_EMPLE, V_DEPT_NO; 

    END LOOP;
    DBMS_OUTPUT.PUT_LINE(C1%ROWCOUNT);
    
    CLOSE C1;
END CONWHILE;     
    

EXECUTE CONWHILE; 



--CON DO-WHILE

CREATE OR REPLACE PROCEDURE SALARIOS_DEPART 
IS
    CURSOR C_DEPART IS SELECT DNOMBRE, MAX(SALARIO) AS MAX_SALARIO, MIN(SALARIO) AS MIN_SALARIO FROM EMPLE JOIN DEPART ON DEPART.DEPT_NO = EMPLE.DEPT_NO GROUP BY DNOMBRE; 
--DECLARAMOS VARIABLES
    V_DNOMBRE DEPART.DNOMBRE%TYPE; 
    V_MAX_SALARIO EMPLE.SALARIO%TYPE;
    V_MIN_SALARIO EMPLE.SALARIO%TYPE;
    CONT_EMPLE INT := 0; 

BEGIN
    OPEN C_DEPART;
    LOOP
        FETCH  C_DEPART INTO V_DNOMBRE, V_MAX_SALARIO, V_MIN_SALARIO;
        EXIT WHEN C_DEPART %NOTFOUND; 
        DBMS_OUTPUT.PUT_LINE('NOMBRE DEPARTAMENTO = ' || V_DNOMBRE || ' MEJOR SALARIO = ' || V_MAX_SALARIO || ' PEOR SALARIO = ' || V_MIN_SALARIO);
        --CREAME UN %ROWCOUNT
    END LOOP;
     DBMS_OUTPUT.PUT_LINE('LA CANTIDAD DE FILAS IMPRESAS ES ' || C_DEPART%ROWCOUNT); -- IMPRESI�N DE LA CANTIDAD DE FILAS
    CLOSE C_DEPART;

END SALARIOS_DEPART; 

EXECUTE SALARIOS_DEPART;

   


--6. Con las tablas de cl�nica veterinaria:  Procedimiento que muestra, ordenados por motivo y despu�s por fh de la visita, los  siguientes datos:  MOTIVO FH VISITA NOMBRE DEL ANIMAL DNI DUE�O PRECIO 
--  MUY MUY SENCILLA 


CREATE OR REPLACE PROCEDURE VISITAS_VETERINARIO 
IS
    CURSOR C1 IS SELECT MOTIVO, FH_VISITA, A.NOMBRE, A.DNI_DUE�O, PRECIO FROM VISITAS V JOIN ANIMALES A ON A.IDENT = V.IDENT_ANIMAL ORDER BY MOTIVO, FH_VISITA; 
    
    --VARIABLES SOLO PARA LOS WHILES (FOR NO LAS UTILIZA)
    V_MOTIVO    VISITAS.MOTIVO%TYPE; 
    V_FH_VISITA DATE; 
    V_NOMBRE_ANIMAL ANIMALES.NOMBRE%TYPE; 
    V_DNI   DUE�OS.DNI%TYPE; 
    V_PRECIO NUMBER; 
    
    --VARIABLE EXTRA
    CONTADOR_VISITAS INT := 0; 
    RECAUDACION NUMBER := 0; 
    
    
BEGIN 
    DBMS_OUTPUT.PUT_LINE('*************CON FOR*******************');
    
    FOR V1 IN C1 LOOP
          DBMS_OUTPUT.PUT_LINE('EL MOTIVO = ' || V1.MOTIVO || ' FECHA = ' || V1.FH_VISITA || ' NOMBRE ANIMAL = ' || V1.NOMBRE || ' PRECIO = ' || V1.PRECIO || '  DNI DUE�O = ' || V1.DNI_DUE�O);
          CONTADOR_VISITAS := CONTADOR_VISITAS +1; 
          RECAUDACION := RECAUDACION + V1.PRECIO;
    END LOOP; 
        DBMS_OUTPUT.PUT_LINE('TOTAL VISITAS = '|| CONTADOR_VISITAS );
         DBMS_OUTPUT.PUT_LINE('RECAUDACION = '|| RECAUDACION );
        
    
     DBMS_OUTPUT.PUT_LINE('*************DO-WHILE*******************'); 
      CONTADOR_VISITAS := 0; 
      RECAUDACION := 0; 
     OPEN C1;
     LOOP 
             FETCH C1 INTO V_MOTIVO, V_FH_VISITA, V_NOMBRE_ANIMAL, V_DNI, V_PRECIO; 
             EXIT   WHEN C1%NOTFOUND; 
             DBMS_OUTPUT.PUT_LINE('EL MOTIVO = ' || V_MOTIVO || ' FECHA = ' || V_FH_VISITA || ' NOMBRE ANIMAL = ' || V_NOMBRE_ANIMAL || ' PRECIO = ' || V_PRECIO || '  DNI DUE�O = ' || V_DNI);
            CONTADOR_VISITAS := CONTADOR_VISITAS +1; 
            RECAUDACION := RECAUDACION + V_PRECIO;
     END LOOP; 
             DBMS_OUTPUT.PUT_LINE('TOTAL VISITAS = '|| CONTADOR_VISITAS );
              DBMS_OUTPUT.PUT_LINE('RECAUDACION = '|| RECAUDACION );
             
            
     CLOSE C1; 
    
 
     
      DBMS_OUTPUT.PUT_LINE('*************WHILE*******************'); 
           
      
      CONTADOR_VISITAS := 0; 
      RECAUDACION := 0; 
        OPEN C1;
        FETCH C1 INTO V_MOTIVO, V_FH_VISITA, V_NOMBRE_ANIMAL, V_DNI, V_PRECIO; 
    
            WHILE C1%FOUND LOOP
                DBMS_OUTPUT.PUT_LINE('EL MOTIVO = ' || V_MOTIVO || ' FECHA = ' || V_FH_VISITA || ' NOMBRE ANIMAL = ' || V_NOMBRE_ANIMAL || ' PRECIO = ' || V_PRECIO || '  DNI DUE�O = ' || V_DNI);
                CONTADOR_VISITAS := CONTADOR_VISITAS +1; 
                 RECAUDACION := RECAUDACION + V_PRECIO;
                 
                FETCH C1 INTO V_MOTIVO, V_FH_VISITA, V_NOMBRE_ANIMAL, V_DNI, V_PRECIO; 
            END LOOP; 
             DBMS_OUTPUT.PUT_LINE('TOTAL VISITAS = '|| CONTADOR_VISITAS );
              DBMS_OUTPUT.PUT_LINE('RECAUDACION = '|| RECAUDACION );
        CLOSE C1; 
    

END VISITAS_VETERINARIO; 

EXECUTE VISITAS_VETERINARIO; 


7. Procedimiento que recibe el nombre de un due�o y lo env�a a una funci�n que  devolver� el dni si existe o null si no existe. 
a. Si no existe: por cada uno de los due�os muestra: 
 Dni, Nombre y Direcci�n 
Por cada uno de los animales del due�o 
 Ident, Nombre y Especie 
b. Si el due�o si exist�a se muestra, por cada uno de sus animales:  Ident, Nombre, Especie y Raza  
De las visitas que ha tenido:  
Fecha y Hora de la visita, Nombre del veterinario que le atendi� y  motivo de la visita 
Al acabar de recorrer las visitas de un animal se indica cuantas ha tenido y la suma de  sus precios. 
Al acabar de recorrer los animales se muestra cuantos animales tiene 

CREATE OR REPLACE FUNCTION BUSCAR_DNI (P_NOMBRE DUE�OS.NOMBRE%TYPE)
RETURN DUE�OS.DNI%TYPE
IS 
    V_DNI DUE�OS.DNI%TYPE;
BEGIN
     
     SELECT DNI INTO V_DNI FROM DUE�OS WHERE UPPER(NOMBRE) LIKE '%'||UPPER(P_NOMBRE)||'%';

    RETURN V_DNI;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            RETURN NULL; 

END BUSCAR_DNI;


CREATE OR REPLACE PROCEDURE MOSTRAR_VISITAS (P_NOMBRE DUE�OS.NOMBRE%TYPE)
IS
    --VARIABLES DE FUNCION 
    V_NOMBRE DUE�OS.NOMBRE%TYPE;
    DNI_REGISTRADO DUE�OS.DNI%TYPE;
    
    --VARIABLES DE UNION ENTRE CURSORES (SIEMPRE DEFINIR ANTES DEL CURSOR, SINO DA ERRORES)
    V_DNI DUE�OS.DNI%TYPE;
    V_IDENT_ANIMAL ANIMALES.IDENT%TYPE;
    
    --VARIABLES POR SI ENCONTRAR EL DUE�O (PARA EL DNI VAMOS A APROVECHAR LA VARIABLE DE UNION QUE HEMOS CREADO YA)
    V_NOMBRE    DUE�OS.NOMBRE%TYPE;
    V_DIRECCION DUE�OS.DIRECCION%TYPE; 
    CONTADOR_ANIMALES INT := 0;
    TOTAL_PRECIO NUMBER := 0; 
    TOTAL_VISITAS INT := 0; 
    
    --CREAMOS CURSORES
    CURSOR C1 IS SELECT DNI, NOMBRE, DIRECCION FROM DUE�OS;
    CURSOR C2 IS SELECT IDENT, NOMBRE, ESPECIO FROM ANIMALES WHERE DNI = V_DNI; --UNIMOS C2. CON C1 EN EL WHERE
    CURSOR C3 IS SELECT FH_VISITA, VET.NOMBRE, MOTIVO, PRECIO FROM VISITAS V JOIN VETERINARIOS VET ON VET.NUMCOLEGIADO = V.NUMCOLEGIADO WHERE IDENT = V_IDENT_ANIMAL; --UNIMOS C2 CON C3 EN EL WHERE
    
BEGIN
    
    --LLAMAMOS A LA FUNCION
    DNI_REGISTRADO := BUSCAR_DNI(V_NOMBRE); 
    
    IF DNI_REGISTRADO IS NULL THEN --SI NO ENCONTRO EL DNI, IMPRIMIMOS TODOS LOS DATOS
            
            FOR V1 IN C1 LOOP
                DBMS_OUTPUT.PUT_LINE(V1.DNI || ' '  || V1.NOMBRE || ' ' || V1.DIRECCION);
                V_DNI =  V1.DNI; -- VARIABLE UNION DENTRO DEL CICLO PARA C2
                
                 CONTADOR_ANIMALES := 0; --REINCIAMOS EL CONTADOR ANTES DE ENTRAR EN SU CURSOR
                FOR V2 IN C2 LOOP
                     DBMS_OUTPUT.PUT_LINE(V2.IDENT || ' ' || V2.NOMBRE || ' ' || V2.ESPECIE);
                     V_IDENT_ANIMAL = V2.IDENT; --VARIABLE DE UNION DE C2 CON C3
                         TOTAL_PRECIO := 0; --REINICIAMOS EL CONTADOR ANTES DE ENTRAR EN SU CURSOR
                        FOR V3 IN C3 LOOP
                             DBMS_OUTPUT.PUT_LINE(V3.FH_VISITA || ' ' || V3.NOMBRE || ' ' || V3.MOTIVO); 
                             TOTAL_PRECIO := TOTAL_PRECIO + V3.PRECIO;
                            TOTAL_VISITAS := TOTAL_VISITAS + 1;
                      END LOOP; 
                            DBMS_OUTPUT.PUT_LINE('TOTAL ANIMALES DE ' || V_NOMBRE ||'= ' || CONTADOR_ANIMALES);
                            DBMS_OUTPUT.PUT_LINE('TOTAL VISITAS DE ' || V2.NOMBRE||'= ' || CONTADOR_VISITAS);
                END LOOP; 
            END LOOP;
            
    ELSE    --SI SE EJECUTA ESTA OPCION ES PORQUE SI SE ENCOTRO UN DNI, EN LUGAR DE MOSTRAR TODOS, SOLAMENTE MOSTRAREMOS EL DUE�O INTRODUCIDO EN EL PARAMETRO
                
                SELECT DNI, NOMBRE, DIRECCION INTO V_DNI, V_NOMBRE, V_DIRECCION FROM DUE�OS WHERE DNI = DNI_REGISTRADO; --SI SABEMOS QUIEN ES EL DUE�O, REALIZAMOS UNA CONSULTA PARA RECUPERAR SOLO SUSD DATOS
            
                DBMS_OUTPUT.PUT_LINE(V_DNI || ' '  || V_NOMBRE || ' ' || V_DIRECCION);
                CONTADOR_ANIMALES := 0; --REINCIAMOS EL CONTADOR ANTES DE ENTRAR EN SU CURSOR
                FOR V2 IN C2 LOOP
                     DBMS_OUTPUT.PUT_LINE(V2.IDENT || ' ' || V2.NOMBRE || ' ' || V2.ESPECIE);
                     CONTADOR_ANIMALES := CONTADOR_ANIMALES +1;
                      V_IDENT_ANIMAL = V2.IDENT;
                      TOTAL_PRECIO := 0; --REINICIAMOS EL CONTADOR  ANTES DE ENTRAR EN SU CURSOR
                      TOTAL_VISITAS := 0;--REINCIIAMOS EL CONTADOR ANTES DE SU CURSOR
                      FOR V3 IN C3 LOOP
                             DBMS_OUTPUT.PUT_LINE(V3.FH_VISITA || ' ' || V3.NOMBRE || ' ' || V3.MOTIVO); 
                             TOTAL_PRECIO := TOTAL_PRECIO + V3.PRECIO;
                              TOTAL_VISITAS := TOTAL_VISITAS + 1;
                           
                      END LOOP;  
                        DBMS_OUTPUT.PUT_LINE('TOTAL ANIMALES DE ' || V_NOMBRE ||'= ' || CONTADOR_ANIMALES);
                        DBMS_OUTPUT.PUT_LINE('TOTAL VISITAS DE ' || V2.NOMBRE||'= ' || CONTADOR_VISITAS);
                END LOOP; 
    END IF; 
END MOSTRAR_VISITAS; 















CREATE OR REPLACE FUNCTION BUSCAR_DNI (PNOMBRE DUE�OS.NOMBRE%TYPE)
RETURN DUE�OS.DNI%TYPE
IS
    V_DNI DUE�OS.DNI%TYPE;
BEGIN
    SELECT DNI INTO V_DNI
    FROM DUE�OS
    WHERE UPPER(TRIM(NOMBRE)) = UPPER(TRIM(PNOMBRE));--TRIM ELIMINA LOS PSIBLES ESPACIOS
   

    RETURN V_DNI;
EXCEPTION
    WHEN NO_DATA_FOUND THEN 
        RETURN NULL;
    WHEN TOO_MANY_ROWS THEN
        RETURN NULL; -- Puedes manejar m�ltiples filas aqu� si es necesario.
END BUSCAR_DNI;


--PROCEDIMIENTO ************************************************+++

CREATE OR REPLACE PROCEDURE MOSTRAR_INFORMACION_DUE�OS(PNOMBRE DUE�OS.NOMBRE%TYPE)
IS
    -- CONTADORES
    VISITAS INT := 0; 
    SUMA_PRECIOS NUMBER := 0;  -- Inicializaci�n de la suma de precios
    ANIMALES_DUE�OS INT := 0;  -- Correcci�n del nombre de la variable
    
    -- VARIABLE DE FUNCION
    RESULTADO VARCHAR2(100); 
    
    -- CURSORES
    CURSOR DUE�O_NO_EXISTE IS SELECT DNI, NOMBRE, DIRECCION FROM DUE�OS;
    CURSOR ANIMALES_DE_DUE�O (P_DNI_DUE�O DUE�OS.DNI%TYPE) IS 
        SELECT IDENT, NOMBRE, ESPECIE FROM ANIMALES WHERE DNI_DUE�O = P_DNI_DUE�O;
    CURSOR ANIMALES_EXISTE IS SELECT IDENT, NOMBRE, ESPECIE, RAZA FROM ANIMALES WHERE DNI_DUE�O = RESULTADO;
    CURSOR ANIMALES_VISITAS (ID_ANIMAL VARCHAR2) IS 
        SELECT FH_VISITA, VET.NOMBRE, MOTIVO, PRECIO
        FROM VISITAS
        JOIN VETERINARIOS VET ON VET.NUMCOLEGIADO = VISITAS.NUMCOLEGIADO
        WHERE IDENT_ANIMAL = ID_ANIMAL;

BEGIN
    -- LLAMAMOS A LA FUNCION
    RESULTADO := BUSCAR_DNI(PNOMBRE);
    
    IF RESULTADO IS NULL THEN
        -- a. Si no existe, por cada uno de los due�os muestra
        FOR V1 IN DUE�O_NO_EXISTE LOOP
            DBMS_OUTPUT.PUT_LINE(V1.DNI || ' '  || V1.NOMBRE || ' ' || V1.DIRECCION);
            FOR V2 IN ANIMALES_DE_DUE�O(V1.DNI) LOOP
                DBMS_OUTPUT.PUT_LINE(V2.IDENT || ' ' || V2.NOMBRE || ' ' || V2.ESPECIE);
                ANIMALES_DUE�OS := ANIMALES_DUE�OS + 1; 
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('TOTAL DE ANIMALES:  ' || ANIMALES_DUE�OS);
            ANIMALES_DUE�OS := 0; -- Reiniciamos contador para el pr�ximo due�o
        END LOOP;
    ELSE
        -- b. Si el due�o si exist�a se muestra, por cada uno de sus animales
        FOR V3 IN ANIMALES_EXISTE LOOP
            DBMS_OUTPUT.PUT_LINE(V3.IDENT || ' ' || V3.NOMBRE || ' ' || V3.ESPECIE || ' ' || V3.RAZA);
            ANIMALES_DUE�OS := ANIMALES_DUE�OS + 1;
            
            FOR V4 IN ANIMALES_VISITAS(V3.IDENT) LOOP
                DBMS_OUTPUT.PUT_LINE(V4.FH_VISITA || ' ' || V4.NOMBRE || ' ' || V4.MOTIVO); 
                VISITAS := VISITAS + 1; 
                SUMA_PRECIOS := SUMA_PRECIOS + NVL(V4.PRECIO, 0);
            END LOOP;
            
            DBMS_OUTPUT.PUT_LINE('VISITAS: ' || VISITAS || ' - TOTAL COSTO: ' || SUMA_PRECIOS);
            VISITAS := 0;  -- Reiniciamos contadores para el pr�ximo animal
            SUMA_PRECIOS := 0;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('TOTAL DE ANIMALES: ' || ANIMALES_DUE�OS);
    END IF; 
END MOSTRAR_INFORMACION_DUE�OS;


BEGIN
    
    MOSTRAR_INFORMACION_DUE�OS('ALICIA'); --DUE�O QUE NO EXISTE. MOSTRAR� TODOS LLOS DATOS

END; 


--8. Con las tablas del taller:  Por cada funci�n de mec�nico mostrar nombre y tel�fono de cada uno de sus  mec�nicos y por cada mec�nico mostrar los tres �ltimos arreglos que ha hecho 
--(matr�cula del coche, nombre del due�o, importe, fecha de entrada y d�as que ha  estado o que lleva en el taller. 


--SOLUCION MAS SENCILLA, (NI CREA PARAMETROS NI CURSORES DINAMICOS, SOLAMENTE DEBES RECORDAR QUE LAS VARIABLES DE UNION(QUE SON LAS QUE UNES EN EL WHERE) ESTE DECLARADDAS ANTES QUE LOS CURSORES... 

CREATE OR REPLACE PROCEDURE MOSTRAR IS
    -- CURSORES
    
    -- VARIABLES DE UNI�N
    -- LAS VARIABLES SE INTENTAN UTILIZAR EN LOS CURSORES DONDE NO SON V�LIDAS PORQUE EL �MBITO DE LA VARIABLE NO EST� CORRECTAMENTE DEFINIDO PARA LOS CURSORES.
    V_FUNCION MECANICOS.FUNCION%TYPE; -- VARIABLE PARA UNIR C1 CON C2. 
    V_MECANICO MECANICOS.NEMPLEADO%TYPE; -- VARIABLE PARA UNIR C2 CON C3
  
    CURSOR C1 IS SELECT DISTINCT FUNCION FROM MECANICOS; 
    CURSOR C2 IS SELECT NOMBRE, TELEFONO, NEMPLEADO FROM MECANICOS WHERE FUNCION = V_FUNCION; 
    CURSOR C3 IS SELECT A.MATRICULA, CLIENTE.NOMBRE, IMPORTE, FECHA_ENTRADA , ROUND(MONTHS_BETWEEN(NVL(FECHA_SALIDA, SYSDATE), FECHA_ENTRADA)*30)
                FROM ARREGLOS A 
                JOIN COCHES_TALLER COCHE ON COCHE.MATRICULA = A.MATRICULA
                JOIN CLIENTES_TALLER CLIENTE ON CLIENTE.NCLIENTE = COCHE.NCLIENTE
                WHERE A.NEMPLEADO = V_MECANICO
                ORDER BY FECHA_ENTRADA DESC; 
                
    
    
    
    -- VARIABLES DE CURSOR C3
    V_MATRICULA COCHES_TALLER.MATRICULA%TYPE;
    V_NOMBRE_CLIENTE CLIENTES_TALLER.NOMBRE%TYPE; 
    V_IMPORTE NUMBER; 
    V_FECHA_ENTRADA DATE; 
    V_DIAS NUMBER; 
    
    -- CONTADOR
    CONTADOR_ARREGLOS INT; 
    
BEGIN

    FOR V1 IN C1 LOOP
        DBMS_OUTPUT.PUT_LINE('FUNCION --> ' || V1.FUNCION || ' <--**********');
        V_FUNCION := V1.FUNCION; -- AQU� SE ASIGNA CORRECTAMENTE LA VARIABLE PARA USO EN C2
        
        -- EL ERROR INDICA QUE NO SE PUEDE USAR V2 EN LAS L�NEAS POSTERIORES DEL BLOQUE. ESTO SE DEBE A UN ERROR DE �MBITO
        FOR V2 IN C2 LOOP
            DBMS_OUTPUT.PUT_LINE('************* MEC�NICO *************');
            DBMS_OUTPUT.PUT_LINE('NOMBRE = ' || V2.NOMBRE || ' TEL�FONO = ' || V2.TELEFONO);
            V_MECANICO := V2.NEMPLEADO; -- AQU� SE ASIGNA CORRECTAMENTE LA VARIABLE PARA USO EN C3
            
            -- RESETEO DE CONTADOR
            CONTADOR_ARREGLOS := 0; 
            
            -- SE ABRE EL CURSOR C3, PERO V_MECANICO PUEDE NO ESTAR DISPONIBLE EN SU �MBITO ACTUAL
            OPEN C3;
            LOOP
                FETCH C3 INTO V_MATRICULA, V_NOMBRE_CLIENTE, V_IMPORTE, V_FECHA_ENTRADA, V_DIAS;
                EXIT WHEN C3%NOTFOUND OR CONTADOR_ARREGLOS = 3;
                DBMS_OUTPUT.PUT_LINE(V_MATRICULA || ' ' || V_NOMBRE_CLIENTE || ' '  || V_IMPORTE || ' ' || V_FECHA_ENTRADA || ' '  || V_DIAS);
                CONTADOR_ARREGLOS := CONTADOR_ARREGLOS +1; 
            END LOOP;
            CLOSE C3; 
        END LOOP; 
    END LOOP; 
END MOSTRAR;

EXECUTE MOSTRAR; 


--SOLUCION 2) CUROSRES DINAMICOS CON LA SELECT EN EL IN
CREATE OR REPLACE PROCEDURE MOSTRAR IS
    -- VARIABLES DE UNI�N
    V_FUNCION MECANICOS.FUNCION%TYPE;
    V_MECANICO MECANICOS.NEMPLEADO%TYPE;
    
    -- VARIABLES DE CURSOR C3
    V_MATRICULA COCHES_TALLER.MATRICULA%TYPE;
    V_NOMBRE_CLIENTE CLIENTES_TALLER.NOMBRE%TYPE; 
    V_IMPORTE NUMBER; 
    V_FECHA_ENTRADA DATE; 
    V_DIAS NUMBER; 
    
    -- CONTADOR
    CONTADOR_ARREGLOS INT;
    
    -- CURSOR PARA FUNCIONES
    CURSOR C1 IS SELECT DISTINCT FUNCION FROM MECANICOS;
    
BEGIN
    FOR V1 IN C1 LOOP
        DBMS_OUTPUT.PUT_LINE('FUNCION --> ' || V1.FUNCION || ' <--**********');
        V_FUNCION := V1.FUNCION;
        
        -- DEFINICI�N DIN�MICA DE CURSOR C2 DENTRO DEL BUCLE
        FOR V2 IN (SELECT NOMBRE, TELEFONO, NEMPLEADO 
                   FROM MECANICOS 
                   WHERE FUNCION = V_FUNCION) LOOP
            DBMS_OUTPUT.PUT_LINE('************* MEC�NICO *************');
            DBMS_OUTPUT.PUT_LINE('NOMBRE = ' || V2.NOMBRE || ' TEL�FONO = ' || V2.TELEFONO);
            V_MECANICO := V2.NEMPLEADO;
            
            -- RESETEO DE CONTADOR
            CONTADOR_ARREGLOS := 0;
            
            -- DEFINICI�N DIN�MICA DE CURSOR C3 DENTRO DEL BUCLE
            FOR V3 IN (SELECT A.MATRICULA, CLIENTE.NOMBRE, A.IMPORTE, A.FECHA_ENTRADA, ROUND(MONTHS_BETWEEN(NVL(A.FECHA_SALIDA, SYSDATE), A.FECHA_ENTRADA) * 30) AS DIAS
                       FROM ARREGLOS A
                       JOIN COCHES_TALLER COCHE ON COCHE.MATRICULA = A.MATRICULA
                       JOIN CLIENTES_TALLER CLIENTE ON CLIENTE.NCLIENTE = COCHE.NCLIENTE
                       WHERE A.NEMPLEADO = V_MECANICO
                       ORDER BY A.FECHA_ENTRADA DESC) LOOP
                DBMS_OUTPUT.PUT_LINE(V3.MATRICULA || ' ' || V3.NOMBRE || ' ' || V3.IMPORTE || ' ' || V3.FECHA_ENTRADA || ' ' || V3.DIAS);
                CONTADOR_ARREGLOS := CONTADOR_ARREGLOS + 1;
                EXIT WHEN CONTADOR_ARREGLOS = 3;
            END LOOP;
        END LOOP;
    END LOOP;
END MOSTRAR;

--SOLUCION 3 CURSORES PARAMETRIZADO

CREATE OR REPLACE PROCEDURE MOSTRAR IS
    -- VARIABLES DE UNI�N
    V_FUNCION MECANICOS.FUNCION%TYPE;
    V_MECANICO MECANICOS.NEMPLEADO%TYPE;
    
    -- VARIABLES DE CURSOR C3
    V_MATRICULA COCHES_TALLER.MATRICULA%TYPE;
    V_NOMBRE_CLIENTE CLIENTES_TALLER.NOMBRE%TYPE; 
    V_IMPORTE NUMBER; 
    V_FECHA_ENTRADA DATE; 
    V_DIAS NUMBER; 
    
    -- CONTADOR
    CONTADOR_ARREGLOS INT;
    
    -- CURSOR PARA FUNCIONES
    CURSOR C1 IS SELECT DISTINCT FUNCION FROM MECANICOS;
    
    -- CURSOR PARAMETRIZADO PARA MEC�NICOS
    CURSOR C2(V_FUNCION MECANICOS.FUNCION%TYPE) IS 
        SELECT NOMBRE, TELEFONO, NEMPLEADO 
        FROM MECANICOS 
        WHERE FUNCION = V_FUNCION;
    
    -- CURSOR PARAMETRIZADO PARA ARREGLOS
    CURSOR C3(V_MECANICO MECANICOS.NEMPLEADO%TYPE) IS
        SELECT A.MATRICULA, CLIENTE.NOMBRE, A.IMPORTE, A.FECHA_ENTRADA, ROUND(MONTHS_BETWEEN(NVL(A.FECHA_SALIDA, SYSDATE), A.FECHA_ENTRADA) * 30) AS DIAS
        FROM ARREGLOS A
        JOIN COCHES_TALLER COCHE ON COCHE.MATRICULA = A.MATRICULA
        JOIN CLIENTES_TALLER CLIENTE ON CLIENTE.NCLIENTE = COCHE.NCLIENTE
        WHERE A.NEMPLEADO = V_MECANICO
        ORDER BY A.FECHA_ENTRADA DESC;
    
BEGIN
    FOR V1 IN C1 LOOP
        DBMS_OUTPUT.PUT_LINE('FUNCION --> ' || V1.FUNCION || ' <--**********');
        V_FUNCION := V1.FUNCION;
        
        FOR V2 IN C2(V_FUNCION) LOOP
            DBMS_OUTPUT.PUT_LINE('************* MEC�NICO *************');
            DBMS_OUTPUT.PUT_LINE('NOMBRE = ' || V2.NOMBRE || ' TEL�FONO = ' || V2.TELEFONO);
            V_MECANICO := V2.NEMPLEADO;
            
            -- RESETEO DE CONTADOR
            CONTADOR_ARREGLOS := 0;
            
            FOR V3 IN C3(V_MECANICO) LOOP
                DBMS_OUTPUT.PUT_LINE(V3.MATRICULA || ' ' || V3.NOMBRE || ' ' || V3.IMPORTE || ' ' || V3.FECHA_ENTRADA || ' ' || V3.DIAS);
                CONTADOR_ARREGLOS := CONTADOR_ARREGLOS + 1;
                EXIT WHEN CONTADOR_ARREGLOS = 3;
            END LOOP;
        END LOOP;
    END LOOP;
END MOSTRAR;

EXECUTE MOSTRAR; 






--9. Por cada coche mostrar sus datos y despu�s los arreglos terminados ordenados por  fecha de entrada. Al �ltimo de cada coche modificarle el importe rebaj�ndolo un  10%. 

CREATE OR REPLACE PROCEDURE MOSTRAR_ARREGLOS 
IS
    CURSOR C1_COCHE IS SELECT * FROM COCHES_TALLER; 
    CURSOR C2_ARREGLOS IS SELECT * FROM ARREGLOS WHERE FECHA_SALIDA IS NOT NULL ORDER BY FECHA_ENTRADA --FOR UPDATE; 
    
    --VARIABLES
    REBAJA ARREGLOS.IMPORTE%TYPE; --RECOGE EL PRECIO REBAJADO 
    ULTIMO_ARREGLO ARREGLOS.FECHA_SALIDA%TYPE; --VARIABLE QUE RECOGE EL RESULTADO DE UN SELECT
BEGIN
    -- DAMOS VALOR A LA VARIABLE ULTIMO_ARREGLO
  --  SELECT MAX(FECHA_SALIDA) INTO ULTIMO_ARREGLO FROM ARREGLOS WHERE FECHA_SALIDA IS NOT NULL GROUP BY MATRICULA; 
    
    FOR V1_COCHE IN C1_COCHE LOOP
        -- Imprimir datos del coche
        DBMS_OUTPUT.PUT_LINE('Datos del coche:');
        DBMS_OUTPUT.PUT_LINE('MATRICULA: ' || V1_COCHE.MATRICULA);
        DBMS_OUTPUT.PUT_LINE('MODELO: ' || V1_COCHE.MODELO);
        DBMS_OUTPUT.PUT_LINE('A�O MATRICULACI�N: ' || V1_COCHE.ANYO_MATRICULA);
        
        FOR V2_ARREGLOS IN C2_ARREGLOS LOOP
            -- Imprimir datos del arreglo
            DBMS_OUTPUT.PUT_LINE('Datos del arreglo:');
            DBMS_OUTPUT.PUT_LINE('MATRICULA: ' || V2_ARREGLOS.MATRICULA);
            DBMS_OUTPUT.PUT_LINE('FECHA_ENTRADA: ' || V2_ARREGLOS.FECHA_ENTRADA);
            DBMS_OUTPUT.PUT_LINE('FECHA_SALIDA: ' || V2_ARREGLOS.FECHA_SALIDA);
            DBMS_OUTPUT.PUT_LINE('IMPORTE: ' || V2_ARREGLOS.IMPORTE);
            
            --HACER DESCUENTO MODIFICANDO IMPORTE
        /*    IF V2_ARREGLOS.FECHA_SALIDA = ULTIMO_ARREGLO THEN
                --APLICAMOS REBAJA
                REBAJA := V2_ARREGLOS.IMPORTE - (V2_ARREGLOS.IMPORTE * (10/100));
                
                --MOSTRAR PRECIO ANTES DE APLICAR DESCUENTO
                DBMS_OUTPUT.PUT_LINE('Precio SIN descuento aplicado: ' || V2_ARREGLOS.IMPORTE);
                
                --MODIFICAMOS PRECIO
                UPDATE ARREGLOS SET IMPORTE = REBAJA WHERE CURRENT OF C2_ARREGLOS; 
                
                --MOSTRAR PRECIO DESPU�S DE APLICAR DESCUENTO
                DBMS_OUTPUT.PUT_LINE('Precio CON descuento aplicado: ' || REBAJA);
            END IF;*/
        END LOOP; 
    END LOOP; 
END MOSTRAR_ARREGLOS; 

EXECUTE MOSTRAR_ARREGLOS; 

--10. Mostrar los tres clientes que m�s dinero llevan gastado en el taller. Sacar su  ncliente y su nombre y el dinero que llevan gastados. 
--A PESAR DE TENER EL CONTADOR INCREMENTADO, SOLO RETORNA UN CLIENTE Y ME SACA DEL LOOP
DECLARE 
   
    CURSOR CLIENTE IS SELECT C.NCLIENTE, NOMBRE, SUM(IMPORTE) AS IMPORTE_TOTAL 
    FROM CLIENTES_TALLER C 
    JOIN COCHES_TALLER CO ON CO.NCLIENTE = C.NCLIENTE 
    JOIN ARREGLOS A ON A.MATRICULA = CO.MATRICULA 
    GROUP BY C.NCLIENTE, NOMBRE HAVING SUM(IMPORTE) IN (SELECT MAX(SUM(IMPORTE)) F FROM CLIENTES_TALLER C 
                                                                                JOIN COCHES_TALLER CO ON CO.NCLIENTE = C.NCLIENTE 
                                                                                JOIN ARREGLOS A ON A.MATRICULA = CO.MATRICULA 
                                                                                GROUP BY C.NCLIENTE, NOMBRE);
                                                                                
      --variables
      CONTADOR_CLIENTE INTEGER := 0; 
      
      V_ID CLIENTES_TALLER.NCLIENTE%TYPE;
      V_NOMBRE  CLIENTES_TALLER.NOMBRE%TYPE;
      V_TOTAL  ARREGLOS.IMPORTE%TYPE;--RECOGE EL IMPORTE TOTAL DE CADA CLIENTE
    
    BEGIN
    
        OPEN CLIENTE;
        LOOP
            FETCH CLIENTE INTO  V_ID, V_NOMBRE, V_TOTAL; 
            EXIT WHEN CONTADOR_CLIENTE = 3 OR CLIENTE%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE(V_ID || V_NOMBRE || ' HA GASTADOS EN TOTAL = ' || V_TOTAL); 
            CONTADOR_CLIENTE := CONTADOR_CLIENTE +1; 
        
        
        END LOOP; 
        
        CLOSE CLIENTE; 
    
    END;

    
11. Procedimiento Mostrar_Averias_Emple Recibe el nombre de un empleado del parque y se lo pasa a una funci�n 
Busca_Emple_Parque que devolver�: 
 Si no existe el empleado, NULL 
 Si existe el empleado pero no tiene aver�as, '0' 
 Si existe y tiene aver�as, el dni del empleado 
 
 
A la vuelta de la llamada a la funci�n, si no existe el empleado o no tiene aver�as, se 
muestra el mensaje correspondiente y acaba el procedimiento. En caso contrario se 
muestra, de cada una de las aver�as del empleado, el nombre de la atracci�n y el d�a 
de la semana en el que fall�. Al acabar mostrar cuantas aver�as tiene acabadas y 
cuantas sin acabar.


CREATE OR REPLACE FUNCTION BUSCAR_EMPLE(PNOM_EMPLEADO EMPLE_PARQUE.NOM_EMPLEADO%TYPE)
RETURN VARCHAR2
IS
   V_DNI_EMPLE EMPLE_PARQUE.DNI_EMPLE%TYPE;
    CANTIDAD_AVERIAS INT := 0; 
BEGIN

     SELECT DNI_EMPLE INTO V_DNI_EMPLE FROM EMPLE_PARQUE WHERE UPPER(NOM_EMPLEADO) LIKE '%' || UPPER(PNOM_EMPLEADO) || '%';
    --SI EXISTE ENTONCES TENEMOS DOS CAMINOS, QUE NO TENGA AVERIAS O QUE LAS TENGA Y EN ESE CASO RETORNA SU DNI
    IF V_DNI_EMPLE IS NOT NULL THEN
        
        SELECT COUNT(*) INTO CANTIDAD_AVERIAS FROM AVERIAS_PARQUE WHERE DNI_EMPLE = V_DNI_EMPLE;
        
        IF CANTIDAD_AVERIAS = 0 THEN
            RETURN '0';
        
        ELSE    
    
                     RETURN V_DNI_EMPLE;    
        END IF;
   
    END IF; 
    
    --SI EL EMPLEADO NO EXISTE SE TERMINA LA FUNCION
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN NULL; 
        
END BUSCAR_EMPLE; 



--PORCEDIMIENTO********************************************

CREATE OR REPLACE PROCEDURE MOSTRAR_AVERIAS_EMPLEADO(PNOM_EMPLEADO EMPLE_PARQUE.NOM_EMPLEADO%TYPE)
IS 
    -- Variables
    CONTADOR_TERMINADAS INT := 0;
    CONTADOR_PENDIENTES INT := 0;
    RESULTADO VARCHAR2(100);
    
    -- Cursor
    CURSOR C1 IS 
        SELECT A.NOM_ATRACCION, TO_CHAR(AVE.FECHA_FALLA, 'DAY') AS DIA, AVE.FECHA_ARREGLO
        FROM AVERIAS_PARQUE AVE 
        JOIN ATRACCIONES A ON A.COD_ATRACCION = AVE.COD_ATRACCION  
        WHERE AVE.DNI_EMPLE = RESULTADO;

    -- Excepciones
    NO_AVERIAS EXCEPTION; 

BEGIN
    -- Obtenemos el DNI del empleado si existe
    RESULTADO := BUSCAR_EMPLE(PNOM_EMPLEADO);

    -- Manejo de caso donde no hay DNI o el empleado no tiene aver�as
    IF RESULTADO IS NULL OR RESULTADO = '0' THEN
        RAISE NO_AVERIAS; 
    ELSE
        -- Si tenemos datos que mostrar porque el empleado tiene aver�as entonces
        FOR V1 IN C1 LOOP
            -- Mostramos los resultados
            DBMS_OUTPUT.PUT_LINE('ATRACCION: ' || V1.NOM_ATRACCION || ' - DIA DE FALLA: ' || V1.DIA); 
            
            -- Contabilizamos los arreglos
            IF V1.FECHA_ARREGLO IS NULL THEN
                CONTADOR_PENDIENTES := CONTADOR_PENDIENTES + 1; 
            ELSE
                CONTADOR_TERMINADAS := CONTADOR_TERMINADAS + 1; 
            END IF; 
        END LOOP; 

        -- Mostramos totales de aver�as arregladas y pendientes
        DBMS_OUTPUT.PUT_LINE('TOTAL ARREGLADAS: ' || CONTADOR_TERMINADAS || ' - TOTAL PENDIENTES: ' || CONTADOR_PENDIENTES); 
    END IF;

EXCEPTION
    WHEN NO_AVERIAS THEN
        DBMS_OUTPUT.PUT_LINE('EL EMPLEADO NO HA REALIZADO NINGUNA AVERIA');
END MOSTRAR_AVERIAS_EMPLEADO;




--PRUEBAS ******************************************
DECLARE
    NOMBRE_EMPLE  EMPLE_PARQUE.NOM_EMPLEADO%TYPE := 'IGNACIO'; --'ANA' (EXISTE EN BBDD PERO NO TIENE AVERIAS) 
   
BEGIN
    MOSTRAR_AVERIAS_EMPLEADO(NOMBRE_EMPLE); 
END;
























