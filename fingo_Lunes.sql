--  Creación de tablas, secuencias y triggers para autoincremento


-- usuarios
CREATE TABLE usuarios (
  id NUMBER PRIMARY KEY,
  nombre VARCHAR2(100) NOT NULL,
  email VARCHAR2(100) NOT NULL UNIQUE,
  telefono VARCHAR2(20),
  password VARCHAR2(255) NOT NULL,
  fecha_registro TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE SEQUENCE seq_usuarios START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_usuarios_bi
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_usuarios.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- categorias
CREATE TABLE categorias (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  nombre VARCHAR2(100) NOT NULL,
  tipo VARCHAR2(20),
  descripcion VARCHAR2(255),
  CONSTRAINT fk_cat_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_categorias START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_categorias_bi
BEFORE INSERT ON categorias
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_categorias.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- finanzas
CREATE TABLE finanzas (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  categoria_id NUMBER,
  tipo VARCHAR2(20),
  monto NUMBER(12,2),
  descripcion VARCHAR2(4000),
  fecha_trx DATE,
  fecha_registro TIMESTAMP DEFAULT SYSTIMESTAMP,
  CONSTRAINT fk_fin_user FOREIGN KEY (user_id) REFERENCES usuarios(id),
  CONSTRAINT fk_fin_cat FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE SEQUENCE seq_finanzas START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_finanzas_bi
BEFORE INSERT ON finanzas
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_finanzas.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- configuracion
CREATE TABLE configuracion (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  notificaciones VARCHAR2(10) DEFAULT 'on',
  CONSTRAINT fk_conf_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_configuracion START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_configuracion_bi
BEFORE INSERT ON configuracion
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_configuracion.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- reportes
CREATE TABLE reportes (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  tipo VARCHAR2(50),
  descripcion VARCHAR2(4000),
  monto NUMBER(12,2),
  fecha DATE,
  fecha_registro TIMESTAMP DEFAULT SYSTIMESTAMP,
  CONSTRAINT fk_rep_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_reportes START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_reportes_bi
BEFORE INSERT ON reportes
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_reportes.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- historial 
CREATE TABLE historial (
  id NUMBER PRIMARY KEY,
  user_id NUMBER,
  accion VARCHAR2(1000),
  fecha_registro TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE SEQUENCE seq_historial START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_historial_bi
BEFORE INSERT ON historial
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_historial.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- alertas
CREATE TABLE alertas (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  tipo VARCHAR2(50),
  mensaje VARCHAR2(4000),
  medio VARCHAR2(20),
  fecha_envio TIMESTAMP,
  CONSTRAINT fk_alert_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_alertas START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_alertas_bi
BEFORE INSERT ON alertas
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_alertas.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- familiares
CREATE TABLE familiares (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  nombre VARCHAR2(100),
  email VARCHAR2(100),
  rol VARCHAR2(30),
  CONSTRAINT fk_fam_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_familiares START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_familiares_bi
BEFORE INSERT ON familiares
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_familiares.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- metas_financieras 
CREATE TABLE metas_financieras (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  nombre VARCHAR2(100),
  monto_objetivo NUMBER(12,2),
  fecha_limite DATE,
  progreso NUMBER(12,2) DEFAULT 0,
  estado VARCHAR2(20) DEFAULT 'en progreso',
  CONSTRAINT fk_meta_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_metas START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_metas_bi
BEFORE INSERT ON metas_financieras
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_metas.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- presupuestos 
CREATE TABLE presupuestos (
  id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  categoria_id NUMBER NOT NULL,
  monto_limite NUMBER(12,2),
  mes NUMBER(2),
  anio NUMBER(4),
  CONSTRAINT fk_pre_user FOREIGN KEY (user_id) REFERENCES usuarios(id),
  CONSTRAINT fk_pre_cat FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

CREATE SEQUENCE seq_presupuestos START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_presupuestos_bi
BEFORE INSERT ON presupuestos
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_presupuestos.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- logs_acceso 
CREATE TABLE logs_acceso (
  id NUMBER PRIMARY KEY,
  user_id NUMBER,
  fecha_ingreso TIMESTAMP DEFAULT SYSTIMESTAMP,
  ip VARCHAR2(50),
  dispositivo VARCHAR2(100),
  CONSTRAINT fk_log_user FOREIGN KEY (user_id) REFERENCES usuarios(id)
);

CREATE SEQUENCE seq_logs START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER trg_logs_bi
BEFORE INSERT ON logs_acceso
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_logs.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/


-- 3) Procedimientos CRUD 


-- Usuarios - CREATE
CREATE OR REPLACE PROCEDURE p_create_usuario(
  p_nombre IN VARCHAR2,
  p_email IN VARCHAR2,
  p_telefono IN VARCHAR2,
  p_password IN VARCHAR2,
  p_id OUT NUMBER
) AS
BEGIN
  INSERT INTO usuarios(nombre, email, telefono, password)
  VALUES (p_nombre, p_email, p_telefono, p_password)
  RETURNING id INTO p_id;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/

-- Usuarios - READ
CREATE OR REPLACE PROCEDURE p_read_usuario(
  p_id IN NUMBER,
  p_nombre OUT VARCHAR2,
  p_email OUT VARCHAR2,
  p_telefono OUT VARCHAR2,
  p_fecha_registro OUT TIMESTAMP
) AS
BEGIN
  SELECT nombre, email, telefono, fecha_registro
  INTO p_nombre, p_email, p_telefono, p_fecha_registro
  FROM usuarios WHERE id = p_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
  p_nombre := NULL;
  p_email := NULL;
  p_telefono := NULL;
  p_fecha_registro := NULL;
END;
/

-- Usuarios - UPDATE
CREATE OR REPLACE PROCEDURE p_update_usuario(
  p_id IN NUMBER,
  p_nombre IN VARCHAR2,
  p_email IN VARCHAR2,
  p_telefono IN VARCHAR2
) AS
BEGIN
  UPDATE usuarios SET nombre = p_nombre, email = p_email, telefono = p_telefono WHERE id = p_id;
  COMMIT;
END;
/

-- Usuarios - DELETE
CREATE OR REPLACE PROCEDURE p_delete_usuario(p_id IN NUMBER) AS
BEGIN
  DELETE FROM usuarios WHERE id = p_id;
  COMMIT;
END;
/

-- Finanzas 
CREATE OR REPLACE PROCEDURE p_create_finanza(
  p_user_id IN NUMBER,
  p_categoria_id IN NUMBER,
  p_tipo IN VARCHAR2,
  p_monto IN NUMBER,
  p_descripcion IN VARCHAR2,
  p_fecha_trx IN DATE,
  p_id OUT NUMBER
) AS
BEGIN
  INSERT INTO finanzas(user_id, categoria_id, tipo, monto, descripcion, fecha_trx)
  VALUES (p_user_id, p_categoria_id, p_tipo, p_monto, p_descripcion, p_fecha_trx)
  RETURNING id INTO p_id;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/

-- Finanzas 
CREATE OR REPLACE PROCEDURE p_read_finanza(
  p_id IN NUMBER,
  p_user_id OUT NUMBER,
  p_tipo OUT VARCHAR2,
  p_monto OUT NUMBER
) AS
BEGIN
  SELECT user_id, tipo, monto INTO p_user_id, p_tipo, p_monto FROM finanzas WHERE id = p_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
  p_user_id := NULL;
  p_tipo := NULL;
  p_monto := NULL;
END;
/

-- Finanzas 
CREATE OR REPLACE PROCEDURE p_update_finanza(
  p_id IN NUMBER,
  p_monto IN NUMBER,
  p_descripcion IN VARCHAR2
) AS
BEGIN
  UPDATE finanzas SET monto = p_monto, descripcion = p_descripcion WHERE id = p_id;
  COMMIT;
END;
/

-- Finanzas 
CREATE OR REPLACE PROCEDURE p_delete_finanza(p_id IN NUMBER) AS
BEGIN
  DELETE FROM finanzas WHERE id = p_id;
  COMMIT;
END;
/

-- Metas 
CREATE OR REPLACE PROCEDURE p_create_meta(
  p_user_id IN NUMBER,
  p_nombre IN VARCHAR2,
  p_monto_objetivo IN NUMBER,
  p_fecha_limite IN DATE,
  p_id OUT NUMBER
) AS
BEGIN
  INSERT INTO metas_financieras(user_id, nombre, monto_objetivo, fecha_limite)
  VALUES (p_user_id, p_nombre, p_monto_objetivo, p_fecha_limite)
  RETURNING id INTO p_id;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END;
/

-- Metas - UPDATE progresos
CREATE OR REPLACE PROCEDURE p_update_meta_progreso(
  p_meta_id IN NUMBER,
  p_progreso IN NUMBER
) AS
BEGIN
  UPDATE metas_financieras SET progreso = p_progreso WHERE id = p_meta_id;
  COMMIT;
END;
/

-- Funciones 


-- Balance total 
CREATE OR REPLACE FUNCTION f_get_balance(p_user_id IN NUMBER) RETURN NUMBER IS
  v_balance NUMBER := 0;
BEGIN
  SELECT NVL(SUM(CASE WHEN tipo = 'ingreso' THEN monto WHEN tipo = 'gasto' THEN -monto ELSE 0 END),0)
    INTO v_balance
    FROM finanzas WHERE user_id = p_user_id;
  RETURN v_balance;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 0;
END;
/

-- Avance de una meta en porcentaje
CREATE OR REPLACE FUNCTION f_avance_meta(p_meta_id IN NUMBER) RETURN NUMBER IS
  v_progreso NUMBER; v_objetivo NUMBER;
BEGIN
  SELECT NVL(progreso,0), NVL(monto_objetivo,0) INTO v_progreso, v_objetivo FROM metas_financieras WHERE id = p_meta_id;
  IF v_objetivo = 0 THEN
    RETURN 0;
  ELSE
    RETURN ROUND((v_progreso / v_objetivo) * 100,2);
  END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 0;
END;
/

-- Total gastos de un mes
CREATE OR REPLACE FUNCTION f_total_gastos_mes(p_user_id IN NUMBER, p_mes IN NUMBER, p_anio IN NUMBER) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(monto),0) INTO v_total
  FROM finanzas
  WHERE user_id=p_user_id AND tipo='gasto'
    AND EXTRACT(MONTH FROM fecha_trx)=p_mes
    AND EXTRACT(YEAR FROM fecha_trx)=p_anio;
  RETURN v_total;
END;
/


-- 5) Vistas

CREATE OR REPLACE VIEW vw_user_summary AS
SELECT u.id, u.nombre, u.email, u.fecha_registro,
       f_get_balance(u.id) AS balance_total,
       (SELECT COUNT(*) FROM finanzas f2 WHERE f2.user_id = u.id) AS transacciones
FROM usuarios u;
/

CREATE OR REPLACE VIEW vw_metas_progreso AS
SELECT m.id, u.nombre usuario, m.nombre meta, m.monto_objetivo, m.progreso,
       f_avance_meta(m.id) avance_porcentaje, m.estado
FROM metas_financieras m
JOIN usuarios u ON m.user_id = u.id;
/

CREATE OR REPLACE VIEW vw_gastos_mensuales AS
SELECT u.id usuario_id, u.nombre, EXTRACT(MONTH FROM f.fecha_trx) mes,
       EXTRACT(YEAR FROM f.fecha_trx) anio, SUM(f.monto) total_gasto
FROM finanzas f JOIN usuarios u ON f.user_id=u.id
WHERE f.tipo='gasto'
GROUP BY u.id, u.nombre, EXTRACT(MONTH FROM f.fecha_trx), EXTRACT(YEAR FROM f.fecha_trx);
/


--Triggers de auditoría


CREATE OR REPLACE TRIGGER trg_finanzas_audit
AFTER INSERT OR UPDATE OR DELETE ON finanzas
FOR EACH ROW
DECLARE
  v_accion VARCHAR2(500);
BEGIN
  IF INSERTING THEN
    v_accion := 'INSERT en finanzas id=' || NVL(:NEW.id, -1) || ' user=' || NVL(:NEW.user_id,-1);
  ELSIF UPDATING THEN
    v_accion := 'UPDATE en finanzas id=' || NVL(:NEW.id, -1) || ' user=' || NVL(:NEW.user_id,-1);
  ELSIF DELETING THEN
    v_accion := 'DELETE en finanzas id=' || NVL(:OLD.id, -1) || ' user=' || NVL(:OLD.user_id,-1);
  END IF;
  INSERT INTO historial(user_id, accion) VALUES (NVL(NVL(:NEW.user_id, :OLD.user_id), -1), v_accion);
END;
/

CREATE OR REPLACE TRIGGER trg_usuario_audit
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
  INSERT INTO historial(user_id, accion) VALUES (:NEW.id, 'CREAR_USUARIO:'||:NEW.email);
END;
/


-- 7) Paquete con cursores y utilidades

CREATE OR REPLACE PACKAGE fingo_pkg IS
  CURSOR c_finanzas(p_user NUMBER) IS SELECT id, tipo, monto, fecha_trx FROM finanzas WHERE user_id=p_user ORDER BY fecha_trx DESC;
  PROCEDURE p_listar_finanzas(p_user NUMBER);
  FUNCTION f_conteo_finanzas(p_user NUMBER) RETURN NUMBER;
  FUNCTION f_balance_resumido(p_user NUMBER) RETURN NUMBER;
END fingo_pkg;
/

CREATE OR REPLACE PACKAGE BODY fingo_pkg IS
  PROCEDURE p_listar_finanzas(p_user NUMBER) IS
    v_rec c_finanzas%ROWTYPE;
  BEGIN
    FOR v_rec IN c_finanzas(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE('ID='||v_rec.id||' TIPO='||v_rec.tipo||' MONTO='||v_rec.monto||' FECHA='||NVL(TO_CHAR(v_rec.fecha_trx,'YYYY-MM-DD'),'N/A'));
    END LOOP;
  END p_listar_finanzas;

  FUNCTION f_conteo_finanzas(p_user NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total FROM finanzas WHERE user_id=p_user;
    RETURN v_total;
  END f_conteo_finanzas;

  FUNCTION f_balance_resumido(p_user NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN f_get_balance(p_user);
  END f_balance_resumido;
END fingo_pkg;
/


-- 8) pruebas (comentar o ejecutar según sea necesario)

-- SET SERVEROUTPUT ON;
-- DECLARE
--   v_id NUMBER;
-- BEGIN
--   p_create_usuario('Juan Perez','juan@example.com','88880000','pwd123', v_id);
--   DBMS_OUTPUT.PUT_LINE('Usuario creado con id='||v_id);
-- END;
-- /





