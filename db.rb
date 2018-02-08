require 'sqlite3'
require 'colorize'

$db = SQLite3::Database.open 'topo.sqlite3'

ele_count = $db.get_first_value("SELECT COUNT(*) FROM elevations;")
peak_count = $db.get_first_value("SELECT COUNT(*) FROM peaks;")
puts "DB contains #{ele_count} elevations and #{peak_count} peaks"