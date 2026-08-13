# Modelo Simulink

O modelo `rotating_pendulum.slx` implementa a equação de movimento sem ocultar
os termos físicos em um único bloco. Essa escolha facilita a conferência entre
a derivação e o diagrama.

![Diagrama completo](figures/simulink-diagram.png)

## Arquivos

- `matlab/simulink/rotating_pendulum.slx`: modelo pronto;
- `build_simulink_model.m`: reconstrói o arquivo `.slx`;
- `open_simulink_model.m`: abre e enquadra o diagrama;
- `validate_simulink_model.m`: compara com MATLAB/`ode45`;
- `validate_simulink_fixed_step.m`: compara `ode4` com o RK4 do projeto.

## Como executar

```matlab
cd('C:\Users\E\Documents\1 - Unicamp\7 - Projetos\pendulo-disco-rotativo')
addpath('matlab')
addpath('matlab/simulink')
open_simulink_model
```

No modelo, clique em **Run**. Os Scopes mostram `[psiDDot, psiDot, psi]` e a
tração. Os blocos `To Workspace` gravam os sinais no objeto de saída da
simulação.

## Leitura do diagrama

A parte superior esquerda gera, a partir do relógio:

```text
alpha, alphaDot, alphaDDot
beta,  betaDot,  betaDDot
```

Os três sinais de cada junta vêm da mesma expressão analítica; por isso não há
incompatibilidade entre posição, velocidade e aceleração.

A região central calcula

```text
Omega = alphaDot + betaDot
rho   = r + l*sin(psi)
A_C   = b*(alphaDot^2*sin(beta) + alphaDDot*cos(beta))
```

e monta

```text
psiDDot = (Omega^2*rho*cos(psi) - g*sin(psi) - A_C*cos(psi))/l.
```

Depois, dois integradores produzem `psiDot` e `psi`. O laço fecha porque `psi`
volta aos blocos `sin(psi)` e `cos(psi)`.

`betaDDot` é gerado e exportado, embora não entre na EDO escalar. Ele é
necessário no cálculo completo da aceleração em `X2` e no modelo Multibody.

## Alterar o movimento prescrito

O caso demonstrativo usa, para cada ângulo `q`,

```text
q(t) = q0 + meanRate*t
       + amplitude*(sin(frequency*t + phase) - sin(phase)).
```

Os parâmetros ficam em `rotpend.defaultParameters`, nos campos
`alphaProfile` e `betaProfile`. Depois de alterá-los, reconstrua o modelo:

```matlab
build_simulink_model(false)
```

Para usar outra lei — uma trajetória tabelada, um sinal medido ou a saída de um
controlador — substitua os seis blocos de fonte. Preserve a ordem física:
ângulo em radianos, velocidade em rad/s e aceleração em rad/s². Não derive
numericamente um sinal ruidoso sem filtragem; forneça as derivadas da mesma lei
de movimento sempre que possível.

## Solvers

O arquivo é salvo com `ode45`, passo variável, `RelTol = 1e-8`,
`AbsTol = 1e-10` e passo máximo de `0.01 s`. Para comparar diretamente com o
RK4, o script de passo fixo troca temporariamente a configuração para `ode4` e
`0.002 s`.

```matlab
report = validate_simulink_model()
fixedReport = validate_simulink_fixed_step()
```

No caso acelerado padrão, os erros máximos observados foram:

| Comparação | erro em `psi` | erro em `psiDot` |
|---|---:|---:|
| Simulink `ode45` × MATLAB `ode45` | `2.81e-10 rad` | `1.30e-9 rad/s` |
| Simulink `ode4` × RK4 MATLAB | `8.05e-16 rad` | `4.00e-15 rad/s` |

A tração mínima foi `2.458 N`, portanto o vínculo permaneceu tracionado nesse
ensaio numérico.

## Parâmetros geométricos

`r` é a distância radial de `C` a `D`; `h` é o deslocamento vertical. Os valores
`a`, `c` e `h` afetam a posição absoluta, mas não a EDO ideal de `psi`.