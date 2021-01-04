using DataFrames
using CSV
using CSVFiles # for providing consistent reading syntax with ExcelFiles
using ExcelFiles
using DelimitedFiles
using XLSX
using BenchmarkTools
using Plots
using StatsPlots

##
## TODO: BUILD AN AFTER ANALYSIS
# [X] BUILD a DATAFRAME for result 
# [X]BUILD a DATAFRAME for models parameters to test the running time 
    # [X] SET UP EXCEL FiLE FOR DATA INPUT 
    # [X] WRITE CODE THAT INPUT THE SETS AND PARAM DIRECTLY FROM THE EXCEL FILE
# [X] CODE FOR RUNNING MULTPLE ROUNDS
    # [X] MULTPLE INPUT
    # [X] MULTPLE OUTPUT
# [X]BUILD Plot to show the sensitivity of the running time regardings the adjusting parameters
    # [X] Create DataFrames - ALL VARS
    # [X] Create DataFrames - ALL STATS
    # [X] Plot Line chart for modeling time and solving time


###################### BUILDING DATAFRAMES #################################################
model_first = 0;
model_last = 3;
#### Variable DataFrames ####
var_Dict = Dict();
var_df = DataFrame(load("output_var0.csv"));
for i in (model_first:model_last)
    var_Dict["scenario$i"] = DataFrame(load("output_var$i.csv"))
end;

for i in (model_first+1:model_last)
    var_df = outerjoin(var_df, var_Dict["scenario$i"],on= [:variable_type,:index],makeunique=true)
end;

var_df = rename(var_df, :value => :scenario_0);
for i in (model_first+1:model_last)
    var_df = rename(var_df, "value_$i" => "scenario_$i")
end;

println(var_df);
# Export the merged dataframe
CSV.write("ScenarioCompare_vars.csv",var_df);

#### Stats DataFrames ####
stat_Dict = Dict();
stat_df = DataFrame(load("output_stat0.csv"));
for i in (model_first:model_last)
    stat_Dict["scenario$i"] = DataFrame(load("output_stat$i.csv"))

end;

for i in (model_first+1:model_last)
    stat_df = append!(stat_df, stat_Dict["scenario$i"])
end;

stat_df[!,:scenario] = convert.(Int,stat_df[!,:scenario,]);

println(stat_df);
# Export the merged stat dataframe
CSV.write("ScenarioCompare_stats.csv",stat_df);



########################## Plotting #################################################
#### DOES NOT WORK ANYMORE!!!! REVISION NEEDED###############
## Interactive Data Exploration (Uncomment to use!)
# stat_df |> Voyager()
# var_df  |> Voyager()
# stat_df
# p1_sce_sol = stat_df |> @vlplot( :point, x=:scenario, y=:solve_time)
# p2_sce_mod = stat_df |> @vlplot( :point, x=:scenario, y=:modeling_time) # not really correct as zero always have a higher model building time
# p3_sce_obj = stat_df |> @vlplot( :point, x=:scenario, y=:objective_time) # something is wrong with y axis
# p4_sce_sol = stat_df |> @vlplot( :line, x=:scenario, y=:solve_time) # maybe will be more useful when have more scenarios
stat_df
@df stat_df plot(:scenario,:objective_value)
@df stat_df plot(:scenario,:solve_time)
@df stat_df plot(:scenario,:modeling_time)

