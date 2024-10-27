
Con las tablas de hr
3. Impide que un empleado pueda reducir su salario emitiendo un mensaje de
error.

CREATE OR REPLACE TRIGGER REDUCIR_SALARIO
BEFORE UPDATE OF SALARY ON EMPLOYEES
FOR EACH ROW
DECLARE
    -- NO ES NECESARIO DECLARAR UNA EXCEPCIÓN PERSONALIZADA PARA USAR RAISE_APPLICATION_ERROR
BEGIN
    IF :OLD.SALARY > :NEW.SALARY THEN
        -- USAMOS RAISE_APPLICATION_ERROR PARA ENVIAR UN MENSAJE DE ERROR Y DETENER LA ACTUALIZACIÓN
        RAISE_APPLICATION_ERROR(-20001, 'NO SE PUEDE REDUCIR EL SALARIO');
    END IF;
END;
/


ROLLBACK; 
UPDATE EMPLOYEES SET SALARY = 1; 

4. Audita cualquier modificación que se produzca en la tabla DEPARTMENTS.
Almacena el nombre de usuario, operación (alta, baja o modificación) y la fecha
en que se produce. Para ello creo primero la tabla AUDITADEPARMENTS que
tendrá los tres campos indicados.
--CORRECTA COMPROBADO.
CREATE TABLE AUDITADEPARTMENTS  (
    
    NOMBRE VARCHAR2(20),
    OPERACION VARCHAR2(15),
    FECHA DATE 

);

CREATE OR REPLACE TRIGGER MODIFICACION AFTER UPDATE OR DELETE OR INSERT ON DEPARTMENTS 
FOR EACH ROW
DECLARE
    OPCION VARCHAR2(15);
BEGIN 

    IF INSERTING THEN 
            OPCION := 'ALTA';
         INSERT INTO AUDITADEPARTMENTS VALUES (:NEW.DEPARTMENT_NAME,OPCION,SYSDATE);
    
    ELSIF UPDATING THEN
            OPCION := 'MODIFICACION';
          INSERT INTO AUDITADEPARTMENTS VALUES (:NEW.DEPARTMENT_NAME,OPCION,SYSDATE);
    
    ELSE
        OPCION := 'BAJA';
         INSERT INTO AUDITADEPARTMENTS VALUES (:OLD.DEPARTMENT_NAME,OPCION,SYSDATE);
    END IF; 
END; 

INSERT INTO DEPARTMENTS VALUES (3999, 'HIGIENISTA', NULL, 1700);
UPDATE  DEPARTMENTS SET DEPARTMENT_NAME = 'ODONTOLOGO' WHERE DEPARTMENT_NAME = 'HIGIENISTA';
DELETE DEPARTMENTS WHERE  DEPARTMENT_NAME = 'ODONTOLOGO';



5. Añade la columna n_empleados a la tabla DEPARTMENTS y haz un
procedimiento que la rellene con el número de empleados que hay en cada
departamento (utilizar cursores de actualización).
A continuación, escribe un
disparador que la mantenga actualizada frente a las actualizaciones que se
hagan en la tabla EMPLOYEES.

--- los tres pasos son correctos pero cuando ejecuto un insert en la tabla, me devuelve un error asociado a trigger




--CORRECCION DE CLASE EJERCICIO DE EXAMEN
Ejercicio 5


alter table departments add n_empleado number(5);

create or replace procedure LlenarNEmpleado
is
cursor c_depart is select department_id from departments for update;
begin
for v_depart in c_depart loop
update departments set n_empleado =(select count(*) from employees where department_id=v_depart.department_id)
where current of c_depart;
end loop;
end;

execute LlenarNEmpleado;

create or replace trigger Ejercicio5HR 
after insert or delete
on employees
for each row
begin
    if inserting then
        update departments set n_empleado=n_empleado+1 where DEPARTMENT_ID=:new.department_id;
    else
        update departments set n_empleado=n_empleado-1 where DEPARTMENT_ID=:old.department_id;
    end if;

end;

delete from employees where employee_id=13



CREATE OR REPLACE TRIGGER ACTUALIZAR_CONTADOR AFTER INSERT OR UPDATE OR DELETE OF DEPARTMENT_ID ON EMPLOYEES
FOR EACH ROW
BEGIN
        IF INSERTING THEN
            UPDATE DEPARTMENTS SET N_EMPLEADOS = N_EMPLEADOS + 1 WHERE DEPARTMENT_ID = :NEW.DEPARTMENT_ID;
        
        ELSIF DELETING THEN
             UPDATE DEPARTMENTS SET N_EMPLEADOS = N_EMPLEADOS -1 WHERE DEPARTMENT_ID = :NEW.DEPARTMENT_ID;
        
      
            --SI ENTRAMOS AQUI ES PORQUE ES CAMBIAR A UN EMPLEADO DE DEPARTAMENTO
        ELSIF UPDATING (`DEPARTMENT_ID´) THEN
             UPDATE DEPARTMENTS SET N_EMPLEADOS = N_EMPLEADOS + 1 WHERE DEPARTMENT_ID = :NEW.DEPARTMENT_ID;
              UPDATE DEPARTMENTS SET N_EMPLEADOS = N_EMPLEADOS -1 WHERE DEPARTMENT_ID = :OLD.DEPARTMENT_ID;
        END IF;
END;

SET SERVEROUTPUT ON;
--PRUEBAS 
INSERT INTO EMPLOYEES (EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY, DEPARTMENT_ID) VALUES
(207, 'Juan', 'Pérez', 'JPerez', TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'IT_PROG', 60000, 60);






