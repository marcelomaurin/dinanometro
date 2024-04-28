# Portugues
# Dinamômetro Digital: Ferramenta Open Source para o Ensino de Forças Newtonianas
## Introdução
Bem-vindo ao repositório do Dinamômetro Digital, um projeto open source dedicado a transformar o ensino e estudo das forças Newtonianas através de uma abordagem prática e interativa. Desenvolvido com o objetivo de proporcionar uma compreensão mais profunda das leis de movimento de Newton, este projeto oferece uma ferramenta educacional inovadora que permite a estudantes e educadores medir e analisar forças no mundo real com facilidade e precisão.

As leis de Newton são pilares fundamentais da física, descrevendo os princípios do movimento e a relação entre os objetos e as forças que atuam sobre eles. Apesar de sua importância indiscutível, o ensino desses conceitos muitas vezes se depara com desafios significativos, especialmente quando se trata de traduzir teoria em experiência prática. O Dinamômetro Digital surge como uma solução para esses desafios, oferecendo uma ponte entre o conhecimento teórico e a aplicação real.

Desafios no Ensino de Física e a Necessidade de Ferramentas Práticas
O ensino de física enfrenta um obstáculo recorrente: como tornar conceitos abstratos compreensíveis e atraentes para os alunos. A dificuldade de visualizar e interagir com essas ideias muitas vezes resulta em desinteresse ou em uma compreensão superficial dos princípios físicos. Além disso, a falta de recursos práticos acessíveis limita as oportunidades para que estudantes realizem experimentos significativos que poderiam consolidar seu aprendizado.

O dinamômetro, um instrumento utilizado para medir a intensidade das forças, é fundamental em muitos experimentos educacionais de física. No entanto, versões tradicionais deste instrumento podem ser caras, frágeis ou difíceis de integrar com as tecnologias atuais de ensino. Reconhecendo essa lacuna, nosso projeto propõe uma versão digital e open source do dinamômetro, desenhada para superar esses obstáculos e promover uma abordagem mais hands-on ao estudo da física.

## O Projeto Dinamômetro Digital
Este repositório contém todos os recursos necessários para construir e utilizar seu próprio dinamômetro digital, incluindo códigos-fonte, instruções de montagem, exemplos de experimentos e materiais educativos complementares. A ferramenta é projetada para ser acessível, com baixo custo de produção e fácil integração em qualquer ambiente educacional, desde salas de aula tradicionais até laboratórios de ciências domésticos.

Ao proporcionar uma maneira tangível de medir forças e explorar a mecânica Newtoniana, esperamos não apenas enriquecer o processo educativo mas também inspirar uma nova geração de cientistas, engenheiros e entusiastas da física. Através da colaboração e contribuição da comunidade open source, este projeto está em constante evolução, buscando sempre melhorar e expandir suas capacidades.

Convidamos você a explorar nosso repositório, contribuir com o projeto e juntar-se a nós nessa jornada para tornar o aprendizado de física mais interativo, acessível e eficaz para todos


## Autoria
Criado para FATEC Ribeirão Preto - Curso de Sistemas Biomédicos.

Autor Marcelo Maurin Martins
email: marcelomaurinmartins@gmail.com

## Relação de Peças
 - ESP32 Duino
 - Celula de Carga 5kg
 - HX711
 - 6 Fios para soldagen
 - Roldana parafusavel
 - Fonte 12V DC
 - 2 parafusos
 - Peças imprimiveis (arquivos STL)

## PinOut

- LOADCELL_DOUT_PIN = 18
- LOADCELL_SCK_PIN = 19

## HX711 Conexoes
<img src="https://github.com/marcelomaurin/dinanometro/blob/main/img/ligcelula.JPG">

## Imagens
<img src="https://github.com/marcelomaurin/dinanometro/blob/main/img/dinamometro.jpeg">

## Funcionamento
O Conjunto consiste de:
- Equipamento eletrônico
- Peças plasticas imprimiveis
- Softwares de coleta de medidas.



## Peças Imprimiveis

### Suporte de Parede
Suporte de parede para instalação do equipamento de medição
- Arquivo: /stl/suporte.stl
- Arquivo solid: /solid/suporte.sldprt

Caixa de fixação do ESP32
- Arquivo solid: /solid/caixa.sldprt
- Arquiv /stl/caixa.stl

## Software
Software compatível com Windows.
Notebook ou PC precisa de Bluetooth para comunicar com equipamento.

### Screens do Software
#### Apresentação
<img src="https://github.com/marcelomaurin/dinanometro/blob/main/img/software01.JPG">
#### Operação
<img src="https://github.com/marcelomaurin/dinanometro/blob/main/img/software02.JPG">
#### Força sobre tempo
<img src="https://github.com/marcelomaurin/dinanometro/blob/main/img/software03.JPG">
#### Configurações
<img src="https://github.com/marcelomaurin/dinanometro/blob/main/img/software04.JPG">

### Requisitos
Windows 7 ou superior, 4Gb de Ram, 50Mb de Disco livre.

### Instalação
Execute o instalador mais recente, localizado na pasta bin.


# Bibliografia
- https://randomnerdtutorials.com/esp32-load-cell-hx711/
- https://techtutorialsx.com/2018/12/09/esp32-arduino-serial-over-bluetooth-client-connection-event/
- https://mundoprojetado.com.br/hx711/


# English
# Digital Dynamometer: Open Source Tool for Teaching Newtonian Forces
## Introduction
Welcome to the Digital Dynamometer repository, an open source project dedicated to transforming the teaching and study of Newtonian forces through a practical and interactive approach. Developed with the goal of providing a deeper understanding of Newton's laws of motion, this project offers an innovative educational tool that allows students and educators to measure and analyze forces in the real world with ease and accuracy.

Newton's laws are fundamental pillars of physics, describing the principles of motion and the relationship between objects and the forces acting upon them. Despite their undisputed importance, teaching these concepts often faces significant challenges, especially when it comes to translating theory into practical experience. The Digital Dynamometer emerges as a solution to these challenges, offering a bridge between theoretical knowledge and real-world application.

## The Digital Dynamometer Project
This repository contains all the resources needed to build and use your own digital dynamometer, including source codes, assembly instructions, experiment examples, and complementary educational materials. The tool is designed to be accessible, with low production cost and easy integration into any educational environment, from traditional classrooms to home science labs.

By providing a tangible way to measure forces and explore Newtonian mechanics, we hope not only to enrich the educational process but also to inspire a new generation of scientists, engineers, and physics enthusiasts. Through the collaboration and contribution of the open source community, this project is constantly evolving, always seeking to improve and expand its capabilities.

We invite you to explore our repository, contribute to the project, and join us on this journey to make physics learning more interactive, accessible, and effective for everyone.

## Authorship
Created for FATEC Ribeirão Preto - Biomedical Systems Course.

Author: Marcelo Maurin Martins
Email: marcelomaurinmartins@gmail.com

## List of Parts
- ESP32 Duino
- 5kg Load Cell
- HX711
- 6 Wires for soldering
- Screw-in Pulley
- 12V DC Power Supply
- 2 Screws
- Printable parts (STL files)

## PinOut
- LOADCELL_DOUT_PIN = 18
- LOADCELL_SCK_PIN = 19

## Operation
The Set consists of:
- Electronic equipment
- Printable plastic parts
- Software for measuring collection.

## Printable Parts
### Wall Bracket
Wall bracket for installing the measuring equipment
- File: /stl/support.stl
- Solid file: /solid/support.sldprt

ESP32 fixing box
- Solid file: /solid/box.sldprt
- File /stl/box.stl

## Software
Software compatible with Windows.
A Notebook or PC needs Bluetooth to communicate with the equipment.

### Requirements
Windows 7 or higher, 4Gb of Ram, 50Mb of free Disk.

### Installation
Run the latest installer, located in the bin folder.

# Bibliography
- https://randomnerdtutorials.com/esp32-load-cell-hx711/
- https://techtutorialsx.com/2018/12/09/esp32-arduino-serial-over-bluetooth-client-connection-event/
- https://mundoprojetado.com.br/hx711/

# French
# Dynamomètre Numérique : Outil Open Source pour l'Enseignement des Forces Newtoniennes
## Introduction
Bienvenue dans le dépôt du Dynamomètre Numérique, un projet open source dédié à transformer l'enseignement et l'étude des forces newtoniennes à travers une approche pratique et interactive. Développé dans le but de fournir une compréhension plus profonde des lois du mouvement de Newton, ce projet propose un outil éducatif innovant permettant aux étudiants et aux éducateurs de mesurer et d'analyser les forces dans le monde réel avec facilité et précision.

Les lois de Newton sont des piliers fondamentaux de la physique, décrivant les principes du mouvement et la relation entre les objets et les forces agissant sur eux. Malgré leur importance incontestée, l'enseignement de ces concepts se heurte souvent à des défis significatifs, notamment lorsqu'il s'agit de traduire la théorie en expérience pratique. Le Dynamomètre Numérique émerge comme une solution à ces défis, offrant un pont entre la connaissance théorique et l'application réelle.

## Le Projet Dynamomètre Numérique
Ce dépôt contient toutes les ressources nécessaires pour construire et utiliser votre propre dynamomètre numérique, y compris les codes sources, les instructions de montage, des exemples d'expériences et des matériaux éducatifs complémentaires. L'outil est conçu pour être accessible, avec un faible coût de production et une intégration facile dans tout environnement éducatif, des salles de classe traditionnelles aux laboratoires de sciences à domicile.

En fournissant un moyen tangible de mesurer les forces et d'explorer la mécanique newtonienne, nous espérons non seulement enrichir le processus éducatif mais aussi inspirer une nouvelle génération de scientifiques, d'ingénieurs et d'enthousiastes de la physique. Grâce à la collaboration et à la contribution de la communauté open source, ce projet évolue constamment, cherchant toujours à améliorer et à étendre ses capacités.

Nous vous invitons à explorer notre dépôt, à contribuer au projet et à vous joindre à nous dans ce voyage pour rendre l'apprentissage de la physique plus interactif, accessible et efficace pour tous.

## Auteur
Créé pour FATEC Ribeirão Preto - Cours de Systèmes Biomédicaux.

Auteur : Marcelo Maurin Martins
Email : marcelomaurinmartins@gmail.com

## Liste des Pièces
- ESP32 Duino
- Cellule de Charge 5kg
- HX711
- 6 Fils pour soudure
- Poulie vissable
- Alimentation 12V DC
- 2 vis
- Pièces imprimables (fichiers STL)

## PinOut
- LOADCELL_DOUT_PIN = 18
- LOADCELL_SCK_PIN = 19

## Fonctionnement
L'ensemble se compose de :
- Équipement électronique
- Pièces en plastique imprimables
- Logiciels de collecte de mesures.

## Pièces Imprimables
### Support Mural
Support mural pour l'installation de l'équipement de mesure
- Fichier : /stl/support.stl
- Fichier solide : /solid/support.sldprt

Boîte de fixation de l'ESP32
- Fichier solide : /solid/boite.sldprt
- Fichier /stl/boite.stl

## Logiciel
Logiciel compatible avec Windows.
Un ordinateur portable ou un PC a besoin de Bluetooth pour communiquer avec l'équipement.

### Exigences
Windows 7 ou supérieur, 4Go de Ram, 50Mo de disque libre.

### Installation
Exécutez le dernier installateur, situé dans le dossier bin.

# Bibliographie
- https://randomnerdtutorials.com/esp32-load-cell-hx711/
- https://techtutorialsx.com/2018/12/09/esp32-arduino-serial-over-bluetooth-client-connection-event/
- https://mundoprojetado.com.br/hx711/

# Spanish
# Dinamómetro Digital: Herramienta Open Source para la Enseñanza de Fuerzas Newtonianas
## Introducción
Bienvenido al repositorio del Dinamómetro Digital, un proyecto de código abierto dedicado a transformar la enseñanza y el estudio de las fuerzas newtonianas a través de un enfoque práctico e interactivo. Desarrollado con el objetivo de proporcionar una comprensión más profunda de las leyes de movimiento de Newton, este proyecto ofrece una herramienta educativa innovadora que permite a estudiantes y educadores medir y analizar fuerzas en el mundo real con facilidad y precisión.

Las leyes de Newton son pilares fundamentales de la física, describiendo los principios del movimiento y la relación entre los objetos y las fuerzas que actúan sobre ellos. A pesar de su importancia indiscutible, la enseñanza de estos conceptos a menudo enfrenta desafíos significativos, especialmente cuando se trata de traducir la teoría en experiencia práctica. El Dinamómetro Digital surge como una solución a estos desafíos, ofreciendo un puente entre el conocimiento teórico y la aplicación real.

## El Proyecto Dinamómetro Digital
Este repositorio contiene todos los recursos necesarios para construir y utilizar tu propio dinamómetro digital, incluyendo códigos fuente, instrucciones de montaje, ejemplos de experimentos y materiales educativos complementarios. La herramienta está diseñada para ser accesible, con un bajo costo de producción y fácil integración en cualquier entorno educativo, desde aulas tradicionales hasta laboratorios de ciencias domésticos.

Al proporcionar una manera tangible de medir fuerzas y explorar la mecánica newtoniana, esperamos no solo enriquecer el proceso educativo sino también inspirar a una nueva generación de científicos, ingenieros y entusiastas de la física. A través de la colaboración y contribución de la comunidad de código abierto, este proyecto está en constante evolución, buscando siempre mejorar y expandir sus capacidades.

Te invitamos a explorar nuestro repositorio, contribuir al proyecto y unirte a nosotros en este viaje para hacer que el aprendizaje de la física sea más interactivo, accesible y efectivo para todos.

## Autoría
Creado para FATEC Ribeirão Preto - Curso de Sistemas Biomédicos.

Autor: Marcelo Maurin Martins
Email: marcelomaurinmartins@gmail.com

## Lista de Piezas
- ESP32 Duino
- Célula de Carga 5kg
- HX711
- 6 Cables para soldadura
- Polea atornillable
- Fuente de alimentación 12V DC
- 2 tornillos
- Piezas imprimibles (archivos STL)

## PinOut
- LOADCELL_DOUT_PIN = 18
- LOADCELL_SCK_PIN = 19

## Funcionamiento
El conjunto consiste en:
- Equipo electrónico
- Piezas plásticas imprimibles
- Software para la recolección de medidas.

## Piezas Imprimibles
### Soporte de Pared
Soporte de pared para la instalación del equipo de medición
- Archivo: /stl/soporte.stl
- Archivo sólido: /solid/soporte.sldprt

Caja de fijación del ESP32
- Archivo sólido: /solid/caja.sldprt
- Archivo /stl/caja.stl

## Software
Software compatible con Windows.
Una Notebook o PC necesita Bluetooth para comunicarse con el equipo.

### Requisitos
Windows 7 o superior, 4Gb de Ram, 50Mb de Disco libre.

### Instalación
Ejecuta el instalador más reciente, ubicado en la carpeta bin.

# Bibliografía
- https://randomnerdtutorials.com/esp32-load-cell-hx711/
- https://techtutorialsx.com/2018/12/09/esp32-arduino-serial-over-bluetooth-client-connection-event/
- https://mundoprojetado.com.br/hx711/

# German
# Digitaler Dynamometer: Open-Source-Werkzeug zum Lehren Newtonscher Kräfte
## Einführung
Willkommen im Repository des Digitalen Dynamometers, einem Open-Source-Projekt, das sich der Transformation des Unterrichts und des Studiums der newtonschen Kräfte durch einen praktischen und interaktiven Ansatz widmet. Entwickelt mit dem Ziel, ein tieferes Verständnis der Bewegungsgesetze Newtons zu vermitteln, bietet dieses Projekt ein innovatives Bildungswerkzeug, das es Schülern und Lehrern ermöglicht, Kräfte in der realen Welt einfach und genau zu messen und zu analysieren.

Die Gesetze Newtons sind grundlegende Pfeiler der Physik, die die Prinzipien der Bewegung und die Beziehung zwischen Objekten und den auf sie wirkenden Kräften beschreiben. Trotz ihrer unbestreitbaren Bedeutung stößt die Vermittlung dieser Konzepte oft auf erhebliche Herausforderungen, insbesondere wenn es darum geht, Theorie in praktische Erfahrung umzusetzen. Der Digitale Dynamometer bietet eine Lösung für diese Herausforderungen und schafft eine Brücke zwischen theoretischem Wissen und realer Anwendung.

## Das Digitale Dynamometer-Projekt
Dieses Repository enthält alle Ressourcen, die benötigt werden, um Ihren eigenen digitalen Dynamometer zu bauen und zu verwenden, einschließlich Quellcodes, Montageanleitungen, Experimentbeispielen und ergänzenden Bildungsmaterialien. Das Werkzeug ist so konzipiert, dass es zugänglich ist, mit niedrigen Produktionskosten und einfacher Integration in jede Bildungsumgebung, von traditionellen Klassenzimmern bis hin zu Heimwissenschaftslaboren.

Indem wir eine greifbare Möglichkeit bieten, Kräfte zu messen und die newtonsche Mechanik zu erkunden, hoffen wir nicht nur, den Bildungsprozess zu bereichern, sondern auch eine neue Generation von Wissenschaftlern, Ingenieuren und Physikbegeisterten zu inspirieren. Durch die Zusammenarbeit und den Beitrag der Open-Source-Gemeinschaft entwickelt sich dieses Projekt ständig weiter und strebt immer danach, seine Fähigkeiten zu verbessern und zu erweitern.

Wir laden Sie ein, unser Repository zu erkunden, zum Projekt beizutragen und uns auf dieser Reise zu begleiten, um das Lernen von Physik interaktiver, zugänglicher und effektiver für alle zu machen.

## Urheberschaft
Erstellt für FATEC Ribeirão Preto - Studiengang Biomedizinische Systeme.

Autor: Marcelo Maurin Martins
E-Mail: marcelomaurinmartins@gmail.com

## Teileliste
- ESP32 Duino
- 5kg Lastzelle
- HX711
- 6 Drähte zum Löten
- Schraubrolle
- 12V DC Stromversorgung
- 2 Schrauben
- Druckbare Teile (STL-Dateien)

## PinOut
- LOADCELL_DOUT_PIN = 18
- LOADCELL_SCK_PIN = 19

## Funktion
Das Set besteht aus:
- Elektronisches Gerät
- Druckbare Kunststoffteile
- Software zur Messdatenerfassung.

## Druckbare Teile
### Wandhalterung
Wandhalterung zur Installation der Messausrüstung
- Datei: /stl/halterung.stl
- Solid-Datei: /solid/halterung.sldprt

Befestigungsbox für das ESP32
- Solid-Datei: /solid/kasten.sldprt
- Datei /stl/kasten.stl

## Software
Software kompatibel mit Windows.
Ein Notebook oder PC benötigt Bluetooth, um mit dem Gerät zu kommunizieren.

### Voraussetzungen
Windows 7 oder höher, 4Gb RAM, 50Mb freier Festplattenspeicher.

### Installation
Führen Sie den neuesten Installer aus, der im Bin-Ordner zu finden ist.

# Bibliografie
- https://randomnerdtutorials.com/esp32-load-cell-hx711/
- https://techtutorialsx.com/2018/12/09/esp32-arduino-serial-over-bluetooth-client-connection-event/
- https://mundoprojetado.com.br/hx711/


