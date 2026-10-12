-- 1. Crear la base de datos y seleccionarla
CREATE DATABASE IF NOT EXISTS db_streamers 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE db_streamers;

-- 2. Crear la tabla de Idiomas (Catálogo 3FN)
CREATE TABLE languages (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3. Crear la tabla de Videojuegos (Catálogo 3FN)
CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    game_name VARCHAR(150) NOT NULL UNIQUE
);

-- 4. Crear la tabla principal de Creadores
CREATE TABLE streamers (
    streamer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    language_id INT NOT NULL,
    total_followers BIGINT DEFAULT 0,
    total_views BIGINT DEFAULT 0,
    active_days_per_week DECIMAL(4,2) DEFAULT 0.00,
    avg_viewers_per_stream INT DEFAULT 0,
    CONSTRAINT fk_streamer_language 
        FOREIGN KEY (language_id) 
        REFERENCES languages(language_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- 5. Crear la tabla intermedia para los juegos principal y secundario
CREATE TABLE stream_juego (
    streamer_id INT NOT NULL,
    game_id INT NOT NULL,
    role ENUM('Main', 'Secondary') NOT NULL,
    PRIMARY KEY (streamer_id, role),
    CONSTRAINT fk_sj_streamer 
        FOREIGN KEY (streamer_id) 
        REFERENCES streamers(streamer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_sj_game 
        FOREIGN KEY (game_id) 
        REFERENCES games(game_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
