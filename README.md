
# Meteograms.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://renilsonlisboa.github.io/Meteograms.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://renilsonlisboa.github.io/Meteograms.jl/dev/)
[![Build Status](https://github.com/renilsonlisboa/Meteograms.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/renilsonlisboa/Meteograms.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/renilsonlisboa/Meteograms.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/renilsonlisboa/Meteograms.jl)

**Meteograms.jl** é um pacote em Julia para importar, visualizar e analisar dados meteorológicos fornecidos pelo INMET (Instituto Nacional de Meteorologia do Brasil). Ele oferece ferramentas para baixar automaticamente dados por estação, filtrar por variáveis, realizar análises exploratórias e gerar gráficos de forma rápida e prática.

## 📦 Instalação

O pacote pode ser instalado diretamente via Julia REPL:

```julia
using Pkg
Pkg.add(url="https://github.com/renilsonlisboa/Meteograms.jl.git")
```

> **Requisitos**: Julia 1.6 ou superior

---

## 🚀 Funcionalidades

- 🔄 **Importação automática de dados** do INMET por código de estação ou cidade
- 🧹 **Limpeza e transformação** dos dados meteorológicos
- 📈 **Criação de gráficos** para análise de temperatura, precipitação, umidade, entre outros
- 📊 **Agrupamento e resumo estatístico** por período (diário, mensal, anual)
- 🌐 Suporte a múltiplas estações e períodos customizáveis

---

## 📂 Estrutura dos Dados

Os dados importados seguem a estrutura padrão do INMET e são retornados como `DataFrame`, com colunas como:

- `Data`
- `Temperatura_Max`
- `Temperatura_Min`
- `Precipitacao`
- `Umidade`
- `Velocidade_Vento`
- `Direcao_Vento`

---

## 🧪 Exemplo de uso

```julia
using Meteograms

# Listar estações disponíveis para uma cidade
estacoes = listar_estacoes("CURITIBA")

# Importar dados para uma estação e intervalo de datas
dados = importar_inmet("A838", "2022-01-01", "2022-12-31")

# Plotar a temperatura diária
plot_temperatura(dados; tipo=:diario)

# Gerar gráfico mensal de precipitação
plot_precipitacao(dados; tipo=:mensal)

# Obter estatísticas resumidas
resumo = resumo_meteorologico(dados)
```

---

## 📊 Exemplos de Gráficos

- Temperatura máxima e mínima com preenchimento entre curvas
- Precipitação acumulada mensal
- Boxplot de variações diárias
- Séries temporais interativas com PlotlyJS (opcional)

---

## 🛠️ Tecnologias Utilizadas

- [DataFrames](https://github.com/JuliaData/DataFrames.jl)
- [Dates](https://docs.julialang.org/en/v1/stdlib/Dates/)
- [INMET](https://github.com/JuliaClimate/INMET.jl)
- [PlotlyJS](https://github.com/JuliaPlots/PlotlyJS.jl)
- [Unitful](https://painterqubits.github.io/Unitful.jl/stable/)

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

## 🙋‍♂️ Contribuindo

Contribuições são bem-vindas! Sinta-se livre para abrir *issues*, *pull requests* ou sugerir melhorias.

---

## 📫 Contato

Para dúvidas ou sugestões:
- **Autor**: Renilson Lisboa Júnior
- **Email**: renilsonlisboajunior@exemplo.com
- **Instituição**: UFPR - Universidade Federal do Paraná

---

> Desenvolvido com ❤️ em Julia para estudos ambientais e meteorológicos no Brasil.
