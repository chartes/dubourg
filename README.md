# Correspondance d'Antoine Du Bourg (1535-1538)

Édition électronique de la correspondance passive d'Antoine Du Bourg
(v. 1490-1538), chancelier de France du 16 juillet 1535 à sa mort accidentelle
le 28 octobre 1538. Plus de 1 200 lettres missives reçues en un peu plus de
trois années, qui touchent à tous les domaines d'activité du chancelier, de la
justice aux finances royales en passant par la surveillance de l'imprimé et la
politique économique du royaume.

- **Auteur** : Antoine Du Bourg
- **Responsable scientifique** : Olivier Poncet, professeur à l'École nationale des chartes
- **Éditrice scientifique et éditrice électronique** : Camille Desenclos
- **Éditeur** : École nationale des chartes – PSL
- **Date de la première édition électronique** : 2011
- **Licence** : CC BY-NC-SA 4.0
- **Identifiant de collection DoTS** : `dubourg`

## Contenu de la branche `migration`

Cette branche présente le corpus selon l'arborescence attendue par DoTS :

```
data/        le fichier TEI servi par BaseX
metadata/    le mapping de métadonnées DoTS et les métadonnées de collection
transform/   la feuille XSL de rendu du corpus
schema/      le schéma RELAX NG de l'édition
```

- `data/dubourg_correspondance.xml` : la source TEI de l'édition.
- `metadata/dots_metadata_mapping.xml` : l'exposition des métadonnées Dublin Core
  et Schema.org à partir du `teiHeader`.
- `metadata/collection.csv` : les métadonnées de la collection `dubourg`
  (fichier tabulé ; le nom est celui que porte le document dans la base).
- `transform/dubourg.xsl` : la surcharge de rendu du corpus. Comme celle des
  autres corpus DoTS, elle importe la feuille générique `hteiml/xsl/tei2html.xsl`
  et ne redéfinit que les spécificités de l'édition ; elle doit donc être
  installée à côté de `hteiml/` et n'est pas utilisable isolément.
- `schema/correspondance.rng` : le schéma RELAX NG de l'édition.

## Provenance des fichiers

Les fichiers de `data/` et de `metadata/` ont été exportés de la base BaseX
`dubourg` le 23 septembre 2026, via l'API REST. Les registres de runtime
`dots/resources_register.xml` et `dots/fragments_register.xml` ne sont pas
versionnés : ils sont reconstruits à l'ingestion.

La feuille de `transform/` provient de l'installation DoTS de travail
(`webapp/static/transform/dubourg/`). Le schéma de `schema/` est repris de la
branche `master`, où il était rangé sous `data/`.

Les feuilles de style, les images et le fichier de configuration de l'interface
ne sont pas versionnés ici : ils relèvent du dépôt `dots-vue-elec-settings`.

Une première version de cette correspondance avait été publiée avec Diple ; ses
sources restent disponibles sur la release
[v0.1.0](https://github.com/chartes/dubourg/releases/tag/v0.1.0).
