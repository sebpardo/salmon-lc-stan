// RStan model of simplified example in salmon life cycle workshop

data {
  int<lower=1> N;         // number of years
  real<lower=0> s1;       // egg-to-smolt survival
  vector<lower=0>[N] s2;    // survival from smolt to pfa per year
  real<lower=0> s3;       // survival from pfa to return
  real<lower=0> propf;    // proportion female
  real<lower=0> fec;      // fecundity (4000)
  vector<lower=0>[N] h;     // harvest rate per year
  real<lower=0> cvdummy;  // cv
}

parameters {
  vector<lower=0>[N] pfa;         // juvenile growth rate (length per unit time)
  vector<lower=0>[N] returns;     // juvenile growth rate (length per unit time)
  vector<lower=0>[N] smolts;
}

transformed parameters {
  vector<lower=0>[N] eggs;        // number of eggs per fish
  vector<lower=0>[N] spawners;    // number of spawners
  vector<lower=0>[N] catches;     // number of catches
  vector[N] logsmolts;           // log smolt number
  vector[N] logreturns;          // log returns number
  vector[N] logpfa;              // log pfa

  // mulogsmolts[1] = log(s1 * 100000);
  // mulogpfa[1] = log(0.25 * 500);
  // 
  // for (t in 1:(N-1)) {
  //   mulogsmolts[t+1] = log(s1 * eggs[t]);
  //   mulogpfa[t+1] = log(s2[t] * smolts[t]);
  // }
  // 
  // for (t in 1:N) {
  //   mulogreturns[t] = log(s3 * pfa[t]);
  //   eggs[t] = spawners[t] * propf * fec;
  //   catches[t] = returns[t] * h[t];
  //   spawners[t] = returns[t] * (1 - h[t]);
  // }  

for (t in 1:N) {
    logsmolts[t] = log(smolts[t]);
    logpfa[t] = log(pfa[t]);
    logreturns[t] = log(returns[t]);
  
    eggs[t] = spawners[t] * propf * fec;
    catches[t] = returns[t] * h[t];
    spawners[t] = returns[t] * (1 - h[t]);
  }  
}

model {
  // Eggs ---> Smolts
  // survival known and fixed to 0.005 with logNormal noise with CV.dummy
  // ------------------------------------------------
  // Initialisation Smolts[t=1]
//  eggs0 = 100000;
//  elogsmolts[1] = log(s1 * eggs0);
//  smolts[1]  ~ normal(elogsmolts[1], cvdummy);
  vector[N] mulogsmolts;          // log smolt number
  vector[N] mulogreturns;         // log returns number
  vector[N] mulogpfa;             // log pfa

for (t in 1:N) {
    mulogsmolts[t] = t == 1 ? log(s1 * 100000) : log(s1 * eggs[t-1]);
    mulogpfa[t] = t == 1 ? log(0.25 * 500) : log(s2[t-1] * smolts[t-1]);
    mulogreturns[t] = log(s3 * pfa[t]);
    
    // smolts[t]  ~ lognormal(mulogsmolts[t], cvdummy);
    // pfa[t]  ~ lognormal(mulogpfa[t], cvdummy);
    // returns[t] ~ lognormal(mulogreturns[t], cvdummy);
  }

  logsmolts  ~ normal(mulogsmolts, cvdummy);
  //target += -logsmolts;
  logpfa  ~ normal(mulogpfa,  cvdummy);
 //target += -logpfa;
  logreturns ~ normal(mulogreturns, cvdummy);
  //target += -logreturns;
  
    // logsmolts = log(smolts);
    // logpfa = log(pfa);
    // logreturns = log(returns);
    // 
    // logsmolts  ~ normal(mulogsmolts, cvdummy);
    // logpfa  ~ normal(mulogpfa, cvdummy);
    // logreturns ~ normal(mulogreturns, cvdummy);

  // Smolt --> PFA survival (survival s2[t])
  // survival known with logNormal noise with CV.dummy
  // ------------------------------------------------
  // PFA --> returns with survival s3
  // survival known and fixed to 0.5 with logNormal noise with CV.dummy
  // ------------------------------------------------
}

