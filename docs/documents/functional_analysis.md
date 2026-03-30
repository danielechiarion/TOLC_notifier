# Analisi funzionale

## Potenziali problemi
Lo sviluppo delle funzionalità precedentemente esposte nell'[analisi dei requisiti](./requirements.md) porta con sè alcuni problemi da implementare nella fase di sviluppo:
1. **Scheduling processi** lo scheduling delle azioni potrebbe essere bloccato all'interno dei sistemi operativi (per iOS potrebbero non esserci sufficienti permessi) se effettuate troppo frequentemente. 
2. **Errori in background** se il processo di ricerca viene eseguito in background, non è possibile salvare eventuali allarmi né mostrarli al momento. Si propone di utilizzare un logger per il salvataggio delle informazioni relative a tali azioni. 
3. 