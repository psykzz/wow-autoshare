# AutoShare

Automatically shares newly accepted quests with party members when a quest
can be shared. Use another addon if you also want to auto-accept shared quests.

Supports Classic Era, Burning Crusade Classic, Wrath Classic, Cataclysm
Classic, Mists Classic, the Classic beta/Forever client, and Retail.

## Installation

Install from [Wago](https://addons.wago.io/addons/wow-autoshare) or
[CurseForge](https://www.curseforge.com/wow/addons/autoshare), or download a
release from GitHub and extract the `AutoShare` folder into `Interface\AddOns`.

## Development and releases

The BigWigs Packager packages pushes to `main` and publishes GitHub releases
for pushed tags. It substitutes `@project-version@` in `AutoShare.toc` when
packaging. To publish a version:

```bash
git tag -a v1.0.1 -m "Release version 1.0.1"
git push origin v1.0.1
```

Add `WAGO_API_TOKEN` and `CF_API_KEY` as repository Actions secrets to enable
uploads to those sites; GitHub provides `GITHUB_TOKEN` automatically. A
CurseForge upload also requires `X-Curse-Project-ID` in `AutoShare.toc`.

## License

See [License.txt](License.txt).
