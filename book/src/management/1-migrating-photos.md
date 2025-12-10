# Migrating Photos

If you are migrating from other photo management services, have a look at [immich-go](https://github.com/simulot/immich-go/tree/main) for automation.

> [!CAUTION]
> immich-go is still an early version. Make sure to confirm that correct and full migration is achieved.

> [!IMPORTANT]
> If you have a large amount of assets to migrate, the RPi may have a hard time processing the migrated assets.
> Immich runs CPU intensive encoding and AI algorithms on your assets. This may cause your RPi to overheat and power down.
> 
> One solution to this is to install a heat sink and manage jobs in the `Administration > Jobs` page. A better solution is to setup a temporary immich instance on a more powerful machine to import and process photos before setting up the RPi. You can follow the [Migration Processing Off RPi](../alternative-setups/1-migration-processing-off-rpi.md) setup steps for this solution.
