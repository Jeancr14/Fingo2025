-- CREAR TABLAS


--- usuarios
CREATE TABLE usuarios (
    id             NUMBER PRIMARY KEY,
    nombre         VARCHAR2(100) NOT NULL,
    email          VARCHAR2(100) NOT NULL UNIQUE,
    telefono       VARCHAR2(20),
    password       VARCHAR2(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT systimestamp
);

/*
Table USUARIOS creado.*/

CREATE SEQUENCE seq_usuarios START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*
Sequence SEQ_USUARIOS creado.*/

-- categorias
CREATE TABLE categorias (
    id          NUMBER PRIMARY KEY,
    user_id     NUMBER NOT NULL,
    nombre      VARCHAR2(100) NOT NULL,
    tipo        VARCHAR2(20),
    descripcion VARCHAR2(255),
    CONSTRAINT fk_cat_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);

/*
Table CATEGORIAS creado.*/

CREATE SEQUENCE seq_categorias START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*
Sequence SEQ_CATEGORIAS creado.*/

-- finanzas
CREATE TABLE finanzas (
    id             NUMBER PRIMARY KEY,
    user_id        NUMBER NOT NULL,
    categoria_id   NUMBER,
    tipo           VARCHAR2(20),
    monto          NUMBER(12, 2),
    descripcion    VARCHAR2(4000),
    fecha_trx      DATE,
    fecha_registro TIMESTAMP DEFAULT systimestamp,
    CONSTRAINT fk_fin_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id ),
    CONSTRAINT fk_fin_cat FOREIGN KEY ( categoria_id )
        REFERENCES categorias ( id )
);
/*
Table FINANZAS creado.*/

CREATE SEQUENCE seq_finanzas START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*
Sequence SEQ_FINANZAS creado.*/

-- configuracion
CREATE TABLE configuracion (
    id             NUMBER PRIMARY KEY,
    user_id        NUMBER NOT NULL,
    notificaciones VARCHAR2(10) DEFAULT 'on',
    CONSTRAINT fk_conf_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);
/*
Table CONFIGURACION creado.*/

CREATE SEQUENCE seq_configuracion START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*
Sequence SEQ_CONFIGURACION creado.*/

-- reportes
CREATE TABLE reportes (
    id             NUMBER PRIMARY KEY,
    user_id        NUMBER NOT NULL,
    tipo           VARCHAR2(50),
    descripcion    VARCHAR2(4000),
    monto          NUMBER(12, 2),
    fecha          DATE,
    fecha_registro TIMESTAMP DEFAULT systimestamp,
    CONSTRAINT fk_rep_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);
/*
Table REPORTES creado.*/

CREATE SEQUENCE seq_reportes START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*
Table REPORTES creado.*/

-- historial
CREATE TABLE historial (
    id             NUMBER PRIMARY KEY,
    user_id        NUMBER,
    accion         VARCHAR2(1000),
    fecha_registro TIMESTAMP DEFAULT systimestamp
);
/*Table HISTORIAL creado.*/

CREATE SEQUENCE seq_historial START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*Sequence SEQ_HISTORIAL creado.*/

-- alertas
CREATE TABLE alertas (
    id          NUMBER PRIMARY KEY,
    user_id     NUMBER NOT NULL,
    tipo        VARCHAR2(50),
    mensaje     VARCHAR2(4000),
    medio       VARCHAR2(20),
    fecha_envio TIMESTAMP,
    CONSTRAINT fk_alert_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);
/*Table ALERTAS creado.*/

CREATE SEQUENCE seq_alertas START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*Sequence SEQ_ALERTAS creado.*/

-- familiares
CREATE TABLE familiares (
    id      NUMBER PRIMARY KEY,
    user_id NUMBER NOT NULL,
    nombre  VARCHAR2(100),
    email   VARCHAR2(100),
    rol     VARCHAR2(30),
    CONSTRAINT fk_fam_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);
/*Table FAMILIARES creado.*/

CREATE SEQUENCE seq_familiares START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*Sequence SEQ_FAMILIARES creado.*/

-- metas_financieras
CREATE TABLE metas_financieras (
    id             NUMBER PRIMARY KEY,
    user_id        NUMBER NOT NULL,
    nombre         VARCHAR2(100),
    monto_objetivo NUMBER(12, 2),
    fecha_limite   DATE,
    progreso       NUMBER(12, 2) DEFAULT 0,
    estado         VARCHAR2(20) DEFAULT 'en progreso',
    CONSTRAINT fk_meta_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);
/*Table METAS_FINANCIERAS creado.*/

CREATE SEQUENCE seq_metas START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*Sequence SEQ_METAS creado.*/

-- presupuestos
CREATE TABLE presupuestos (
    id           NUMBER PRIMARY KEY,
    user_id      NUMBER NOT NULL,
    categoria_id NUMBER NOT NULL,
    monto_limite NUMBER(12, 2),
    mes          NUMBER(2),
    anio         NUMBER(4),
    CONSTRAINT fk_pre_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id ),
    CONSTRAINT fk_pre_cat FOREIGN KEY ( categoria_id )
        REFERENCES categorias ( id )
);
/*
Table PRESUPUESTOS creado.*/

CREATE SEQUENCE seq_presupuestos START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*Sequence SEQ_PRESUPUESTOS creado.*/

-- logs_acceso
CREATE TABLE logs_acceso (
    id            NUMBER PRIMARY KEY,
    user_id       NUMBER,
    fecha_ingreso TIMESTAMP DEFAULT systimestamp,
    ip            VARCHAR2(50),
    dispositivo   VARCHAR2(100),
    CONSTRAINT fk_log_user FOREIGN KEY ( user_id )
        REFERENCES usuarios ( id )
);
/*Table LOGS_ACCESO creado.*/

CREATE SEQUENCE seq_logs START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/*Sequence SEQ_LOGS creado.*/




---Triggers

-- trg de usuarios
CREATE OR REPLACE TRIGGER trg_usuarios_bi
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_usuarios.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/
-- trg de finanzas
CREATE OR REPLACE TRIGGER trg_finanzas_bi
BEFORE INSERT ON finanzas
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_finanzas.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/
-- trg metas
CREATE OR REPLACE TRIGGER trg_metas_bi
BEFORE INSERT ON metas_financieras
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_metas.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- trg presupuestos
CREATE OR REPLACE TRIGGER trg_presupuestos_bi
BEFORE INSERT ON presupuestos
FOR EACH ROW
BEGIN
  IF :NEW.id IS NULL THEN
    SELECT seq_presupuestos.NEXTVAL INTO :NEW.id FROM dual;
  END IF;
END;
/

-- trg finanzas auditoria
CREATE OR REPLACE TRIGGER trg_finanzas_audit
AFTER INSERT OR UPDATE OR DELETE ON finanzas
FOR EACH ROW
DECLARE
  v_accion VARCHAR2(500);
BEGIN
  IF INSERTING THEN
    v_accion := 'INSERT en finanzas id=' || NVL(:NEW.id, -1);
  ELSIF UPDATING THEN
    v_accion := 'UPDATE en finanzas id=' || NVL(:NEW.id, -1);
  ELSIF DELETING THEN
    v_accion := 'DELETE en finanzas id=' || NVL(:OLD.id, -1);
  END IF;
  
  INSERT INTO historial(user_id, accion)
  VALUES (NVL(NVL(:NEW.user_id, :OLD.user_id), -1), v_accion);
END;
/

-- trg usuario audit
CREATE OR REPLACE TRIGGER trg_usuario_audit
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
  INSERT INTO historial(user_id, accion)
  VALUES (:NEW.id, 'Nuevo usuario registrado: ' || :NEW.email);
END;
/


--                      PROCEDIMIENTOS CRUD

-- Usuarios - CREATE
CREATE OR REPLACE PROCEDURE p_create_usuario (
    p_nombre   IN VARCHAR2,
    p_email    IN VARCHAR2,
    p_telefono IN VARCHAR2,
    p_password IN VARCHAR2,
    p_id       OUT NUMBER
) AS
BEGIN
    INSERT INTO usuarios (
        nombre,
        email,
        telefono,
        password
    ) VALUES ( p_nombre,
               p_email,
               p_telefono,
               p_password ) RETURNING id INTO p_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
/*Procedure P_CREATE_USUARIO compilado*/

-- Usuarios - READ
CREATE OR REPLACE PROCEDURE p_read_usuario (
    p_id             IN NUMBER,
    p_nombre         OUT VARCHAR2,
    p_email          OUT VARCHAR2,
    p_telefono       OUT VARCHAR2,
    p_fecha_registro OUT TIMESTAMP
) AS
BEGIN
    SELECT
        nombre,
        email,
        telefono,
        fecha_registro
    INTO
        p_nombre,
        p_email,
        p_telefono,
        p_fecha_registro
    FROM
        usuarios
    WHERE
        id = p_id;

EXCEPTION
    WHEN no_data_found THEN
        p_nombre := NULL;
        p_email := NULL;
        p_telefono := NULL;
        p_fecha_registro := NULL;
END;
/
/*Procedure P_READ_USUARIO compilado*/


-- Usuarios - UPDATE
CREATE OR REPLACE PROCEDURE p_update_usuario (
    p_id       IN NUMBER,
    p_nombre   IN VARCHAR2,
    p_email    IN VARCHAR2,
    p_telefono IN VARCHAR2
) AS
BEGIN
    UPDATE usuarios
    SET
        nombre = p_nombre,
        email = p_email,
        telefono = p_telefono
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_UPDATE_USUARIO compilado*/

-- Usuarios - DELETE
CREATE OR REPLACE PROCEDURE p_delete_usuario (
    p_id IN NUMBER
) AS
BEGIN
    DELETE FROM usuarios
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*
Procedure P_UPDATE_USUARIO compilado*/

-- Finanzas - CREATE
CREATE OR REPLACE PROCEDURE p_create_finanza (
    p_user_id      IN NUMBER,
    p_categoria_id IN NUMBER,
    p_tipo         IN VARCHAR2,
    p_monto        IN NUMBER,
    p_descripcion  IN VARCHAR2,
    p_fecha_trx    IN DATE,
    p_id           OUT NUMBER
) AS
BEGIN
    INSERT INTO finanzas (
        user_id,
        categoria_id,
        tipo,
        monto,
        descripcion,
        fecha_trx
    ) VALUES ( p_user_id,
               p_categoria_id,
               p_tipo,
               p_monto,
               p_descripcion,
               p_fecha_trx ) RETURNING id INTO p_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
/*Procedure P_CREATE_FINANZA compilado*/

-- Finanzas - READ
CREATE OR REPLACE PROCEDURE p_read_finanza (
    p_id      IN NUMBER,
    p_user_id OUT NUMBER,
    p_tipo    OUT VARCHAR2,
    p_monto   OUT NUMBER
) AS
BEGIN
    SELECT
        user_id,
        tipo,
        monto
    INTO
        p_user_id,
        p_tipo,
        p_monto
    FROM
        finanzas
    WHERE
        id = p_id;

EXCEPTION
    WHEN no_data_found THEN
        p_user_id := NULL;
        p_tipo := NULL;
        p_monto := NULL;
END;
/
/*Procedure P_READ_FINANZA compilado*/

-- Finanzas - UPDATE
CREATE OR REPLACE PROCEDURE p_update_finanza (
    p_id          IN NUMBER,
    p_monto       IN NUMBER,
    p_descripcion IN VARCHAR2
) AS
BEGIN
    UPDATE finanzas
    SET
        monto = p_monto,
        descripcion = p_descripcion
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_UPDATE_FINANZA compilado*/

-- Finanzas - DELETE
CREATE OR REPLACE PROCEDURE p_delete_finanza (
    p_id IN NUMBER
) AS
BEGIN
    DELETE FROM finanzas
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_DELETE_FINANZA compilado*/

-- Metas - CREATE
CREATE OR REPLACE PROCEDURE p_create_meta (
    p_user_id        IN NUMBER,
    p_nombre         IN VARCHAR2,
    p_monto_objetivo IN NUMBER,
    p_fecha_limite   IN DATE,
    p_id             OUT NUMBER
) AS
BEGIN
    INSERT INTO metas_financieras (
        user_id,
        nombre,
        monto_objetivo,
        fecha_limite
    ) VALUES ( p_user_id,
               p_nombre,
               p_monto_objetivo,
               p_fecha_limite ) RETURNING id INTO p_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
/*Procedure P_CREATE_META compilado*/

-- Metas - UPDATE progreso
CREATE OR REPLACE PROCEDURE p_update_meta_progreso (
    p_meta_id  IN NUMBER,
    p_progreso IN NUMBER
) AS
BEGIN
    UPDATE metas_financieras
    SET
        progreso = p_progreso
    WHERE
        id = p_meta_id;

    COMMIT;
END;
/
/*Procedure P_UPDATE_META_PROGRESO compilado*/

-- lista usuarios
CREATE OR REPLACE PROCEDURE p_listar_usuarios IS
BEGIN
    FOR r IN (
        SELECT
            id,
            nombre,
            email
        FROM
            usuarios
    ) LOOP
        dbms_output.put_line('ID='
                             || r.id
                             || ' - '
                             || r.nombre
                             || ' ('
                             || r.email
                             || ')');
    END LOOP;
END;
/
/*Procedure P_LISTAR_USUARIOS compilado*/

-- buscar usuario por correo
CREATE OR REPLACE PROCEDURE p_buscar_usuario_email (
    p_email IN VARCHAR2
) IS
    v_id     NUMBER;
    v_nombre VARCHAR2(100);
BEGIN
    SELECT
        id,
        nombre
    INTO
        v_id,
        v_nombre
    FROM
        usuarios
    WHERE
        email = p_email;

    dbms_output.put_line('Usuario encontrado: '
                         || v_nombre
                         || ' (ID='
                         || v_id
                         || ')');

EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('No existe usuario con ese correo.');
END;
/
/*Procedure P_LISTAR_USUARIOS compilado*/

-- Listar finanzas de un usuario
CREATE OR REPLACE PROCEDURE p_listar_finanzas_usuario (
    p_user_id IN NUMBER
) IS
BEGIN
    FOR r IN (
        SELECT
            tipo,
            monto,
            descripcion
        FROM
            finanzas
        WHERE
            user_id = p_user_id
        ORDER BY
            fecha_trx DESC
    ) LOOP
        dbms_output.put_line(r.tipo
                             || ' - '
                             || r.monto
                             || ' - '
                             || nvl(r.descripcion, '-'));
    END LOOP;
END;
/
/*Procedure P_LISTAR_FINANZAS_USUARIO compilado*/


-- Listar catg por usuario
CREATE OR REPLACE PROCEDURE p_listar_categorias_usuario (
    p_user_id IN NUMBER
) IS
BEGIN
    FOR r IN (
        SELECT
            nombre,
            tipo
        FROM
            categorias
        WHERE
            user_id = p_user_id
    ) LOOP
        dbms_output.put_line('Categoría: '
                             || r.nombre
                             || ' ('
                             || r.tipo
                             || ')');
    END LOOP;
END;
/
/*Procedure P_LISTAR_FINANZAS_USUARIO compilado*/

-- Crear alerta
CREATE OR REPLACE PROCEDURE p_crear_alerta (
    p_user_id IN NUMBER,
    p_tipo    IN VARCHAR2,
    p_mensaje IN VARCHAR2,
    p_medio   IN VARCHAR2
) AS
    v_id NUMBER;
BEGIN
    INSERT INTO alertas (
        user_id,
        tipo,
        mensaje,
        medio,
        fecha_envio
    ) VALUES ( p_user_id,
               p_tipo,
               p_mensaje,
               p_medio,
               systimestamp ) RETURNING id INTO v_id;

    COMMIT;
    dbms_output.put_line('Alerta creada con ID=' || v_id);
END;
/
/*Procedure P_CREAR_ALERTA compilado*/

-- Eliminar alerta
CREATE OR REPLACE PROCEDURE p_eliminar_alerta (
    p_id IN NUMBER
) AS
BEGIN
    DELETE FROM alertas
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_ELIMINAR_ALERTA compilado*/

-- Crear reporte
CREATE OR REPLACE PROCEDURE p_crear_reporte (
    p_user_id     IN NUMBER,
    p_tipo        IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_monto       IN NUMBER
) AS
    v_id NUMBER;
BEGIN
    INSERT INTO reportes (
        user_id,
        tipo,
        descripcion,
        monto,
        fecha
    ) VALUES ( p_user_id,
               p_tipo,
               p_descripcion,
               p_monto,
               sysdate ) RETURNING id INTO v_id;

    COMMIT;
    dbms_output.put_line('Reporte creado con ID=' || v_id);
END;
/
/*Procedure P_CREAR_REPORTE compilado*/

-- Eliminar reporte
CREATE OR REPLACE PROCEDURE p_eliminar_reporte (
    p_id IN NUMBER
) AS
BEGIN
    DELETE FROM reportes
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_ELIMINAR_REPORTE compilado*/

-- Crear presupuesto
CREATE OR REPLACE PROCEDURE p_crear_presupuesto (
    p_user_id      IN NUMBER,
    p_categoria_id IN NUMBER,
    p_monto        IN NUMBER,
    p_mes          IN NUMBER,
    p_anio         IN NUMBER
) AS
    v_id NUMBER;
BEGIN
    INSERT INTO presupuestos (
        user_id,
        categoria_id,
        monto_limite,
        mes,
        anio
    ) VALUES ( p_user_id,
               p_categoria_id,
               p_monto,
               p_mes,
               p_anio ) RETURNING id INTO v_id;

    COMMIT;
    dbms_output.put_line('Presupuesto creado con ID=' || v_id);
END;
/
/*Procedure P_CREAR_PRESUPUESTO compilado*/

-- Actualizar presupuesto
CREATE OR REPLACE PROCEDURE p_update_presupuesto (
    p_id    IN NUMBER,
    p_monto IN NUMBER
) AS
BEGIN
    UPDATE presupuestos
    SET
        monto_limite = p_monto
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_UPDATE_PRESUPUESTO compilado*/

-- Eliminar presupuesto
CREATE OR REPLACE PROCEDURE p_delete_presupuesto (
    p_id IN NUMBER
) AS
BEGIN
    DELETE FROM presupuestos
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_DELETE_PRESUPUESTO compilado*/

-- Crear familiar
CREATE OR REPLACE PROCEDURE p_crear_familiar (
    p_user_id IN NUMBER,
    p_nombre  IN VARCHAR2,
    p_email   IN VARCHAR2,
    p_rol     IN VARCHAR2
) AS
    v_id NUMBER;
BEGIN
    INSERT INTO familiares (
        user_id,
        nombre,
        email,
        rol
    ) VALUES ( p_user_id,
               p_nombre,
               p_email,
               p_rol ) RETURNING id INTO v_id;

    COMMIT;
    dbms_output.put_line('Familiar creado con ID=' || v_id);
END;
/
/*Procedure P_CREAR_FAMILIAR compilado*/

-- Eliminar familiar
CREATE OR REPLACE PROCEDURE p_delete_familiar (
    p_id IN NUMBER
) AS
BEGIN
    DELETE FROM familiares
    WHERE
        id = p_id;

    COMMIT;
END;
/
/*Procedure P_DELETE_FAMILIAR compilado*/

-- Insertar historial
CREATE OR REPLACE PROCEDURE p_insert_historial (
    p_user_id IN NUMBER,
    p_accion  IN VARCHAR2
) AS
BEGIN
    INSERT INTO historial (
        user_id,
        accion
    ) VALUES ( p_user_id,
               p_accion );

    COMMIT;
END;
/
/*Procedure P_INSERT_HISTORIAL compilado*/

-- Marcar meta como completada
CREATE OR REPLACE PROCEDURE p_marcar_meta_completada (
    p_meta_id IN NUMBER
) AS
BEGIN
    UPDATE metas_financieras
    SET
        estado = 'completado',
        progreso = monto_objetivo
    WHERE
        id = p_meta_id;

    COMMIT;
END;
/
/*Procedure P_MARCAR_META_COMPLETADA compilado*/

-- Total de ingresos de un usuario
CREATE OR REPLACE FUNCTION f_total_ingresos_usuario (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT
        nvl(
            sum(monto),
            0
        )
    INTO v_total
    FROM
        finanzas
    WHERE
            user_id = p_user_id
        AND tipo = 'ingreso';

    RETURN v_total;
END;
/
/*Function F_TOTAL_INGRESOS_USUARIO compilado*/


-- Total de gastos de un usuario
CREATE OR REPLACE FUNCTION f_total_gastos_usuario (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT
        nvl(
            sum(monto),
            0
        )
    INTO v_total
    FROM
        finanzas
    WHERE
            user_id = p_user_id
        AND tipo = 'gasto';

    RETURN v_total;
END;
/
/*Function F_TOTAL_GASTOS_USUARIO compilado*/

-- Cantidad de alertas por usuario
CREATE OR REPLACE FUNCTION f_total_alertas_usuario (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO v_count
    FROM
        alertas
    WHERE
        user_id = p_user_id;

    RETURN v_count;
END;
/
/*Function F_TOTAL_ALERTAS_USUARIO compilado*/

-- Promedio de gasto mensual
CREATE OR REPLACE FUNCTION f_promedio_gasto_mensual (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_prom NUMBER;
BEGIN
    SELECT
        nvl(
            avg(monto),
            0
        )
    INTO v_prom
    FROM
        finanzas
    WHERE
            user_id = p_user_id
        AND tipo = 'gasto';

    RETURN v_prom;
END;
/
/*Function F_TOTAL_ALERTAS_USUARIO compilado*/

-- Total de metas completadas
CREATE OR REPLACE FUNCTION f_total_metas_completadas (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO v_total
    FROM
        metas_financieras
    WHERE
            user_id = p_user_id
        AND lower(estado) = 'completado';

    RETURN v_total;
END;
/
/*Function F_TOTAL_METAS_COMPLETADAS compilado*/

-- Porcentaje de ahorro
CREATE OR REPLACE FUNCTION f_porcentaje_ahorro (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_ingresos NUMBER;
    v_gastos   NUMBER;
BEGIN
    v_ingresos := f_total_ingresos_usuario(p_user_id);
    v_gastos := f_total_gastos_usuario(p_user_id);
    IF v_ingresos = 0 THEN
        RETURN 0;
    ELSE
        RETURN round(((v_ingresos - v_gastos) / v_ingresos) * 100, 2);
    END IF;

END;
/
/*Function F_PORCENTAJE_AHORRO compilado*/

-- Cantidad de reportes generados
CREATE OR REPLACE FUNCTION f_total_reportes_usuario (
    p_user_id NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT
        COUNT(*)
    INTO v_total
    FROM
        reportes
    WHERE
        user_id = p_user_id;

    RETURN v_total;
END;
/
/*Function F_TOTAL_REPORTES_USUARIO compilado*/



--                      Funciones

-- Balance total 
CREATE OR REPLACE FUNCTION f_get_balance (
    p_user_id IN NUMBER
) RETURN NUMBER IS
    v_balance NUMBER := 0;
BEGIN
    SELECT
        nvl(
            sum(
                CASE
                    WHEN tipo = 'ingreso' THEN
                        monto
                    WHEN tipo = 'gasto' THEN
                        -monto
                    ELSE 0
                END
            ),
            0
        )
    INTO v_balance
    FROM
        finanzas
    WHERE
        user_id = p_user_id;

    RETURN v_balance;
EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;
END;
/
/*Function F_GET_BALANCE compilado*/

-- Avance de una meta en  %
CREATE OR REPLACE FUNCTION f_avance_meta (
    p_meta_id IN NUMBER
) RETURN NUMBER IS
    v_progreso NUMBER;
    v_objetivo NUMBER;
BEGIN
    SELECT
        nvl(progreso, 0),
        nvl(monto_objetivo, 0)
    INTO
        v_progreso,
        v_objetivo
    FROM
        metas_financieras
    WHERE
        id = p_meta_id;

    IF v_objetivo = 0 THEN
        RETURN 0;
    ELSE
        RETURN round((v_progreso / v_objetivo) * 100, 2);
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;
END;
/
/*Function F_AVANCE_META compilado*/

-- Total gastos de un mes
CREATE OR REPLACE FUNCTION f_total_gastos_mes (
    p_user_id IN NUMBER,
    p_mes     IN NUMBER,
    p_anio    IN NUMBER
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT
        nvl(
            sum(monto),
            0
        )
    INTO v_total
    FROM
        finanzas
    WHERE
            user_id = p_user_id
        AND tipo = 'gasto'
        AND EXTRACT(MONTH FROM fecha_trx) = p_mes
        AND EXTRACT(YEAR FROM fecha_trx) = p_anio;

    RETURN v_total;
END;
/
/*Function F_TOTAL_GASTOS_MES compilado*/

--  listar metas completadas
CREATE OR REPLACE PROCEDURE p_listar_metas_completadas IS
BEGIN
  FOR r IN (SELECT nombre, monto_objetivo FROM metas_financieras WHERE LOWER(estado)='completado') LOOP
    DBMS_OUTPUT.PUT_LINE('Meta completada: '||r.nombre||' ('||r.monto_objetivo||')');
  END LOOP;
END;
/
/*Procedure P_LISTAR_METAS_COMPLETADAS compilado*/

-- eliminar usuario en cascada
CREATE OR REPLACE PROCEDURE p_eliminar_usuario_cascada(p_id IN NUMBER) AS
BEGIN
  DELETE FROM finanzas WHERE user_id=p_id;
  DELETE FROM metas_financieras WHERE user_id=p_id;
  DELETE FROM categorias WHERE user_id=p_id;
  DELETE FROM usuarios WHERE id=p_id;
  COMMIT;
END;
/
/*Procedure P_ELIMINAR_USUARIO_CASCADA compilado*/






--                      VISTAS

CREATE OR REPLACE VIEW vw_user_summary AS
    SELECT
        u.id,
        u.nombre,
        u.email,
        u.fecha_registro,
        f_get_balance(u.id) AS balance_total,
        (
            SELECT
                COUNT(*)
            FROM
                finanzas f2
            WHERE
                f2.user_id = u.id
        )                   AS transacciones
    FROM
        usuarios

u;
/
/*View VW_USER_SUMMARY creado.*/

CREATE OR REPLACE VIEW vw_metas_progreso AS
    SELECT
        m.id,
        u.nombre            usuario,
        m.nombre            meta,
        m.monto_objetivo,
        m.progreso,
        f_avance_meta(m.id) avance_porcentaje,
        m.estado
    FROM
             metas_financieras m
        JOIN usuarios u ON m.user_id = u.id;
/
/*View VW_METAS_PROGRESO creado.*/


CREATE OR REPLACE VIEW vw_gastos_mensuales AS
SELECT u.id usuario_id, u.nombre, EXTRACT(MONTH FROM f.fecha_trx) mes,
       EXTRACT(YEAR FROM f.fecha_trx) anio, SUM(f.monto) total_gasto
FROM finanzas f JOIN usuarios u ON f.user_id=u.id
WHERE f.tipo='gasto'
GROUP BY u.id, u.nombre, EXTRACT(MONTH FROM f.fecha_trx), EXTRACT(YEAR FROM f.fecha_trx);
/
/*View VW_METAS_PROGRESO creado.*/


-- usuarios con su total de alertas
CREATE OR REPLACE VIEW vw_usuarios_alertas AS
SELECT u.id, u.nombre, f_total_alertas_usuario(u.id) AS total_alertas
FROM usuarios u;
/
/*View VW_METAS_PROGRESO creado.*/

-- resumen de ingresos gastos y balance
CREATE OR REPLACE VIEW vw_finanzas_resumen AS
SELECT u.id usuario_id, u.nombre,
       f_total_ingresos_usuario(u.id) ingresos,
       f_total_gastos_usuario(u.id) gastos,
       f_get_balance(u.id) balance
FROM usuarios u;
/
/*View VW_FINANZAS_RESUMEN creado.*/

-- metas completadas
CREATE OR REPLACE VIEW vw_metas_completadas AS
SELECT m.id, u.nombre usuario, m.nombre meta, m.monto_objetivo, m.estado
FROM metas_financieras m JOIN usuarios u ON m.user_id=u.id
WHERE LOWER(m.estado)='completado';
/
/*View VW_METAS_COMPLETADAS creado.*/

-- gastos por categoría
CREATE OR REPLACE VIEW vw_gastos_por_categoria AS
SELECT c.nombre categoria, SUM(f.monto) total
FROM finanzas f JOIN categorias c ON f.categoria_id=c.id
WHERE f.tipo='gasto'
GROUP BY c.nombre;
/
/*View VW_GASTOS_POR_CATEGORIA creado.*/

-- usuarios mas de 3 meses
CREATE OR REPLACE VIEW vw_usuarios_metas_activas AS
SELECT u.id, u.nombre, COUNT(m.id) cantidad_metas
FROM usuarios u JOIN metas_financieras m ON u.id=m.user_id
WHERE LOWER(m.estado)='en progreso'
GROUP BY u.id, u.nombre
HAVING COUNT(m.id) > 3;
/
/*View VW_USUARIOS_METAS_ACTIVAS creado.*/

-- Vhistorial reciente con fecha de registro
CREATE OR REPLACE VIEW vw_historial_reciente AS
SELECT h.user_id, u.nombre, h.accion, h.fecha_registro
FROM historial h JOIN usuarios u ON h.user_id=u.id
WHERE h.fecha_registro > SYSDATE - 30;
/
/*View VW_HISTORIAL_RECIENTE creado.*/

-- }usuarios con ahorros positivo
CREATE OR REPLACE VIEW vw_usuarios_ahorradores AS
SELECT u.id, u.nombre,
       f_porcentaje_ahorro(u.id) porcentaje_ahorro
FROM usuarios u
WHERE f_porcentaje_ahorro(u.id) > 0;
/
/*View VW_USUARIOS_AHORRADORES creado.*/

--                      Paquetes y cursores

CREATE OR REPLACE PACKAGE fingo_pkg IS
  CURSOR c_finanzas(p_user NUMBER) IS SELECT id, tipo, monto, fecha_trx FROM finanzas WHERE user_id=p_user ORDER BY fecha_trx DESC;
  PROCEDURE p_listar_finanzas(p_user NUMBER);
  FUNCTION f_conteo_finanzas(p_user NUMBER) RETURN NUMBER;
  FUNCTION f_balance_resumido(p_user NUMBER) RETURN NUMBER;
END fingo_pkg;
/
/*Package FINGO_PKG compilado*/

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
/*Package Body FINGO_PKG compilado*/

-- pkg_usuarios
CREATE OR REPLACE PACKAGE pkg_usuarios IS
  CURSOR c_usuarios IS SELECT id, nombre, email, telefono FROM usuarios ORDER BY fecha_registro DESC;
  PROCEDURE p_listar_usuarios;
  PROCEDURE p_actualizar_password(p_id NUMBER, p_nueva_pwd VARCHAR2);
  FUNCTION f_total_usuarios RETURN NUMBER;
END pkg_usuarios;
/
/*Package PKG_USUARIOS compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_usuarios IS
  PROCEDURE p_listar_usuarios IS
  BEGIN
    FOR r IN c_usuarios LOOP
      DBMS_OUTPUT.PUT_LINE('ID='||r.id||' - '||r.nombre||' ('||r.email||')');
    END LOOP;
  END;
  PROCEDURE p_actualizar_password(p_id NUMBER, p_nueva_pwd VARCHAR2) IS
  BEGIN
    UPDATE usuarios SET password=p_nueva_pwd WHERE id=p_id;
    COMMIT;
  END;
  FUNCTION f_total_usuarios RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total FROM usuarios;
    RETURN v_total;
  END;
END pkg_usuarios;
/
/*Package Body PKG_USUARIOS compilado*/

-- pkg_finanzas
CREATE OR REPLACE PACKAGE pkg_finanzas IS
  CURSOR c_gastos_mes(p_user NUMBER, p_mes NUMBER, p_anio NUMBER) IS
    SELECT descripcion, monto, fecha_trx FROM finanzas
    WHERE user_id=p_user AND tipo='gasto'
    AND EXTRACT(MONTH FROM fecha_trx)=p_mes
    AND EXTRACT(YEAR FROM fecha_trx)=p_anio;
  PROCEDURE p_listar_gastos_mes(p_user NUMBER, p_mes NUMBER, p_anio NUMBER);
  FUNCTION f_total_transacciones(p_user NUMBER) RETURN NUMBER;
END pkg_finanzas;
/
/*Package PKG_FINANZAS compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_finanzas IS
  PROCEDURE p_listar_gastos_mes(p_user NUMBER, p_mes NUMBER, p_anio NUMBER) IS
  BEGIN
    FOR r IN c_gastos_mes(p_user, p_mes, p_anio) LOOP
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(r.fecha_trx,'YYYY-MM-DD')||' - '||r.descripcion||' $'||r.monto);
    END LOOP;
  END;
  FUNCTION f_total_transacciones(p_user NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total FROM finanzas WHERE user_id=p_user;
    RETURN v_total;
  END;
END pkg_finanzas;
/
/*Package Body PKG_FINANZAS compilado*/

-- pkg_metas
CREATE OR REPLACE PACKAGE pkg_metas IS
  CURSOR c_metas_en_progreso(p_user NUMBER) IS
    SELECT nombre, progreso, monto_objetivo FROM metas_financieras
    WHERE user_id=p_user AND LOWER(estado)='en progreso';
  PROCEDURE p_listar_metas_usuario(p_user NUMBER);
  FUNCTION f_promedio_avance(p_user NUMBER) RETURN NUMBER;
END pkg_metas;
/
/*
Package PKG_METAS compilado*/


CREATE OR REPLACE PACKAGE BODY pkg_metas IS
  PROCEDURE p_listar_metas_usuario(p_user NUMBER) IS
  BEGIN
    FOR r IN c_metas_en_progreso(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE('Meta: '||r.nombre||' Avance: '||ROUND((r.progreso/r.monto_objetivo)*100,2)||'%');
    END LOOP;
  END;
  FUNCTION f_promedio_avance(p_user NUMBER) RETURN NUMBER IS
    v_prom NUMBER;
  BEGIN
    SELECT NVL(AVG((progreso/monto_objetivo)*100),0)
    INTO v_prom FROM metas_financieras WHERE user_id=p_user AND monto_objetivo>0;
    RETURN ROUND(v_prom,2);
  END;
END pkg_metas;
/
/*Package Body PKG_METAS compilado*/

-- pkg_alertas
CREATE OR REPLACE PACKAGE pkg_alertas IS
  CURSOR c_alertas_usuario(p_user NUMBER) IS SELECT tipo, mensaje, fecha_envio FROM alertas WHERE user_id=p_user;
  PROCEDURE p_listar_alertas_usuario(p_user NUMBER);
  FUNCTION f_alertas_recientes(p_dias NUMBER) RETURN NUMBER;
END pkg_alertas;
/
/*Package PKG_ALERTAS compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_alertas IS
  PROCEDURE p_listar_alertas_usuario(p_user NUMBER) IS
  BEGIN
    FOR r IN c_alertas_usuario(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE('['||TO_CHAR(r.fecha_envio,'YYYY-MM-DD HH24:MI')||'] '||r.tipo||': '||r.mensaje);
    END LOOP;
  END;
  FUNCTION f_alertas_recientes(p_dias NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total FROM alertas WHERE fecha_envio > SYSDATE - p_dias;
    RETURN v_total;
  END;
END pkg_alertas;
/
/*Package Body PKG_ALERTAS compilado*/

-- pkg_reportes
CREATE OR REPLACE PACKAGE pkg_reportes IS
  CURSOR c_reportes_usuario(p_user NUMBER) IS SELECT tipo, descripcion, monto, fecha FROM reportes WHERE user_id=p_user;
  PROCEDURE p_listar_reportes_usuario(p_user NUMBER);
  FUNCTION f_total_reportes RETURN NUMBER;
END pkg_reportes;
/
/*Package PKG_REPORTES compilado*/


CREATE OR REPLACE PACKAGE BODY pkg_reportes IS
  PROCEDURE p_listar_reportes_usuario(p_user NUMBER) IS
  BEGIN
    FOR r IN c_reportes_usuario(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE('['||TO_CHAR(r.fecha,'YYYY-MM-DD')||'] '||r.tipo||' - '||r.descripcion||' $'||r.monto);
    END LOOP;
  END;
  FUNCTION f_total_reportes RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total FROM reportes;
    RETURN v_total;
  END;
END pkg_reportes;
/
/*Package Body PKG_REPORTES compilado*/

-- pkg_presupuestos
CREATE OR REPLACE PACKAGE pkg_presupuestos IS
  CURSOR c_presupuestos_usuario(p_user NUMBER) IS SELECT mes, anio, monto_limite FROM presupuestos WHERE user_id=p_user;
  PROCEDURE p_listar_presupuestos_usuario(p_user NUMBER);
  FUNCTION f_total_presupuesto_anual(p_user NUMBER, p_anio NUMBER) RETURN NUMBER;
END pkg_presupuestos;
/
/*Package PKG_PRESUPUESTOS compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_presupuestos IS
  PROCEDURE p_listar_presupuestos_usuario(p_user NUMBER) IS
  BEGIN
    FOR r IN c_presupuestos_usuario(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE('Mes '||r.mes||'/'||r.anio||' - Límite: '||r.monto_limite);
    END LOOP;
  END;
  FUNCTION f_total_presupuesto_anual(p_user NUMBER, p_anio NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT NVL(SUM(monto_limite),0) INTO v_total FROM presupuestos WHERE user_id=p_user AND anio=p_anio;
    RETURN v_total;
  END;
END pkg_presupuestos;
/
/*Package Body PKG_PRESUPUESTOS compilado*/

-- pkg_familiares
CREATE OR REPLACE PACKAGE pkg_familiares IS
  CURSOR c_familiares_usuario(p_user NUMBER) IS SELECT nombre, email, rol FROM familiares WHERE user_id=p_user;
  PROCEDURE p_listar_familiares_usuario(p_user NUMBER);
END pkg_familiares;
/
/*Package PKG_FAMILIARES compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_familiares IS
  PROCEDURE p_listar_familiares_usuario(p_user NUMBER) IS
  BEGIN
    FOR r IN c_familiares_usuario(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE('Familiar: '||r.nombre||' ('||r.rol||') - '||r.email);
    END LOOP;
  END;
END pkg_familiares;
/
/*
Package Body PKG_FAMILIARES compilado*/

-- pkg_historial
CREATE OR REPLACE PACKAGE pkg_historial IS
  CURSOR c_historial_usuario(p_user NUMBER) IS SELECT accion, fecha_registro FROM historial WHERE user_id=p_user ORDER BY fecha_registro DESC;
  PROCEDURE p_mostrar_historial_usuario(p_user NUMBER);
END pkg_historial;
/
/*Package PKG_HISTORIAL compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_historial IS
  PROCEDURE p_mostrar_historial_usuario(p_user NUMBER) IS
  BEGIN
    FOR r IN c_historial_usuario(p_user) LOOP
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(r.fecha_registro,'YYYY-MM-DD HH24:MI')||' - '||r.accion);
    END LOOP;
  END;
END pkg_historial;
/
/*Package Body PKG_HISTORIAL compilado*/

-- pkg_configuracion
CREATE OR REPLACE PACKAGE pkg_configuracion IS
  CURSOR c_config_usuarios IS SELECT user_id, notificaciones FROM configuracion;
  PROCEDURE p_listar_config;
  PROCEDURE p_actualizar_notificaciones(p_user NUMBER, p_estado VARCHAR2);
END pkg_configuracion;
/
/*Package PKG_CONFIGURACION compilado*/

CREATE OR REPLACE PACKAGE BODY pkg_configuracion IS
  PROCEDURE p_listar_config IS
  BEGIN
    FOR r IN c_config_usuarios LOOP
      DBMS_OUTPUT.PUT_LINE('Usuario '||r.user_id||' - Notificaciones: '||r.notificaciones);
    END LOOP;
  END;
  PROCEDURE p_actualizar_notificaciones(p_user NUMBER, p_estado VARCHAR2) IS
  BEGIN
    UPDATE configuracion SET notificaciones=p_estado WHERE user_id=p_user;
    COMMIT;
  END;
END pkg_configuracion;
/
/*Package Body PKG_CONFIGURACION compilado*/


