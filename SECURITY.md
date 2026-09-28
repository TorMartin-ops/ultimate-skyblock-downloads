# Security

## Supported version

Security fixes target the latest released version. Older releases remain historical downloads and may
contain bugs fixed later. Use the same Ultimate Skyblock version on clients and the server.

## Report privately

Use GitHub's **Security → Report a vulnerability** on this repository when available.
If private reporting is unavailable, open an issue saying only that you need a private reporting channel.
Do not post exploit details, credentials, personal data or a private server address publicly.

Describe the affected version, impact and minimal reproduction. Sanitized excerpts are preferable to full logs.
If a credential was exposed, revoke it at its provider; deleting it from Git is not enough.

## Downloads

Use this repository's Releases page. Windows installers download the companion files from the pinned URLs
in `modpack/mods.lock.json` and verify their hashes. The portable `.mrpack` uses the same pinned files.
Minecraft accounts are handled by your launcher, not by the pack installer. Never send account files to maintainers.

Automated scans reduce accidental leaks; they do not prove the absence of all sensitive data or vulnerabilities.
