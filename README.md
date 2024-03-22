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

### Requisitos
Windows 7 ou superior, 4Gb de Ram, 50Mb de Disco livre.

### Instalação
Execute o instalador mais recente, localizado na pasta bin.


# Bibliografia
- https://randomnerdtutorials.com/esp32-load-cell-hx711/
- https://techtutorialsx.com/2018/12/09/esp32-arduino-serial-over-bluetooth-client-connection-event/
- https://mundoprojetado.com.br/hx711/


