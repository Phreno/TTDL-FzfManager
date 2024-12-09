#############################################
# Fonctions Utilitaires
#############################################

<#
.SYNOPSIS
Selectionne une ou plusieurs taches depuis la liste ttdl a l'aide de fzf.
.DESCRIPTION
La fonction `Select-Fuzzy` execute `ttdl --dry-run` pour obtenir la liste des taches,
ignore les premieres et dernieres lignes inutiles, puis utilise `fzf` pour permettre
une selection interactive. Elle renvoie les lignes selectionnees.
.EXAMPLE
PS C:\> Select-Fuzzy
    # Ouvre fzf et permet de choisir une ou plusieurs taches. Les lignes correspondantes
    # sont ensuite renvoyees.
#>
function Select-Fuzzy {
  ttdl --dry-run |
  Select-Object -Skip 2 |
  Select-Object -SkipLast 2 |
  fzf --multi --tac
}

<#
.SYNOPSIS
Extrait l'ID d'une tache a partir de son entree textuelle.
.DESCRIPTION
La fonction `ConvertTo-Id` prend en entree une ou plusieurs lignes textuelles,
extraite l'ID numerique (debut de ligne) de chaque tache, et renvoie cet ID.
.PARAMETER entry
Une ligne textuelle representant une tache telle qu'affichee par `ttdl`.
.EXAMPLE
PS C:\> "  3 (A) Envoyer le rapport `@bureau" | ConvertTo-Id
3
#>
function ConvertTo-Id {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(ValueFromPipeline)] [string]$entry)
  process { $entry | Select-String -Pattern "^(?<ID>\d+)" | ForEach-Object { $_.Matches[0].Groups['ID'].Value } }
}

#############################################
# Fonctions d'Action sur les Taches
#############################################

<#
.SYNOPSIS
Ajoute une nouvelle tache a la liste.
.DESCRIPTION
La fonction `Invoke-Add` cree une nouvelle tache dans `todo.txt` en utilisant `ttdl add`.
Elle prend un sujet (texte) en parametre et l'ajoute comme nouvelle tache.
.PARAMETER subject
Le sujet (titre) de la nouvelle tache.
.EXAMPLE
PS C:\> Invoke-Add "Envoyer la facture +work due:2024-12-31"
#>
function Invoke-Add {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$subject)
  process { if ($PSCmdlet.ShouldProcess($subject,"add")) { ttdl add $subject } }
}

<#
.SYNOPSIS
Demarre le chronometre d'une tache.
.DESCRIPTION
La fonction `Invoke-Start` demarre le timer associe a une tache identifiee par son ID.
Cette fonctionnalite depend de la capacite de `ttdl` a gerer le temps.
.PARAMETER ID
L'ID de la tache dont on demarre le timer.
.EXAMPLE
PS C:\> "5" | Invoke-Start
#>
function Invoke-Start {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID)
  process { if ($PSCmdlet.ShouldProcess($ID,"start")) { ttdl start $ID } }
}

<#
.SYNOPSIS
Arrete le chronometre d'une tache.
.DESCRIPTION
La fonction `Invoke-Stop` arrete le timer d'une tache donnee par son ID.
.PARAMETER ID
L'ID de la tache a arreter.
.EXAMPLE
PS C:\> "5" | Invoke-Stop
#>
function Invoke-Stop {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID)
  process { if ($PSCmdlet.ShouldProcess($ID,"stop")) { ttdl stop $ID } }
}

<#
.SYNOPSIS
Marque une tache comme terminee.
.DESCRIPTION
La fonction `Invoke-Done` modifie l'etat d'une tache identifiee par son ID en "completee".
.PARAMETER ID
L'ID de la tache a marquer comme terminee.
.EXAMPLE
PS C:\> "5" | Invoke-Done
#>
function Invoke-Done {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID)
  process { if ($PSCmdlet.ShouldProcess($ID,"done")) { ttdl done $ID } }
}


<#
.SYNOPSIS
Restaure une tache completee en tache incomplete.
.DESCRIPTION
La fonction `Invoke-Undone` retire la marque de completion d'une tache, la rendant a nouveau incomplete.
.PARAMETER ID
L'ID de la tache a restaurer.
.EXAMPLE
PS C:\> "5" | Invoke-Undone
#>
function Invoke-Undone {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID)
  process { if ($PSCmdlet.ShouldProcess($ID,"undone")) { ttdl undone $ID } }
}


<#
.SYNOPSIS
Supprime une tache.
.DESCRIPTION
La fonction `Invoke-Remove` supprime une tache identifiee par son ID de la liste.
Par defaut, `ttdl rm` s'applique aux taches incompletes, utiliser `-a` ou `-A` pour inclure
les taches terminees si necessaire.
.PARAMETER ID
L'ID de la tache a supprimer.
.EXAMPLE
PS C:\> "5" | Invoke-Remove
#>
function Invoke-Remove {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID)
  process { if ($PSCmdlet.ShouldProcess($ID,"remove")) { ttdl rm $ID } }
}

<#
.SYNOPSIS
Ajoute un suffixe au sujet d'une tache.
.DESCRIPTION
La fonction `Invoke-Append` ajoute le texte specifie par `-suffix` a la fin
du sujet de la tache identifiee par son ID.
.PARAMETER ID
L'ID de la tache.
.PARAMETER suffix
Le texte a ajouter a la fin du sujet.
.EXAMPLE
PS C:\> "5" | Invoke-Append -suffix " [a revoir]"
#>
function Invoke-Append {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID,[Parameter(Mandatory)] [string]$suffix)
  process { if ($PSCmdlet.ShouldProcess($ID,"append $suffix")) { ttdl append $ID $suffix } }
}


<#
.SYNOPSIS
Ajoute un prefixe au sujet d'une tache.
.DESCRIPTION
La fonction `Invoke-Prepend` insere le texte specifie par `-prefix` au debut
du sujet de la tache identifiee par son ID.
.PARAMETER ID
L'ID de la tache.
.PARAMETER prefix
Le texte a inserer au debut du sujet.
.EXAMPLE
PS C:\> "5" | Invoke-Prepend -prefix "URGENT: "
#>
function Invoke-Prepend {
  [CmdletBinding(SupportsShouldProcess)]
  param([Parameter(Mandatory,ValueFromPipeline)] [string]$ID,[Parameter(Mandatory)] [string]$prefix)
  process { if ($PSCmdlet.ShouldProcess($ID,"prefix $prefix")) { ttdl prepend $ID $prefix } }
}

<#
.SYNOPSIS
Modifie une ou plusieurs tâches avec les options d'édition fournies.
.DESCRIPTION
La fonction `Invoke-Edit` appelle `ttdl e` avec l'ID (ou un filtre) et applique les options d'édition spécifiées.
Vous pouvez modifier la priorité, la date d'échéance (due), la récurrence, ajouter ou supprimer des projets, des contextes, 
des tags, des hashtags, ainsi que remplacer certaines de ces valeurs.

Les paramètres correspondent directement aux options `--set-pri`, `--set-due`, `--set-rec`, `--set-proj`, 
`--set-ctx`, `--del-proj`, `--del-ctx`, `--repl-proj`, `--repl-ctx`, `--set-threshold`, `--set-tag`, 
`--set-hashtag`, `--del-tag`, `--del-hashtag`, `--repl-hashtag` de `ttdl`.

.PARAMETER ID
L'ID (ou la plage d'IDs) de la tâche à modifier, ou un critère de sélection (ex: +projet, `@context, ...)

.PARAMETER SetPri
Change la priorité de la tâche. Valeurs possibles: `none`, `A-Z`, `+`, `-`.

.PARAMETER SetDue
Change la date d'échéance de la tâche. Format : `YYYY-MM-DD` ou `none`.

.PARAMETER SetRec
Change la récurrence de la tâche. Format : `none`, `1m`, `15d` etc.

.PARAMETER SetProj
Ajoute un ou plusieurs projets à la tâche (format CSV).

.PARAMETER SetCtx
Ajoute un ou plusieurs contextes à la tâche (format CSV).

.PARAMETER DelProj
Supprime un projet de la tâche.

.PARAMETER DelCtx
Supprime un contexte de la tâche.

.PARAMETER ReplProj
Remplace un ou plusieurs projets. Format: `oldproj+newproj,oldproj2+newproj2`

.PARAMETER ReplCtx
Remplace un ou plusieurs contextes. Format: `oldctx@newctx,oldctx2@newctx2`

.PARAMETER SetThreshold
Change la date de seuil (threshold) de la tâche. Format: `YYYY-MM-DD` ou `none`.

.PARAMETER SetTag
Ajoute un ou plusieurs tags. Format: `TAG1:VALUE1,TAG2:VALUE2`

.PARAMETER SetHashtag
Ajoute un ou plusieurs hashtags. Format: `HASHTAG1,HASHTAG2`

.PARAMETER DelTag
Supprime un ou plusieurs tags. Format: `TAG1,TAG2`

.PARAMETER DelHashtag
Supprime un ou plusieurs hashtags. Format: `HASHTAG1,HASHTAG2`

.PARAMETER ReplHashtag
Remplace un ou plusieurs hashtags. Format: `HASHTAG1:NEW1,HASHTAG2:NEW2`

.EXAMPLE
PS C:\> Invoke-Edit -ID 5 --SetPri A --SetDue 2025-01-01

Modifie la tâche d'ID 5, lui attribue la priorité A et fixe la due date au 1er janvier 2025.

.EXAMPLE
PS C:\> Invoke-Edit -ID +monprojet --Set-Ctx "work,home" --Del-Proj oldproj

Modifie toutes les tâches du projet `monprojet`, leur ajoute les contextes "work" et "home", 
et supprime le projet nommé "oldproj".
#>
function Invoke-Edit {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$ID,

    [string]$SetPri,
    [string]$SetDue,
    [string]$SetRec,
    [string]$SetProj,
    [string]$SetCtx,
    [string]$DelProj,
    [string]$DelCtx,
    [string]$ReplProj,
    [string]$ReplCtx,
    [string]$SetThreshold,
    [string]$SetTag,
    [string]$SetHashtag,
    [string]$DelTag,
    [string]$DelHashtag,
    [string]$ReplHashtag
  )

  begin { $argsList = @() }
  process {
    # Construction de la liste d'arguments
    if ($SetPri) { $argsList += "--set-pri=$SetPri" }
    if ($SetDue) { $argsList += "--set-due=$SetDue" }
    if ($SetRec) { $argsList += "--set-rec=$SetRec" }
    if ($SetProj) { $argsList += "--set-proj=$SetProj" }
    if ($SetCtx) { $argsList += "--set-ctx=$SetCtx" }
    if ($DelProj) { $argsList += "--del-proj=$DelProj" }
    if ($DelCtx) { $argsList += "--del-ctx=$DelCtx" }
    if ($ReplProj) { $argsList += "--repl-proj=$ReplProj" }
    if ($ReplCtx) { $argsList += "--repl-ctx=$ReplCtx" }
    if ($SetThreshold) { $argsList += "--set-threshold=$SetThreshold" }
    if ($SetTag) { $argsList += "--set-tag=$SetTag" }
    if ($SetHashtag) { $argsList += "--set-hashtag=$SetHashtag" }
    if ($DelTag) { $argsList += "--del-tag=$DelTag" }
    if ($DelHashtag) { $argsList += "--del-hashtag=$DelHashtag" }
    if ($ReplHashtag) { $argsList += "--repl-hashtag=$ReplHashtag" }

    # Appel à ttdl e
    if (-not ($argsList.Count -gt 0)) {
      # Si aucune option n'est spécifiée, on n'appelle pas ttdl
      Write-Verbose "Aucune modification n'a été spécifiée."
      return
    }

    if ($PSCmdlet.ShouldProcess($ID,"edit $argsList")) {
      ttdl e $ID $argsList
    }
  }
}
#############################################
# Fonctions de Selection et d’Action Combinees
#############################################

<#
.SYNOPSIS
Selectionne une tache via fzf puis demarre son timer.
.DESCRIPTION
`Start-Task` utilise `Select-Entry` pour choisir une tache, en extrait l'ID,
puis appelle `Invoke-Start` pour demarrer le timer.
.EXAMPLE
PS C:\> Start-Task
    # Selectionne une tache et demarre son chronometre.
#>
function Start-Task {
  [CmdletBinding(SupportsShouldProcess)] param()
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Start }
}

<#
.SYNOPSIS
Selectionne une tache via fzf puis arrete son timer.
.DESCRIPTION
`Stop-Task` utilise `Select-Entry` pour choisir une tache, en extrait l'ID,
puis appelle `Invoke-Stop` pour arreter le timer.
.EXAMPLE
PS C:\> Stop-Task
#>
function Stop-Task {
  [CmdletBinding(SupportsShouldProcess)] param()
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Stop }
}

<#
.SYNOPSIS
Selectionne une tache via fzf puis la marque comme terminee.
.DESCRIPTION
`Complete-Task` permet de choisir une tache, puis la marque comme completee grace a `Invoke-Done`.
.EXAMPLE
PS C:\> Complete-Task
#>
function Complete-Task {
  [CmdletBinding(SupportsShouldProcess)] param()
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Done }
}

<#
.SYNOPSIS
Selectionne une tache via fzf puis la remet en incomplete si elle etait completee.
.DESCRIPTION
`Restore-Task` choisit une tache, recupere son ID, puis appelle `Invoke-Undone` pour retirer la marque de completion.
.EXAMPLE
PS C:\> Restore-Task
#>
function Restore-Task {
  [CmdletBinding(SupportsShouldProcess)] param()
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Undone }
}

<#
.SYNOPSIS
Selectionne une tache via fzf puis la supprime.
.DESCRIPTION
`Remove-Task` ouvre un selecteur fzf, recupere l'ID de la tache selectionnee, puis la supprime via `Invoke-Remove`.
.EXAMPLE
PS C:\> Remove-Task
#>
function Remove-Task {
  [CmdletBinding(SupportsShouldProcess)] param()
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Remove }
}

<#
.SYNOPSIS
Selectionne une tache via fzf puis ajoute un suffixe a son sujet.
.DESCRIPTION
`Add-TaskSuffix` permet de choisir une tache et d'y ajouter le texte specifie a la fin de son sujet.
.PARAMETER suffix
Le texte a ajouter.
.EXAMPLE
PS C:\> Add-TaskSuffix " [revu]"
    # Selectionne une tache, puis ajoute " [revu]" a la fin.
#>
function Add-TaskSuffix {
  [CmdletBinding(SupportsShouldProcess)] param([Parameter(Mandatory,Position = 0)] [string]$suffix)
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Append -suffix $suffix }
}

<#
.SYNOPSIS
Selectionne une tache via fzf puis ajoute un prefixe a son sujet.
.DESCRIPTION
`Add-TaskPrefix` permet de choisir une tache et d'y ajouter le texte specifie au debut de son sujet.
.PARAMETER prefix
Le texte a inserer au debut du sujet.
.EXAMPLE
PS C:\> Add-TaskPrefix "IMPORTANT: "
    # Selectionne une tache, puis ajoute "IMPORTANT: " au debut.
#>
function Add-TaskPrefix {
  [CmdletBinding(SupportsShouldProcess)] param([Parameter(Mandatory,Position = 0)] [string]$prefix)
  process { Select-Fuzzy | ConvertTo-Id | Invoke-Prepend -Prefix $prefix }
}

#############################################
# Fonctions d'edition
#############################################


<#
.SYNOPSIS
Sélectionne une ou plusieurs tâches via fzf puis applique les modifications spécifiées.
.DESCRIPTION
`Edit-Task` utilise `Select-Entry` et `ConvertTo-Id` pour sélectionner des tâches, puis 
appelle `Invoke-Edit` avec les paramètres d'édition fournis (voir `Invoke-Edit` pour la liste complète).

Ce flux permet de choisir interactivement une tâche et d'y appliquer facilement des modifications.
.PARAMETER SetPri
Voir `Invoke-Edit` pour la description.
.PARAMETER SetDue
Voir `Invoke-Edit` pour la description.
... etc pour chaque paramètre
.EXAMPLE
PS C:\> Edit-Task --SetPri A --SetDue 2025-01-01
    # Sélectionne une tâche, puis la modifie avec la priorité A et une due date au 01/01/2025
#>
function Edit-Task {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [string]$SetPri,
    [string]$SetDue,
    [string]$SetRec,
    [string]$SetProj,
    [string]$SetCtx,
    [string]$DelProj,
    [string]$DelCtx,
    [string]$ReplProj,
    [string]$ReplCtx,
    [string]$SetThreshold,
    [string]$SetTag,
    [string]$SetHashtag,
    [string]$DelTag,
    [string]$DelHashtag,
    [string]$ReplHashtag
  )
  process {
    Select-Fuzzy | ConvertTo-Id | Invoke-Edit `
       -SetPri $SetPri `
       -SetDue $SetDue `
       -SetRec $SetRec `
       -SetProj $SetProj `
       -SetCtx $SetCtx `
       -DelProj $DelProj `
       -DelCtx $DelCtx `
       -ReplProj $ReplProj `
       -ReplCtx $ReplCtx `
       -SetThreshold $SetThreshold `
       -SetTag $SetTag `
       -SetHashtag $SetHashtag `
       -DelTag $DelTag `
       -DelHashtag $DelHashtag `
       -ReplHashtag $ReplHashtag
  }
}
#############################################
# Alias
#############################################

New-Alias -Name "s" -Value "Start-Task" -Force
New-Alias -Name "so" -Value "Stop-Task" -Force
New-Alias -Name "ia" -Value "Invoke-Add" -Force
New-Alias -Name "co" -Value "Complete-Task" -Force
New-Alias -Name "re" -Value "Restore-Task" -Force
New-Alias -Name "ds" -Value "Add-TaskSuffix" -Force
New-Alias -Name "dp" -Value "Add-TaskPrefix" -Force
New-Alias -Name "dl" -Value "Remove-Task" -Force
New-Alias -Name "ed" -Value "Edit-Task" -Force
