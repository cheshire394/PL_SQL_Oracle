1 
Ejercicios PL/SQL Hoja 2 - 
Procedimientos y Funciones 
1. Procedimiento que recibe un precio y un porcentaje de incremento y muestra el precio 
incrementado. En caso de que el porcentaje no sea un valor entre 0 y 100 muestra un 
mensaje de error. 

-- FACILISIMO
CREATE OR REPLACE PROCEDURE EJ1HOJA1 (PRECIO NUMBER, PORCENTAJE NUMBER)
IS
    AUMENTO NUMBER;  -- Corrección del nombre de la variable.
    PORCENTAJE_NO_VALIDO EXCEPTION; 

BEGIN
        IF PORCENTAJE NOT BETWEEN 0 AND 100 THEN
            RAISE PORCENTAJE_NO_VALIDO;
            
        ELSE 
            AUMENTO := PRECIO + (PRECIO * PORCENTAJE/100);
        END IF;

    EXCEPTION 
        WHEN PORCENTAJE_NO_VALIDO THEN  -- Corrección en el manejo de la excepción.
            DBMS_OUTPUT.PUT_LINE('ERROR: EL PORCENTAJE INTRODUCIDO DEBE COMPRENDER ENTRE 0 Y 100');

END EJ1HOJA1;
/
SET SERVEROUTPUT ON;
EXECUTE EJ1HOJA1(5, 100);
EXECUTE EJ1HOJA1(5, 105);



2. Procedimiento que recibe dos números y escribe todos los números pares que hay  entre ambos. 

--ESTE PROCEDIMIENTO TIENE UN PEQUEÑO DETALLE QUE HAY QUE SABER.

CREATE OR REPLACE PROCEDURE PARES (NUM1 IN OUT INT, NUM2 IN OUT  INT)
IS
    INTERCAMBIO INT;
BEGIN
        IF NUM2 < NUM1 THEN 
            INTERCAMBIO := NUM2;
            NUM2 := NUM1;
            NUM1:= INTERCAMBIO; 
        END IF;
        
        FOR I IN REVERSE NUM1..NUM2 LOOP
            IF I MOD 2 = 0 THEN 
                DBMS_OUTPUT.PUT_LINE(I); 
            END IF;
        END LOOP;

END PARES;

DECLARE
    v_num1 INT := 1;
    v_num2 INT := 10;
BEGIN
    -- Llamar al procedimiento con variables, no con valores literales
    PARES(v_num1, v_num2);
    PARES(v_num2,v_num1);
    
END;



--3. Procedimiento que muestra la tabla de multiplicar de un número que recibe (entre 10) 
--FACILISIMO
CREATE OR REPLACE PROCEDURE MULTIPLICA (NUM INT)
IS
BEGIN

    FOR I IN 1..10 LOOP
            DBMS_OUTPUT.PUT_LINE(NUM * I );
    
    END LOOP;
END MULTIPLICA; 

EXECUTE MULTIPLICA(6);



4. Función que recibe una fecha y devuelve el año en número. 
--TIENE MAS MIGA DE LO QUE APARENTA
CREATE OR REPLACE FUNCTION FECHA ( P_FECHA DATE)
    RETURN NUMBER
IS
    ANIO NUMBER;
BEGIN
   ANIO := TO_NUMBER(TO_CHAR(P_FECHA, 'YYYY'));
   RETURN ANIO;
    
END FECHA;

DECLARE
    V_FECHA DATE := '&ANIO'; 
    ANIO NUMBER;
BEGIN
   ANIO := FECHA(V_FECHA);
   DBMS_OUTPUT.PUT_LINE(ANIO);
END;


--5. Desarrollar una función que devuelva el número de años completos que hay entre dos fechas que se pasan como argumentos (como si fuera calcular la edad) 

CREATE OR REPLACE FUNCTION CONTAR_ANIOS(FECHA1 DATE, FECHA2 DATE)
    RETURN NUMBER
IS
    CANTIDAD_ANIOS NUMBER;
BEGIN 
    -- Usar ABS para asegurar que el resultado sea siempre positivo y FLOOR para redondear hacia abajo
    CANTIDAD_ANIOS := FLOOR(ABS(MONTHS_BETWEEN(FECHA1, FECHA2) / 12));
    RETURN CANTIDAD_ANIOS;
END CONTAR_ANIOS;
/

DECLARE
    fecha1 DATE := TO_DATE('01/01/2015', 'DD/MM/YYYY');
    fecha2 DATE := TO_DATE('01/01/2020', 'DD/MM/YYYY');
    resultado NUMBER;
BEGIN
    resultado := CONTAR_ANIOS(fecha1, fecha2);
    DBMS_OUTPUT.PUT_LINE('Años completos entre las fechas: ' || resultado);
END;
/



6. Escribir una función que, haciendo uso de la función anterior devuelva los trienios que 
hay entre dos fechas. (Un trienio son tres años completos). 

CREATE OR REPLACE FUNCTION TRIENIOS(FECHA1 DATE, FECHA2 DATE)
RETURN NUMBER
IS
    V_TRIENIOS NUMBER;
BEGIN
    V_TRIENIOS := CONTAR_ANIOS(FECHA1, FECHA2)/3; 
    RETURN FLOOR(V_TRIENIOS);
END TRIENIOS; 

DECLARE
    RESULTADO NUMBER; 
    FECHA1 DATE := TO_DATE('27/06/2028' , 'DD/MM/YYYY');
    FECHA2 DATE := TO_DATE('27/06/2024', 'DD/MM/YYYY'); 
BEGIN
    RESULTADO := TRIENIOS(FECHA1, FECHA2);
    DBMS_OUTPUT.PUT_LINE(RESULTADO); 
END; 
    


7. Escribir una función que recibe una cadena y la devuelve en mayúsculas y con  cualquier carácter que no sea una letra sustituido por el carácter blanco . 
Por ejemplo: 
 Caramelo -> CARAMELO 
 Ca%a6elo -> CA A ELO 
    
8. Función que recibe un apellido y devuelve la fecha de alta en la empresa o null si no 
existe el apellido en EMPLE 
--CORRECTO COMPILO TODO A LA PRIMERA
CREATE OR REPLACE FUNCTION FECHA_ALTA (P_APELLIDO EMPLE.APELLIDO%TYPE)
    RETURN DATE
IS
    V_APELLIDO EMPLE.APELLIDO%TYPE;
    V_FECHA_ALT EMPLE.FECHA_ALT%TYPE; 
BEGIN
    SELECT APELLIDO, FECHA_ALT INTO V_APELLIDO, V_FECHA_ALT FROM EMPLE WHERE APELLIDO = P_APELLIDO; 
    
    RETURN V_FECHA_ALT; 

END FECHA_ALTA;

DECLARE
    RESULTADO EMPLE.FECHA_ALT%TYPE; 
     V_APELLIDO EMPLE.APELLIDO%TYPE;
BEGIN
    RESULTADO:= FECHA_ALTA('SALA');
    DBMS_OUTPUT.PUT_LINE(RESULTADO);
END; 


9. Procedimiento que recibe un apellido de empleado y un nuevo oficio y modifica a este 
empleado el oficio. Validar que exista el empleado, mostrar el oficio antiguo y el 
nuevo. 

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE MODIFICAR_OFICIO (P_APELLIDO EMPLE.APELLIDO%TYPE , P_NEW_OFICIO EMPLE.OFICIO%TYPE)
IS
--DECLARE los procesimientos y funciones nunca llevan declare, eso son los bloques anonimos.
    V_APELLIDO  EMPLE.APELLIDO%TYPE;
    V_OFICIO  EMPLE.OFICIO%TYPE;

BEGIN
      SELECT APELLIDO, OFICIO INTO V_APELLIDO, V_OFICIO FROM EMPLE WHERE APELLIDO = P_APELLIDO; 
    
    IF V_APELLIDO IS NOT NULL THEN
        UPDATE EMPLE SET OFICIO = P_NEW_OFICIO WHERE APELLIDO = P_APELLIDO;
        DBMS_OUTPUT.PUT_LINE('EL OFICIO DE' || P_APELLIDO || ' HA SIDO MODIFICADO DE ' ||V_OFICIO || ' A ' || P_NEW_OFICIO); 
    END IF; 
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('EL APELLIDO ' || P_APELLIDO || ' NO EXISTE EN LA BBDD');

END MODIFICAR_OFICIO;

--PRUEBAS
EXECUTE MODIFICAR_OFICIO('SALA', 'HIGIENISTA');
SELECT OFICIO FROM EMPLE WHERE APELLIDO = 'SALA'; 

EXECUTE MODIFICAR_OFICIO('ALICIA', 'HIGIENISTA');  

ROLLBACK; 

--10. Procedimiento que muestra el salario máximo, mínimo y medio de un departamento  recibido por parámetro. 
SET SERVEROUTPUT ON; 
CREATE OR REPLACE PROCEDURE DEPART_SALARIOS(P_DEPT_NO EMPLE.DEPT_NO%TYPE)  --COMO ES UN DEPARTAMENTO ESPECIFICO NO HACE FALTA GROUP BY
IS 
    V_MAX EMPLE.SALARIO%TYPE; 
    V_MIN EMPLE.SALARIO%TYPE; 
    V_PROMEDIO EMPLE.SALARIO%TYPE; 
BEGIN
    SELECT MAX(SALARIO) , MIN(SALARIO), AVG(SALARIO) INTO V_MAX, V_MIN, V_PROMEDIO FROM EMPLE WHERE DEPT_NO = P_DEPT_NO;
    DBMS_OUTPUT.PUT_LINE( V_MAX || ' ' || V_MIN || '  ' || V_PROMEDIO);
     
    -- EN ESTE CASO ES NECESARIO LEVANTAR DATA_FOUND XK LAS VARIABLES SON FUNCIONES MAX, MIN, AVG....
    --SIN EMBARGO EN EL EJEMPLO DE ARRIBA TRABAJABAMOS DIRECTAMENTE CON LA COLUMNA DE UNA TABLA, NO ERA NECESARIO PLANTARLE UN RAISE AL DATA FOUND.
     IF V_PROMEDIO IS NULL THEN
        RAISE NO_DATA_FOUND; 
     END IF; 
     
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE( 'EL DEPARTAMENTO INTRODUCIDO NO EXISTE EN NUESTRA BBDD');
END DEPART_SALARIOS; 

EXECUTE DEPART_SALARIOS(76); 

--11. Escribe un procedimiento que dado el título de una serie muestre el código que le  corresponde siempre y cuando no haya más de uno. 
SET SERVEROUTPUT ON; 

CREATE OR REPLACE PROCEDURE BUSCAR_CODIGO (P_TITULO SERIE.SERIE_TITULO%TYPE)
IS
    V_COD SERIE.SERIE_ID%TYPE;
    DUPLICADO INT; 
     
    TITULO_DUPLICADO EXCEPTION; 
BEGIN
    SELECT COUNT(SERIE_TITULO) INTO  DUPLICADO FROM SERIE WHERE UPPER(SERIE_TITULO) = UPPER(P_TITULO);
                                                    

    IF DUPLICADO > 1 THEN
        RAISE TITULO_DUPLICADO;
    ELSIF DUPLICADO = 0 THEN
        RAISE NO_DATA_FOUND; --PORQUE ESTAMOS TRABAJANDO CON FUNCION ES NECESARIO LEVANTARLA
          
    ELSE --SOLO SI NO ES DUPLICADO Y ADEMAS SE ENCUENTRA EN LA BBDD BUSCAMOS EL CÓDIGO
        SELECT SERIE_ID INTO V_COD FROM SERIE WHERE UPPER(SERIE_TITULO) = UPPER(P_TITULO);
         DBMS_OUTPUT.PUT_LINE('EL CODIGO ES ' || V_COD);
    END IF;

    EXCEPTION 
        WHEN TITULO_DUPLICADO THEN
                DBMS_OUTPUT.PUT_LINE('EL TITULO INTRODUCIDO PERTENCE A VARIS CODIGOS'); 
        WHEN NO_DATA_FOUND THEN
             DBMS_OUTPUT.PUT_LINE('EL TITULO INTRODUCIDO NO PERTENECE A LA BBDD'); 
END BUSCAR_CODIGO; 

--PRUEBAS NO PERMITE EXECUTE ¿POR QUÉ?

-- Si necesitas manejar excepciones lanzadas por el procedimiento, como en tu caso con la excepción personalizada TITULO_DUPLICADO, 
 --necesitarás envolver la llamada en un bloque PL/SQL completo con secciones BEGIN, EXCEPTION, y END.
 
--tampoco te dejara si...Si la llamada al procedimiento forma parte de un conjunto más amplio de operaciones PL/SQL, como múltiples llamadas a procedimientos/funciones,
--operaciones condicionales, bucles, etc., entonces también necesitarás usar un bloque PL/SQL completo en lugar de EXECUTE.


--EXECUTE BUSCAR_CODIGO('THE KILLING'); --TITULO DUPLICADO
--EXECUTE BUSCAR_CODIGO('BORGEN');
BEGIN
    BUSCAR_CODIGO('THE KILLING'); --TITULO DUPLICADO;
    BUSCAR_CODIGO('ALICIA'); --NO EXISTE
    BUSCAR_CODIGO('BORGEN'); --COMPILA SIN EXCEPCION
END;


/********* EXPLICACION
En SQL, no puedes mezclar la recuperación de un valor concreto de un campo (como SERIE_ID) con una función de agregación (COUNT, MAX, MIN, etc.) en la misma consulta sin usar GROUP BY.
Cuando aplicas GROUP BY, la consulta agrupa los resultados por los campos especificados y aplica la función de agregación a cada grupo.

-- Esta consulta es incorrecta y no se ejecutará correctamente en SQL:
SELECT SERIE_ID, COUNT(*) INTO V_COD, DUPLICADO FROM SERIE WHERE UPPER(SERIE_TITULO) = UPPER(P_TITULO);
*/


--12. Escribe un procedimiento que dado el código de una serie muestre el total de  capítulos. Si la serie introducida por el usuario no existe en nuestra base de datos, se le 
--mostrará el siguiente mensaje al usuario: La serie introducida no existe. 

CREATE OR REPLACE PROCEDURE TOTAL_CAPITULOS(P_SERIE_ID SERIE.SERIE_ID%TYPE)
IS
    V_SERIE_ID  SERIE.SERIE_ID%TYPE;
    TOTAL_CAPITULOS INT;
BEGIN
    SELECT SUM(NVL(CAPITULO,0)) INTO TOTAL_CAPITULOS FROM CAPITULO WHERE SERIE_ID = P_SERIE_ID; 
    
    IF TOTAL_CAPITULOS IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE CAPITULOS ES: '|| TOTAL_CAPITULOS);
    ELSE
        RAISE NO_DATA_FOUND;
    END IF; 
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('LA SERIE INTRODUCIDA NO ESXISTE EN LA BBDD'); 

END TOTAL_CAPITULOS; 


--PRUEBAS
BEGIN
    TOTAL_CAPITULOS('BRGN'); 
    TOTAL_CAPITULOS('ALICIA'); 
END;

EXECUTE TOTAL_CAPITULOS('BRGN'); --EN ESTE CASO SI COMPILA CON EXCUTE Y ES UN SUM


--13. Convertir el ejercicio anterior en una función para que devuelva el número de  capítulos en lugar de imprimirlos. 


CREATE OR REPLACE FUNCTION F_TOTAL_CAPITULOS(P_SERIE_ID SERIE.SERIE_ID%TYPE)
RETURN INT
IS
    V_SERIE_ID  SERIE.SERIE_ID%TYPE;
    TOTAL_CAPITULOS INT;
BEGIN
    SELECT SUM(NVL(CAPITULO,0)) INTO TOTAL_CAPITULOS FROM CAPITULO WHERE SERIE_ID = P_SERIE_ID;   
    IF TOTAL_CAPITULOS IS NOT NULL THEN
        RETURN TOTAL_CAPITULOS;
    ELSE
        RAISE NO_DATA_FOUND;
    END IF; 
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            RETURN -1;
END F_TOTAL_CAPITULOS; 


DECLARE
    RESULTADO INT;
BEGIN
   RESULTADO :=  F_TOTAL_CAPITULOS('BRGN'); 
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE CAPITULOS ES: '|| RESULTADO);
    RESULTADO:=  F_TOTAL_CAPITULOS('ALICIA'); 
        DBMS_OUTPUT.PUT_LINE('EL TOTAL DE CAPITULOS ES: '|| RESULTADO);
END;


--14. Utilizar la función correspondiente al ejercicio anterior para rellenar la columna  CAPÍTULOS de la tabla SERIE. Para llamar a la función hacerlo desde un 
--procedimiento al cual se le pasa como parámetro el código de la serie. 

CREATE OR REPLACE PROCEDURE RELLENAR_CAPITULOS
IS
    V_SERIE_ID  SERIE.SERIE_ID%TYPE := 'BRGN'; 
    RESULTADO INT; 
BEGIN
    
    RESULTADO :=  F_TOTAL_CAPITULOS(V_SERIE_ID); --IMPORTANTE VINCULAR LA VARIABLE CON EL PARAMETRO, SI LO HACES DIRECTAMENTE NO ACTUALIZA LA COLUMNA
    
    IF RESULTADO = -1 THEN
        DBMS_OUTPUT.PUT_LINE(' LA SERIE INTRODUCIDA NO EXISTE, NO PROCEDEMOS A INTRODUCIR NINGUN DATO EN CAPITULOS'); 
    
    ELSE
        UPDATE SERIE SET CAPITULOS = NVL(CAPITULOS, 0)+RESULTADO WHERE SERIE_ID = V_SERIE_ID; --SI NO VUELVES A ESPECIFICAR EN ESTE PROCEDIMIENTO EL ID, TE METE EL RETORNO DE ESE ID EN TODAS LAS COLUMNAS
         DBMS_OUTPUT.PUT_LINE('COLUMNA CAPITULOS ACTUALIZADA'); 
    
    END IF;
END RELLENAR_CAPITULOS; 

EXECUTE RELLENAR_CAPITULOS;

ROLLBACK; 
15. Escribe un procedimiento que dado el nombre de un autor, muestre el número de  personajes que interpreta. 

CREATE OR REPLACE PROCEDURE NUM_PERSONAJES (P_ACTOR_NOMBRE ACTOR.ACTOR_NOMBRE%TYPE)
IS
    CANTIDAD_PERSONAJES INT := 0; 
    
    NO_EXISTE EXCEPTION; 
    

BEGIN
    SELECT COUNT(R.ACTOR_ID)INTO CANTIDAD_PERSONAJES FROM REPARTO R JOIN ACTOR A ON A.ACTOR_ID = R.ACTOR_ID WHERE UPPER(A.ACTOR_NOMBRE) = UPPER(P_ACTOR_NOMBRE);
    
    
    IF CANTIDAD_PERSONAJES != 0 THEN 
        DBMS_OUTPUT.PUT_LINE(CANTIDAD_PERSONAJES || ' SON LOS PERSONAJES INTERPRETADOS POR EL ACTOR ' || P_ACTOR_NOMBRE); 
    
     ELSE
        RAISE NO_EXISTE; 
       
    END IF; 
    
    EXCEPTION
        WHEN NO_EXISTE THEN
            DBMS_OUTPUT.PUT_LINE(' EL ACTOR INTRODUCIDO NO EXISTE EN NUESTRA BBDD'); 
    
END NUM_PERSONAJES; 

EXECUTE NUM_PERSONAJES('BRYAN CRANSTON'); 
EXECUTE NUM_PERSONAJES ('ALICIA'); 



16. Procedimiento que recibe un departamento y busca el empleado con menos salario de  dicho departamento para subirle un porcentaje que recibe como parámetro, Validar 
que con ese porcentaje no supere la media del departamento, en cuyo caso no se  modifica.

CREATE OR REPLACE PROCEDURE INCREMETAR_SALARIO (P_DEPT_NO DEPART.DEPT_NO%TYPE, PORCENTAJE NUMBER)
IS
    PROMEDIO EMPLE.SALARIO%TYPE; 
    AUMENTO EMPLE.SALARIO%TYPE; 
    
    PORCENTAJE_NO_VALIDO EXCEPTION; 
    AUMENTO_SUPERA_MEDIA EXCEPTION; 
    
BEGIN
    -- Verificar primero el rango del porcentaje
    IF PORCENTAJE NOT BETWEEN 1 AND 100 THEN 
         RAISE PORCENTAJE_NO_VALIDO; 
    END IF;
    
    -- Calcular el promedio de salario del departamento
    SELECT AVG(SALARIO) INTO PROMEDIO FROM EMPLE WHERE DEPT_NO = P_DEPT_NO;

    -- Determinar el aumento aplicando el porcentaje al salario más bajo en el departamento
    SELECT MIN(SALARIO) INTO AUMENTO FROM EMPLE WHERE DEPT_NO = P_DEPT_NO;
    AUMENTO := AUMENTO + (AUMENTO * PORCENTAJE / 100);

    -- Comprobar si el aumento supera el promedio
    IF PROMEDIO < AUMENTO THEN 
        RAISE AUMENTO_SUPERA_MEDIA; 
    ELSE
         -- Aplicar el aumento al empleado con el salario más bajo en el departamento
         UPDATE EMPLE
         SET SALARIO = AUMENTO
         WHERE DEPT_NO = P_DEPT_NO AND SALARIO = (SELECT MIN(SALARIO) FROM EMPLE WHERE DEPT_NO = P_DEPT_NO);
         DBMS_OUTPUT.PUT_LINE(' SALARIO MODIFICADO '); 
    END IF;
        
EXCEPTION
    WHEN AUMENTO_SUPERA_MEDIA THEN
        DBMS_OUTPUT.PUT_LINE('EL AUMENTO SUPERA LA MEDIA DEL DEPARTAMENTO, NO MODIFICAMOS EL SALARIO'); 
    WHEN PORCENTAJE_NO_VALIDO THEN
        DBMS_OUTPUT.PUT_LINE('EL PORCENTAJE INTRODUCIDO DEBE COMPRENDER ENTRE 1 Y 100');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('DEPARTAMENTO INTRODUCIDO NO ENCONTRADO EN LA BBDD'); 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR DESCONOCIDO'); 
END INCREMETAR_SALARIO;

BEGIN
 INCREMETAR_SALARIO(10, 1);-- DATOS CORRECTOS

 INCREMETAR_SALARIO(10, 101); --PORCENTAJE NO VALIDO
END; 



17. Codificar un procedimiento que permita borrar un empleado cuyo número se pasará en  la llamada. 

SET SERVEROUTPUT ON; 

CREATE OR REPLACE PROCEDURE ELIMINAR_EMPLE(P_EMP_NO EMPLE.EMP_NO%TYPE)
IS
    V_EMP_NO EMPLE.EMP_NO%TYPE; 
 
BEGIN
    SELECT EMP_NO INTO V_EMP_NO FROM EMPLE WHERE EMP_NO = P_EMP_NO; 
    
    IF V_EMP_NO IS NULL THEN
        RAISE NO_DATA_FOUND;
    ELSE
        DELETE EMPLE WHERE EMP_NO = P_EMP_NO;
        IF SQL%ROWCOUNT = 1 THEN
            DBMS_OUTPUT.PUT_LINE('EMPLEADO ELIMINADO CORRECTAMENTE');
        ELSE 
             DBMS_OUTPUT.PUT_LINE('FALLO EN LA ELIMINACION');
        END IF;
    END IF; 

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('EMPLEADO '|| P_EMP_NO ||' NO EXISTEN EN LA BBDD');
END ELIMINAR_EMPLE;

BEGIN
    ELIMINAR_EMPLE(7934);--ELIMINA A SALA
    ELIMINAR_EMPLE(6);--NO ELIMINA A NADIE
END; 

ROLLBACK;

18. Procedimiento que recibe el nombre de un departamento y un porcentaje. Dentro del  procedimiento validar que el porcentaje sea un valor entre 0 y 100. 
Mediante una  función hallar el código del departamento. Si no existiera mensaje de error y acaba el  procedimiento. Subir el salario en el porcentaje indicado a los empleados del 
departamento siempre que al aplicar el porcentaje no superen el salario del presidente  de la empresa. 

SET SERVEROUTPUT ON; 

CREATE OR REPLACE FUNCTION BUSCAR_COD (P_DNOMBRE DEPART.DNOMBRE%TYPE)
    RETURN DEPART.DEPT_NO%TYPE
IS
    RESULTADO DEPART.DEPT_NO%TYPE; 
BEGIN
    SELECT DEPT_NO INTO RESULTADO FROM DEPART WHERE UPPER(DNOMBRE) = UPPER(P_DNOMBRE); 
    RETURN RESULTADO;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END BUSCAR_COD;



CREATE OR REPLACE PROCEDURE SUBIR_SALARIO (P_DNOMBRE DEPART.DNOMBRE%TYPE, PORCENTAJE NUMBER)
IS
    --VARIABLES
    COD_DEPART DEPART.DEPT_NO%TYPE; 
    SALARIO_PRESIDENTE EMPLE.SALARIO%TYPE;
    AUMENTO EMPLE.SALARIO%TYPE;
    CONTADOR_AUMENTOS INT := 0;
    
    --CURSORES
    CURSOR C1 IS SELECT EMP_NO , SALARIO FROM EMPLE WHERE DEPT_NO = COD_DEPART; --VARIABLE QUE ALMACENABA EL CODIGO QUE DEVUELVE EL NOMBRE
    
    --EXCEPCIONES
    PORCENTAJE_NO_VALIDO EXCEPTION; 
    DEPARTAMENTO_NO_VALIDO EXCEPTION; 


BEGIN
    
    IF PORCENTAJE NOT BETWEEN 0 AND 100 THEN
        RAISE PORCENTAJE_NO_VALIDO;
    END IF;
    
    --SI EL % ES VALIDO, COMPROBAMOS QUE EL DEPARTAMENTO EXISTA
    COD_DEPART := BUSCAR_COD(P_DNOMBRE);
    
    IF COD_DEPART IS NULL THEN
        RAISE DEPARTAMENTO_NO_VALIDO;
     
     ELSE   
        --SI EL DEPARTAMENTO EXISTE ENTONCES CONSULTAMOS EL SALARIO DEL PRESIDENTE
            
            SELECT SALARIO INTO SALARIO_PRESIDENTE FROM EMPLE WHERE UPPER(OFICIO) = 'PRESIDENTE';
            
            FOR V1 IN C1 LOOP
        
                    AUMENTO := V1.SALARIO + (V1.SALARIO * PORCENTAJE/100);
                    
                    IF AUMENTO > SALARIO_PRESIDENTE THEN
                        DBMS_OUTPUT.PUT_LINE('EL SALARIO INTRODUCIDO SUPERA AL DEL PRESIDENTE');   
                    ELSE
                        UPDATE EMPLE SET SALARIO = AUMENTO WHERE EMP_NO = V1.EMP_NO; 
                         DBMS_OUTPUT.PUT_LINE('EL SALARIO DE ' || V1.EMP_NO || ' HA SIDO AUMENTADO A ' || V1.SALARIO);  
                         CONTADOR_AUMENTOS := CONTADOR_AUMENTOS +1; 
                         
                    END IF;
                    
           END LOOP;    
            DBMS_OUTPUT.PUT_LINE('EL NUMERO DE SALARIOS AUMENTOS ES DE: ' || CONTADOR_AUMENTOS);    
    END IF; 

    EXCEPTION
        WHEN PORCENTAJE_NO_VALIDO THEN
            DBMS_OUTPUT.PUT_LINE('EL PORCENTAJE INTRODUCIDO DEBE COMPRENDER ENTRE 0 Y 100'); 
        WHEN DEPARTAMENTO_NO_VALIDO THEN
            DBMS_OUTPUT.PUT_LINE('EL DEPARTAMENTO ' || P_DNOMBRE || ' NO EXISTE EN NUESTRA BBDD'); 
END SUBIR_SALARIO; 


EXECUTE SUBIR_SALARIO('CONTABILIDAD', 10); --CORRECTOS

BEGIN
  SUBIR_SALARIO('CONTABILIDAD', 101); -- Porcentaje no válido
END;
/

BEGIN
  SUBIR_SALARIO('CONTA', 10); -- Departamento no válido
END;
/



19. Utilizando las tablas del TALLER realiza un procedimiento para dar de alta un nuevo 
arreglo o acabar uno existente. Recibe: 

• Un indicador de lo que se va a hacer: ‘A’ alta de nuevo arreglo, ‘T’ terminar un arreglo. 
• Matrícula del coche que va a arreglar 
• Función del mecánico que necesita 
• Importe del arreglo 
Comprobar que el indicador sea ‘A’ o ‘T’, si no es así levantamos una excepción 
informando al usuario de que hay datos incorrectos y se acaba el procedimiento. 
Cuando sea ‘A’ alta haremos: 
• Mediante una función Busca_Matricula a la que le pasamos la matrícula recibida 
comprobamos que esta exista. 
Si existe devolvemos true. 
Si no existe: 
Comprobamos que la matrícula tenga 4 dígitos y tres letras. Si no es así la 
función devuelve false. 
Si está bien la damos de alta en Coches_Taller dejando el resto de campos a 
nulo excepto ncliente que será 0. Más adelante ya rellenaremos los datos 
necesarios. 
• Si la función Busca_Matricula devolvió false levantamos una excepción 
informando al usuario de que hay datos incorrectos y se acaba el procedimiento. 
• Pasar la función recibida a una función Busca_Funcion que devolverá el 
nempleado de: 
o Si no hay nadie con esa función, el nempleado del más antiguo en el taller. 
o Si hay varios, el más nuevo de los de esa función. 
o Si hay uno solo, ese. 
3 
• Dar de alta un arreglo con la matricula recibida, el nempleado devuelto por la 
anterior función, fecha de entrada la del sistema, fecha de salida a nulo e importe 
el recibido si es mayor o igual a 0. Si no dejarlo a nulo. 
Cuando sea ‘T’ significa que el arreglo ha terminado. Haremos: 
• Comprobar que exista un registro en ARREGLOS con la matricula recibida y la 
fecha de salida a nulo. Si no es así dar un mensaje de error y acaba el 
procedimiento. 
• SI existe el registro actualizarlo poniendo en la fecha de salida la fecha del sistema 
y en el importe el recibido si es mayor que 0, si no dejar el que tuviera. 
 
 
 
 
 
20. Crear un procedimiento llamado PBORRA_AUTOR que permita borrar un autor 
cuyo idAutor se pasará como parámetro. Se visualizará un mensaje con el nombre del 
autor borrado o un mensaje de error. 

CREATE OR REPLACE  PROCEDURE ELIMINAR_AUTOR (PIDAUTOR AUTORES.IDAUTOR%TYPE)
IS
BEGIN
    
    DELETE AUTORES WHERE IDAUTOR = PIDAUTOR;
    
    IF SQL%ROWCOUNT = 1 THEN
        DBMS_OUTPUT.PUT_LINE('AUTOR ELIMINADO');
        --COMMIT; 
    ELSE   
        DBMS_OUTPUT.PUT_LINE('ERROR EN LA ELIMINACION');
       
    END IF; 
    
    EXCEPTION 
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('HA EXISTIDO ALGUN TIPO DE FALLO ..>' || SQLERRM); 
            ROLLBACK; 
END ELIMINAR_AUTOR; 

SET SERVEROUTPUT ON; 

EXECUTE ELIMINAR_AUTOR(6);
ROLLBACK; 
EXECUTE ELIMINAR_AUTOR(1009); 





21. Codificar un bloque anónimo que llame al procedimiento PBORRA_AUTOR, se leerá 
el idAutor desde teclado. 

DECLARE
    CODIGO AUTORES.IDAUTOR%TYPE := &CODIGO_AUTOR;
BEGIN

    ELIMINAR_AUTOR(CODIGO);
END; 

ROLLBACK;
22. Crear una función FCUANTOS_LIBROS al que se le pasa un idAutor y devuelve el 
número de libros de ese autor. 

CREATE OR REPLACE FUNCTION CANTIDAD_LIBROS (PIDAUTOR AUTORES.IDAUTOR%TYPE)
RETURN INT
IS
    CANTIDAD INT := 0;
BEGIN
    SELECT COUNT(*) INTO CANTIDAD FROM LIBROS_AUTORES WHERE IDAUTOR = PIDAUTOR; --CON COUNT NO ES NECESARIO USAR NO_DATA_FOUND YA QUE NUNCA VA ENTRAR AHI, SI NO TIENE RESULTADOS SERÁ 0 SIEMPRE
    RETURN CANTIDAD;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RETURN 0;
END CANTIDAD_LIBROS;

-- Bloque de prueba para la función
DECLARE
    RESULTADO INT;
    PIDAUTOR AUTORES.IDAUTOR%TYPE := 9; -- Asigna un valor de prueba adecuado
BEGIN
    RESULTADO := CANTIDAD_LIBROS(PIDAUTOR);
    DBMS_OUTPUT.PUT_LINE('LA CANTIDAD DE LIBROS DEL ID ' || PIDAUTOR || ' ES ' || RESULTADO);
END;



23. Hacer una función FEXISTE_AUTOR al que le paso el idAutor y devuelve true si 
dicho autor existe en la tabla Autores o false en caso contrario. 

CREATE OR REPLACE FUNCTION EXISTE_AUTOR(PID AUTORES.IDAUTOR%TYPE)
RETURN BOOLEAN
IS
    EXISTE BOOLEAN := FALSE; 
    CONTADOR INT := 0; 
BEGIN
    
    SELECT COUNT(*) INTO CONTADOR FROM AUTORES WHERE IDAUTOR = PID; 
    
    
    IF CONTADOR > 0 THEN 
        EXISTE := TRUE; 
    END IF; 
    
    RETURN EXISTE; 
END EXISTE_AUTOR; 


DECLARE 
     EXISTE BOOLEAN := FALSE;
     PID AUTORES.IDAUTOR%TYPE := 983; 
BEGIN
    EXISTE := EXISTE_AUTOR(PID);
    DBMS_OUTPUT.PUT_LINE(CASE WHEN EXISTE THEN 'TRUE' ELSE 'FALSE' END); 
    
END; 
    


24. Desarrolla un nuevo procedimiento PINSERTA_LIBRO para insertar un libro en la  base de datos. Se comprobará que existe el autor en la tabla Autores llamando a la 
función FEXISTE_AUTOR. Se leerán todos sus datos desde teclado, excepto la fecha  de publicación que se introducirá la del sistema. 

CREATE OR REPLACE PROCEDURE INSERTAR_LIBRO (
    PID LIBROS_AUTORES.IDLIBRO%TYPE, 
    PTITULO LIBROS_AUTORES.TITULO%TYPE,
    PNUMPAGINAS LIBROS_AUTORES.NUMPAGINAS%TYPE,
    PFECHA LIBROS_AUTORES.FECHAPUB%TYPE, 
    PIDAUTOR LIBROS_AUTORES.IDAUTOR%TYPE
)
IS
    V_EXISTE_AUTOR BOOLEAN := FALSE;
    ID_DUPLICADO INT; 
    

    -- Excepciones
    AUTOR_NO_VALIDO EXCEPTION; 
    LIBRO_ID_DUPLICADO EXCEPTION;

BEGIN
    SELECT COUNT(*) INTO ID_DUPLICADO FROM LIBROS_AUTORES WHERE IDLIBRO = PID; 
    
    IF ID_DUPLICADO = 1 THEN
        RAISE LIBRO_ID_DUPLICADO;
        
    ELSE
    
    
            -- Llamada a la función que verifica la existencia del autor
            V_EXISTE_AUTOR := EXISTE_AUTOR(PIDAUTOR);
        
            -- Si el autor existe, insertamos el libro
            IF V_EXISTE_AUTOR THEN
                INSERT INTO LIBROS_AUTORES (IDLIBRO, TITULO, NUMPAGINAS, FECHAPUB, IDAUTOR)
                VALUES (PID, PTITULO, PNUMPAGINAS, PFECHA, PIDAUTOR);
                IF SQL%ROWCOUNT = 1 THEN
                    DBMS_OUTPUT.PUT_LINE('EL LIBRO SE HA INSERTADO CORRECTAMENTE');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('FALLO DE INSERCCIÓN');
                END IF; 
            ELSE
                -- Si el autor no existe, se lanza una excepción personalizada
                RAISE AUTOR_NO_VALIDO; 
            END IF; 
            
    END IF; 
    

EXCEPTION
    -- Manejo de la excepción en caso de que el autor no esté registrado
    WHEN AUTOR_NO_VALIDO THEN
        DBMS_OUTPUT.PUT_LINE('EL AUTOR INTRODUCIDO NO ESTÁ REGISTRADO EN LA BBDD'); 
    WHEN LIBRO_ID_DUPLICADO THEN
        DBMS_OUTPUT.PUT_LINE('EL ID DEL LIBRO INTRODUCIDO VIOLA LA PRIMARY KEY, SELECCIONA OTRO ID'); 
END INSERTAR_LIBRO;


25. Crear un bloque anónimo que llame al procedimiento PINSERTA_LIBRO 

DECLARE
    v_id_libro LIBROS_AUTORES.IDLIBRO%TYPE;
    v_titulo LIBROS_AUTORES.TITULO%TYPE;
    v_numpaginas LIBROS_AUTORES.NUMPAGINAS%TYPE;
    v_fecha LIBROS_AUTORES.FECHAPUB%TYPE := SYSDATE;  -- Usamos la fecha actual como ejemplo
    v_id_autor LIBROS_AUTORES.IDAUTOR%TYPE;
BEGIN
    -- Aquí el usuario introduciría los valores manualmente o serían obtenidos por un front-end
    v_id_libro := &ID_LIBRO;
    v_titulo := '&TITULO';
    v_numpaginas := &PAGINAS;
    v_id_autor := &ID_AUTOR;

    INSERTAR_LIBRO(v_id_libro, v_titulo, v_numpaginas, v_fecha, v_id_autor);
END;




26. Realiza una función que reciba una cadena y devuelva la cadena invertida. Poned un 
ejemplo de llamada a la función. 

CREATE OR REPLACE FUNCTION INVERTIR_CADENA (CADENA VARCHAR2)
RETURN VARCHAR2
IS
CADENA_INVERTIDA VARCHAR2(100); 

BEGIN
    
    FOR I IN REVERSE 1..LENGTH(CADENA) LOOP
        
        CADENA_INVERTIDA := CADENA_INVERTIDA || SUBSTR(CADENA,I,1); 
    
    END LOOP; 
    
    RETURN CADENA_INVERTIDA; 
END INVERTIR_CADENA;


DECLARE 
    CADENA VARCHAR2(100) := '&CADENA'; -- Aumentado para mayor flexibilidad
    RESULTADO VARCHAR2(100);           -- Ajustado para coincidir con el tamaño de CADENA
BEGIN
    RESULTADO := INVERTIR_CADENA(CADENA); 
    DBMS_OUTPUT.PUT_LINE(RESULTADO); 
END; 



SET SERVEROUTPUT ON; 

