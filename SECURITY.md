# Security

## Which version

Fixes go into the latest release. Older releases stay up but do not get
patched. Clients and the server should run the same version.

## Reporting a problem

Use **Security > Report a vulnerability** on this repository. If that is not
available, open an issue that only says you need a private way to report
something. Please do not post exploit details, passwords, personal data or a
private server address in public.

Tell me which version it is, what the problem lets someone do, and the
shortest way to reproduce it. If a password or token was leaked, revoke it
where it was issued. Deleting it from Git is not enough.

## Downloads

Only download from this repository's Releases page. The Windows installer gets
the other mods from the URLs in `modpack/mods.lock.json` and checks their
hashes. The `.mrpack` uses the same files. Your Minecraft account is handled by
your launcher, the installer never touches it. Never send account files to
anyone.
