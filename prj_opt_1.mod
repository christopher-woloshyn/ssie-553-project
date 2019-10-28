option solver cplex;

#create sets
set MONTH;
set MONTH_PLUS_1;

# Parameters for the objective function
param production_cost {m in MONTH};
param inventory_cost {m in MONTH};
param labor_cost {m in MONTH};
param overtime_cost {m in MONTH};

# Parameters for the initial inventory
param initial_inv;

# Parameters for the constraints
param demand {m in MONTH};
param max_labor {m in MONTH};
param max_overtime {m in MONTH};

# Decision variables
var labor {m in MONTH} integer >= 0;				# Hours of regular labor
var overtime {m in MONTH} integer >= 0;				# Hours of overtime labor
var trucks {m in MONTH} = labor[m] + overtime[m];	# Number of trucks produced (labor + overtime)
var inventory {m in MONTH_PLUS_1} integer >=0;		# Number of trucks in inventory

# Objective Function
minimize total_cost: sum {m in MONTH}(
production_cost[m] * trucks[m] +	# (cost to produce 1 truck in month m) * (number of trucks produced in month m)
inventory_cost[m] * inventory[m] +	# (cost to keep 1 truck in inventory in month m) * (number of trucks in inventory in month m)
labor_cost[m] * labor[m] +			# (cost of 1 man-month of labor in month m) * (man-months of labor used in month m)
overtime_cost[m] * overtime[m]		# (cost of 1 man-month of overtime labor in month m) * (man-months of overtime labor used in month m)
);

# Constraints on the maximum amount of labor per month
s.t. max_regular_labor {m in MONTH}: labor[m] <= max_labor[m];
s.t. max_overtime_labor {m in MONTH}: overtime[m] <= max_overtime[m];

# Constraints made to update the inventory each month
s.t. set_initial_inv: inventory[0] = initial_inv;
s.t. update_inv {m in MONTH}: inventory[m] = inventory[m-1] + trucks[m] - demand[m];