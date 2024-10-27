--Estos son bloques anonimos, para volver a ejecutarlos y usarlos debo 
--guardarlos en algun lado para poder volver a usarlos, sino se pierden.

--Siempre, primero la siguiente linea para que muestre lo que quiero imprimir por pantalla.
SET SERVEROUTPUT ON;

--1. Construir un bloque PL/SQL que escriba el texto 'Hola nom_alumno'. Donde 
--nom_alumno deberia de ser sustituido por el nombre del alumno. 
DECLARE
NOM_ALUMNO VARCHAR2(20);
BEGIN
DBMS_OUTPUT.PUT_LINE('Hola ' || '&NOM_ALUMNO');
END;

--2. Realizar un bloque en el que se definan tres variables de tipo number y se inicialicen a 5, 
--8 y 3 respectivamente. La funcionalidad del bloque consistir en sumar las variables 1 y 2 
--y multiplicar el resultado obtenido por la tercera variable. Finalmente, se imprime el 
--valor resultado precedido de la siguiente frase: -El resultado es :. 
DECLARE
V_UNO NUMBER(2) DEFAULT 5;
V_DOS NUMBER(2) := 8;
V_TRES NUMBER(2)DEFAULT 3;

BEGIN
V_TRES := (V_UNO+V_DOS)*V_TRES;
DBMS_OUTPUT.PUT_LINE('El resultado es ' || V_TRES);
END;

--3. Realiza un bloque anï¿œnimo que pida un valor de radio con decimales y obtï¿œn el ï¿œrea del 
--cï¿œrculo. Declara el valor de pi como una constante.
DECLARE
V_RADIO NUMBER(5,2) := &V_RADIO;
V_PI CONSTANT NUMBER(3,2) := 3.14;
V_AREA NUMBER(5,2);

BEGIN
V_AREA := V_PI*(V_RADIO*V_RADIO);
DBMS_OUTPUT.PUT_LINE('El Area del circulo es: ' || V_AREA);
END;

--4. Pide un nombre y un apellido y muestra el resultado de su concatenaciï¿œn en mayï¿œsculas, 
--asï¿œ como la longitud del resultado concatenado 
DECLARE
V_NOMBRE VARCHAR2(20);
V_APELLIDO VARCHAR2(20);
V_LONGITUD NUMBER(5):= (LENGTH('V_NOMBRE')+LENGTH('V_APELLIDO'));
BEGIN
DBMS_OUTPUT.PUT_LINE(UPPER('&V_NOMBRE')||UPPER('&V_APELLIDO')||V_LONGITUD);
END;

--5. Solicita una fecha al usuario y muestra la informaciï¿œn de dï¿œa, mes (en letra) y aï¿œo en 
--lï¿œneas separadas. 
DECLARE
FECHA DATE := TO_DATE('&FECHA', 'DD-MM-YYYY');
BEGIN
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'DAY'));
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'MONTH'));
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'YEAR'));
END;

--6. Repite el ejercicio anterior con la fecha del sistema y visualizando en una lï¿œnea mï¿œs la 
--hora (hora y minutos separados por :). 
DECLARE
FECHA DATE := SYSDATE;
BEGIN
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'DAY'));
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'MONTH'));
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'YEAR'));
DBMS_OUTPUT.PUT_LINE(TO_CHAR(FECHA,'HH24:MI')); --FORMATO DE HORA CON LOS MINUTOS INCLUIDOS
END;

--7. Pide al usuario un numero y comprueba si es par o impar, mostrando un mensaje que lo 
--indique. 

SET SERVEROUT ON; 


DECLARE
    NUM NUMBER(3) := '&NUMERO'; --PUEDES DECLARARLA AQUI
BEGIN
    IF MOD(NUM,2)= 0 THEN
        DBMS_OUTPUT.PUT_LINE('EL NUMERO '||NUM|| ' ES PAR');
    ELSE
          DBMS_OUTPUT.PUT_LINE('EL NUMERO '||NUM|| ' ES IMPAR');
    END IF;
END; 

DECLARE 
NUMERO NUMBER(2);
BEGIN
NUMERO  := &NUMERO; -- O PUEDES INICIALIZARLA EN BEGIN.
IF MOD(NUMERO,2) = 0 THEN
DBMS_OUTPUT.PUT_LINE('ES PAR');
ELSE
DBMS_OUTPUT.PUT_LINE('ES IMPAR');
END IF;
END;

--8. Pide al usuario una cadena y una letra. Emite un mensaje que diga si la letra forma parte o 
--no de la cadena 

DECLARE
CADENA VARCHAR2(25):= UPPER('&CADENA'); --PONER LAS COMILLAS SINO SOLO ACEPTA NUMEROS
LETRA CHAR(1):= UPPER('&LETRA'); --PONER LAS COMILLAS SINO SOLO ACEPTA NUMEROS
BEGIN
IF INSTR(CADENA, LETRA) > 0 THEN
DBMS_OUTPUT.PUT_LINE('La letra introducida ESTA en la cadena.');
ELSE
DBMS_OUTPUT.PUT_LINE('La letra introducida NO ESTA en la cadena');
END IF;
END;


--9. Modifica el ejemplo anterior solicitando 2 letras e indicando si aparece alguna de las dos 
--letras, las dos letras o ninguna 

--SOLUCCION CON IF
DECLARE
CADENA VARCHAR2(25):= UPPER('&CADENA'); --PONER LAS COMILLAS SINO SOLO ACEPTA NUMEROS
LETRA1 CHAR(1):= UPPER('&LETRA'); --PONER LAS COMILLAS SINO SOLO ACEPTA NUMEROS
LETRA2 CHAR(1):= UPPER('&LETRA'); 
BEGIN 
    IF INSTR(CADENA, LETRA1) > 0 AND INSTR(CADENA, LETRA2) > 0 THEN DBMS_OUTPUT.PUT_LINE('LAS DOS LETRAS APARECEN EN LA CADENA');
    ELSIF INSTR(CADENA, LETRA1) > 0 OR INSTR(CADENA, LETRA2) >0 THEN DBMS_OUTPUT.PUT_LINE('ALGUNA DE LAS LETRAS APARECEN EN LA CADENA');
    ELSE  DBMS_OUTPUT.PUT_LINE('NINGUNA DE LAS LETRAS APARECEN EN LA CADENA');
    END IF; 
END; 

--SOLUCION CON CASE
DECLARE
CADENA VARCHAR2(25):= UPPER('&CADENA'); --PONER LAS COMILLAS SINO SOLO ACEPTA NUMEROS
LETRA1 CHAR(1):= UPPER('&LETRA'); --PONER LAS COMILLAS SINO SOLO ACEPTA NUMEROS
LETRA2 CHAR(1):= UPPER('&LETRA'); 
BEGIN 
    CASE
    WHEN INSTR(CADENA, LETRA1) > 0 AND INSTR (CADENA, LETRA2) > 0 THEN DBMS_OUTPUT.PUT_LINE('LAS DOS LETRAS APARECEN EN LA CADENA'); 
    WHEN INSTR(CADENA, LETRA1) > 0 OR INSTR (CADENA, LETRA2) > 0 THEN DBMS_OUTPUT.PUT_LINE('UNA DE LAS DOS LETRAS APARECEN EN LA CADENA');
    WHEN INSTR(CADENA, LETRA1) = 0 AND INSTR(CADENA, LETRA2) = 0 THEN DBMS_OUTPUT.PUT_LINE('Ninguna de las letras aparece en la cadena'); --LO METISTE COMO UN ELSE Y FALLABA
    END CASE; 
END; 
    


--EXTRA --> ESTE ENUNCIADO ME LO INVENTADO, PERO BASICAMENTE CUENTA EL NUMERO DE VECES QUE APARECE LA LETRA EN LA CADENA

DECLARE
    CADENA VARCHAR2(10) := '&CADENA';
    LETRA CHAR(1) := '&LETRA';
    CONTADOR_LETRA NUMBER(1) := 0; 
BEGIN
    FOR i IN 0..LENGTH(CADENA) LOOP
        IF SUBSTR(CADENA, i, 1) = LETRA THEN --INCREMENTAMOS EL CONTADOR SI ES IGUAL QUE LA LETRA
            CONTADOR_LETRA := CONTADOR_LETRA +1; 
        END IF; 
    END LOOP; 
    
    IF CONTADOR_LETRA  = 1 THEN DBMS_OUTPUT.PUT_LINE('LA LETRA: '||LETRA|| ' APARECE UNA ÚNICA VEZ'); 
    ELSIF CONTADOR_LETRA  >1 THEN DBMS_OUTPUT.PUT_LINE('LA LETRA: '||LETRA|| ' APARECE VARIAS VECES'); 
    ELSE  DBMS_OUTPUT.PUT_LINE('LA LETRA: '||LETRA|| ' NO APARECE EN LA CADENA'); 
    END IF; 
END; 

--10. Dados 2 numeros, calcula el resultado de dividir el mayor de ambos entre el menor. Ojo, 
--si el menor es 0, emite un mensaje que indique que no se puede hacer la division.

DECLARE 
    NUM_MAYOR NUMBER := &NUMERO1;
    NUM_MENOR NUMBER := &NUMERO2;
    INTERCAMBIO NUMBER; 
    RESULTADO NUMBER; 
BEGIN
    --PRIMERO CONTROLAREMOS QUE EL NUMERO MAYOR SE DIVIDA POR EL MENOR
    IF NUM_MENOR > NUM_MAYOR THEN
        INTERCAMBIO := NUM_MAYOR; --INTERCAMBIO GUARDA EL VALOR DE NUM_MAYOR
        NUM_MAYOR := NUM_MENOR; --MAYOR ACOGERA EL NUMERO MENOR QUE EN REALIDAD ES MAYOR.
        NUM_MENOR := INTERCAMBIO; --Y NUM MENOR SE QUEDARA CON EL VALOR DE NUM_MAYOR QUE EN REALIDAD ES MENOR
    ELSIF NUM_MENOR = 0 THEN 
        --CAPTURAMOS LA EXCEPCION: 
        RAISE_APPLICATION_ERROR(-20001, 'ERROR NO SE PUEDE DIVIDIR POR CERO'); 
    END IF; 

    RESULTADO := NUM_MAYOR / NUM_MENOR; 
    DBMS_OUTPUT.PUT_LINE(RESULTADO);
EXCEPTION
    WHEN ZERO_DIVIDE THEN  --ZERO_DIVIDE ES UNA VARIABLE DE PL/SQL PARA CONTROLAR ESTE TIPO DE EXCEPCIONES
         DBMS_OUTPUT.PUT_LINE('Error: Se intentó dividir por 0');
END; 
    

DECLARE
NUMERO1 NUMBER(2):= &NUMERO1;
NUMERO2 NUMBER(2):= &NUMERO2;
RESULTADO NUMBER(2);
BEGIN
IF NUMERO1 > NUMERO2 AND NUMERO2 != 0 THEN
RESULTADO := NUMERO1/NUMERO2;
DBMS_OUTPUT.PUT_LINE('El resultado de la division es: ' || RESULTADO);
ELSIF NUMERO2 > NUMERO1 AND NUMERO1 != 0 THEN
RESULTADO := NUMERO2/NUMERO1;
DBMS_OUTPUT.PUT_LINE('El resultado de la division es: ' || RESULTADO);
ELSE
DBMS_OUTPUT.PUT_LINE('ERROR, El divisor menor es 0');
END IF;
END;

--11. Dados 3 nUmeros, muestra un mensaje que indique si alguno de ellos es equivalente a la  suma de los otros dos. 

DECLARE 
    NUM1 NUMBER := '&NUMERO1';
    NUM2 NUMBER := '&NUMERO2';
    NUM3 NUMBER := '&NUMERO3';
    RESULTADO BOOLEAN := FALSE;
BEGIN 

    IF NUM1+NUM2 = NUM3 OR  NUM1+NUM3 = NUM2 OR  NUM2+NUM3 = NUM1 THEN 
        RESULTADO := TRUE; 
    END IF; 
      DBMS_OUTPUT.PUT_LINE('ALGUNA SUMA TIENE COMO RESULTADO LA SUMA DE LAS OTRA DOS: '|| CASE WHEN RESULTADO THEN 'TRUE' ELSE 'FALSE' END); -- SQL NO PERMITE IMPRIMIR DIRECTAMENTE VALORES BOOL
END; 
  

DECLARE
NUM1 NUMBER(3) := &NUM1;
NUM2 NUMBER(3) := &NUM2;
NUM3 NUMBER(3) := &NUM3;
BEGIN
CASE
WHEN NUM1+NUM2 = NUM3 THEN
DBMS_OUTPUT.PUT_LINE(NUM3 ||' es el TERCER numero introducido y es EQUIVALENTE a la suma de los otros dos');
WHEN NUM3+NUM2 = NUM1 THEN
DBMS_OUTPUT.PUT_LINE(NUM1 ||' es el PRIMER numero introducido y es EQUIVALENTE a la suma de los otros dos');
WHEN NUM1+NUM3 = NUM2 THEN
DBMS_OUTPUT.PUT_LINE(NUM2 ||' es el SEGUNDO numero introducido y es EQUIVALENTE a la suma de los otros dos');
ELSE
DBMS_OUTPUT.PUT_LINE('NINGUNO de los numero dados es equivalente');
END CASE;
END;

--12. Averigua si un anio dado es bisiesto. Todos los anioos multiplos de 4 son bisiestos, salvo los  que son multiplos de 100 y no de 400.
--*NOTA  --> Para determinar si un número es múltiplo de otro, simplemente debes verificar si el residuo de la división entre los dos números es igual a cero.
 --   Es divisible por 4 y no es divisible por 100, o
--    Es divisible por 400.

DECLARE
    ANIO NUMBER(4):= '&AÑO'; 
    ISMULTIPLO BOOLEAN := FALSE; 
BEGIN
    IF (MOD(ANIO, 4) = 0 AND MOD(ANIO, 100) != 0) OR MOD(ANIO, 400) = 0  THEN 
        ISMULTIPLO := TRUE; 
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('EL AÑO INTRODUCIDO ' || ANIO || ' ES BISIESTO ' || CASE WHEN ISMULTIPLO THEN 'TRUE' ELSE 'FALSE' END);
    
END; 










