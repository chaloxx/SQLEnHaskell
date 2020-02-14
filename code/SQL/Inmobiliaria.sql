CREATE USER pablo;
SELECT USER pablo;
CREATE DATABASE Inmobiliaria;
USE Inmobiliaria;

/*SELECT ALL  FROM Persona INNER JOIN Cliente ON Persona.codigo = Cliente.codigo*/
/*SELECT Persona.nombre, Vendedor.codigo FROM Persona RIGHT JOIN  Vendedor ON Vendedor.codigo = Persona.codigo*/
/*SELECT codigoCliente,codigo FROM Visitas,(SELECT codigo FROM Inmueble WHERE precio = 67000) AS Pepe*/

/*CREATE TABLE Poblacion(
  nombrePoblacion  String,
  nHabitantes      Int NULL,
  KEY (nombrePoblacion)
) ;

CREATE TABLE Zona(
  nombrePob  String,
  nombreZ  String,
  KEY (nombrePob, nombreZ),
  FOREIGN KEY (nombrePob) REFERENCE Poblacion (nombrePoblacion) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Inmueble (
  codigo    String,
  precio            Int,
  direccion         String,
  superficie        Int,
  nombreP  String,
  nombreZ       String,
  KEY (codigo),
  FOREIGN KEY (nombreP,nombreZ) REFERENCE Zona (nombrePob,nombreZ) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Limita (
  nombreP    String,
  nombreZ    String ,
  nombreP2   String ,
  nombreZ2   String,
  KEY (nombreP, nombreZ, nombreP2, nombreZ2),
  FOREIGN KEY (nombreP,nombreZ) REFERENCE Zona (nombrePob,nombreZ)  ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (nombreP2,nombreZ2) REFERENCE Zona (nombrePob,nombreZ)  ON DELETE CASCADE ON UPDATE CASCADE
);



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
  codigoP  Int,
  dni     Int NULL,
  KEY (codigoP),
  FOREIGN KEY (codigoP) REFERENCE Persona (codigo) ON DELETE CASCADE ON UPDATE CASCADE
);





CREATE TABLE PoseeInmueble (
  codigoProp  Int,
  codigoInm   String,
  KEY (codigoProp, codigoInm),
  FOREIGN KEY (codigoProp) REFERENCE Propietario (codigoP) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (codigoInm) REFERENCE Inmueble (codigo)   ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE PrefiereZona (
  codCliente    Int,
  nombrePob  String,
  nombreZona  String,
  KEY (codCliente, nombrePob, nombreZona),
  FOREIGN KEY (codCliente) REFERENCE Persona (codigo) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (nombrePob,nombreZona) REFERENCE Zona (nombrePob,nombreZ) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Visitas (
  codigoCliente    Int,
  codigoInmueble   String,
  fechaHora  DateTime ,
  KEY (codigoInmueble, fechaHora),
  FOREIGN KEY (codigoCliente) REFERENCE Cliente (codigo) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (codigoInmueble) REFERENCE Inmueble (codigo) ON DELETE CASCADE ON UPDATE CASCADE
);






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



INSERT Inmueble ("Ros0001", 200000, "Sarmiento 234", 80, "Rosario","Centro");
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

*/


/*



INSERT  Propietario (1002, 8777999);
INSERT  Propietario (1003, 9777999);
INSERT  Propietario (1004, 10777999);
INSERT  Propietario (1007, 20777999);
INSERT  Propietario (1008, 20778000);



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
INSERT PoseeInmueble (1008, "Slr0001")






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


/*Testeo*/

/*SELECT ALL FROM Habitantes*/
/*SELECT pepe FROM Poblacion,Algo*/
/*SELECT nHabitantes AS cantHabitantes FROM Poblacion*/
/*SELECT Poblacion.nHabitantes  FROM Poblacion */
/*SELECT Poblacion.nHabitantes AS cantHabitantes  FROM Poblacion */

/*Contar cuantos inmuebles hay en cada ciudad*/
/*SELECT COUNT(codigo) AS nro,nombreP FROM Inmueble GROUP BY nombreP*/


/*En que ciudad hay más de 5 inmuebles?*/
SELECT nombreP FROM Inmueble GROUP BY nombreP HAVING COUNT(codigo) >= 5





/*Obtener los nombres de los dueños de los inmuebles*/
/*SELECT DISTINCT apellido FROM Persona, PoseeInmueble WHERE Persona.codigo = PoseeInmueble.codigoProp*/

/*Obtener todos los códigos de los inmuebles cuyo precio está en el intervalo 600.000 a 700.000
inclusive*/

/*SELECT codigo FROM Inmueble WHERE precio > 599999 AND precio <= 800001*/
/*SELECT codigo FROM Inmueble WHERE precio > 599999 AND precio < 800001 ORDER BY codigo ASC si lo quiero ordenado por codigo*/

/*Obtener los nombres de los clientes que prefieran inmuebles sólo en la zona Norte de Santa Fe*/
/*SELECT DISTINCT nombre FROM Persona,PrefiereZona WHERE EXIST (SELECT ALL FROM PrefiereZona WHERE  nombreZona = "Norte" AND nombrePob = "Santa Fe" AND Persona.codigo = PrefiereZona.codCliente) AND  NOT EXIST (SELECT ALL FROM PrefiereZona WHERE  (nombreZona <>  "Norte" OR nombrePob <> "Santa Fe") AND Persona.codigo = codCliente)*/

/*Obtener los nombres de los empleados que atiendan a algún cliente que prefiera la zona Centro
de Rosario.*/
/*SELECT DISTINCT nombre FROM Persona
                            INNER JOIN
                            (SELECT vendedor FROM (SELECT codigo FROM Persona
                                                                      INNER JOIN
                                                                      PrefiereZona
                                                                      ON codigo = codCliente WHERE nombrePob = "Rosario" AND nombreZona = "Centro")
                                                   AS s1
                                                  INNER JOIN
                                                 (SELECT ALL FROM Cliente COLUMN codigo AS cod)
                                                 ON s1.codigo = Cliente.cod)
                                                  AS s2 ON vendedor = codigo*/



/*Obtener los nombres de los vendedores que atienden a otros vendedores.*/
/*SELECT nombre FROM Persona
                  INNER JOIN
                  (SELECT vendedor FROM Cliente WHERE codigo IN (SELECT vendedor FROM Cliente)) AS s1
                   ON codigo = vendedor*/





/*Obtener los nombres de los clientes que prefieran inmuebles en todas las zonas de Rosario*/
 /*SELECT DISTINCT nombre FROM Persona,
                             (SELECT codCliente FROM  PrefiereZona AS S0 WHERE  NOT EXIST (SELECT nombreZ FROM Zona AS S1 WHERE nombrePob = "Rosario"  AND NOT EXIST (SELECT ALL FROM PrefiereZona AS S2 WHERE S2.codCliente = S0.codCliente AND  S2.nombreZona = S1.nombreZ))) AS S4
                              WHERE Persona.codigo = S4.codCliente*/





/*Hay clientes que ya visitaron o tienen programado visitar todos los inmuebles de sus zonas favoritas
(un cliente que no tenga zonas de preferencia no entrará en esta categoría).
Para cada uno de ellos, obtener su nombre junto con información de los inmuebles (código, zona
y precio) ubicados en zonas no preferidas por ellos pero sı́ limı́trofes a alguna de ellas.*/

/*SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombreZ, Inmueble.precio
FROM   Persona, PrefiereZona, Limita, Inmueble
WHERE  Persona.codigo = PrefiereZona.codCliente AND Zonas preferidas
       (Limita.nombreP = PrefiereZona.nombrePob AND Zonas limitrofes a las preferidas
       Limita.nombreZ = PrefiereZona.nombreZona AND
       Inmueble.nombreP = Limita.nombreP2 AND Inmuebles en zonas limitrofes
       Inmueble.nombreZ = Limita.nombreZ2
       OR
       Limita.nombreP2 = PrefiereZona.nombrePob AND Zonas limitrofes a las preferidas
       Limita.nombreZ2 = PrefiereZona.nombreZona AND
       Inmueble.nombreP = Limita.nombreP AND Inmuebles en zonas limitrofes
       Inmueble.nombreZ = Limita.nombreZ)
       AND

       Persona.codigo IN Chequear que esta persona sea un cliente que visitó todos los inmuebles en sus zonas favoritas
       (SELECT codigo FROM Cliente WHERE NOT EXIST (SELECT ALL FROM PrefiereZona,Inmueble
                                                     WHERE Cliente.codigo = PrefiereZona.codCliente AND
                                                          Inmueble.nombreP = PrefiereZona.nombrePob AND
                                                          Inmueble.nombreZ = PrefiereZona.nombreZona AND
                                                          NOT EXIST (SELECT ALL FROM Visitas WHERE
                                                                      Visitas.codigoCliente = Cliente.codigo AND
                                                                      Visitas.codigoInmueble = Inmueble.codigo)))*/
/*La última consulta no termina*/
