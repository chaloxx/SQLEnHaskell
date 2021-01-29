SELECT USER pablo alonso;
USE Inmobiliaria;

DROP ALL TABLE;



CREATE TABLE Poblacion(
  nombrePoblacion  String,
  nHabitantes      Int NULL,
  KEY (nombrePoblacion)
);





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


/*
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
);





DROP TABLE Poblacion ;
DROP TABLE Zona ;
DROP TABLE Inmueble ;
DROP TABLE Persona ;
DROP TABLE Vendedor ;
DROP TABLE Cliente ;
DROP TABLE Visitas ;

*/
/*

INSERT  Poblacion ("Rosario", 1500000);
INSERT  Poblacion ("Casilda", 14000);
INSERT  Poblacion ("Santa Fe", 500000);
INSERT  Poblacion ("San Lorenzo", 400000);




INSERT  Zona ("Rosario", "Norte");
INSERT  Zona ("Rosario", "Sur");
INSERT  Zona ("Rosario", "Centro");
INSERT  Zona ("Rosario", "Oeste");
INSERT  Zona ("Santa Fe", "Norte");
INSERT  Zona ("Santa Fe", "Sur");
INSERT  Zona ("Santa Fe", "Centro");
INSERT  Zona ("Casilda", "Este");
INSERT  Zona ("Casilda", "Oeste");
INSERT  Zona ("San Lorenzo", "Norte");
INSERT  Zona ("San Lorenzo", "Sur");
INSERT  Zona ("San Lorenzo", "Centro");

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

INSERT  Limita ("Rosario", "Oeste", "Rosario", "Centro");
INSERT  Limita ("Rosario", "Sur", "Rosario", "Centro");
INSERT  Limita ("Rosario", "Norte", "Rosario", "Centro");
INSERT  Limita ("Santa Fe", "Norte", "Santa Fe", "Centro");
INSERT  Limita ("Santa Fe", "Sur", "Santa Fe", "Centro");
INSERT  Limita ("San Lorenzo", "Norte", "San Lorenzo", "Centro");
INSERT  Limita ("San Lorenzo", "Sur", "San Lorenzo", "Centro");
INSERT  Limita ("Casilda", "Este", "Casilda", "Oeste");

INSERT  Persona (1001, "Roberto", "Planta", "Sarmiento 236, Rosario", 4304931);
INSERT  Persona (1002, "Rogelio", "Aguas", "Avellaneda 2436, Rosario", 4304932);
INSERT  Persona (1003, "Juan", "Rodriguez", "Mitre 45, Rosario", 4304933);
INSERT  Persona (1004, "Juana", "Lopez", "San Martin 246, Rosario", 4304934);
INSERT  Persona (1005, "Mirta", "Gonzalez", "Sarmiento 4236, Rosario", 4304935);
INSERT  Persona (1006, "Laura", "Perez", "Corrientes 4236, Santa Fe", 445935);
INSERT  Persona (1007, "Luis", "Salazar", "Moreno 236, Casilda", 455935);
INSERT  Persona (1008, "Maria", "Salazar", "Moreno 236, Casilda", 455935);

INSERT  Persona (1011, "Ana", "Zarantonelli", "Sarmiento 123, Rosario", 4555001);
INSERT  Persona (1012, "Belen", "Yani", "Avellaneda 234, Rosario", 4555002);
INSERT  Persona (1013, "Carlos", "Xuan", "Roca 345, San Lorenzo", 4555003);
INSERT  Persona (1014, "Dario", "Watson", "Mitre 456, Casilda", 4555004);
INSERT  Persona (1015, "Emilio", "Visconti", "Urquiza 567, Rosario", 4555005);
INSERT  Persona (1016, "Facundo", "Uriarte", "Alvear 678, Rosario", 4555006);
INSERT  Persona (1017, "Gabriela", "Troncoso", "Belgrano 789, Santa Fe", 4555007);
INSERT  Persona (1018, "Hugo", "Sosa", "Saavedra 890, Rosario", 4555008);

INSERT  Vendedor (1004, "21-12777999-2", 10000);
INSERT  Vendedor (1005, "21-13777999-2", 10000);
INSERT  Vendedor (1006, "21-14777999-2", 10000);

INSERT  Cliente (1011, 1004);
INSERT  Cliente (1012, 1004);
INSERT  Cliente (1013, 1004);
INSERT  Cliente (1014, 1004);
INSERT  Cliente (1015, 1005);
INSERT  Cliente (1016, 1005);
INSERT  Cliente (1017, 1006);
INSERT  Cliente (1018, 1006);
INSERT  Cliente (1005, 1006);
INSERT  Cliente (1001, 1005);

INSERT  PrefiereZona (1012, "Rosario", "Centro");
INSERT  PrefiereZona (1013, "Rosario", "Centro");
INSERT  PrefiereZona (1014, "Casilda", "Oeste");
INSERT  PrefiereZona (1014, "Casilda", "Este");
INSERT  PrefiereZona (1015, "Santa Fe", "Sur");
INSERT  PrefiereZona (1015, "Santa Fe", "Norte");
INSERT  PrefiereZona (1016, "Santa Fe","Norte");
INSERT  PrefiereZona (1017, "Rosario", "Centro");
INSERT  PrefiereZona (1017, "Rosario", "Sur");
INSERT  PrefiereZona (1017, "Rosario", "Norte");
INSERT  PrefiereZona (1017, "Rosario", "Oeste");
INSERT  PrefiereZona (1018, "Rosario", "Centro");
INSERT  PrefiereZona (1005, "San Lorenzo","Sur");
INSERT  PrefiereZona (1001, "Casilda", "Oeste");

INSERT  Propietario (1002, 8777999);
INSERT  Propietario (1003, 9777999);
INSERT  Propietario (1004, 10777999);
INSERT  Propietario (1007, 20777999);
INSERT  Propietario (1008, 20778000);

INSERT  PoseeInmueble (1003, "Ros0001");
INSERT  PoseeInmueble (1003, "Ros0002");
INSERT  PoseeInmueble (1002, "Ros0003");
INSERT  PoseeInmueble (1002, "Ros0004");
INSERT  PoseeInmueble (1002, "Ros0005");
INSERT  PoseeInmueble (1002, "Ros0006");
INSERT  PoseeInmueble (1002, "Ros0007");
INSERT  PoseeInmueble (1002, "Ros0008");
INSERT  PoseeInmueble (1002, "Ros0009");
INSERT  PoseeInmueble (1002, "Ros0010");
INSERT  PoseeInmueble (1002, "Ros0011");
INSERT  PoseeInmueble (1007, "Cas0001");
INSERT  PoseeInmueble (1007, "Cas0002");
INSERT  PoseeInmueble (1007, "Stf0001");
INSERT  PoseeInmueble (1007, "Stf0002");
INSERT  PoseeInmueble (1007, "Stf0003");
INSERT  PoseeInmueble (1007, "Stf0004");
INSERT  PoseeInmueble (1008, "Stf0004");
INSERT  PoseeInmueble (1007, "Stf0005");
INSERT  PoseeInmueble (1008, "Stf0005");
INSERT  PoseeInmueble (1008, "Slr0001");

INSERT  Visitas (1011, "Slr0001", 2014-10-29 10:00:00);
INSERT  Visitas (1012, "Ros0001", 2014-10-29 10:00:00);
INSERT  Visitas (1011, "Slr0001", 2014-10-28 10:00:00);
INSERT  Visitas (1012, "Ros0001", 2014-10-28 10:00:00);
INSERT  Visitas (1015, "Ros0001", 2014-10-15 10:00:00);
INSERT  Visitas (1016, "Ros0002", 2014-10-15 10:00:00);
INSERT  Visitas (1013, "Ros0001", 2014-02-01 10:00:00);
INSERT  Visitas (1013, "Ros0002", 2014-02-02 10:00:00);
INSERT  Visitas (1013, "Ros0003", 2014-02-03 10:00:00);
INSERT  Visitas (1001, "Cas0002", 2014-03-01 10:00:00);
INSERT  Visitas (1018, "Stf0001", 2014-11-06 10:00:00);
INSERT  Visitas (1018, "Stf0001", 2014-11-08 10:00:00)
*/
