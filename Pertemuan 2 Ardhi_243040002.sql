--membuat database--
CREATE DATABASE Toko_Retail_DB;

USE Toko_Retail_DB;
GO

--buat table kategori
CREATE TABLE KategoriProduk (
	kategoriID INT IDENTITY(1,1) PRIMARY KEY,
	NamaKategori VARCHAR(100) NOT NULL UNIQUE
);
GO

EXEC sp_help 'KategoriProduk';

--buat table produk--
CREATE TABLE Produk (
	ProdukID INT IDENTITY(1001,1) PRIMARY KEY,
	SKU VARCHAR(20) NOT NULL UNIQUE,
	NamaProduk VARCHAR(150) NOT NULL,
	Harga DECIMAL(10, 2) NOT NULL,
	Stok INT NOT NULL,
	KategoriID INT NULL,  --boleh NULL jika belum dikategorikan
	
	CONSTRAINT CHK_HargaPositif CHECK (Harga >= 0 ),
	CONSTRAINT CHK_StokPositif CHECK (Stok >= 0 ),
	CONSTRAINT FK_Produk_Kategori
		FOREIGN KEY (KategoriID)
		REFERENCES KategoriProduk(KategoriID)
 );

 EXEC sp_help 'Produk';

 /* 3. Buat tabel Pelanggan */ 
CREATE TABLE Pelanggan ( 
    PelangganID INT IDENTITY(1,1) PRIMARY KEY, 
    NamaDepan VARCHAR(50) NOT NULL, 
    NamaBelakang VARCHAR(50) NULL, 
    Email VARCHAR(100) NOT NULL UNIQUE, 
    NoTelepon VARCHAR(20) NULL,
	TanggalDaftar DATE DEFAULT GETDATE() 
);

/* 4. Buat tabel Pesanan Header */ 
CREATE TABLE PesananHeader ( 
    PesananID INT IDENTITY(50001, 1) PRIMARY KEY, 
    PelangganID INT NOT NULL, 
    TanggalPesanan DATETIME2 DEFAULT GETDATE(), 
    StatusPesanan VARCHAR(20) NOT NULL, 
     
    CONSTRAINT CHK_StatusPesanan CHECK (StatusPesanan IN ('Baru', 'Proses', 
'Selesai', 'Batal')), 
    CONSTRAINT FK_Pesanan_Pelanggan  
        FOREIGN KEY (PelangganID)  
        REFERENCES Pelanggan(PelangganID) 
        -- ON DELETE NO ACTION (Default) 
); 
GO 
 
/* 5. Buat tabel Pesanan Detail */ 
CREATE TABLE PesananDetail ( 
    PesananDetailID INT IDENTITY(1,1) PRIMARY KEY, 
    PesananID INT NOT NULL, 
    ProdukID INT NOT NULL, 
    Jumlah INT NOT NULL, 
    HargaSatuan DECIMAL(10, 2) NOT NULL, -- Harga saat barang itu dibeli 
 
    CONSTRAINT CHK_JumlahPositif CHECK (Jumlah > 0), 
    CONSTRAINT FK_Detail_Header 
        FOREIGN KEY (PesananID)  
        REFERENCES PesananHeader(PesananID) 
        ON DELETE CASCADE,  -- Jika Header dihapus, detail ikut terhapus 
     
    CONSTRAINT FK_Detail_Produk 
        FOREIGN KEY (ProdukID)  
        REFERENCES Produk(ProdukID) 
); 
GO


PRINT 'Database Toko_Retail_DB dan semua tabel berhasil dibuat';



 /*Memasukkan data Pelanggan */ -- Sintaks eksplisit (Best Practice) 
INSERT INTO Pelanggan (NamaDepan, NamaBelakang, Email, NoTelepon)
VALUES 
('Erik','Adia','erik.adia@email.com','08123456789'),
('Shaka','Juts','shaka.juts@email.com',NULL);

EXEC sp_help 'Pelanggan';


/* 2. Memasukkan data Kategori (Multi-row) */ 
INSERT INTO KategoriProduk (NamaKategori)
VAlUES
('Elektronik'),
('Pakaian'),
('Buku');


EXEC sp_help 'KategoriProduk';

/* 3. Verifikasi Data */ 
PRINT 'Data Pelanggan:';
SELECT * FROM Pelanggan;

PRINT 'Data Kategori:';
SELECT * FROM KategoriProduk;

/* Masukkan data Produk yang merujuk ke KategoriID */
INSERT INTO Produk (SKU, NamaProduk, Harga, Stok, KategoriID)
VALUES
('ELEC-001','Laptop Asus TUF', 12000000.00, 50, 1),
('PAK-001','kaos Polos Hitam', 75000.00, 200, 2),
('BUK-001', 'Dasar-Dasar SQL', 120000.00, 100, 3);

UPDATE Produk
SET NamaProduk= 'Kaos Polos Hitam'
WHERE  KategoriID = 2;


/* Verifikasi Data */ 
PRINT 'Data Produk:'; 
SELECT P.*, K.NamaKategori 
FROM Produk AS P 
JOIN KategoriProduk AS K ON P.KategoriID = K.KategoriID; 


/* Cek data SEBELUM di-update */ 
SELECT * FROM Pelanggan WHERE PelangganID = 2;

BEGIN TRANSACTION; --Mulai zona aman

UPDATE Pelanggan
SET NoTelepon = '082233445566'
WHERE PelangganID = 2;

SELECT * FROM Pelanggan WHERE PelangganID = 2;

-- Jika sudah yakin, jadikan permanen 
COMMIT TRANSACTION;

SELECT * FROM Pelanggan WHERE PelangganID = 2;


PRINT 'Data Elektronik SEBELUM Update:';


USE Toko_Retail_DB; 


--Update Harga semua produk di KategoriID 1.
PRINT 'Data Elektronik SEBELUM Update:';
SELECT * FROM Produk WHERE KategoriID = 1 ;

BEGIN TRANSACTION;

UPDATE Produk
SET Harga = Harga * 1.10 -- operasi aritmatika pada nilai kolom '
WHERE KategoriID = 1;

print 'Data Elektronik SETELAH Update (BELUM di-COMMIT):';

select * from Produk where KategoriID = 1 ;

--cek apakah ada kesalahan? jika tidak, commit.
commit transaction;



--DELETE (SATU BARIS SPESIFIK)
print 'Data Produk SEBELUM Delete:';
select * from Produk where SKU = 'BUK-001';

begin transaction;

delete from Produk
where SKU = 'BUK-001';

print 'Data Produk SETELAH Delete (Belum di-COMMIT):';
select * from Produk where SKU = 'BUK-001'; --Harusnya kosong

commit transaction;

-- Bencana & ROLLBACK (Latihan Paling Penting)
/* Cek data stok. HARUSNYA 50 dan 200 */
print 'data stok sebelum bencana:';
select SKU, NamaProduk, Stok from Produk;

begin transaction; --WAJIB! ini adalah jaringan pengaman kita.

--Bencana Terjadi : Lupa Klausa WHERE!
update Produk
set Stok = 0;

/* Cek data setelah bencana. SEMUA STOK JADI 0! */
PRINT 'Data Stok SETELAH Bencana (PANIK!):';
SELECT SKU, NamaProduk, Stok FROM Produk;

-- JANGAN COMMIT! BATALKAN!
print 'Melakukan Rollback...';
rollback transaction;

/* Cek data setelah diselamatkan */
PRINT 'Data Stok SETELAH di-ROLLBACK (AMAN):';
SELECT SKU, NamaProduk, Stok FROM Produk;



--Latihan 8: DELETE dan Pelanggaran FOREIGN KEY

/* 1. Buat 1 pesanan untuk budi */
insert into PesananHeader (PelangganID, StatusPesanan)
values (1, 'Baru');

PRINT 'Data Pesanan Budi:';
SELECT * FROM PesananHeader WHERE PelangganID = 1;
GO

/* 2. Coba hapus Pelanggan Budi (PelangganID 1) */
print 'mencoba hapus Budi...';
begin transaction;

delete from Pelanggan
where PelangganID = 1 ;
--perintah ini akan gagal--

rollback transaction;--batalkan (walaupun sudah gagal)



--Latihan 9 (Tantangan): INSERT ... SELECT
create table ProdukArsip (
    ProdukID int primary key, -- tanpa IDENTITY
    SKU varchar(20) not null,
    NamaProduk varchar(150) not null,
    Harga decimal(10, 2) not null,
    TanggalArsip date default getdate()
);

print 'melihat tabel ProdukArsip'
select * from ProdukArsip;

begin transaction;

/* 2. Habiskan stok Kaos (SKU PAK-001) */
update Produk set Stok = 0 where sku = 'PAK-001';

/* 3. Salin data dari Produk ke ProdukArsip (INSERT ... SELECT) */
insert into ProdukArsip (ProdukID, SKU, NamaProduk, Harga)
select ProdukID, SKU, NamaProduk, Harga
from Produk
where Stok = 0;

/* 4. Hapus data yang sudah diarsip dari tabel Produk */
DELETE FROM Produk
WHERE Stok = 0;

/* Verifikasi */
PRINT 'Cek Produk Aktif (Kaos harus hilang):';
SELECT * FROM Produk;

PRINT 'Cek Produk Arsip (Kaos harus ada):';
SELECT * FROM ProdukArsip;

--jika yakin, commit
commit transaction;