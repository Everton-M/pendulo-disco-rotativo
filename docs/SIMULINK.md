# Guia do modelo Simulink

Este guia explica como abrir, executar, interpretar e modificar o modelo
`rotating_pendulum.slx`. O diagrama foi construído somente com blocos básicos,
para que a passagem da equação diferencial ao Simulink permaneça visível.

![Diagrama completo do Simulink](figures/simulink-diagram.png)

## 1. Arquivos

- `matlab/simulink/rotating_pendulum.slx`: modelo pronto para uso;
- `matlab/simulink/build_simulink_model.m`: recria o `.slx` do zero;
- `matlab/simulink/open_simulink_model.m`: abre e enquadra o diagrama;
- `matlab/simulink/validate_simulink_model.m`: compara o Simulink com `ode45`;
- `matlab/simulink/validate_simulink_fixed_step.m`: compara `ode4` com o RK4;
- `matlab/+rotpend/defaultParameters.m`: parâmetros físicos e iniciais.

Manter o gerador em código é útil no GitHub porque arquivos `.slx` são binários:
o script mostra exatamente quais blocos, parâmetros e conexões formam o modelo.

## 2. Como abrir

Abra o MATLAB na raiz do repositório e execute:

```matlab
addpath('matlab')
addpath('matlab/simulink')
open_simulink_model
```

Também é possível abrir diretamente `matlab/simulink/rotating_pendulum.slx`.

## 3. Como executar

Na janela do Simulink, pressione o botão **Run**. O tempo final padrão é 20 s.
Ao terminar, abra:

- `Scope estados`: mostra, nessa ordem, `psiDDot`, `psiDot` e `psi`;
- `Scope tensao`: mostra a força de tração calculada.

Os blocos `Salvar ...` também criam séries temporais chamadas `simPsi`,
`simPsiDot`, `simPsiDDot` e `simTension` na saída da simulação.

Para executar pela linha de comando:

```matlab
out = sim('rotating_pendulum');
plot(out.simPsi.Time, rad2deg(out.simPsi.Data))
xlabel('Tempo [s]')
ylabel('\psi [graus]')
grid on
```

## 4. Como ler o diagrama

O caminho principal é:

```text
Equação dinâmica -> dividir por l -> psiDDot -> Integrador -> psiDot
                                                   |
                                                   v
                                              Integrador -> psi
```

O ângulo `psi` retorna aos blocos `sin(psi)` e `cos(psi)`. Essa realimentação
fecha a equação diferencial não linear. O tempo produzido pelo bloco `Tempo t`
gera `beta(t) = beta0 + betaRate*t`.

Os três termos que entram no bloco `Equacao dinamica` são:

```text
+ (alphaRate + betaRate)^2 * (r + l*sin(psi)) * cos(psi)
- g*sin(psi)
- b*alphaRate^2*sin(beta)*cos(psi)
```

O bloco `Dividir por l` transforma essa soma em `psiDDot`.

## 5. Condições iniciais e parâmetros

As condições iniciais ficam nos dois integradores:

- `Integrador psiDot`: `p.psiRate0`;
- `Integrador psi`: `p.psi0`.

Os parâmetros são armazenados no workspace do próprio modelo. Para mudar os
valores padrão de forma permanente, edite `defaultParameters.m` e reconstrua:

```matlab
build_simulink_model(false)
```

Os ângulos devem estar em radianos. Por exemplo:

```matlab
p.psi0 = deg2rad(15);
```

## 6. Solver

O modelo é entregue com:

- tipo: `Variable-step`;
- solver: `ode45`;
- tolerância relativa: `1e-8`;
- tolerância absoluta: `1e-10`;
- passo máximo: `0.01 s`.

Para reproduzir um RK4 de passo fixo, abra **Model Settings > Solver** e use:

- tipo: `Fixed-step`;
- solver: `ode4 (Runge-Kutta)`;
- passo: `0.002`.

Passo fixo é importante quando o modelo será executado em tempo real ou gerará
código. Para análise numérica inicial, o passo variável é mais conveniente.

## 7. Validação automática

Execute:

```matlab
report = validate_simulink_model()
fixedReport = validate_simulink_fixed_step()
```

O procedimento simula o `.slx`, resolve a mesma equação com `ode45`, compara
`psi` e `psiDot` nos mesmos instantes e verifica se a tração permanece positiva.

Na configuração entregue, foram obtidos aproximadamente:

```text
erro máximo em psi:     5.73e-10 rad
erro máximo em psiDot:  2.48e-09 rad/s
tração mínima:          2.456 N
```

Com `ode4` e passo fixo de 0,002 s, a comparação com o RK4 implementado neste
projeto apresentou erros de aproximadamente 2,39e-15 rad em `psi` e
1,02e-14 rad/s em `psiDot`.

## 8. Significado de r, h e c

- `r` é a distância radial de `C` a `D` e aparece no termo centrífugo;
- `h` é a distância vertical de `C` a `D`;
- `c` é a distância vertical de `B` a `C`;
- a altura de `D` em relação a `B` é `c + h`.

Como `c` e `h` são deslocamentos verticais constantes, eles não aparecem na
equação angular ideal. Ambos aparecem na posição absoluta usada na trajetória
3D. O modelo Simulink atual resolve a dinâmica angular e a tração; a posição 3D
continua sendo calculada pelo pós-processamento MATLAB.

## 9. Próxima etapa: modelo físico 3D

Este `.slx` é um modelo **por equações**. A montagem de sólidos, juntas e corpos
é uma etapa diferente, feita no Simscape Multibody. A sequência recomendada é:

1. validar este diagrama contra MATLAB;
2. criar os corpos e juntas no Simscape Multibody;
3. importar ou associar a geometria CAD;
4. comparar `psi`, posição de `E` e forças de vínculo entre os dois modelos.

Assim, diferenças no modelo 3D podem ser atribuídas à geometria, massa ou
juntas, pois a equação matemática já foi validada separadamente.
