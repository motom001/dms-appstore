# Sicherheit

Dieses Repository gehört zum DMS ([motom001/dms](https://github.com/motom001/dms)) und enthält: Einträge für die App-Stores (umbrelOS, ZimaOS, CasaOS, Unraid, TrueNAS, UGREEN).

## Eine Sicherheitslücke melden

Bitte **kein öffentliches Issue** für Sicherheitslücken. Melde sie vertraulich über GitHub: **Security → Report a vulnerability** in diesem Repository ([Private Vulnerability Reporting](https://github.com/motom001/dms-appstore/security/advisories/new)).

Betrifft die Lücke das DMS selbst, melde sie bitte direkt im Repository [motom001/dms](https://github.com/motom001/dms/security/advisories/new).

## Was automatisch geprüft wird

| Was | Womit | Wann |
| --- | --- | --- |
| Werkzeuge (Python, Shell), Workflows | CodeQL | jeder Pull Request, jeder Push auf `main` |
| App-Einträge | Probe-Installation (Umbrel, ZimaOS/CasaOS), TrueNAS-Prüfwerkzeug | jeder Pull Request, täglich |
| GitHub-Actions | Dependabot (Warnungen und Updates) | jeder Pull Request, wöchentlich |
| Geheimnisse (Tokens, Passwörter) | Secret Scanning mit Push-Schutz | jeder Push |

Die Funde stehen unter **Security** in diesem Repository.
