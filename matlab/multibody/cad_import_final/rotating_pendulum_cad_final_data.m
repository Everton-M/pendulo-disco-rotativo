% Simscape(TM) Multibody(TM) version: 24.1

% This is a model data file derived from a Simscape Multibody Import XML file using the smimport function.
% The data in this file sets the block parameter values in an imported Simscape Multibody model.
% For more information on this file, see the smimport function help page in the Simscape Multibody documentation.
% You can modify numerical values, but avoid any other changes to this file.
% Do not add code to this file. Do not edit the physical units shown in comments.

%%%VariableName:smiData


%============= RigidTransform =============%

%Initialize the RigidTransform structure array by filling in null values.
smiData.RigidTransform(7).translation = [0.0 0.0 0.0];
smiData.RigidTransform(7).angle = 0.0;
smiData.RigidTransform(7).axis = [0.0 0.0 0.0];
smiData.RigidTransform(7).ID = "";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(1).translation = [277.50000000000017 0 76.000000000000071];  % mm
smiData.RigidTransform(1).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(1).axis = [1 0 0];
smiData.RigidTransform(1).ID = "B[2_conexao-2:-:3_disco-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(2).translation = [1.034461134167978e-13 -1.3557090406509204e-13 -19];  % mm
smiData.RigidTransform(2).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(2).axis = [1 0 0];
smiData.RigidTransform(2).ID = "F[2_conexao-2:-:3_disco-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(3).translation = [70.250395503564818 -1.5181732400495473 104.99999999999999];  % mm
smiData.RigidTransform(3).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(3).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(3).ID = "B[3_disco-1:-:4_corda-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(4).translation = [5.9999999999999627 0.49999999999927391 -5.4456439357863928e-13];  % mm
smiData.RigidTransform(4).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(4).axis = [-0.57735026918962584 -0.57735026918962562 0.57735026918962595];
smiData.RigidTransform(4).ID = "F[3_disco-1:-:4_corda-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(5).translation = [0 0 255.00000000000011];  % mm
smiData.RigidTransform(5).angle = 0;  % rad
smiData.RigidTransform(5).axis = [0 0 0];
smiData.RigidTransform(5).ID = "B[1_base_fixa-2:-:2_conexao-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(6).translation = [-3.1416284613105786e-12 -1.9974010756295557e-12 -2.2737367544323206e-13];  % mm
smiData.RigidTransform(6).angle = 0;  % rad
smiData.RigidTransform(6).axis = [0 0 0];
smiData.RigidTransform(6).ID = "F[1_base_fixa-2:-:2_conexao-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(7).translation = [-19.433247553764041 3.4008183219165953 1000.0000000000073];  % mm
smiData.RigidTransform(7).angle = 0;  % rad
smiData.RigidTransform(7).axis = [0 0 0];
smiData.RigidTransform(7).ID = "RootGround[1_base_fixa-2]";


%============= Solid =============%
%Center of Mass (CoM) %Moments of Inertia (MoI) %Product of Inertia (PoI)

%Initialize the Solid structure array by filling in null values.
smiData.Solid(4).mass = 0.0;
smiData.Solid(4).CoM = [0.0 0.0 0.0];
smiData.Solid(4).MoI = [0.0 0.0 0.0];
smiData.Solid(4).PoI = [0.0 0.0 0.0];
smiData.Solid(4).color = [0.0 0.0 0.0];
smiData.Solid(4).opacity = 0.0;
smiData.Solid(4).ID = "";

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(1).mass = 0.25;  % kg
smiData.Solid(1).CoM = [0 0 -8.25];  % cm
smiData.Solid(1).MoI = [2.538595931707138 2.5414221783666262 0.018116224301068819];  % kg*cm^2
smiData.Solid(1).PoI = [-0.016144676981041797 0.096868061886250217 0.00078516421614794002];  % kg*cm^2
smiData.Solid(1).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(1).opacity = 1;
smiData.Solid(1).ID = "4_corda*:*Valor predeterminado";

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(2).mass = 0.19948725169915843;  % kg
smiData.Solid(2).CoM = [20.942865876722298 0 1.9630646895575725];  % cm
smiData.Solid(2).MoI = [1.1911938270841573 26.365460134114052 26.010659393404467];  % kg*cm^2
smiData.Solid(2).PoI = [0 -1.9867489119169206 0];  % kg*cm^2
smiData.Solid(2).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(2).opacity = 1;
smiData.Solid(2).ID = "2_conexao*:*Valor predeterminado";

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(3).mass = 0.10330484701033957;  % kg
smiData.Solid(3).CoM = [0.42330261815241488 -0.00048446634215697362 0.48682358256850328];  % cm
smiData.Solid(3).MoI = [1.5298679859124904 1.7953611253541799 2.7546299896371984];  % kg*cm^2
smiData.Solid(3).PoI = [0.00047983318755422127 -0.22936337611687144 0.00031410936551380057];  % kg*cm^2
smiData.Solid(3).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(3).opacity = 1;
smiData.Solid(3).ID = "3_disco*:*Valor predeterminado";

%Inertia Type - Custom
%Visual Properties - Simple
smiData.Solid(4).mass = 0.55526545231308333;  % kg
smiData.Solid(4).CoM = [0 0 8.1886204365876356];  % cm
smiData.Solid(4).MoI = [35.70275099062814 35.70275099062814 3.9455253197330054];  % kg*cm^2
smiData.Solid(4).PoI = [0 0 0];  % kg*cm^2
smiData.Solid(4).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(4).opacity = 1;
smiData.Solid(4).ID = "1_base_fixa*:*Valor predeterminado";


%============= Joint =============%
%X Revolute Primitive (Rx) %Y Revolute Primitive (Ry) %Z Revolute Primitive (Rz)
%X Prismatic Primitive (Px) %Y Prismatic Primitive (Py) %Z Prismatic Primitive (Pz) %Spherical Primitive (S)
%Constant Velocity Primitive (CV) %Lead Screw Primitive (LS)
%Position Target (Pos)

%Initialize the RevoluteJoint structure array by filling in null values.
smiData.RevoluteJoint(3).Rz.Pos = 0.0;
smiData.RevoluteJoint(3).ID = "";

smiData.RevoluteJoint(1).Rz.Pos = -87.454295162217761;  % deg
smiData.RevoluteJoint(1).ID = "[2_conexao-2:-:3_disco-1]";

smiData.RevoluteJoint(2).Rz.Pos = 146.00850608893253;  % deg
smiData.RevoluteJoint(2).ID = "[3_disco-1:-:4_corda-1]";

smiData.RevoluteJoint(3).Rz.Pos = 55.200600511731921;  % deg
smiData.RevoluteJoint(3).ID = "[1_base_fixa-2:-:2_conexao-2]";

