# DMS App Store

[Deutsch](README.md) · **English**

App store entries for the [DMS](https://github.com/motom001/dms): document management for households and families. With them you install the DMS on a home server with one click, without Docker or a command line.

> **The DMS itself is in German so far** – its user interface and its manuals. An English user interface is planned ([dms #357](https://github.com/motom001/dms/issues/357)). This README is a translation; if it differs from the German [README.md](README.md), the German version applies.

| System | How to add the store |
| --- | --- |
| **umbrelOS** | App Store → ⋯ (top right) → *Community App Stores* → `https://github.com/motom001/dms-appstore` |
| **ZimaOS** | App Store → manage sources (*Quellen verwalten* in the German interface) → `https://cdn.jsdelivr.net/gh/motom001/dms-appstore@gh-pages` |
| **CasaOS** | App Store → more apps (*Weitere Apps* in the German interface) → `https://github.com/motom001/dms-appstore/archive/refs/heads/main.zip` |

After that, **DMS** appears in the app store. Once it is installed, open the app. A wizard asks for the name of your household and creates the first administrator. The database is already connected.

> **Set it up right after installing.** Until the administrator has been created, anyone in your home network could do it.

In detail: [How do I get a DMS? → App store](https://motom001.github.io/dms/installieren/aktuell/app-store/) (installation manual, German).

What comes next and how we work is described in the [roadmap](ROADMAP.md) (German).

## More platforms

| Platform | Folder | Status |
| --- | --- | --- |
| **TrueNAS** | `truenas/dms/` (generated) | tested with the catalogue's check tool for every release; ready for a PR to [truenas/apps](https://github.com/truenas/apps) under `ix-dev/community/dms` ([#182](https://github.com/motom001/dms/issues/182)) |
| **Unraid** | `unraid/dms.xml`, `unraid/dms-datenbank.xml` | templates for Community Applications; submission via [ca.unraid.net](https://ca.unraid.net/submit) ([#183](https://github.com/motom001/dms/issues/183)) |
| **UGREEN** | `ugreen/` | draft for the App Center, open questions in `ugreen/README.md` (German) ([#181](https://github.com/motom001/dms/issues/181)) |
| **Umbrel official** | `offiziell/umbrel/dms/` (generated) | ready for a PR to [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps) ([#186](https://github.com/motom001/dms/issues/186)) |
| **ZimaOS official** | `Apps/DMS/` | the same file for a PR to [IceWhaleTech/CasaOS-AppStore](https://github.com/IceWhaleTech/CasaOS-AppStore) ([#186](https://github.com/motom001/dms/issues/186)) |

Guides without an app store (Synology, QNAP, UGREEN, TrueNAS, Unraid, Docker) are in the installation manual under [How do I get a DMS?](https://motom001.github.io/dms/installieren/aktuell/) (German).

## Layout

| Path | Content |
| --- | --- |
| `vorlagen/` | templates for Umbrel, ZimaOS/CasaOS and TrueNAS – **make changes here** |
| `werkzeuge/erzeugen.py` | fills in version, images (with digest) and pictures |
| `umbrel-app-store.yml`, `motom001-dms/` | Umbrel (generated) |
| `Apps/DMS/`, `store-config.json`, `supported-languages.json` | ZimaOS/CasaOS (Compose generated) |
| branch `gh-pages` | built ZimaOS store (v2) |

The workflow **Store aktualisieren** (update store) runs daily and after changes to the templates. It fetches the latest DMS release, resolves the images for amd64 and arm64 to their digest and generates the entries. Then it **installs them as a test**: Umbrel and ZimaOS/CasaOS are started, the DMS is set up via the API, restarted and the sign-in is checked; TrueNAS runs through the catalogue's check tool. Only then does it commit and build the ZimaOS store. It can also be started by hand for a specific version.

Please report bugs and requests in the [DMS repository](https://github.com/motom001/dms/issues) – in German or English.

## License

[Apache-2.0](LICENSE), see also [NOTICE](NOTICE). Store operators may freely take over and adapt the entries. Whoever redistributes them includes the license and the notices from NOTICE and marks modified files; publishing the source of a modified version is not required. The DMS itself is covered by the license in the [DMS repository](https://github.com/motom001/dms/blob/main/LICENSE).
