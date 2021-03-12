SELECT USER pablo alonso;
USE Libreria;

/*
UPDATE Autor SET
    Residencia = "Buenos Aires"
    WHERE Nombre = "Abelardo" AND Apellido = "Castillo";
*/

/*
UPDATE Libro SET
      Precio = Precio + (Precio/10)
      WHERE Editorial = "UNR";
*/


DELETE Libro
	WHERE EXISTS (SELECT ALL FROM Escribe WHERE Libro.Isbn = Escribe.Isbn AND Año = 1998-1-1);
