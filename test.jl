using JuMP
using Combinatorics
using DataFrames
using CSV
using ExcelFiles
using DelimitedFiles
using XLSX
using BenchmarkTools
using GLPK
using Gurobi



i = 0

println("Scenario $i initiated")


##### Sets #####
# read sets
sets_df = load("Scenario$i.xlsx", "sets") |> DataFrame;
sets_df;
set_K = sets_df[!,:K]; 
set_S = sets_df[!,:S];
set_L = sets_df[!,:L];
set_N = sets_df[!,:N];

set_K = findall(!ismissing, set_K);
set_S = findall(!ismissing, set_S);
set_L = findall(!ismissing, set_L);
set_N = findall(!ismissing, set_N);

set_A = [(i,j) for (i,j) in permutations(set_N,2) if i != j]
set_IL = [(i,l) for i in set_N for l in set_L];
set_KN = [(k,i) for k in set_K for i in set_N];
set_KSA = [(k,s,i,j) for k in set_K for s in set_S for (i,j) in set_A];
set_KSN = [(k,s,i) for k in set_K for s in set_S for i in set_N];

##### Parameters with multiple indices #####
# Read from input data file
param_c_df = load("Scenario$i.xlsx", "param_cc") |> DataFrame;
# Convert and create parameters
param_c_df[!,[:k, :s, :i, :j]] = convert.(Int,param_c_df[!,[:k, :s, :i, :j]]) #convert to int
param_c_df[!,:index] = zip(param_c_df[!,:k], param_c_df[!,:s],param_c_df[!,:i],param_c_df[!,:j]) |> collect #create index col
param_c_df = DataFrames.select!(param_c_df,[:index,:value]);
param_c = eachrow(param_c_df) |> Dict # convert to dict type

param_U_df = load("Scenario$i.xlsx", "param_U") |> DataFrame;
param_U_df[!,[:s, :i, :j]] = convert.(Int,param_U_df[!,[:s, :i, :j]]);
param_U_df[!,:index] = zip(param_U_df[!,:s],param_U_df[!,:i],param_U_df[!,:j]) |> collect;
param_U_df = DataFrames.select!(param_U_df,[:index,:value]);
param_U = eachrow(param_U_df) |> Dict;

param_v_df = load("Scenario$i.xlsx", "param_vv") |> DataFrame;
param_v_df[!,[:k,:s,:i]] = convert.(Int,param_v_df[!,[:k,:s,:i]]);
param_v_df[!,:index] = zip(param_v_df[!,:k], param_v_df[!,:s],param_v_df[!,:i]) |> collect;
param_v_df = DataFrames.select!(param_v_df,[:index,:value]);
param_v = eachrow(param_v_df) |> Dict;

param_prop_df = load("Scenario$i.xlsx", "param_prop") |> DataFrame;
param_prop_df[!,[:k,:s,:i]] = convert.(Int,param_prop_df[!,[:k,:s,:i]]);
param_prop_df[!,:index] = zip(param_prop_df[!,:k], param_prop_df[!,:s],param_prop_df[!,:i]) |> collect; 
param_prop_df = DataFrames.select!(param_prop_df,[:index,:value]);
param_prop = eachrow(param_prop_df) |> Dict;

param_F_df = load("Scenario$i.xlsx", "param_F") |> DataFrame;
param_F_df[!,[:i,:l]] = convert.(Int,param_F_df[!,[:i,:l]]);
param_F_df[!,:index] = zip(param_F_df[!,:i], param_F_df[!,:l]) |> collect;
param_F_df = DataFrames.select!(param_F_df,[:index,:value]); 
param_F = eachrow(param_F_df) |> Dict;

param_d_df = load("Scenario$i.xlsx", "param_dd") |> DataFrame;
param_d_df[!,[:i,:j]] = convert.(Int,param_d_df[!,[:i,:j]]);
param_d_df[!,:index] = zip(param_d_df[!,:i], param_d_df[!,:j]) |> collect;
param_d_df = DataFrames.select!(param_d_df,[:index,:value]);
param_d = eachrow(param_d_df) |> Dict;

##### Parameters with single index #####
param_M_df = load("Scenario$i.xlsx", "param_M") |> DataFrame;
param_M_df[!,[:index]] = convert.(Int,param_M_df[!,[:index]]);
param_M = eachrow(param_M_df) |> Dict;

param_b_df = load("Scenario$i.xlsx", "param_bb") |> DataFrame;
param_b_df[!,[:index]] = convert.(Int,param_b_df[!,[:index]]);
param_b = eachrow(param_b_df) |> Dict;

param_q_df = load("Scenario$i.xlsx", "param_qq") |> DataFrame;
param_q_df[!,[:index]] = convert.(Int,param_q_df[!,[:index]]);
param_q = eachrow(param_q_df) |> Dict;

param_h_df = load("Scenario$i.xlsx", "param_hh") |> DataFrame;
param_h_df[!,[:index]] = convert.(Int,param_h_df[!,[:index]]);
param_h = eachrow(param_h_df) |> Dict;

param_p_df = load("Scenario$i.xlsx", "param_pp") |> DataFrame;
param_p_df[!,[:index]] = convert.(Int,param_p_df[!,[:index]]);
param_p = eachrow(param_p_df) |> Dict;

param_P_df = load("Scenario$i.xlsx", "param_P") |> DataFrame;
param_P_df[!,[:index]] = convert.(Int,param_P_df[!,[:index]]);
param_P = eachrow(param_P_df) |> Dict;

param_u_df = load("Scenario$i.xlsx", "param_uu") |> DataFrame;
param_u_df[!,[:index]] = convert.(Int,param_u_df[!,[:index]]);
param_u = eachrow(param_u_df) |> Dict;

param_bigM_df = load("Scenario$i.xlsx", "param_bigM") |> DataFrame;
param_bigM_df[!,[:index]] = convert.(Int,param_bigM_df[!,[:index]]);
param_bigM = eachrow(param_bigM_df) |> Dict;

# Adjusting parameters
param_D_df = load("Scenario$i.xlsx", "param_D") |> DataFrame;
param_D_df[!,[:index]] = convert.(Int,param_D_df[!,[:index]]);
param_D = eachrow(param_D_df) |> Dict;

param_alpha_df = load("Scenario$i.xlsx", "param_alpha") |> DataFrame;
param_alpha_df[!,[:index]] = convert.(Int,param_alpha_df[!,[:index]]);
param_alpha = eachrow(param_alpha_df) |> Dict;

println("Parameters set up successfully for scenario $i")


####################################################################################################################
#### Model Prep ####
# Time the model
TimeTrack_start = time();

# Preparing an optimization model
m = Model(Gurobi.Optimizer);
# m = Model(GLPK.Optimizer);

##Declaring variables

# variables
@variable(m, y[index in set_IL], Bin);
@variable(m, r[index in set_KN] >= 0, Int);
@variable(m, x[index in set_KSA] >= 0, Int);
@variable(m, z[index in set_KSN] >= 0, Int);
@variable(m, w[index in set_KSN] >= 0, Int);
@variable(m, gamma[s in set_S], Bin);


##Objective function
@objective(m, Min, sum(param_F[(i,l)] * y[(i,l)] for (i,l) in set_IL) # Fix Cost
                    + sum(param_q[k] * r[(k,n)] for (k,n) in set_KN)  # Preposition Cost
                    + sum(param_P[s] * param_c[(k,s,i,j)] * x[(k,s,i,j)] for (k,s,i,j) in set_KSA) # Scenario Specific Cost 1
                    + sum(param_P[s] * param_h[k] * z[(k,s,i)] + param_P[s] * param_p[k] * w[(k,s,i)] for (k,s,i) in set_KSN) # Scenario Specific Cost 2
            ); 

##Constraints 
# Flow Conservation
fc = @constraint(m, fc[k in set_K, s in set_S, i in set_N],
                        sum(x[(k,s,j,i)] for j in set_N if j != i) + param_prop[(k,s,i)]* r[(k,i)] - z[(k,s,i)]
                        ==
                        sum(x[(k,s,i,j)] for j in set_N if j != i) + param_v[(k,s,i)] - w[(k,s,i)]
            );

# Open Facility Capacity
ofc = @constraint(m, ofc[i in set_N],
                    sum(param_b[k] * r[(k,i)] for k in set_K)
                    <= 
                    sum(param_M[l] * y[(i,l)] for l in set_L)
            );
# Facility Number per Node
fpn = @constraint(m, fpn[i in set_N],
                sum(y[(i,l)] for l in set_L)
                <=
                1
            );
# Arc Capacity
ac = @constraint(m, ac[s in set_S, (i,j) in set_A],
                sum(param_u[k] * x[(k,s,i,j)] for k in set_K)
                <=
                param_U[(s,i,j)]
            );


# Average Distance Limit
adl = @constraint(m, adl[k in set_K, s in set_S],
                    sum(param_d[(i,j)] * x[(k,s,i,j)] for (i,j) in set_A)
                    <=
                    param_D[k] * sum(param_v[(k,s,i)] for i in set_N) + param_bigM[1] * (1 - gamma[s])            
            );

# Reliability Set Definition
rsd = @constraint(m, rsd,
                sum(param_P[s] * gamma[s] for s in set_S)
                >=
                param_alpha[1]
            );

# Demand requirements for scenarios in reliable set
dmrs = @constraint(m, dmrs[k in set_K, s in set_S, i in set_N],
                    w[(k,s,i)]
                    <=
                    param_v[(k,s,i)] * (1 - gamma[s])               
            );

println("Model successfully set up for scenario $i")
####################################################################################################################
#### Model solving ####

# Printing the prepared optimization model
# print(m)

# Solving the optimization problem
JuMP.optimize!(m)
TimeTrack_elapsed = time() - TimeTrack_start;





####################################################################################################################
#### Post-processing ####

# Print result
println("Model running time is: ", round(TimeTrack_elapsed,digits = 5),"s")
println("Model solving time:",round(JuMP.solve_time(m),digits = 5), "s")

# save the optimized variables to *_star
y_star = JuMP.value.(y);
r_star = JuMP.value.(r);
x_star = JuMP.value.(x);
z_star = JuMP.value.(z);
w_star = JuMP.value.(w);
gamma_star = JuMP.value.(gamma);

# Print objective value
println("Objective value: ", JuMP.objective_value(m))

# Print the non-zero variables
println("If a variable is not printed, the value is 0!")
for (i,l) in set_IL
    if y_star[(i,l)] == 1
        println("facility $l located in node $i")
    else end
end;

for (k,i) in set_KN
    if r_star[(k,i)] > 0
        println("Amount of commodity $k pre-position at node $i: ", r_star[(k,i)])
    else end
end;

for (k,s,i,j) in set_KSA
    if x_star[(k,s,i,j)] > 0 
    println("Amount of commodity $k shipped across link ($i,$j) in scenario $s: ", x_star[(k,s,i,j)])
    else end
end;

for (k,s,i) in set_KSN
    if z_star[(k,s,i)] > 0 
        println("Commodity $k not used in scenario $s at node $i: ", z_star[(k,s,i)] )
    else end
end;

for (k,s,i) in set_KSN
    if w_star[(k,s,i)] > 0
        println("Shortage of commodity $k at node $i in scenario $s: ", w_star[(k,s,i)])
    else end
end;

for s in set_S
    if gamma_star[s] > 0
        println("Scenario $s belong to the reliable set")
    else end
end;
