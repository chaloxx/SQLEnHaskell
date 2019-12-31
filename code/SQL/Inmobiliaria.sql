SELECT USER pablo alonso;
USE Inmobiliaria;
/*DELETE Inmueble WHERE codigo = "Cas0001"*/

CREATE TABLE Poblacion(
  nombrePoblacion  String,
  nHabitantes      Int NULL,
  KEY (nombrePoblacion)
) ;

CREATE TABLE Zona(
  nombrePoblacion  String,
  nombreZona       String,
  KEY (nombreZona, nombrePoblacion),
  FOREIGN KEY (nombrePoblacion) REFERENCE Poblacion (nombrePoblacion) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Inmueble (
  codigo    String,
  precio            Int,
  direccion         String,
  superficie        Int,
  nombreP  String,
  nombreZ       String,
  KEY (codigo),
  FOREIGN KEY (nombreP,nombreZ) REFERENCE Zona (nombrePoblacion,nombreZona) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Limita (
  nombreP    String,
  nombreZ    String ,
  nombreP2   String ,
  nombreZ2   String,
  KEY (nombreP, nombreZ, nombreP2, nombreZ2),
  FOREIGN KEY (nombreP) REFERENCE Poblacion (nombrePoblacion)  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (nombreZ) REFERENCE Zona (nombreZona)  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (nombreP2) REFERENCE Poblacion (nombrePoblacion)  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (nombreZ2) REFERENCE Zona (nombreZona)  ON DELETE CASCADE ON UPDATE CASCADE
) ;



CREATE TABLE Persona (
  codigo    Int ,
  nombre    String,
  apellido  String,
  domicilio String NULL,
  telefono  Int NULL,
  KEY (codigo)
);

CREATE TABLE Vendedor (
  codigo  Int ,
  cuil    String   NULL,
  sueldo  Int  NULL,
  KEY (codigo),
  FOREIGN KEY (codigo) REFERENCE Persona (codigo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Cliente (
  codigo    Int ,
  vendedor  Int ,
  KEY (codigo),
  FOREIGN KEY (codigo) REFERENCE Persona (codigo)  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (vendedor) REFERENCE Persona (codigo)  ON DELETE CASCADE ON UPDATE CASCADE
) ;



CREATE TABLE Propietario (
  codigo  Int,
  dni     Int NULL,
  KEY (codigoPropietario),
  FOREIGN KEY (codigoPropietario) REFERENCE Persona (codigo) ON DELETE CASCADE ON UPDATE CASCADE
);





CREATE TABLE PoseeInmueble (
  codigoProp  Int,
  codigoInmueble     String,
  KEY (codigoProp, codigoInmueble),
  FOREIGN KEY (codigoProp) REFERENCE Propietario (codigoPropietario) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (codigoInmueble) REFERENCE Inmueble (codigo)   ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PrefiereZona (
  codigoCliente    Int,
  nombreP  String,
  nombreZ  String,
  KEY (codigoCliente, nombrePoblacion, nombreZona),
  FOREIGN KEY (codigoCliente) REFERENCE Persona (codigo) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (nombreP,nombreZ) REFERENCE Zona (nombrePoblacion,nombreZona) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Visitas (
  codigoCliente    Int,
  codigoInmueble   String,
  fechaHora  DateTime ,
  KEY (codigoInmueble, fechaHora),
  FOREIGN KEY (codigoCliente) REFERENCE Cliente (codigo) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (codigoInmueble) REFERENCE Inmueble (codigo) ON DELETE CASCADE ON UPDATE CASCADE
)


/*INSERT  Visitas (1011, "Slr0001", 2014-10-29 10:00:00);
INSERT  Visitas (1012, "Ros0001", 2014-10-29 10:00:00);
INSERT  Visitas (1011, "Slr0001", 2014-10-28 10:00:00);
INSERT  Visitas (1012, "Ros000", 2014-10-28 10:00:00);
INSERT  Visitas (1015, "Ros0001", 2014-10-15 10:00:00);
INSERT  Visitas (1016, "Ros0002", 2014-10-15 10:00:00);
INSERT  Visitas (1013, "Ros0001", 2014-02-01 10:00:00);
INSERT  Visitas (1013, "Ros0002", 2014-02-02 10:00:00);
INSERT  Visitas (1013, "Ros0003", 2014-02-03 10:00:00);
INSERT  Visitas (1001, "Cas0error "Aca llega"002", 2014-03-01 10:00:00);
INSERT  Visitas (1018, "Stf0001", 2014-11-06 10:00:00);
INSERT  Visitas (1018, "Stf0001", 2014-11-08 10:00:00);


INSERT  Inmueble ("Ros0001", 200000, "Sarmiento 234", 80, "Rosario","Centro");
INSERT  Inmueble ("Ros0002", 3000000, "Mitre 134", 90, "Rosario","Centro");
INSERT  Inmueble ("Ros0003", 600000, "Rioja 344", 60, "Rosario","Centro");
INSERT  Inmueble ("Ros0004", 900000, "Cordoba 344", 92, "Rosario","Sur");
INSERT  Inmueble ("Ros0005", 110000, "Santa Fe 344", 102, "Rosario","Sur");
INSERT  Inmueble ("Ros0006", 700000, "San Lorenzo 344", 52, "Rosario","Sur");
INSERT  Inmueble ("Ros0007", 820000, "Alberdi 3344", 93, "Rosario","Norte");
INSERT  Inmueble ("Ros0008", 830000, "Rondeau 4044", 44, "Rosario","Norte");
INSERT  Inmueble ("Ros0009", 640000, "Mendoza 5344", 92, "Rosario","Oeste");
INSERT  Inmueble ("Ros0010", 650000, "Rioja 2344", 110, "Rosario","Oeste");
INSERT  Inmueble ("Ros0011", 660000, "Mendoza 2344", 64, "Rosario","Oeste");
INSERT  Inmueble ("Cas0001", 670000, "Mitre 111", 250, "Casilda","Este");
INSERT  Inmueble ("Cas0002", 680000, "San Martin 222", 90, "Casilda","Oeste");
INSERT  Inmueble ("Stf0001", 690000, "San Martin 1234", 89, "Santa Fe","Centro");
INSERT  Inmueble ("Stf0002", 710000, "San Martin 1345", 91, "Santa Fe","Centro");
INSERT  Inmueble ("Stf0003", 810000, "San Martin 1456", 99, "Santa Fe","Centro");
INSERT  Inmueble ("Stf0004", 611000, "Mitre 46", 99, "Santa Fe","Norte");
INSERT  Inmueble ("Stf0005", 1000000, "Mitre 4446", 99, "Santa Fe","Sur");
INSERT  Inmueble ("Slr0001", 1000000, "Maipu 46", 109, "San Lorenzo","Sur");


INSERT  Propietario (1002, 8777999);
INSERT  Propietario (1003, 9777999);
INSERT  Propietario (1004, 10777999);
INSERT  Propietario (1007, 20777999);
INSERT  Propietario (1008, 20778000)



INSERT PoseeInmueble (1003, "Ros0001");
INSERT PoseeInmueble (1003, "Ros0002");
INSERT PoseeInmueble (1002, "Ros0003");
INSERT PoseeInmueble (1002, "Ros0004");
INSERT PoseeInmueble (1002, "Ros0005");
INSERT PoseeInmueble (1002, "Ros0006");
INSERT PoseeInmueble (1002, "Ros0007");
INSERT PoseeInmueble (1002, "Ros0008");
INSERT PoseeInmueble (1002, "Ros0009");
INSERT PoseeInmueble (1002, "Ros0010");
INSERT PoseeInmueble (1002, "Ros0011");
INSERT PoseeInmueble (1007, "Cas0001");
INSERT PoseeInmueble (1007, "Cas0002");
INSERT PoseeInmueble (1007, "Stf0001");
INSERT PoseeInmueble (1007, "Stf0002");
INSERT PoseeInmueble (1007, "Stf0003");
INSERT PoseeInmueble (1007, "Stf0004");
INSERT PoseeInmueble (1008, "Stf0004");
INSERT PoseeInmueble (1007, "Stf0005");
INSERT PoseeInmueble (1008, "Stf0005");
INSERT PoseeInmueble (1008, "Slr0001")*/
