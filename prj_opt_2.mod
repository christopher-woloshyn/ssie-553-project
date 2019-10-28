option solver cplex;

#create sets
set MONTH;
set MONTH_PLUS_1;

# Parameters for the objective function
param production_cost {m in MONTH};
param inventory_cost {m in MONTH};
param labor_cost {m in MONTH};
param overtime_cost {m in MONTH};
param hiring_cost {m in MONTH};
param firing_cost {m in MONTH};
param backorder_cost {m in MONTH};

# Parameters for the initial inventory
param initial_inv;
param initial_back;
param initial_work;

# Parameters for the constraints
param demand {m in MONTH};

# Decision variables
var labor {m in MONTH_PLUS_1} integer >= 0;			# of hours of regular labor
var overtime {m in MONTH} integer >= 0;				# of hours of overtime labor in month m
var trucks {m in MONTH} = labor[m] + overtime[m];	# of trucks produced (labor + overtime) in month m
var inventory {m in MONTH_PLUS_1} integer >=0;		# of trucks in inventory in month m

var workers {m in MONTH_PLUS_1} integer >= 0;		# of workers in month m
var hired {m in MONTH} integer >= 0;				# of workers hired in month m
var fired {m in MONTH} integer >= 0;				# of workers fired in month m
var backorder {m in MONTH_PLUS_1} integer >= 0;		# of trucks put on backorder in month m

# Objective Function
minimize total_cost: sum {m in MONTH}(
production_cost[m] * trucks[m] +	# (cost to produce 1 truck in month m) * (number of trucks produced in month m)
inventory_cost[m] * inventory[m] +	# (cost to keep 1 truck in inventory in month m) * (number of trucks in inventory in month m)
labor_cost[m] * workers[m] +		# (cost of 1 man-month of labor in month m) * (man-months of labor used in month m)
overtime_cost[m] * overtime[m] +	# (cost of 1 man-month of overtime labor in month m) * (man-months of overtime labor used in month m)
hiring_cost[m] * hired[m] +			# (cost to hire 1 worker in month m) * (number of workers hired in month m)
firing_cost[m] * fired[m] +			# (cost to fire 1 worker in month m) * (number of workers fired in month m)
backorder_cost[m] * backorder[m]	# (cost to put 1 truck on backorder in month m) * (number of trucks pur on backorder in month m)
);

# Constraints on the maximum amount of labor per month
s.t. max_labor {m in MONTH}: labor[m] <= workers[m];
s.t. max_overtime_labor {m in MONTH}: overtime[m] <= .25 * workers[m];

# Constraints made to update the inventory each month
s.t. set_initial_inv: inventory[0] = initial_inv;
s.t. set_initial_back: backorder[0] = initial_back;
s.t. update_inv_back {m in MONTH}: inventory[m] = inventory[m-1] + trucks[m] - demand[m] + backorder[m] - backorder[m-1];

# Constraints made to update the number of workers each month
s.t. set_initial_work: workers[0] = initial_work;
s.t. update_work {m in MONTH}: workers[m] = workers[m-1] + hired[m] - fired[m];