# AutoShare

Automatically shares newly accepted quests with party members when a quest
can be shared. Use another addon if you also want to auto-accept shared quests.

Targets Classic Era (`11508`, `11509`), Burning Crusade Classic (`20505`,
`20506`), Wrath Classic (`30405`, `38002`), Cataclysm Classic (`40402`),
Mists Classic (`50503`, `50504`), the Classic beta/Forever client (`16001`),
and Retail (`90002`, `120100`, `120105`). The addon selects the
quest-sharing API available on the running client rather than assuming
every branch uses the same quest event payload.

To check the available APIs in-game after `/reload`, run:

```text
/script print("AutoShare:", AS_Frame and AS_Frame:IsEventRegistered("QUEST_ACCEPTED"), "modern:", C_QuestLog and C_QuestLog.IsPushableQuest ~= nil, "legacy:", GetQuestLogPushable ~= nil, "push:", QuestLogPushQuest ~= nil)
```

Then accept a shareable quest while grouped to check that the share prompt
reaches another player; API presence alone does not confirm a successful share.

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
