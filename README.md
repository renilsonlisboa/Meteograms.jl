
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
Pkg.add(url="https://github.com/renilsonlisboa/Meteograms.jl")
```

> **Requisitos**: Julia 1.10 ou superior

## 🚀 Funcionalidades

- 🔄 **Importação automática de dados** do INMET por código de estação ou cidade
- 🧹 **Limpeza e transformação** dos dados meteorológicos
- 📈 **Criação de gráficos** para análise de temperatura, precipitação, umidade, entre outros
- 📊 **Agrupamento e resumo estatístico** por período (diário, mensal, anual)
- 🌐 Suporte a múltiplas estações e períodos customizáveis

## 📂 Estrutura dos Dados

Os dados importados seguem a estrutura padrão do INMET e são retornados como `DataFrame`, com colunas como:

- `Data`
- `Temperatura_Max`
- `Temperatura_Min`
- `Precipitacao`
- `Umidade`
- `Velocidade_Vento`
- `Direcao_Vento`



## 🧪 Exemplo de uso

```julia
using Meteograms

Meteograms.meteorologia("01/01/2025", "31/05/2025", "RS")

```

## 📊 Exemplos de Gráficos

- Temperatura máxima e mínima com preenchimento entre curvas
- Precipitação acumulada mensal
- Boxplot de variações diárias
- Séries temporais interativas com PlotlyJS


## 🙋‍♂️ Contribuindo

Contribuições são bem-vindas! Sinta-se livre para abrir *issues*, *pull requests* ou sugerir melhorias.

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).