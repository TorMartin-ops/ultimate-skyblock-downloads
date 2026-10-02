# Included mods

The client installer installs ten JAR files. All the gameplay is in Voidhome. The rest are for performance and for showing useful info.

| Mod | Why it is included |
|---|---|
| Voidhome | The world, progression, skills, quests, fishing and co-op systems |
| [Fabric API](https://modrinth.com/mod/fabric-api) | Required library for Voidhome |
| [Sodium](https://modrinth.com/mod/sodium) | Faster rendering |
| [Lithium](https://modrinth.com/mod/lithium) | Faster game logic, including the singleplayer server |
| [FerriteCore](https://modrinth.com/mod/ferrite-core) | Lower memory use |
| [ImmediatelyFast](https://modrinth.com/mod/immediatelyfast) | Optimized HUD, text, particles and entity rendering |
| [Entity Culling](https://modrinth.com/mod/entityculling) | Avoids drawing entities hidden behind blocks; server-side farms keep running |
| [AppleSkin](https://modrinth.com/mod/appleskin) | Food and saturation information |
| [Jade](https://modrinth.com/mod/jade) | Information about the block or creature you are looking at |
| [Shulker Box Tooltip](https://modrinth.com/mod/shulkerboxtooltip) | Preview stored items without placing the box |

You only need Voidhome and Fabric API to play. The other eight are optional. How much they help depends on your PC and how big your base is.

You need Minecraft 26.3, Fabric Loader 0.19.5 and Java 25. The loader is not a file in `mods`. Exact companion versions and download hashes are in [mods.lock.json](../modpack/mods.lock.json).

## Why Minecraft shows more than ten mods

Fabric API alone is 44 small modules, and other mods and the loader bring their own libraries. Fabric counts every one of them. So a big number in the mod list does not mean the installer added that many mods. Do not try to remove modules from a JAR.

## Windows installation and updates

1. Download the latest `voidhome-<version>-client.zip` from [GitHub Releases](https://github.com/TorMartin-ops/voidhome-downloads/releases/latest).
2. Extract it, close Minecraft and the launcher, and double-click **Install.bat**.
3. Select the Voidhome installation named in the installer's completion message.

The installer uses a dedicated game directory, normally `%APPDATA%\.minecraft\profiles\ultimate-skyblock-26.3`. It installs the ten files and nothing else. The launcher profile's name is updated to show the installed version, unless you renamed it yourself.

To preview changes without writing anything:

```powershell
powershell -ExecutionPolicy Bypass -File install-client.ps1 -DryRun
```

Re-running the installer upgrades the mod and removes unchanged companion JARs that it previously installed but which are no longer in this set. It keeps saves, settings, and user-added or modified JARs. It records ownership in `mods/.ultimateskyblock-managed.json`. If you added a second Voidhome JAR manually, keep only the current version.

Advanced options are `-GameDir <folder>`, `-ModJar <file>`, or `-ModJarUrl <https URL>` with `-ModJarSha1 <hash>`. Normally the installer finds the mod JAR beside itself.

## macOS and Linux

Import the release's `.mrpack` in a launcher that supports Modrinth packs. It has the same mod versions as the Windows installer, and no settings or worlds. See [portable instructions](../modpack/PORTABLE.md).

For manual installation, install Fabric Loader for Minecraft 26.3. Put the release's Voidhome JAR and the pinned Fabric API JAR in the profile's `mods` folder. Those two files are enough to play. Add the other eight from the table if you want them, with the versions in the lock file. The Windows installer does not run on macOS or Linux. The mod has not been tested much on macOS.

## Playing with friends

The host and every player need the same Voidhome version and a Fabric API that fits it. The server does not need the client performance and info mods.

The dedicated server installer defaults to **four JARs**: Voidhome, Fabric API, Lithium and FerriteCore. Optional server support for the included information mods is available with `-Include appleskin,jade,shulkerboxtooltip`. That only gives those mods the server data they want. See [HOSTING.md](HOSTING.md).

The client installer does not install any hosting service, tunnel or account. Everything is free, and the official downloads are on this project's GitHub Releases page.
