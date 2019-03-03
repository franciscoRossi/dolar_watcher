# dolar-watcher
Simple ruby script that parses the website http://www.dolarhoy.com and extracts the US dollar prices in ARS every 60 seconds and records the prices in a csv file.
It also support gnome notifications

## Running the script
- Running in silent mode (only write to stdout and csv file):
  `$ ruby ./src/main.rb`
- Running in desktop mode (GNOME notifications enabled):
  `$ ruby ./src/main.rb -n`
