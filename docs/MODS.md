# Included mods

The **2.8.5 client installer installs ten JAR files**. All Skyblock gameplay is in Ultimate Skyblock; the companions improve performance and useful information.

| Mod | Why it is included |
|---|---|
| Ultimate Skyblock | The world, progression, skills, quests, fishing and co-op systems |
| [Fabric API](https://modrinth.com/mod/fabric-api) | Required library for Ultimate Skyblock |
| [Sodium](https://modrinth.com/mod/sodium) | Faster rendering |
| [Lithium](https://modrinth.com/mod/lithium) | Faster game logic, including the singleplayer server |
| [FerriteCore](https://modrinth.com/mod/ferrite-core) | Lower memory use |
| [ImmediatelyFast](https://modrinth.com/mod/immediatelyfast) | Optimized HUD, text, particles and entity rendering |
| [Entity Culling](https://modrinth.com/mod/entityculling) | Avoids drawing entities hidden behind blocks; server-side farms keep running |
| [AppleSkin](https://modrinth.com/mod/appleskin) | Food and saturation information |
| [Jade](https://modrinth.com/mod/jade) | Information about the block or creature you are looking at |
| [Shulker Box Tooltip](https://modrinth.com/mod/shulkerboxtooltip) | Preview stored items without placing the box |

Only **Ultimate Skyblock and Fabric API** are required for gameplay. The other eight are the curated companions. Performance benefits depend on your hardware and base; no fixed FPS improvement is promised.

Minecraft **26.3**, Fabric Loader **0.19.5** and Java **25** are required. Loader is not another file in `mods`. Exact companion versions and download hashes are in [mods.lock.json](../modpack/mods.lock.json).

## Why Minecraft shows more than ten mods

The pinned Fabric API JAR contains **44 internal modules**. Other mods and the loader also include libraries. Fabric counts these separately. A high displayed count does not mean the installer added that many separate gameplay mods. Do not remove individual modules from a JAR.

## Windows installation and updates

1. Download the latest `ultimate-skyblock-<version>-client.zip` from [GitHub Releases](https://github.com/TorMartin-ops/ultimate-skyblock-downloads/releases/latest).
2. Extract it, close Minecraft and the launcher, and double-click **Install.bat**.
3. Select the Ultimate Skyblock installation named in the installer's completion message.

The installer uses a dedicated game directory, normally `%APPDATA%\.minecraft\profiles\ultimate-skyblock-26.3`. It installs the ten-file set without additional bundles. Standard generated launcher names are updated to show the installed version; custom names are preserved.

To preview changes without writing anything:

```powershell
powershell -ExecutionPolicy Bypass -File install-client.ps1 -DryRun
```

Re-running the installer upgrades the mod and removes unchanged companion JARs that it previously installed but which are no longer in this set. It keeps saves, settings, and user-added or modified JARs. It records ownership in `mods/.ultimateskyblock-managed.json`. If you added a second Ultimate Skyblock JAR manually, keep only the current version.

Advanced options are `-GameDir <folder>`, `-ModJar <file>`, or `-ModJarUrl <https URL>` with `-ModJarSha1 <hash>`. Normally the installer finds the mod JAR beside itself.

## macOS and Linux

Import the release's `.mrpack` in a launcher with Modrinth pack support to install the curated set. It uses the same pinned versions as the Windows installer and contains no personal settings or worlds. See [portable instructions](../modpack/PORTABLE.md).

For manual installation, install Fabric Loader for Minecraft 26.3. Put the release's Ultimate Skyblock JAR and the pinned Fabric API JAR in the profile's `mods` folder. Those two files are sufficient for gameplay. Add the eight companions from the table if wanted, using the versions and URLs in the lock. The supplied Windows installer does not run on macOS or Linux. Native macOS gameplay has not been fully verified.

## Playing with friends

The host and every player need the **same Ultimate Skyblock version** and compatible Fabric API. The client performance and information mods are not mandatory server dependencies.

The dedicated server installer defaults to **four JARs**: Ultimate Skyblock, Fabric API, Lithium and FerriteCore. Optional server support for the included information mods is available with `-Include appleskin,jade,shulkerboxtooltip`. This provides additional server data for their clients; it adds no new progression system. See [HOSTING.md](HOSTING.md).

No hosting service, tunnel, account or paid subscription is installed by the client installer. Use the project's GitHub Releases page for official downloads; no paid modpack subscription is required.
