# Modelo Simscape Multibody

`rotating_pendulum_multibody.slx` é a representação física do mesmo sistema
usado na EDO. O objetivo é conferir a cinemática em três dimensões e preparar a
substituição dos sólidos simples por peças CAD.

![Diagrama Multibody](figures/multibody-diagram.png)

## Abrir e simular

Com a pasta raiz do repositório definida como a pasta atual (*Current Folder*)
do MATLAB, execute:

```matlab
addpath('matlab')
addpath('matlab/multibody')
open_multibody_model
```

Para executar a comparação automática:

```matlab
report = validate_multibody_model()
```

## Cadeia física

O modelo segue a sequência:

```text
World -> O-A -> junta alpha -> A-B -> B-C -> junta beta
      -> C-D -> alinhamento do eixo -> junta psi -> D-E -> massa E
```

As transformações `O-A`, `B-C` e `C-D` representam a geometria. Em particular,

```text
C-D = [0, r, h] em B2,
z_D = a + c + h.
```

A transformação anterior à junta `psi` alinha o eixo padrão `Z` do bloco com
`X2`, eixo físico de oscilação da haste.

## Movimento das juntas acionadas

As juntas `alpha` e `beta` usam atuação por movimento. Cada conversor recebe
três entradas coerentes:

- posição angular;
- velocidade angular;
- aceleração angular.

O caso demonstrativo usa os mesmos perfis harmônicos do MATLAB. Isso é
importante em movimento acelerado: fornecer apenas posição e deixar o software
estimar derivadas pode introduzir filtragem, atraso ou forças artificiais.

A junta `psi` não recebe movimento imposto. Sua resposta resulta da gravidade,
da inércia e do movimento da base.

## Sólidos e massa

Coluna, braço, disco, suportes e haste são sólidos visuais com massa numérica
muito pequena. A massa física é concentrada em `E`. Essa configuração reproduz
a hipótese usada na EDO; ela não pretende representar ainda as inércias reais
das peças.

## Sensores e blocos de saída

O modelo exporta:

- `mbAlpha` e `mbBeta`: posições das juntas acionadas;
- `mbPsi`, `mbPsiDot` e `mbPsiDDot`: estado da junta livre;
- `mbPositionE`: posição absoluta da massa;
- `mbJointForce`: reação vetorial no pivô `D`.

As caixas visivelmente vazias são conversores `PS-Simulink`. Elas transformam
sinais físicos do Simscape em sinais comuns do Simulink e estão corretas mesmo
quando o ícone não mostra texto interno.

## Validação

O script resolve a EDO nos mesmos instantes da simulação física e compara
ângulo, velocidade, aceleração, posição de `E` e força axial. A tração é obtida
projetando a reação da junta na direção instantânea da haste.

![Comparação Multibody e equação](figures/multibody-validation.png)

A validação também confere se as juntas `alpha` e `beta` reproduzem os perfis
prescritos. No caso demonstrativo de 20 s, foram obtidos:

| Grandeza | erro máximo |
|---|---:|
| `psi` | `7.76e-9 rad` |
| `psiDot` | `3.71e-8 rad/s` |
| `psiDDot` | `1.74e-7 rad/s²` |
| posição de `E` | `2.72e-9 m` |
| tração | `1.15e-8 N` |

As juntas acionadas reproduziram `alpha` e `beta` até a precisão numérica, e a
força axial mínima foi `2.458 N`.

## Integração com CAD

Há dois caminhos usuais:

1. substituir cada sólido por um `File Solid`;
2. importar uma montagem por `smimport` e reconectar as juntas.

Em ambos os casos, preserve os referenciais `O`, `A`, `B`, `C`, `D` e `E`, os
eixos de rotação e a orientação de `C-D`. Depois, substitua massas e tensores de
inércia demonstrativos pelos valores do CAD.

Com massas reais, a resposta deixará de coincidir exatamente com a EDO de massa
pontual. Essa diferença será um resultado físico do modelo ampliado, não um erro
de implementação.