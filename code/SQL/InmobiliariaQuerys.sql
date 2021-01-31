SELECT USER pablo alonso;
USE Inmobiliaria;
/*a*/
/*Nombres de los dueños de los inmuebles*/
/*SELECT DISTINCT apellido
FROM Persona, PoseeInmueble
WHERE Persona.codigo = PoseeInmueble.codigoProp;*/



/*b*/
/*códigos de los inmuebles cuyo precio está en el intervalo 600.000 a 700.000
inclusive.*/
/*SELECT codigo
FROM Inmueble
WHERE precio >= 600000 AND precio <= 800000
ORDER BY codigo ASC;
*/



/*c*/
/*Obtener los nombres de los clientes que prefieran inmuebles sólo en la zona Norte de Santa Fe.*/

SELECT DISTINCT nombre
FROM Persona,PrefiereZona AS PZ
WHERE EXISTS( SELECT ALL FROM PrefiereZona WHERE  nombreZ = "Norte" AND nombreP = "Santa Fe" AND codigo = codigoCliente)
    /*   AND
       NOT EXISTS (SELECT ALL FROM PrefiereZona WHERE  (nombreZona <> "Norte" OR nombrePoblacion <> "Santa Fe") AND codigo = codigoCliente);*/
