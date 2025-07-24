### `/app/custom` – Custom Configuration

This directory is used for **custom configuration files** that can modify `authserver.conf` and `worldserver.conf` without manually editing them.

- Place one or more configuration files in this directory.
- Each line in a file must follow the format:

  Key = Value

  Example:
  AllowTwoSide.Interaction.Guild = 1  
  AuctionHouseBot.Seller.Enabled = 1

- To apply the changes, run:

  make apply_custom_config              (applies all files in the directory)  
  make apply_custom_config FILE=world.conf   (applies only the specified file)

  to apply without make use: 
  docker compose run --rm utility /bin/commands/apply_custom_config.sh /app/custom/world.conf

 

All values defined in these files will overwrite existing values in the configuration files.

Example configs you can create:
- **crossfaction.conf**: Enables cross-faction play (group, guild, chat, mail, auction house).
- **ahbot.conf**: Activates and tunes the Auction House Bot.

This system allows you to easily customize your server behavior without touching the default configuration files.