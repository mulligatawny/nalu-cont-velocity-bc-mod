Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs 
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0

  - name: solve_cont
    type: tpetra
    method: gmres 
    preconditioner: muelu 
    tolerance: 1e-5
    max_iterations: 100
    kspace: 100
    output_level: 0
    recompute_preconditioner: no
    muelu_xml_file_name: milestone.xml

realms:

  - name: fluidRealm
    mesh: ../chan-coarse.exo
    use_edges: yes 
    automatic_decomposition_type: rcb

    time_step_control:
     target_courant: 1.0
     time_step_change_factor: 1.1
   
    equation_systems:
      name: theEqSys
      max_iterations: 2 
  
      solver_system_specification:
        pressure: solve_cont
        velocity: solve_scalar

      systems:

        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: [fluid-QUAD]
        value:
          pressure: 0.0
          velocity: [1.0,0.0]

    material_properties:
      target_name: [fluid-QUAD]
      specifications:
        - name: density
          type: constant
          value: 1.2

        - name: viscosity
          type: constant
          value: 0.008

    solution_options:
      turbulence_model: laminar
      name: myOptions

      options:

        - hybrid_factor:
            velocity: 0.0

        - limiter:
            pressure: no
            velocity: no

        - projected_nodal_gradient:
            pressure: element
            velocity: element 

    boundary_conditions:

    - inflow_boundary_condition: bc_1
      target_name: inlet
      inflow_user_data:
        velocity: [0.1,0.0]
        use_cont_velocity_bc: yes
 
    - open_boundary_condition: bc_2
      target_name: outlet
      open_user_data:
        pressure: 0.0
#        velocity: [1.0,0.0]

    - wall_boundary_condition: bc_3
      target_name: top-wall
      wall_user_data:
        velocity: [0.0,0.0]
        use_wall_function: no

    - wall_boundary_condition: bc_3
      target_name: bottom-wall
      wall_user_data:
        velocity: [0.0,0.0]
        use_wall_function: no

    output:
      output_data_base_name: output/out.e
      output_frequency: 100 
      output_node_set: no 
      output_variables:
       - velocity
       - pressure

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: 200
      time_step: 1.0e-2
      time_stepping_type: adaptive 
      time_step_count: 0
      second_order_accuracy: yes

      realms:
        - fluidRealm
