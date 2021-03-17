SELECT USER pablo alonso;
USE  Prueba;
DROP ALL TABLE;
CREATE TABLE A (codigo Int, nombre String NULL,KEY(codigo));
CREATE TABLE B (codigoB Int NULL, nombreB String ,KEY(nombreB),FOREIGN KEY(codigoB) REFERENCE A (codigo) ON DELETE RESTRICTED);


INSERT A (1,"pepe");
INSERT B (1,"pepa");
DELETE A WHERE codigo = 1;
