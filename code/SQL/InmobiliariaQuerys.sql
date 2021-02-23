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

/*
SELECT DISTINCT nombre
FROM Persona AS p JOIN (SELECT vendedor FROM (SELECT codigo AS cod FROM Persona JOIN PrefiereZona ON codigo = codigoCliente WHERE nombreP = "Rosario" AND nombreZ = "Centro") AS s1 JOIN Cliente ON s1.cod = Cliente.codigo ) AS s2
             ON vendedor = codigo
*/

/*SELECT nombre FROM Persona JOIN (SELECT vendedor FROM Cliente WHERE codigo IN (SELECT vendedor FROM Cliente)) AS s1 ON codigo = vendedor;*/

/*SELECT vendedor FROM Cliente AS C WHERE codigo IN (SELECT vendedor AS codVendedor FROM Cliente)*/





/*SELECT Persona.nombre, Persona.apellido, Inmueble.codigo, Inmueble.nombreZ, Inmueble.precio*/
/*FROM   Persona, PrefiereZona, Limita, Inmueble*/
/*WHERE  Persona.codigo = PrefiereZona.codigoCliente AND*/ /*Zonas preferidas*/
  /*     (Limita.nombreP = PrefiereZona.nombreP AND*/ /*Zonas limitrofes a las preferidas*/
       /*Limita.nombreZ = PrefiereZona.nombreZ AND*/
       /*Inmueble.nombreP = Limita.nombreP2 AND*/ /*Inmuebles en zonas limitrofes*/
       /*Inmueble.nombreZ = Limita.nombreZ2*/
       /*OR
       Limita.nombreP2 = PrefiereZona.nombreP AND*/ /*Zonas limitrofes a las preferidas*/
       /*Limita.nombreZ2 = PrefiereZona.nombreZ AND*/
       /*Inmueble.nombreP = Limita.nombreP AND*/ /*Inmuebles en zonas limitrofes*/
       /*Inmueble.nombreZ = Limita.nombreZ)*/


       /*
       AND
       Persona.codigo IN  Chequear que esta persona sea un cliente que visitó todos los inmuebles en sus zonas favoritas
       (SELECT codigo FROM Cliente WHERE NOT EXISTS (SELECT ALL FROM PrefiereZona,Inmueble
                                                     WHERE Cliente.codigo = PrefiereZona.codigoCliente AND
                                                          Inmueble.nombreP = PrefiereZona.nombreP AND
                                                          Inmueble.nombreZ = PrefiereZona.nombreZ AND
                                                          NOT EXISTS (SELECT ALL FROM Visitas WHERE
                                                                      Visitas.codigoCliente = Cliente.codigo AND
                                                                      Visitas.codigoInmueble = Inmueble.codigo)));*/
