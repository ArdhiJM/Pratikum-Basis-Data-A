-- =============================================
-- DATABASE: JAMS_243040002
-- =============================================
CREATE DATABASE JAMS_243040002;
GO

USE JAMS_243040002;
GO

-- =============================================
-- TABEL MAHASISWA
-- =============================================

-- Membuat tabel Mahasiswa
CREATE TABLE Mahasiswa (
    Nama VARCHAR(100),
    Npm CHAR(9),
    Alamat VARCHAR(100)
);
GO

-- Menambahkan kolom Kelas
ALTER TABLE Mahasiswa
ADD Kelas CHAR(8);
GO

-- Mengubah kolom Alamat
ALTER TABLE Mahasiswa
ALTER COLUMN Alamat VARCHAR(50);
GO

-- Mengecek struktur tabel
EXEC sp_help 'Mahasiswa';
GO

-- =============================================
-- TABEL DOSEN
-- =============================================

-- Membuat tabel Dosen
CREATE TABLE Dosen (
    Nama VARCHAR(100) NOT NULL,
    Nip CHAR(9) UNIQUE,
    Alamat VARCHAR(100),
    Prodi VARCHAR(100)
);
GO

EXEC sp_help 'Dosen';
GO

-- Menghapus kolom Alamat
ALTER TABLE Dosen
DROP COLUMN Alamat;
GO

-- =============================================
-- CONSTRAINT PADA TABEL MAHASISWA
-- =============================================

-- Menambahkan constraint UNIQUE pada Npm
ALTER TABLE Mahasiswa
ADD CONSTRAINT UQ_Npm_Mahasiswa UNIQUE (Npm);
GO

-- Menambahkan kolom Nilai
ALTER TABLE Mahasiswa
ADD Nilai INT;
GO

-- Menambahkan constraint DEFAULT pada Nilai
ALTER TABLE Mahasiswa
ADD CONSTRAINT DF_Nilai_Mahasiswa DEFAULT 100 FOR Nilai;
GO

EXEC sp_help 'Mahasiswa';
GO

-- =============================================
-- DATABASE: Toko_pedia
-- =============================================
CREATE DATABASE Toko_pedia;
GO

USE Toko_pedia;
GO

-- =============================================
-- TABEL PELANGGAN
-- =============================================
CREATE TABLE Pelanggan (
    PelangganID INT IDENTITY(1,1) PRIMARY KEY,
    NamaPelanggan VARCHAR(100) NOT NULL,
    Email VARCHAR(100),
    Telepon VARCHAR(20),
    Alamat VARCHAR(255)
);
GO

-- =============================================
-- TABEL PRODUK (Harus dibuat sebelum PesananDetail)
-- =============================================
CREATE TABLE Produk (
    ProdukID INT NOT NULL,
    NamaProduk VARCHAR(100),
    Harga DECIMAL(10, 2)
);
GO

-- =============================================
-- TABEL PESANAN HEADER
-- =============================================
CREATE TABLE PesananHeader (
    PesananID INT IDENTITY(1,1) PRIMARY KEY,
    TanggalPesanan DATETIME2 NOT NULL,
    PelangganID INT NOT NULL,
    StatusPesanan VARCHAR(10) NOT NULL,
    
    -- Constraint FOREIGN KEY
    CONSTRAINT FK_Pesanan_Pelanggan
        FOREIGN KEY (PelangganID) REFERENCES Pelanggan(PelangganID),
    
    -- Constraint CHECK
    CONSTRAINT CHK_StatusPesanan
        CHECK (StatusPesanan IN ('Baru', 'Proses', 'Selesai'))
);
GO

EXEC sp_help 'Pelanggan';
EXEC sp_help 'PesananHeader';
GO

-- =============================================
-- LATIHAN 4: ALTER TABLE (Modifikasi Struktur)
-- =============================================

-- 1. Menambahkan Primary Key ke tabel Produk
ALTER TABLE Produk
ALTER COLUMN ProdukID INT NOT NULL;
GO

ALTER TABLE Produk
ADD CONSTRAINT PK_Produk PRIMARY KEY (ProdukID);
GO

-- 2. Menambahkan kolom NoTelepon ke tabel Pelanggan
ALTER TABLE Pelanggan
ADD NoTelepon VARCHAR(20) NULL;
GO

-- 3. Mengubah kolom Harga di Produk agar wajib diisi
ALTER TABLE Produk
ALTER COLUMN Harga DECIMAL(10, 2) NOT NULL;
GO

-- Cek struktur tabel
EXEC sp_help 'Produk';
EXEC sp_help 'Pelanggan';
GO

-- =============================================
-- LATIHAN 5: DROP TABLE dan Manajemen Dependensi
-- =============================================

-- 1. Membuat tabel PesananDetails
CREATE TABLE PesananDetail (
    PesananDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PesananID INT NOT NULL,
    ProdukID INT NOT NULL,
    Jumlah INT NOT NULL,
    
    CONSTRAINT FK_Detail_Header
        FOREIGN KEY (PesananID) REFERENCES PesananHeader(PesananID),
    CONSTRAINT FK_Detail_Produk
        FOREIGN KEY (ProdukID) REFERENCES Produk(ProdukID)
);
GO

-- 2. Mencoba menghapus tabel Pelanggan (akan GAGAL karena ada FK)
PRINT 'Mencoba menghapus Pelanggan... (Harusnya Gagal)';
-- DROP TABLE Pelanggan;
-- Error: Cannot drop because it is referenced by FK constraint
GO

-- 3. Mencoba menghapus tabel PesananHeader (akan GAGAL karena ada FK)
PRINT 'Mencoba menghapus PesananHeader... (Harusnya Gagal)';
-- DROP TABLE PesananHeader;
-- Error: Cannot drop because it is referenced by FK constraint
GO

-- 4. Menghapus tabel secara berurutan (dari child ke parent)
PRINT 'Menghapus PesananDetail (tabel anak) terlebih dahulu...';
DROP TABLE PesananDetail;
GO

PRINT 'Menghapus PesananHeader (tabel induk dari detail)...';
DROP TABLE PesananHeader;
GO

PRINT 'Menghapus Pelanggan (tabel induk dari header)...';
DROP TABLE Pelanggan;
GO

PRINT 'Menghapus Produk...';
DROP TABLE Produk;
GO

PRINT 'Semua tabel berhasil dihapus.';
GO