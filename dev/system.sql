----------------------------------------------------------------
--
--  system.sql
--  The schema for all the read only data in the game.
--
--  Written in 2012 by Brendan A R Sechter <bsechter@sennue.com>
--
--  To the extent possible under law, the author(s) have
--  dedicated all copyright and related and neighboring rights
--  to this software to the public domain worldwide. This
--  software is distributed without any warranty.
--
--  You should have received a copy of the CC0 Public Domain
--  Dedication along with this software. If not, see
--  <http://creativecommons.org/publicdomain/zero/1.0/>.
--
----------------------------------------------------------------

----------------------------------------------------------------
-- Schema
----------------------------------------------------------------

-- Splash Screens
DROP TABLE IF EXISTS splash_screens;
CREATE TABLE IF NOT EXISTS splash_screens (
  resolution   INTEGER,
  portrait     INTEGER,
  priority     INTEGER,
  image        VARCHAR ( 32 ),
  display_time REAL,
  fade_time    REAL,
  PRIMARY KEY ( priority, portrait, resolution )
);

-- Loading Screens
DROP TABLE IF EXISTS loading_screens;
CREATE TABLE IF NOT EXISTS loading_screens (
  resolution   INTEGER,
  portrait     INTEGER,
  image        VARCHAR ( 32 ),
  PRIMARY KEY ( resolution, portrait, image )
);

-- Slide Show
DROP TABLE IF EXISTS slide_show;
CREATE TABLE IF NOT EXISTS slide_show (
  priority     INTEGER,
  resolution   INTEGER,
  image        VARCHAR ( 32 ),
  PRIMARY KEY ( priority, resolution, image )
);

-- Supported Screen Resolutions
DROP TABLE IF EXISTS texture_resolution_list;
CREATE TABLE IF NOT EXISTS texture_resolution_list (
  resolution INTEGER,
  PRIMARY KEY ( resolution )
);
DROP VIEW IF EXISTS max_texture_resolution;
CREATE VIEW IF NOT EXISTS max_texture_resolution AS
        SELECT MAX ( resolution ) AS resolution FROM texture_resolution_list;
DROP VIEW IF EXISTS min_texture_resolution;
CREATE VIEW IF NOT EXISTS min_texture_resolution AS
        SELECT MIN ( resolution ) AS resolution FROM texture_resolution_list;

----------------------------------------------------------------
-- Data
----------------------------------------------------------------

----------------------------------------------------------------
-- Splash Screens
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 0, 0, "fade"                     );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 0, 1, "splash_sennue_horizontal" );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 0, 2, "splash_moai_horizontal"   );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 0, 9, "fade"                     );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 1, 0, "fade"                     );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 1, 1, "splash_sennue_vertical"   );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 1, 2, "splash_moai_vertical"     );
INSERT INTO splash_screens ( portrait, priority, image ) VALUES ( 1, 9, "fade"                     );

-- Splash Screen Dynamically Generated Values
UPDATE splash_screens SET display_time = 2.00, fade_time = 0.50 WHERE 'fade' <> image;
UPDATE splash_screens SET display_time = 0.00, fade_time = 0.50 WHERE 'fade' = image;
UPDATE splash_screens SET resolution = 2048;
INSERT INTO splash_screens ( resolution, portrait, priority, image, display_time, fade_time )
  SELECT 1024 AS resolution, portrait, priority, image, display_time, fade_time FROM splash_screens
  UNION
  SELECT  512 AS resolution, portrait, priority, image, display_time, fade_time FROM splash_screens;
UPDATE splash_screens SET image = image || '@' || resolution WHERE 'fade' <> image;
UPDATE splash_screens SET image = image || '.png';
----------------------------------------------------------------

----------------------------------------------------------------
-- Loading Screens
INSERT INTO loading_screens ( portrait, image ) VALUES ( 0, "loading" );
INSERT INTO loading_screens ( portrait, image ) VALUES ( 1, "loading" );

-- Loading Screen Dynamically Generated Values
UPDATE loading_screens SET resolution = 2048;
INSERT INTO loading_screens ( resolution, portrait, image )
  SELECT 1024 AS resolution, portrait, image FROM loading_screens
  UNION
  SELECT  512 AS resolution, portrait, image FROM loading_screens;
UPDATE loading_screens SET image = image || '@' || resolution || '.png';
----------------------------------------------------------------

----------------------------------------------------------------
-- Slide Show
INSERT INTO slide_show ( priority, image ) VALUES ( 1, "slide_1" );
INSERT INTO slide_show ( priority, image ) VALUES ( 2, "slide_2" );
INSERT INTO slide_show ( priority, image ) VALUES ( 3, "slide_3" );

-- Slide Show Dynamically Generated Values
UPDATE slide_show SET resolution = 2048;
INSERT INTO slide_show ( resolution, priority, image )
  SELECT 1024 AS resolution, priority, image FROM slide_show
  UNION
  SELECT  512 AS resolution, priority, image FROM slide_show;
UPDATE slide_show SET image = image || '@' || resolution || '.png';
----------------------------------------------------------------

----------------------------------------------------------------
-- List of Texture Resolutions
INSERT INTO texture_resolution_list ( resolution ) VALUES ( 2048 );
INSERT INTO texture_resolution_list ( resolution ) VALUES ( 1024 );
INSERT INTO texture_resolution_list ( resolution ) VALUES (  512 );
----------------------------------------------------------------

