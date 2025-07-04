    module Meteograms

        # Write your package code here.
        using DataFrames, Statistics, INMET, Dates, PlotlyJS, Unitful, Missings
        using REPL.TerminalMenus

        #ENV["INMET_TOKEN"] = "SnFOaWF6Tmd4R1pXa1NQcVdIYlBOTWtNNVA5d29iUWI=JqNiazNgxGZWkSPqWHbPNMkM5P9wobQb"

        function __init__()
            # Configurar a variável de ambiente quando o pacote é carregado
            ENV["INMET_TOKEN"] = "SnFOaWF6Tmd4R1pXa1NQcVdIYlBOTWtNNVA5d29iUWI=JqNiazNgxGZWkSPqWHbPNMkM5P9wobQb"
            
            # Opcional: verificar se foi configurado corretamente
            if !haskey(ENV, "INMET_TOKEN")
                @warn "Falha ao configurar INMET_TOKEN"
            end
        end

        function meteorologia(start::String, finish::String, UF::String = "RS")
            
            # Realiza a verificação e localização da Área de Trabalho do Usuário
            caminho_desktop = joinpath(homedir(), "OneDrive\\Área de Trabalho")

            if !isdir("$(caminho_desktop)\\Resultados_INMET")
                mkpath("$(caminho_desktop)\\Resultados_INMET")
            else
            end 

            #Converte os valores de data em INT64 para Ano, Mês e Dia
            data_inicial = Meta.parse.(split(start, "/"))
            data_final = Meta.parse.(split(finish, "/"))
            inicio = Date(data_inicial[3], data_inicial[2], data_inicial[1])
            fim = Date(data_final[3], data_final[2], data_final[1])
            data = inicio
            
            # Definição do painel de seleção da unidade de 
            choices = 0
            controle_estacoes_disponiveis = unique(filter(x -> x.UF == UF, INMET.on(Date(data_inicial[3],data_inicial[2],data_inicial[1]))).CD_ESTACAO) .* " - " .* unique(filter(x -> x.UF == UF, INMET.on(Date(data_inicial[3],data_inicial[2],data_inicial[1]))).DC_NOME)
            estacoes_disponiveis = unique(filter(x -> x.UF == UF, INMET.on(Date(data_inicial[3],data_inicial[2],data_inicial[1]))).CD_ESTACAO)
            menu = RadioMenu(controle_estacoes_disponiveis)
            while choices == 0
                choices = request("Selecione a estação meteorológica:", menu)
            end
            
            dados = INMET.series(Symbol(estacoes_disponiveis[choices]), Date(data_inicial[3],data_inicial[2],data_inicial[1]), Date(data_final[3],data_final[2],data_final[1]), :day)
            dados2 = INMET.series(Symbol(estacoes_disponiveis[choices]), Date(data_inicial[3],data_inicial[2],data_inicial[1]), Date(data_final[3],data_final[2],data_final[1]), :hour)
            
            calc_radiacao = combine(groupby(dados2, [:CD_ESTACAO, :DT_MEDICAO])) do df
                # Processamento para RAD_GLO
                rad_vals = ustrip.(skipmissing(df.RAD_GLO))
                rad_positivos = max.(rad_vals, 0.0)
                
                # Processamento para UMD_MAX com tratamento para coleções vazias
                umid_vals = ustrip.(skipmissing(df.UMD_MAX))
                umid_max = isempty(umid_vals) ? missing : round(mean(umid_vals), digits = 1)
                
                # Retorna um NamedTuple com ambas as colunas
                (
                    RAD_GLO = sum(rad_positivos),
                    UMID_MAX = umid_max
                )
            end

            insertcols!(dados, "RAD_GLO" => calc_radiacao.RAD_GLO, "UMID_MAX" => calc_radiacao.UMID_MAX)

            # Variável auxiliar para classificação dos dados
            Meses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
            
            # Resultado final dos dados por mês
            resultado = DataFrame()

            while data <= fim
                # Confere se a pasta do ano de processamento existe
                if !isdir("$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))")
                    mkpath("$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))")
                    mkpath("$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))")
                end

                # Filtra os dados mês a mês
                if month(data) < 10
                    
                    teste = filter(x -> startswith(x.DT_MEDICAO, string(year(data))*"-0"*string(month(data))), dados)
                else
                    teste = filter(x -> startswith(x.DT_MEDICAO, string(year(data))*"-"*string(month(data))), dados)
                end

                # Define um vetor com os dias do mês
                x = 1:1:day(Dates.lastdayofmonth(data))

                # Define cada linha do gráfico
                trace_min = scatter(x=x, y=passmissing(x -> ustrip(x.val)).(teste.TEMP_MIN), mode="lines+markers", name="TEM_MIN",  line=attr(color="deepskyblue"))
                trace_med = scatter(x=x, y=passmissing(x -> ustrip(x.val)).(teste.TEMP_MED), mode="lines+markers", name="TEM_MED",  line=attr(color="limegreen"))
                trace_max = scatter(x=x, y=passmissing(x -> ustrip(x.val)).(teste.TEMP_MAX), mode="lines+markers", name="TEM_MAX",  line=attr(color="red"))

                # Define os paramêtros para a plotagem do gráfico
                layout = Layout(
                    title=attr(
                        text="Temperatura do Ar Max, Min, Med em $(Meses[month(data)]) de $(year(data))",
                        x=0.5,
                        xanchor="center",
                        font=attr(
                            family="Arial Black",
                            size=16,
                            color="black"
                        )
                    ),
                    yaxis=attr(
                        title=attr(
                            text="Temperatura do Ar (°C)",
                            font=attr(
                                family="Arial Black",
                                size=14,
                                color="black"
                            )
                        ),
                        showgrid=true,
                        gridcolor="lightgray",
                        gridwidth=1
                    ),
                    xaxis=attr(
                        tickmode="linear",
                        tick0=1,
                        dtick=1,
                        range=[0.5, day(Dates.lastdayofmonth(data)) + 0.5],
                        showgrid=false,     
                        gridcolor="lightgray",  
                        gridwidth=1             
                    ),
                    legend=attr(
                        orientation="h",
                        x=0.5,
                        xanchor="center",
                        y=-0.05,
                        font=attr(
                            family="Arial Black",
                            size=12,
                            color="black"
                        )
                    ),
                    width = 1800,
                    height = 720
                )

                fig =   plot([trace_min, trace_med, trace_max], layout)
                savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))\\Temperatura $(Meses[month(data)]) de $(year(data)).png", scale=3)

                # Define cada linha do gráfico
                trace_min = scatter(x=x, y=passmissing(x -> ustrip(x.val)).(teste.UMID_MIN), mode="lines+markers", name="UMID_MIN",  line=attr(color="deepskyblue"))
                trace_med = scatter(x=x, y=passmissing(x -> ustrip(x.val)).(teste.UMID_MED), mode="lines+markers", name="UMID_MED",  line=attr(color="limegreen"))
                trace_max = scatter(x=x, y=teste.UMID_MAX, mode="lines+markers", name="UMID_MAX",  line=attr(color="red"))

                # Define os paramêtros para a plotagem do gráfico
                layout = Layout(
                    title=attr(
                        text="Umidade Relativa do Ar Max, Min, Med em $(Meses[month(data)]) de $(year(data))",
                        x=0.5,
                        xanchor="center",
                        font=attr(
                            family="Arial Black",
                            size=16,
                            color="black"
                        )
                    ),
                    yaxis=attr(
                        title=attr(
                            text="Umidade Relativa do Ar (%)",
                            font=attr(
                                family="Arial Black",
                                size=14,
                                color="black"
                            )
                        ),
                        showgrid=true,
                        gridcolor="lightgray",
                        gridwidth=1
                    ),
                    xaxis=attr(
                        tickmode="linear",
                        tick0=1,
                        dtick=1,
                        range=[0.5, day(Dates.lastdayofmonth(data)) + 0.5],
                        showgrid=false,     
                        gridcolor="lightgray",  
                        gridwidth=1             
                    ),
                    legend=attr(
                        orientation="h",
                        x=0.5,
                        xanchor="center",
                        y=-0.05,
                        font=attr(
                            family="Arial Black",
                            size=12,
                            color="black"
                        )
                    ),
                    width = 1800,
                    height = 720
                )
     
                precipitacao = passmissing(x -> ustrip(x.val)).(teste.CHUVA)

                # Preencher valores missing com 0 para o cálculo acumulado
                precipitacao_preenchida = coalesce.(precipitacao, 0)
                
                # Calcular a precipitação acumulada
                acumulado = cumsum(precipitacao_preenchida)
                
                # Criar o gráfico de barras
                bar_plot = bar(
                    x=x,
                    y=precipitacao,
                    name="Precipitação Pluvial Diária",
                    marker_color="rgba(55, 128, 191, 0.7)",
                    opacity=0.7
                )
                
                # Criar o gráfico de linha acumulado
                line_plot = scatter(
                    x=x,
                    y=acumulado,
                    name="Preciptação Pluvial Acumulada",
                    line=attr(color="red", width=2.5),
                    yaxis="y2"
                )
                
                # Configurar o layout
                layout = Layout(
                    title=attr(
                        text="Precipitação Pluvial em $(Meses[(month(data))]) de $(year(data))",
                        x=0.5,
                        xanchor="center",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    yaxis=attr(
                        title=attr(
                            text = "Precipitação Pluvial (mm)",
                            font=attr(
                                family="Arial Black",
                                size=14,
                                color="black"
                            )
                        ),
                        side="left",
                        showgrid=true
                    ),
                    yaxis2=attr(
                        title= attr(
                            text = "Precipitação Pluvial Acumulada (mm)",
                            font=attr(
                                family="Arial Black",
                                size=14,
                                color="black"
                            )
                        ),
                        overlaying="y",
                        side="right",
                        showgrid=false,
                        zeroline=false
                    ),
                    plot_bgcolor="rgba(240, 240, 240, 0.8)",
                    legend=attr(
                        orientation="h",
                        x=0.5,
                        xanchor="center",
                        y=-0.05,
                        font=attr(
                            family="Arial Black",
                            size=12,
                            color="black"
                        )
                    ),
                    #margin=attr(r=150)  # Aumenta margem direita para o eixo secundário
                )
                
                fig = plot([bar_plot, line_plot], layout)
                savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))\\Preciptação em $(Meses[month(data)]) de $(year(data)).png", scale=3)

                fig =   plot([trace_min, trace_med, trace_max], layout)
                savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))\\Umidade Relativa $(Meses[month(data)]) de $(year(data)).png", scale=3)
            
                radiacao = teste.RAD_GLO

                # Criar o gráfico de barras
                bar_plot = bar(
                    x=x,
                    y=radiacao,
                    name="Precipitação Pluvial Diária",
                    marker_color="rgba(55, 128, 191, 0.7)",
                    opacity=0.7
                )

                # Configurar o layout
                layout = Layout(
                    title=attr(
                        text="Radiação Solar em $(Meses[(month(data))]) de $(year(data))",
                        x=0.5,
                        xanchor="center",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    yaxis=attr(
                        title=attr(
                            text = "Radiação Solar (Kj/m²)",
                            font=attr(
                                family="Arial Black",
                                size=14,
                                color="black"
                            )
                        ),
                        side="left",
                        showgrid=true
                    ),
                    plot_bgcolor="rgba(240, 240, 240, 0.8)",
                    legend=attr(
                        orientation="h",
                        x=0.5,
                        xanchor="center",
                        y=-0.05,
                        font=attr(
                            family="Arial Black",
                            size=12,
                            color="black"
                        )
                    ),
                    #margin=attr(r=150)  # Aumenta margem direita para o eixo secundário
                )
                
                fig = plot(bar_plot, layout)

                savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\$(year(data))\\Radiação Média em $(Meses[month(data)]) de $(year(data)).png", scale=3)

                resultado = vcat(
                    resultado, 
                    DataFrame(
                        Ano = year(data), 
                        Mês = Meses[month(data)], 
                        TEM_MIN = minimum([x.val for x in skipmissing(teste.TEMP_MIN)]), 
                        TEM_MED = round(mean([x.val for x in skipmissing(teste.TEMP_MED)]), digits = 1), 
                        TEM_MAX = maximum([x.val for x in skipmissing(teste.TEMP_MAX)]),
                        UMID_MIN= minimum([x.val for x in skipmissing(teste.UMID_MIN)]), 
                        UMID_MED = round(mean([x.val for x in skipmissing(teste.UMID_MED)]), digits = 1), 
                        UMID_MAX = maximum(teste.UMID_MAX),
                        RAD_GLO = round(mean(teste.RAD_GLO), digits = 1), 
                        CHUVA = maximum([x.val for x in skipmissing(teste.CHUVA)])
                    )
                )
                
                data += Month(1)
            end

            data -= Month(1)

            x = resultado.Mês

            trace_min = scatter(x=x, y=resultado.TEM_MIN, mode="lines+markers", name="TEM_MIN", line=attr(color="deepskyblue"))
            trace_med = scatter(x=x, y=resultado.TEM_MED, mode="lines+markers", name="TEM_MED", line=attr(color="limegreen"))
            trace_max = scatter(x=x, y=resultado.TEM_MAX, mode="lines+markers", name="TEM_MAX", line=attr(color="red"))

            # Define os paramêtros para a plotagem do gráfico
            layout = Layout(
                title=attr(
                    text="Temperatura do Ar Max, Min, Med em $(year(data))",
                    x=0.5,
                    xanchor="center",
                    font=attr(
                        family="Arial Black",
                        size=16,
                        color="black"
                    )
                ),
                yaxis=attr(
                    title=attr(
                        text="Temperatura do Ar (°C)",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    showgrid=true,
                    gridcolor="lightgray",
                    gridwidth=1
                ),
                xaxis=attr(
                    tickmode="linear",
                    tick0=1,
                    dtick=1,
                    showgrid=false,     
                    gridcolor="lightgray",  
                    gridwidth=1             
                ),
                legend=attr(
                    orientation="h",
                    x=0.5,
                    xanchor="center",
                    y=-0.05,
                    font=attr(
                        family="Arial Black",
                        size=12,
                        color="black"
                    )
                ),
                width=800, height=500
            )

            fig = plot([trace_min, trace_med, trace_max], layout)
            display(fig)
            savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\Resumo Mensal - Temperatura do Ar.png", scale=2)

            trace_min = scatter(x=x, y=resultado.UMID_MIN, mode="lines+markers", name="UMID_MIN", line=attr(color="deepskyblue"))
            trace_med = scatter(x=x, y=resultado.UMID_MED, mode="lines+markers", name="UMID_MED", line=attr(color="limegreen"))
            trace_max = scatter(x=x, y=resultado.UMID_MAX, mode="lines+markers", name="UMID_MAX", line=attr(color="red"))

            # Define os paramêtros para a plotagem do gráfico
            layout = Layout(
                title=attr(
                    text="Umidade do Ar Max, Min, Med em $(year(data))",
                    x=0.5,
                    xanchor="center",
                    font=attr(
                        family="Arial Black",
                        size=16,
                        color="black"
                    )
                ),
                yaxis=attr(
                    title=attr(
                        text="Umidade Relativa do Ar (%)",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    showgrid=true,
                    gridcolor="lightgray",
                    gridwidth=1
                ),
                xaxis=attr(
                    tickmode="linear",
                    tick0=1,
                    dtick=1,
                    showgrid=false,     
                    gridcolor="lightgray",  
                    gridwidth=1             
                ),
                legend=attr(
                    orientation="h",
                    x=0.5,
                    xanchor="center",
                    y=-0.05,
                    font=attr(
                        family="Arial Black",
                        size=12,
                        color="black"
                    )
                ),
                width=800, height=500
            )

            fig = plot([trace_min, trace_med, trace_max], layout)
            display(fig)
            savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\Resumo Mensal - Umidade Relativa do Ar.png", scale=2)

            precipitacao = resultado.CHUVA

            # Preencher valores missing com 0 para o cálculo acumulado
            precipitacao_preenchida = coalesce.(precipitacao, 0)
            
            # Calcular a precipitação acumulada
            acumulado = cumsum(precipitacao_preenchida)
            
            # Criar o gráfico de barras
            bar_plot = bar(
                x=x,
                y=precipitacao,
                name="Precipitação Pluvial Diária",
                marker_color="rgba(55, 128, 191, 0.7)",
                opacity=0.7
            )
            
            # Criar o gráfico de linha acumulado
            line_plot = scatter(
                x=x,
                y=acumulado,
                name="Preciptação Pluvial Acumulada",
                line=attr(color="red", width=2.5),
                yaxis="y2"
            )
            
            # Configurar o layout
            layout = Layout(
                title=attr(
                    text="Precipitação Pluvial $(year(data))",
                    x=0.5,
                    xanchor="center",
                    font=attr(
                        family="Arial Black",
                        size=14,
                        color="black"
                    )
                ),
                yaxis=attr(
                    title=attr(
                        text = "Precipitação Pluvial Diária (mm)",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    side="left",
                    showgrid=true
                ),
                yaxis2=attr(
                    title= attr(
                        text = "Precipitação Pluvial Acumulada (mm)",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    overlaying="y",
                    side="right",
                    showgrid=false,
                    zeroline=false
                ),
                plot_bgcolor="rgba(240, 240, 240, 0.8)",
                legend=attr(
                    orientation="h",
                    x=0.5,
                    xanchor="center",
                    y=-0.05,
                    font=attr(
                        family="Arial Black",
                        size=12,
                        color="black"
                    )
                ),
                #margin=attr(r=150)  # Aumenta margem direita para o eixo secundário
            )
            
            fig = plot([bar_plot, line_plot], layout)
            display(fig)
            savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\Preciptação Pluvial $(year(data)).png", scale=3)

            radiacao = resultado.RAD_GLO

            # Criar o gráfico de barras
            bar_plot = bar(
                x=x,
                y=radiacao,
                marker_color="rgba(55, 128, 191, 0.7)",
                opacity=0.7
            )

            # Configurar o layout
            layout = Layout(
                title=attr(
                    text="Radiação Solar Média em $(year(data))",
                    x=0.5,
                    xanchor="center",
                    font=attr(
                        family="Arial Black",
                        size=14,
                        color="black"
                    )
                ),
                yaxis=attr(
                    title=attr(
                        text = "Radiação Solar (Kj/m²)",
                        font=attr(
                            family="Arial Black",
                            size=14,
                            color="black"
                        )
                    ),
                    side="left",
                    showgrid=true
                ),
                plot_bgcolor="rgba(240, 240, 240, 0.8)",
                legend=attr(
                    orientation="h",
                    x=0.5,
                    xanchor="center",
                    y=-0.05,
                    font=attr(
                        family="Arial Black",
                        size=12,
                        color="black"
                    )
                ),
                #margin=attr(r=150)  # Aumenta margem direita para o eixo secundário
            )
            
            fig = plot(bar_plot, layout)
            display(fig)
            savefig(fig, "$(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])\\Radiação Solar em $(year(data)).png", scale=3)

            try 
                run(`explorer $(caminho_desktop)\\Resultados_INMET\\$(controle_estacoes_disponiveis[choices])`)
            catch e
            end

            return dados2
        end
    end
