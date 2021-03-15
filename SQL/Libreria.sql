CREATE USER pablo alonso;
SELECT USER pablo alonso;
CREATE DATABASE Libreria;
USE Libreria;
DROP ALL TABLE;



CREATE TABLE Autor (
    Nombre String,
    Apellido String,
    Nacionalidad String,
    Residencia String,
    Id Int,
     KEY (Id)
);

CREATE TABLE Libro (
    Isbn String,
    Titulo String,
    Editorial String,
    Precio Int,
     KEY (Isbn)
);



CREATE TABLE Escribe (
    Año Date,
    Id Int,
    Isbn String,
    KEY (Id, Isbn, Año),
    FOREIGN KEY (Id) REFERENCE Autor (Id),
    FOREIGN KEY (Isbn) REFERENCE Libro (Isbn)
    ON DELETE CASCADE ON UPDATE CASCADE
);


INSERT Autor ("Damian", "Ariel", "Argentina", "Rosario",1);
INSERT Autor ("Pablo", "Luis", "Argentina", "Venado",2);
INSERT Autor ("Abelardo", "Castillo", "Argentina", "Rosario",3);
INSERT Autor ("Jose", "Saramago", "Portugal", "Lisboa",4);
INSERT Autor ("Bram", "Stoker", "Inglaterra", "Londres",5);
INSERT Autor ("Pepito", "Lopes", "Brasil", "San Pablo",6);


INSERT  Libro ("0001", "Ensayo Sobre la Ceguera", "EMPA", 800);
INSERT  Libro ("0002", "Dracula", "EMPA", 800);
INSERT  Libro ("0003", "Calculo I", "UNR", 300);
INSERT  Libro ("0004", "Sistemas", "UNR", 100);
INSERT  Libro ("0005", "Aventuras", "UNR", 100);

INSERT  Escribe (2000-1-1,4, "0001");
INSERT  Escribe (1897-1-1,5, "0002");
INSERT  Escribe (1995-1-1,5, "0004");
INSERT  Escribe (1998-1-1,6, "0005");
