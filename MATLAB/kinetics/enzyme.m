function sd = enzyme()

% Initialize model object.
enzymeMod = sbiomodel('abl phosphorylation');

% Define reactions.
reactionMod = addreaction(enzymeMod, 'S -> P');

% Set initial concentrations.
enzymeMod.species(1).InitialAmount = 1;
enzymeMod.species(2).InitialAmount = 0;

% Define kinetic law.
kineticLaw = addkineticlaw(reactionMod, 'Henri-Michaelis-Menten');

% Add rate constants.
addparameter(kineticLaw, 'Vmax', 10^-6);
addparameter(kineticLaw, 'Km', 4);
kineticLaw.ParameterVariableNames = {'Vmax', 'Km'};
kineticLaw.SpeciesVariableNames = 'S';

csObj = getconfigset(enzymeMod, 'active');
set(csObj, 'StopTime', 10^10);
sd = sbiosimulate(enzymeMod, csObj);
sbioplot(sd);
end