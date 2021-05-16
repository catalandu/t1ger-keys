# T1GER KEYS

### Contact
Author: T1GER#9080
Discord: https://discord.gg/FdHkq5q

### Requirements
- progressBar

You can get my version of `progressBar` from my github repository:
https://github.com/Hamza8700/fivem_scripts

### Installation
1) Drag & drop the folder into your `resources` server folder.
2) Configure the config file to your liking.
3) Import the SQL file into your database.
4) Add `start t1ger_keys` to your server config.

### Showcase
- https://streamable.com/hfs6yu

### Utils
Change Police Blip type and other things in utils.
Also the dispatch message for armed grand theft auto is also there.

### Protection
Do not touch or delete the protection folder. This is security. Upon deleting/corruption these, script will not work.

### Commands
/carsearch 
- works only when you've stolen a vehicle from an NPC by threatening with a gun

/hotwire
- works only if you've successfully lockpicked into a vehicle

/givekeys
- Opens a menu, where u can choose key to give to closest player

/carmenu
- Opens car menu

### Registering a key to a car
call this event: 
TriggerServerEvent('t1ger_keys:registerNewKey', plate)