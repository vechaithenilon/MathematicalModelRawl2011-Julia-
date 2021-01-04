# MathematicalModelRawl2011-Julia-
A mathematical model of Rawl.2011 (doi: 10.1007/s00291-011-0248-1) using Julia and JuMP

The ASHO_Multi.jl takes the input of parameters and produce a list of variables as well as some performance characteristics of the mathematical model.
The ScenarioAnalysis combines the results of different scenarios for further analysis

Input: Excel files "Scenario$i.XLSX"
Output: Csv files "output_stat$i.csv", "output_var$i.csv" (ASHO_Multi.jl) and "ScenarioCompare_stats.csv", "ScenarioCompare_vars.csv" (ScenarioAnalysis.jl)
