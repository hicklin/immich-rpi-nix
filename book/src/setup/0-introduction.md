# Setup

The following steps setup a RPi immich server **with no media assets**. Following this, you may [migrate photos from your previous app](../management/1-migrating-photos.md).

> [!IMPORTANT]
> If you have a large amount of assets to migrate, the RPi may have a hard time processing the migrated assets.
> Immich runs CPU intensive encoding and AI algorithms on your assets. This may cause your RPi to overheat and power down.
> 
> One solution to this is to install a heat sink and manage jobs in the `Administration > Jobs` page. A better solution is to setup a temporary immich instance on a more powerful machine to import and process photos before setting up the RPi. You can follow the [Migration Processing Off RPi](../alternative-setups/1-migration-processing-off-rpi.md) setup steps for this solution.