# Pêndulo em disco rotativo — dinâmica não linear em MATLAB

Projeto de portfólio que liga a derivação analítica de um sistema com três
rotações consecutivas ao modelo físico, à integração numérica e a uma futura
implementação em Simulink/CAD.

O sistema possui um braço de comprimento `b`, um disco cujo pivô está a uma
distância radial `r` e vertical `h` de seu centro, e um pêndulo de comprimento `l`. As velocidades
angulares do braço e do disco são prescritas e constantes; o ângulo do pêndulo
é a coordenada dinâmica.

## Resultado principal

Para as convenções de eixos documentadas no relatório, a equação ideal é

```text
l*psiDDot + g*sin(psi)
  + b*alphaRate^2*sin(beta)*cos(psi)
  - (alphaRate + betaRate)^2*(r + l*sin(psi))*cos(psi) = 0,
```

com `beta(t) = beta0 + betaRate*t`. O modelo também aceita, opcionalmente,
amortecimento viscoso no pivô e torque externo.

## Exemplo de saída

![Resposta angular calculada por RK4 e ode45](docs/figures/angular-response.png)

| Grandezas físicas | Trajetória absoluta da massa |
|---|---|
| ![Tração e energia](docs/figures/physical-outputs.png) | ![Trajetória 3D](docs/figures/mass-trajectory.png) |

## Modelo Simulink

![Diagrama do modelo Simulink](docs/figures/simulink-diagram.png)

O arquivo `matlab/simulink/rotating_pendulum.slx` implementa a equação em
blocos, com dois integradores, scopes, cálculo da tração e exportação dos
sinais. Para abrir e validar:

```matlab
addpath('matlab')
addpath('matlab/simulink')
open_simulink_model
report = validate_simulink_model()
fixedReport = validate_simulink_fixed_step()
```

Consulte o [guia detalhado do Simulink](docs/SIMULINK.md) para aprender a ler,
executar e modificar o diagrama.
## Modelo físico Simscape Multibody

![Diagrama do modelo físico](docs/figures/multibody-diagram.png)

O arquivo `matlab/multibody/rotating_pendulum_multibody.slx` representa a
montagem com corpos, referenciais, juntas, gravidade, motores prescritos e
sensores. Para abrir e validar:

```matlab
addpath('matlab')
addpath('matlab/multibody')
open_multibody_model
report = validate_multibody_model()
```

![Comparação entre Multibody e equação](docs/figures/multibody-validation.png)

Consulte o [guia do Simscape Multibody](docs/MULTIBODY.md) para a descrição
dos referenciais, validação e futura substituição dos sólidos por peças CAD.

> Os valores de `defaultParameters.m` são apenas ilustrativos. Substitua-os
> por dimensões, massa e condições de operação medidas ou extraídas do CAD.

## Estrutura

```text
pendulo-disco-rotativo/
├── matlab/
│   ├── +numerics/rk4.m             # RK4 clássico genérico
│   ├── +post/plotSimulation.m      # gráficos e trajetória 3D
│   ├── +rotpend/                    # modelo físico e simulação
│   ├── multibody/                   # modelo físico Simscape e validação
│   ├── simulink/                    # modelo SLX, gerador e validação
│   ├── tests/                       # testes de convergência e consistência
│   └── run_simulation.m             # exemplo reproduzível
├── report/
│   └── main.tex                     # relatório completo em LaTeX
└── results/                         # saídas geradas (ignoradas pelo Git)
```

## Como executar

Requisitos: MATLAB R2024a ou versão recente com o framework de testes padrão.

No MATLAB, abra a pasta do projeto e execute:

```matlab
run('matlab/run_simulation.m')
```

O script compara o RK4 de passo fixo com `ode45`, imprime o erro máximo entre
os estados e salva gráficos em `results/`.

Para os testes:

```matlab
addpath('matlab')
results = run_all_tests();
```

## Compilação do relatório

O relatório usa apenas pacotes LaTeX usuais. Com TeX Live/MiKTeX e `latexmk`:

```text
cd report
latexmk -pdf main.tex
```

Ele também pode ser enviado diretamente ao Overleaf junto com a pasta
`matlab/`, pois inclui trechos do código por caminho relativo.

## Correspondência com CAD e Simulink

| Entidade física | Parâmetro/junta | Modelo |
|---|---|---|
| coluna `O–A` | `a`, deslocamento vertical | só posição absoluta |
| braço `A–B` | `b`, junta rotativa em `Z` | `alpha(t)` |
| suporte `B–C` | `c`, deslocamento vertical | só posição absoluta |
| suporte `C–D` | `r` em `+Y2`, `h` em `+Z2` | raio e altura do pivô |
| haste `D–E` | `l`, junta rotativa em `X2` | estado `psi(t)` |
| massa em `E` | `m` | massa pontual |

No Simulink, a função `rotpend.rhs` pode ser transcrita para um bloco MATLAB
Function alimentando dois integradores em cascata. Para um modelo físico 3D,
as mesmas origens e direções devem ser usadas nas juntas do Simscape
Multibody; isso torna a comparação de posição, aceleração e tensão direta.

## Hipóteses e limites

- haste sem massa, rígida e sempre tracionada;
- massa concentrada em `E`;
- velocidades `alphaRate` e `betaRate` impostas por atuadores ideais;
- ausência de folgas, flexibilidade e resistência do ar no caso-base;
- `r` é radial no plano do disco e aparece no termo centrífugo;
- `h` é vertical de `C` a `D`; junto com `c`, afeta a posição absoluta, mas não
  entra na equação dinâmica ideal;
- tensão negativa indica perda de contato/haste não tracionada e invalida este
  modelo contínuo simples.

Consulte [report/main.tex](report/main.tex) para a auditoria da resolução,
derivação completa, interpretação física e estratégia de validação.
