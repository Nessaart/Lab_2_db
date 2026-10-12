const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const db = require('./services/mysql.service');

async function startDataIngestion() {
    const csvFilePath = path.join(__dirname, 'Streamers.csv');

    if (!fs.existsSync(csvFilePath)) {
        console.error(`File Streamers.csv not found at: ${csvFilePath}`);
        process.exit(1);
    }

    console.log('Reading Streamers.csv and processing ingestion...');
    let recordCounter = 0;

    const stream = fs.createReadStream(csvFilePath).pipe(csv());

    for await (const row of stream) {
        try {
            const name = row.NAME;
            const language = row.LANGUAGE;
            const mainGame = row.MOST_STREAMED_GAME;
            const secondGame = row['2ND_MOST_STREAMED_GAME'];
            const followers = parseInt(row.TOTAL_FOLLOWERS) || 0;
            const views = parseInt(row.TOTAL_VIEWS) || 0;
            const activeDays = parseFloat(row.ACTIVE_DAYS_PER_WEEK) || 0.0;
            const avgViewers = parseInt(row.AVG_VIEWERS_PER_STREAM) || 0;

            if (!name || !language) continue;

            await db.execute(
                `INSERT INTO languages (language_name) VALUES (?) ON DUPLICATE KEY UPDATE language_name = language_name`,
                [language]
            );
            const [langRows] = await db.execute(
                `SELECT language_id FROM languages WHERE language_name = ?`,
                [language]
            );
            const languageId = langRows[0].language_id;

            const [streamerResult] = await db.execute(
                `INSERT INTO streamers (name, language_id, total_followers, total_views, active_days_per_week, avg_viewers_per_stream) 
                 VALUES (?, ?, ?, ?, ?, ?)`,
                [name, languageId, followers, views, activeDays, avgViewers]
            );
            const streamerId = streamerResult.insertId;

            if (mainGame && mainGame.trim() !== '') {
                await db.execute(
                    `INSERT INTO games (game_name) VALUES (?) ON DUPLICATE KEY UPDATE game_name = game_name`,
                    [mainGame]
                );
                const [gameRows] = await db.execute(
                    `SELECT game_id FROM games WHERE game_name = ?`,
                    [mainGame]
                );
                const gameId = gameRows[0].game_id;

                await db.execute(
                    `INSERT INTO stream_juego (streamer_id, game_id, role) VALUES (?, ?, 'Main')`,
                    [streamerId, gameId]
                );
            }

            if (secondGame && secondGame.trim() !== '' && secondGame.toLowerCase() !== 'nan') {
                await db.execute(
                    `INSERT INTO games (game_name) VALUES (?) ON DUPLICATE KEY UPDATE game_name = game_name`,
                    [secondGame]
                );
                const [gameRows2] = await db.execute(
                    `SELECT game_id FROM games WHERE game_name = ?`,
                    [secondGame]
                );
                const gameId2 = gameRows2[0].game_id;

                await db.execute(
                    `INSERT INTO stream_juego (streamer_id, game_id, role) VALUES (?, ?, 'Secondary')`,
                    [streamerId, gameId2]
                );
            }

            recordCounter++;
            if (recordCounter % 100 === 0) {
                console.log(`Processed ${recordCounter} streamers...`);
            }

        } catch (err) {
            console.error(`Error inserting ${row.NAME}:`, err.message);
        }
    }

    console.log(`\nIngestion completed successfully! Total records inserted: ${recordCounter}`);
    process.exit(0);
}

startDataIngestion();