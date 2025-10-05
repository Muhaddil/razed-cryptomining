Config = {}

Config.CryptoMinerProp = {
    `prop_laptop_01a`, -- Example
    `v_corp_servercln`
}

Config.SellCryptoEnabled = true -- Set to false to disable the 'sellcrypto' command.

-- If one of these have been changed, you must change both to not confuse players.
Config.CryptoWithdrawalFeeShown = '10' -- This is a percentage shown the the ox_lib menu - e.g 10 = 10%
Config.CryptoWithdrawalFee = '0.90'    -- This is a percentage of the fee when withdrawing the crypto - e.g 0.90 = 10%

Config.Target = 'ox'                   -- 'qb' or 'ox' depending on the target you use
Config.FrameWork = 'auto'              -- Framework being used (auto, esx or qb)
Config.ESXVer = 'new'                  -- ESX version (new or old)
Config.Inventory = 'ox'                -- 'qb', 'esx' or 'ox' depending on the inventory you use

Config.Crypto = 'lb-phone'             -- 'qb' | 'renewed-phone' | 'lb-phone'
Config.EnableCryptoSellCommand = false -- If you want to have the /sellcrypto command enabled
Config.RenewedCryptoType = "gne"       -- Only for renewed-phone "gne", "shung", "xcoin", "lme"
Config.LBPhoneCryptoType =
"ethereum"                             -- Only for lb-phone: "bitcoin", "ethereum", "tether", "binancecoin", "usd-coin", "ripple", "binance-usd", "cardano", "dogecoin", "solana", "shiba-inu", "polkadot", "litecoin", "bitcoin-cash"

Config.Email = true                    -- if true, it will send the player the emails, if false it wont send the emails
Config.PurchaseEmailSender = 'Jonathan Sanders'
Config.PurchaseEmailSubject = 'New Crypto Miner'
Config.PurchaseEmailText =
'Congrats on the crypto miner. Want some info? The default GTX 480 is very slow, I reccomend to install a newer and more powerfull graphics card for faster mining speeds. This industry can be very lucriticve and volatile. Good luck, Johnny'

Config.gpuEmailSender = 'Jonathan Sanders'
Config.gpuEmailSubject = 'New Graphics Card'
Config.gpuEmailText =
'Congrats on the new graphics card. Make the most out of it, it is one profitable side hustle or buisness. Congrats, Johnny'

Config.Price = {
    ['Stage 1'] = 85000, -- Price to buy the crypto miner
}
