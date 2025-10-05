![RazedCryptoMining23](https://github.com/planeklm/razed-cryptomining/assets/91488137/2974fd19-33f9-409a-a1a1-194d1590237c)

**Hello FiveM community!👋**\
We have created a crypto mining system for multiple frameworks. The overall idea for this script is that I have yet to find a free crypto miner which functions. Thank you to everybody who contributed to this project, I am very proud of what we have created!

# Features
* **8 graphics card upgrades** - If your players are needing an upgrade, they can choose 7 different tiers of graphics cards, from the GTX 480 to the RTX 5090.
* **Withdraw crypto with a set fee** - When the coins are withdrew, you can set a fee (default 10%).
*  **Crypto miner in houses** - With different housing scripts, you can place down the server rack prop to use the miner.
* **Multiple framework support** - Now supports ESX (both new and old versions) and QB-Core frameworks with automatic detection.
* **Multiple phone integrations** - Compatible with qb-phone, renewed-phone, and lb-phone with configurable crypto types.
* **Multiple inventory support** - Works with QB, ESX, and ox inventory systems.
* **Multiple target systems** - Compatible with both qb-target and ox_target.
* **Email notification system** - Configurable email notifications for purchases and upgrades.
* **Crypto selling command** - Optional /sellcrypto command that can be enabled/disabled.
* **Lightweight and optimized** - We've tried to make the most lightweight and optimized script, this means it can run on virtually any server without sacrificing performance.
* **Fully open-source & customizable** - Want to add more graphics cards? Or help us expand this script? We've made our script in the main idea of community collaboration. Not sure what to do? We've made our config file with as many options to suit your server.
* **Configurable prices, props, fees and emails**

# Preview
[![](https://i.imgur.com/USdx6mP.png)](https://youtu.be/ohPHNCPLdt4)

# Installation
* Drag and drop `razed-cryptomining`
* In your `server.cfg` add `ensure razed-cryptomining`
* Execute the `cryptomining.sql` into your database
* Configure your settings in `config.lua` to match your server's framework and preferences

# Recomendations From Us
* If using `ps-housing` or `qb-housing`, we recommend to change the price of the server rack prop to the appropriate price of a mining rig. You can use the server rack prop as a mining rig for houses or warehouses!

# Items & Images
**❤️ to Markow (amsali22) for making 99% this!**\
[razed-crypto-imgs](https://github.com/amsali22/razed-crypto-imgs)

* Drag and Drop the `images` to your inventory `images` folder.

* Add items from `items.md` to your `qb-core/shared/items.lua` file or ox_inventory items file.


# Dependencies
[qb-core](https://github.com/qbcore-framework/qb-core) or [es_extended (ESX)](https://github.com/esx-framework/esx-legacy)\
[interact-sound](https://github.com/qbcore-framework/interact-sound)\
[ox_lib](https://github.com/overextended/ox_lib)\
[oxmysql](https://github.com/overextended/oxmysql)

One of the following phone systems:
* [qb-crypto](https://github.com/qbcore-framework/qb-crypto)
* [renewed-phone](https://github.com/Renewed-Scripts/qb-phone)
* [lb-phone](https://github.com/lbphone/lb-phone)

One of the following target systems:
* [qb-target](https://github.com/qbcore-framework/qb-target)
* [ox_target](https://github.com/overextended/ox_target)

# Configuration Options
The script now includes extensive configuration options in `config.lua`:
* Framework selection (auto-detection, ESX, QB)
* ESX version selection (new or old)
* Inventory system selection (QB, ESX, ox)
* Phone integration options (QB, renewed-phone, lb-phone)
* Crypto type selection for different phone systems
* Email notification settings
* Crypto withdrawal fee configuration
* Crypto selling command toggle

# Credits
**Original Creators:**\
[planeklm (KLM)](https://github.com/planeklm)\
[LeSiiN](https://github.com/LeSiiN)\
[Markow](https://github.com/amsali22)