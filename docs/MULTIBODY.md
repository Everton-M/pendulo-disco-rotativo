# Modelo físico em Simscape Multibody

O arquivo `rotating_pendulum_multibody.slx` representa fisicamente o mesmo
sistema da equação diferencial. Ele contém corpos visuais, referenciais,
transformações rígidas, três juntas rotativas, gravidade, uma massa pontual em
`E`, atuação dos motores e sensores.

![Diagrama Multibody](figures/multibody-diagram.png)

## Como abrir e executar

Na raiz do repositório:

```matlab
addpath('matlab')
addpath('matlab/multibody')
open_multibody_model
```

Pressione **Run**. O Mechanics Explorer abrirá a visualização 3D. No diagrama,
os scopes mostram os estados de `psi` e a posição absoluta de `E`.

Para executar a verificação automática:

```matlab
report = validate_multibody_model()
```

## Correspondência física

| Trecho | Transformação ou junta | Significado |
|---|---|---|
| `O -> A` | `[0 0 a]` | altura da coluna |
| junta `alpha` | revoluta em `Z` | rotação absoluta do braço |
| `A -> B` | `[b 0 0]` | comprimento do braço |
| `B -> C` | `[0 0 c]` | elevação até o centro do disco |
| junta `beta` | revoluta em `Z` | rotação do disco relativa ao braço |
| `C -> D` | `[0 r h]` | raio e altura do pivô pendular |
| junta `psi` | revoluta em `X2` | movimento livre do pêndulo |
| `D -> E` | comprimento `l` | haste até a massa pontual |

A junta do pêndulo usa uma transformação de eixos para que o eixo `Z` padrão
da junta coincida com `X2`. No referencial auxiliar da junta:

```text
xJ = y2,   yJ = z2,   zJ = x2.
```

Assim, a rotação positiva `psi` leva a massa na direção radial positiva e
mantém a mesma convenção usada na derivação.

## Atuação dos motores

As juntas `alpha` e `beta` recebem movimentos prescritos:

```text
alpha(t) = alpha0 + alphaRate*t
beta(t)  = beta0  + betaRate*t
```

Os conversores recebem explicitamente três sinais:

- posição angular;
- velocidade angular constante;
- aceleração angular nula.

Fornecer as derivadas é importante. Estimá-las com um filtro faria os motores
partirem temporariamente do repouso, introduzindo uma aceleração inicial que
não existe na hipótese matemática e alterando a resposta do pêndulo.

## Massa e geometria

A derivação considera haste sem massa e partícula concentrada em `E`. Para
reproduzir isso:

- o bloco `Massa pontual E` possui massa `p.m`;
- coluna, braço, disco, suporte e haste têm massa numérica desprezível;
- os sólidos coloridos existem principalmente para visualização.

O Simscape requer propriedades de inércia válidas, por isso os sólidos visuais
usam massa `1e-9 kg` e inércia `1e-12 kg*m^2`, em vez de zero exato.

## Sensores e saídas

O modelo exporta:

| Variável | Conteúdo |
|---|---|
| `mbPsi` | ângulo do pêndulo |
| `mbPsiDot` | velocidade angular do pêndulo |
| `mbPsiDDot` | aceleração angular do pêndulo |
| `mbAlpha`, `mbBeta` | movimentos efetivamente aplicados |
| `mbPositionE` | posição absoluta 3D de `E` |
| `mbJointForce` | força vetorial de reação na junta `D` |

A tração é a projeção de `mbJointForce` na direção instantânea da haste. Como
a haste gira com `psi`, usar apenas uma componente cartesiana da força não é
suficiente.

## Resultados da validação

A comparação de 20 s contra o modelo analítico produziu:

```text
erro máximo em psi:        1.748e-08 rad
erro máximo em psiDot:     7.624e-08 rad/s
erro máximo na posição E:  6.118e-09 m
erro máximo na tração:     1.821e-08 N
tração mínima:             2.456 N
```

![Comparação Multibody e equação](figures/multibody-validation.png)

Essas diferenças são erros numéricos de solver, não uma divergência física.

## Substituição futura por CAD

Há duas estratégias possíveis.

### Preservar as juntas atuais

Exporte cada peça como STEP ou Parasolid e substitua os sólidos visuais por
blocos `File Solid`. Mantenha os `Rigid Transform`, juntas, atuadores e sensores.
Essa opção é controlada e funciona mesmo quando o CAD não exporta corretamente
as relações da montagem.

### Importar a montagem completa

Com Simscape Multibody Link, exporte a montagem do SolidWorks/Creo e use
`smimport` para criar outro modelo. Depois transfira para ele:

- movimentos prescritos de `alpha` e `beta`;
- sensores de `psi` e posição de `E`;
- configuração da gravidade;
- scripts de comparação deste projeto.

Antes da importação, crie no CAD sistemas de coordenadas em `O`, `A`, `B`, `C`,
`D` e `E`, com nomes claros. Os eixos de junta devem seguir `Z`, `Z` e `X2`.

## Quando o CAD real muda a equação

Ao substituir a massa pontual por peças reais, braço, disco e haste passam a
ter massa e tensores de inércia. O modelo Multibody continuará simulando, mas
deixará de coincidir com a equação ideal. Isso permite dois níveis de estudo:

1. manter massas desprezíveis para verificar a derivação;
2. ativar massas e inércias reais para estudar o equipamento construído.

Para uma nova equação analítica com haste massiva, a formulação deve incluir a
energia cinética rotacional e o centro de massa distribuído da haste.
