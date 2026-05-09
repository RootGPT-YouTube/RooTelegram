# RooTelegram — Un client Telegram leggero e reattivo per SailfishOS
## Caratteristiche principali
Interfaccia semplice, veloce e ottimizzata per SailfishOS
Supporto completo alla formattazione dei messaggi (grassetto, corsivo, monospazio, ecc.)
Notifiche affidabili tramite daemon dedicato
Supporto alle Custom Emoji
Gestione dei PIN dei messaggi
Selezione e copia parziale del testo
Gestione delle richieste di accesso ai gruppi (per admin)
Architettura moderna basata su UI + daemon, per apertura istantanea dell’app

## Origini del progetto
RooTelegram nasce come evoluzione e modernizzazione del primordiale client Telegram per SailfishOS:

Fernschreiber di Sebastian J. Wolf
https://github.com/Wunderfitz/harbour-fernschreiber

e trae ispirazione da alcune soluzioni tecniche di:

Yottagram di Michal Szczepaniak
https://github.com/Michal-Szczepaniak/Yottagram

Entrambi i progetti hanno rappresentato un punto di partenza prezioso, ma RooTelegram introduce un’architettura completamente rinnovata, pensata per essere più veloce, più stabile e più adatta ai dispositivi moderni.

## Obiettivo del progetto
L’obiettivo di RooTelegram è offrire un client Telegram:

reattivo → apertura istantanea grazie al daemon sempre attivo

leggero → UI minimale, nessun effetto pesante

affidabile → notifiche sempre funzionanti

coerente con SailfishOS → integrazione nativa, rispetto delle linee guida Silica

Il design è volutamente scarno e basilare, perché la priorità è la velocità, non l’estetica.

## Roadmap
Stato attuale dello sviluppo (ROADMAP):

0. Modifiche dei messaggi (formattazione testo) — ✔️ FATTO

1. Notifiche funzionanti — ✔️ FATTO

2. Demone per le notifiche — ✔️ FATTO

3. Creazione e gestione delle cartelle — ✔️ FATTO

4. Emoji custom — ✔️ FATTO

5. PIN dei messaggi — ✔️ FATTO

6. Selezione parziale del testo + copia — ✔️ FATTO

7. Gestione richieste accesso ai gruppi (admin) — ✔️ FATTO

8. Stati / Stories — ⏳ DA FARE

9. Bugfix formattazione — ✔️ FATTO

10. Traduzione (possibile supporto IA) — ⏳ DA FARE

11. Aggiungere “Invia a RooTelegram” nel menù Condividi di SailfishOS — ✔️ FATTO

12. Aggiungere "Chiama" per le telefonate via Telegram — ⏳ DA FARE

13. Migliorare preview immagini (portrait e landscape), migliorare formattazione messaggi (wordwrap e mono) e preview link — ✔️ FATTO

14. Bio utente e tabulazione (Media, Audio, Documenti, Link, Gruppi) — ✔️ FATTO

Opzionale:

Riordinamento dei gruppi dei “Custom Emoji Set” — ✔️ FATTO

#[ENGLISH] RooTelegram — A lightweight and responsive Telegram client for SailfishOS
##Main features
Simple, fast interface optimized for SailfishOS
Full support for message formatting (bold, italic, monospace, etc.)
Reliable notifications through a dedicated daemon
Support for Custom Emoji
Message PIN management
Partial text selection and copy
Handling of group join requests (for admins)
Modern architecture based on UI + daemon for instant app launch

Project origins
RooTelegram was born as an evolution and modernization of the early Telegram client for SailfishOS:

Fernschreiber by Sebastian J. Wolf
https://github.com/Wunderfitz/harbour-fernschreiber

and takes inspiration from some technical solutions found in:

Yottagram by Michal Szczepaniak
https://github.com/Michal-Szczepaniak/Yottagram

Both projects served as valuable starting points, but RooTelegram introduces a completely renewed architecture designed to be faster, more stable, and better suited for modern devices.

##Project goal
The goal of RooTelegram is to offer a Telegram client that is:

responsive → instant opening thanks to the always‑running daemon

lightweight → minimal UI, no heavy effects

reliable → notifications that always work

consistent with SailfishOS → native integration, respecting Silica guidelines

The design is intentionally minimal and essential, because the priority is speed, not aesthetics.

##Roadmap
Current development status (ROADMAP):

Message editing (text formatting) — ✔️ DONE

Working notifications — ✔️ DONE

Notification daemon — ✔️ DONE

Folder creation and management — ✔️ DONE

Custom Emoji — ✔️ DONE

Message PINs — ✔️ DONE

Partial text selection + copy — ✔️ DONE

Handling group join requests (admin) — ✔️ DONE

Stories / Status — ⏳ TO DO

Formatting bugfixes — ✔️ DONE

Translation (possible AI support) — ⏳ TO DO

Add “Send to RooTelegram” in SailfishOS Share menu — ✔️ DONE

Add “Call” for Telegram voice calls — ⏳ TO DO

Improve image previews (portrait & landscape), improve message formatting (wordwrap & mono) and link previews — ✔️ DONE

User bio and tabs (Media, Audio, Documents, Links, Groups) — ✔️ DONE

Optional:

Reordering of “Custom Emoji Set” groups — ✔️ DONE
