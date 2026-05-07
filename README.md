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
Basato su MTProto ufficiale

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
Stato attuale dello sviluppo:

0. Modifiche dei messaggi (formattazione testo) — ✔️ FATTO

1. Notifiche funzionanti — ✔️ FATTO

2. Demone per le notifiche — ✔️ FATTO

3. Creazione e gestione delle cartelle — ⏳ IN CORSO

4. Emoji custom — ✔️ FATTO

5. PIN dei messaggi — ✔️ FATTO

6. Selezione parziale del testo + copia — ✔️ FATTO

7. Gestione richieste accesso ai gruppi (admin) — ✔️ FATTO

8. Stati / Stories — ⏳ DA FARE

9. Bugfix formattazione — ✔️ FATTO

10. Traduzione (possibile supporto IA) — ⏳ DA FARE

11. Aggiungere “Invia a RooTelegram” nel menù Condividi di SailfishOS — ⏳ DA FARE

Opzionale:

Riordinamento dei gruppi dei “Custom Emoji Set”
