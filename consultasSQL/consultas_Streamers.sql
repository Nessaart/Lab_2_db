-- consulta1_Top 10 streamers
SELECT 
    s.name AS streamer, 
    l.language_name AS idioma, 
    s.total_followers, 
    s.total_views
FROM streamers s
JOIN languages l ON s.language_id = l.language_id
ORDER BY s.total_followers DESC
LIMIT 10;

-- consulta2_Estadísticas de visualizaciones
SELECT 
    l.language_name AS idioma, 
    COUNT(s.streamer_id) AS total_streamers,
    ROUND(AVG(s.total_views), 2) AS promedio_vistas,
    ROUND(AVG(s.active_days_per_week), 2) AS promedio_dias_activos
FROM languages l
JOIN streamers s ON l.language_id = s.language_id
GROUP BY l.language_name
ORDER BY total_streamers DESC;

-- consulta3_10 juegos principales mas transmitidos

SELECT 
    g.game_name AS videojuego, 
    COUNT(sj.streamer_id) AS total_streamers
FROM games g
JOIN stream_juego sj ON g.game_id = sj.game_id
WHERE sj.role = 'Main'
GROUP BY g.game_name
ORDER BY total_streamers DESC
LIMIT 10;

-- consulta4_Streamers con mayor promedio de espectadores por transmisión

SELECT 
    s.name AS streamer, 
    s.avg_viewers_per_stream AS espectadores_promedio, 
    s.total_followers, 
    l.language_name AS idioma
FROM streamers s
JOIN languages l ON s.language_id = l.language_id
ORDER BY s.avg_viewers_per_stream DESC
LIMIT 10;

-- consulta5_juegos evaluados por rol
SELECT 
    sj.role AS rol, 
    COUNT(sj.streamer_id) AS total_asignaciones
FROM stream_juego sj
GROUP BY sj.role;


-- consultas basicas 

-- WHERE
SELECT name, total_followers, active_days_per_week, total_views 
FROM streamers 
WHERE total_followers > 500000 AND active_days_per_week >= 4.0; 

-- JOIN
SELECT s.name AS streamer, l.language_name AS idioma, s.total_followers 
FROM streamers s
JOIN languages l ON s.language_id = l.language_id
LIMIT 10;

-- JOIN_3
SELECT 
    s.name AS streamer, 
    l.language_name AS idioma, 
    g.game_name AS juego_principal
FROM streamers s
JOIN languages l ON s.language_id = l.language_id
JOIN stream_juego sj ON s.streamer_id = sj.streamer_id
JOIN games g ON sj.game_id = g.game_id
WHERE sj.role = 'Main'
LIMIT 10;

-- GROUP BY
SELECT 
    l.language_name AS idioma, 
    COUNT(s.streamer_id) AS total_streamers
FROM languages l
JOIN streamers s ON l.language_id = s.language_id
GROUP BY l.language_name
ORDER BY total_streamers DESC;

