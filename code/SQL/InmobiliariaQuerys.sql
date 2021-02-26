SELECT USER pablo alonso;
USE Inmobiliaria;
/*a*/
/*Nombres de los dueños de los inmuebles*/
/*
SELECT DISTINCT apellido
FROM Persona, PoseeInmueble
WHERE Persona.codigo = PoseeInmueble.codigoProp;
*/



/*b*/
/*códigos de los inmuebles cuyo precio está en el intervalo 600.000 a 700.000
inclusive.*/
/*
SELECT codigo
FROM Inmueble
WHERE precio >= 600000 AND precio <= 800000
ORDER BY codigo ASC;
*/


/*c*/
/*Obtener los nombres de los clientes que prefieran inmuebles sólo en la zona Norte de Santa Fe.*/
/*SELECT DISTINCT  nombre
FROM Persona,PrefiereZona AS PZ
WHERE EXISTS( SELECT ALL FROM PrefiereZona WHERE  nombreZ = "Norte" AND nombreP = "Santa Fe" AND codigo = codigoCliente)
      AND
      NOT  EXISTS (SELECT ALL FROM PrefiereZona WHERE  (nombreZ <> "Norte" OR nombreP <> "Santa Fe") AND codigo = codigoCliente )
      */

/*d*/
/*
SELECT DISTINCT nombre
FROM Persona INNER JOIN (SELECT vendedor FROM (SELECT codigo AS cod FROM Persona JOIN PrefiereZona ON codigo = codigoCliente WHERE nombreP = "Rosario" AND nombreZ = "Centro") AS s1 JOIN Cliente ON s1.cod = Cliente.codigo ) AS s2
             ON vendedor = codigo
*/



/*e*/
/*SELECT nombre FROM Persona JOIN (SELECT vendedor FROM Cliente AS C WHERE codigo IN (SELECT vendedor FROM Cliente)) AS s1 ON codigo = vendedor*/


/*f*/

/*
SELECT DISTINCT nombre
FROM Persona, (SELECT codigoCliente
              FROM  PrefiereZona AS S0
              WHERE  NOT EXISTS (SELECT nombreZona FROM Zona AS S1 WHERE nombrePoblacion = "Rosario"  AND
                     NOT EXISTS (SELECT ALL FROM PrefiereZona AS S2 WHERE S2.codigoCliente = S0.codigoCliente AND  S2.nombreZ = S1.nombreZona))) AS S4
WHERE Persona.codigo = S4.codigoCliente
*/


/*g*/



/*
SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombreZ, Inmueble.precio
FROM   Persona, PrefiereZona, Limita, Inmueble
WHERE  Persona.codigo = PrefiereZona.codigoCliente AND
       (Limita.nombreP = PrefiereZona.nombreP AND
       Limita.nombreZ = PrefiereZona.nombreZ AND
       Inmueble.nombreP = Limita.nombreP2 AND
       Inmueble.nombreZ = Limita.nombreZ2
       OR
       Limita.nombreP2 = PrefiereZona.nombreP AND
       Limita.nombreZ2 = PrefiereZona.nombreZ AND
       Inmueble.nombreP = Limita.nombreP AND
       Inmueble.nombreZ = Limita.nombreZ) AND
       Persona.codigo IN
       (SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT ALL FROM PrefiereZona AS PZ,Inmueble AS I
                                                     WHERE Cliente.codigo = PZ.codigoCliente AND
                                                          Inmueble.nombreP = PZ.nombreP AND
                                                          Inmueble.nombreZ = PZ.nombreZ AND
                                                          NOT EXISTS (SELECT ALL FROM Visitas WHERE
                                                                      Visitas.codigoCliente = Cliente.codigo AND
                                                                      Visitas.codigoInmueble = Inmueble.codigo)));
*/


SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombreZ, Inmueble.precio
FROM   Persona, PrefiereZona AS PZ, Limita, Inmueble
WHERE  Persona.codigo = PZ.codigoCliente AND
       (Limita.nombreP = PZ.nombreP AND
       Limita.nombreZ = PZ.nombreZ AND
       Inmueble.nombreP = Limita.nombreP2 AND
       Inmueble.nombreZ = Limita.nombreZ2
       OR
       Limita.nombreP2 = PZ.nombreP AND
       Limita.nombreZ2 = PZ.nombreZ AND
       Inmueble.nombreP = Limita.nombreP AND
       Inmueble.nombreZ = Limita.nombreZ) AND
       Persona.codigo IN (1001,1011,1013)
       /*(SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT ALL FROM PrefiereZona AS PZ2,Inmueble AS I2
                                                     WHERE Cliente.codigo = PZ2.codigoCliente AND
                                                          I2.nombreP = PZ2.nombreP AND
                                                          I2.nombreZ = PZ2.nombreZ AND
                                                          NOT EXISTS (SELECT ALL FROM Visitas WHERE
                                                                      Visitas.codigoCliente = Cliente.codigo AND
                                                                      Visitas.codigoInmueble = I2.codigo)));
*/

/*
SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT ALL FROM PrefiereZona AS PZ2,Inmueble AS I2
                                              WHERE Cliente.codigo = PZ2.codigoCliente AND
                                                   I2.nombreP = PZ2.nombreP AND
                                                   I2.nombreZ = PZ2.nombreZ AND
                                                   NOT EXISTS (SELECT ALL FROM Visitas WHERE
                                                               Visitas.codigoCliente = Cliente.codigo AND
                                                               Visitas.codigoInmueble = I2.codigo))
*/
