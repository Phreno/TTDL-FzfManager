# TTDL-FzfManager

**TTDL-FzfManager** est un module PowerShell qui facilite la gestion des tâches Todo.txt à l'aide de l’outil [ttdl](https://github.com/cybernium/ttdl) et de la sélection interactive via [fzf](https://github.com/junegunn/fzf). Ce module offre une gamme de fonctions permettant d’ajouter, d’éditer, de compléter, de restaurer, de supprimer et de gérer vos tâches directement depuis le terminal, de manière intuitive et efficace.

## Principales Fonctions

- **Sélection Interractive**: Le module utilise `fzf` pour permettre une sélection rapide et aisée des tâches parmi la liste retournée par `ttdl`.
- **Gestion Complète des Tâches**: Ajoutez, complétez, restaurez, supprimez et éditez vos tâches via des commandes simples.
- **Édition Avancée**: Ajustez la priorité, la date d’échéance, les récurrences, les projets, les contextes, les tags, les hashtags, et plus encore grâce aux options `--set-*`, `--del-*`, `--repl-*`.
- **Alias Pratiques**: Des alias sont fournis pour accélérer les opérations les plus courantes, rendant l’utilisation du module plus fluide.

## Fonctionnalités Clés

1. **Intégration avec `ttdl`**:  
   Toutes les opérations sont exécutées via `ttdl`, un outil puissant et flexible pour la gestion de tâches au format Todo.txt.

2. **Utilisation d’`fzf`**:  
   Fzf offre une interface de sélection interactive depuis le terminal, vous permettant de filtrer, sélectionner et agir sur une ou plusieurs tâches sans effort.

3. **Paramètres d’édition Complets**:  
   - `--set-pri` : Définir ou modifier la priorité (A-Z, +, - ou none)  
   - `--set-due` : Définir ou supprimer une date d’échéance (YYYY-MM-DD ou none)  
   - `--set-rec` : Définir une récurrence (par ex. 1m, 15d)  
   - `--set-proj`, `--set-ctx`, `--set-tag`, `--set-hashtag` : Ajouter des projets, contextes, tags et hashtags  
   - `--del-proj`, `--del-ctx`, `--del-tag`, `--del-hashtag` : Supprimer ces éléments  
   - `--repl-proj`, `--repl-ctx`, `--repl-hashtag` : Remplacer ces éléments par de nouveaux valeurs  
   - `--set-threshold` : Définir une date seuil (threshold)

4. **Vérification et Validation des Paramètres**:  
   Les entrées utilisateur sont validées afin de minimiser les erreurs de format et garantir le respect des standards Todo.txt.

## Exemples d’Utilisation

- Sélectionner une tâche puis la compléter :  
  ```powershell
  co
  ```
  
- Ajouter une nouvelle tâche :  
  ```powershell
  ia "Envoyer le rapport +work @finance due:2025-04-01"
  ```

- Éditer la priorité et la date d’échéance d’une tâche sélectionnée interactivement :  
  ```powershell
  Edit-Task --SetPri A --SetDue 2025-01-01
  ```

- Ajouter un suffixe à la tâche choisie :  
  ```powershell
  ds " [à revoir]"
  ```

## Installation

1. Assurez-vous d’avoir `ttdl` installé et accessible dans votre `$PATH`.
2. Installez `fzf`.
3. Clonez ce dépôt et importez le module :
   ```powershell
   Import-Module ./TTDL-FzfManager.ps1
   ```

4. Les fonctions et alias seront alors disponibles dans votre session PowerShell.

## Contribution

Les contributions sont les bienvenues ! Veuillez créer une pull request ou ouvrir une issue pour discuter de nouvelles fonctionnalités, corrections de bugs ou améliorations.

## Licence

Ce projet est distribué sous la licence MIT. Consultez le fichier [LICENSE](LICENSE) pour plus d’informations.
